//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/obj/machinery/power/emitter
	name = "Emitter"
	desc = "A heavy duty industrial laser"
	icon = 'icons/obj/singularity.dmi'
	icon_state = "emitter"
	anchored = 0
	density = 1
	req_access = list(access_engine_equip)

	use_power = 0
	idle_power_usage = 10
	active_power_usage = 300

	var/active = 0
	var/powered = 0
	var/fire_delay = 100
	var/last_shot = 0
	var/shot_number = 0
	var/locked = 0

	machine_flags = EMAGGABLE | WRENCHMOVE | FIXED2WORK | WELD_FIXED

	var/frequency = 0
	var/id_tag = null
	var/datum/radio_frequency/radio_connection

	// Now uses a constant beam.
	var/obj/effect/beam/emitter/beam = null

	//Radio remote control
/obj/machinery/power/emitter/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)


/obj/machinery/power/emitter/verb/rotate_cw()
	set name = "Rotate (Clockwise)"
	set category = "Object"
	set src in oview(1)

	if (src.anchored || usr:stat)
		usr << "It is fastened to the floor!"
		return 0
	src.dir = turn(src.dir, 90)
	return 1

/obj/machinery/power/emitter/verb/rotate_ccw()
	set name = "Rotate (Counter-Clockwise)"
	set category = "Object"
	set src in oview(1)

	if (src.anchored || usr:stat)
		usr << "It is fastened to the floor!"
		return 0
	src.dir = turn(src.dir, -90)
	return 1

/obj/machinery/power/emitter/initialize()
	..()
	if(state == 2 && anchored)
		connect_to_network()
		src.directwired = 1
	if(frequency)
		set_frequency(frequency)

/obj/machinery/power/emitter/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
	return {"
	<ul>
		<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[1439]">Reset</a>)</li>
		<li>[format_tag("ID Tag","id_tag","set_id")]</a></li>
	</ul>
	"}

/obj/machinery/power/emitter/proc/update_beam()
	if(active)
		if(!beam)
			beam = new (loc)
			beam.dir=dir
		beam.emit(spawn_by=src)
	else
		qdel(beam)
		beam=null

/obj/machinery/power/emitter/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag))
		return 0

	var/on=0
	switch(signal.data["command"])
		if("on")
			on=1

		if("off")
			on=0

		if("set")
			on = signal.data["state"] > 0

		if("toggle")
			on = !active

	if(anchored && state == 2 && on != active)
		active=on
		var/statestr=on?"on":"off"
		// Spammy message_admins("Emitter turned [statestr] by radio signal ([signal.data["command"]] @ [frequency]) in [formatJumpTo(src)]",0,1)
		log_game("Emitter turned [statestr] by radio signal ([signal.data["command"]] @ [frequency]) in ([x],[y],[z])")
		investigate_log("turned <font color='orange'>[statestr]</font> by radio signal ([signal.data["command"]] @ [frequency])","singulo")
		update_icon()
		update_beam()

/obj/machinery/power/emitter/Destroy()
	qdel(beam)
	message_admins("Emitter deleted at ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
	log_game("Emitter deleted at ([x],[y],[z])")
	investigate_log("<font color='red'>deleted</font> at ([x],[y],[z])","singulo")
	..()

/obj/machinery/power/emitter/update_icon()
	if (active && powernet && avail(active_power_usage))
		icon_state = "emitter_+a"
	else
		icon_state = "emitter"


/obj/machinery/power/emitter/attack_hand(mob/user as mob)
	// Require consciousness
	if(user.stat && !isAdminGhost(user))
		return
	src.add_fingerprint(user)
	if(state == 2)
		if(!powernet)
			user << "The emitter isn't connected to a wire."
			return 1
		if(!src.locked)
			if(src.active==1)
				src.active = 0
				user << "You turn off the [src]."
				message_admins("Emitter turned off by [key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
				log_game("Emitter turned off by [user.ckey]([user]) in ([x],[y],[z])")
				investigate_log("turned <font color='red'>off</font> by [user.key]","singulo")
			else
				src.active = 1
				user << "You turn on the [src]."
				src.shot_number = 0
				src.fire_delay = 100
				message_admins("Emitter turned on by [key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
				log_game("Emitter turned on by [user.ckey]([user]) in ([x],[y],[z])")
				investigate_log("turned <font color='green'>on</font> by [user.key]","singulo")
			update_icon()
			update_beam()
		else
			user << "\red The controls are locked!"
	else
		user << "\red The [src] needs to be firmly secured to the floor first."
		return 1


/obj/machinery/power/emitter/emp_act(var/severity)//Emitters are hardened but still might have issues
//	add_load(1000)
/*	if((severity == 1)&&prob(1)&&prob(1))
		if(src.active)
			src.active = 0
			src.use_power = 1	*/
	return 1

/obj/machinery/containment_field/meteorhit()
	return 0

/obj/machinery/power/emitter/process()
	if(stat & BROKEN)
		return

	if(state != 2 || (!powernet && active_power_usage))
		active = 0
		update_icon()
		update_beam()
		return

	if(((last_shot + fire_delay) <= world.time) && (active == 1))
		if(!active_power_usage || avail(active_power_usage))
			add_load(active_power_usage)

			if(!powered)
				powered = 1
				update_icon()
				investigate_log("regained power and turned <font color='green'>on</font>","singulo")
		else
			if(powered)
				powered = 0
				update_icon()
				investigate_log("lost power and turned <font color='red'>off</font>","singulo")
			return

		last_shot = world.time

		if(shot_number < 3)
			fire_delay = 2
			shot_number++
		else
			fire_delay = rand(20, 100)
			shot_number = 0

		//beam = getFromPool(/obj/item/projectile/beam/emitter, loc)
		//beam.dir = dir
		//playsound(get_turf(src), 'sound/weapons/emitter.ogg', 25, 1)

		if(prob(35))
			var/datum/effect/effect/system/spark_spread/Sparks = new
			Sparks.set_up(5, 1, src)
			Sparks.start()

		//A.dumbfire()

/obj/machinery/power/emitter/emag(mob/user)
	if(!emagged)
		locked = 0
		emagged = 1
		user.visible_message("[user.name] emags the [src.name].","\red You short out the lock.")
		return

/obj/machinery/power/emitter/wrenchAnchor(mob/user)
	if(active)
		user << "Turn off the [src] first."
		return
	return ..()

/obj/machinery/power/emitter/weldToFloor()
	if(..() == 1)
		switch(state)
			if(1)
				disconnect_from_network()
				src.directwired = 0
			if(2)
				connect_to_network()
				src.directwired = 1
		return 1
	return -1

/obj/machinery/power/emitter/attackby(obj/item/W, mob/user)
	if(..())
		return 1

	if(istype(W, /obj/item/device/multitool))
		update_multitool_menu(user)

	if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))
		if(emagged)
			user << "\red The lock seems to be broken"
			return
		if(src.allowed(user))
			if(active)
				src.locked = !src.locked
				user << "The controls are now [src.locked ? "locked." : "unlocked."]"
			else
				src.locked = 0 //just in case it somehow gets locked
				user << "\red The controls can only be locked when the [src] is online"
		else
			user << "\red Access denied."
		return

/obj/effect/beam/emitter
	name = "emitter beam"
	icon = 'icons/effects/beam.dmi'

	var/base_state = "emitter"

	icon_state = "emitter_1"

	max_range = 20

	var/power = 1

	anchored = 1.0
	flags = TABLEPASS

	damage_type=BURN
	damage=30

	// Notify prisms of power change.
	var/event/power_change=new

/obj/effect/beam/emitter/proc/set_power(var/newpower=1)
	power=newpower
	if(next)
		var/obj/effect/beam/emitter/next_beam=next
		next_beam.set_power(power)
	update_icon()
	if(!master)
		INVOKE_EVENT(power_change,list("beam"=src))

/obj/effect/beam/emitter/spawn_child()
	var/obj/effect/beam/emitter/beam = ..()
	beam.power=power
	return beam

/obj/effect/beam/emitter/update_icon()
	var/visible_power=min(max(round(power/3)+1,1),3)
	//if(!master) testing("Visible power: [visible_power]")
	icon_state="[base_state]_[visible_power]"

/obj/effect/beam/emitter/get_damage()
	return damage*power