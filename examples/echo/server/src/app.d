import
    async,
    std.stdio,
    std.socket,
    std.exception;

void main()
{
    auto listener = new TcpListener;
    listener.bind(new InternetAddress("127.0.0.1", 12290));
    listener.listen(10);

    auto loop = new EventLoop(listener, null, null, &onReceive, null, null);
    loop.run();
}

void onReceive(TcpClient client, const scope ubyte[] data) nothrow @trusted
{
    collectException({
        writefln("Receive from %s: %d", client.remoteAddress, data.length);
        client.send(data); // echo
    }());
}
