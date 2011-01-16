/*////////////////////////////////////////////////
The Singularity Engine
By Mport
tbh this could likely be better and I did not use all that many comments on it.
However people seem to like it for some reason.
*/////////////////////////////////////////////////

#define collector_control_range 12

/////SINGULARITY SPAWNER
/obj/machinery/the_singularitygen/
	name = "Gravitational Singularity Generator"
	desc = "An Odd Device which produces a Gravitational Singularity when set up."
	icon = 'singularity.dmi'
	icon_state = "TheSingGen"
	anchored = 1
	density = 1


//////////////////////Singularity gen START
/obj/machinery/the_singularitygen/New()
	..()

/obj/machinery/the_singularitygen/process()
	var/turf/T = get_turf(src)
	if (singularity_is_surrounded(T))
		new /obj/machinery/the_singularity/(T, 100)
		del(src)

/obj/machinery/the_singularitygen/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench))
		anchored = !anchored
		playsound(src.loc, 'Ratchet.ogg', 75, 1)
		if(anchored)
			user.visible_message("[user.name] secures [src.name] to the floor.", \
				"You secure the [src.name] to the floor.", \
				"You hear ratchet")
		else
			user.visible_message("[user.name] unsecures [src.name] from the floor.", \
				"You unsecure the [src.name] from the floor.", \
				"You hear ratchet")
		return
	return ..()

/proc/singularity_is_surrounded(turf/T)
	var/checkpointC = 0
	for (var/obj/X in orange(3,T)) //TODO: do we need requirement to singularity be actually _surrounded_ by field?
		if(istype(X, /obj/machinery/containment_field) || istype(X, /obj/machinery/shieldwall))
			checkpointC ++
	return checkpointC >= 20

/////SINGULARITY
/obj/machinery/the_singularity/
	name = "Gravitational Singularity"
	desc = "A Gravitational Singularity."
	icon = '160x160.dmi'
	icon_state = "Singularity"
	anchored = 1
	density = 1
	layer = 6
	unacidable = 1 //Don't comment this out.
	var/active = 0
	var/energy = 10
	var/Dtime = null
	var/Wtime = 0
	var/dieot = 0
	var/selfmove = 1
	var/grav_pull = 6

//////////////////////Singularity START

/obj/machinery/the_singularity/New(loc, var/E = 100, var/Ti = null)
	src.energy = E
	pixel_x = -64
	pixel_y = -64
	event()
	if(Ti)
		src.Dtime = Ti
	..()
	notify_collector_controller()

/obj/machinery/the_singularity/attack_hand(mob/user as mob)
	return 1

/obj/machinery/the_singularity/blob_act(severity)
	return

/obj/machinery/the_singularity/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0 to 3.0) //no way
			return
	return

/obj/machinery/the_singularity/Del()
	//TODO: some animation
	notify_collector_controller()
	..()

/obj/machinery/the_singularity/process()
	eat()

	if(src.Dtime)//If its a temp singularity IE: an event
		if(Wtime != 0)
			if((src.Wtime + src.Dtime) <= world.time)
				src.Wtime = 0
				del(src)
		else
			src.Wtime = world.time

	if(dieot)
		if(energy <= 0)//slowly dies over time
			del(src)
		else
			energy -= 5

	switch(energy)
		if(1000 to 1999)
			for(var/obj/machinery/field_generator/F in orange(5,src))
				F.turn_off()
		if(2000 to INFINITY)
			explosion(src.loc, 4, 8, 15, 0)
			src.ex_act(1) //if it survived the explosion

	if(prob(15))//Chance for it to run a special event
		event()
	var/turf/T = get_turf(src)
	var/is_surrounded = singularity_is_surrounded(T)
	if ( is_surrounded && active )
		src.active = 0
		src.dieot = 0
		notify_collector_controller()
		spawn(50)
			if (!active)
				grav_pull = 6
				icon_state = "Singularity"
	else if  ( is_surrounded==0 && active==0 )
		src.active = 1
		src.dieot = 1
		grav_pull = 8
		notify_collector_controller()
	if(active == 1)
		move()
		spawn(5)
			move()


/obj/machinery/the_singularity/proc/notify_collector_controller()
	var/oldsrc = src
	src = null //for spawn() working even after Del(), see byond documentation about sleep() -rastaf0
	for(var/obj/machinery/power/collector_control/myCC in orange(collector_control_range,oldsrc))
		spawn() myCC.updatecons()

/obj/machinery/the_singularity
	var/global/list/uneatable = list(\
		/obj/machinery/the_singularity, \
		/obj/machinery/containment_field, \
		/obj/machinery/shieldwall, \
		/turf/space, \
		/obj/effects, \
		/obj/beam, /* not sure*/ \
		/obj/overlay
	)

/obj/machinery/the_singularity/proc/is_eatable(atom/X)
	for (var/Type in uneatable)
		if (istype(X, Type))
			return 0
	return 1

/obj/machinery/the_singularity/proc/eat()
	for (var/atom/X in orange(grav_pull,src))
		if(isarea(X))
			continue
		if (!is_eatable(X))
			continue

		if(istype(X,/obj/machinery/field_generator))
			var/obj/machinery/field_generator/F = X
			if(F.active)
				continue
		if(istype(X,/obj/machinery/shieldwallgen))
			var/obj/machinery/shieldwallgen/S = X
			if(S.active)
				continue
		switch(get_dist(src,X))
			if(0 to 2)
				src.Bumped(X)
			else if(!isturf(X))
				if(!istype(X,/mob/living/carbon/human))
					if(!X:anchored)
						step_towards(X,src)
				else
					var/mob/living/carbon/human/H = X
					if(istype(H.shoes,/obj/item/clothing/shoes/magboots))
						var/obj/item/clothing/shoes/magboots/M = H.shoes
						if(M.magpulse)
							continue
					else
						step_towards(H,src)

/obj/machinery/the_singularity/proc/move()
	var/direction_go = pick(cardinal)
	if(locate(/obj/machinery/containment_field) in get_step(src,direction_go) || \
			locate(/obj/machinery/shieldwall) in get_step(src,direction_go))
		icon_state = "Singularity"
		return
	if(selfmove)
		spawn(0)
			icon_state = "Singularity2"
			step(src, direction_go)


/obj/machinery/the_singularity/Bumped(atom/A)
	var/gain = 0
	if (!is_eatable(A))
		return
	if (istype(A,/mob/living))//if its a mob
		gain = 20
		if(istype(A,/mob/living/carbon/human))
			if(A:mind)
				if((A:mind:assigned_role == "Station Engineer") || (A:mind:assigned_role == "Chief Engineer") )
					gain = 100
		A:gib()

	else if(istype(A,/obj/))
		A:ex_act(1.0)
		if(A) del(A)
		gain = 2

	else if(isturf(A))
		/*if(!active)
			if(isturf(A,/turf/simulated/floor/engine)) //here was a bug. But now it's a feature. -rasta0
				return*/

/*		if(istype(A,/turf/simulated/floor))
			A:ReplaceWithSpace()
			gain = 2
		else
			A:ReplaceWithFloor()*/
		A:ReplaceWithSpace() //
		gain = 2

	src.energy += gain

/////////////////////////////////////////////Controls which "event" is called
/obj/machinery/the_singularity/proc/event()
	var/numb = pick(1,2,3,4,5,6)
	switch(numb)
		if(1)//EMP
			Zzzzap()
		if(2)//Eats the turfs around it
			if(prob(60))
				BHolerip()
			else
				event()
		if(3)//tox damage all carbon mobs in area
			Toxmob()
		if(4)//Stun mobs who lack optic scanners
			Mezzer()
		else
			//do nothing
			return


/obj/machinery/the_singularity/proc/Toxmob()
	for(var/mob/living/carbon/M in view(7, src.loc))
		if(istype(M,/mob/living/carbon/human))
			if(M:wear_suit)
				return
		M.toxloss += 3
		M.radiation += 10
		if (src.energy>150)
			M.toxloss += ((src.energy-150)/50)*3
			M.radiation += ((src.energy-150)/50)*10
		if (src.energy>300)
			M.fireloss += ((src.energy-300)/50)*3
		M.updatehealth()
		M << "\red You feel odd."

/obj/machinery/the_singularity/proc/Mezzer()
	for(var/mob/living/carbon/M in oviewers(8, src))
		if(istype(M,/mob/living/carbon/human))
			if(istype(M:glasses,/obj/item/clothing/glasses/meson))
				M << "\blue You look directly into The [src.name], good thing you had your protective eyewear on!"
				return
		M << "\red You look directly into The [src.name] and feel weak."
		if (M:stunned < 3)
			M.stunned = 3
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red <B>[] stares blankly at The []!</B>", M, src), 1)

/obj/machinery/the_singularity
	var/global/list/turf/simulated/unstrippable = list(\
		/turf/simulated/floor/engine, \
		/turf/simulated/floor/grid, \
		/turf/simulated/shuttle, \
		/turf/simulated/wall/asteroid
	)

//looks like I need new function istypefromlist
/obj/machinery/the_singularity/proc/is_strippable(turf/simulated/X)
	for(var/Type in unstrippable)
		if (istype(X,Type))
			return 0
	return 1

/obj/machinery/the_singularity/proc/BHolerip()
	for (var/turf/simulated/X in orange(5,src))
		if (!is_strippable(X))
			continue
		if (!prob(30))
			continue
		var/dist = get_dist(src,X)
		if ( (dist>=3 && dist<=5) )
			if (istype(X,/turf/simulated/floor) && !istype(X,/turf/simulated/floor/plating))
				if(!X:broken)
					if(prob(80))
						new/obj/item/stack/tile (X)
						X:break_tile_to_plating()
					else

						X:break_tile()
			else if(istype(X,/turf/simulated/wall))
				X:dismantle_wall()
			else
				X:ReplaceWithFloor()

/* NOTE: someone said he has plan to redo EMP so I dont touch anything except excluding pipes - rastaf0 */
/obj/machinery/the_singularity/proc/Zzzzap()///Pulled from wizard spells might edit later
	var/turf/myturf = get_turf(src)

	var/obj/overlay/pulse = new/obj/overlay ( myturf )
	pulse.icon = 'effects.dmi'
	pulse.icon_state = "emppulse"
	pulse.name = "emp pulse"
	pulse.anchored = 1
	spawn(20)
		del(pulse)

	for(var/mob/living/M in viewers(world.view-1, myturf))

		//if(M == usr) continue

		if (istype(M, /mob/living/silicon))
			M.fireloss += 25
			flick("noise", M:flash)
			M << "\red <B>*BZZZT*</B>"
			M << "\red Warning: Electromagnetic pulse detected."
			if(istype(M, /mob/living/silicon/ai))
				if (prob(30))
					switch(pick(1,2)) //Add Random laws.
						if(1)
							M:cancel_camera()
						if(2)
							M:ai_call_shuttle()
						//if(3)
						//	M:lockdown()
			continue


		M << "\red <B>Your equipment malfunctions.</B>"
		if (locate(/obj/item/weapon/cloaking_device, M))
			for(var/obj/item/weapon/cloaking_device/S in M)
				S.active = 0
				S.icon_state = "shield0"
/*
		if (locate(/obj/item/device/disguiser, M))
			for(var/obj/item/device/disguiser/S in M)
				S.disrupt(M)
				S.on = 0
*/

		if (locate(/obj/item/weapon/gun/energy, M))
			for(var/obj/item/weapon/gun/energy/G in M)
				G.charges = 0
				G.update_icon()

		if ((istype(M, /mob/living/carbon/human)) && (istype(M:glasses, /obj/item/clothing/glasses/thermal)))
			M << "\red <B>Your thermals malfunction.</B>"
			M.eye_blind = 3
			M.eye_blurry = 5
			M.disabilities |= 1
			spawn(100)
				if(M)
					M.disabilities &= ~1

		if (locate(/obj/item/device/radio, M))
			for(var/obj/item/device/radio/R in M) //Add something for the intercoms.
				R.broadcasting = 0
				R.listening = 0

		if (locate(/obj/item/device/flash, M))
			for(var/obj/item/device/flash/F in M) //Add something for the intercoms.
				F.attack_self()

		if (locate(/obj/item/weapon/baton, M))
			for(var/obj/item/weapon/baton/B in M) //Add something for the intercoms.
				B.charges = 0

		if(locate(/obj/item/clothing/under/chameleon, M))
			for(var/obj/item/clothing/under/chameleon/C in M) //Add something for the intercoms.
				M << "\red <B>Your jumpsuit malfunctions</B>"
				C.name = "psychedelic"
				C.desc = "Groovy!"
				C.icon_state = "psyche"
				C.color = "psyche"
				spawn(200)
					if(C)
						C.name = "Black Jumpsuit"
						C.icon_state = "bl_suit"
						C.color = "black"
						C.desc = null

		M << "\red <B>BZZZT</B>"


	for(var/obj/machinery/A in range(world.view-1, myturf))
		var/unpowered = 0
		for (var/Type in list(\
			/obj/machinery/atmospherics/pipe, \
			/obj/machinery/the_singularity, \
			/obj/machinery/containment_field, \
			/obj/machinery/shieldwall, \
			/obj/machinery/field_generator )) //field generators arent connected to apc
			if (istype(A,Type))
				unpowered = 1
				break
		if (unpowered)
			continue
		A.use_power(7500)

		var/obj/overlay/pulse2 = new/obj/overlay ( A.loc )
		pulse2.icon = 'effects.dmi'
		pulse2.icon_state = "empdisable"
		pulse2.name = "emp sparks"
		pulse2.anchored = 1
		pulse2.dir = pick(cardinal)

		spawn(10)
			del(pulse2)

		if(istype(A, /obj/machinery/computer) && prob(20))
			A:set_broken()

		if(istype(A, /obj/machinery/firealarm) && prob(50))
			A:alarm()

		if(istype(A, /obj/machinery/power/smes))
			A:online = 0
			A:charging = 0
			A:output = 0
			A:charge -= 1e6
			if (A:charge < 0)
				A:charge = 0

		if(istype(A, /obj/machinery/power/apc))
			if(A:cell)
				A:cell.use(1000)
			A:lighting = 0
			A:equipment = 0
			A:environ = 0

		if(istype(A, /obj/machinery/camera))
			A.icon_state = "cameraemp"
			A:network = null
			for(var/mob/living/silicon/ai/O in world)
				if (O.current == A)
					O.cancel_camera()
					O << "Your connection to the camera has been lost."

		if(istype(A, /obj/machinery/clonepod))
			A:malfunction()

////////CONTAINMENT FIELD

/obj/machinery/containment_field
	name = "Containment Field"
	desc = "An energy field."
	icon = 'singularity.dmi'
	icon_state = "Contain_F"
	anchored = 1
	density = 0
	unacidable = 1
	//var/active = 1
	//var/power = 10
	//var/delay = 5
	//var/last_active
	//var/mob/U
	var/obj/machinery/field_generator/gen_primary
	var/obj/machinery/field_generator/gen_secondary

//////////////Contaiment Field START

/obj/machinery/containment_field/New(var/obj/machinery/field_generator/A, var/obj/machinery/field_generator/B)
	..()
	src.gen_primary = A
	src.gen_secondary = B
	if(A&&B)
		src.dir = get_dir(B,A)
	spawn(1)
		src.sd_SetLuminosity(5)

/obj/machinery/containment_field/attack_hand(mob/user as mob)
	return 1

/obj/machinery/containment_field/blob_act()
	return

/obj/machinery/containment_field/ex_act(severity)
	return

/obj/machinery/containment_field/process()
	if(prob(50))
		gen_primary.power -= 1
	else
		gen_secondary.power -= 1


/obj/machinery/containment_field/proc/shock(mob/user as mob)
	if(isnull(gen_primary))
		del(src)
		return
	if(isnull(gen_secondary))
		del(src)
		return

	var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
	s.set_up(5, 1, user.loc)
	s.start()
	var/power = max(gen_primary.power,gen_secondary.power)
	var/prot = 1
	var/shock_damage = 0
	if(power > 200)
		shock_damage = min(rand(40,100),rand(40,100))*prot
	else if(power > 120)
		shock_damage = min(rand(30,90),rand(30,90))*prot
	else if(power > 80)
		shock_damage = min(rand(20,40),rand(20,40))*prot
	else if(power > 60)
		shock_damage = min(rand(20,30),rand(20,30))*prot
	else
		shock_damage = min(rand(10,20),rand(10,20))*prot

	user.burn_skin(shock_damage)
	//user.fireloss += shock_damage
	user.updatehealth()
	user.visible_message("\red [user.name] was shocked by the [src.name]!", \
		"\red <B>You feel a powerful shock course through your body sending you flying!</B>", \
		"\red You hear a heavy electrical crack")
	//user.unlock_medal("High Voltage", 1)

	if(user.stunned < shock_damage)	user.stunned = shock_damage
	if(user.weakened < 10*prot)	user.weakened = 10*prot
	var/atom/target = get_edge_target_turf(user, get_dir(src, get_step_away(user, src)))
	user.throw_at(target, 200, 4)
	src.gen_primary.power -= 3
	src.gen_secondary.power -= 3
	return


/obj/machinery/containment_field/HasProximity(atom/movable/AM as mob|obj)
	if(istype(AM,/mob/living/carbon) && prob(50))
		shock(AM)
		return

/////EMITTER
/obj/machinery/emitter
	name = "Emitter"
	desc = "Shoots a high power laser when active"
	icon = 'singularity.dmi'
	icon_state = "Emitter"
	anchored = 0
	density = 1
	req_access = list(access_engine)
	var/active = 0
//	var/power = 20
	var/fire_delay = 100
//	var/HP = 20
	var/last_shot = 0
	var/shot_number = 0
	var/state = 0
	var/locked = 0



/obj/machinery/emitter/New()
	..()
	return

/obj/machinery/emitter/update_icon()
	if (active && !(stat & (NOPOWER|BROKEN)))
		icon_state = "Emitter +a"
	else
		icon_state = "Emitter"

/obj/machinery/emitter/attack_hand(mob/user as mob)
	if(state == 3)
		if(!src.locked || istype(user, /mob/living/silicon))
			src.add_fingerprint(user)
			if(src.active==1)
				src.active = 0
				user << "You turn off the [src]."
			else
				src.active = 1
				user << "You turn on the [src]."
				src.shot_number = 0
				src.fire_delay = 100
			update_icon()
		else
			user << "The controls are locked!"
	else
		user << "The [src] needs to be firmly secured to the floor first."
		return 1

/obj/machinery/emitter/process()

	if(stat & (NOPOWER|BROKEN))
		return

	if(!src.state == 3 || !anchored)
		src.active = 0
		return

	if(((src.last_shot + src.fire_delay) <= world.time) && (src.active == 1))
		src.last_shot = world.time
		if(src.shot_number < 3)
			src.fire_delay = 2
			src.shot_number ++
		else
			src.fire_delay = rand(20,100)
			src.shot_number = 0

		use_power(1000)
		var/obj/beam/a_laser/A = new /obj/beam/a_laser( src.loc )
		A.icon_state = "u_laser"
		playsound(src.loc, 'emitter.ogg', 75, 1)

		if(prob(35))
			var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
			s.set_up(5, 1, src)
			s.start()

		if(src.dir == 1)//Up
			A.yo = 20
			A.xo = 0

		else if(src.dir == 2)//Down
			A.yo = -20
			A.xo = 0

		else if(src.dir == 4)//Right
			A.yo = 0
			A.xo = 20

		else if(src.dir == 8)//Left
			A.yo = 0
			A.xo = -20

		else // Any other
			A.yo = -20
			A.xo = 0

		A.process()
	..()



/obj/machinery/emitter/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench))
		if(active)
			user << "\red Turn off the [src] first."
			return 1

		else if(state == 0)
			state = 1
			playsound(src.loc, 'Ratchet.ogg', 75, 1)
			user.visible_message("[user.name] secures [src.name] to the floor.", \
				"You secure the external reinforcing bolts.", \
				"You hear ratchet")
			src.anchored = 1

		else if(state == 1)
			state = 0
			playsound(src.loc, 'Ratchet.ogg', 75, 1)
			user.visible_message("[user.name] unsecures [src.name] to the floor.", \
				"You undo the external reinforcing bolts.", \
				"You hear ratchet")
			src.anchored = 0
		else
			user << "\red [src] is welded to the floor!"
			return 1

	else if(istype(W, /obj/item/weapon/weldingtool) && W:welding)
		if (state == 0)
			user << "\red The [src] needs to be wrenched to the floor first."
			return 1

		if (W:get_fuel() < 2) //weldingtool always uses 1 additional unit of fuel
			user << "\blue You need more welding fuel to complete this task."
			return 1
		W:use_fuel(1)
		W:eyecheck(user)
		playsound(src.loc, 'Welder2.ogg', 50, 1)

		if(state == 1)
			user.visible_message("[user.name] starts to weld [src.name] to the floor.", \
				"You start to weld the [src] to the floor.", \
				"You hear welding")
			if (do_after(user,20))
				state = 3
				user << "You weld the [src] to the floor."
			else
				return 1

		else if(state == 3)
			user.visible_message("[user.name] starts to cut [src.name] from the floor.", \
				"You start to cut the [src] free from the floor.", \
				"You hear welding")
			if (do_after(user,20))
				state = 1
				user << "You cut the [src] free from the floor."
			else
				return 1

	else if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (src.allowed(user))
			src.locked = !src.locked
			user << "Controls are now [src.locked ? "locked." : "unlocked."]"
		else
			user << "\red Access denied."
			return 1
	else
		user.visible_message("\red The [src.name] has been hit with the [W.name] by [user.name]!", \
			"\red You hit the [src.name] with your [W.name]!", \
			"You hear bang")
	src.add_fingerprint(user)


/obj/machinery/emitter/power_change()
	..()
	update_icon()
//////////////ARRAY


/obj/machinery/power/collector_array
	name = "Radiation Collector Array"
	desc = "A device which uses Hawking Radiation and plasma to produce power."
	icon = 'singularity.dmi'
	icon_state = "ca"
	anchored = 1
	density = 1
	req_access = list(access_engine)
	directwired = 1
	var/active = 0
	var/obj/item/weapon/tank/plasma/P = null
	var/obj/machinery/power/collector_control/CU = null


/////////////ARRAY START

/obj/machinery/power/collector_array/New()
	..()
	spawn(5)
		updateicon()


/obj/machinery/power/collector_array/proc/updateicon()
	overlays = null
	if(P)
		overlays += image('singularity.dmi', "ptank")
	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		overlays += image('singularity.dmi', "on")

/obj/machinery/power/collector_array/proc/updateicon_on()
	icon_state = "ca_on"
	flick("ca_active", src)
	updateicon()

/obj/machinery/power/collector_array/proc/updateicon_off()
	updateicon()
	icon_state = "ca"
	flick("ca_deactive", src)

/obj/machinery/power/collector_array/proc/eject()
	var/obj/item/weapon/tank/plasma/Z = src.P
	if (!Z)
		return
	Z.loc = get_turf(src)
	Z.layer = initial(Z.layer)
	src.P = null
	if (src.active)
		src.active = 0
		updateicon_off()
	else
		updateicon()
	if (CU)
		CU.updatecons()

/obj/machinery/power/collector_array/power_change()
	..()
	updateicon()

/obj/machinery/power/collector_array/process()
	if(src.active == 1)
		if(P)
			if(P.air_contents.toxins <= 0)
				P.air_contents.toxins = 0
				src.active = 0
				updateicon_off()
		else
			src.active = 0
			updateicon_off()
	//use_power called from collector_array/process

/obj/machinery/power/collector_array/attack_hand(mob/user as mob)
	if (..())
		return
	if(src.anchored != 1)
		user << "\red The [src] needs to be secured to the floor first."
		return 1
	if (!src.allowed(user))
		user << "\red Access denied."
		return 1
	if (!P)
		user << "\red The [src] cannot be turned on without plasma."
		return 1
	if (!CU)
		user << "\red The [src] is not connected with The Radiation Collector Control."
		return 1
	src.active = !src.active
	if(src.active)
		updateicon_on()
		user.visible_message("[user.name] turns on the collector array.", \
			"You turn on the collector array.")
	else
		updateicon_off()
		user.visible_message("[user.name] turns off the collector array.", \
			"You turn off the collector array.")
	CU.updatecons()

/obj/machinery/power/collector_array/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/tank/plasma))
		if(src.anchored == 1)
			if(src.P)
				user << "\red There appears to already be a plasma tank loaded!"
				return 1
			src.P = W
			W.loc = src
			if (user.client)
				user.client.screen -= W
			user.u_equip(W)
			updateicon()
			if (CU)
				CU.updatecons()
		else
			user << "The collector needs to be secured to the floor first."
			return 1

	else if(istype(W, /obj/item/weapon/crowbar))
		if(!P)
			return 1
		eject()

	else if(istype(W, /obj/item/weapon/wrench))
		if(active)
			user << "\red Turn off the collector first."
			return 1

		else
			playsound(src.loc, 'Ratchet.ogg', 75, 1)
			src.anchored = !src.anchored
			if(src.anchored == 1)
				user.visible_message("[user.name] secures [src.name] reinforcing bolts to the floor.", \
					"You secure the collector reinforcing bolts.", \
					"You hear ratchet")
			else
				user.visible_message("[user.name] unsecures [src.name] reinforcing bolts from the floor.", \
					"You undo the external reinforcing bolts.", \
					"You hear ratchet")
			for(var/obj/machinery/power/collector_control/myCC in orange(1,src))
				myCC.updatecons()

	else
		user.visible_message("\red The [src.name] has been hit with the [W.name] by [user.name]!", \
			"\red You hit the [src.name] with your [W.name]!", \
			"You hear bang")
	src.add_fingerprint(user)

/obj/machinery/power/collector_array/ex_act(severity)
	switch(severity)
		if(2.0 to 3.0)
			eject()
	return ..()

/obj/machinery/power/collector_array/Del()
	. = ..()
	for(var/obj/machinery/power/collector_control/myCC in orange(1,src))
		myCC.updatecons()

////////////CONTROL UNIT

/obj/machinery/power/collector_control
	name = "Radiation Collector Control"
	desc = "A device which uses Hawking Radiation and Plasma to produce power."
	icon = 'singularity.dmi'
	icon_state = "cu"
	anchored = 1
	density = 1
	req_access = list(access_engine)
	directwired = 1
	var/active = 0
	var/lastpower = 0
	var/obj/machinery/power/collector_array/CA[4]
	var/list/obj/machinery/the_singularity/S

////////////CONTROL UNIT START

/obj/machinery/power/collector_control/New()
	..()
	spawn(10)
		while(1)
			updatecons()
			sleep(600)

/obj/machinery/power/collector_control/proc/add_ca(var/obj/machinery/power/collector_array/newCA)
	if (newCA in CA)
		return 1
	for (var/i = 1, i<= CA.len, i++)
		var/obj/machinery/power/collector_array/nextCA = CA[i]
		if (isnull(nextCA))
			CA[i] = newCA
			return 1
	//CA += newCA
	return 0

/obj/machinery/power/collector_control/proc/updatecons()
	S = list()
	for(var/obj/machinery/the_singularity/myS in orange(collector_control_range,src))
		S += myS

	for (var/ca_dir in list( WEST, EAST, NORTH, SOUTH ) /* cardinal*/ )
		var/obj/machinery/power/collector_array/newCA = locate() in get_step(src,ca_dir)
		if (isnull(newCA))
			continue
		if (!isnull(newCA.CU) && newCA.CU != src)
			var/n = CA.Find(newCA)
			if (n)
				CA[n] = null
			continue
		if (!newCA.anchored || (!isnull(newCA.CU) && newCA.CU != src))
			var/n = CA.Find(newCA)
			if (n)
				CA[n] = null
				newCA.CU = null
			continue
		if (add_ca(newCA))
			newCA.CU = src
	updateicon()
	//is not recursive now, because can be called several times. See New(). - rastaf0

/obj/machinery/power/collector_control/proc/updateicon()
	overlays = null
	if(stat & (NOPOWER|BROKEN))
		return
	if(src.active == 0)
		return
	overlays += image('singularity.dmi', "cu on")
	var/err = 0
	for (var/i = 1, i <= CA.len, i++)
		var/obj/machinery/power/collector_array/myCA = CA[i]
		if(myCA)
			if (myCA.P)
				if(myCA.active)
					overlays += image('singularity.dmi', "cu [i] on")
				if (myCA.P.air_contents.toxins <= 0)
					err = 1
			else
				err = 1
	if(err)
		overlays += image('singularity.dmi', "cu n error")
	for (var/obj/machinery/the_singularity/myS in S)
		if(myS)
			overlays += image('singularity.dmi', "cu sing")
			break
	for (var/obj/machinery/the_singularity/myS in S)
		if(myS && myS.active)
			overlays += image('singularity.dmi', "cu conterr")
			break


/obj/machinery/power/collector_control/power_change()
	..() //this set NOPOWER
	if (stat & (NOPOWER|BROKEN))
		lastpower = 0
	updateicon() //this checks NOPOWER


/obj/machinery/power/collector_control/process()
	if(stat & (NOPOWER|BROKEN))
		return
	if(!active)
		return
	var/power_a = 0
	var/power_s = 0
	var/power_p = 0

	for (var/obj/machinery/the_singularity/myS in S)
		if(!isnull(myS))
			power_s += myS.energy

	for (var/i = 1, i<= CA.len, i++)
		var/obj/machinery/power/collector_array/myCA = CA[i]
		if (!myCA)
			continue
		var/obj/item/weapon/tank/plasma/myP = myCA.P
		if (myCA.active && myP)
			myCA.use_power(250)
			power_p += myP.air_contents.toxins
			myP.air_contents.toxins -= 0.001

	power_a = power_p*power_s*50
	src.lastpower = power_a
	add_avail(power_a)
	use_power(250)


/obj/machinery/power/collector_control/attack_hand(mob/user as mob)
	if (..())
		return
	if(src.anchored==1)
		if (!src.allowed(user))
			user << "\red Access denied."
			return 1
		src.active = !src.active
		if(!src.active)
			user << "You turn off the [src]."
			src.lastpower = 0
			updateicon()
		if(src.active)
			user << "You turn on the [src]."
			updatecons()
	else
		user << "\red The [src] needs to be secured to the floor first."
		return 1

/obj/machinery/power/collector_control/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/device/analyzer))
		user << "\blue The analyzer detects that [lastpower]W are being produced."
	else if(istype(W, /obj/item/weapon/wrench))
		if(active)
			user << "\red Turn off the collector control first."
			return 1

		playsound(src.loc, 'Ratchet.ogg', 75, 1)
		src.anchored = !src.anchored
		if(src.anchored == 1)
			user.visible_message("[user.name] secures [src.name] to the floor.", \
				"You secure the [src.name] to the floor.", \
				"You hear ratchet")
			connect_to_network()
		else
			user.visible_message("[user.name] unsecures [src.name] to the floor.", \
				"You undo the [src] securing bolts.", \
				"You hear ratchet")
			disconnect_from_network()
	else
		user.visible_message("\red The [src.name] has been hit with the [W.name] by [user.name]!", \
			"\red You hit the [src.name] with your [W.name]!", \
			"You hear bang")
	src.add_fingerprint(user)

/////FIELD GEN
#define field_generator_max_power 250
/obj/machinery/field_generator
	name = "Field Generator"
	desc = "Projects an energy field when active"
	icon = 'singularity.dmi'
	icon_state = "Field_Gen"
	anchored = 0
	density = 1
	req_access = list(access_engine)
	var/Varedit_start = 0
	var/Varpower = 0
	var/active = 0
	var/power = 20
	var/state = 0
	//var/steps = 0
	//var/last_check = 0
	//var/check_delay = 10
	//var/recalc = 0
	var/locked = 0
	var/warming_up = 0
	var/powerlevel = 0
	var/list/obj/machinery/containment_field/fields
////FIELD GEN START

/obj/machinery/field_generator/update_icon()
	if (!active)
		icon_state = "Field_Gen"
		return
	var/level = 3
	switch (power)
		if(0 to 60)
			level = 1
		if(61 to 220)
			level = 2
		if(221 to INFINITY)
			level = 3
	level = min(level,warming_up)
	if (powerlevel!=level)
		powerlevel = level
		icon_state = "Field_Gen +a[powerlevel]"

/obj/machinery/field_generator/proc/turn_off()
	src.active = 0
	spawn(1)
		src.cleanup()
	update_icon()

/obj/machinery/field_generator/proc/turn_on()
	src.active = 1
	warming_up = 1
	powerlevel = 0
	spawn(1)
		while (warming_up<3 && active)
			sleep(50)
			warming_up++
			update_icon()
	update_icon()

/obj/machinery/field_generator/attack_hand(mob/user as mob)
	if(state == 3)
		if(!src.locked || istype(user, /mob/living/silicon))
			if(src.active >= 1)
	//			src.active = 0
	//			icon_state = "Field_Gen"
				user << "You are unable to turn off the [src], wait till it powers down."
	//			src.cleanup()
				return 1
			else
				user.visible_message("[user.name] turns on [src.name]", \
					"You turn on the [src].", \
					"You hear heavy droning")
				turn_on()
				src.add_fingerprint(user)
		else
			user << "The controls are locked!"
	else
		user << "The [src] needs to be firmly secured to the floor first."

/obj/machinery/field_generator/New()
	..()
	fields = list()
	return

/obj/machinery/field_generator/process()

	if(src.Varedit_start == 1)
		if(src.active == 0)
			src.active = 1
			src.state = 3
			src.power = field_generator_max_power
			src.anchored = 1
			src.warming_up = 1
		Varedit_start = 0

	if(src.active == 1)
		if(!src.state == 3 || !anchored)
			turn_off()
			return
		spawn(1)
			setup_field(1)
		spawn(2)
			setup_field(2)
		spawn(3)
			setup_field(4)
		spawn(4)
			setup_field(8)
		src.active = 2
	if(src.power < 0)
		src.power = 0
	if(src.power > field_generator_max_power)
		src.power = field_generator_max_power
	if(src.active >= 1)
		src.power -= 1
		if(Varpower == 0)
			if(src.power <= 0)
				for(var/mob/M in viewers(src))
					M.show_message("\red The [src.name] shuts down due to lack of power!")
				turn_off()
				return
		update_icon()

/obj/machinery/field_generator/proc/setup_field(var/NSEW)
	var/turf/T = src.loc
	var/obj/machinery/field_generator/G
	var/steps = 0

	if(!NSEW)//Make sure its ran right
		return

	for(var/dist = 0, dist <= 9, dist += 1) // checks out to 8 tiles away for another generator
		T = get_step(T, NSEW)
		steps += 1
		G = locate(/obj/machinery/field_generator) in T
		if(!isnull(G))
			steps -= 1
			if(!G.active)
				return
			break

	if(isnull(G))
		return

	T = src.loc

	for(var/dist = 0, dist < steps, dist += 1) // creates each field tile
		var/field_dir = get_dir(T,get_step(G.loc, NSEW))
		T = get_step(T, NSEW)
		var/obj/machinery/containment_field/CF = new/obj/machinery/containment_field/(src, G) //(ref to this gen, ref to connected gen)
		fields += CF
		G.fields += CF
		CF.loc = T
		CF.dir = field_dir


/obj/machinery/field_generator/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench) && state!=3)
		if(active)
			user << "Turn off the [src] first."
			return 1

		if(state == 0)
			state = 1
			playsound(src.loc, 'Ratchet.ogg', 75, 1)
			user.visible_message("[user.name] secures [src.name] to the floor.", \
				"You secure the external reinforcing bolts to the floor.", \
				"You hear ratchet")
			src.anchored = 1

		else if(state == 1)
			state = 0
			playsound(src.loc, 'Ratchet.ogg', 75, 1)
			user.visible_message("[user.name] unsecures [src.name] reinforcing bolts from the floor.", \
				"You undo the external reinforcing bolts.", \
				"You hear ratchet")
			src.anchored = 0

	else if(istype(W, /obj/item/weapon/weldingtool) && W:welding)
		if(state == 0)
			user << "\red The [src.name] needs to be wrenched to the floor first."
			return 1
		if (W:get_fuel() < 2)
			user << "\blue You need more welding fuel to complete this task."
			return 1
		W:use_fuel(1)
		W:eyecheck(user)
		playsound(src.loc, 'Welder2.ogg', 50, 1)

		if(state == 1)
			user.visible_message("[user.name] starts to weld [src.name] to the floor.", \
				"You start to weld the [src] to the floor.", \
				"You hear welding")
			if (do_after(user,20))
				state = 3
				user << "You weld the field generator to the floor."
			else
				return 1

		else if(state == 3)
			user.visible_message("[user.name] starts to cut [src.name] free from the floor.", \
				"You start to cut the [src] free from the floor.", \
				"You hear welding")
			if (do_after(user,20))
				state = 1
				user << "You cut the [src] free from the floor."
			else
				return 1

	else if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (src.allowed(user))
			src.locked = !src.locked
			user << "Controls are now [src.locked ? "locked." : "unlocked."]"
		else
			user << "\red Access denied."
			return 1

	else
		user.visible_message("\red The [src.name] has been hit with the [W.name] by [user.name]!", \
			"\red You hit the [src.name] with your [W.name]!", \
			"You hear bang")
	src.add_fingerprint(user)


/obj/machinery/field_generator/bullet_act(flag)

	if (flag == PROJECTILE_BULLET)
		src.power -= 10
	/*else if (flag == PROJECTILE_MEDBULLET)
		src.power -= 5*/
	else if (flag == PROJECTILE_WEAKBULLET)
		src.power -= 1
	else if (flag == PROJECTILE_LASER)
		src.power += 20
	else if (flag == PROJECTILE_TASER)
		src.power += 3
	else
		src.power -= 2
	update_icon()
	return

/obj/machinery/field_generator/proc/cleanup()
	var/obj/machinery/field_generator/G
	for (var/obj/machinery/containment_field/F in fields)
		if (isnull(F))
			continue
		G = (F.gen_primary == src) ? F.gen_secondary : F.gen_primary
		if (G)
			G.fields -= F
		del(F)
	fields = list()

/obj/machinery/field_generator/Del()
	src.cleanup()
	..()

