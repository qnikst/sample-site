module Sample.ApiSpec where

import           Data.Aeson
import           Data.Aeson.Diff
import           Data.Aeson.Encode.Pretty
import qualified Data.ByteString.Lazy.Char8 as BL8
import           Data.Proxy
import qualified Data.Text                  as Text
import           Data.Text.Encoding
import           Test.Hspec
import           Test.HUnit.Base            (assertFailure, (@?))

import           Sample.Api
import           Paths_sample_site

import           Servant.Swagger.Test       (validateEveryToJSON)

ppJSON :: ToJSON a => a -> String
ppJSON = Text.unpack . decodeUtf8 . BL8.toStrict . encodePretty

spec :: Spec
spec = do
  describe "Swagger spec for API v1" $ do

    context "ToJSON matches ToSchema in CacheApi" $ do
      validateEveryToJSON (Proxy :: Proxy Api)

    it "swagger.json is up-to-date" $ do
      path <- getDataFileName "swagger.json"
      eSwagger <- eitherDecode <$> BL8.readFile path
      case eSwagger of
        Left err -> assertFailure ("could not load swagger.json: " ++ err)
        Right fromFile -> do
          let fromAPI = toJSON swagger
          (fromFile == fromAPI) @? ppJSON (diff fromFile fromAPI)

