/* I am informed this was added by Giacom to reduce mob-stacking in escape pods.
It's sorta problematic atm due to the shuttle changes I am trying to do
Sorry Giacom. Please don't be mad :(
/mob/living/Life()
	..()
	var/area/A = get_area(loc)
	if(A && A.push_dir)
		push_mob_back(src, A.push_dir)
*/

/mob/living/New()
	. = ..()
	generateStaticOverlay()
	if(staticOverlays.len)
		for(var/mob/living/simple_animal/drone/D in player_list)
			if(D && D.seeStatic)
				if(D.staticChoice in staticOverlays)
					D.staticOverlays |= staticOverlays[D.staticChoice]
					D.client.images |= staticOverlays[D.staticChoice]
				else //no choice? force static
					D.staticOverlays |= staticOverlays["static"]
					D.client.images |= staticOverlays["static"]
	if(unique_name)
		name = "[name] ([rand(1, 1000)])"
		real_name = name

	faction |= "\ref[src]"


/mob/living/Destroy()
	..()

	for(var/mob/living/simple_animal/drone/D in player_list)
		for(var/image/I in staticOverlays)
			D.staticOverlays.Remove(I)
			D.client.images.Remove(I)
			qdel(I)
	staticOverlays.len = 0

	return QDEL_HINT_HARDDEL_NOW


/mob/living/proc/generateStaticOverlay()
	staticOverlays.Add(list("static", "blank", "letter"))
	var/image/staticOverlay = image(getStaticIcon(new/icon(icon,icon_state)), loc = src)
	staticOverlay.override = 1
	staticOverlays["static"] = staticOverlay

	staticOverlay = image(getBlankIcon(new/icon(icon, icon_state)), loc = src)
	staticOverlay.override = 1
	staticOverlays["blank"] = staticOverlay

	staticOverlay = getLetterImage(src)
	staticOverlay.override = 1
	staticOverlays["letter"] = staticOverlay


//Generic Bump(). Override MobBump() and ObjBump() instead of this.
/mob/living/Bump(atom/A, yes)
	if(..()) //we are thrown onto something
		return
	if (buckled || !yes || now_pushing)
		return
	if(ismob(A))
		var/mob/M = A
		if(MobBump(M))
			return
	if(isobj(A))
		var/obj/O = A
		if(ObjBump(O))
			return
	if(istype(A, /atom/movable))
		var/atom/movable/AM = A
		if(PushAM(AM))
			return

/mob/living/Bumped(atom/movable/AM)
	..()
	last_bumped = world.time

//Called when we bump onto a mob
/mob/living/proc/MobBump(mob/M)
	//Even if we don't push/swap places, we "touched" them, so spread fire
	spreadFire(M)

	if(now_pushing)
		return 1

	//Should stop you pushing a restrained person out of the way
	if(isliving(M))
		var/mob/living/L = M
		if((L.pulledby && L.restrained()) || L.grabbed_by.len)
			if(!(world.time % 5))
				src << "<span class='warning'>[L] is restrained, you cannot push past.</span>"
			return 1

		if(L.pulling)
			if(ismob(L.pulling))
				var/mob/P = L.pulling
				if(P.restrained())
					if(!(world.time % 5))
						src << "<span class='warning'>[L] is restraining [P], you cannot push past.</span>"
					return 1

	//switch our position with M
	//BubbleWrap: people in handcuffs are always switched around as if they were on 'help' intent to prevent a person being pulled from being seperated from their puller
	if((M.a_intent == "help" || M.restrained()) && (a_intent == "help" || restrained()) && M.canmove && canmove && !M.buckled && !M.buckled_mobs.len) // mutual brohugs all around!
		if(loc && !loc.Adjacent(M.loc))
			return 1
		now_pushing = 1
		var/oldloc = loc
		var/oldMloc = M.loc


		var/M_passmob = (M.pass_flags & PASSMOB) // we give PASSMOB to both mobs to avoid bumping other mobs during swap.
		var/src_passmob = (pass_flags & PASSMOB)
		M.pass_flags |= PASSMOB
		pass_flags |= PASSMOB

		M.Move(oldloc)
		Move(oldMloc)

		if(!src_passmob)
			pass_flags &= ~PASSMOB
		if(!M_passmob)
			M.pass_flags &= ~PASSMOB

		now_pushing = 0
		return 1

	//okay, so we didn't switch. but should we push?
	//not if he's not CANPUSH of course
	if(!(M.status_flags & CANPUSH))
		return 1
	//anti-riot equipment is also anti-push
	if(M.r_hand && (prob(M.r_hand.block_chance * 2)) && !istype(M.r_hand, /obj/item/clothing))
		return 1
	if(M.l_hand && (prob(M.l_hand.block_chance * 2)) && !istype(M.l_hand, /obj/item/clothing))
		return 1

//Called when we bump onto an obj
/mob/living/proc/ObjBump(obj/O)
	return

//Called when we want to push an atom/movable
/mob/living/proc/PushAM(atom/movable/AM)
	if(now_pushing)
		return 1
	if(!client && (mob_size < MOB_SIZE_SMALL))
		return
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

	if(istype(AM) && AM.Adjacent(src))
		start_pulling(AM)
	else
		stop_pulling()

//same as above
/mob/living/pointed(atom/A as mob|obj|turf in view())
	if(src.stat || !src.canmove || src.restrained())
		return 0
	if(src.status_flags & FAKEDEATH)
		return 0
	if(!..())
		return 0
	visible_message("<b>[src]</b> points to [A]")
	return 1

/mob/living/verb/succumb(whispered as null)
	set hidden = 1
	if (InCritical())
		src.attack_log += "[src] has [whispered ? "whispered his final words" : "succumbed to death"] with [round(health, 0.1)] points of health!"
		src.adjustOxyLoss(src.health - config.health_threshold_dead)
		updatehealth()
		if(!whispered)
			src << "<span class='notice'>You have given up life and succumbed to death.</span>"
		death()

/mob/living/proc/InCritical()
	return (src.health < 0 && src.health > -95 && stat == UNCONSCIOUS)

/mob/living/ex_act(severity, target)
	..()
	flash_eyes()

/mob/living/proc/updatehealth()
	if(status_flags & GODMODE)
		return
	health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss()
	update_stat()


//This proc is used for mobs which are affected by pressure to calculate the amount of pressure that actually
//affects them once clothing is factored in. ~Errorage
/mob/living/proc/calculate_affecting_pressure(pressure)
	return pressure


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

/mob/living/proc/adjustBruteLoss(amount, updating_health=1)
	if(status_flags & GODMODE)
		return 0
	bruteloss = Clamp(bruteloss + amount, 0, maxHealth*2)
	if(updating_health)
		updatehealth()

/mob/living/proc/getOxyLoss()
	return oxyloss

/mob/living/proc/adjustOxyLoss(amount, updating_health=1)
	if(status_flags & GODMODE)
		return 0
	oxyloss = Clamp(oxyloss + amount, 0, maxHealth*2)
	if(updating_health)
		updatehealth()

/mob/living/proc/setOxyLoss(amount, updating_health=1)
	if(status_flags & GODMODE)
		return 0
	oxyloss = amount
	if(updating_health)
		updatehealth()

/mob/living/proc/getToxLoss()
	return toxloss

/mob/living/proc/adjustToxLoss(amount, updating_health=1)
	if(status_flags & GODMODE)
		return 0
	toxloss = Clamp(toxloss + amount, 0, maxHealth*2)
	if(updating_health)
		updatehealth()

/mob/living/proc/setToxLoss(amount, updating_health=1)
	if(status_flags & GODMODE)
		return 0
	toxloss = amount
	if(updating_health)
		updatehealth()

/mob/living/proc/getFireLoss()
	return fireloss

/mob/living/proc/adjustFireLoss(amount, updating_health=1)
	if(status_flags & GODMODE)
		return 0
	fireloss = Clamp(fireloss + amount, 0, maxHealth*2)
	if(updating_health)
		updatehealth()

/mob/living/proc/getCloneLoss()
	return cloneloss

/mob/living/proc/adjustCloneLoss(amount, updating_health=1)
	if(status_flags & GODMODE)
		return 0
	cloneloss = Clamp(cloneloss + amount, 0, maxHealth*2)
	if(updating_health)
		updatehealth()

/mob/living/proc/setCloneLoss(amount, updating_health=1)
	if(status_flags & GODMODE)
		return 0
	cloneloss = amount
	if(updating_health)
		updatehealth()

/mob/living/proc/getBrainLoss()
	return brainloss

/mob/living/proc/adjustBrainLoss(amount)
	if(status_flags & GODMODE)
		return 0
	brainloss = Clamp(brainloss + amount, 0, maxHealth*2)

/mob/living/proc/setBrainLoss(amount)
	if(status_flags & GODMODE)
		return 0
	brainloss = amount

/mob/living/proc/getStaminaLoss()
	return staminaloss

/mob/living/proc/adjustStaminaLoss(amount, updating_stamina = 1)
	return

/mob/living/carbon/adjustStaminaLoss(amount, updating_stamina = 1)
	if(status_flags & GODMODE)
		return 0
	staminaloss = Clamp(staminaloss + amount, 0, maxHealth*2)
	if(updating_stamina)
		update_stamina()

/mob/living/carbon/alien/adjustStaminaLoss(amount, updating_stamina = 1)
	return

/mob/living/proc/setStaminaLoss(amount, updating_stamina = 1)
	return

/mob/living/carbon/setStaminaLoss(amount, updating_stamina = 1)
	if(status_flags & GODMODE)
		return 0
	staminaloss = amount
	if(updating_stamina)
		update_stamina()

/mob/living/carbon/alien/setStaminaLoss(amount, updating_stamina = 1)
	return

/mob/living/proc/getMaxHealth()
	return maxHealth

/mob/living/proc/setMaxHealth(newMaxHealth)
	maxHealth = newMaxHealth

// MOB PROCS //END

/mob/living/proc/mob_sleep()
	set name = "Sleep"
	set category = "IC"

	if(sleeping)
		src << "<span class='notice'>You are already sleeping.</span>"
		return
	else
		if(alert(src, "You sure you want to sleep for a while?", "Sleep", "Yes", "No") == "Yes")
			SetSleeping(20) //Short nap
	update_canmove()

/mob/proc/get_contents()

/mob/living/proc/lay_down()
	set name = "Rest"
	set category = "IC"

	resting = !resting
	src << "<span class='notice'>You are now [resting ? "resting" : "getting up"].</span>"
	update_canmove()

//Recursive function to find everything a mob is holding.
/mob/living/get_contents(obj/item/weapon/storage/Storage = null)
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
		for(var/obj/item/weapon/folder/F in src.contents)	//Check for folders
			L += F.contents
		return L

/mob/living/proc/check_contents_for(A)
	var/list/L = src.get_contents()

	for(var/obj/B in L)
		if(B.type == A)
			return 1
	return 0


/mob/living/proc/electrocute_act(shock_damage, obj/source, siemens_coeff = 1, safety = 0, tesla_shock = 0)
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
	var/t = shooter.zone_selected
	if ((t in list( "eyes", "mouth" )))
		t = "head"
	var/obj/item/organ/limb/def_zone = ran_zone(t)
	return def_zone

//damage/heal the mob ears and adjust the deaf amount
/mob/living/adjustEarDamage(damage, deaf)
	ear_damage = max(0, ear_damage + damage)
	ear_deaf = max(0, ear_deaf + deaf)

//pass a negative argument to skip one of the variable
/mob/living/setEarDamage(damage, deaf)
	if(damage >= 0)
		ear_damage = damage
	if(deaf >= 0)
		ear_deaf = deaf

// heal ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/heal_organ_damage(brute, burn, updating_health=1)
	adjustBruteLoss(-brute, updating_health)
	adjustFireLoss(-burn, updating_health)
	if(updating_health)
		updatehealth()

// damage ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/take_organ_damage(brute, burn, updating_health=1)
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	if(updating_health)
		updatehealth()

// heal MANY external organs, in random order
/mob/living/proc/heal_overall_damage(brute, burn, updating_health=1)
	adjustBruteLoss(-brute, updating_health)
	adjustFireLoss(-burn, updating_health)
	if(updating_health)
		updatehealth()

// damage MANY external organs, in random order
/mob/living/proc/take_overall_damage(brute, burn, updating_health=1)
	adjustBruteLoss(brute, updating_health)
	adjustFireLoss(burn, updating_health)
	if(updating_health)
		updatehealth()

//proc used to ressuscitate a mob
/mob/living/proc/revive(full_heal = 0, admin_revive = 0)
	if(full_heal)
		fully_heal(admin_revive)
	if(stat == DEAD && can_be_revived()) //in some cases you can't revive (e.g. no brain)
		dead_mob_list -= src
		living_mob_list += src
		suiciding = 0
		stat = UNCONSCIOUS //the mob starts unconscious,
		blind_eyes(1)
		updatehealth() //then we check if the mob should wake up.
		update_canmove()
		update_sight()
		reload_fullscreen()
		. = 1

//proc used to completely heal a mob.
/mob/living/proc/fully_heal(admin_revive = 0)
	setToxLoss(0, 0)
	setOxyLoss(0, 0)
	setCloneLoss(0, 0)
	setBrainLoss(0)
	setStaminaLoss(0, 0)
	SetParalysis(0, 0)
	SetStunned(0, 0)
	SetWeakened(0, 0)
	SetSleeping(0, 0)
	radiation = 0
	nutrition = NUTRITION_LEVEL_FED + 50
	bodytemperature = 310
	set_blindness(0)
	set_blurriness(0)
	set_eye_damage(0)
	cure_nearsighted()
	cure_blind()
	disabilities = 0
	ear_deaf = 0
	ear_damage = 0
	hallucination = 0
	heal_overall_damage(1000, 1000)
	ExtinguishMob()
	fire_stacks = 0
	updatehealth()
	update_canmove()


//proc called by revive(), to check if we can actually ressuscitate the mob (we don't want to revive him and have him instantly die again)
/mob/living/proc/can_be_revived()
	. = 1
	if(health <= config.health_threshold_dead)
		return 0

/mob/living/proc/update_damage_overlays()
	return

/mob/living/proc/Examine_OOC()
	set name = "Examine Meta-Info (OOC)"
	set category = "OOC"
	set src in view()

	if(config.allow_Metadata)
		if(client)
			src << "[src]'s Metainfo:<br>[client.prefs.metadata]"
		else
			src << "[src] does not have any stored infomation!"
	else
		src << "OOC Metadata is not supported by this server!"

	return

/mob/living/Move(atom/newloc, direct)
	if (buckled && buckled.loc != newloc) //not updating position
		if (!buckled.anchored)
			return buckled.Move(newloc, direct)
		else
			return 0

	if (restrained())
		stop_pulling()


	var/cuff_dragged = 0
	if (restrained())
		for(var/mob/living/M in range(1, src))
			if (M.pulling == src && !M.incapacitated())
				cuff_dragged = 1
	if (!cuff_dragged && pulling && !throwing && (get_dist(src, pulling) <= 1 || pulling.loc == loc))
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
					var/pull_ok = 1
					if (M.grabbed_by.len)
						if (prob(75))
							var/obj/item/weapon/grab/G = pick(M.grabbed_by)
							visible_message("<span class='danger'>[src] has pulled [G.affecting] from [G.assailant]'s grip.</span>")
							qdel(G)
						else
							pull_ok = 0
						if (M.grabbed_by.len)
							pull_ok = 0
					if (pull_ok)
						var/atom/movable/t = M.pulling
						M.stop_pulling()

						//this is the gay blood on floor shit -- Added back -- Skie
						if(M.lying && !M.buckled && (prob(M.getBruteLoss() / 2)))
							makeTrail(T, M)
						pulling.Move(T, get_dir(pulling, T))
						if(M)
							M.start_pulling(t)
				else
					if (pulling)
						pulling.Move(T, get_dir(pulling, T))
	else
		stop_pulling()
		. = ..()
	if (s_active && !(s_active in contents) && !(s_active.loc in contents))
		// It's ugly. But everything related to inventory/storage is. -- c0
		s_active.close(src)

/mob/living/movement_delay()
	. = ..()
	if(isturf(loc))
		var/turf/open/T = loc
		. += T.slowdown
	switch(m_intent)
		if("run")
			if(drowsyness > 0)
				. += 6
			. += config.run_speed
		if("walk")
			. += config.walk_speed

/mob/living/proc/makeTrail(turf/T, mob/living/M)
	if(!has_gravity(M))
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if((NOBLOOD in H.dna.species.specflags) || (!H.blood_max) || (H.bleedsuppress))
			return
	var/blood_exists = 0
	var/trail_type = M.getTrail()
	for(var/obj/effect/decal/cleanable/trail_holder/C in M.loc) //checks for blood splatter already on the floor
		blood_exists = 1
	if (istype(M.loc, /turf) && trail_type != null)
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
				if(M.has_dna()) //blood DNA
					var/mob/living/carbon/DNA_helper = M
					H.blood_DNA[DNA_helper.dna.unique_enzymes] = DNA_helper.dna.blood_type

/mob/living/proc/getTrail() //silicon and simple_animals don't get blood trails
    return null

/mob/living/verb/resist()
	set name = "Resist"
	set category = "IC"

	if(!isliving(src) || next_move > world.time || stat || weakened || stunned || paralysis)
		return
	changeNext_move(CLICK_CD_RESIST)

	//resisting grabs (as if it helps anyone...)
	if(!restrained())
		var/resisting = 0
		for(var/obj/O in requests)
			qdel(O)
			resisting++
		for(var/X in grabbed_by)
			var/obj/item/weapon/grab/G = X
			resisting++
			if(G.state == GRAB_PASSIVE)
				qdel(G)
			else
				if(G.state == GRAB_AGGRESSIVE)
					if(prob(25))
						visible_message("<span class='danger'>[src] has broken free of [G.assailant]'s grip!</span>")
						qdel(G)
				else
					if(G.state == GRAB_NECK)
						if(prob(5))
							visible_message("<span class='danger'>[src] has broken free of [G.assailant]'s headlock!</span>")
							qdel(G)
		if(resisting)
			visible_message("<span class='danger'>[src] resists!</span>")
			return

	//unbuckling yourself
	if(buckled && last_special <= world.time)
		resist_buckle()

	//Breaking out of a container (Locker, sleeper, cryo...)
	else if(isobj(loc))
		var/obj/C = loc
		C.container_resist(src)

	else if(canmove)
		if(on_fire)
			resist_fire() //stop, drop, and roll
		else if(last_special <= world.time)
			resist_restraints() //trying to remove cuffs.


/mob/living/proc/resist_buckle()
	buckled.user_unbuckle_mob(src,src)

/mob/living/proc/resist_fire()
	return

/mob/living/proc/resist_restraints()
	return

/mob/living/proc/get_visible_name()
	return name

/mob/living/update_gravity(has_gravity)
	if(!ticker || !ticker.mode)
		return
	if(has_gravity)
		clear_alert("weightless")
	else
		throw_alert("weightless", /obj/screen/alert/weightless)
	float(!has_gravity)

/mob/living/proc/float(on)
	if(throwing)
		return
	var/fixed = 0
	if(anchored || (buckled && buckled.anchored))
		fixed = 1
	if(on && !floating && !fixed)
		animate(src, pixel_y = pixel_y + 2, time = 10, loop = -1)
		floating = 1
	else if(((!on || fixed) && floating))
		animate(src, pixel_y = get_standard_pixel_y_offset(lying), time = 10)
		floating = 0

//called when the mob receives a bright flash
/mob/living/proc/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /obj/screen/fullscreen/flash)
	if(check_eye_prot() < intensity && (override_blindness_check || !(disabilities & BLIND)))
		overlay_fullscreen("flash", type)
		addtimer(src, "clear_fullscreen", 25, FALSE, "flash", 25)
		return 1

//this returns the mob's protection against eye damage (number between -1 and 2)
/mob/living/proc/check_eye_prot()
	return 0

//this returns the mob's protection against ear damage (0 or 1)
/mob/living/proc/check_ear_prot()
	return 0

// The src mob is trying to strip an item from someone
// Override if a certain type of mob should be behave differently when stripping items (can't, for example)
/mob/living/stripPanelUnequip(obj/item/what, mob/who, where)
	if(what.flags & NODROP)
		src << "<span class='warning'>You can't remove \the [what.name], it appears to be stuck!</span>"
		return
	who.visible_message("<span class='danger'>[src] tries to remove [who]'s [what.name].</span>", \
					"<span class='userdanger'>[src] tries to remove [who]'s [what.name].</span>")
	what.add_fingerprint(src)
	if(do_mob(src, who, what.strip_delay))
		if(what && what == who.get_item_by_slot(where) && Adjacent(who))
			who.unEquip(what)
			add_logs(src, who, "stripped", addition="of [what]")

// The src mob is trying to place an item on someone
// Override if a certain mob should be behave differently when placing items (can't, for example)
/mob/living/stripPanelEquip(obj/item/what, mob/who, where)
	what = src.get_active_hand()
	if(what && (what.flags & NODROP))
		src << "<span class='warning'>You can't put \the [what.name] on [who], it's stuck to your hand!</span>"
		return
	if(what)
		if(!what.mob_can_equip(who, where, 1))
			src << "<span class='warning'>\The [what.name] doesn't fit in that place!</span>"
			return
		visible_message("<span class='notice'>[src] tries to put [what] on [who].</span>")
		if(do_mob(src, who, what.put_on_delay))
			if(what && Adjacent(who))
				unEquip(what)
				who.equip_to_slot_if_possible(what, where, 0, 1)
				add_logs(src, who, "equipped", what)

/mob/living/singularity_act()
	var/gain = 20
	investigate_log("([key_name(src)]) has been consumed by the singularity.","singulo") //Oh that's where the clown ended up!
	gib()
	return(gain)

/mob/living/singularity_pull(S, current_size)
	if(current_size >= STAGE_SIX)
		throw_at_fast(S,14,3, spin=1)
	else
		step_towards(src,S)

/mob/living/narsie_act()
	if(client)
		makeNewConstruct(/mob/living/simple_animal/hostile/construct/harvester, src, null, 0)
	else
		new /mob/living/simple_animal/hostile/construct/harvester/hostile(get_turf(src))
	spawn_dust()
	gib()
	return


/atom/movable/proc/do_attack_animation(atom/A, end_pixel_y)
	var/pixel_x_diff = 0
	var/pixel_y_diff = 0
	var/final_pixel_y = initial(pixel_y)
	if(end_pixel_y)
		final_pixel_y = end_pixel_y

	var/direction = get_dir(src, A)
	if(direction & NORTH)
		pixel_y_diff = 8
	else if(direction & SOUTH)
		pixel_y_diff = -8

	if(direction & EAST)
		pixel_x_diff = 8
	else if(direction & WEST)
		pixel_x_diff = -8

	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff, time = 2)
	animate(pixel_x = initial(pixel_x), pixel_y = final_pixel_y, time = 2)


/mob/living/do_attack_animation(atom/A)
	var/final_pixel_y = get_standard_pixel_y_offset(lying)
	..(A, final_pixel_y)
	floating = 0 // If we were without gravity, the bouncing animation got stopped, so we make sure we restart the bouncing after the next movement.

	// What icon do we use for the attack?
	var/image/I
	if(hand && l_hand) // Attacked with item in left hand.
		I = image(l_hand.icon, A, l_hand.icon_state, A.layer + 1)
	else if(!hand && r_hand) // Attacked with item in right hand.
		I = image(r_hand.icon, A, r_hand.icon_state, A.layer + 1)
	else // Attacked with a fist?
		return

	// Who can see the attack?
	var/list/viewing = list()
	for(var/mob/M in viewers(A))
		if(M.client)
			viewing |= M.client
	flick_overlay(I, viewing, 5) // 5 ticks/half a second

	// Scale the icon.
	I.transform *= 0.75
	// The icon should not rotate.
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

	// Set the direction of the icon animation.
	var/direction = get_dir(src, A)
	if(direction & NORTH)
		I.pixel_y = -16
	else if(direction & SOUTH)
		I.pixel_y = 16

	if(direction & EAST)
		I.pixel_x = -16
	else if(direction & WEST)
		I.pixel_x = 16

	if(!direction) // Attacked self?!
		I.pixel_z = 16

	// And animate the attack!
	animate(I, alpha = 175, pixel_x = 0, pixel_y = 0, pixel_z = 0, time = 3)

/mob/living/proc/do_jitter_animation(jitteriness)
	var/amplitude = min(4, (jitteriness/100) + 1)
	var/pixel_x_diff = rand(-amplitude, amplitude)
	var/pixel_y_diff = rand(-amplitude/3, amplitude/3)
	var/final_pixel_x = get_standard_pixel_x_offset(lying)
	var/final_pixel_y = get_standard_pixel_y_offset(lying)
	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff , time = 2, loop = 6)
	animate(pixel_x = final_pixel_x , pixel_y = final_pixel_y , time = 2)
	floating = 0 // If we were without gravity, the bouncing animation got stopped, so we make sure to restart it in next life().

/mob/living/proc/get_temperature(datum/gas_mixture/environment)
	var/loc_temp = T0C
	if(istype(loc, /obj/mecha))
		var/obj/mecha/M = loc
		loc_temp =  M.return_temperature()

	else if(istype(loc, /obj/structure/transit_tube_pod))
		loc_temp = environment.temperature

	else if(istype(get_turf(src), /turf/open/space))
		var/turf/heat_turf = get_turf(src)
		loc_temp = heat_turf.temperature

	else if(istype(loc, /obj/machinery/atmospherics/components/unary/cryo_cell))
		var/obj/machinery/atmospherics/components/unary/cryo_cell/C = loc
		var/datum/gas_mixture/G = C.AIR1

		if(G.total_moles() < 10)
			loc_temp = environment.temperature
		else
			loc_temp = G.temperature

	else
		loc_temp = environment.temperature

	return loc_temp

/mob/living/proc/get_standard_pixel_x_offset(lying = 0)
	return initial(pixel_x)

/mob/living/proc/get_standard_pixel_y_offset(lying = 0)
	return initial(pixel_y)

/mob/living/Stat()
	..()
	if(statpanel("Status"))
		if(ticker)
			if(ticker.mode)
				for(var/datum/gang/G in ticker.mode.gangs)
					if(isnum(G.dom_timer))
						stat(null, "[G.name] Gang Takeover: [max(G.dom_timer, 0)]")

/mob/living/cancel_camera()
	..()
	cameraFollow = null

/mob/living/proc/can_track(mob/living/user)
	//basic fast checks go first. When overriding this proc, I recommend calling ..() at the end.
	var/turf/T = get_turf(src)
	if(!T)
		return 0
	if(T.z == ZLEVEL_CENTCOM) //dont detect mobs on centcomm
		return 0
	if(T.z >= ZLEVEL_SPACEMAX)
		return 0
	if(user != null && src == user)
		return 0
	if(invisibility || alpha == 0)//cloaked
		return 0
	if(digitalcamo || digitalinvis)
		return 0

	// Now, are they viewable by a camera? (This is last because it's the most intensive check)
	if(!near_camera(src))
		return 0

	return 1

//used in datum/reagents/reaction() proc
/mob/living/proc/get_permeability_protection()
	return 0

/mob/living/proc/harvest(mob/living/user)
	if(qdeleted(src))
		return
	if(butcher_results)
		for(var/path in butcher_results)
			for(var/i = 1; i <= butcher_results[path];i++)
				new path(src.loc)
			butcher_results.Remove(path) //In case you want to have things like simple_animals drop their butcher results on gib, so it won't double up below.
	visible_message("<span class='notice'>[user] butchers [src].</span>")
	gib()

/mob/living/canUseTopic(atom/movable/M, be_close = 0, no_dextery = 0)
	if(incapacitated())
		return
	if(no_dextery)
		if(be_close && in_range(M, src))
			return 1
	else
		src << "<span class='warning'>You don't have the dexterity to do this!</span>"
	return
/mob/living/proc/can_use_guns(var/obj/item/weapon/gun/G)
	if (G.trigger_guard != TRIGGER_GUARD_ALLOW_ALL && !IsAdvancedToolUser())
		src << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return 0
	return 1

/mob/living/carbon/proc/update_stamina()
	return

/mob/living/carbon/human/update_stamina()
	if(staminaloss)
		var/total_health = (health - staminaloss)
		if(total_health <= config.health_threshold_crit && !stat)
			src << "<span class='notice'>You're too exhausted to keep going...</span>"
			Weaken(5)
			setStaminaLoss(health - 2)
	update_health_hud()

/mob/proc/update_sight()
	return

/mob/proc/blind_eyes(amount)
	if(amount>0)
		var/old_eye_blind = eye_blind
		eye_blind = max(eye_blind, amount)
		if(!old_eye_blind)
			throw_alert("blind", /obj/screen/alert/blind)
			overlay_fullscreen("blind", /obj/screen/fullscreen/blind)

/mob/proc/adjust_blindness(amount)
	if(amount>0)
		var/old_eye_blind = eye_blind
		eye_blind += amount
		if(!old_eye_blind)
			throw_alert("blind", /obj/screen/alert/blind)
			overlay_fullscreen("blind", /obj/screen/fullscreen/blind)
	else if(eye_blind)
		var/blind_minimum = 0
		if(stat != CONSCIOUS || (disabilities & BLIND))
			blind_minimum = 1
		eye_blind = max(eye_blind+amount, blind_minimum)
		if(!eye_blind)
			clear_alert("blind")
			clear_fullscreen("blind")

/mob/proc/set_blindness(amount)
	if(amount>0)
		var/old_eye_blind = eye_blind
		eye_blind = amount
		if(client && !old_eye_blind)
			throw_alert("blind", /obj/screen/alert/blind)
			overlay_fullscreen("blind", /obj/screen/fullscreen/blind)
	else if(eye_blind)
		var/blind_minimum = 0
		if(stat != CONSCIOUS || (disabilities & BLIND))
			blind_minimum = 1
		eye_blind = blind_minimum
		if(!eye_blind)
			clear_alert("blind")
			clear_fullscreen("blind")

/mob/proc/blur_eyes(amount)
	if(amount>0)
		var/old_eye_blurry = eye_blurry
		eye_blurry = max(amount, eye_blurry)
		if(!old_eye_blurry)
			overlay_fullscreen("blurry", /obj/screen/fullscreen/blurry)

/mob/proc/adjust_blurriness(amount)
	var/old_eye_blurry = eye_blurry
	eye_blurry = max(eye_blurry+amount, 0)
	if(amount>0)
		if(!old_eye_blurry)
			overlay_fullscreen("blurry", /obj/screen/fullscreen/blurry)
	else if(old_eye_blurry && !eye_blurry)
		clear_fullscreen("blurry")

/mob/proc/set_blurriness(amount)
	var/old_eye_blurry = eye_blurry
	eye_blurry = max(amount, 0)
	if(amount>0)
		if(!old_eye_blurry)
			overlay_fullscreen("blurry", /obj/screen/fullscreen/blurry)
	else if(old_eye_blurry)
		clear_fullscreen("blurry")


/mob/proc/damage_eyes(amount)
	return

/mob/living/carbon/damage_eyes(amount)
	if(amount>0)
		eye_damage = amount
		if(eye_damage > 20)
			if(eye_damage > 30)
				overlay_fullscreen("eye_damage", /obj/screen/fullscreen/impaired, 2)
			else
				overlay_fullscreen("eye_damage", /obj/screen/fullscreen/impaired, 1)


/mob/proc/set_eye_damage(amount)
	return

/mob/living/carbon/set_eye_damage(amount)
	eye_damage = max(amount,0)
	if(eye_damage > 20)
		if(eye_damage > 30)
			overlay_fullscreen("eye_damage", /obj/screen/fullscreen/impaired, 2)
		else
			overlay_fullscreen("eye_damage", /obj/screen/fullscreen/impaired, 1)
	else
		clear_fullscreen("eye_damage")

/mob/proc/adjust_eye_damage(amount)
	return

/mob/living/carbon/adjust_eye_damage(amount)
	eye_damage = max(eye_damage+amount, 0)
	if(eye_damage > 20)
		if(eye_damage > 30)
			overlay_fullscreen("eye_damage", /obj/screen/fullscreen/impaired, 2)
		else
			overlay_fullscreen("eye_damage", /obj/screen/fullscreen/impaired, 1)
	else
		clear_fullscreen("eye_damage")

/mob/proc/adjust_drugginess(amount)
	return

/mob/living/carbon/adjust_drugginess(amount)
	var/old_druggy = druggy
	if(amount>0)
		druggy += amount
		if(!old_druggy)
			overlay_fullscreen("high", /obj/screen/fullscreen/high)
			throw_alert("high", /obj/screen/alert/high)
	else if(old_druggy)
		druggy = max(druggy+amount, 0)
		if(!druggy)
			clear_fullscreen("high")
			clear_alert("high")

/mob/proc/set_drugginess(amount)
	return

/mob/living/carbon/set_drugginess(amount)
	var/old_druggy = druggy
	druggy = amount
	if(amount>0)
		if(!old_druggy)
			overlay_fullscreen("high", /obj/screen/fullscreen/high)
			throw_alert("high", /obj/screen/alert/high)
	else if(old_druggy)
		clear_fullscreen("high")
		clear_alert("high")

/mob/proc/cure_blind() //when we want to cure the BLIND disability only.
	return

/mob/living/carbon/cure_blind()
	if(disabilities & BLIND)
		disabilities &= ~BLIND
		adjust_blindness(-1)
		return 1

/mob/proc/cure_nearsighted()
	return

/mob/living/carbon/cure_nearsighted()
	if(disabilities & NEARSIGHT)
		disabilities &= ~NEARSIGHT
		clear_fullscreen("nearsighted")
		return 1

/mob/proc/become_nearsighted()
	return

/mob/living/carbon/become_nearsighted()
	if(!(disabilities & NEARSIGHT))
		disabilities |= NEARSIGHT
		overlay_fullscreen("nearsighted", /obj/screen/fullscreen/impaired, 1)
		return 1

/mob/proc/become_blind()
	return

/mob/living/carbon/become_blind()
	if(!(disabilities & BLIND))
		disabilities |= BLIND
		blind_eyes(1)
		return 1
