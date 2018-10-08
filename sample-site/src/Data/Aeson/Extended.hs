-- |
-- Extension to Aeson, that defines project
-- naming and encoding conventions.
module Data.Aeson.Extended
  ( module Data.Aeson
  , defaultAesonOptions
  ) where

import Data.Aeson

-- | Defauilt json encoding conventions.
--
-- 1. @Nothing@ fields are omited.
-- 2. Sum values are encoded as object with a single field.
-- 3. Labels are not modified.
defaultAesonOptions :: Options
defaultAesonOptions = defaultOptions
  { omitNothingFields = True
  , sumEncoding = ObjectWithSingleField
  , fieldLabelModifier = id
  }
