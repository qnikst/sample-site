{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE TemplateHaskell #-}
module Servant.API.Extended
  ( Message(..)
  , module Servant.API
  ) where

import Data.Aeson.Extended as Aeson
import Data.Aeson.TH
import Data.Coerce
import qualified Data.Text as T
import Data.Swagger
import Servant.API
import Test.QuickCheck
import GHC.Generics

-- | An object with JSON message message.
newtype Message = Message { message :: T.Text }
  deriving (Show, Generic)

instance Arbitrary Message where
  arbitrary = coerce . T.pack <$> arbitrary

instance ToSchema Message where
  declareNamedSchema = genericDeclareNamedSchema
    (fromAesonOptions defaultAesonOptions)

deriveJSON defaultAesonOptions ''Message

