/*////////////////////////////////////////////////
The Singularity Engine
By Mport
tbh this could likely be better and I did not use all that many comments on it.
However people seem to like it for some reason.
*/////////////////////////////////////////////////

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
	var/checkpointC = 0
	for (var/obj/X in orange(3,src))
		if(istype(X, /obj/machinery/containment_field) || istype(X, /obj/machinery/shieldwall))
			checkpointC ++
	if(checkpointC >= 20)
		var/turf/T = src.loc
		new /obj/machinery/the_singularity/(T, 100)
		del(src)

/obj/machinery/the_singularitygen/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench))
		if(!anchored)
			anchored = 1
			playsound(src.loc, 'Ratchet.ogg', 75, 1)
			user << "You secure the [src.name] to the floor."
			src.anchored = 1
			return
		else if(anchored)
			anchored = 0
			playsound(src.loc, 'Ratchet.ogg', 75, 1)
			user << "You unsecure the [src.name]."
			src.anchored = 0
			return


/////SINGULARITY
/obj/machinery/the_singularity/
	name = "Gravitational Singularity"
	desc = "A Gravitational Singularity."
	icon = '160x160.dmi'
	icon_state = "Singularity"
	anchored = 1
	density = 1
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

	if(prob(15))//Chance for it to run a special event
		event()
	if(active == 1)
		move()
		spawn(5)
			move()
	else
		var/checkpointC = 0
		for (var/obj/X in orange(3,src))
			if(istype(X, /obj/machinery/containment_field) || istype(X, /obj/machinery/shieldwall))
				checkpointC ++
		if(checkpointC < 18)
			src.active = 1
			src.dieot = 1
			grav_pull = 8


/obj/machinery/the_singularity/proc/eat()
	for (var/atom/X in orange(grav_pull,src))
		if(istype(X,/obj/machinery/the_singularity))
			continue
		if(istype(X,/obj/machinery/containment_field))
			continue
		if(istype(X,/obj/machinery/field_generator))
			var/obj/machinery/field_generator/F = X
			if(F.active)
				continue
		if(istype(X,/turf/space))
			continue
		if(istype(X,/obj/machinery/shieldwall))
			continue
		if(istype(X,/obj/machinery/shieldwallgen))
			var/obj/machinery/shieldwallgen/S = X
			if(S.active)
				continue
		if(!active)
			if(isturf(X,/turf/simulated/floor/engine))
				continue
		if(!isarea(X))
			switch(get_dist(src,X))
				if(2)
					src.Bumped(X)
				if(1)
					src.Bumped(X)
				if(0)
					src.Bumped(X)
				else if(!isturf(X))
					if(!X:anchored)
						step_towards(X,src)

/obj/machinery/the_singularity/proc/move()
	var/direction_go = pick(1,2,4,8)
	if(locate(/obj/machinery/containment_field) || locate(/obj/machinery/shieldwall) in get_step(src,NORTH))
		if(direction_go == 1)
			icon_state = "Singularity"
			return
	if(locate(/obj/machinery/containment_field) || locate(/obj/machinery/shieldwall) in get_step(src,SOUTH))
		if(direction_go == 2)
			icon_state = "Singularity"
			return
	if(locate(/obj/machinery/containment_field) || locate(/obj/machinery/shieldwall) in get_step(src,EAST))
		if(direction_go == 4)
			icon_state = "Singularity"
			return
	if(locate(/obj/machinery/containment_field) || locate(/obj/machinery/shieldwall) in get_step(src,WEST))
		if(direction_go == 8)
			icon_state = "Singularity"
			return
	if(selfmove)
		spawn(0)
			icon_state = "Singularity2"
			step(src, direction_go)


/obj/machinery/the_singularity/Bumped(atom/A)
	var/gain = 0

	if(istype(A,/obj/machinery/the_singularity))
		return

	if(istype(A,/obj/machinery/the_singularity))//Dont eat other sings
		return
	if (istype(A,/mob/living))//if its a mob
		gain = 20
		if(istype(A,/mob/living/carbon/human))
			if(A:mind)
				if((A:mind:assigned_role == "Station Engineer") || (A:mind:assigned_role == "Cief Engineer") )
					gain = 100
		A:gib()

	else if(istype(A,/obj/))
		if(istype(A,/obj/machinery/containment_field))
			return
		if(istype(A,/obj/machinery/shieldwall))
			return
		A:ex_act(1.0)
		if(A) del(A)
		gain = 2

	else if(isturf(A))
		if(isturf(/turf/space))
			return
		if(!active)
			if(isturf(A,/turf/simulated/floor/engine))
				return

		if(!istype(A,/turf/simulated/floor)&& (!isturf(/turf/space)))
			A:ReplaceWithFloor()
		if(istype(A,/turf/simulated/floor) && (!isturf(/turf/space)))
			A:ReplaceWithSpace()
			gain = 2
	src.energy += gain

/////////////////////////////////////////////Controls which "event" is called
/obj/machinery/the_singularity/proc/event()
	var/numb = pick(1,2,3,4,5,6)
	switch(numb)
		if(1)//EMP
			Zzzzap()
			return
		if(2)//Eats the turfs around it
			if(prob(60))
				BHolerip()
			else
				event()
			return
		if(3)//tox damage all carbon mobs in area
			Toxmob()
			return
		if(4)//Stun mobs who lack optic scanners
			Mezzer()
			return
		else
			return


/obj/machinery/the_singularity/proc/Toxmob()
	for(var/mob/living/carbon/M in orange(7, src))
		if(istype(M,/mob/living/carbon/human))
			if(M:wear_suit)
				return
		M.toxloss += 3
		M.radiation += 10
		M.updatehealth()
		M << "\red You feel odd."

/obj/machinery/the_singularity/proc/Mezzer()
	for(var/mob/living/carbon/M in oviewers(8, src))
		if(istype(M,/mob/living/carbon/human))
			if(istype(M:glasses,/obj/item/clothing/glasses/meson))
				M << "\red You look directly into The [src.name], good thing you had your protective eyewear on!"
				return
		M << "\red You look directly into The [src.name] and feel weak."
		if (M:stunned < 3)
			M.stunned = 3
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red <B>[] stares blankly at The []!</B>", M, src), 1)

/obj/machinery/the_singularity/proc/BHolerip()
	for (var/atom/X in orange(6,src))
		if(isturf(X))
			if(!istype(X,/turf/space))
				switch(get_dist(src,X))
					if(4 to 5)
						if(prob(30))
							if(istype(X,/turf/simulated/floor) && !istype(X,/turf/simulated/floor/plating))
								if(!X:broken)
									if(prob(80))
										new/obj/item/weapon/tile (X)
										X:break_tile_to_plating()
									else
										X:break_tile()
							else if(istype(X,/turf/simulated/wall))
								new /obj/structure/girder/reinforced( X )
								new /obj/item/weapon/sheet/r_metal( X )
								X:ReplaceWithFloor()
							else
								X:ReplaceWithFloor()
	return

/obj/machinery/the_singularity/proc/Zzzzap()///Pulled from wizard spells might edit later
	var/turf/myturf = get_turf(src)

	var/obj/overlay/pulse = new/obj/overlay ( myturf )
	pulse.icon = 'effects.dmi'
	pulse.icon_state = "emppulse"
	pulse.name = "emp pulse"
	pulse.anchored = 1
	spawn(20)
		del(pulse)

	for(var/mob/M in viewers(world.view-1, myturf))

		if(!istype(M, /mob/living)) continue
		if(M == usr) continue

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
				A:cell:charge -= 1000
				if (A:cell:charge < 0)
					A:cell:charge = 0
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
	var/active = 1
	var/power = 10
	var/delay = 5
	var/last_active
	var/mob/U
	var/obj/machinery/field_generator/gen_primary
	var/obj/machinery/field_generator/gen_secondary



//////////////Contaiment Field START


/obj/machinery/containment_field/New(var/obj/machinery/field_generator/A, var/obj/machinery/field_generator/B)
	..()
	src.gen_primary = A
	src.gen_secondary = B
	spawn(1)
		src.sd_SetLuminosity(5)

/obj/machinery/containment_field/attack_hand(mob/user as mob)
	return


/obj/machinery/containment_field/process()
	if(isnull(gen_primary)||isnull(gen_secondary))
		del(src)
		return

	if(!(gen_primary.active)||!(gen_secondary.active))
		del(src)
		return

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
	src.power = max(gen_primary.power,gen_secondary.power)
	var/prot = 1
	var/shock_damage = 0
	if(src.power > 200)
		shock_damage = min(rand(40,100),rand(40,100))*prot
	else if(src.power > 120)
		shock_damage = min(rand(30,90),rand(30,90))*prot
	else if(src.power > 80)
		shock_damage = min(rand(20,40),rand(20,40))*prot
	else if(src.power > 60)
		shock_damage = min(rand(20,30),rand(20,30))*prot
	else
		shock_damage = min(rand(10,20),rand(10,20))*prot

	user.burn_skin(shock_damage)
	user.fireloss += shock_damage
	user.updatehealth()
	user << "\red <B>You feel a powerful shock course through your body sending you flying!</B>"
	//user.unlock_medal("High Voltage", 1)

	if(user.stunned < shock_damage)	user.stunned = shock_damage
	if(user.weakened < 10*prot)	user.weakened = 10*prot
	var/atom/target = get_edge_target_turf(user, get_dir(src, get_step_away(user, src)))
	user.throw_at(target, 200, 4)
	for(var/mob/M in viewers(src))
		if(M == user)	continue
		M.show_message("\red [user.name] was shocked by the [src.name]!", 3, "\red You hear a heavy electrical crack", 2)
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
	var/power = 20
	var/fire_delay = 100
	var/HP = 20
	var/last_shot = 0
	var/shot_number = 0
	var/state = 0
	var/locked = 0



/obj/machinery/emitter/New()
	..()
	return

/obj/machinery/emitter/attack_hand(mob/user as mob)
	if(state == 3)
		if(!src.locked)
			if(src.active==1)
				src.active = 0
				icon_state = "Emitter"
				user << "You turn off the emitter."
			else
				src.active = 1
				icon_state = "Emitter +a"
				user << "You turn on the emitter."
				src.shot_number = 0
				src.fire_delay = 100
		else
			user << "The controls are locked!"
	else
		user << "The emitter needs to be firmly secured to the floor first."
	src.add_fingerprint(user)
	..()


/obj/machinery/emitter/attack_ai(mob/user as mob)
	if(state == 3)
		if(src.active==1)
			src.active = 0
			icon_state = "Emitter"
			user << "You turn off the emitter."
		else
			src.active = 1
			icon_state = "Emitter +a"
			user << "You turn on the emitter."
			src.shot_number = 0
			src.fire_delay = 100
	else
		user << "The emitter needs to be firmly secured to the floor first."
	src.add_fingerprint(user)


/obj/machinery/emitter/process()

	if(stat & (NOPOWER|BROKEN))
		return

	if(!src.state == 3)
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

		var/obj/beam/a_laser/A = new /obj/beam/a_laser( src.loc )
		A.icon_state = "u_laser"
		playsound(src.loc, 'Laser.ogg', 75, 1)

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
			user << "Turn off the emitter first."
			return

		else if(state == 0)
			state = 1
			playsound(src.loc, 'Ratchet.ogg', 75, 1)
			user << "You secure the external reinforcing bolts to the floor."
			src.anchored = 1
			return

		else if(state == 1)
			state = 0
			playsound(src.loc, 'Ratchet.ogg', 75, 1)
			user << "You undo the external reinforcing bolts."
			src.anchored = 0
			return

	if(istype(W, /obj/item/weapon/weldingtool) && W:welding)

		var/turf/T = user.loc

		if (W:get_fuel() < 1)
			user << "\blue You need more welding fuel to complete this task."
			return
		W:use_fuel(1)

		if(state == 1)
			W:eyecheck(user)
			user << "You start to weld the emitter to the floor."
			playsound(src.loc, 'Welder2.ogg', 50, 1)
			sleep(20)

			if ((user.loc == T && user.equipped() == W))
				state = 3

				user << "You weld the emitter to the floor."
			else if((istype(user, /mob/living/silicon/robot) && (user.loc == T)))
				state = 3
				user << "You weld the emitter to the floor."
			return

		if(state == 3)
			user << "You start to cut the emitter free from the floor."
			playsound(src.loc, 'Welder2.ogg', 50, 1)
			sleep(20)
			if ((user.loc == T && user.equipped() == W))
				state = 1
/*				if(src.link) //Time to clear our link.
					src.link.master = null
					src.link = null*/
				user << "You cut the emitter free from the floor."
			else if((istype(user, /mob/living/silicon/robot) && (user.loc == T)))
				state = 1
/*				if(src.link)
					src.link.master = null
					src.link = null*/
				user << "You cut the emitter free from the floor."
			return

	if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (src.allowed(user))
			src.locked = !src.locked
			user << "Controls are now [src.locked ? "locked." : "unlocked."]"
		else
			user << "\red Access denied."

	else
		src.add_fingerprint(user)
		user << "\red You hit the [src.name] with your [W.name]!"
		for(var/mob/M in viewers(src))
			if(M == user)	continue
			M.show_message("\red The [src.name] has been hit with the [W.name] by [user.name]!")




//////////////ARRAY


/obj/machinery/power/collector_array
	name = "Radiation Collector Array"
	desc = "A device which uses Hawking Radiation and plasma to produce power."
	icon = 'singularity.dmi'
	icon_state = "ca"
	anchored = 1
	density = 1
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

	if(stat & (NOPOWER|BROKEN))
		overlays = null
	if(P)
		overlays += image('singularity.dmi', "ptank")
	else
		overlays = null
	overlays += image('singularity.dmi', "on")
	if(P)
		overlays += image('singularity.dmi', "ptank")

/obj/machinery/power/collector_array/power_change()
	updateicon()
	..()


/obj/machinery/power/collector_array/process()

	if(P)
		if(P.air_contents.toxins <= 0)
			src.active = 0
			icon_state = "ca_deactive"
			updateicon()
	else if(src.active == 1)
		src.active = 0
		icon_state = "ca_deactive"
		updateicon()
	..()

/obj/machinery/power/collector_array/attack_hand(mob/user as mob)
	if(src.anchored == 1)
		if(src.active==1)
			src.active = 0
			icon_state = "ca_deactive"
			CU.updatecons()
			user << "You turn off the collector array."
			return

		if(src.active==0)
			src.active = 1
			icon_state = "ca_active"
			CU.updatecons()
			user << "You turn on the collector array."
			return
	else
		src.add_fingerprint(user)
		user << "\red The collector needs to be secured to the floor first."
		return

/obj/machinery/power/collector_array/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/tank/plasma))
		if(src.anchored == 1)
			if(src.P)
				user << "\red There appears to already be a plasma tank loaded!"
				return
			src.P = W
			W.loc = src
			if (user.client)
				user.client.screen -= W
			user.u_equip(W)
			CU.updatecons()
			updateicon()
			return
		else
			user << "The collector needs to be secured to the floor first."
			return

	if(istype(W, /obj/item/weapon/crowbar))
		if(!P)
			return
		var/obj/item/weapon/tank/plasma/Z = src.P
		Z.loc = get_turf(src)
		Z.layer = initial(Z.layer)
		src.P = null
		CU.updatecons()
		updateicon()
		return

	if(istype(W, /obj/item/weapon/wrench))
		if(active)
			user << "\red Turn off the collector first."
			return

		else if(src.anchored == 0)
			playsound(src.loc, 'Ratchet.ogg', 75, 1)
			user << "You secure the collector reinforcing bolts to the floor."
			src.anchored = 1
			return

		else if(src.anchored == 1)
			playsound(src.loc, 'Ratchet.ogg', 75, 1)
			user << "You undo the external reinforcing bolts."
			src.anchored = 0
			return

	else
		src.add_fingerprint(user)
		user << "\red You hit the [src.name] with your [W.name]!"
		for(var/mob/M in viewers(src))
			if(M == user)	continue
			M.show_message("\red The [src.name] has been hit with the [W.name] by [user.name]!")


////////////CONTROL UNIT

/obj/machinery/power/collector_control
	name = "Radiation Collector Control"
	desc = "A device which uses Hawking Radiation and Plasma to produce power."
	icon = 'singularity.dmi'
	icon_state = "cu"
	anchored = 1
	density = 1
	directwired = 1
	var/active = 0
	var/lastpower = 0
	var/obj/item/weapon/tank/plasma/P1 = null
	var/obj/item/weapon/tank/plasma/P2 = null
	var/obj/item/weapon/tank/plasma/P3 = null
	var/obj/item/weapon/tank/plasma/P4 = null
	var/obj/machinery/power/collector_array/CA1 = null
	var/obj/machinery/power/collector_array/CA2 = null
	var/obj/machinery/power/collector_array/CA3 = null
	var/obj/machinery/power/collector_array/CA4 = null
	var/obj/machinery/power/collector_array/CAN = null
	var/obj/machinery/power/collector_array/CAS = null
	var/obj/machinery/power/collector_array/CAE = null
	var/obj/machinery/power/collector_array/CAW = null
	var/obj/machinery/the_singularity/S1 = null

////////////CONTROL UNIT START

/obj/machinery/power/collector_control/New()
	..()
	spawn(10)
		updatecons()

/obj/machinery/power/collector_control/proc/updatecons()

	CAN = locate(/obj/machinery/power/collector_array) in get_step(src,NORTH)
	CAS = locate(/obj/machinery/power/collector_array) in get_step(src,SOUTH)
	CAE = locate(/obj/machinery/power/collector_array) in get_step(src,EAST)
	CAW = locate(/obj/machinery/power/collector_array) in get_step(src,WEST)
	for(var/obj/machinery/the_singularity/S in orange(12,src))
		S1 = S

	if(!isnull(CAN))
		CA1 = CAN
		CAN.CU = src
		if(CA1.P)
			P1 = CA1.P
	else
		CAN = null
	if(!isnull(CAS))
		CA3 = CAS
		CAS.CU = src
		if(CA3.P)
			P3 = CA3.P
	else
		CAS = null
	if(!isnull(CAW))
		CA4 = CAW
		CAW.CU = src
		if(CA4.P)
			P4 = CA4.P
	else
		CAW = null
	if(!isnull(CAE))
		CA2 = CAE
		CAE.CU = src
		if(CA2.P)
			P2 = CA2.P
	else
		CAE = null
	if(isnull(S1))
		S1 = null

	updateicon()
	spawn(600)
		updatecons()


/obj/machinery/power/collector_control/proc/updateicon()

	if(stat & (NOPOWER|BROKEN))
		overlays = null
	else
		overlays = null
	if(src.active == 0)
		return
	overlays += image('singularity.dmi', "cu on")
	if((P1)&&(CA1.active != 0))
		overlays += image('singularity.dmi', "cu 1 on")
	if((P2)&&(CA2.active != 0))
		overlays += image('singularity.dmi', "cu 2 on")
	if((P3)&&(CA3.active != 0))
		overlays += image('singularity.dmi', "cu 3 on")
	if((!P1)||(!P2)||(!P3))
		overlays += image('singularity.dmi', "cu n error")
	if(S1)
		overlays += image('singularity.dmi', "cu sing")
		if(!S1.active)
			overlays += image('singularity.dmi', "cu conterr")


/obj/machinery/power/collector_control/power_change()
	updateicon()
	..()


/obj/machinery/power/collector_control/process()
	if(src.active == 1)
		var/power_a = 0
		var/power_s = 0
		var/power_p = 0

		if(!isnull(S1))
			power_s += S1.energy
		if(!isnull(P1))
			if(CA1.active != 0)
				power_p += P1.air_contents.toxins
				P1.air_contents.toxins -= 0.001
		if(!isnull(P2))
			if(CA2.active != 0)
				power_p += P2.air_contents.toxins
				P2.air_contents.toxins -= 0.001
		if(!isnull(P3))
			if(CA3.active != 0)
				power_p += P3.air_contents.toxins
				P3.air_contents.toxins -= 0.001
		if(!isnull(P4))
			if(CA4.active != 0)
				power_p += P4.air_contents.toxins
				P4.air_contents.toxins -= 0.001
		power_a = power_p*power_s*50
		src.lastpower = power_a
		add_avail(power_a)
	..()


/obj/machinery/power/collector_control/attack_hand(mob/user as mob)
	if(src.anchored==1)
		if(src.active==1)
			src.active = 0
			user << "You turn off the collector control."
			src.lastpower = 0
			updateicon()
			return

		if(src.active==0)
			src.active = 1
			user << "You turn on the collector control."
			updatecons()
			return
	else
		src.add_fingerprint(user)
		user << "\red The collector control needs to be secured to the floor first."
		return


/obj/machinery/power/collector_control/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/device/analyzer))
		user << "\blue The analyzer detects that [lastpower]W are being produced."

	if(istype(W, /obj/item/weapon/wrench))
		if(active)
			user << "\red Turn off the collector control first."
			return

		else if(src.anchored == 0)
			playsound(src.loc, 'Ratchet.ogg', 75, 1)
			user << "You secure the collector control to the floor."
			src.anchored = 1
			return

		else if(src.anchored == 1)
			playsound(src.loc, 'Ratchet.ogg', 75, 1)
			user << "You undo the collector control securing bolts."
			src.anchored = 0
			return

	else
		src.add_fingerprint(user)
		user << "\red You hit the [src.name] with your [W.name]!"
		for(var/mob/M in viewers(src))
			if(M == user)	continue
			M.show_message("\red The [src.name] has been hit with the [W.name] by [user.name]!")





/////FIELD GEN

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
	var/max_power = 250
	var/state = 0
	var/steps = 0
	var/last_check = 0
	var/check_delay = 10
	var/recalc = 0
	var/locked = 0

////FIELD GEN START

/obj/machinery/field_generator/attack_hand(mob/user as mob)
	if(state == 3)
		if(!src.locked)
			if(src.active >= 1)
	//			src.active = 0
	//			icon_state = "Field_Gen"
				user << "You are unable to turn off the field generator, wait till it powers down."
	//			src.cleanup()
			else
				src.active = 1
				icon_state = "Field_Gen +a"
				user << "You turn on the field generator."
		else
			user << "The controls are locked!"
	else
		user << "The field generator needs to be firmly secured to the floor first."
	src.add_fingerprint(user)

/obj/machinery/field_generator/attack_ai(mob/user as mob)
	if(state == 3)
		if(src.active >= 1)
			user << "You are unable to turn off the field generator, wait till it powers down."
		else
			src.active = 1
			icon_state = "Field_Gen +a"
			user << "You turn on the field generator."
	else
		user << "The field generator needs to be firmly secured to the floor first."
	src.add_fingerprint(user)

/obj/machinery/field_generator/New()
	..()
	return

/obj/machinery/field_generator/process()

	if(src.Varedit_start == 1)
		if(src.active == 0)
			src.active = 1
			src.state = 3
			src.power = 250
			src.anchored = 1
			icon_state = "Field_Gen +a"
		Varedit_start = 0

	if(src.active == 1)
		if(!src.state == 3)
			src.active = 0
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
	if(src.power > src.max_power)
		src.power = src.max_power
	if(src.active >= 1)
		src.power -= 1
		if(Varpower == 0)
			if(src.power <= 0)
				for(var/mob/M in viewers(src))
					M.show_message("\red The [src.name] shuts down due to lack of power!")
				icon_state = "Field_Gen"
				src.active = 0
				spawn(1)
					src.cleanup(1)
				spawn(1)
					src.cleanup(2)
				spawn(1)
					src.cleanup(4)
				spawn(1)
					src.cleanup(8)

/obj/machinery/field_generator/proc/setup_field(var/NSEW = 0)
	var/turf/T = src.loc
	var/turf/T2 = src.loc
	var/obj/machinery/field_generator/G
	var/steps = 0
	var/oNSEW = 0

	if(!NSEW)//Make sure its ran right
		return

	if(NSEW == 1)
		oNSEW = 2
	else if(NSEW == 2)
		oNSEW = 1
	else if(NSEW == 4)
		oNSEW = 8
	else if(NSEW == 8)
		oNSEW = 4

	for(var/dist = 0, dist <= 9, dist += 1) // checks out to 8 tiles away for another generator
		T = get_step(T2, NSEW)
		T2 = T
		steps += 1
		if(locate(/obj/machinery/field_generator) in T)
			G = (locate(/obj/machinery/field_generator) in T)
			steps -= 1
			if(!G.active)
				return
			G.cleanup(oNSEW)
			break

	if(isnull(G))
		return

	T2 = src.loc

	for(var/dist = 0, dist < steps, dist += 1) // creates each field tile
		var/field_dir = get_dir(T2,get_step(T2, NSEW))
		T = get_step(T2, NSEW)
		T2 = T
		var/obj/machinery/containment_field/CF = new/obj/machinery/containment_field/(src, G) //(ref to this gen, ref to connected gen)
		CF.loc = T
		CF.dir = field_dir


/obj/machinery/field_generator/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench))
		if(active)
			user << "Turn off the field generator first."
			return

		else if(state == 0)
			state = 1
			playsound(src.loc, 'Ratchet.ogg', 75, 1)
			user << "You secure the external reinforcing bolts to the floor."
			src.anchored = 1
			return

		else if(state == 1)
			state = 0
			playsound(src.loc, 'Ratchet.ogg', 75, 1)
			user << "You undo the external reinforcing bolts."
			src.anchored = 0
			return

	if(istype(W, /obj/item/weapon/weldingtool) && W:welding)

		var/turf/T = user.loc

		if (W:get_fuel() < 1)
			user << "\blue You need more welding fuel to complete this task."
			return
		W:use_fuel(1)

		if(state == 1)
			user << "You start to weld the field generator to the floor."
			playsound(src.loc, 'Welder2.ogg', 50, 1)
			sleep(20)

			if ((user.loc == T && user.equipped() == W))
				state = 3
				W:eyecheck(user)
				user << "You weld the field generator to the floor."
			else if((istype(user, /mob/living/silicon/robot) && (user.loc == T)))
				state = 3
				user << "You weld the field generator to the floor."
			return

		if(state == 3)
			user << "You start to cut the field generator free from the floor."
			playsound(src.loc, 'Welder2.ogg', 50, 1)
			sleep(20)

			if ((user.loc == T && user.equipped() == W))
				state = 1
/*				if(src.link) //Clear active link.
					src.link.master = null
					src.link = null*/
				W:eyecheck(user)
				user << "You cut the field generator free from the floor."
			else if((istype(user, /mob/living/silicon/robot) && (user.loc == T)))
				state = 1
/*				if(src.link) //Clear active link.
					src.link.master = null
					src.link = null*/
				user << "You cut the field generator free from the floor."
			return

	if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (src.allowed(user))
			src.locked = !src.locked
			user << "Controls are now [src.locked ? "locked." : "unlocked."]"
		else
			user << "\red Access denied."

	else
		src.add_fingerprint(user)
		user << "\red You hit the [src.name] with your [W.name]!"
		for(var/mob/M in viewers(src))
			if(M == user)	continue
			M.show_message("\red The [src.name] has been hit with the [W.name] by [user.name]!")


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
	return


/obj/machinery/field_generator/proc/cleanup(var/NSEW)
	var/obj/machinery/containment_field/F
	var/obj/machinery/field_generator/G
	var/turf/T = src.loc
	var/turf/T2 = src.loc

	for(var/dist = 0, dist <= 9, dist += 1) // checks out to 8 tiles away for fields
		T = get_step(T2, NSEW)
		T2 = T
		if(locate(/obj/machinery/containment_field) in T)
			F = (locate(/obj/machinery/containment_field) in T)
			del(F)

		if(locate(/obj/machinery/field_generator) in T)
			G = (locate(/obj/machinery/field_generator) in T)
			if(!G.active)
				break

/obj/machinery/field_generator/Del()
	src.cleanup(1)
	src.cleanup(2)
	src.cleanup(4)
	src.cleanup(8)
	..()


