module async.eventloop;

import
	async.codec,
	async.event.selector,
	async.net.tcpclient,
	async.net.tcplistener,
	std.socket;

version (linux)
	import async.event.epoll;
else
{
	import async.event.kqueue;
	version(KQUEUE) { } else version (Windows)
	{
		import async.event.iocp;
	}
	else static assert(0, "Unsupported platform.");
}

class EventLoop : LoopSelector
{
	this(TcpListener listener, OnConnected onConnected = null, OnDisconnected onDisconnected = null,
		OnReceive onReceive = null, OnSendCompleted onSendCompleted = null,
		OnSocketError onSocketError = null, Codec codec = null, uint workerThreadNum = 0)
	{
		version (Posix)
		{
			import core.sys.posix.signal;

			// For main thread.
			signal(SIGPIPE, SIG_IGN);

			// For background threads.
			sigset_t mask1;
			sigemptyset(&mask1);
			sigaddset(&mask1, SIGPIPE);
			sigaddset(&mask1, SIGILL);
			sigprocmask(SIG_BLOCK, &mask1, null);
		}

		super(listener, onConnected, onDisconnected, onReceive, onSendCompleted, onSocketError, codec, workerThreadNum);
	}

	this(TcpListener listener, OnConnected onConnected, OnDisconnected onDisconnected,
		void function(TcpClient, const scope ubyte[]) nothrow @trusted onReceive, OnSendCompleted onSendCompleted = null,
		OnSocketError onSocketError = null, Codec codec = null, uint workerThreadNum = 0)
	{
		import std.functional;
		this(listener, onConnected, onDisconnected,
			onReceive.toDelegate, onSendCompleted, onSocketError, codec, workerThreadNum);
	}

	void run()
	{
		import std.experimental.logger;
		debug infof("Start listening to %s...", _listener.localAddress);
		startLoop();
	}
}