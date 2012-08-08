//BLIND

/client/proc/blind()
	set category = "Spells"
	set name = "Blind"
	set desc = "This spell temporarly blinds a single person and does not require wizard garb."

	var/mob/M = input(usr, "Who do you wish to blind?") as mob in oview()

	if(M)
		if(usr.stat)
			src << "Not when you are incapacitated."
			return
	//	if(!usr.casting()) return
		usr.verbs -= /client/proc/blind
		spawn(300)
			usr.verbs += /client/proc/blind

		usr.whisper("STI KALY")

		var/obj/effect/overlay/B = new /obj/effect/overlay( M.loc )
		B.icon_state = "blspell"
		B.icon = 'icons/obj/wizard.dmi'
		B.name = "spell"
		B.anchored = 1
		B.density = 0
		B.layer = 4
		M.canmove = 0
		spawn(5)
			del(B)
			M.canmove = 1
		M << text("\blue Your eyes cry out in pain!")
		M.disabilities |= NEARSIGHTED
		spawn(300)
			M.disabilities &= ~NEARSIGHTED
		M.eye_blind = 10
		M.eye_blurry = 20
		return

//MAGIC MISSILE

/client/proc/magicmissile()
	set category = "Spells"
	set name = "Magic missile"
	set desc = "This spell fires several, slow moving, magic projectiles at nearby targets."
	if(usr.stat)
		src << "Not when you are incapacitated."
		return
	if(!usr.casting()) return

	usr.say("FORTI GY AMA")

	for (var/mob/living/M as mob in oview())
		spawn(0)
			var/obj/effect/overlay/A = new /obj/effect/overlay( usr.loc )
			A.icon_state = "magicm"
			A.icon = 'icons/obj/wizard.dmi'
			A.name = "a magic missile"
			A.anchored = 0
			A.density = 0
			A.layer = 4
			var/i
			for(i=0, i<20, i++)
				if (!istype(M)) //it happens sometimes --rastaf0
					break
				var/obj/effect/overlay/B = new /obj/effect/overlay( A.loc )
				B.icon_state = "magicmd"
				B.icon = 'icons/obj/wizard.dmi'
				B.name = "trail"
				B.anchored = 1
				B.density = 0
				B.layer = 3
				spawn(5)
					del(B)
				step_to(A,M,0)
				if (get_dist(A,M) == 0)
					M.Weaken(5)
					M.take_overall_damage(0,10)
					del(A)
					return
				sleep(5)
			del(A)

	usr.verbs -= /client/proc/magicmissile
	spawn(100)
		usr.verbs += /client/proc/magicmissile

//SMOKE

/client/proc/smokecloud()

	set category = "Spells"
	set name = "Smoke"
	set desc = "This spell spawns a cloud of choking smoke at your location and does not require wizard garb."
	if(usr.stat)
		src << "Not when you are incapacitated."
		return
//	if(!usr.casting()) return
	usr.verbs -= /client/proc/smokecloud
	spawn(120)
		usr.verbs += /client/proc/smokecloud
	var/datum/effect/effect/system/bad_smoke_spread/smoke = new /datum/effect/effect/system/bad_smoke_spread()
	smoke.set_up(10, 0, usr.loc)
	smoke.start()


//SLEEP SMOKE

///client/proc/smokecloud()
//
//	set category = "Spells"
//	set name = "Sleep Smoke"
//	set desc = "This spell spawns a cloud of choking smoke at your location and does not require wizard garb. But, without the robes, you have no protection against the magic."
//	if(usr.stat)
//		src << "Not when you are incapacitated."
//		return
//	if(!usr.casting()) return
//	usr.verbs -= /client/proc/smokecloud
//	spawn(120)
//		usr.verbs += /client/proc/smokecloud
//	var/datum/effect/system/sleep_smoke_spread/smoke = new /datum/effect/system/sleep_smoke_spread()
//	smoke.set_up(10, 0, usr.loc)
//	smoke.start()

//FORCE WALL

/obj/effect/forcefield
	desc = "A space wizard's magic wall."
	name = "FORCEWALL"
	icon = 'icons/effects/effects.dmi'
	icon_state = "m_shield"
	anchored = 1.0
	opacity = 0
	density = 1
	unacidable = 1


	bullet_act(var/obj/item/projectile/Proj, var/def_zone)
		var/turf/T = get_turf(src.loc)
		if(T)
			for(var/mob/M in T)
				Proj.on_hit(M,M.bullet_act(Proj, def_zone))
		return



/client/proc/forcewall()

	set category = "Spells"
	set name = "Forcewall"
	set desc = "This spell creates an unbreakable wall that lasts for 30 seconds and does not need wizard garb."
	if(usr.stat)
		src << "Not when you are incapacitated."
		return
//	if(!usr.casting()) return

	usr.verbs -= /client/proc/forcewall
	spawn(100)
		usr.verbs += /client/proc/forcewall
	var/forcefield

	usr.whisper("TARCOL MINTI ZHERI")

	forcefield =  new /obj/effect/forcefield(locate(usr.x,usr.y,usr.z))
	spawn (300)
		del (forcefield)
	return

//FIREBALLAN

/client/proc/fireball()
	set category = "Spells"
	set name = "Fireball"
	set desc = "This spell fires a fireball at a target and does not require wizard garb."
	if(usr.stat)
		src << "Not when you are incapacitated."
		return
//	if(!usr.casting()) return

	usr.verbs -= /client/proc/fireball
	spawn(100)
		usr.verbs += /client/proc/fireball

	usr.say("ONI SOMA")

	var/mob/living/user = src
	if(!istype(user))
		return

	var/i
	var/turf/T
	var/range = 15

	var/x = user.loc.x
	var/y = user.loc.y
	var/z = user.loc.z

	switch(user.dir)
		if(NORTH)
			T = get_turf(locate(x, y + range, z))
		if(EAST)
			T = get_turf(locate(x + range, y, z))
		if(SOUTH)
			T = get_turf(locate(x, y - range, z))
		if(WEST)
			T = get_turf(locate(x - range, y, z))
		else
			return

	var/obj/effect/overlay/A = new /obj/effect/overlay( usr.loc )

	A.icon_state = "fireball"
	A.icon = 'icons/obj/wizard.dmi'
	A.name = "a fireball"
	A.anchored = 0
	A.density = 0
	A.luminosity = 3

	step_to(A, T, 0)
	for(i=0, i<100, i++)
		var/hit = 0
		var/moving = step_to(A,T,0)
		for(var/mob/living/target in range(1, A))
			hit = 1
			target.take_overall_damage(20,25)
		if(hit)
			explosion(A.loc, -1, -1, 2, 2)
			del(A)
			return
		if(!moving)
			explosion(A.loc, -1, -1, 2, 2)
			del(A)
			return
		sleep(2)
	if(A)
		explosion(A.loc, -1, -1, 2, 2)
		del(A)
	return

//KNOCK

/client/proc/knock()
	set category = "Spells"
	set name = "Knock"
	set desc = "This spell opens nearby doors and does not require wizard garb."
	if(usr.stat)
		src << "Not when you are incapacitated."
		return
//	if(!usr.casting()) return
	usr.verbs -= /client/proc/knock
	spawn(100)
		usr.verbs += /client/proc/knock

	usr.whisper("AULIE OXIN FIERA")

	for(var/obj/machinery/door/G in oview(3))
		spawn(1)
			G.open()
	return

//KILL

/mob/proc/kill(mob/living/M as mob in oview(1))
	set category = "Spells"
	set name = "Disintegrate"
	set desc = "This spell instantly kills somebody adjacent to you with the vilest of magick."
	if(usr.stat)
		src << "Not when you are incapacitated."
		return
	if(!usr.casting()) return
	usr.verbs -= /mob/proc/kill
	spawn(600)
		usr.verbs += /mob/proc/kill

	usr.say("EI NATH")

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(4, 1, M)
	s.start()

	M.dust()

//DISABLE TECH

/mob/proc/tech()
	set category = "Spells"
	set name = "Disable Technology"
	set desc = "This spell disables all weapons, cameras and most other technology in range."
	if(usr.stat)
		src << "Not when you are incapacitated."
		return
	if(!usr.casting()) return
	usr.verbs -= /mob/proc/tech
	spawn(400)
		usr.verbs += /mob/proc/tech

	usr.say("NEC CANTIO")
	empulse(src, 6, 10)
	return

//BLINK

/client/proc/blink()
	set category = "Spells"
	set name = "Blink"
	set desc = "This spell randomly teleports you a short distance."
	if(usr.stat)
		src << "Not when you are incapacitated."
		return
	if(!usr.casting()) return
	var/list/turfs = new/list()
	for(var/turf/T in orange(6))
		if(istype(T,/turf/space)) continue
		if(T.density) continue
		if(T.x>world.maxx-4 || T.x<4)	continue	//putting them at the edge is dumb
		if(T.y>world.maxy-4 || T.y<4)	continue
		turfs += T
	if(!turfs.len) turfs += pick(/turf in orange(6))
	var/datum/effect/effect/system/harmless_smoke_spread/smoke = new /datum/effect/effect/system/harmless_smoke_spread()
	smoke.set_up(10, 0, usr.loc)
	smoke.start()
	var/turf/picked = pick(turfs)
	if(!isturf(picked)) return
	usr.loc = picked
	usr.verbs -= /client/proc/blink
	spawn(40)
		usr.verbs += /client/proc/blink

//TELEPORT

/mob/proc/teleport()
	set category = "Spells"
	set name = "Teleport"
	set desc = "This spell teleports you to a type of area of your selection."
	if(usr.stat)
		src << "Not when you are incapacitated."
		return
	if(!usr.casting()) return
	var/A
	usr.verbs -= /mob/proc/teleport
/*
	var/list/theareas = new/list()
	for(var/area/AR in world)
		if(istype(AR, /area/shuttle) || istype(AR, /area/syndicate_station)) continue
		if(theareas.Find(AR.name)) continue
		var/turf/picked = pick(get_area_turfs(AR.type))
		if (picked.z == src.z)
			theareas += AR.name
			theareas[AR.name] = AR
*/

	A = input("Area to jump to", "BOOYEA", A) in teleportlocs

	spawn(600)
		usr.verbs += /mob/proc/teleport

	var/area/thearea = teleportlocs[A]

	usr.say("SCYAR NILA [uppertext(A)]")

	var/datum/effect/effect/system/harmless_smoke_spread/smoke = new /datum/effect/effect/system/harmless_smoke_spread()
	smoke.set_up(5, 0, usr.loc)
	smoke.attach(usr)
	smoke.start()
	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!T.density)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L+=T
	if(L.len)
		usr.loc = pick(L)
	else
		usr <<"The spell matrix was unable to locate a suitable teleport destination for an unknown reason. Sorry."

	smoke.start()

/mob/proc/teleportscroll()
	if(usr.stat)
		usr << "Not when you are incapacitated."
		return
	var/A

	A = input("Area to jump to", "BOOYEA", A) in teleportlocs
	var/area/thearea = teleportlocs[A]

	var/datum/effect/effect/system/harmless_smoke_spread/smoke = new /datum/effect/effect/system/harmless_smoke_spread()
	smoke.set_up(5, 0, usr.loc)
	smoke.attach(usr)
	smoke.start()
	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!T.density)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L+=T

	if(!L.len)
		usr <<"Invalid teleport destination."
		return

	else
		usr.loc = pick(L)
		smoke.start()

//JAUNT

/client/proc/jaunt()
	set category = "Spells"
	set name = "Ethereal Jaunt"
	set desc = "This spell creates your ethereal form, temporarily making you invisible and able to pass through walls."
	if(usr.stat)
		src << "Not when you are incapacitated."
		return
	if(!usr.casting()) return
	usr.verbs -= /client/proc/jaunt
	spawn(300)
		usr.verbs += /client/proc/jaunt
	spell_jaunt(usr)

/proc/spell_jaunt(var/mob/H, time = 50)
	if(H.stat) return
	spawn(0)
		var/mobloc = get_turf(H.loc)
		var/obj/effect/dummy/spell_jaunt/holder = new /obj/effect/dummy/spell_jaunt( mobloc )
		var/atom/movable/overlay/animation = new /atom/movable/overlay( mobloc )
		animation.name = "water"
		animation.density = 0
		animation.anchored = 1
		animation.icon = 'icons/mob/mob.dmi'
		animation.icon_state = "liquify"
		animation.layer = 5
		animation.master = holder
		flick("liquify",animation)
		H.loc = holder
		H.client.eye = holder
		var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
		steam.set_up(10, 0, mobloc)
		steam.start()
		sleep(time)
		mobloc = get_turf(H.loc)
		animation.loc = mobloc
		steam.location = mobloc
		steam.start()
		H.canmove = 0
		sleep(20)
		flick("reappear",animation)
		sleep(5)
		H.loc = mobloc
		H.canmove = 1
		H.client.eye = H
		del(animation)
		del(holder)
/*
/obj/effect/dummy/spell_jaunt
	name = "water"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	var/canmove = 1
	density = 0
	anchored = 1

/obj/effect/dummy/spell_jaunt/relaymove(var/mob/user, direction)
	if (!src.canmove) return
	switch(direction)
		if(NORTH)
			src.y++
		if(SOUTH)
			src.y--
		if(EAST)
			src.x++
		if(WEST)
			src.x--
		if(NORTHEAST)
			src.y++
			src.x++
		if(NORTHWEST)
			src.y++
			src.x--
		if(SOUTHEAST)
			src.y--
			src.x++
		if(SOUTHWEST)
			src.y--
			src.x--
	src.canmove = 0
	spawn(2) src.canmove = 1

/obj/effect/dummy/spell_jaunt/ex_act(blah)
	return
/obj/effect/dummy/spell_jaunt/bullet_act(blah,blah)
	return
*/
//MUTATE

/client/proc/mutate()
	set category = "Spells"
	set name = "Mutate"
	set desc = "This spell causes you to turn into a hulk and gain laser vision for a short while."
	if(usr.stat)
		src << "Not when you are incapacitated."
		return
	if(!usr.casting()) return
	usr.verbs -= /client/proc/mutate
	spawn(400)
		usr.verbs += /client/proc/mutate

	usr.say("BIRUZ BENNAR")

	usr << text("\blue You feel strong! You feel pressure building behind your eyes!")
	if (!(HULK in usr.mutations))
		usr.mutations.Add(HULK)
	if (!(LASER in usr.mutations))
		usr.mutations.Add(LASER)
	spawn (300)
		if (LASER in usr.mutations) usr.mutations.Remove(LASER)
		if (HULK in usr.mutations)  usr.mutations.Remove(HULK)
	return

//BODY SWAP /N

/mob/proc/swap(mob/living/M as mob in oview())
	set category = "Spells"
	set name = "Mind Transfer"
	set desc = "This spell allows the user to switch bodies with a target."
	if(usr.stat)
		src << "Not when you are incapacitated."
		return

	if(M.client && M.mind)
		if(M.mind.special_role != "Wizard" || "Fake Wizard" || "Changeling" || "Cultist" || "Space Ninja")//Wizards, changelings, ninjas, and cultists are protected.
			if( (istype(M, /mob/living/carbon/human)) || (istype(M, /mob/living/carbon/monkey)) && M.stat != 2)
				var/mob/living/carbon/human/H = M //so it does not freak out when looking at the variables.
				var/mob/living/carbon/human/U = src

				U.whisper("GIN'YU CAPAN")
				U.verbs -= /mob/proc/swap
				//Remove special verbs from both mobs
				if(U.mind.special_verbs.len)
					for(var/V in U.mind.special_verbs)
						U.verbs -= V
				if(H.mind.special_verbs.len)
					for(var/V in H.mind.special_verbs)
						H.verbs -= V

				//empty out H
				var/mob/dead/observer/G = H.ghostize(0) //Transfers H to a temporary mob

				//Start the Transfer
				U.mind.transfer_to(H)
				G.mind.transfer_to(U)
				U.key = G.key			//has to be called explicitly since ghostize() set the datum/mind/var/active = 0

				//Re-add those special verbs and stuff
				if(H.mind.special_verbs.len)
					var/spell_loss = 1//Can lose only one spell during transfer.
					var/probability = 95 //To determine the chance of wizard losing their spell.
					for(var/V in H.mind.special_verbs)
						if(spell_loss == 0)
							H.verbs += V
						else
							if(prob(probability))
								H.verbs += V
								probability -= 7//Chance of of keeping spells goes down each time a spell is added. Less spells means less chance of losing them.
							else
								spell_loss = 0
								H.mind.special_verbs -= V
								spawn(500)
									H << "The mind transfer has robbed you of a spell."

				if(U.mind.special_verbs.len)//Basic fix to swap verbs for any mob if needed.
					for(var/V in U.mind.special_verbs)
						U.verbs += V

				spawn(500)
					U << "Something about your body doesn't seem quite right..."

				U.Paralyse(20)
				H.Paralyse(20)

				spawn(600)
					H.verbs += /mob/proc/swap

			else
				src << "Their mind is not compatible."
				return
		else
			src << "Their mind is resisting your spell."
			return

	else
		src << "They appear to be brain-dead."
	return