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
	//Even if we don't push/swap places, we "touched" them, so spread fire
	spreadFire(M)

	if(now_pushing)
		return 1

	//BubbleWrap: Should stop you pushing a restrained person out of the way
	if(istype(M, /mob/living))
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

		for(var/mob/living/simple_animal/slime/slime in view(1,M))
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
	if(!(M.status_flags & CANPUSH))
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
	visible_message("<b>[src]</b> points to [A]")
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
	if(client && !eye_blind)
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
	return pressure


//sort of a legacy burn method for /electrocute, /shock, and the e_chair
/mob/living/proc/burn_skin(burn_amount)
	if(istype(src, /mob/living/carbon/human))
		//world << "DEBUG: burn_skin(), mutations=[mutations]"
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
	handle_regular_status_updates() //we update our health right away.

/mob/living/proc/getOxyLoss()
	return oxyloss

/mob/living/proc/adjustOxyLoss(var/amount)
	if(status_flags & GODMODE)	return 0
	oxyloss = min(max(oxyloss + amount, 0),(maxHealth*2))
	handle_regular_status_updates()

/mob/living/proc/setOxyLoss(var/amount)
	if(status_flags & GODMODE)	return 0
	oxyloss = amount
	handle_regular_status_updates()

/mob/living/proc/getToxLoss()
	return toxloss

/mob/living/proc/adjustToxLoss(var/amount)
	if(status_flags & GODMODE)	return 0
	toxloss = min(max(toxloss + amount, 0),(maxHealth*2))
	handle_regular_status_updates()

/mob/living/proc/setToxLoss(var/amount)
	if(status_flags & GODMODE)	return 0
	toxloss = amount
	handle_regular_status_updates()

/mob/living/proc/getFireLoss()
	return fireloss

/mob/living/proc/adjustFireLoss(var/amount)
	if(status_flags & GODMODE)	return 0
	fireloss = min(max(fireloss + amount, 0),(maxHealth*2))
	handle_regular_status_updates() //we update our health right away.

/mob/living/proc/getCloneLoss()
	return cloneloss

/mob/living/proc/adjustCloneLoss(var/amount)
	if(status_flags & GODMODE)	return 0
	cloneloss = min(max(cloneloss + amount, 0),(maxHealth*2))
	handle_regular_status_updates()

/mob/living/proc/setCloneLoss(var/amount)
	if(status_flags & GODMODE)	return 0
	cloneloss = amount
	handle_regular_status_updates()

/mob/living/proc/getBrainLoss()
	return brainloss

/mob/living/proc/adjustBrainLoss(var/amount)
	if(status_flags & GODMODE)	return 0
	brainloss = min(max(brainloss + amount, 0),(maxHealth*2))
	handle_regular_status_updates()

/mob/living/proc/setBrainLoss(var/amount)
	if(status_flags & GODMODE)	return 0
	brainloss = amount
	handle_regular_status_updates() //we update our health right away.

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

/mob/living/proc/mob_sleep()
	set name = "Sleep"
	set category = "IC"

	if(sleeping)
		src << "<span class='notice'>You are already sleeping.</span>"
		return
	else
		if(alert(src, "You sure you want to sleep for a while?", "Sleep", "Yes", "No") == "Yes")
			sleeping = 20 //Short nap
	update_canmove()

/mob/proc/get_contents()

/mob/living/proc/lay_down()
	set name = "Rest"
	set category = "IC"

	resting = !resting
	src << "<span class='notice'>You are now [resting ? "resting" : "getting up"].</span>"
	update_canmove()

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
		for(var/obj/item/weapon/folder/F in src.contents)	//Check for folders
			L += F.contents
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

//damage/heal the mob ears and adjust the deaf amount
/mob/living/adjustEarDamage(var/damage, var/deaf)
	ear_damage = max(0, ear_damage + damage)
	ear_deaf = max(0, ear_deaf + deaf)

//pass a negative argument to skip one of the variable
/mob/living/setEarDamage(var/damage, var/deaf)
	if(damage >= 0)
		ear_damage = damage
	if(deaf >= 0)
		ear_deaf = deaf

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
	nutrition = NUTRITION_LEVEL_FED + 50
	bodytemperature = 310
	disabilities = 0
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
		for(var/obj/item/weapon/restraints/R in C.contents) //actually remove cuffs from inventory
			qdel(R)
		if(C.reagents)
			for(var/datum/reagent/R in C.reagents.reagent_list)
				C.reagents.clear_reagents()
			C.reagents.addiction_list = list()
	for(var/datum/disease/D in viruses)
		D.cure(0)
	if(stat == DEAD)
		dead_mob_list -= src
		living_mob_list += src
	stat = CONSCIOUS
	if(ishuman(src))
		var/mob/living/carbon/human/human_mob = src
		human_mob.restore_blood()
		human_mob.remove_all_embedded_objects()

	update_fire()
	regenerate_icons()

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
	if (buckled && buckled.loc != newloc)
		if (!buckled.anchored)
			return buckled.Move(newloc, direct)
		else
			return 0

	if (restrained())
		stop_pulling()


	var/cuff_dragged = 0
	if (restrained())
		for(var/mob/living/M in range(src, 1))
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
	if ((s_active && !( s_active in contents ) ))
		s_active.close(src)

	for(var/mob/living/simple_animal/slime/M in oview(1,src))
		M.UpdateFeed(src)

/mob/living/proc/makeTrail(var/turf/T, var/mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if((NOBLOOD in H.dna.species.specflags) || (!H.blood_max) || (H.bleedsuppress))
			return
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
				if(check_dna_integrity(M)) //blood DNA
					var/mob/living/carbon/DNA_helper = pulling
					H.blood_DNA[DNA_helper.dna.unique_enzymes] = DNA_helper.dna.blood_type

/mob/living/proc/getTrail() //silicon and simple_animals don't get blood trails
    return null

/mob/living/verb/resist()
	set name = "Resist"
	set category = "IC"

	if(!isliving(src) || next_move > world.time)
		return
	changeNext_move(CLICK_CD_RESIST)

	//resisting grabs (as if it helps anyone...)
	if(!stat && canmove && !restrained())
		var/resisting = 0
		for(var/obj/O in requests)
			qdel(O)
			resisting++
		for(var/obj/item/weapon/grab/G in grabbed_by)
			resisting++
			if(G.state == GRAB_PASSIVE)
				qdel(G)
			else
				if(G.state == GRAB_AGGRESSIVE)
					if(prob(25))
						visible_message("<span class='warning'>[src] has broken free of [G.assailant]'s grip!</span>")
						qdel(G)
				else
					if(G.state == GRAB_NECK)
						if(prob(5))
							visible_message("<span class='warning'>[src] has broken free of [G.assailant]'s headlock!</span>")
							qdel(G)
		if(resisting)
			visible_message("<span class='warning'>[src] resists!</span>")
			return

	//unbuckling yourself
	if(buckled && last_special <= world.time)
		resist_buckle()

	//Breaking out of a container (Locker, sleeper, cryo...)
	else if(loc && istype(loc, /obj) && !isturf(loc))
		if(stat == CONSCIOUS && !stunned && !weakened && !paralysis)
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
	if(!ticker)
		return
	if(has_gravity)
		clear_alert("weightless")
	else
		throw_alert("weightless")
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
		var/final_pixel_y = get_standard_pixel_y_offset(lying)
		animate(src, pixel_y = final_pixel_y, time = 10)
		floating = 0

//called when the mob receives a bright flash
/mob/living/proc/flash_eyes(intensity = 1, override_blindness_check = 0)
	if(check_eye_prot() < intensity && (override_blindness_check || !(disabilities & BLIND)))
		flick("e_flash", flash)
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
		if(what && Adjacent(who))
			who.unEquip(what)
			add_logs(src, who, "stripped", addition="of [what]")

// The src mob is trying to place an item on someone
// Override if a certain mob should be behave differently when placing items (can't, for example)
/mob/living/stripPanelEquip(obj/item/what, mob/who, where)
	what = src.get_active_hand()
	if(what && (what.flags & NODROP))
		src << "<span class='warning'>You can't put \the [what.name] on [who], it's stuck to your hand!</span>"
		return
	if(what && what.mob_can_equip(who, where, 1))
		visible_message("<span class='notice'>[src] tries to put [what] on [who].</span>")
		if(do_mob(src, who, what.put_on_delay))
			if(what && Adjacent(who))
				src.unEquip(what)
				who.equip_to_slot_if_possible(what, where, 0, 1)
				add_logs(src, who, "equipped", what)

/mob/living/singularity_act()
	var/gain = 20
	investigate_log("([key_name(src)]) has been consumed by the singularity.","singulo") //Oh that's where the clown ended up!
	gib()
	return(gain)

/mob/living/singularity_pull(S)
	step_towards(src,S)

/mob/living/narsie_act()
	if(client)
		makeNewConstruct(/mob/living/simple_animal/construct/harvester, src, null, 1)
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
	animate(pixel_x = initial(pixel_x), pixel_y = final_pixel_y, time = 2)


/mob/living/do_attack_animation(atom/A)
	var/final_pixel_y = get_standard_pixel_y_offset(lying)
	..(A, final_pixel_y)
	floating = 0 // If we were without gravity, the bouncing animation got stopped, so we make sure to restart it in next life().

	//Show an image of the wielded weapon over the person who got dunked.
	var/image/I
	if(hand)
		if(l_hand)
			I = image(l_hand.icon,A,l_hand.icon_state,A.layer+1)
	else
		if(r_hand)
			I = image(r_hand.icon,A,r_hand.icon_state,A.layer+1)
	if(I)
		var/list/viewing = list()
		for(var/mob/M in viewers(A))
			if(M.client)
				viewing |= M.client
		flick_overlay(I,viewing,5)
		I.pixel_z = 16 //lift it up...
		animate(I, pixel_z = 0, alpha = 125, time = 3) //smash it down into them!

/mob/living/proc/do_jitter_animation(jitteriness)
	var/amplitude = min(4, (jitteriness/100) + 1)
	var/pixel_x_diff = rand(-amplitude, amplitude)
	var/pixel_y_diff = rand(-amplitude/3, amplitude/3)
	var/final_pixel_x = get_standard_pixel_x_offset(lying)
	var/final_pixel_y = get_standard_pixel_y_offset(lying)
	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff , time = 2, loop = 6)
	animate(pixel_x = final_pixel_x , pixel_y = final_pixel_y , time = 2)
	floating = 0 // If we were without gravity, the bouncing animation got stopped, so we make sure to restart it in next life().

/mob/living/proc/get_temperature(var/datum/gas_mixture/environment)
	var/loc_temp = T0C
	if(istype(loc, /obj/mecha))
		var/obj/mecha/M = loc
		loc_temp =  M.return_temperature()

	else if(istype(loc, /obj/structure/transit_tube_pod))
		loc_temp = environment.temperature

	else if(istype(get_turf(src), /turf/space))
		var/turf/heat_turf = get_turf(src)
		loc_temp = heat_turf.temperature

	else if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
		var/obj/machinery/atmospherics/unary/cryo_cell/C = loc
		var/datum/gas_mixture/C_air_contents = C.airs[1]

		if(C_air_contents.total_moles() < 10)
			loc_temp = environment.temperature
		else
			loc_temp = C_air_contents.temperature

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
	if(digitalcamo)
		return 0

	// Now, are they viewable by a camera? (This is last because it's the most intensive check)
	if(!near_camera(src))
		return 0

	return 1

//used in datum/reagents/reaction() proc
/mob/living/proc/get_permeability_protection()
	return 0
