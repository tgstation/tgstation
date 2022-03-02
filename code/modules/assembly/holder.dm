/obj/item/assembly_holder
	name = "Assembly"
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "assembly_holder"
	inhand_icon_state = "assembly"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	flags_1 = CONDUCT_1
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 2
	throw_range = 7

	var/list/obj/item/assembly/assemblies

/obj/item/assembly_holder/Initialize(mapload)
	. = ..()
	LAZYINITLIST(assemblies)
	AddComponent(/datum/component/simple_rotation)

/obj/item/assembly_holder/Destroy()
	QDEL_LAZYLIST(assemblies)
	return ..()

/obj/item/assembly_holder/Exited(atom/movable/gone, direction)
	. = ..()
	LAZYREMOVE(assemblies, gone)

/obj/item/assembly_holder/IsAssemblyHolder()
	return TRUE


/obj/item/assembly_holder/proc/assemble(obj/item/assembly/A, obj/item/assembly/A2, mob/user)
	attach(A,user)
	attach(A2,user)
	name = "[A.name]-[A2.name] assembly"
	update_appearance()
	SSblackbox.record_feedback("tally", "assembly_made", 1, "[initial(A.name)]-[initial(A2.name)]")

/obj/item/assembly_holder/proc/add_assembly(obj/item/assembly/A, mob/user)
	attach(A, user)
	name = ""
	for(var/obj/item/assembly/assembly in assemblies)
		name += "[assembly.name]-"
	name = splicetext(name, length(name), length(name) + 1, "")
	name += " assembly"
	update_appearance()

/obj/item/assembly_holder/proc/attach(obj/item/assembly/A, mob/user)
	if(!A.remove_item_from_storage(src))
		if(user)
			user.transferItemToLoc(A, src)
		else
			A.forceMove(src)
	A.holder = src
	A.toggle_secure()
	LAZYADD(assemblies,A)
	A.holder_movement()
	A.on_attach()

/obj/item/assembly_holder/update_appearance(updates=ALL)
	. = ..()
	master?.update_appearance(updates)

/obj/item/assembly_holder/update_overlays()
	. = ..()
	for(var/i in 1 to LAZYLEN(assemblies) step 2)
		var/obj/item/assembly/assembly = assemblies[i]
		. += "[assembly.icon_state]_left"
		for(var/left_overlay in assembly.attached_overlays)
			. += "[left_overlay]_l"
	for(var/i in 2 to LAZYLEN(assemblies) step 2)
		var/obj/item/assembly/assembly = assemblies[i]
		var/mutable_appearance/right = mutable_appearance(icon, "[assembly.icon_state]_left")
		right.transform = matrix(-1, 0, 0, 0, 1, 0)
		for(var/right_overlay in assembly.attached_overlays)
			right.add_overlay("[right_overlay]_l")
		. += right

/obj/item/assembly_holder/on_found(mob/finder)
	for(var/obj/item/assembly/assembly in assemblies)
		assembly.on_found(finder)

/obj/item/assembly_holder/setDir()
	. = ..()
	for(var/obj/item/assembly/assembly in assemblies)
		assembly.holder_movement()

/obj/item/assembly_holder/dropped(mob/user)
	. = ..()
	for(var/obj/item/assembly/assembly in assemblies)
		assembly.dropped()

/obj/item/assembly_holder/attack_hand(mob/living/user, list/modifiers)//Perhapse this should be a holder_pickup proc instead, can add if needbe I guess
	. = ..()
	if(.)
		return
	for(var/obj/item/assembly/assembly in assemblies)
		assembly.attack_hand()

/obj/item/assembly_holder/attackby(obj/item/W, mob/user, params)
	if(isassembly(W))
		var/obj/item/assembly/A = W
		if(!A.secured)
			add_assembly(A,user)

/obj/item/assembly_holder/AltClick(mob/user)
	return ..() // This hotkey is BLACKLISTED since it's used by /datum/component/simple_rotation

/obj/item/assembly_holder/screwdriver_act(mob/user, obj/item/tool)
	if(..())
		return TRUE
	to_chat(user, span_notice("You disassemble [src]!"))
	for(var/obj/item/assembly/assembly in assemblies)
		assembly.on_detach()
		LAZYREMOVE(assemblies,assembly)
	qdel(src)
	return TRUE

/obj/item/assembly_holder/attack_self(mob/user)
	src.add_fingerprint(user)
	if(LAZYLEN(assemblies) == 1)
		to_chat(user, span_danger("Assembly part missing!"))
		return

	for(var/obj/item/assembly/assembly in assemblies)
		assembly.attack_self(user)


/obj/item/assembly_holder/proc/process_activation(obj/D, normal = 1, special = 1)
	if(!D)
		return FALSE
	if(normal && LAZYLEN(assemblies) >= 2)
		for(var/obj/item/assembly/assembly in assemblies)
			if(LAZYACCESS(assemblies,assembly) != D)
				assembly.pulsed(FALSE)
	if(master)
		master.receive_signal()
	return TRUE
