/datum/wires/simple_wire   //two bit wire type just to add assemblies to things that dont have specific wires
	randomize = 0

/datum/wires/simple_wire/attach_assembly(obj/item/device/assembly/S)
	if(assemblies.len)
		return 0
	assemblies |= (S)
	S.connected = src
	return 1

/datum/wires/simple_wire/detach_assembly(mob/user)
	if(assemblies.len)
		var/obj/item/device/assembly/I = assemblies[1]
		assemblies.Cut()
		I.connected = null
		I.loc = holder.loc
		user.put_in_hands(I)
		return I

/datum/wires/simple_wire/pulse_assembly(obj/item/device/assembly/S)
	if(S in assemblies)
		holder.activate(S)