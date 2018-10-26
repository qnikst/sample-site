{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE CApiFFI #-}
{-# LANGUAGE OverloadedStrings #-}
module Main where

import Control.Concurrent (forkIO, threadDelay)
import Control.Monad (forever)
import qualified Data.ByteString.Char8 as BS
import Prometheus
import qualified Network.HTTP.Types as HTTP
import qualified Network.Wai as Wai
import qualified Network.Wai.Handler.Warp as Warp
import Network.Wai.Middleware.Prometheus
import System.Random
import Data.Word
import Data.Text()
import Foreign.Ptr
import Foreign.C
import Foreign.Storable

process:: IO ()
process = do
  processedOps <- register $ counter
    Info{ metricName = "myapp_processed_ops_total"
        , metricHelp = "The total number of processed events"
        }
  forever $ do
    threadDelay 2000000
    incCounter  processedOps

foreign import capi "wrapper.h value gc_time" c_gc :: Ptr Word64

collectCHist :: Info -> IO [SampleGroup]
collectCHist info = do
  print (c_gc)
  s1 <- peekElemOff c_gc 0
  s2 <- peekElemOff c_gc 2
  s3 <- peekElemOff c_gc 3 
  return [SampleGroup info HistogramType $
            [ Sample "ghc_gc_elapsed_ns_bucket" [("le","1000000")]  (t s1)
            , Sample "ghc_gc_elapsed_ns_bucket" [("le","10000000")] (t s2)
            , Sample "ghc_gc_elapsed_ns_bucket" [("le","+INF")]     (t s2)
            ]
         ]
    where
      t = BS.pack . show
 

main :: IO ()
main = do
  forkIO $ process
  _ <- register $ Metric $ pure ((), collectCHist (Info "A" "B"))
  Warp.run 2020
    $ prometheus def{prometheusEndPoint=["metrics"]}
    $ \req resp -> do
        randomRIO (1,10*1000*1000) >>= threadDelay
        let headers = [(HTTP.hContentType, "text/plain; version=0.0.4")]
        resp $ Wai.responseLBS HTTP.status200 headers "OK"
