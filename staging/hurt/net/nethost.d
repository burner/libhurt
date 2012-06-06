/*******************************************************************************

	copyright:      Copyright (c) 2004 Kris Bell. All rights reserved
	license:	BSD style: $(LICENSE)
	author:	 Kris

*******************************************************************************/
module hurt.net.nethost;

private import  core.sys.posix.netdb;
private import  core.sys.posix.unistd;

private import hurt.net.socket,
		hurt.net.address,
		hurt.net.internetaddress;
	
import hurt.string.stringutil;

/*******************************************************************************


*******************************************************************************/

public class NetHost
{
	//char[]	  name;
	string name;
	string[]	aliases;
	//char[][]	aliases;
	uint[]	  addrList;

	/***********************************************************************

	***********************************************************************/

	protected void validHostent(hostent* he)
	{
		if (he.h_addrtype != AddressFamily.INET || he.h_length != 4)
		    throw new SocketException("Address family mismatch.");
	}

	/***********************************************************************

	***********************************************************************/

	void populate (hostent* he)
	{
		int i;
		char* p;

		name = fromStringz(he.h_name);

		for (i = 0;; i++)
		    {
		    p = he.h_aliases[i];
		    if(!p)
			break;
		    }

		if (i)
		   {
		   aliases = new string[i];
		   for (i = 0; i != aliases.length; i++)
			aliases[i] = fromStringz(he.h_aliases[i]);
		   }
		else
		   aliases = null;

		for (i = 0;; i++)
		    {
		    p = he.h_addr_list[i];
		    if(!p)
			break;
		    }

		if (i)
		   {
		   addrList = new uint[i];
		   for (i = 0; i != addrList.length; i++)
			//addrList[i] = Address.ntohl(*(cast(uint*)he.h_addr_list[i])); ??
			addrList[i] = *cast(uint*)he.h_addr_list[i];
		   }
		else
		   addrList = null;
	}

	/***********************************************************************

	***********************************************************************/

	bool getHostByName(const(char)[] name)
	{
		char[1024] tmp;

		synchronized (NetHost.classinfo)
		{
		    auto he = gethostbyname(toStringz(name));
		    if(!he)
			return false;
			
		    validHostent(he);
		    populate(he);
		}
		return true;
	}

	/***********************************************************************

	***********************************************************************/

	bool getHostByAddr(uint addr)
	{
		uint x = htonl(addr);
		synchronized (NetHost.classinfo)
		{
		    auto he = .gethostbyaddr(&x, 4, AddressFamily.INET);
		    if(!he)
			return false;
			
		    validHostent(he);
		    populate(he);
		}
		return true;
	}

	/***********************************************************************

	***********************************************************************/

	//shortcut
	bool getHostByAddr(char[] addr)
	{
		synchronized (NetHost.classinfo)
		{
		    uint x = inet_addr(toStringz(addr));
		    return getHostByAddr(x);
		}
	}
	
	/**
	 * returns the hostname of this host see: /etc/hostname
	 */
	static char[] hostName()
	{
	    char[64] name;
	    if(.gethostname(name.ptr, name.length) == -1)
		   throw new SocketException("Unable to obtain host name: ");
	    
	    return fromStringz(name.ptr).dup;
	}
}


/*******************************************************************************

*******************************************************************************/

unittest {
	import core.stdc.stdio;
	import hurt.io.stdio;
	
	// hostname
	char[] hostname = NetHost.hostName();
	printfln("hostname: %s", hostname);
	
	// lookup by name
	NetHost hostent = new NetHost();
	hostent.getHostByName(hostname);
	assert(hostent.addrList.length > 0);
	foreach(int i, string s; hostent.aliases) {
	    printfln("aliases[%d] = %s", i, s); 
	}
	
	// reverse lookup
	InternetAddress address = new InternetAddress(ntohl(hostent.addrList[0]), InternetAddress.PORT_ANY);
	printfln("IP-Address = %s", address.toAddrString());
	printfln("Name = %s", hostent.name);
	
	// lookup by addr
	assert(hostent.getHostByAddr(ntohl(hostent.addrList[0])));
	printfln("name = %s", hostent.name);
	foreach(int i, string s; hostent.aliases)
	    printfln("aliases[%s] = %d", i, s);
}
