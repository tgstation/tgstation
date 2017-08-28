/mob/living/Initialize()
	. = ..()
	generateStaticOverlay()
	if(staticOverlays.len)
		for(var/mob/living/simple_animal/drone/D in GLOB.player_list)
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
	var/datum/atom_hud/data/human/medical/advanced/medhud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medhud.add_to_hud(src)
	faction += "\ref[src]"


/mob/living/prepare_huds()
	..()
	prepare_data_huds()

/mob/living/proc/prepare_data_huds()
	med_hud_set_health()
	med_hud_set_status()

/mob/living/Destroy()
	if(LAZYLEN(status_effects))
		for(var/s in status_effects)
			var/datum/status_effect/S = s
			if(S.on_remove_on_mob_delete) //the status effect calls on_remove when its mob is deleted
				qdel(S)
			else
				S.be_replaced()
	if(ranged_ability)
		ranged_ability.remove_ranged_ability(src)
	if(buckled)
		buckled.unbuckle_mob(src,force=1)
	QDEL_NULL(riding_datum)

	for(var/mob/living/simple_animal/drone/D in GLOB.player_list)
		for(var/image/I in staticOverlays)
			D.staticOverlays.Remove(I)
			D.client.images.Remove(I)
			qdel(I)
	staticOverlays.len = 0
	remove_from_all_data_huds()

	return ..()

/mob/living/ghostize(can_reenter_corpse = 1)
	var/prev_client = client
	. = ..()
	if(.)
		if(ranged_ability && prev_client)
			ranged_ability.remove_mousepointer(prev_client)


/mob/living/proc/OpenCraftingMenu()
	return

/mob/living/proc/generateStaticOverlay()
	staticOverlays.Add(list("static", "blank", "letter", "animal"))
	var/image/staticOverlay = image(getStaticIcon(new/icon(icon,icon_state)), loc = src)
	staticOverlay.override = 1
	staticOverlays["static"] = staticOverlay

	staticOverlay = image(getBlankIcon(new/icon(icon, icon_state)), loc = src)
	staticOverlay.override = 1
	staticOverlays["blank"] = staticOverlay

	staticOverlay = getLetterImage(src)
	staticOverlay.override = 1
	staticOverlays["letter"] = staticOverlay

	staticOverlay = getRandomAnimalImage(src)
	staticOverlay.override = 1
	staticOverlays["animal"] = staticOverlay


//Generic Collide(). Override MobCollide() and ObjCollide() instead of this.
/mob/living/Collide(atom/A)
	if(..()) //we are thrown onto something
		return
	if (buckled || now_pushing)
		return
	if(ismob(A))
		var/mob/M = A
		if(MobCollide(M))
			return
	if(isobj(A))
		var/obj/O = A
		if(ObjCollide(O))
			return
	if(ismovableatom(A))
		var/atom/movable/AM = A
		if(PushAM(AM))
			return

/mob/living/CollidedWith(atom/movable/AM)
	..()
	last_bumped = world.time

//Called when we bump onto a mob
/mob/living/proc/MobCollide(mob/M)
	//Even if we don't push/swap places, we "touched" them, so spread fire
	spreadFire(M)

	if(now_pushing)
		return 1

	//Should stop you pushing a restrained person out of the way
	if(isliving(M))
		var/mob/living/L = M
		if(L.pulledby && L.pulledby != src && L.restrained())
			if(!(world.time % 5))
				to_chat(src, "<span class='warning'>[L] is restrained, you cannot push past.</span>")
			return 1

		if(L.pulling)
			if(ismob(L.pulling))
				var/mob/P = L.pulling
				if(P.restrained())
					if(!(world.time % 5))
						to_chat(src, "<span class='warning'>[L] is restraining [P], you cannot push past.</span>")
					return 1

	if(moving_diagonally)//no mob swap during diagonal moves.
		return 1

	if(!M.buckled && !M.has_buckled_mobs())
		var/mob_swap
		//the puller can always swap with its victim if on grab intent
		if(M.pulledby == src && a_intent == INTENT_GRAB)
			mob_swap = 1
		//restrained people act if they were on 'help' intent to prevent a person being pulled from being separated from their puller
		else if((M.restrained() || M.a_intent == INTENT_HELP) && (restrained() || a_intent == INTENT_HELP))
			mob_swap = 1
		if(mob_swap)
			//switch our position with M
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
	for(var/obj/item/I in M.held_items)
		if(!istype(M, /obj/item/clothing))
			if(prob(I.block_chance*2))
				return 1

//Called when we bump onto an obj
/mob/living/proc/ObjCollide(obj/O)
	return

//Called when we want to push an atom/movable
/mob/living/proc/PushAM(atom/movable/AM)
	if(now_pushing)
		return 1
	if(moving_diagonally)// no pushing during diagonal moves.
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
		var/current_dir
		if(isliving(AM))
			current_dir = AM.dir
		step(AM, t)
		if(current_dir)
			AM.setDir(current_dir)
		now_pushing = 0

//mob verbs are a lot faster than object verbs
//for more info on why this is not atom/pull, see examinate() in mob.dm
/mob/living/verb/pulled(atom/movable/AM as mob|obj in oview(1))
	set name = "Pull"
	set category = "Object"

	if(istype(AM) && Adjacent(AM))
		start_pulling(AM)
	else
		stop_pulling()

//same as above
/mob/living/pointed(atom/A as mob|obj|turf in view())
	if(incapacitated())
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
		src.log_message("Has [whispered ? "whispered his final words" : "succumbed to death"] with [round(health, 0.1)] points of health!", INDIVIDUAL_ATTACK_LOG)
		src.adjustOxyLoss(src.health - HEALTH_THRESHOLD_DEAD)
		updatehealth()
		if(!whispered)
			to_chat(src, "<span class='notice'>You have given up life and succumbed to death.</span>")
		death()

/mob/living/incapacitated(ignore_restraints, ignore_grab)
	if(stat || IsUnconscious() || IsStun() || IsKnockdown() || (!ignore_restraints && restrained(ignore_grab)))
		return 1

/mob/living/proc/InCritical()
	return (health < HEALTH_THRESHOLD_CRIT && health > HEALTH_THRESHOLD_DEAD && (stat == SOFT_CRIT || stat == UNCONSCIOUS))

/mob/living/proc/InFullCritical()
	return (health < HEALTH_THRESHOLD_FULLCRIT && health > HEALTH_THRESHOLD_DEAD && stat == UNCONSCIOUS)

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
	return temperature



/mob/living/proc/getMaxHealth()
	return maxHealth

/mob/living/proc/setMaxHealth(newMaxHealth)
	maxHealth = newMaxHealth

// MOB PROCS //END

/mob/living/proc/mob_sleep()
	set name = "Sleep"
	set category = "IC"

	if(IsSleeping())
		to_chat(src, "<span class='notice'>You are already sleeping.</span>")
		return
	else
		if(alert(src, "You sure you want to sleep for a while?", "Sleep", "Yes", "No") == "Yes")
			SetSleeping(400) //Short nap
	update_canmove()

/mob/proc/get_contents()

/mob/living/proc/lay_down()
	set name = "Rest"
	set category = "IC"

	resting = !resting
	to_chat(src, "<span class='notice'>You are now [resting ? "resting" : "getting up"].</span>")
	update_canmove()

//Recursive function to find everything a mob is holding.
/mob/living/get_contents(obj/item/storage/Storage = null)
	var/list/L = list()

	if(Storage) //If it called itself
		L += Storage.return_inv()
		return L
	else
		L += src.contents
		for(var/obj/item/storage/S in src.contents)	//Check for storage items
			L += get_contents(S)
		for(var/obj/item/clothing/under/U in src.contents)	//Check for jumpsuit accessories
			L += U.contents
		for(var/obj/item/folder/F in src.contents)	//Check for folders
			L += F.contents
		return L

/mob/living/proc/check_contents_for(A)
	var/list/L = src.get_contents()

	for(var/obj/B in L)
		if(B.type == A)
			return 1
	return 0

/mob/living/proc/can_inject()
	return 1

/mob/living/proc/get_organ_target()
	var/mob/shooter = src
	var/t = shooter.zone_selected
	if ((t in list( "eyes", "mouth" )))
		t = "head"
	var/def_zone = ran_zone(t)
	return def_zone


/mob/living/proc/updatehealth()
	if(status_flags & GODMODE)
		return
	health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss()
	update_stat()
	med_hud_set_health()
	med_hud_set_status()

//proc used to ressuscitate a mob
/mob/living/proc/revive(full_heal = 0, admin_revive = 0)
	if(full_heal)
		fully_heal(admin_revive)
	if(stat == DEAD && can_be_revived()) //in some cases you can't revive (e.g. no brain)
		GLOB.dead_mob_list -= src
		GLOB.living_mob_list += src
		suiciding = 0
		stat = UNCONSCIOUS //the mob starts unconscious,
		blind_eyes(1)
		updatehealth() //then we check if the mob should wake up.
		update_canmove()
		update_sight()
		clear_alert("not_enough_oxy")
		reload_fullscreen()
		. = 1
		if(mind)
			for(var/S in mind.spell_list)
				var/obj/effect/proc_holder/spell/spell = S
				spell.updateButtonIcon()

//proc used to completely heal a mob.
/mob/living/proc/fully_heal(admin_revive = 0)
	restore_blood()
	setToxLoss(0, 0) //zero as second argument not automatically call updatehealth().
	setOxyLoss(0, 0)
	setCloneLoss(0, 0)
	setBrainLoss(0)
	setStaminaLoss(0, 0)
	SetUnconscious(0, FALSE)
	set_disgust(0)
	SetStun(0, FALSE)
	SetKnockdown(0, FALSE)
	SetSleeping(0, FALSE)
	radiation = 0
	nutrition = NUTRITION_LEVEL_FED + 50
	bodytemperature = 310
	set_blindness(0)
	set_blurriness(0)
	set_eye_damage(0)
	cure_nearsighted()
	cure_blind()
	cure_husk()
	disabilities = 0
	hallucination = 0
	heal_overall_damage(100000, 100000, 0, 0, 1) //heal brute and burn dmg on both organic and robotic limbs, and update health right away.
	ExtinguishMob()
	fire_stacks = 0
	update_canmove()


//proc called by revive(), to check if we can actually ressuscitate the mob (we don't want to revive him and have him instantly die again)
/mob/living/proc/can_be_revived()
	. = 1
	if(health <= HEALTH_THRESHOLD_DEAD)
		return 0

/mob/living/proc/update_damage_overlays()
	return

/mob/living/proc/Examine_OOC()
	set name = "Examine Meta-Info (OOC)"
	set category = "OOC"
	set src in view()

	if(config.allow_Metadata)
		if(client)
			to_chat(src, "[src]'s Metainfo:<br>[client.prefs.metadata]")
		else
			to_chat(src, "[src] does not have any stored information!")
	else
		to_chat(src, "OOC Metadata is not supported by this server!")

	return

/mob/living/Move(atom/newloc, direct)
	if (buckled && buckled.loc != newloc) //not updating position
		if (!buckled.anchored)
			return buckled.Move(newloc, direct)
		else
			return 0

	var/atom/movable/pullee = pulling
	if(pullee && get_dist(src, pullee) > 1)
		stop_pulling()
	if(pullee && !isturf(pullee.loc) && pullee.loc != loc) //to be removed once all code that changes an object's loc uses forceMove().
		log_game("DEBUG:[src]'s pull on [pullee] wasn't broken despite [pullee] being in [pullee.loc]. Pull stopped manually.")
		stop_pulling()
	var/turf/T = loc
	. = ..()
	if(. && pulling && pulling == pullee) //we were pulling a thing and didn't lose it during our move.
		if(pulling.anchored)
			stop_pulling()
			return

		var/pull_dir = get_dir(src, pulling)
		if(get_dist(src, pulling) > 1 || ((pull_dir - 1) & pull_dir)) //puller and pullee more than one tile away or in diagonal position
			if(isliving(pulling))
				var/mob/living/M = pulling
				if(M.lying && !M.buckled && (prob(M.getBruteLoss()*200/M.maxHealth)))
					M.makeTrail(T)
			pulling.Move(T, get_dir(pulling, T)) //the pullee tries to reach our previous position
			if(pulling && get_dist(src, pulling) > 1) //the pullee couldn't keep up
				stop_pulling()

	if(pulledby && moving_diagonally != FIRST_DIAG_STEP && get_dist(src, pulledby) > 1)//separated from our puller and not in the middle of a diagonal move.
		pulledby.stop_pulling()

	if (s_active && !(CanReach(s_active,view_only = TRUE)))
		s_active.close(src)

/mob/living/movement_delay(ignorewalk = 0)
	. = ..()
	if(isopenturf(loc) && !is_flying())
		var/turf/open/T = loc
		. += T.slowdown
	if(ignorewalk)
		. += config.run_speed
	else
		switch(m_intent)
			if(MOVE_INTENT_RUN)
				if(drowsyness > 0)
					. += 6
				. += config.run_speed
			if(MOVE_INTENT_WALK)
				. += config.walk_speed

/mob/living/proc/makeTrail(turf/T)
	if(!has_gravity())
		return
	var/blood_exists = 0

	for(var/obj/effect/decal/cleanable/trail_holder/C in src.loc) //checks for blood splatter already on the floor
		blood_exists = 1
	if (isturf(src.loc))
		var/trail_type = getTrail()
		if(trail_type)
			var/brute_ratio = round(getBruteLoss()/maxHealth, 0.1)
			if(blood_volume && blood_volume > max(BLOOD_VOLUME_NORMAL*(1 - brute_ratio * 0.25), 0))//don't leave trail if blood volume below a threshold
				blood_volume = max(blood_volume - max(1, brute_ratio * 2), 0) 					//that depends on our brute damage.
				var/newdir = get_dir(T, src.loc)
				if(newdir != src.dir)
					newdir = newdir | src.dir
					if(newdir == 3) //N + S
						newdir = NORTH
					else if(newdir == 12) //E + W
						newdir = EAST
				if((newdir in GLOB.cardinals) && (prob(50)))
					newdir = turn(get_dir(T, src.loc), 180)
				if(!blood_exists)
					new /obj/effect/decal/cleanable/trail_holder(src.loc)
				for(var/obj/effect/decal/cleanable/trail_holder/TH in src.loc)
					if((!(newdir in TH.existing_dirs) || trail_type == "trails_1" || trail_type == "trails_2") && TH.existing_dirs.len <= 16) //maximum amount of overlays is 16 (all light & heavy directions filled)
						TH.existing_dirs += newdir
						TH.add_overlay(image('icons/effects/blood.dmi', trail_type, dir = newdir))
						TH.transfer_mob_blood_dna(src)

/mob/living/carbon/human/makeTrail(turf/T)
	if((NOBLOOD in dna.species.species_traits) || !bleed_rate || bleedsuppress)
		return
	..()

/mob/living/proc/getTrail()
	if(getBruteLoss() < 300)
		return pick("ltrails_1", "ltrails_2")
	else
		return pick("trails_1", "trails_2")

/mob/living/experience_pressure_difference(pressure_difference, direction, pressure_resistance_prob_delta = 0)
	if (client && client.move_delay >= world.time + world.tick_lag*2)
		pressure_resistance_prob_delta -= 30

	var/list/turfs_to_check = list()

	if (has_limbs)
		var/turf/T = get_step(src, angle2dir(dir2angle(direction)+90))
		if (T)
			turfs_to_check += T

		T = get_step(src, angle2dir(dir2angle(direction)-90))
		if (T)
			turfs_to_check += T

		for (var/t in turfs_to_check)
			T = t
			if (T.density)
				pressure_resistance_prob_delta -= 20
				continue
			for (var/atom/movable/AM in T)
				if (AM.density && AM.anchored)
					pressure_resistance_prob_delta -= 20
					break
	if(!force_moving)
		..(pressure_difference, direction, pressure_resistance_prob_delta)

/mob/living/verb/resist()
	set name = "Resist"
	set category = "IC"

	if(!isliving(src) || next_move > world.time || incapacitated(ignore_restraints = 1))
		return
	changeNext_move(CLICK_CD_RESIST)

	//resisting grabs (as if it helps anyone...)
	if(!restrained(ignore_grab = 1) && pulledby)
		visible_message("<span class='danger'>[src] resists against [pulledby]'s grip!</span>")
		resist_grab()
		add_logs(pulledby, src, "resisted grab")
		return

	//unbuckling yourself
	if(buckled && last_special <= world.time)
		resist_buckle()

	//Breaking out of a container (Locker, sleeper, cryo...)
	else if(isobj(loc))
		var/obj/C = loc
		C.container_resist(src)

	else if(has_status_effect(/datum/status_effect/freon))
		to_chat(src, "You start breaking out of the ice cube!")
		if(do_mob(src, src, 40))
			if(has_status_effect(/datum/status_effect/freon))
				to_chat(src, "You break out of the ice cube!")
				remove_status_effect(/datum/status_effect/freon)
				update_canmove()

	else if(canmove)
		if(on_fire)
			resist_fire() //stop, drop, and roll
		else if(last_special <= world.time)
			resist_restraints() //trying to remove cuffs.


/mob/proc/resist_grab(moving_resist)
	return 1 //returning 0 means we successfully broke free

/mob/living/resist_grab(moving_resist)
	. = 1
	if(pulledby.grab_state)
		if(prob(30/pulledby.grab_state))
			visible_message("<span class='danger'>[src] has broken free of [pulledby]'s grip!</span>")
			add_logs(pulledby, src, "broke grab")
			pulledby.stop_pulling()
			return 0
		if(moving_resist && client) //we resisted by trying to move
			client.move_delay = world.time + 20
	else
		pulledby.stop_pulling()
		return 0

/mob/living/proc/resist_buckle()
	buckled.user_unbuckle_mob(src,src)

/mob/living/proc/resist_fire()
	return

/mob/living/proc/resist_restraints()
	return

/mob/living/proc/get_visible_name()
	return name

/mob/living/update_gravity(has_gravity,override = 0)
	if(!SSticker.HasRoundStarted())
		return
	if(has_gravity)
		clear_alert("weightless")
	else
		throw_alert("weightless", /obj/screen/alert/weightless)
	if(!override)
		float(!has_gravity)

/mob/living/float(on)
	if(throwing)
		return
	var/fixed = 0
	if(anchored || (buckled && buckled.anchored))
		fixed = 1
	if(on && !floating && !fixed)
		animate(src, pixel_y = pixel_y + 2, time = 10, loop = -1)
		sleep(10)
		animate(src, pixel_y = pixel_y - 2, time = 10, loop = -1)
		floating = 1
	else if(((!on || fixed) && floating))
		animate(src, pixel_y = get_standard_pixel_y_offset(lying), time = 10)
		floating = 0

// The src mob is trying to strip an item from someone
// Override if a certain type of mob should be behave differently when stripping items (can't, for example)
/mob/living/stripPanelUnequip(obj/item/what, mob/who, where)
	if(what.flags_1 & NODROP_1)
		to_chat(src, "<span class='warning'>You can't remove \the [what.name], it appears to be stuck!</span>")
		return
	who.visible_message("<span class='danger'>[src] tries to remove [who]'s [what.name].</span>", \
					"<span class='userdanger'>[src] tries to remove [who]'s [what.name].</span>")
	what.add_fingerprint(src)
	if(do_mob(src, who, what.strip_delay))
		if(what && Adjacent(who))
			if(islist(where))
				var/list/L = where
				if(what == who.get_item_for_held_index(L[2]))
					if(who.dropItemToGround(what))
						add_logs(src, who, "stripped", addition="of [what]")
			if(what == who.get_item_by_slot(where))
				if(who.dropItemToGround(what))
					add_logs(src, who, "stripped", addition="of [what]")

// The src mob is trying to place an item on someone
// Override if a certain mob should be behave differently when placing items (can't, for example)
/mob/living/stripPanelEquip(obj/item/what, mob/who, where)
	what = src.get_active_held_item()
	if(what && (what.flags_1 & NODROP_1))
		to_chat(src, "<span class='warning'>You can't put \the [what.name] on [who], it's stuck to your hand!</span>")
		return
	if(what)
		var/list/where_list
		var/final_where

		if(islist(where))
			where_list = where
			final_where = where[1]
		else
			final_where = where

		if(!what.mob_can_equip(who, src, final_where, TRUE, TRUE))
			to_chat(src, "<span class='warning'>\The [what.name] doesn't fit in that place!</span>")
			return

		visible_message("<span class='notice'>[src] tries to put [what] on [who].</span>")
		if(do_mob(src, who, what.equip_delay_other))
			if(what && Adjacent(who) && what.mob_can_equip(who, src, final_where, TRUE, TRUE))
				if(temporarilyRemoveItemFromInventory(what))
					if(where_list)
						if(!who.put_in_hand(what, where_list[2]))
							what.forceMove(get_turf(who))
					else
						who.equip_to_slot(what, where, TRUE)

/mob/living/singularity_pull(S, current_size)
	if(current_size >= STAGE_SIX)
		throw_at(S,14,3, spin=1)
	else
		step_towards(src,S)

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

	else if(isspaceturf(get_turf(src)))
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
		if(SSticker && SSticker.mode)
			for(var/datum/gang/G in SSticker.mode.gangs)
				if(G.is_dominating)
					stat(null, "[G.name] Gang Takeover: [max(G.domination_time_remaining(), 0)]")
			if(istype(SSticker.mode, /datum/game_mode/blob))
				var/datum/game_mode/blob/B = SSticker.mode
				if(B.message_sent)
					stat(null, "Blobs to Blob Win: [GLOB.blobs_legit.len]/[B.blobwincount]")

/mob/living/cancel_camera()
	..()
	cameraFollow = null

/mob/living/proc/can_track(mob/living/user)
	//basic fast checks go first. When overriding this proc, I recommend calling ..() at the end.
	var/turf/T = get_turf(src)
	if(!T)
		return 0
	if(T.z == ZLEVEL_CENTCOM) //dont detect mobs on centcom
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
	if(QDELETED(src))
		return
	if(butcher_results)
		for(var/path in butcher_results)
			for(var/i = 1; i <= butcher_results[path];i++)
				new path(src.loc)
			butcher_results.Remove(path) //In case you want to have things like simple_animals drop their butcher results on gib, so it won't double up below.
	visible_message("<span class='notice'>[user] butchers [src].</span>")
	gib(0, 0, 1)

/mob/living/canUseTopic(atom/movable/M, be_close = 0, no_dextery = 0)
	if(incapacitated())
		return
	if(no_dextery)
		if(be_close && in_range(M, src))
			return 1
	else
		to_chat(src, "<span class='warning'>You don't have the dexterity to do this!</span>")
	return
/mob/living/proc/can_use_guns(obj/item/G)
	if (G.trigger_guard != TRIGGER_GUARD_ALLOW_ALL && !IsAdvancedToolUser())
		to_chat(src, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return FALSE
	return TRUE

/mob/living/carbon/proc/update_stamina()
	if(staminaloss)
		var/total_health = (health - staminaloss)
		if(total_health <= HEALTH_THRESHOLD_CRIT && !stat)
			to_chat(src, "<span class='notice'>You're too exhausted to keep going...</span>")
			Knockdown(100)
			setStaminaLoss(health - 2)
	update_health_hud()

/mob/living/carbon/alien/update_stamina()
	return

/mob/living/proc/owns_soul()
	if(mind)
		return mind.soulOwner == mind
	return TRUE

/mob/living/proc/return_soul()
	hellbound = 0
	if(mind)
		var/datum/antagonist/devil/devilInfo = mind.soulOwner.has_antag_datum(ANTAG_DATUM_DEVIL)
		if(devilInfo)//Not sure how this could be null, but let's just try anyway.
			devilInfo.remove_soul(mind)
		mind.soulOwner = mind

/mob/living/proc/has_bane(banetype)
	var/datum/antagonist/devil/devilInfo = is_devil(src)
	return devilInfo && banetype == devilInfo.bane

/mob/living/proc/check_weakness(obj/item/weapon, mob/living/attacker)
	if(mind && mind.has_antag_datum(ANTAG_DATUM_DEVIL))
		return check_devil_bane_multiplier(weapon, attacker)
	return 1

/mob/living/proc/check_acedia()
	if(src.mind && src.mind.objectives)
		for(var/datum/objective/sintouched/acedia/A in src.mind.objectives)
			return 1
	return 0

/mob/living/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback)
	stop_pulling()
	. = ..()

// Called when we are hit by a bolt of polymorph and changed
// Generally the mob we are currently in is about to be deleted
/mob/living/proc/wabbajack_act(mob/living/new_mob)
	new_mob.name = real_name
	new_mob.real_name = real_name

	if(mind)
		mind.transfer_to(new_mob)
	else
		new_mob.key = key

	for(var/para in hasparasites())
		var/mob/living/simple_animal/hostile/guardian/G = para
		G.summoner = new_mob
		G.Recall()
		to_chat(G, "<span class='holoparasite'>Your summoner has changed form!</span>")

/mob/living/proc/fakefireextinguish()
	return

/mob/living/proc/fakefire()
	return



//Mobs on Fire
/mob/living/proc/IgniteMob()
	if(fire_stacks > 0 && !on_fire)
		on_fire = 1
		src.visible_message("<span class='warning'>[src] catches fire!</span>", \
						"<span class='userdanger'>You're set on fire!</span>")
		src.set_light(3)
		throw_alert("fire", /obj/screen/alert/fire)
		update_fire()
		return TRUE
	return FALSE

/mob/living/proc/ExtinguishMob()
	if(on_fire)
		on_fire = 0
		fire_stacks = 0
		src.set_light(0)
		clear_alert("fire")
		update_fire()

/mob/living/proc/adjust_fire_stacks(add_fire_stacks) //Adjusting the amount of fire_stacks we have on person
	fire_stacks = Clamp(fire_stacks + add_fire_stacks, -20, 20)
	if(on_fire && fire_stacks <= 0)
		ExtinguishMob()

//Share fire evenly between the two mobs
//Called in MobCollide() and Crossed()
/mob/living/proc/spreadFire(mob/living/L)
	if(!istype(L))
		return
	var/L_old_on_fire = L.on_fire

	if(on_fire) //Only spread fire stacks if we're on fire
		fire_stacks /= 2
		L.fire_stacks += fire_stacks
		if(L.IgniteMob())
			log_game("[key_name(src)] bumped into [key_name(L)] and set them on fire")

	if(L_old_on_fire) //Only ignite us and gain their stacks if they were onfire before we bumped them
		L.fire_stacks /= 2
		fire_stacks += L.fire_stacks
		IgniteMob()

//Mobs on Fire end

// used by secbot and monkeys Crossed
/mob/living/proc/knockOver(var/mob/living/carbon/C)
	if(C.key) //save us from monkey hordes
		C.visible_message("<span class='warning'>[pick( \
						"[C] dives out of [src]'s way!", \
						"[C] stumbles over [src]!", \
						"[C] jumps out of [src]'s path!", \
						"[C] trips over [src] and falls!", \
						"[C] topples over [src]!", \
						"[C] leaps out of [src]'s way!")]</span>")
	C.Knockdown(40)

/mob/living/post_buckle_mob(mob/living/M)
	if(riding_datum)
		riding_datum.handle_vehicle_offsets()
		riding_datum.handle_vehicle_layer()

/mob/living/ConveyorMove()
	if((movement_type & FLYING) && !stat)
		return
	..()

/mob/living/can_be_pulled()
	return ..() && !(buckled && buckled.buckle_prevents_pull)

//Updates canmove, lying and icons. Could perhaps do with a rename but I can't think of anything to describe it.
//Robots, animals and brains have their own version so don't worry about them
/mob/living/proc/update_canmove()
	var/ko = IsKnockdown() || IsUnconscious() || stat || (status_flags & FAKEDEATH)
	var/chokehold = pulledby && pulledby.grab_state >= GRAB_NECK
	var/buckle_lying = !(buckled && !buckled.buckle_lying)
	var/has_legs = get_num_legs()
	var/has_arms = get_num_arms()
	var/ignore_legs = get_leg_ignore()
	if(ko || resting || has_status_effect(STATUS_EFFECT_STUN) || chokehold)
		drop_all_held_items()
		unset_machine()
		if(pulling)
			stop_pulling()
	else if(has_legs || ignore_legs)
		lying = 0

	if(buckled)
		lying = 90*buckle_lying
	else if(!lying)
		if(resting)
			fall()
		else if(ko || (!has_legs && !ignore_legs) || chokehold)
			fall(forced = 1)
	canmove = !(ko || resting || has_status_effect(STATUS_EFFECT_STUN) || has_status_effect(/datum/status_effect/freon) || chokehold || buckled || (!has_legs && !ignore_legs && !has_arms))
	density = !lying
	if(lying)
		if(layer == initial(layer)) //to avoid special cases like hiding larvas.
			layer = LYING_MOB_LAYER //so mob lying always appear behind standing mobs
	else
		if(layer == LYING_MOB_LAYER)
			layer = initial(layer)
	update_transform()
	if(!lying && lying_prev)
		if(client)
			client.move_delay = world.time + movement_delay()
	lying_prev = lying
	return canmove
