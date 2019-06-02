/datum/wires/explosive/New(atom/holder)
	add_duds(2) // In this case duds actually explode.
	..()

/datum/wires/explosive/on_pulse(index)
	explode()

/datum/wires/explosive/on_cut(index, mend)
	explode()

/datum/wires/explosive/proc/explode()
	return

/datum/wires/explosive/chem_grenade
	holder_type = /obj/item/grenade/chem_grenade
	randomize = TRUE
	var/fingerprint
	var/assembly

/datum/wires/explosive/chem_grenade/interactable(mob/user)
	var/obj/item/grenade/chem_grenade/G = holder
	if(G.stage == 2)
		return TRUE

/datum/wires/explosive/chem_grenade/attach_assembly(color, obj/item/assembly/S)
	if(istype(S,/obj/item/assembly/timer))
		var/obj/item/grenade/chem_grenade/G = holder
		var/obj/item/assembly/timer/T = S
		G.det_time = T.saved_time*10
	if(istype(S,/obj/item/assembly/prox_sensor))
		var/obj/item/grenade/chem_grenade/G = holder
		G.landminemode = S
		S.proximity_monitor.wire = TRUE
	fingerprint = S.fingerprintslast
	assembly = "[S.name]"
	return ..()

/datum/wires/explosive/chem_grenade/explode()
	var/obj/item/grenade/chem_grenade/G = holder
	G.prime()

/datum/wires/explosive/chem_grenade/on_cut(index, mend)
	return

/datum/wires/explosive/chem_grenade/pulse(wire, user)
	if(user)
		message_admins("[user] has pulsed a grenade wire.")
		log_game("[user] has pulsed a grenade wire.")
	else if(assembly)
		message_admins("An [assembly] has pulsed a grenade, which was installed by [fingerprint].")
		log_game("An [assembly] has pulsed a grenade, which was installed by [fingerprint].")
	..()

/datum/wires/explosive/chem_grenade/detach_assembly(color)
	var/obj/item/assembly/S = get_attached(color)
	if(S && istype(S))
		assemblies -= color
		S.connected = null
		S.forceMove(holder.drop_location())
		var/obj/item/grenade/chem_grenade/G = holder
		G.landminemode = null
		return S

/datum/wires/explosive/c4
	holder_type = /obj/item/grenade/plastic/c4
	randomize = TRUE	//Same behaviour since no wire actually disarms it

/datum/wires/explosive/c4/interactable(mob/user)
	var/obj/item/grenade/plastic/c4/P = holder
	if(P.open_panel)
		return TRUE

/datum/wires/explosive/c4/explode()
	var/obj/item/grenade/plastic/c4/P = holder
	P.prime()


/datum/wires/explosive/pizza
	holder_type = /obj/item/pizzabox
	randomize = TRUE

/datum/wires/explosive/pizza/New(atom/holder)
	wires = list(
		WIRE_DISARM
	)
	add_duds(3) // Duds also explode here.
	..()

/datum/wires/explosive/pizza/interactable(mob/user)
	var/obj/item/pizzabox/P = holder
	if(P.open && P.bomb)
		return TRUE

/datum/wires/explosive/pizza/get_status()
	var/obj/item/pizzabox/P = holder
	var/list/status = list()
	status += "The red light is [P.bomb_active ? "on" : "off"]."
	status += "The green light is [P.bomb_defused ? "on": "off"]."
	return status

/datum/wires/explosive/pizza/on_pulse(wire)
	var/obj/item/pizzabox/P = holder
	switch(wire)
		if(WIRE_DISARM) // Pulse to toggle
			P.bomb_defused = !P.bomb_defused
		else // Boom
			explode()

/datum/wires/explosive/pizza/on_cut(wire, mend)
	var/obj/item/pizzabox/P = holder
	switch(wire)
		if(WIRE_DISARM) // Disarm and untrap the box.
			if(!mend)
				P.bomb_defused = TRUE
		else
			if(!mend && !P.bomb_defused)
				explode()

/datum/wires/explosive/pizza/explode()
	var/obj/item/pizzabox/P = holder
	P.bomb.detonate()


/datum/wires/explosive/gibtonite
	holder_type = /obj/item/twohanded/required/gibtonite

/datum/wires/explosive/gibtonite/explode()
	var/obj/item/twohanded/required/gibtonite/P = holder
	P.GibtoniteReaction(null, 2)