/obj/item/assembly/infra
	name = "infrared emitter"
	desc = "Emits a visible or invisible beam and is triggered when the beam is interrupted."
	icon_state = "infrared"
	custom_materials = list(/datum/material/iron=1000, /datum/material/glass=500)
	is_position_sensitive = TRUE
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	var/on = FALSE
	var/visible = FALSE
	var/maxlength = 8
	var/list/obj/effect/beam/i_beam/beams
	var/olddir = 0
	var/turf/listeningTo
	var/hearing_range = 3

/obj/item/assembly/infra/Initialize(mapload)
	. = ..()
	beams = list()
	START_PROCESSING(SSobj, src)
	AddComponent(/datum/component/simple_rotation, AfterRotation = CALLBACK(src, .proc/AfterRotation))

/obj/item/assembly/infra/proc/AfterRotation(mob/user, degrees)
	refreshBeam()

/obj/item/assembly/infra/AltClick(mob/user)
	return ..() // This hotkey is BLACKLISTED since it's used by /datum/component/simple_rotation

/obj/item/assembly/infra/Destroy()
	STOP_PROCESSING(SSobj, src)
	listeningTo = null
	QDEL_LIST(beams)
	. = ..()

/obj/item/assembly/infra/examine(mob/user)
	. = ..()
	. += span_notice("The infrared trigger is [on?"on":"off"].")

/obj/item/assembly/infra/activate()
	if(!..())
		return FALSE //Cooldown check
	on = !on
	refreshBeam()
	update_appearance()
	return TRUE

/obj/item/assembly/infra/toggle_secure()
	secured = !secured
	if(secured)
		START_PROCESSING(SSobj, src)
		refreshBeam()
	else
		QDEL_LIST(beams)
		STOP_PROCESSING(SSobj, src)
	update_appearance()
	return secured

/obj/item/assembly/infra/update_appearance(updates=ALL)
	. = ..()
	holder?.update_appearance(updates)

/obj/item/assembly/infra/update_overlays()
	. = ..()
	attached_overlays = list()
	if(!on)
		return
	. += "infrared_on"
	attached_overlays += "infrared_on"
	if(visible && secured)
		. += "infrared_visible"
		attached_overlays += "infrared_visible"

/obj/item/assembly/infra/dropped()
	. = ..()
	if(holder)
		holder_movement() //sync the dir of the device as well if it's contained in a TTV or an assembly holder
	else
		refreshBeam()

/obj/item/assembly/infra/process()
	if(!on || !secured)
		refreshBeam()
		return

/obj/item/assembly/infra/proc/refreshBeam()
	QDEL_LIST(beams)
	if(throwing || !on || !secured)
		return
	if(holder)
		if(holder.master) //incase the sensor is part of an assembly that's contained in another item, such as a single tank bomb
			if(!holder.master.IsSpecialAssembly() || !isturf(holder.master.loc))
				return
		else if(!isturf(holder.loc)) //else just check where the holder is
			return
	else if(!isturf(loc)) //or just where the fuck we are in general
		return
	var/turf/T = get_turf(src)
	var/_dir = dir
	var/turf/_T = get_step(T, _dir)
	if(_T)
		for(var/i in 1 to maxlength)
			var/obj/effect/beam/i_beam/I = new(T)
			if(istype(holder, /obj/item/assembly_holder))
				var/obj/item/assembly_holder/assembly_holder = holder
				I.icon_state = "[initial(I.icon_state)]_[(assembly_holder.a_left == src) ? "l":"r"]" //Sync the offset of the beam with the position of the sensor.
			else if(istype(holder, /obj/item/transfer_valve))
				I.icon_state = "[initial(I.icon_state)]_ttv"
			I.set_density(TRUE)
			if(!I.Move(_T))
				qdel(I)
				switchListener(_T)
				break
			I.set_density(FALSE)
			beams += I
			I.master = src
			I.setDir(_dir)
			I.invisibility = visible? 0 : INVISIBILITY_ABSTRACT
			T = _T
			_T = get_step(_T, _dir)
			CHECK_TICK

/obj/item/assembly/infra/on_detach()
	. = ..()
	if(!.)
		return
	refreshBeam()

/obj/item/assembly/infra/attack_hand(mob/user, list/modifiers)
	. = ..()
	refreshBeam()

/obj/item/assembly/infra/Moved()
	var/t = dir
	. = ..()
	setDir(t)

/obj/item/assembly/infra/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, force, gentle = FALSE, quickstart = TRUE)
	. = ..()
	olddir = dir

/obj/item/assembly/infra/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!olddir)
		return
	setDir(olddir)
	olddir = null

/obj/item/assembly/infra/proc/trigger_beam(atom/movable/AM, turf/location)
	refreshBeam()
	switchListener(location)
	if(!secured || !on || next_activate > world.time)
		return FALSE
	pulse(FALSE)
	audible_message("<span class='infoplain'>[icon2html(src, hearers(src))] *beep* *beep* *beep*</span>", null, hearing_range)
	for(var/mob/hearing_mob in get_hearers_in_view(hearing_range, src))
		hearing_mob.playsound_local(get_turf(src), 'sound/machines/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
	next_activate = world.time + 30

/obj/item/assembly/infra/proc/switchListener(turf/newloc)
	if(listeningTo == newloc)
		return
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_ATOM_EXITED)
	RegisterSignal(newloc, COMSIG_ATOM_EXITED, .proc/check_exit)
	listeningTo = newloc

/obj/item/assembly/infra/proc/check_exit(datum/source, atom/movable/gone, direction)
	SIGNAL_HANDLER

	if(QDELETED(src))
		return
	if(src == gone || istype(gone, /obj/effect/beam/i_beam))
		return
	if(isitem(gone))
		var/obj/item/I = gone
		if (I.item_flags & ABSTRACT)
			return
	INVOKE_ASYNC(src, .proc/refreshBeam)

/obj/item/assembly/infra/setDir()
	. = ..()
	refreshBeam()

/obj/item/assembly/infra/ui_status(mob/user)
	if(is_secured(user))
		return ..()
	return UI_CLOSE

/obj/item/assembly/infra/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "InfraredEmitter", name)
		ui.open()

/obj/item/assembly/infra/ui_data(mob/user)
	var/list/data = list()
	data["on"] = on
	data["visible"] = visible
	return data

/obj/item/assembly/infra/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("power")
			on = !on
			. = TRUE
		if("visibility")
			visible = !visible
			. = TRUE

	update_appearance()
	refreshBeam()

/***************************IBeam*********************************/

/obj/effect/beam/i_beam
	name = "infrared beam"
	icon = 'icons/obj/guns/projectiles.dmi'
	icon_state = "ibeam"
	anchored = TRUE
	density = FALSE
	pass_flags = PASSTABLE|PASSGLASS|PASSGRILLE
	pass_flags_self = LETPASSTHROW
	var/obj/item/assembly/infra/master

/obj/effect/beam/i_beam/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/beam/i_beam/proc/on_entered(datum/source, atom/movable/AM as mob|obj)
	SIGNAL_HANDLER
	if(istype(AM, /obj/effect/beam))
		return
	if (isitem(AM))
		var/obj/item/I = AM
		if (I.item_flags & ABSTRACT)
			return
	INVOKE_ASYNC(master, /obj/item/assembly/infra.proc/trigger_beam, AM, get_turf(src))
