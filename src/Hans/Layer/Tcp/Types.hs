module Hans.Layer.Tcp.Types where

import Hans.Address.IP4
import Hans.Message.Tcp

import Control.Exception
import qualified Data.Sequence as Seq


data SocketId = SocketId
  { sidLocalPort  :: !TcpPort
  , sidRemotePort :: !TcpPort
  , sidRemoteHost :: !IP4
  } deriving (Eq,Show,Ord)

emptySocketId :: SocketId
emptySocketId  = SocketId
  { sidLocalPort  = TcpPort 0
  , sidRemotePort = TcpPort 0
  , sidRemoteHost = IP4 0 0 0 0
  }

listenSocketId :: TcpPort -> SocketId
listenSocketId port = emptySocketId { sidLocalPort = port }

incomingSocketId :: IP4 -> TcpHeader -> SocketId
incomingSocketId remote hdr = SocketId
  { sidLocalPort  = tcpDestPort hdr
  , sidRemotePort = tcpSourcePort hdr
  , sidRemoteHost = remote
  }

data SocketRequest
  = SockListen
    deriving (Show)

data SocketResult a
  = SocketResult a
  | SocketError SomeException
    deriving (Show)

socketError :: Exception e => e -> SocketResult a
socketError  = SocketError . toException

type Acceptor = SocketId -> IO ()

type Close = IO ()

data TcpSocket = TcpSocket
  { tcpSocketId  :: !SocketId
  , tcpState     :: !ConnState
  , tcpAcceptors :: Seq.Seq Acceptor
  , tcpClose     :: Seq.Seq Close
  , tcpSockSeq   :: !TcpSeqNum
  , tcpSockAck   :: !TcpAckNum
  }

setConnState :: ConnState -> TcpSocket -> TcpSocket
setConnState state tcp = tcp { tcpState = state }

emptyTcpSocket :: TcpSocket
emptyTcpSocket  = TcpSocket
  { tcpSocketId  = emptySocketId
  , tcpState     = Closed
  , tcpAcceptors = Seq.empty
  , tcpClose     = Seq.empty
  , tcpSockSeq   = TcpSeqNum 0
  , tcpSockAck   = TcpAckNum 0
  }

isAccepting :: TcpSocket -> Bool
isAccepting  = not . Seq.null . tcpAcceptors

pushAcceptor :: Acceptor -> TcpSocket -> TcpSocket
pushAcceptor k tcp = tcp { tcpAcceptors = tcpAcceptors tcp Seq.|> k }

popAcceptor :: TcpSocket -> Maybe (Acceptor,TcpSocket)
popAcceptor tcp = case Seq.viewl (tcpAcceptors tcp) of
  k Seq.:< ks -> Just (k,tcp { tcpAcceptors = ks })
  Seq.EmptyL  -> Nothing

pushClose :: Close -> TcpSocket -> TcpSocket
pushClose k tcp = tcp { tcpClose = tcpClose tcp Seq.|> k }

data ConnState
  = Closed
  | Listen
  | SynSent
  | SynReceived
  | Established
  | CloseWait
  | FinWait1
  | FinWait2
  | Closing
  | LastAck
  | TimeWait
    deriving (Show,Eq,Ord)
