/*******************************************************************************

	copyright:      Copyright (c) 2011 Kris Bell. All rights reserved
	license:	BSD style: $(LICENSE)
	version:	Initial release: Aug 2011
	author:	 Kris, Tim

*******************************************************************************/
module hurt.net.tcpsocket;

public import hurt.net.socket;
public import hurt.net.internetaddress;

class TcpSocket : Socket
{
    /**
     * Constructor that directly trys to establish a connection
     * 
     * params:
     *  addr = the address or hostname
     *  port = the port number
     */
    public this(const(char)[] addr, ushort port = InternetAddress.PORT_ANY)
    {
	// ditto
	this(new InternetAddress(addr, port));
    }
    
    /**
     * Default constructor, if addr is null, this socket doesn't connect
     *
     * params:
     *  addr = an adress structure usually created from hurt.net.internetaddress
     */
    public this(Address addr = null)
    {
	// family, type, protocol
	super((addr ? addr.addressFamily() : AddressFamily.INET), SocketType.STREAM, ProtocolType.TCP);
	
	// connect
	if(addr !is null) {
	    super.connect(addr);
	}
    }
    
    /**
     * connect function with addr and host
     */
    public override Socket connect(const(char)[] addr, ushort port = InternetAddress.PORT_ANY)
    {
	return super.connect(new InternetAddress(addr, port));
    }
    
    /**
     * connect with an address
     */
    public override Socket connect(Address address)
    {
	return super.connect(address);
    }
};
