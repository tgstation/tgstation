/obj/item/device/assembly/infra
	name = "infrared emitter"
	desc = "Emits a visible or invisible beam and is triggered when the beam is interrupted.\n<span class='notice'>Alt-click to rotate it clockwise.</span>"
	icon_state = "infrared"
	materials = list(MAT_METAL=1000, MAT_GLASS=500)

	var/on = FALSE
	var/visible = FALSE
	var/maxlength = 8
	var/list/obj/effect/beam/i_beam/beams
	var/olddir = 0
	var/datum/component/redirect/listener

/obj/item/device/assembly/infra/Initialize()
	. = ..()
	beams = list()
	START_PROCESSING(SSobj, src)

/obj/item/device/assembly/infra/Destroy()
	QDEL_LIST(beams)
	return ..()

/obj/item/device/assembly/infra/describe()
	return "The infrared trigger is [on?"on":"off"]."

/obj/item/device/assembly/infra/activate()
	if(!..())
		return 0//Cooldown check
	on = !on
	update_icon()
	return 1

/obj/item/device/assembly/infra/toggle_secure()
	secured = !secured
	if(secured)
		START_PROCESSING(SSobj, src)
	else
		QDEL_LIST(beams)
		STOP_PROCESSING(SSobj, src)
	update_icon()
	return secured

/obj/item/device/assembly/infra/update_icon()
	cut_overlays()
	attached_overlays = list()
	if(on)
		add_overlay("infrared_on")
		attached_overlays += "infrared_on"

	if(holder)
		holder.update_icon()
	return

/obj/item/device/assembly/infra/dropped()
	refreshBeam()

/obj/item/device/assembly/infra/process()
	if(!on || !secured)
		refreshBeam()
		return

/obj/item/device/assembly/infra/proc/refreshBeam()
	QDEL_LIST(beams)
	if(throwing || !on || !secured || !(isturf(loc) || holder && isturf(holder.loc)))
		return
	var/turf/T = get_turf(src)
	var/_dir = dir
	var/turf/_T = get_step(T, _dir)
	if(_T)
		for(var/i in 1 to maxlength)
			var/obj/effect/beam/i_beam/I = new(T)
			I.density = TRUE
			if(!I.Move(_T))
				qdel(I)
				switchListener(_T)
				break
			I.density = FALSE
			beams += I
			I.master = src
			I.setDir(_dir)
			I.invisibility = visible? 0 : INVISIBILITY_ABSTRACT
			T = _T
			_T = get_step(_T, _dir)
			CHECK_TICK

/obj/item/device/assembly/infra/attack_hand()
	. = ..()
	refreshBeam()

/obj/item/device/assembly/infra/Moved()
	var/t = dir
	. = ..()
	setDir(t)

/obj/item/device/assembly/infra/throw_at()
	. = ..()
	olddir = dir

/obj/item/device/assembly/infra/throw_impact()
	. = ..()
	if(!olddir)
		return
	setDir(olddir)
	olddir = null

/obj/item/device/assembly/infra/holder_movement()
	if(!holder)
		return 0
	refreshBeam()
	return 1

/obj/item/device/assembly/infra/proc/trigger_beam(atom/movable/AM, turf/location)
	refreshBeam()
	switchListener(location)
	if(!secured || !on || next_activate > world.time)
		return FALSE
	pulse(0)
	audible_message("[icon2html(src, hearers(src))] *beep* *beep*", null, 3)
	next_activate =  world.time + 30

/obj/item/device/assembly/infra/proc/switchListener(turf/newloc)
	QDEL_NULL(listener)
	listener = newloc.AddComponent(/datum/component/redirect, COMSIG_ATOM_EXITED, CALLBACK(src, .proc/check_exit))

/obj/item/device/assembly/infra/proc/check_exit(atom/movable/offender)
	if(offender && ((offender.flags_1 & ABSTRACT_1) || offender == src))
		return
	return refreshBeam()

/obj/item/device/assembly/infra/interact(mob/user)//TODO: change this this to the wire control panel
	if(is_secured(user))
		user.set_machine(src)
		var/dat = "<TT><B>Infrared Laser</B>\n<B>Status</B>: [on ? "<A href='?src=[REF(src)];state=0'>On</A>" : "<A href='?src=[REF(src)];state=1'>Off</A>"]<BR>\n<B>Visibility</B>: [visible ? "<A href='?src=[REF(src)];visible=0'>Visible</A>" : "<A href='?src=[REF(src)];visible=1'>Invisible</A>"]<BR>\n</TT>"
		dat += "<BR><BR><A href='?src=[REF(src)];refresh=1'>Refresh</A>"
		dat += "<BR><BR><A href='?src=[REF(src)];close=1'>Close</A>"
		user << browse(dat, "window=infra")
		onclose(user, "infra")
		return

/obj/item/device/assembly/infra/Topic(href, href_list)
	..()
	if(usr.incapacitated() || !in_range(loc, usr))
		usr << browse(null, "window=infra")
		onclose(usr, "infra")
		return
	if(href_list["state"])
		on = !(on)
		update_icon()
		refreshBeam()
	if(href_list["visible"])
		visible = !(visible)
		refreshBeam()
	if(href_list["close"])
		usr << browse(null, "window=infra")
		return
	if(usr)
		attack_self(usr)

/obj/item/device/assembly/infra/verb/rotate()//This could likely be better
	set name = "Rotate Infrared Laser"
	set category = "Object"
	set src in usr

	if(usr.incapacitated())
		return

	setDir(turn(dir, -90))

/obj/item/device/assembly/infra/AltClick(mob/user)
	..()
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!in_range(src, user))
		return
	else
		rotate()

/obj/item/device/assembly/infra/setDir()
	. = ..()
	refreshBeam()

/***************************IBeam*********************************/

/obj/effect/beam/i_beam
	name = "infrared beam"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "ibeam"
	var/obj/item/device/assembly/infra/master
	anchored = TRUE
	density = FALSE
	flags_1 = ABSTRACT_1
	pass_flags = PASSTABLE|PASSGLASS|PASSGRILLE|LETPASSTHROW

/obj/effect/beam/i_beam/Crossed(atom/movable/AM as mob|obj)
	if(istype(AM, /obj/effect/beam) || (AM.flags_1 & ABSTRACT_1))
		return
	master.trigger_beam(AM, get_turf(src))
