<<<<<<< HEAD
//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/obj/machinery/power/emitter
	name = "Emitter"
	desc = "A heavy duty industrial laser.\n<span class='notice'>Alt-click to rotate it clockwise.</span>"
	icon = 'icons/obj/singularity.dmi'
	icon_state = "emitter"
	var/icon_state_on = "emitter_+a"
	anchored = 0
	density = 1
	req_access = list(access_engine_equip)

	use_power = 0
	idle_power_usage = 10
	active_power_usage = 300

	var/active = 0
	var/powered = 0
	var/fire_delay = 100
	var/maximum_fire_delay = 100
	var/minimum_fire_delay = 20
	var/last_shot = 0
	var/shot_number = 0
	var/state = 0
	var/locked = 0

	var/projectile_type = /obj/item/projectile/beam/emitter

	var/projectile_sound = 'sound/weapons/emitter.ogg'

/obj/machinery/power/emitter/New()
	..()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/emitter(null)
	B.apply_default_parts(src)
	RefreshParts()

/obj/item/weapon/circuitboard/machine/emitter
	name = "circuit board (Emitter)"
	build_path = /obj/machinery/power/emitter
	origin_tech = "programming=3;powerstorage=4;engineering=4"
	req_components = list(
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)

/obj/machinery/power/emitter/RefreshParts()
	var/max_firedelay = 120
	var/firedelay = 120
	var/min_firedelay = 24
	var/power_usage = 350
	for(var/obj/item/weapon/stock_parts/micro_laser/L in component_parts)
		max_firedelay -= 20 * L.rating
		min_firedelay -= 4 * L.rating
		firedelay -= 20 * L.rating
	maximum_fire_delay = max_firedelay
	minimum_fire_delay = min_firedelay
	fire_delay = firedelay
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		power_usage -= 50 * M.rating
	active_power_usage = power_usage

/obj/machinery/power/emitter/verb/rotate()
	set name = "Rotate"
	set category = "Object"
	set src in oview(1)

	if(usr.stat || !usr.canmove || usr.restrained())
		return
	if (src.anchored)
		usr << "<span class='warning'>It is fastened to the floor!</span>"
		return 0
	src.setDir(turn(src.dir, 270))
	return 1

/obj/machinery/power/emitter/AltClick(mob/user)
	..()
	if(user.incapacitated())
		user << "<span class='warning'>You can't do that right now!</span>"
		return
	if(!in_range(src, user))
		return
	else
		rotate()

/obj/machinery/power/emitter/initialize()
	..()
	if(state == 2 && anchored)
		connect_to_network()

/obj/machinery/power/emitter/Destroy()
	if(ticker && ticker.current_state == GAME_STATE_PLAYING)
		message_admins("Emitter deleted at ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
		log_game("Emitter deleted at ([x],[y],[z])")
		investigate_log("<font color='red'>deleted</font> at ([x],[y],[z])","singulo")
	return ..()

/obj/machinery/power/emitter/update_icon()
	if (active && powernet && avail(active_power_usage))
		icon_state = icon_state_on
	else
		icon_state = initial(icon_state)


/obj/machinery/power/emitter/attack_hand(mob/user)
	src.add_fingerprint(user)
	if(state == 2)
		if(!powernet)
			user << "<span class='warning'>The emitter isn't connected to a wire!</span>"
			return 1
		if(!src.locked)
			if(src.active==1)
				src.active = 0
				user << "<span class='notice'>You turn off \the [src].</span>"
				message_admins("Emitter turned off by [key_name_admin(user)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[user]'>FLW</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
				log_game("Emitter turned off by [key_name(user)] in ([x],[y],[z])")
				investigate_log("turned <font color='red'>off</font> by [key_name(user)]","singulo")
			else
				src.active = 1
				user << "<span class='notice'>You turn on \the [src].</span>"
				src.shot_number = 0
				src.fire_delay = maximum_fire_delay
				investigate_log("turned <font color='green'>on</font> by [key_name(user)]","singulo")
			update_icon()
		else
			user << "<span class='warning'>The controls are locked!</span>"
	else
		user << "<span class='warning'>The [src] needs to be firmly secured to the floor first!</span>"
		return 1


/obj/machinery/power/emitter/emp_act(severity)//Emitters are hardened but still might have issues
//	add_load(1000)
/*	if((severity == 1)&&prob(1)&&prob(1))
		if(src.active)
			src.active = 0
			src.use_power = 1	*/
	return 1


/obj/machinery/power/emitter/process()
	if(stat & (BROKEN))
		return
	if(src.state != 2 || (!powernet && active_power_usage))
		src.active = 0
		update_icon()
		return
	if(((src.last_shot + src.fire_delay) <= world.time) && (src.active == 1))

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
				log_game("Emitter lost power in ([x],[y],[z])")
				message_admins("Emitter lost power in ([x],[y],[z] - <a href='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
			return

		src.last_shot = world.time
		if(src.shot_number < 3)
			src.fire_delay = 2
			src.shot_number ++
		else
			src.fire_delay = rand(minimum_fire_delay,maximum_fire_delay)
			src.shot_number = 0

		var/obj/item/projectile/A = PoolOrNew(projectile_type,src.loc)

		A.setDir(src.dir)
		playsound(src.loc, projectile_sound, 25, 1)

		if(prob(35))
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(5, 1, src)
			s.start()

		switch(dir)
			if(NORTH)
				A.yo = 20
				A.xo = 0
			if(EAST)
				A.yo = 0
				A.xo = 20
			if(WEST)
				A.yo = 0
				A.xo = -20
			else // Any other
				A.yo = -20
				A.xo = 0
		A.starting = loc
		A.fire()


/obj/machinery/power/emitter/attackby(obj/item/W, mob/user, params)

	if(istype(W, /obj/item/weapon/wrench))
		if(active)
			user << "<span class='warning'>Turn off \the [src] first!</span>"
			return
		switch(state)
			if(0)
				if(isinspace()) return
				state = 1
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				user.visible_message("[user.name] secures [src.name] to the floor.", \
					"<span class='notice'>You secure the external reinforcing bolts to the floor.</span>", \
					"<span class='italics'>You hear a ratchet</span>")
				src.anchored = 1
			if(1)
				state = 0
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				user.visible_message("[user.name] unsecures [src.name] reinforcing bolts from the floor.", \
					"<span class='notice'>You undo the external reinforcing bolts.</span>", \
					"<span class='italics'>You hear a ratchet.</span>")
				src.anchored = 0
			if(2)
				user << "<span class='warning'>The [src.name] needs to be unwelded from the floor!</span>"
		return

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(active)
			user << "Turn off \the [src] first."
			return
		switch(state)
			if(0)
				user << "<span class='warning'>The [src.name] needs to be wrenched to the floor!</span>"
			if(1)
				if (WT.remove_fuel(0,user))
					playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)
					user.visible_message("[user.name] starts to weld the [src.name] to the floor.", \
						"<span class='notice'>You start to weld \the [src] to the floor...</span>", \
						"<span class='italics'>You hear welding.</span>")
					if (do_after(user,20/W.toolspeed, target = src))
						if(!src || !WT.isOn()) return
						state = 2
						user << "<span class='notice'>You weld \the [src] to the floor.</span>"
						connect_to_network()
			if(2)
				if (WT.remove_fuel(0,user))
					playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)
					user.visible_message("[user.name] starts to cut the [src.name] free from the floor.", \
						"<span class='notice'>You start to cut \the [src] free from the floor...</span>", \
						"<span class='italics'>You hear welding.</span>")
					if (do_after(user,20/W.toolspeed, target = src))
						if(!src || !WT.isOn()) return
						state = 1
						user << "<span class='notice'>You cut \the [src] free from the floor.</span>"
						disconnect_from_network()
		return

	if(W.GetID())
		if(emagged)
			user << "<span class='warning'>The lock seems to be broken!</span>"
			return
		if(allowed(user))
			if(active)
				locked = !locked
				user << "<span class='notice'>You [src.locked ? "lock" : "unlock"] the controls.</span>"
			else
				user << "<span class='warning'>The controls can only be locked when \the [src] is online!</span>"
		else
			user << "<span class='danger'>Access denied.</span>"
		return

	if(default_deconstruction_screwdriver(user, "emitter_open", "emitter", W))
		return

	if(exchange_parts(user, W))
		return

	if(default_pry_open(W))
		return

	if(default_deconstruction_crowbar(W))
		return

	return ..()

/obj/machinery/power/emitter/emag_act(mob/user)
	if(!emagged)
		locked = 0
		emagged = 1
		if(user)
			user.visible_message("[user.name] emags the [src.name].","<span class='notice'>You short out the lock.</span>")
=======
//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/obj/machinery/power/emitter
	name = "emitter"
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

	machine_flags = EMAGGABLE | WRENCHMOVE | FIXED2WORK | WELD_FIXED | MULTITOOL_MENU

	var/frequency = 0
	var/id_tag = null
	var/datum/radio_frequency/radio_connection

	//Now uses a constant beam.
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

	if(src.anchored || usr:stat)
		to_chat(usr, "<span class='warning'>It is fastened to the floor!</span>")
		return 0
	src.dir = turn(src.dir, -90)
	return 1

/obj/machinery/power/emitter/verb/rotate_ccw()
	set name = "Rotate (Counter-Clockwise)"
	set category = "Object"
	set src in oview(1)

	if(src.anchored || usr:stat)
		to_chat(usr, "<span class='warning'>It is fastened to the floor!</span>")
		return 0
	src.dir = turn(src.dir, 90)
	return 1

/obj/machinery/power/emitter/initialize()

	..()
	if(state == 2 && anchored)
		connect_to_network()
		update_icon()
		update_beam()

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


	if(active && powered)
		if(!beam)
			beam = new (loc)
			beam.dir = dir
			beam.emit(spawn_by=src)
	else
		if(beam)
			beam._re_emit = 0
			qdel(beam)
			beam = null

/obj/machinery/power/emitter/receive_signal(datum/signal/signal)

	if(!signal.data["tag"] || (signal.data["tag"] != id_tag))
		return 0

	var/on
//	to_chat(world, "\ref[src] received signal. tag [signal.data["tag"]], cmd [signal.data["command"]], state [signal.data["state"]], sigtype [signal.data["sigtype"]]")
	if(signal.data["command"])
		switch(signal.data["command"])
			if("on")
				on = 1

			if("off")
				on = 0

			if("set")
				on = signal.data["state"] > 0

			if("toggle")
				on = !active

		if(!isnull(on) && anchored && state == 2 && on != active)
			active = on
			var/statestr = on ? "on":"off"
			// Spammy message_admins("Emitter turned [statestr] by radio signal ([signal.data["command"]] @ [frequency]) in [formatJumpTo(src)]",0,1)
			log_game("Emitter turned [statestr] by radio signal ([signal.data["command"]] @ [frequency]) in ([x],[y],[z])")
			investigation_log(I_SINGULO,"turned <font color='orange'>[statestr]</font> by radio signal ([signal.data["command"]] @ [frequency])")
			update_icon()
			update_beam()

/obj/machinery/power/emitter/Destroy()

	qdel(beam)
	message_admins("Emitter deleted at ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
	log_game("Emitter deleted at ([x],[y],[z])")
	investigation_log(I_SINGULO,"<font color='red'>deleted</font> at ([x],[y],[z])")
	..()

/obj/machinery/power/emitter/update_icon()

	if(powered && get_powernet() && avail(active_power_usage) && active)
		icon_state = "emitter_+a"
	else
		icon_state = "emitter"

/obj/machinery/power/emitter/attack_hand(mob/user as mob)

	//Require consciousness
	if(user.stat && !isAdminGhost(user))
		return

	src.add_fingerprint(user)
	if(state == 2)
		if(!get_powernet())
			to_chat(user, "<span class='warning'>\The [src] isn't connected to a wire.</span>")
			return 1
		if(!src.locked)
			if(active)
				turn_off()
				user.visible_message("<span class='warning'>[user] turns \the [src] off.", \
				"<span class='notice'>You turn \the [src] off.")
				message_admins("Emitter turned off by [key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
				log_game("Emitter turned off by [user.ckey]([user]) in ([x],[y],[z])")
				investigation_log(I_SINGULO,"turned <font color='red'>off</font> by [user.key]")
			else
				turn_on()
				user.visible_message("<span class='warning'>[user] turns \the [src] on.", \
				"<span class='notice'>You turn \the [src] on.")
				message_admins("Emitter turned on by [key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
				log_game("Emitter turned on by [user.ckey]([user]) in ([x],[y],[z])")
				investigation_log(I_SINGULO,"turned <font color='green'>on</font> by [user.key]")
		else
			to_chat(user, "<span class='warning'>\The [src]'s controls are locked!</span>")
	else
		to_chat(user, "<span class='warning'>\The [src] needs to be firmly secured to the floor first.</span>")
		return 1

//Important note, those procs not log the emitter being turned on or off, so please use the logs in attack_hand above
/obj/machinery/power/emitter/proc/turn_on()
	active = 1
	shot_number = 0
	fire_delay = 100
	update_icon()
	update_beam()

/obj/machinery/power/emitter/proc/turn_off()
	active = 0
	update_icon()
	update_beam()

/obj/machinery/power/emitter/emp_act(var/severity) //Emitters are EMP-proof for obvious reasons

	return 1

/obj/machinery/power/emitter/process()

	if(!anchored) //If it got unanchored "inexplicably"... fucking badmins
		active = 0
		update_icon()
		update_beam()
		return

	if(stat & BROKEN)
		return

	if(state != 2 || (!powernet && active_power_usage)) //Not welded to the floor, or no more wire underneath and requires power
		active = 0
		update_icon()
		update_beam()
		return

	if(((last_shot + fire_delay) <= world.time) && (active == 1)) //It's currently activated and it hasn't processed in a bit
		if(!active_power_usage || avail(active_power_usage)) //Doesn't require power or powernet has enough supply
			add_load(active_power_usage) //Drain it then bitch
			if(!powered) //Yay its powered
				powered = 1
				update_icon()
				update_beam()
				investigation_log(I_SINGULO,"regained power and turned <font color='green'>on</font>")
		else
			if(powered) //Fuck its not anymore
				powered = 0 //Whelp time to kill it then
				update_beam() //Update its beam and icon
				update_icon()
				investigation_log(I_SINGULO,"lost power and turned <font color='red'>off</font>")
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
		user.visible_message("<span class='danger'>[user] shorts out \the [src]'s lock.</span>", "<span class='warning'>You short out \the [src]'s lock.</span>")
		return

/obj/machinery/power/emitter/wrenchAnchor(mob/user)

	if(active)
		to_chat(user, "<span class='warning'>Turn off \the [src] first.</span>")
		return
	return ..()

/obj/machinery/power/emitter/weldToFloor()

	if(..() == 1)
		switch(state)
			if(1)
				disconnect_from_network()
			if(2)
				connect_to_network()
		return 1
	return -1

/obj/machinery/power/emitter/attackby(obj/item/W, mob/user)

	. = ..() //Holy fucking shit
	if(.)
		return .

	if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))
		if(emagged)
			to_chat(user, "<span class='warning'>The lock appears to be broken.</span>")
			return
		if(src.allowed(user))
			if(active)
				src.locked = !src.locked
				to_chat(user, "<span class='notice'>The controls are now [src.locked ? "locked" : "unlocked"].</span>")
			else
				src.locked = 0 //just in case it somehow gets locked
				to_chat(user, "<span class='warning'>The controls can only be locked when \the [src] is online</span>")
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")
		return

/obj/effect/beam/emitter

	name = "emitter beam"
	icon = 'icons/effects/beam.dmi'
	icon_state = "emitter_1"
	anchored = 1.0
	flags = 0
	damage = 30
	damage_type = BURN

	var/base_state = "emitter"
	var/power = 1

	//Notify prisms of power change.
	var/event/power_change = new

/obj/effect/beam/emitter/proc/set_power(var/newpower = 1)
	power = newpower
	if(next)
		var/obj/effect/beam/emitter/next_beam=next
		next_beam.set_power(power)
	update_icon()
	if(!master)
		INVOKE_EVENT(power_change,list("beam" = src))

/obj/effect/beam/emitter/spawn_child()
	var/obj/effect/beam/emitter/beam = ..()
	if(!beam) return null
	beam.power = power
	return beam

/obj/effect/beam/emitter/update_icon()
	if(!master)
		invisibility = 101 //Make doubly sure
		return
	var/visible_power = Clamp(round(power/3) + 1, 1, 3)
	//if(!master)
		//testing("Visible power: [visible_power]")
	icon_state = "[base_state]_[visible_power]"

/obj/effect/beam/emitter/get_machine_underlay(var/mdir)
	var/visible_power = Clamp(round(power/3) + 1, 1, 3)
	return image(icon = icon, icon_state = "[base_state]_[visible_power] underlay", dir = mdir)

/obj/effect/beam/emitter/get_damage()
	return damage * power

/obj/machinery/power/emitter/canClone(var/obj/machinery/power/emitter/O)
	return istype(O)

/obj/machinery/power/emitter/clone(var/obj/machinery/power/emitter/O)
	id_tag = O.id_tag
	set_frequency(O.id_tag)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
