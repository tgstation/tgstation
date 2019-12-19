//Automated arm for picking up loose items and placing them into machines or on the ground. Method done is via an attack, uses a dummy mob to emulate this.

/obj/machinery/robotic_arm
	icon = 'icons/obj/machines/robotic_arm.dmi'
	icon_state = "robot_arm"
	name = "automatic robotic arm"
	desc = "A cyborg arm on a stationary base."
	use_power = IDLE_POWER_USE
	idle_power_usage = 0
	active_power_usage = 100
	layer = BELOW_OBJ_LAYER
	dir = 1
	anchored = FALSE
	var/r_arm = TRUE //False if we need to return a left arm upon disassembly
	var/moving = FALSE
	var/obj/machinery/target
	var/turf/source
	var/turf/dest
	var/obj/item/held
	var/mob/living/simple_animal/robotic_arm_dummy/dummy //A dummy mob to use when inserting objects, which is done via attack chain.

/obj/machinery/robotic_arm/lefty
	r_arm = FALSE

/obj/machinery/robotic_arm/Initialize()
	. = ..()
	wires = new /datum/wires/robotic_arm(src)
	dummy = new /mob/living/simple_animal/robotic_arm_dummy(src)
	dummy.arm = src
	source_update()

/obj/machinery/robotic_arm/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation, ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_VERBS, null, CALLBACK(src, .proc/can_be_rotated))

/obj/machinery/robotic_arm/proc/can_be_rotated(mob/user,rotation_type)
	if (anchored)
		to_chat(user, "<span class='warning'>It is fastened to the floor!</span>")
		return FALSE
	return TRUE

/obj/machinery/robotic_arm/Moved() //In case we get moved while still anchored (admemes, shuttle, whatever)
	. = ..()
	if(!anchored)
		return
	set_turfs()

/obj/machinery/robotic_arm/attackby(obj/item/I, mob/user, params)
	if(is_wire_tool(I) && panel_open)
		wires.interact(user)
		return
	return ..()

/obj/machinery/robotic_arm/wrench_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(!I.use_tool(src, user, 5, volume=50))
		return 
	anchored = !anchored
	if(!anchored)
		STOP_PROCESSING(SSmachines, src)
	else
		set_turfs()
		START_PROCESSING(SSmachines, src)
	user.visible_message("<span class='notice'>[user.name] [anchored?"unbolts":"bolts down"] the [src].</span>", \
				"<span class='notice'>You [anchored?"unbolt":"bolt down"] the [src].</span>")
	return TRUE

/obj/machinery/robotic_arm/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	default_deconstruction_screwdriver(user, "robot_arm", "robot_arm", I)
	return TRUE

/obj/machinery/robotic_arm/crowbar_act(mob/living/user, obj/item/I)
	if(!panel_open)
		return FALSE
	if(I.use_tool(src, user, 5, volume=50))
		if(r_arm)
			new /obj/item/bodypart/r_arm/robot(get_turf(src))
		else
			new /obj/item/bodypart/l_arm/robot(get_turf(src))
		new /obj/item/robotic_arm_base(get_turf(src))
		user.visible_message("<span class='notice'>[user.name] prys off the robotic arm from its base.</span>", \
				"<span class='notice'>You pry off the robotic arm from its base</span>")
		qdel(dummy) //prevent robo-gibs
		qdel(src)
		return TRUE

/obj/machinery/robotic_arm/Destroy()
	target = null
	source = null
	dest = null
	if(held)
		held.forceMove(get_turf(src))
	held = null
	if(dummy && !QDELETED(dummy))
		dummy.death(FALSE)
	. = ..()

/obj/machinery/robotic_arm/proc/set_turfs()
	if(source)
		UnregisterSignal(source, COMSIG_TURF_CONTENTS_CHANGE)
	if(dest)
		UnregisterSignal(dest, COMSIG_TURF_CONTENTS_CHANGE)
	source = get_step(src, turn(dir,-180))
	RegisterSignal(source, COMSIG_TURF_CONTENTS_CHANGE, .proc/source_update)
	dest = get_step(src, dir)

/obj/machinery/robotic_arm/process()
	..()
	if(!anchored || moving)
		return
	if(!anchored  || wires.is_cut(WIRE_SENSOR) || wires.is_cut(WIRE_MOTOR1) || !locate(/obj/item) in source) //If we're unanchored, our detection wire is cut, or the arm rotate wire is cut
		STOP_PROCESSING(SSmachines, src)
		return
	if(!grab()) //if we didn't find jack
		STOP_PROCESSING(SSmachines, src)

/obj/machinery/robotic_arm/proc/grab()
	if(!held) //wire shenanigans can lead to us already having something held...
		var/O = locate(/obj/item) in source
		if(!O)
			return FALSE
		held = O
		held.forceMove(src)
		dummy.real_name = "robotic_arm([held.fingerprintslast])" //For admin log purposes
	animate_move()
	addtimer(CALLBACK(src, /obj/machinery/robotic_arm/proc/deposit), 1 SECONDS, TIMER_UNIQUE)
	moving = TRUE
	return TRUE

/obj/machinery/robotic_arm/proc/deposit()
	destination_update()
	if(wires.is_cut(WIRE_MOTOR2))
		ADD_TRAIT(held, TRAIT_NODROP, HELD_BY_ROBOARM) //Nodrop for the attack chain
	else
		REMOVE_TRAIT(held, TRAIT_NODROP, HELD_BY_ROBOARM)
	if(target)
		held.melee_attack_chain(dummy, target)
	if(held.loc == src && !HAS_TRAIT(held, TRAIT_NODROP)) //If the above didn't take it from us
		held.forceMove(dest)
	if(held.loc != src)
		held = null
	animate_return()
	sleep(1)
	moving = FALSE

/obj/machinery/robotic_arm/proc/animate_move()
	icon_state = "robot_arm_dropping"
	flick("robot_arm_move", src)
	return

obj/machinery/robotic_arm/proc/animate_return()
	icon_state = "robot_arm"
	flick("robot_arm_return", src)
	return

/obj/machinery/robotic_arm/proc/source_update()
	START_PROCESSING(SSmachines, src)
	return

/obj/machinery/robotic_arm/proc/destination_update() //prioritize machines, then mobs, and finally items
	if(target && !QDELETED(target) && get_turf(target) == dest)
		return
	target = null
	var/M
	for(M in dest)
		if(istype(M, /obj/machinery))
			if(istype(M,/obj/machinery/atmospherics))
				continue
			target = M
			return
	M = locate(/mob) in dest
	if(M)
		target = M
		return
	M = locate(/obj/item) in dest
	if(M)
		target = M


////////////////////
//Dummy Simple Mob//
////////////////////

/mob/living/simple_animal/robotic_arm_dummy
	name = "robotic arm"
	health = 200
	maxHealth = 200
	mob_biotypes = MOB_ROBOTIC
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	AIStatus = AI_OFF
	sentience_type = SENTIENCE_BOSS
	can_have_ai = FALSE
	del_on_death = 1
	var/obj/machinery/robotic_arm/arm

/mob/living/simple_animal/robotic_arm_dummy/death()
	if(arm && !QDELETED(arm))
		qdel(arm)
	new /obj/effect/gibspawner/robot(get_turf(src))
	. = ..()
	

////////////////////
//Robotic Arm Base//
////////////////////
obj/item/robotic_arm_base
	icon = 'icons/obj/machines/robotic_arm.dmi'
	icon_state = "base02"
	name = "robotic arm base"
	desc = "A base frame to support an automatic robotic arm."

obj/item/robotic_arm_base/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/bodypart/r_arm/robot))
		new /obj/machinery/robotic_arm(get_turf(src))
		qdel(W)
		qdel(src)
		return

	if(istype(W, /obj/item/bodypart/l_arm/robot))
		new /obj/machinery/robotic_arm/lefty(get_turf(src))
		qdel(W)
		qdel(src)
		return

	. = ..()
