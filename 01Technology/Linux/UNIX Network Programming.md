# UNIX Network Programming - The Sockets Networking API

UNP

## Part 1 Introduction and TCP/IP

## Chapter 2: The Transport Layer: TCP, UDP, and SCTP

TCP Connection Establishment：Three-Way Handshake

TCP Connection Termination：it takes four segments to terminate a con- nection. Since a FIN and an ACK are required in each direction, four segments are normally required.

TCP establishes connections using a three-way handshake and terminates connections using a four-packet exchange.

P41 Figure 2.4: TCP State Transition Diagram

### 2.7 TIME_WAIT State

The end that performs the active close goes through TIME_WAIT State. The duration that this endpoint remains in this state is twice the maximum segment lifetime (MSL), sometimes called 2MSL.

There are two reasons for the TIME_WAIT state:

1. To implement TCP’s full-duplex connection termination reliably. (retransmit the final ACK)
2. To allow old duplicate segments to expire in the network

### 2.11 Buffer Sizes and Limitations

When an application calls write, the kernel copies all the data from the application buffer into the socket send buffer. If there is insufficient room in the socket buffer for all the application’s data (either the application buffer is larger than the socket send buffer, or there is already data in the socket send buffer), the process is put to sleep. This assumes the normal default of a blocking socket. (We will talk about nonblocking sockets in Chapter 16.) The kernel will not return from the write until the final byte in the application buffer has been copied into the socket send buffer. Therefore, the successful return from a write to a TCP socket only tells us that we can reuse our application buffer. It does not tell us that either the peer TCP has received the data or that the peer application has received the data. (We will talk about this more with the SO_LINGER socket option in Section 7.5.)

## 4 Elementary TCP Sockets

### 4.2 socket Function

To perform network I/O, the first thing a process must do is call the socket function, specifying the type of communication protocol desired (TCP using IPv4, UDP using IPv6, Unix domain stream protocol, etc.).

### 4.3 connect Function

The connect function is used by a TCP client to establish a connection with a TCP server. Initiates TCP’s three-way handshake

There are several different error returns possible.

1. If the client TCP receives no response to its SYN segment, **ETIMEDOUT** is returned.
2. If the server’s response to the client’s SYN is a reset (RST), this indicates that no process is waiting for connections on the server host at the port specified (i.e., the server process is probably not running). This is a hard error and the error **ECONNREFUSED** is returned to the client as soon as the RST is received.
3. If the client’s SYN elicits an ICMP ‘‘destination unreachable’’ from some inter- mediate router, this is considered a soft error. If no response is received after some fixed amount of time (75 sec- onds for 4.4BSD), the saved ICMP error is returned to the process as either **EHOSTUNREACH** or **ENETUNREACH**.

### 4.4 bind Function

The bind function assigns a local protocol address to a socket. With the Internet protocols, the protocol address is the combination of either a 32-bit IPv4 address or a 128-bit IPv6 address, along with a 16-bit TCP or UDP port number.

### 4.5 listen Function

The listen function is called only by a TCP server and it performs two actions:

1. When a socket is created by the socket function, it is assumed to be an active socket, that is, a client socket that will issue a connect. The listen function converts an unconnected socket into a passive socket, indicating that the kernel should accept incoming connection requests directed to this socket. In terms of the TCP state transition diagram (Figure 2.4), the call to listen moves the socket from the CLOSED state to the LISTEN state.
2. The second argument (backlog) to this function specifies the maximum number of connections the kernel should queue for this socket.

To understand the backlog argument, we must realize that for a given listening socket, the kernel maintains two queues:

1. An incomplete connection queue, which contains an entry for each SYN that has arrived from a client for which the server is awaiting completion of the TCP three-way handshake. These sockets are in the SYN_RCVD state (Figure 2.4).
2. A completed connection queue, which contains an entry for each client with whom the TCP three-way handshake has completed. These sockets are in the ESTABLISHED state (Figure 2.4).

### 4.6 accept Function

accept is called by a TCP server to return the next completed connection from the front of the completed connection queue.
