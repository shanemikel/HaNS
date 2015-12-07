module Hans.Config (
    Config(..),
    defaultConfig,
    HasConfig(..),
  ) where

import Hans.Lens

import Data.Time.Clock (NominalDiffTime)
import Data.Word (Word8)


-- | General network stack configuration.
data Config = Config { cfgInputQueueSize :: {-# UNPACK #-} !Int

                     , cfgArpTableSize :: {-# UNPACK #-} !Int
                       -- ^ Best to pick a prime number.

                     , cfgArpTableLifetime :: !NominalDiffTime

                     , cfgArpRetry :: {-# UNPACK #-} !Int
                       -- ^ Number of times to retry an arp request before
                       -- failing

                     , cfgArpRetryDelay :: {-# UNPACK #-} !Int
                       -- ^ The amount of time to wait between arp request
                       -- retransmission.

                     , cfgIP4FragTimeout :: !NominalDiffTime
                       -- ^ Number of seconds to wait before expiring a
                       -- partially reassembled IP4 packet

                     , cfgIP4InitialTTL :: {-# UNPACK #-} !Word8

                     , cfgUdpSocketTableSize :: {-# UNPACK #-} !Int
                       -- ^ Number of buckets in the udp socket table

                     , cfgDnsResolveTimeout :: !Int
                       -- ^ In microseconds
                     }

defaultConfig :: Config
defaultConfig  = Config { cfgInputQueueSize     = 128
                        , cfgArpTableSize       = 67
                        , cfgArpTableLifetime   = 60 -- 60 seconds
                        , cfgArpRetry           = 10
                        , cfgArpRetryDelay      = 2000 -- 2 seconds
                        , cfgIP4FragTimeout     = 30
                        , cfgIP4InitialTTL      = 128
                        , cfgUdpSocketTableSize = 31
                        , cfgDnsResolveTimeout  = 5000000
                        }

class HasConfig cfg where
  config :: Getting r cfg Config

instance HasConfig Config where
  config = id
  {-# INLINE config #-}

