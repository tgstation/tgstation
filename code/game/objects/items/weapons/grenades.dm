/*
CONTAINS:
EMP GRENADE
FLASHBANG

*/

/obj/item/weapon/empgrenade/afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
	if (user.equipped() == src)
		if ((user.mutations & 16) && prob(50))
			user << "\red Huh? How does this thing work?!"
			src.state = 1
			src.icon_state = "empar"
			playsound(src.loc, 'armbomb.ogg', 75, 1, -3)
			spawn( 5 )
				prime()
				return
		else if (!( src.state ))
			user << "\red You prime the emp grenade! [det_time/10] seconds!"
			src.state = 1
			src.icon_state = "empar"
			playsound(src.loc, 'armbomb.ogg', 75, 1, -3)
			spawn( src.det_time )
				prime()
				return
		user.dir = get_dir(user, target)
		user.drop_item()
		var/t = (isturf(target) ? target : target.loc)
		walk_towards(src, t, 3)
		src.add_fingerprint(user)
	return

/obj/item/weapon/empgrenade/proc/prime()
	playsound(src.loc, 'Welder2.ogg', 25, 1)
	var/turf/T = get_turf(src)
	if(T)
		T.hotspot_expose(700,125)

	var/grenade = src // detaching the proc - in theory
	src = null

	var/obj/overlay/pulse = new/obj/overlay ( T )
	pulse.icon = 'effects.dmi'
	pulse.icon_state = "emppulse"
	pulse.name = "emp pulse"
	pulse.anchored = 1
	spawn(20)
		del(pulse)

	for(var/obj/item/weapon/W in range(world.view-1, T))

		if (istype(W, /obj/item/assembly/m_i_ptank) || istype(W, /obj/item/assembly/r_i_ptank) || istype(W, /obj/item/assembly/t_i_ptank))

			var/fuckthis
			if(istype(W:part1,/obj/item/weapon/tank/plasma))
				fuckthis = W:part1
				fuckthis:ignite()
			if(istype(W:part2,/obj/item/weapon/tank/plasma))
				fuckthis = W:part2
				fuckthis:ignite()
			if(istype(W:part3,/obj/item/weapon/tank/plasma))
				fuckthis = W:part3
				fuckthis:ignite()


	for(var/mob/living/M in viewers(world.view-1, T))

		if(!istype(M, /mob/living)) continue

		if (istype(M, /mob/living/silicon))
			M.fireloss += 25
			flick("noise", M:flash)
			M << "\red <B>*BZZZT*</B>"
			M << "\red Warning: Electromagnetic pulse detected."
			if(istype(M, /mob/living/silicon/ai))
				if (prob(30))
					switch(pick(1,2,3)) //Add Random laws.
						if(1)
							M:cancel_camera()
						if(2)
							M:lockdown()
						if(3)
							M:ai_call_shuttle()
			continue


		M << "\red <B>Your equipment malfunctions.</B>" //Yeah, i realise that this WILL
														//show if theyre not carrying anything
														//that is affected. lazy.
		if (locate(/obj/item/weapon/cloaking_device, M))
			for(var/obj/item/weapon/cloaking_device/S in M)
				S.active = 0
				S.icon_state = "shield0"

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
					C.name = "Black Jumpsuit"
					C.icon_state = "bl_suit"
					C.color = "black"
					C.desc = null

		M << "\red <B>BZZZT</B>"


	for(var/obj/machinery/A in range(world.view-1, T))
		A.use_power(7500)

		var/obj/overlay/pulse2 = new/obj/overlay ( A.loc )
		pulse2.icon = 'effects.dmi'
		pulse2.icon_state = "empdisable"
		pulse2.name = "emp sparks"
		pulse2.anchored = 1
		pulse2.dir = pick(cardinal)

		spawn(10)
			del(pulse2)

		if(istype(A, /obj/machinery/turret))
			A:enabled = 0
			A:lasers = 0
			A:power_change()

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
			spawn(100)
				A:output = initial(A:output)
				A:charging = initial(A:charging)
				A:online = initial(A:online)

		if(istype(A, /obj/machinery/door))
			if(prob(20) && (istype(A,/obj/machinery/door/airlock) || istype(A,/obj/machinery/door/window)) )
				A:open()
			if(prob(40))
				if(A:secondsElectrified != 0) continue
				A:secondsElectrified = -1
				spawn(300)
					A:secondsElectrified = 0

		if(istype(A, /obj/machinery/power/apc))
			if(A:cell)
				A:cell:charge -= 1000
				if (A:cell:charge < 0)
					A:cell:charge = 0
			A:lighting = 0
			A:equipment = 0
			A:environ = 0
			spawn(600)
				A:equipment = 3
				A:environ = 3

		if(istype(A, /obj/machinery/camera))
			A.icon_state = "cameraemp"
			A:network = null                   //Not the best way but it will do. I think.
			spawn(900)
				A:network = initial(A:network)
				A:icon_state = initial(A:icon_state)
			for(var/mob/living/silicon/ai/O in world)
				if (O.current == A)
					O.cancel_camera()
					O << "Your connection to the camera has been lost."
			for(var/mob/O in world)
				if (istype(O.machine, /obj/machinery/computer/security))
					var/obj/machinery/computer/security/S = O.machine
					if (S.current == A)
						O.machine = null
						S.current = null
						O.reset_view(null)
						O << "The screen bursts into static."

		if(istype(A, /obj/machinery/clonepod))
			A:malfunction()

	for(var/obj/mecha/M in range(world.view-1, T))
		M.cell.charge = 0
		M.health -= 100
		M.update_health()

	del(grenade)

	return

/obj/item/weapon/flashbang/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/screwdriver))
		switch(src.det_time)
			if ("1")
				src.det_time = 30
				user.show_message("\blue You set the flashbang for 3 second detonation time.")
				src.desc = "It is set to detonate in 3 seconds."
			if ("30")
				src.det_time = 100
				user.show_message("\blue You set the flashbang for 10 second detonation time.")
				src.desc = "It is set to detonate in 10 seconds."
			if ("100")
				src.det_time = 1
				user.show_message("\blue You set the flashbang for instant detonation.")
				src.desc = "It is set to detonate instantly."
		src.add_fingerprint(user)
	return

/obj/item/weapon/flashbang/afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
	if (user.equipped() == src)
		if ((user.mutations & 16) && prob(50))
			user << "\red Huh? How does this thing work?!"
			src.state = 1
			src.icon_state = "flashbang1"
			playsound(src.loc, 'armbomb.ogg', 75, 1, -3)
			spawn( 5 )
				prime()
				return
		else if (!( src.state ))
			user << "\red You prime the flashbang! [det_time/10] seconds!"
			src.state = 1
			src.icon_state = "flashbang1"
			playsound(src.loc, 'armbomb.ogg', 75, 1, -3)
			spawn( src.det_time )
				prime()
				return
		user.dir = get_dir(user, target)
		user.drop_item()
		var/t = (isturf(target) ? target : target.loc)
		walk_towards(src, t, 3)
		src.add_fingerprint(user)
	return

/obj/item/weapon/flashbang/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/weapon/flashbang/attack_hand()
	walk(src, null, null)
	..()
	return

/obj/item/weapon/flashbang/proc/prime()
	playsound(src.loc, 'bang.ogg', 25, 1)
	var/turf/T = get_turf(src)
	if(T)
		T.hotspot_expose(700,125)

	for(var/mob/living/carbon/M in viewers(T, null))
		if (locate(/obj/item/weapon/cloaking_device, M))
			for(var/obj/item/weapon/cloaking_device/S in M)
				S.active = 0
				S.icon_state = "shield0"
		if ((get_dist(M, T) <= 2 || src.loc == M.loc || src.loc == M))
			flick("e_flash", M.flash)
			if(!(M.mutations & 8))  M.stunned = 10
			if(!(M.mutations & 8))  M.weakened = 3
			M << "\red <B>BANG</B>"
			if ((prob(14) || (M == src.loc && prob(70))))
				M.ear_damage += rand(1, 10)
			else
				if (prob(30))
					M.ear_damage += rand(0, 5)
			if (!( M.paralysis ))
				M.eye_stat += rand(0, 5)
			if (prob(10))
				M.eye_stat += rand(0, 4)
			M.ear_deaf += 30
			if (M == src.loc)
				M.eye_stat += rand(2, 5)
				if (prob(60))
					if (istype(M, /mob/living/carbon/human))
						var/mob/living/carbon/human/H = M
						if (!( istype(H.ears, /obj/item/clothing/ears/earmuffs) ))
							M.ear_damage += 15
							M.ear_deaf += 60
					else
						M.ear_damage += 15
						M.ear_deaf += 60
		else
			if (get_dist(M, T) <= 5)
				flick("e_flash", M.flash)
				if (!( istype(M, /mob/living/carbon/human) ))
					if(!(M.mutations & 8))  M.stunned = 7
					if(!(M.mutations & 8))  M.weakened = 2
				else
					var/mob/living/carbon/human/H = M
					M.ear_deaf += 10
					if (prob(20))
						M.ear_damage += rand(0, 4)
					if ((!( istype(H.glasses, /obj/item/clothing/glasses/sunglasses) || istype(H.head, /obj/item/clothing/head/helmet/welding) ) || M.paralysis))
						if(!(M.mutations & 8))  M.stunned = 7
						if(!(M.mutations & 8))  M.weakened = 2
					else
						if (!( M.paralysis ))
							M.eye_stat += rand(1, 3)
				M << "\red <B>BANG</B>"
			else
				if (!( istype(M, /mob/living/carbon/human) ))
					flick("flash", M.flash)
				else
					var/mob/living/carbon/human/H = M
					if (!( istype(H.glasses, /obj/item/clothing/glasses/sunglasses) || istype(H.head, /obj/item/clothing/head/helmet/welding) ) )
						flick("flash", M.flash)
				M.eye_stat += rand(1, 2)
				M.ear_deaf += 5
				M << "\red <B>BANG</B>"
		if (M.eye_stat >= 20)
			M << "\red Your eyes start to burn badly!"
			M.disabilities |= 1
			if (prob(M.eye_stat - 20 + 1))
				M << "\red You can't see anything!"
				M.sdisabilities |= 1
		if (M.ear_damage >= 15)
			M << "\red Your ears start to ring badly!"
			if (prob(M.ear_damage - 10 + 5))
				M << "\red You can't hear anything!"
				M.sdisabilities |= 4
		else
			if (M.ear_damage >= 5)
				M << "\red Your ears start to ring!"

	for(var/obj/blob/B in view(8,T))
		var/damage = round(30/(get_dist(B,T)+1))
		B.health -= damage
		B.update()
	del(src)
	return

/obj/item/weapon/flashbang/attack_self(mob/user as mob)
	if (!src.state)
		if (user.mutations & 16)
			user << "\red Huh? How does this thing work?!"
			spawn( 5 )
				prime()
				return
		else
			user << "\red You prime the flashbang! [det_time/10] seconds!"
			src.state = 1
			src.icon_state = "flashbang1"
			add_fingerprint(user)
			spawn( src.det_time )
				prime()
				return
	return

/obj/item/weapon/empgrenade/attack_self(mob/user as mob)
	if (!src.state)
		if (user.mutations & 16)
			user << "\red Huh? How does this thing work?!"
			spawn( 5 )
				prime()
				return
		else
			user << "\red You prime the flashbang! [det_time/10] seconds!"
			src.state = 1
			src.icon_state = "empar"
			add_fingerprint(user)
			spawn( src.det_time )
				prime()
				return
	return