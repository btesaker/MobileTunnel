# MobileTunnel

Mobile TCP tunnel allowing reconnects

MobileTunnel consist of a client and server side. The client side offer a listening TCP socket. Connection on this socket is forwarded via the server side to a target service. If the connection between the client and server is broken, the MobileTunnel will try to reestablish it without interupting the forwarded connection.

The core processes is the connector and agent responsible for the tunnel. In addition there is a manager for setting things up. 


## The agent

The agent is started with the -a option. It connects the target, and emits a status line on STDOUT before going into background. The format of the status line is "<listenport><space><secret><CR><LF>".

On conection failure the agent will emit the status message "0 <connection failure string>" and exit.
On successful connection the agent listens for connections on <listenport>.

On connection it reads a 86 byte <connection string> from the socket. The connection string has the format "<verb><timestamp><sha-256><CR><LF>":

  1 <verb> 1 byte
  2 <timestamp> 19 byte textual unix timestamp in format "%12.6f"
  3 <sha-256> 64 byte hexadexmal hexadecimal sha-256 sum of the string "<verb><timestamp><secret>"
  4 <CR><LF> 2 byte newllne marker. May be any two byte combination.

If the connection string does not meet the following critera it reject the connection:

  - matches /^[SCX]\d{12}\.\d{6}[0-9a-f]{64}..$/
  - <timestamp> is newer than the last connection attemt
  - <timestamp> is within +/- 2s from correct time.
  - <sha-256> is equal to sha-256 sum of "<verb><timestamp><secret>"

When the connect string is validated, the agent acts on the <verb>:

  - "S": Write <status> to the new connection, close it and return listening for new connections
  - "X": Terminate any transfer subprocesses and exit
  - "C": Terminate any transfer subprocesses, forks new transfer subprocesses and return listening for new connections

If the target connection is shut down unexpectedly the agent should close any client side connection and wait up to 10s for a status readout. The <status> matches /^0/ for failure, /^[1-9]/ for success.

### Buffer data

Any dying transfer subprocesses writes its buffer to a temporary file xor'ed with a one time pad. Any starting transfer subprocesses loads its buffer from its predecessord file with the same pad.


## The connector

