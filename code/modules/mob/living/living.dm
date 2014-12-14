/mob/living/Life()
	..()
	var/area/cur_area = get_area(loc)
	if(cur_area)
		cur_area.mob_activate(src)

/mob/living/Destroy()
//	if(mind)
//		mind.current = null
	..()
	del(src)

//Generic Bump(). Override MobBump() and ObjBump() instead of this.
/mob/living/Bump(atom/A, yes)
	if (buckled || !yes || now_pushing)
		return
	if(ismob(A))
		var/mob/M = A
		if(MobBump(M))
			return
	..()
	if(isobj(A))
		var/obj/O = A
		if(ObjBump(O))
			return
	if(istype(A, /atom/movable))
		var/atom/movable/AM = A
		if(PushAM(AM))
			return

//Called when we bump onto a mob
/mob/living/proc/MobBump(mob/M)
	if(now_pushing)
		return 1

	//BubbleWrap: Should stop you pushing a restrained person out of the way
	if(istype(M, /mob/living/carbon/human))
		for(var/mob/MM in range(M, 1))
			if( ((MM.pulling == M && ( M.restrained() && !( MM.restrained() ) && MM.stat == CONSCIOUS)) || locate(/obj/item/weapon/grab, M.grabbed_by.len)) )
				if ( !(world.time % 5) )
					src << "<span class='warning'>[M] is restrained, you cannot push past.</span>"
				return 1
			if( M.pulling == MM && ( MM.restrained() && !( M.restrained() ) && M.stat == CONSCIOUS) )
				if ( !(world.time % 5) )
					src << "<span class='warning'>[M] is restraining [MM], you cannot push past.</span>"
				return 1

	//switch our position with M
	//BubbleWrap: people in handcuffs are always switched around as if they were on 'help' intent to prevent a person being pulled from being seperated from their puller
	if((M.a_intent == "help" || M.restrained()) && (a_intent == "help" || restrained()) && M.canmove && canmove) // mutual brohugs all around!
		now_pushing = 1
		//TODO: Make this use Move(). we're pretty much recreating it here.
		//it could be done by setting one of the locs to null to make Move() work, then setting it back and Move() the other mob
		var/oldloc = loc
		loc = M.loc
		M.loc = oldloc
		M.LAssailant = src

		for(var/mob/living/carbon/slime/slime in view(1,M))
			if(slime.Victim == M)
				slime.UpdateFeed()

		//cross any movable atoms on either turf
		for(var/atom/movable/AM in loc)
			AM.Crossed(src)
		for(var/atom/movable/AM in oldloc)
			AM.Crossed(M)
		now_pushing = 0
		return 1

	//okay, so we didn't switch. but should we push?
	//not if he's not CANPUSH of course
	if(!(M.status_flags & CANPUSH) )
		return 1
	//anti-riot equipment is also anti-push
	if(M.r_hand && istype(M.r_hand, /obj/item/weapon/shield/riot))
		return 1
	if(M.l_hand && istype(M.l_hand, /obj/item/weapon/shield/riot))
		return 1

//Called when we bump onto an obj
/mob/living/proc/ObjBump(obj/O)
	return

//Called when we want to push an atom/movable
/mob/living/proc/PushAM(atom/movable/AM)
	if(now_pushing)
		return 1
	if(!AM.anchored)
		now_pushing = 1
		var/t = get_dir(src, AM)
		if (istype(AM, /obj/structure/window))
			var/obj/structure/window/W = AM
			if(W.fulltile)
				for(var/obj/structure/window/win in get_step(W,t))
					now_pushing = 0
					return
		if(pulling == AM)
			stop_pulling()
		step(AM, t)
		now_pushing = 0

//mob verbs are a lot faster than object verbs
//for more info on why this is not atom/pull, see examinate() in mob.dm
/mob/living/verb/pulled(atom/movable/AM as mob|obj in oview(1))
	set name = "Pull"
	set category = "Object"

	if(AM.Adjacent(src))
		src.start_pulling(AM)
	return

//same as above
/mob/living/pointed(atom/A as mob|obj|turf in view())
	if(src.stat || !src.canmove || src.restrained())
		return 0
	if(src.status_flags & FAKEDEATH)
		return 0
	if(!..())
		return 0
	usr.visible_message("<b>[src]</b> points to [A]")
	return 1

/mob/living/verb/succumb(var/whispered as null)
	set hidden = 1
	if (InCritical())
		src.attack_log += "[src] has [whispered ? "whispered his final words" : "succumbed to death"] with [round(health, 0.1)] points of health!"
		src.adjustOxyLoss(src.health - config.health_threshold_dead)
		updatehealth()
		if(!whispered)
			src << "<span class='notice'>You have given up life and succumbed to death.</span>"
		death()

/mob/living/proc/InCritical()
	return (src.health < 0 && src.health > -95.0 && stat == UNCONSCIOUS)

/mob/living/ex_act(severity, target)
	..()
	if(client && !blinded)
		flick("flash", src.flash)

/mob/living/proc/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
		return
	health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss()


//This proc is used for mobs which are affected by pressure to calculate the amount of pressure that actually
//affects them once clothing is factored in. ~Errorage
/mob/living/proc/calculate_affecting_pressure(var/pressure)
	return 0


//sort of a legacy burn method for /electrocute, /shock, and the e_chair
/mob/living/proc/burn_skin(burn_amount)
	if(istype(src, /mob/living/carbon/human))
		//world << "DEBUG: burn_skin(), mutations=[mutations]"
		if (COLD_RESISTANCE in src.mutations) //fireproof
			return 0
		var/mob/living/carbon/human/H = src	//make this damage method divide the damage to be done among all the body parts, then burn each body part for that much damage. will have better effect then just randomly picking a body part
		var/divided_damage = (burn_amount)/(H.organs.len)
		var/extradam = 0	//added to when organ is at max dam
		for(var/obj/item/organ/limb/affecting in H.organs)
			if(!affecting)	continue
			if(affecting.take_damage(0, divided_damage+extradam))	//TODO: fix the extradam stuff. Or, ebtter yet...rewrite this entire proc ~Carn
				H.update_damage_overlays(0)
		H.updatehealth()
		return 1
	else if(istype(src, /mob/living/carbon/monkey))
		if (COLD_RESISTANCE in src.mutations) //fireproof
			return 0
		var/mob/living/carbon/monkey/M = src
		M.adjustFireLoss(burn_amount)
		M.updatehealth()
		return 1
	else if(istype(src, /mob/living/silicon/ai))
		return 0

/mob/living/proc/adjustBodyTemp(actual, desired, incrementboost)
	var/temperature = actual
	var/difference = abs(actual-desired)	//get difference
	var/increments = difference/10 //find how many increments apart they are
	var/change = increments*incrementboost	// Get the amount to change by (x per increment)

	// Too cold
	if(actual < desired)
		temperature += change
		if(actual > desired)
			temperature = desired
	// Too hot
	if(actual > desired)
		temperature -= change
		if(actual < desired)
			temperature = desired
//	if(istype(src, /mob/living/carbon/human))
//		world << "[src] ~ [src.bodytemperature] ~ [temperature]"
	return temperature


// MOB PROCS
/mob/living/proc/getBruteLoss()
	return bruteloss

/mob/living/proc/adjustBruteLoss(var/amount)
	if(status_flags & GODMODE)	return 0
	bruteloss = min(max(bruteloss + amount, 0),(maxHealth*2))

/mob/living/proc/getOxyLoss()
	return oxyloss

/mob/living/proc/adjustOxyLoss(var/amount)
	if(status_flags & GODMODE)	return 0
	oxyloss = min(max(oxyloss + amount, 0),(maxHealth*2))

/mob/living/proc/setOxyLoss(var/amount)
	if(status_flags & GODMODE)	return 0
	oxyloss = amount

/mob/living/proc/getToxLoss()
	return toxloss

/mob/living/proc/adjustToxLoss(var/amount)
	if(status_flags & GODMODE)	return 0
	toxloss = min(max(toxloss + amount, 0),(maxHealth*2))

/mob/living/proc/setToxLoss(var/amount)
	if(status_flags & GODMODE)	return 0
	toxloss = amount

/mob/living/proc/getFireLoss()
	return fireloss

/mob/living/proc/adjustFireLoss(var/amount)
	if(status_flags & GODMODE)	return 0
	fireloss = min(max(fireloss + amount, 0),(maxHealth*2))

/mob/living/proc/getCloneLoss()
	return cloneloss

/mob/living/proc/adjustCloneLoss(var/amount)
	if(status_flags & GODMODE)	return 0
	cloneloss = min(max(cloneloss + amount, 0),(maxHealth*2))

/mob/living/proc/setCloneLoss(var/amount)
	if(status_flags & GODMODE)	return 0
	cloneloss = amount

/mob/living/proc/getBrainLoss()
	return brainloss

/mob/living/proc/adjustBrainLoss(var/amount)
	if(status_flags & GODMODE)	return 0
	brainloss = min(max(brainloss + amount, 0),(maxHealth*2))

/mob/living/proc/setBrainLoss(var/amount)
	if(status_flags & GODMODE)	return 0
	brainloss = amount

/mob/living/proc/getStaminaLoss()
	return staminaloss

/mob/living/proc/adjustStaminaLoss(var/amount)
	if(status_flags & GODMODE)	return 0
	staminaloss = min(max(staminaloss + amount, 0),(maxHealth*2))

/mob/living/proc/setStaminaLoss(var/amount)
	if(status_flags & GODMODE)	return 0
	staminaloss = amount

/mob/living/proc/getMaxHealth()
	return maxHealth

/mob/living/proc/setMaxHealth(var/newMaxHealth)
	maxHealth = newMaxHealth

// MOB PROCS //END


/mob/proc/get_contents()

/mob/living/proc/mob_sleep()
	set name = "Sleep"
	set category = "IC"

	if(usr.sleeping)
		usr << "<span class='notice'>You are already sleeping.</span>"
		return
	else
		if(alert(src, "You sure you want to sleep for a while?", "Sleep", "Yes", "No") == "Yes")
			usr.sleeping = 20 //Short nap


/mob/living/proc/lay_down()
	set name = "Rest"
	set category = "IC"

	resting = !resting
	src << "<span class='notice'>You are now [resting ? "resting" : "getting up"].</span>"

//Recursive function to find everything a mob is holding.
/mob/living/get_contents(var/obj/item/weapon/storage/Storage = null)
	var/list/L = list()

	if(Storage) //If it called itself
		L += Storage.return_inv()
		return L
	else
		L += src.contents
		for(var/obj/item/weapon/storage/S in src.contents)	//Check for storage items
			L += get_contents(S)
		for(var/obj/item/clothing/under/U in src.contents)	//Check for jumpsuit accessories
			L += U.contents
		return L

/mob/living/proc/check_contents_for(A)
	var/list/L = src.get_contents()

	for(var/obj/B in L)
		if(B.type == A)
			return 1
	return 0


/mob/living/proc/electrocute_act(var/shock_damage, var/obj/source, var/siemens_coeff = 1.0)
	  return 0 //only carbon liveforms have this proc

/mob/living/emp_act(severity)
	var/list/L = src.get_contents()
	for(var/obj/O in L)
		O.emp_act(severity)
	..()

/mob/living/proc/can_inject()
	return 1

/mob/living/proc/get_organ_target()
	var/mob/shooter = src
	var/t = shooter:zone_sel.selecting
	if ((t in list( "eyes", "mouth" )))
		t = "head"
	var/obj/item/organ/limb/def_zone = ran_zone(t)
	return def_zone


// heal ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/heal_organ_damage(var/brute, var/burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	src.updatehealth()

// damage ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/take_organ_damage(var/brute, var/burn)
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	src.updatehealth()

// heal MANY external organs, in random order
/mob/living/proc/heal_overall_damage(var/brute, var/burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	src.updatehealth()

// damage MANY external organs, in random order
/mob/living/proc/take_overall_damage(var/brute, var/burn)
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	src.updatehealth()

/mob/living/proc/revive()
	setToxLoss(0)
	setOxyLoss(0)
	setCloneLoss(0)
	setBrainLoss(0)
	setStaminaLoss(0)
	SetParalysis(0)
	SetStunned(0)
	SetWeakened(0)
	radiation = 0
	nutrition = 400
	bodytemperature = 310
	sdisabilities = 0
	disabilities = 0
	blinded = 0
	eye_blind = 0
	eye_blurry = 0
	ear_deaf = 0
	ear_damage = 0
	heal_overall_damage(1000, 1000)
	ExtinguishMob()
	fire_stacks = 0
	suiciding = 0
	if(iscarbon(src))
		var/mob/living/carbon/C = src
		C.handcuffed = initial(C.handcuffed)
		if(C.reagents)
			for(var/datum/reagent/R in C.reagents.reagent_list)
				C.reagents.clear_reagents()
	for(var/datum/disease/D in viruses)
		D.cure(0)
	if(stat == 2)
		dead_mob_list -= src
		living_mob_list += src
	if(!isanimal(src))	stat = CONSCIOUS
	update_fire()
	regenerate_icons()
	..()
	return

/mob/living/proc/update_damage_overlays()
	return


/mob/living/proc/Examine_OOC()
	set name = "Examine Meta-Info (OOC)"
	set category = "OOC"
	set src in view()

	if(config.allow_Metadata)
		if(client)
			usr << "[src]'s Metainfo:<br>[client.prefs.metadata]"
		else
			usr << "[src] does not have any stored infomation!"
	else
		usr << "OOC Metadata is not supported by this server!"

	return

/mob/living/Move(atom/newloc, direct)
	if (buckled && buckled.loc != newloc)
		if (!buckled.anchored)
			return buckled.Move(newloc, direct)
		else
			return 0

	if (restrained())
		stop_pulling()


	var/t7 = 1
	if (restrained())
		for(var/mob/living/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained() )))
				t7 = null
	if (t7 && pulling && (get_dist(src, pulling) <= 1 || pulling.loc == loc))
		var/turf/T = loc
		. = ..()

		if (pulling && pulling.loc)
			if(!isturf(pulling.loc))
				stop_pulling()
				return
			else
				if(Debug)
					diary <<"pulling disappeared? at [__LINE__] in mob.dm - pulling = [pulling]"
					diary <<"REPORT THIS"

		/////
		if(pulling && pulling.anchored)
			stop_pulling()
			return

		if (!restrained())
			var/diag = get_dir(src, pulling)
			if ((diag - 1) & diag)
			else
				diag = null
			if ((get_dist(src, pulling) > 1 || diag))
				if (isliving(pulling))
					var/mob/living/M = pulling
					var/ok = 1
					if (locate(/obj/item/weapon/grab, M.grabbed_by))
						if (prob(75))
							var/obj/item/weapon/grab/G = pick(M.grabbed_by)
							if (istype(G, /obj/item/weapon/grab))
								visible_message("<span class='danger'>[src] has pulled [G.affecting] from [G.assailant]'s grip.</span>")
								qdel(G)
						else
							ok = 0
						if (locate(/obj/item/weapon/grab, M.grabbed_by.len))
							ok = 0
					if (ok)
						var/atom/movable/t = M.pulling
						M.stop_pulling()

						//this is the gay blood on floor shit -- Added back -- Skie
						if (M.lying && (prob(M.getBruteLoss() / 2)))
							var/blood_exists = 0
							var/trail_type = M.getTrail()
							for(var/obj/effect/decal/cleanable/trail_holder/C in M.loc) //checks for blood splatter already on the floor
								blood_exists = 1
							if (istype(M.loc, /turf/simulated) && trail_type != null)
								var/newdir = get_dir(T, M.loc)
								if(newdir != M.dir)
									newdir = newdir | M.dir
									if(newdir == 3) //N + S
										newdir = NORTH
									else if(newdir == 12) //E + W
										newdir = EAST
								if((newdir in list(1, 2, 4, 8)) && (prob(50)))
									newdir = turn(get_dir(T, M.loc), 180)
								if(!blood_exists)
									new /obj/effect/decal/cleanable/trail_holder(M.loc)
								for(var/obj/effect/decal/cleanable/trail_holder/H in M.loc)
									if((!(newdir in H.existing_dirs) || trail_type == "trails_1" || trail_type == "trails_2") && H.existing_dirs.len <= 16) //maximum amount of overlays is 16 (all light & heavy directions filled)
										H.existing_dirs += newdir
										H.overlays.Add(image('icons/effects/blood.dmi',trail_type,dir = newdir))
										H.trail_type = trail_type
										if(check_dna_integrity(M)) //blood DNA
											var/mob/living/carbon/DNA_helper = pulling
											H.blood_DNA[DNA_helper.dna.unique_enzymes] = DNA_helper.dna.blood_type
						pulling.Move(T, get_dir(pulling, T))
						if(M)
							M.start_pulling(t)
				else
					if (pulling)
						pulling.Move(T, get_dir(pulling, T))
	else
		stop_pulling()
		. = ..()
	if ((s_active && !( s_active in contents ) ))
		s_active.close(src)

	if(update_slimes)
		for(var/mob/living/carbon/slime/M in view(1,src))
			M.UpdateFeed(src)

/mob/living/proc/getTrail() //silicon and simple_animals don't get blood trails
    return null

/mob/living/proc/cuff_break(obj/item/weapon/restraints/I, mob/living/carbon/C)

	if(HULK in usr.mutations)
		C.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))

	C.visible_message("<span class='danger'>[C] manages to break [I]!</span>")
	C << "<span class='notice'>You successfully break [I].</span>"
	qdel(I)

	if(C.handcuffed)
		C.handcuffed = null
		C.update_inv_handcuffed(0)
	else
		C.legcuffed = null
		C.update_inv_legcuffed(0)


/mob/living/proc/cuff_resist(obj/item/weapon/restraints/I, mob/living/carbon/C)
	var/breakouttime = 600
	var/displaytime = 1
	if(istype(I, /obj/item/weapon/restraints/handcuffs))
		var/obj/item/weapon/restraints/handcuffs/HC = C.handcuffed
		breakouttime = HC.breakouttime
	else if(istype(I, /obj/item/weapon/restraints/legcuffs))
		var/obj/item/weapon/restraints/legcuffs/LC = C.legcuffed
		breakouttime = LC.breakouttime
	displaytime = breakouttime / 600

	if(isalienadult(C) || HULK in usr.mutations)
		C.visible_message("<span class='warning'>[C] is trying to break [I]!</span>")
		C << "<span class='notice'>You attempt to break [I]. (This will take around 5 seconds and you need to stand still.)</span>"
		spawn(0)
			if(do_after(C, 50))
				if(!I || C.buckled)
					return
				cuff_break(I, C)
			else
				C << "<span class='warning'>You fail to break [I]!</span>"
	else

		C.visible_message("<span class='warning'>[C] attempts to remove [I]!</span>")
		C << "<span class='notice'>You attempt to remove [I]. (This will take around [displaytime] minutes and you need to stand still.)</span>"
		spawn(0)
			if(do_after(C, breakouttime))
				if(!I || C.buckled)
					return
				C.visible_message("<span class='danger'>[C] manages to remove [I]!</span>")
				C << "<span class='notice'>You successfully remove [I].</span>"

				if(C.handcuffed)
					C.handcuffed.loc = usr.loc
					C.handcuffed = null
					C.update_inv_handcuffed(0)
				if(C.legcuffed)
					C.legcuffed.loc = usr.loc
					C.legcuffed = null
					C.update_inv_legcuffed(0)
			else
				C << "<span class='warning'>You fail to remove [I]!</span>"

/mob/living/verb/resist()
	set name = "Resist"
	set category = "IC"

	if(!isliving(usr) || usr.next_move > world.time)
		return
	usr.changeNext_move(CLICK_CD_RESIST)

	var/mob/living/L = usr

	//resisting grabs (as if it helps anyone...)
	if(!L.stat && L.canmove && !L.restrained())
		var/resisting = 0
		for(var/obj/O in L.requests)
			qdel(O)
			resisting++
		for(var/obj/item/weapon/grab/G in usr.grabbed_by)
			resisting++
			if(G.state == GRAB_PASSIVE)
				qdel(G)
			else
				if(G.state == GRAB_AGGRESSIVE)
					if(prob(25))
						L.visible_message("<span class='warning'>[L] has broken free of [G.assailant]'s grip!</span>")
						qdel(G)
				else
					if(G.state == GRAB_NECK)
						if(prob(5))
							L.visible_message("<span class='warning'>[L] has broken free of [G.assailant]'s headlock!</span>")
							qdel(G)
		if(resisting)
			L.visible_message("<span class='warning'>[L] resists!</span>")
			return

	//unbuckling yourself
	if(L.buckled && L.last_special <= world.time)
		if(iscarbon(L))
			var/mob/living/carbon/C = L
			if(C.handcuffed)
				C.changeNext_move(CLICK_CD_BREAKOUT)
				C.last_special = world.time + CLICK_CD_BREAKOUT
				C.visible_message("<span class='warning'>[C] attempts to unbuckle themself!</span>", \
							"<span class='notice'>You attempt to unbuckle yourself. (This will take around one minute and you need to stay still.)</span>")
				spawn(0)
					if(do_after(usr, 600))
						if(!C.buckled)
							return
						C.visible_message("<span class='danger'>[C] manages to unbuckle themself!</span>", \
											"<span class='notice'>You successfully unbuckle yourself.</span>")
						C.buckled.manual_unbuckle(C)
					else
						C << "<span class='warning'>You fail to unbuckle yourself!</span>"
			else
				L.buckled.manual_unbuckle(L)
		else
			L.buckled.manual_unbuckle(L)

	//Breaking out of a container (Locker, sleeper, cryo...)
	else if(loc && istype(loc, /obj) && !isturf(loc))
		if(L.stat == CONSCIOUS && !L.stunned && !L.weakened && !L.paralysis)
			var/obj/C = loc
			C.container_resist(L)

	//Stop drop and roll & Handcuffs
	else if(iscarbon(L))
		var/mob/living/carbon/CM = L
		if(CM.on_fire && CM.canmove)
			CM.fire_stacks -= 5
			CM.Weaken(3)
			CM.spin(32,2)
			CM.visible_message("<span class='danger'>[CM] rolls on the floor, trying to put themselves out!</span>", \
				"<span class='notice'>You stop, drop, and roll!</span>")
			sleep(30)
			if(fire_stacks <= 0)
				CM.visible_message("<span class='danger'>[CM] has successfully extinguished themselves!</span>", \
					"<span class='notice'>You extinguish yourself.</span>")
				ExtinguishMob()
			return
		if(CM.canmove && (CM.last_special <= world.time))
			if(CM.handcuffed || CM.legcuffed)
				CM.changeNext_move(CLICK_CD_BREAKOUT)
				CM.last_special = world.time + CLICK_CD_BREAKOUT
				if(CM.handcuffed)
					cuff_resist(CM.handcuffed, CM)
				else
					cuff_resist(CM.legcuffed, CM)

/mob/living/carbon/proc/spin(spintime, speed)
	spawn()
		var/D = dir
		while(spintime >= speed)
			sleep(speed)
			switch(D)
				if(NORTH)
					D = EAST
				if(SOUTH)
					D = WEST
				if(EAST)
					D = SOUTH
				if(WEST)
					D = NORTH
			dir = D
			spintime -= speed
	return

/mob/living/proc/get_visible_name()
	return name

/mob/living/proc/CheckStamina()
	if(staminaloss)
		var/total_health = (health - staminaloss)
		if(total_health <= config.health_threshold_crit && !stat)
			Exhaust()
			setStaminaLoss(health - 2)
			return
		setStaminaLoss(max((staminaloss - 2), 0))

/mob/living/proc/Exhaust()
	src << "<span class='notice'>You're too exhausted to keep going...</span>"
	Weaken(5)

/mob/living/update_gravity(has_gravity)
	if(!ticker)
		return
	float(!has_gravity)

/mob/living/proc/float(on)
	if(on && !floating)
		animate(src, pixel_y = 2, time = 10, loop = -1)
		floating = 1
	else if(!on && floating)
		animate(src, pixel_y = initial(pixel_y), time = 10)
		floating = 0

// The src mob is trying to strip an item from someone
// Override if a certain type of mob should be behave differently when stripping items (can't, for example)
/mob/living/stripPanelUnequip(obj/item/what, mob/who, where)
	if(what.flags & NODROP)
		src << "<span class='notice'>You can't remove \the [what.name], it appears to be stuck!</span>"
		return
	who.visible_message("<span class='danger'>[src] tries to remove [who]'s [what.name].</span>", \
					"<span class='userdanger'>[src] tries to remove [who]'s [what.name].</span>")
	what.add_fingerprint(src)
	if(do_mob(src, who, what.strip_delay))
		if(what && Adjacent(who))
			who.unEquip(what)
			add_logs(src, who, "stripped", addition="of [what]")

// The src mob is trying to place an item on someone
// Override if a certain mob should be behave differently when placing items (can't, for example)
/mob/living/stripPanelEquip(obj/item/what, mob/who, where)
	what = src.get_active_hand()
	if(what && (what.flags & NODROP))
		src << "<span class='notice'>You can't put \the [what.name] on [who], it's stuck to your hand!</span>"
		return
	if(what && what.mob_can_equip(who, where, 1))
		visible_message("<span class='notice'>[src] tries to put [what] on [who].</span>")
		if(do_mob(src, who, what.put_on_delay))
			if(what && Adjacent(who))
				src.unEquip(what)
				who.equip_to_slot_if_possible(what, where, 0, 1)
				add_logs(src, who, "equipped", object=what)

/mob/living/singularity_act()
	var/gain = 20
	investigate_log(" has consumed [key_name(src)].","singulo") //Oh that's where the clown ended up!
	gib()
	return(gain)

/mob/living/singularity_pull(S)
	step_towards(src,S)

/mob/living/proc/do_attack_animation(atom/A)
	var/pixel_x_diff = 0
	var/pixel_y_diff = 0
	var/direction = get_dir(src, A)
	switch(direction)
		if(NORTH)
			pixel_y_diff = 8
		if(SOUTH)
			pixel_y_diff = -8
		if(EAST)
			pixel_x_diff = 8
		if(WEST)
			pixel_x_diff = -8
		if(NORTHEAST)
			pixel_x_diff = 8
			pixel_y_diff = 8
		if(NORTHWEST)
			pixel_x_diff = -8
			pixel_y_diff = 8
		if(SOUTHEAST)
			pixel_x_diff = 8
			pixel_y_diff = -8
		if(SOUTHWEST)
			pixel_x_diff = -8
			pixel_y_diff = -8
	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff, time = 2)
	animate(pixel_x = initial(pixel_x), pixel_y = initial(pixel_y), time = 2)
	floating = 0 // If we were without gravity, the bouncing animation got stopped, so we make sure we restart the bouncing after the next movement.
