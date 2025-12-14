/obj/item/assembly_holder
	name = "Assembly"
	icon = 'icons/obj/devices/new_assemblies.dmi'
	icon_state = "assembly_holder"
	inhand_icon_state = "assembly"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	obj_flags = CONDUCTS_ELECTRICITY
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 2
	throw_range = 7
	/// used to store the list of assemblies making up our assembly holder
	var/list/obj/item/assembly/assemblies

/obj/item/assembly_holder/Initialize(mapload)
	. = ..()
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

/**
 * on_attach: Pass on_attach message to child assemblies
 *
 */
/obj/item/assembly_holder/proc/on_attach()
	var/obj/item/newloc = loc
	if(!newloc.IsSpecialAssembly() && !newloc.IsAssemblyHolder())
		return
	for(var/obj/item/assembly/assembly in assemblies)
		assembly.on_attach()

/obj/item/assembly_holder/proc/try_add_assembly(obj/item/assembly/attached_assembly, mob/user)
	if(attached_assembly.secured)
		balloon_alert(user, "not attachable!")
		return FALSE

	if(LAZYLEN(assemblies) >= HOLDER_MAX_ASSEMBLIES)
		balloon_alert(user, "too many assemblies!")
		return FALSE

	if(attached_assembly.assembly_flags & ASSEMBLY_NO_DUPLICATES)
		if(locate(attached_assembly.type) in assemblies)
			balloon_alert(user, "can't attach another of that!")
			return FALSE

	add_assembly(attached_assembly, user)
	balloon_alert(user, "part attached")
	return TRUE

/**
 * Adds an assembly to the assembly holder
 *
 * This proc is used to add an assembly to the assembly holder, update the appearance, and the name of it.
 * Arguments:
 * * attached_assembly - assembly we are adding to the assembly holder
 * * user - user we pass into attach()
 */
/obj/item/assembly_holder/proc/add_assembly(obj/item/assembly/attached_assembly, mob/user)
	attach(attached_assembly, user)
	name = ""
	for(var/obj/item/assembly/assembly as anything in assemblies)
		name += "[assembly.name]-"
	name = splicetext(name, length(name), length(name) + 1, "")
	name += " assembly"
	update_appearance()

/obj/item/assembly_holder/proc/attach(obj/item/assembly/A, mob/user)
	if(!A.remove_item_from_storage(src, user))
		if(user)
			user.transferItemToLoc(A, src)
		else
			A.forceMove(src)
	A.holder = src
	A.toggle_secure()
	LAZYADD(assemblies, A)
	A.holder_movement()
	A.on_attach()

/obj/item/assembly_holder/update_appearance(updates=ALL)
	. = ..()
	master?.update_appearance(updates)

/obj/item/assembly_holder/update_overlays()
	. = ..()
	for(var/i in 1 to LAZYLEN(assemblies))
		if(IS_LEFT_INDEX(i))
			var/obj/item/assembly/assembly = assemblies[i]
			. += mutable_appearance(assembly.icon, "[assembly.icon_state]_left")
			for(var/left_overlay in assembly.attached_overlays)
				. += "[left_overlay]_l"
		if(IS_RIGHT_INDEX(i))
			var/obj/item/assembly/assembly = assemblies[i]
			var/mutable_appearance/right = mutable_appearance(assembly.icon, "[assembly.icon_state]_left")
			right.transform = matrix(-1, 0, 0, 0, 1, 0)
			for(var/right_overlay in assembly.attached_overlays)
				right.add_overlay("[right_overlay]_l")
			. += right

/obj/item/assembly_holder/on_found(mob/finder)
	for(var/obj/item/assembly/assembly as anything in assemblies)
		assembly.on_found(finder)

/obj/item/assembly_holder/setDir()
	. = ..()
	for(var/obj/item/assembly/assembly as anything in assemblies)
		assembly.holder_movement()

/obj/item/assembly_holder/dropped(mob/user)
	. = ..()
	for(var/obj/item/assembly/assembly as anything in assemblies)
		assembly.dropped()

/obj/item/assembly_holder/attack_hand(mob/living/user, list/modifiers)//Perhapse this should be a holder_pickup proc instead, can add if needbe I guess
	. = ..()
	if(.)
		return
	for(var/obj/item/assembly/assembly as anything in assemblies)
		assembly.attack_hand(user, modifiers) // Note override in assembly.dm to prevent side effects here

/obj/item/assembly_holder/attackby(obj/item/weapon, mob/user, list/modifiers, list/attack_modifiers)
	if(isassembly(weapon))
		try_add_assembly(weapon, user)
		return

	return ..()


/obj/item/assembly_holder/screwdriver_act(mob/user, obj/item/tool)
	loc.balloon_alert(user, "disassembled")

	deconstruct(TRUE)

	return ITEM_INTERACT_SUCCESS

/obj/item/assembly_holder/atom_deconstruct(disassembled)
	for(var/obj/item/assembly/assembly as anything in assemblies)
		assembly.on_detach()
		LAZYREMOVE(assemblies, assembly)

/obj/item/assembly_holder/attack_self(mob/user)
	src.add_fingerprint(user)
	if(LAZYLEN(assemblies) == 1)
		balloon_alert(user, "part missing!")
		return

	for(var/obj/item/assembly/assembly as anything in assemblies)
		assembly.attack_self(user)

/**
 * this proc is used to process the activation of the assembly holder
 *
 * This proc is usually called by signalers, timers, or anything that can trigger and
 * send a pulse to the assembly holder, which then calls this proc that actually activates the assemblies
 * Arguments:
 * * /obj/device - the device we sent the pulse from which called this proc
 */
/obj/item/assembly_holder/proc/process_activation(obj/device)
	if(!device)
		return FALSE
	if(LAZYLEN(assemblies) >= 2)
		for(var/obj/item/assembly/assembly as anything in assemblies)
			if(assembly != device)
				assembly.pulsed()
	if(master)
		master.receive_signal()
	return TRUE
