/// Battle hallucination, makes it sound like a melee or gun battle is going on in the background.
/datum/hallucination/battle
	abstract_hallucination_parent = /datum/hallucination/battle
	random_hallucination_weight = 3
	hallucination_tier = HALLUCINATION_TIER_COMMON

/// Subtype of battle hallucination for gun based battles, where it sounds like someone is being shot.
/datum/hallucination/battle/gun
	abstract_hallucination_parent = /datum/hallucination/battle/gun
	/// The lower end to how many shots we'll fire.
	var/shots_to_fire_lower_range = 3
	/// The upper end to how many shots we'll fire.
	var/shots_to_fire_upper_range = 6
	/// The sound effect we play when we "fire" a shot.
	var/fire_sound = 'sound/items/weapons/gun/shotgun/shot.ogg'
	/// The sound we make when our shot actually "hits" "someone".
	var/hit_person_sound = 'sound/items/weapons/pierce.ogg'
	/// The sound we make when our shot misses someone and "hits" a "wall".
	var/hit_wall_sound = SFX_RICOCHET
	/// The number of successful hits required to "down" the "someone" we're firing at.
	var/number_of_hits_to_end = 2
	/// The probability chance we have to make our "hit" person fall down after we pass the number_of_hits_to_end.
	var/chance_to_fall = 80

/datum/hallucination/battle/gun/start()
	fire_loop(random_far_turf(), rand(shots_to_fire_lower_range, shots_to_fire_upper_range))
	return TRUE

/// The main loop for gun based hallucinations.
/datum/hallucination/battle/gun/proc/fire_loop(turf/source, shots_left = 3, hits = 0)
	if(QDELETED(src) || QDELETED(hallucinator) || !source)
		return

	// We shoot our shot.
	hallucinator.playsound_local(source, fire_sound, 25, TRUE)

	// Shortly after shooting our shot, it plays a hit (or miss) sound.
	var/next_hit_sound = rand(0.5 SECONDS, 1 SECONDS)
	if(prob(50))
		addtimer(CALLBACK(hallucinator, TYPE_PROC_REF(/mob/, playsound_local), source, hit_person_sound, 25, TRUE), next_hit_sound)
		hits++
	else
		addtimer(CALLBACK(hallucinator, TYPE_PROC_REF(/mob/, playsound_local), source, hit_wall_sound, 25, TRUE), next_hit_sound)

	// If we scored enough hits, we have a chance to knock them down and stop the hallucination early.
	if(hits >= number_of_hits_to_end && prob(chance_to_fall))
		addtimer(CALLBACK(hallucinator, TYPE_PROC_REF(/mob/, playsound_local), source, SFX_BODYFALL, 25, TRUE), next_hit_sound)
		qdel(src)

	// Or, if we do have shots left, keep it going.
	else if(shots_left >= 0)
		shots_left--
		addtimer(CALLBACK(src, PROC_REF(fire_loop), source, shots_left, hits), rand(CLICK_CD_RANGE, CLICK_CD_RANGE + 6))

	// Otherwise, if we have no shots left, stop the hallucination.
	else
		qdel(src)


/// Gun battle hallucination that sounds like disabler fire.
/datum/hallucination/battle/gun/disabler
	shots_to_fire_lower_range = 5
	shots_to_fire_upper_range = 10
	fire_sound = 'sound/items/weapons/taser2.ogg'
	hit_person_sound = 'sound/items/weapons/tap.ogg'
	hit_wall_sound = 'sound/items/weapons/effects/searwall.ogg'
	number_of_hits_to_end = 3
	chance_to_fall = 70

/// Gun battle hallucination that sounds like laser fire.
/datum/hallucination/battle/gun/laser
	shots_to_fire_lower_range = 5
	shots_to_fire_upper_range = 10
	fire_sound = 'sound/items/weapons/laser.ogg'
	hit_person_sound = 'sound/items/weapons/sear.ogg'
	hit_wall_sound = 'sound/items/weapons/effects/searwall.ogg'
	number_of_hits_to_end = 4
	chance_to_fall = 70

/// A hallucination of someone being hit with a stun prod, followed by cable cuffing.
/datum/hallucination/battle/stun_prod

/datum/hallucination/battle/stun_prod/start()
	var/turf/source = random_far_turf()

	hallucinator.playsound_local(source, 'sound/items/weapons/egloves.ogg', 40, TRUE)
	hallucinator.playsound_local(source, SFX_BODYFALL, 25, TRUE)
	addtimer(CALLBACK(src, PROC_REF(fake_cuff), source), 2 SECONDS)
	return TRUE

/// Plays a fake cable-cuff sound and deletes the hallucination.
/datum/hallucination/battle/stun_prod/proc/fake_cuff(turf/source)
	if(QDELETED(src) || QDELETED(hallucinator) || !source)
		return

	hallucinator.playsound_local(source, 'sound/items/weapons/cablecuff.ogg', 15, TRUE)
	qdel(src)

/// A hallucination of someone being stun batonned, and subsequently harmbatonned.
/datum/hallucination/battle/harm_baton

/datum/hallucination/battle/harm_baton/start()
	var/turf/source = random_far_turf()

	hallucinator.playsound_local(source, 'sound/items/weapons/egloves.ogg', 40, TRUE)
	hallucinator.playsound_local(source, SFX_BODYFALL, 25, TRUE)

	addtimer(CALLBACK(src, PROC_REF(harmbaton_loop), source, rand(5, 12)), 2 SECONDS)
	return TRUE

/// The main sound loop for harmbatonning.
/datum/hallucination/battle/harm_baton/proc/harmbaton_loop(turf/source, hits_remaing = 5)
	if(QDELETED(src) || QDELETED(hallucinator) || !source)
		return

	hallucinator.playsound_local(source, SFX_SWING_HIT, 50, TRUE)
	hits_remaing--
	if(hits_remaing <= 0)
		qdel(src)

	else
		addtimer(CALLBACK(src, PROC_REF(harmbaton_loop), source, hits_remaing), rand(CLICK_CD_MELEE, CLICK_CD_MELEE + 4))

/// A hallucination of someone unsheathing an energy sword, going to town, and sheathing it again.
/datum/hallucination/battle/e_sword

/datum/hallucination/battle/e_sword/start()
	var/turf/source = random_far_turf()

	hallucinator.playsound_local(source, 'sound/items/weapons/saberon.ogg', 15, 1)
	addtimer(CALLBACK(src, PROC_REF(stab_loop), source, rand(4, 8)), CLICK_CD_MELEE)
	return TRUE

/// The main sound loop of someone being esworded.
/datum/hallucination/battle/e_sword/proc/stab_loop(turf/source, stabs_remaining = 4)
	if(QDELETED(src) || QDELETED(hallucinator) || !source)
		return

	if(stabs_remaining >= 1)
		hallucinator.playsound_local(source, 'sound/items/weapons/blade1.ogg', 50, TRUE)

	else
		hallucinator.playsound_local(source, 'sound/items/weapons/saberoff.ogg', 15, TRUE)
		qdel(src)
		return

	if(stabs_remaining == 4)
		hallucinator.playsound_local(source, SFX_BODYFALL, 25, TRUE)

	addtimer(CALLBACK(src, PROC_REF(stab_loop), source, stabs_remaining - 1), rand(CLICK_CD_MELEE, CLICK_CD_MELEE + 6))

/// A hallucination of a syndicate bomb ticking down.
/datum/hallucination/battle/bomb

/datum/hallucination/battle/bomb/start()
	addtimer(CALLBACK(src, PROC_REF(fake_tick), random_far_turf(), rand(3, 11)), 1.5 SECONDS)
	return TRUE

/// The loop of the (fake) bomb ticking down.
/datum/hallucination/battle/bomb/proc/fake_tick(turf/source, ticks_remaining = 3)
	if(QDELETED(src) || QDELETED(hallucinator) || !source)
		return

	hallucinator.playsound_local(source, 'sound/items/timer.ogg', 25, FALSE)
	ticks_remaining--
	if(ticks_remaining <= 0)
		qdel(src)

	else
		addtimer(CALLBACK(src, PROC_REF(fake_tick), source, ticks_remaining), 1.5 SECONDS)
