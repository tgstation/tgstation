/obj/item/device/assembly/infra
	name = "infrared emitter"
	desc = "Emits a visible or invisible beam and is triggered when the beam is interrupted.\n<span class='notice'>Alt-click to rotate it clockwise.</span>"
	icon_state = "infrared"
	materials = list(MAT_METAL=1000, MAT_GLASS=500)
	origin_tech = "magnets=2;materials=2"

	var/on = 0
	var/visible = 0
	var/obj/effect/beam/i_beam/first = null
	var/obj/effect/beam/i_beam/last = null


/obj/item/device/assembly/infra/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/device/assembly/infra/Destroy()
	if(first)
		qdel(first)
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
		on = 0
		if(first)
			qdel(first)
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

/obj/item/device/assembly/infra/process()
	if(!on)
		if(first)
			qdel(first)
		return
	if(!secured)
		return
	if(first && last)
		last.process()
		return
	var/turf/T = get_turf(src)
	if(T)
		var/obj/effect/beam/i_beam/I = new /obj/effect/beam/i_beam(T)
		I.master = src
		I.density = 1
		I.setDir(dir)
		first = I
		step(I, I.dir)
		if(first)
			I.density = 0
			I.vis_spread(visible)
			I.limit = 8
			I.process()

/obj/item/device/assembly/infra/attack_hand()
	qdel(first)
	..()
	return

/obj/item/device/assembly/infra/Move()
	var/t = dir
	..()
	setDir(t)
	qdel(first)
	return

/obj/item/device/assembly/infra/holder_movement()
	if(!holder)
		return 0
	qdel(first)
	return 1

/obj/item/device/assembly/infra/proc/trigger_beam()
	if(!secured || !on || next_activate > world.time)
		return FALSE
	pulse(0)
	audible_message("\icon[src] *beep* *beep*", null, 3)
	next_activate =  world.time + 30

/obj/item/device/assembly/infra/interact(mob/user)//TODO: change this this to the wire control panel
	if(is_secured(user))
		user.set_machine(src)
		var/dat = "<TT><B>Infrared Laser</B>\n<B>Status</B>: [on ? "<A href='?src=\ref[src];state=0'>On</A>" : "<A href='?src=\ref[src];state=1'>Off</A>"]<BR>\n<B>Visibility</B>: [visible ? "<A href='?src=\ref[src];visible=0'>Visible</A>" : "<A href='?src=\ref[src];visible=1'>Invisible</A>"]<BR>\n</TT>"
		dat += "<BR><BR><A href='?src=\ref[src];refresh=1'>Refresh</A>"
		dat += "<BR><BR><A href='?src=\ref[src];close=1'>Close</A>"
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
	if(href_list["visible"])
		visible = !(visible)
		if(first)
			first.vis_spread(visible)
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

	setDir(turn(dir, 90))
	return

/obj/item/device/assembly/infra/AltClick(mob/user)
	..()
	if(user.incapacitated())
		user << "<span class='warning'>You can't do that right now!</span>"
		return
	if(!in_range(src, user))
		return
	else
		rotate()



/***************************IBeam*********************************/

/obj/effect/beam/i_beam
	name = "infrared beam"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "ibeam"
	var/obj/effect/beam/i_beam/next = null
	var/obj/effect/beam/i_beam/previous = null
	var/obj/item/device/assembly/infra/master = null
	var/limit = null
	var/visible = 0
	var/left = null
	anchored = 1


/obj/effect/beam/i_beam/proc/hit()
	if(master)
		master.trigger_beam()
	qdel(src)
	return

/obj/effect/beam/i_beam/proc/vis_spread(v)
	visible = v
	if(next)
		next.vis_spread(v)


/obj/effect/beam/i_beam/process()
	if((loc.density || !(master)))
		qdel(src)
		return
	if(left > 0)
		left--
	if(left < 1)
		if(!(visible))
			invisibility = INVISIBILITY_ABSTRACT
		else
			invisibility = 0
	else
		invisibility = 0

	if(!next && (limit > 0))
		var/obj/effect/beam/i_beam/I = new /obj/effect/beam/i_beam(loc)
		I.master = master
		I.density = 1
		I.setDir(dir)
		I.previous = src
		next = I
		step(I, I.dir)
		if(next)
			I.density = 0
			I.vis_spread(visible)
			I.limit = limit - 1
			master.last = I
			I.process()

/obj/effect/beam/i_beam/Bump()
	qdel(src)
	return

/obj/effect/beam/i_beam/Bumped()
	hit()

/obj/effect/beam/i_beam/Crossed(atom/movable/AM as mob|obj)
	if(istype(AM, /obj/effect/beam))
		return
	hit()

/obj/effect/beam/i_beam/Destroy()
	if(master.first == src)
		master.first = null
	if(next)
		qdel(next)
		next = null
	if(previous)
		previous.next = null
		master.last = previous
	return ..()
