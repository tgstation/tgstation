/*
Exonet Protocol Version 2

This is designed to be a fairly simple fake-networking system, allowing you to send and receive messages
between the exonet_protocol datums, and for atoms to react to those messages, based on the contents of the message.
Hopefully, this can evolve to be a more robust fake-networking system and allow for some devious network hacking in the future.

Version 1 never existed.

*Setting up*

To set up the exonet link, define a variable on your desired atom it is like this;
	var/datum/exonet_protocol/exonet = null
Afterwards, before you want to do networking, call exonet = New(src), then exonet.make_address(string), and give it a string to hash into the new IP.
The reason it needs a string is so you can have the addresses be persistant, assuming no-one already took it first.

When you're no longer wanting to use the address and want to free it up, like when you want to Destroy() it, you need to call remove_address()
Destroy() also automatically calls remove_address().

*Sending messages*

To send a message to another datum, you need to know it's EPv2 (fake IP) address.  Once you know that, call send_message(), place your
intended address in the first argument, then the message in the second.  For example, send_message(exonet.address, "ping") will make you
ping yourself.

*Receiving messages*
You don't need to do anything special to receive the messages, other than give your target exonet datum an address as well.  Once something hits
your datum with send_message(), receive_message() is called, and the default action is to call receive_exonet_message() on the datum's holder.
You'll want to override receive_exonet_message() on your atom, and define what will occur when the message is received.
The receiving atom will receive the origin atom (the atom that sent the message), the origin address, and finally the message itself.
It's suggested to start with an if or switch statement for the message, to determine what to do.
*/

/datum/exonet_protocol
	var/address = "" //Resembles IPv6, but with only five 'groups', e.g. XXXX:XXXX:XXXX:XXXX:XXXX
	var/atom/holder

/datum/exonet_protocol/New(var/atom/H)
	holder = H

/datum/exonet_protocol/Destroy()
	remove_address()
	holder = null
	return ..()

// Proc: make_address()
// Parameters: 1 (string - used to make into a hash that will be part of the new address)
// Description: Allocates a new address based on the string supplied.  It results in consistant addresses for each round assuming it is not already taken..
/datum/exonet_protocol/proc/make_address(var/string)
	if(!string)
		return
	var/hex = copytext(md5(string),1,25)
	if(!hex)
		return
	var/addr_1 = copytext(hex,1,5)
	var/addr_2 = copytext(hex,5,9)
	var/addr_3 = copytext(hex,9,13)
	var/addr_4 = copytext(hex,13,17)
	address = "fc00:[addr_1]:[addr_2]:[addr_3]:[addr_4]"
	if(SScircuit.all_exonet_connections[address])
		stack_trace("WARNING: Exonet address collision in make_address. Holder type if applicable is [holder? holder.type : "NO HOLDER"]!")
	SScircuit.all_exonet_connections[address] = src


// Proc: make_arbitrary_address()
// Parameters: 1 (new_address - the desired address)
// Description: Allocates that specific address, if it is available.
/datum/exonet_protocol/proc/make_arbitrary_address(var/new_address)
	if(new_address)
		if(new_address == SScircuit.get_exonet_address(new_address) )	//Collision test.
			return FALSE
		address = new_address
		SScircuit.all_exonet_connections[address] = src
		return TRUE


// Proc: remove_address()
// Parameters: None
// Description: Deallocates the address, freeing it for use.
/datum/exonet_protocol/proc/remove_address()
	SScircuit.all_exonet_connections -= address
	address = ""



// Proc: send_message()
// Parameters: 3 (target_address - the desired address to send the message to, data_type - text stating what the content is meant to be used for,
// 		content - the actual 'message' being sent to the address)
// Description: Sends the message to target_address, by calling receive_message() on the desired datum.  Returns true if the message is recieved.
/datum/exonet_protocol/proc/send_message(var/target_address, var/data_type, var/content)
	if(!address)
		return FALSE
	var/obj/machinery/exonet_node/node = SScircuit.get_exonet_node()
	if(!node) // Telecomms went boom, ion storm, etc.
		return FALSE
	var/datum/exonet_protocol/exonet = SScircuit.get_exonet_address(target_address)
	if(exonet)
		node.write_log(address, target_address, data_type, content)
		return exonet.receive_message(holder, address, data_type, content)

// Proc: receive_message()
// Parameters: 4 (origin_atom - the origin datum's holder, origin_address - the address the message originated from,
// 		data_type - text stating what the content is meant to be used for, content - the actual 'message' being sent from origin_atom)
// Description: Called when send_message() successfully reaches the intended datum.  By default, calls receive_exonet_message() on the holder atom.
/datum/exonet_protocol/proc/receive_message(var/atom/origin_atom, var/origin_address, var/data_type, var/content)
	holder.receive_exonet_message(origin_atom, origin_address, data_type, content)
	return TRUE // for send_message()

// Proc: receive_exonet_message()
// Parameters: 3 (origin_atom - the origin datum's holder, origin_address - the address the message originated from, message - the message that was sent)
// Description: Override this to make your atom do something when a message is received.
/atom/proc/receive_exonet_message(var/atom/origin_atom, var/origin_address, var/message, var/text)
	return
