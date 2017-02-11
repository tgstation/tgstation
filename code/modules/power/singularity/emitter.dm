

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
	wires = new /datum/wires/emitter(src)

/obj/item/weapon/circuitboard/machine/emitter
	name = "Emitter (Machine Board)"
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

/obj/machinery/power/emitter/Initialize()
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

/obj/machinery/power/emitter/attack_animal(mob/living/simple_animal/M)
	if(ismegafauna(M) && anchored)
		state = 0
		anchored = FALSE
		M.visible_message("<span class='warning'>[M] rips [src] free from its moorings!</span>")
	else
		..()
	if(!anchored)
		step(src, get_dir(M, src))


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
	if(src.active == 1)
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
			return
		if(!check_delay())
			return FALSE
		fire_beam()

/obj/machinery/power/emitter/proc/check_delay()
	if((src.last_shot + src.fire_delay) <= world.time)
		return TRUE
	return FALSE

/obj/machinery/power/emitter/proc/fire_beam_pulse()
	if(!check_delay())
		return FALSE
	if(state != 2)
		return FALSE
	if(avail(active_power_usage))
		add_load(active_power_usage)
		fire_beam()

/obj/machinery/power/emitter/proc/fire_beam()
	src.last_shot = world.time
	if(src.shot_number < 3)
		src.fire_delay = 20
		src.shot_number ++
	else
		src.fire_delay = rand(minimum_fire_delay,maximum_fire_delay)
		src.shot_number = 0
	var/obj/item/projectile/A = new projectile_type(src.loc)
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

/obj/machinery/power/emitter/can_be_unfasten_wrench(mob/user, silent)
	if(state == EM_WELDED)
		if(!silent)
			user  << "<span class='warning'>[src] is welded to the floor!</span>"
		return FAILED_UNFASTEN
	return ..()

/obj/machinery/power/emitter/default_unfasten_wrench(mob/user, obj/item/weapon/wrench/W, time = 20)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		if(anchored)
			state = EM_SECURED
		else
			state = EM_UNSECURED

/obj/machinery/power/emitter/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench))
		if(active)
			user << "<span class='warning'>Turn \the [src] off first!</span>"
			return
		default_unfasten_wrench(user, W, 0)
		return

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(active)
			user << "Turn \the [src] off first."
			return
		switch(state)
			if(EM_UNSECURED)
				user << "<span class='warning'>The [src.name] needs to be wrenched to the floor!</span>"
			if(EM_SECURED)
				if(WT.remove_fuel(0,user))
					playsound(loc, WT.usesound, 50, 1)
					user.visible_message("[user.name] starts to weld the [name] to the floor.", \
						"<span class='notice'>You start to weld \the [src] to the floor...</span>", \
						"<span class='italics'>You hear welding.</span>")
					if(do_after(user,20*W.toolspeed, target = src) && WT.isOn())
						state = EM_WELDED
						user << "<span class='notice'>You weld \the [src] to the floor.</span>"
						connect_to_network()
			if(EM_WELDED)
				if(WT.remove_fuel(0,user))
					playsound(loc, WT.usesound, 50, 1)
					user.visible_message("[user.name] starts to cut the [name] free from the floor.", \
						"<span class='notice'>You start to cut \the [src] free from the floor...</span>", \
						"<span class='italics'>You hear welding.</span>")
					if(do_after(user,20*W.toolspeed, target = src) && WT.isOn())
						state = EM_SECURED
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

	if(is_wire_tool(W) && panel_open)
		wires.interact(user)
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
