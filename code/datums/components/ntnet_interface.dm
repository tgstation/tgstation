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



/datum/component/ntnet_interface/Initialize(network_name=null)			//Don't force ID unless you know what you're doing!
	SSnetworks.register_interface(src, network_name)	// default to station
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL), .proc/on_multitool)

/datum/component/ntnet_interface/Destroy()
	SSnetworks.unregister_interface(src)
	UnregisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL))
	return ..()

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

/// Fuck it this is about networking, we are doing this with a tablet
/datum/component/ntnet_interface/proc/OnTablet(datum/source, mob/user, obj/item/modular_computer/TABLET)
	SIGNAL_HANDLER
#if 0
	if(!I.multitool_check_buffer(user, I))
		return COMPONENT_BLOCK_TOOL_ATTACK
	var/obj/item/multitool/M = I
	if (!QDELETED(M.buffer) && istype(M.buffer, /obj/machinery/ore_silo))
		if (silo == M.buffer)
			to_chat(user, "<span class='warning'>[parent] is already connected to [silo]!</span>")
			return COMPONENT_BLOCK_TOOL_ATTACK
		if (silo)
			silo.connected -= src
			silo.updateUsrDialog()
		else if (mat_container)
			mat_container.retrieve_all()
			qdel(mat_container)
		silo = M.buffer
		silo.connected += src
		silo.updateUsrDialog()
		mat_container = silo.GetComponent(/datum/component/material_container)
		to_chat(user, "<span class='notice'>You connect [parent] to [silo] from the multitool's buffer.</span>")

#endif
		to_chat(user, "<span class='notice'>You wack the thing with your tablet [parent] </span>")
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
