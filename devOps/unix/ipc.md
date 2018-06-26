File

Signal / Asynchronous System Trap

Socket
-------
Data sent over a network interface, either to a different process on the same computer or to another computer on the network.
the term port (another term for a female connector) is used for external endpoints at a node, and the term socket is also used for an internal endpoint of local inter-process communication (IPC) (not over a network).

A process can refer to a socket using a socket descriptor, a type of handle. A process first requests that the protocol stack create a socket, and the stack returns a descriptor to the process so it can identify the socket.

sockets are assumed to be associated with a specific socket address, namely the IP address and a port number for the local node, and there is a corresponding socket address at the foreign node (other node), which itself has an associated socket, used by the foreign process. Associating a socket with a socket address is called binding.

In the Berkeley sockets standard, sockets are a form of file descriptor (a file handle), due to the Unix philosophy that "everything is a file"

A TCP server may serve several clients concurrently, by creating a child process for each client and establishing a TCP connection between the child process and the client. Unique dedicated sockets are created for each connection. These are in established state when a socket-to-socket virtual connection or virtual circuit (VC), also known as a TCP session, is established with the remote socket, providing a duplex byte stream.

A server may create several concurrently established TCP sockets with the same local port number and local IP address, each mapped to its own server-child process, serving its own client process. They are treated as different sockets by the operating system, since the remote socket address (the client IP address and/or port number) are different; i.e. since they have different socket pair tuples.

The socket is primarily a concept used in the transport layer of the Internet model. Networking equipment such as routers and switches do not require implementations of the Transport Layer, as they operate on the link layer level (switches) or at the internet layer (routers)

Unix domain socket 
---------
Similar to an internet socket but all communication occurs within the kernel. Domain sockets use the file system as their address space. Processes reference a domain socket as an inode, and multiple processes can communicate with one socket

Message queue
-------
Typically implemented by the operating system,

Pipe
--------
Typically a parent program opens anonymous pipes, and creates a new process that inherits the other ends of the pipes, or creates several new processes and arranges them in a pipeline.
a sequence of processes chained together by their standard streams, so that the output of each process (stdout) feeds directly as input (stdin) to the next one.
The pipe ends appear to be normal, anonymous file descriptors, except that they have no ability to seek.
In most Unix-like systems, all processes of a pipeline are started at the same time, with their streams appropriately connected, and managed by the scheduler together with all other processes running on the machine. An important aspect of this, setting Unix pipes apart from other pipe implementations, is the concept of buffering: for example a sending program may produce 5000 bytes per second, and a receiving program may only be able to accept 100 bytes per second, but no data is lost. Instead, the output of the sending program is held in the buffer. When the receiving program is ready to read data, then next program in the pipeline reads from the buffer.



Named pipe
-------
A pipe implemented through a file on the file system instead of standard input and output. Multiple processes can read and write to the file as a buffer for IPC data.
A traditional pipe is "unnamed" and lasts only as long as the process. A named pipe, however, can last as long as the system is up, beyond the life of the process. It can be deleted if no longer used. Usually a named pipe appears as a file, and generally processes attach to it for IPC.

Shared memory
------
Multiple processes are given access to the same block of memory which creates a shared buffer for the processes to communicate with each other.

POSIX also provides the mmap API for mapping files into memory; a mapping can be shared, allowing the file's contents to be used as shared memory.

With enough privileges, processes can request the kernel to map part of another process's memory space to its own, as is the case for debuggers.

Memory-mapped file
-------
A file mapped to RAM and can be modified by changing memory addresses directly instead of outputting to a stream.

