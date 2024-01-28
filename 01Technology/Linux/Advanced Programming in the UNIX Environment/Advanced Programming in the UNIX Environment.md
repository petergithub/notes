# Advanced Programming in the UNIX Environment

APUE 3rd Edition

## Chapter 3. File I/O

### 3.10 File Sharing

Figure 3.7 shows a pictorial arrangement of these three tables for a single process that has two different files open: one file is open on standard input (file descriptor 0), and the other is open on standard output (file descriptor 1).

![Figure 3.7 Kernel data structures for open files](image/Figure%203.7%20Kernel%20data%20structures%20for%20open%20files.png)

If two independent processes have the same file open, we could have the arrangement shown in Figure 3.8.

![Figure 3.8 Two independent processes with the same file open](image/Figure%203.8%20Two%20independent%20processes%20with%20the%20same%20file%20open.png)

### 3.13 sync, fsync, and fdatasync Functions

*delayed write* When we write data to a file, the data is normally copied by the kernel into one of its buffer cache or page cache and queued for writing to disk at some later time.

* The function **sync** is normally called periodically (usually every 30 seconds) from a system daemon, often called update.
* The function **fsync** refers only to a single file, specified by the file descriptor fd, and waits for the disk writes to complete before returning.
* The **fdatasync** function is similar to fsync, but it affects only the data portions of a file. With fsync, the file’s attributes are also updated synchronously.

Most system only support sync and fsync.

## Chapter 4. Files and Directories

### 4.14 File Systems

We can think of a disk drive being divided into one or more partitions. Each partition can contain a file system, as shown in Figure 4.13. The i-nodes are fixed-length entries that contain most of the information about a file.

![Figure 4.13 Disk drive, partitions, and a file system](image/Figure%204.13%20Disk%20drive,%20partitions,%20and%20a%20file%20system.png)

If we examine the i-node and data block portion of a cylinder group in more detail, we could have the arrangement shown in Figure 4.14.

![Figure 4.14 Cylinder group’s i-nodes and data blocks in more detail](image/Figure%204.14%20Cylinder%20group%E2%80%99s%20i-nodes%20and%20data%20blocks%20in%20more%20detail.png)

### 4.22 Reading Directories

Directories can be read by anyone who has access permission to read the directory. But only the kernel can write to a directory, to preserve file system sanity. Recall from Section 4.5 that the write permission bits and execute permission bits for a directory determine if we can create new files in the directory and remove files from the directory—they don’t specify if we can write to the directory itself.

## Chapter 7. Process Environment

### 7.6 Memory Layout of a C Program

1. Text segment, consisting of the machine instructions that the CPU executes.
2. Initialized data segment, usually called simply the data segment, containing variables that are specifically initialized in the program.
3. Uninitialized data segment, often called the “bss” segment, named after an ancient assembler operator that stood for “block started by symbol.”
4. Stack, where automatic variables are stored, along with information that is saved each time a function is called.
5. Heap, where dynamic memory allocation usually takes place.

Figure 7.6 Typical memory arrangement

## Chatper 8 Process Control

### 8.3 fork Function

### 8.6 wait and waitpid Functions

### 8.12 Interpreter Files

These files are text files that begin with a line of the form `#! pathname [ optional-argument ]`
The most common of these interpreter files begin with the line `#!/bin/sh`

The actual file that gets executed by the kernel is not the interpreter file, but rather the file specified by the pathname on the first line of the interpreter file.

## Chatper 9 Process Relationships

### 9.2 Terminal Logins

Other Linux distributions, such as recent Ubuntu distributions, ship with a version of init that is known as ‘‘Upstart.’’ It uses configuration files named *.conf that are stored in the `/etc/init` directory.

## Chatper 14 Advanced I/O

14.2 Nonblocking I/O

14.3 Record Locking

14.4 I/O Multiplexing

## Chatper 15 Interprocess Communication

pipes and FIFOs are still be used effectively.

Avoid using message queues and semaphores.

Shared memory still has its use, although the same functionality can be provided through the use of the mmap function

## Chatper 16 Network IPC: Sockets
