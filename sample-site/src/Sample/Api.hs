-- |
--
-- Server API.
--
-- Notes to developer:
--   
--   * Each endpoint should be written as a separate type
--   * Nesting is endpoints is encouraged.
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
module Sample.Api
  ( Api
  , swagger
  , updateSwaggerFile
  ) where

import Control.Lens
import Data.Aeson.Encode.Pretty (encodePretty)
import qualified Data.ByteString.Lazy as B.L
import Data.Proxy
import Data.Swagger
import qualified Data.Text as T
import Servant.Swagger
import Servant.API.Extended

-- | Current API version.
-- 
-- This version evolves independently form server/client/package versions.
apiVersion :: T.Text
apiVersion = "0.0.1"

swagger :: Swagger
swagger = toSwagger (Proxy @ Api)
  & info.title .~ "Experimental API"
  & info.description ?~
    "This is a benchmark site, and used for general \
    \ experiments and blog examples"
  & info.version .~ apiVersion

updateSwaggerFile :: IO ()
updateSwaggerFile = B.L.writeFile "swagger.json"
  $ encodePretty swagger

type Api
  = JsonApi

type JsonApi
  = Description
    "Raw JSON output API \
    \ For each request, an object mapping the key message to Hello, World! \
    \  must be instantiated."
  :> "json"
  :> Get '[JSON] Message

