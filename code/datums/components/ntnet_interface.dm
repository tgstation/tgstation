//Thing meant for allowing datums and objects to access an NTnet network datum.
// we ignore A because of the 24 bit issue
#define IP_TO_STRING(IP) "[IP.upper>>16].[IP.upper&0xFF].[IP.lower>>16].[IP.lower&0xFF]"
/datum/ip
	/// since we don't have access to full 32 bit masks, so deal with 16 bit numbers
	var/upper = 0
	var/lower = 0
	var/text // cached text refrence

/datum/ip/New(A1, A2, A3, A4)
	if(isnum(A3) && isnum(A4))
		ASSERT(A1 < 256 && A2 < 256 && A3< 256 && A4< 256)
		upper = (A1 << 16)  |  A2
		lower = (A3 << 16)  |  A4
	else if(istype(A1,/datum/ip))
		var/datum/ip/A = A1
		upper = A.upper
		lower = A.lower
	else
		upper = A1
		lower = A2
	text = IP_TO_STRING(src)

/datum/ip/proc/to_string()
	return text

/datum/ip/proc/operator&=(datum/ip/B)
	upper &= B.upper
	lower &= B.lower
	return src

/datum/ip/proc/operator&(datum/ip/B)
	return new/datum/ip(upper & B.upper,lower & B.lower)

/datum/ip/proc/operator~=(datum/ip/B)
	return upper == B.upper && lower == B.lower

/datum/ip/address
	/// since we don't have access to full 32 bit masks, going to assume we have alteast 24 bit
	var/datum/ip/address
	var/datum/ip/subnet_mask
	var/datum/ip/network_prefex // network ip addres

/datum/ip/address/New(datum/ip/A, datum/ip/M)
	address = A
	subnet_mask = M
	network_prefex = address & subnet_mask

// Check if an IP address is within the network defined by an IP
// address and a netmask.
/datum/ip/address/proc/in_network(datum/ip/A)
	return network_prefex.upper == (upper & A.upper) && network_prefex.lower == (lower & A.lower)

// this handles lookups bettween an ip address and hardware_id as well as dns resolving
/datum/ip/arp_and_dns_table
	var/static/list/ip_cache = list()			// cache of ip address ip_text -> datum/ip
	var/list/arp = list()						// arp lookup ip -> hardware_id
	var/list/dns = list()						// dns lookup name -> ip

/datum/ip/arp_and_dns_table/Destroy()
	QDEL_NULL(ip_cache)
	QDEL_NULL(arp)
	QDEL_NULL(dns)
	return ..()

/datum/ip/arp_and_dns_table/proc/add_ip_to_cache(datum/ip/A)
	if(A && !ip_cache[A])
		if(ip_cache[A.text])
			A = ip_cache[A.text]
		else
			ip_cache[A.text] = A
			ip_cache[A] = A.text
	return A

/datum/ip/arp_and_dns_table/proc/arp_lookup(datum/ip/A)
	return arp[add_ip_to_cache(A)]

/datum/ip/arp_and_dns_table/proc/dns_reverse_lookup(datum/ip/A)
	return dns[add_ip_to_cache(A)]

/datum/ip/arp_and_dns_table/proc/arp_reverse_lookup(hid)
	return arp[hid]

/datum/ip/arp_and_dns_table/proc/dns_lookup(name)
	return dns[name]

/datum/ip/arp_and_dns_table/proc/update_arp(datum/component/ntnet_interface/HID, datum/ip/A)
	A = add_ip_to_cache(A)
	arp[HID.hardware_id] = A
	arp[A] = HID

// should do some checking on dns name?  Moved that over to the tgui
/datum/ip/arp_and_dns_table/proc/update_dns(name, datum/ip/A)
	A = add_ip_to_cache(A)
	dns[name] = A
	dns[A] = name

/datum/ip/arp_and_dns_table/proc/resolve_to_hardware(value)
	var/datum/ip/IP = value
	if(!IP && istext(value))	// its text so its a dns lookup
		IP = dns_lookup(value)
	return arp[IP]


/datum/ip/router
	var/static/datum/ip/arp_and_dns_table/arp = new
	var/datum/ip/address 				// address to this router


// we don't do any proper network bitmask checking on the ip address
// This is just for caching so there arn't rogue ips flowating around
/datum/ip/router


/datum/proc/ntnet_receive(datum/netdata/data)
	return

/datum/proc/ntnet_receive_broadcast(datum/netdata/data)
	return

/datum/proc/ntnet_send(datum/netdata/data, netid)
	var/datum/component/ntnet_interface/NIC = GetComponent(/datum/component/ntnet_interface)
	if(!NIC)
		return FALSE
	return NIC.__network_send(data, netid)

/datum/component/ntnet_interface
	var/hardware_id			//text. this is the true ID. do not change this. stuff like ID forgery can be done manually.
	var/datum/ntnet/network = null
	var/differentiate_broadcast = TRUE				//If false, broadcasts go to ntnet_receive. NOT RECOMMENDED.
	var/list/linked_interfaces

/datum/component/ntnet_interface/Initialize(network_name=null)			//Don't force ID unless you know what you're doing!
	set_network(network_name)
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL), .proc/on_multitool)

/datum/component/ntnet_interface/Destroy()
	SSnetworks.unregister_interface(src)
	linked_interfaces = null
	UnregisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL))
	return ..()
/datum/component/ntnet_interface/proc/set_network(network_name=null)
	linked_interfaces = list() // clear linked names
	if(network)
		SSnetworks.unregister_interface(src)
	SSnetworks.register_interface(src, network_name)




/datum/component/ntnet_interface/proc/__network_receive(datum/netdata/data)			//Do not directly proccall!
	if(!SEND_SIGNAL(parent, COMSIG_COMPONENT_NTNET_RECEIVE, data))
		return
	if(differentiate_broadcast && data.broadcast)
		parent.ntnet_receive_broadcast(data)
	else
		parent.ntnet_receive(data)

/datum/component/ntnet_interface/proc/__network_send(datum/netdata/data, netid)			//Do not directly proccall!
	network.process_data_transmit(src, data)
	return TRUE


/datum/component/ntnet_interface/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Telecomms")
		ui.open()

/datum/component/ntnet_interface/ui_data(mob/user)
	var/list/data = list()

	data += add_option()

	data["hardware_id"] = hardware_id

	var/obj/item/multitool/heldmultitool = get_multitool(user)
	data["multitool"] = heldmultitool

	if(heldmultitool)
		data["multibuff"] = heldmultitool.buffer

	data["toggled"] = toggled

	var/list/linked = list()
	for(var/hid in linked_interfaces)
		var/datum/component/ntnet_interface/N = linked_interfaces[hid]
		linked[hid] = parent.name
	data["linked"] = linked

	return data

/datum/component/ntnet_interface/ui_act(action, params)
	if(..())
		return

	if(!issilicon(usr))
		if(!istype(usr.get_active_held_item(), /obj/item/multitool))
			return

	var/obj/item/multitool/heldmultitool = get_multitool(operator)

	switch(action)
		if("toggle")
			toggled = !toggled
			update_power()
			update_icon()
			log_game("[key_name(operator)] toggled [toggled ? "On" : "Off"] [src] at [AREACOORD(src)].")
			. = TRUE
		if("id")
			if(params["value"])
				if(length(params["value"]) > 32)
					to_chat(operator, "<span class='warning'>Error: Machine ID too long!</span>")
					playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
					return
				else
					id = params["value"]
					log_game("[key_name(operator)] has changed the ID for [src] at [AREACOORD(src)] to [id].")
					. = TRUE
		if("network")
			if(params["value"])
				if(network.network_id != params["value"])
					set_network(params["value"])
					log_game("[hardware_id] network has changed  to [network.network_id].")
					. = TRUE
		if("freq")
			var/newfreq = tempfreq * 10
			if(newfreq == FREQ_SYNDICATE)
				to_chat(operator, "<span class='warning'>Error: Interference preventing filtering frequency: \"[newfreq / 10] GHz\"</span>")
				playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
			else
				if(!(newfreq in freq_listening) && newfreq < 10000)
					freq_listening.Add(newfreq)
					log_game("[key_name(operator)] added frequency [newfreq] for [src] at [AREACOORD(src)].")
					. = TRUE
		if("delete")
			freq_listening.Remove(params["value"])
			log_game("[key_name(operator)] added removed frequency [params["value"]] for [src] at [AREACOORD(src)].")
			. = TRUE
		if("unlink")
			var/obj/machinery/telecomms/T = links[text2num(params["value"])]
			if(T)
				// Remove link entries from both T and src.
				if(T.links)
					T.links.Remove(src)
				links.Remove(T)
				log_game("[key_name(operator)] unlinked [src] and [T] at [AREACOORD(src)].")
				. = TRUE
		if("link")
			if(heldmultitool)
				var/obj/machinery/telecomms/T = heldmultitool.buffer
				if(istype(T) && T != src)
					if(!(src in T.links))
						T.links += src
					if(!(T in links))
						links += T
						log_game("[key_name(operator)] linked [src] for [T] at [AREACOORD(src)].")
						. = TRUE
		if("buffer")
			heldmultitool.buffer = src
			. = TRUE
		if("flush")
			heldmultitool.buffer = null
			. = TRUE

	add_act(action, params)
	. = TRUE


/datum/component/ntnet_interface/proc/on_multitool(datum/source, mob/user, obj/item/multitool/TABLET)
	SIGNAL_HANDLER

	return COMPONENT_BLOCK_TOOL_ATTACK

/datum/component/ntnet_interface/proc/get_multitool(mob/user)
	var/obj/item/multitool/P = null
	// Let's double check
	if(!issilicon(user) && istype(user.get_active_held_item(), /obj/item/multitool))
		P = user.get_active_held_item()
	else if(isAI(user))
		var/mob/living/silicon/ai/U = user
		P = U.aiMulti
	else if(iscyborg(user) && in_range(user, src))
		if(istype(user.get_active_held_item(), /obj/item/multitool))
			P = user.get_active_held_item()
	return P

/datum/component/ntnet_interface/proc/canAccess(mob/user)
	if(issilicon(user) || in_range(user, src))
		return TRUE
	return FALSE
