{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeOperators #-}
module Sample.Server
  ( server
  , run
  ) where

import qualified Network.Wai.Handler.Warp as Warp
import Network.Wai.Middleware.Prometheus
import Sample.Api
import Servant
import Servant.API.Extended
import Servant.Swagger.UI

type API
  = SwaggerSchemaUI "swagger-ui" "swagger.json"
  :<|> Api

run :: IO ()
run = do
  Warp.run configPort
    $ prometheus def {
        prometheusInstrumentPrometheus = False
        }
    $ serve (Proxy @API)
    $ swaggerSchemaUIServer swagger 
        :<|> server
  where
    configPort :: Int
    configPort = 8080

server :: Handler Message
server = pure $ Message "Hello World!"
