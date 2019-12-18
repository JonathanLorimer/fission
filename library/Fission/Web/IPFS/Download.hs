module Fission.Web.IPFS.Download
  ( API
  , get
  ) where

import           Servant

import           Fission.Prelude
import qualified Fission.Web.Error as Web.Err

import           Network.IPFS
import qualified Network.IPFS.Types      as IPFS
import qualified Network.IPFS.Get        as IPFS
import           Network.IPFS.File.Types as File

type API =  PathAPI
       :<|> QueryAPI

type PathAPI = Capture "cid" IPFS.CID
            :> Get '[OctetStream, PlainText] File.Serialized

type QueryAPI = QueryParam "cid" IPFS.CID
             :> Get '[OctetStream, PlainText] File.Serialized

get ::
  ( MonadLocalIPFS m
  , MonadLogger    m
  , MonadThrow     m
  )
  => ServerT API m
get = pathGet :<|> queryGet

queryGet ::
  ( MonadLocalIPFS m
  , MonadLogger    m
  , MonadThrow     m
  )
  => ServerT QueryAPI m
queryGet = \case
  Just cid -> IPFS.getFile cid >>= Web.Err.ensure
  Nothing  -> throwM err404

pathGet ::
  ( MonadLocalIPFS m
  , MonadLogger    m
  , MonadThrow     m
  )
  => ServerT PathAPI m
pathGet cid = IPFS.getFile cid >>= Web.Err.ensure
