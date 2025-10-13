#define LAST_RESORT_EXPLOSION_RANGE 2
#define LAST_RESORT_BLIND_RANGE 4

/datum/action/changeling/headcrab
	name = "Last Resort"
	desc = "We sacrifice our current body in a moment of need, violently expanding to break through obstacles and reforming as a headslug. Costs 20 chemicals."
	helptext = "We will violently expand, destroying obstacles around us, then be placed in control of a small, fragile creature. We may attack a corpse like this to plant an egg which will slowly mature into a new form for us."
	button_icon_state = "last_resort"
	chemical_cost = 20
	dna_cost = 1
	req_stat = DEAD
	ignores_fakedeath = TRUE
	disabled_by_fire = FALSE

/datum/action/changeling/headcrab/can_be_used_by(mob/living/user)
	if(HAS_TRAIT(user, TRAIT_TEMPORARY_BODY))
		return FALSE
	if(isanimal_or_basicmob(user) && !istype(user, /mob/living/basic/headslug) && !isconstruct(user) && !(user.mob_biotypes & MOB_SPIRIT))
		return TRUE
	return ..()

/datum/action/changeling/headcrab/sting_action(mob/living/user)
	set waitfor = FALSE
	var/confirm = tgui_alert(user, "Are we sure we wish to destroy our body and create a headslug?", "Last Resort", list("Yes", "No"))
	if(active || confirm != "Yes")
		return
	active = TRUE
	..()
	user.visible_message(span_boldwarning("[user]'s body begins to pulsate and swell unnaturally!"))
	playsound(user, 'sound/effects/wounds/crack1.ogg', 100, TRUE)
	animate(user, transform = user.transform * 1.5, color = COLOR_RED, time = 1 SECONDS)
	if(is_walled(user))
		user.Immobilize(1.5 SECONDS) // to prevent the breaking of the wrong walls (who would think of using the antistun after the last resort)
		escaping_prison(user)
	addtimer(CALLBACK(src, PROC_REF(gibbing), user), 1.1 SECONDS)

/datum/action/changeling/headcrab/proc/gibbing(mob/living/user)
	if(QDELETED(user))
		active = FALSE
		return
	gore_explosion(user)

	var/datum/mind/stored_mind = user.mind
	var/list/organs = user.get_organs_for_zone(BODY_ZONE_HEAD, TRUE)
	var/turf/user_turf = get_turf(user)

	user.transfer_observers_to(user_turf) // user is about to be deleted, store orbiters on the turf
	if(user.stat != DEAD)
		user.investigate_log("has been gibbed by headslug burst.", INVESTIGATE_DEATHS)
	user.gib(DROP_ALL_REMAINS)
	addtimer(CALLBACK(src, PROC_REF(spawn_headcrab), stored_mind, user_turf, organs), 0.5 SECONDS) // without this delay the worm will be almost dead due to the explosion :(

/// Creates a light explosion, blinds and confuses mobs in range
/datum/action/changeling/headcrab/proc/gore_explosion(mob/living/user)
	var/list/user_DNA = user.get_blood_dna_list()
	user.visible_message(span_boldwarning("[user]'s body ruptures in a violent explosion of biomass!"))
	playsound(user, 'sound/effects/goresplat.ogg', 100, TRUE) //yuck!!
	explosion(user, light_impact_range = LAST_RESORT_EXPLOSION_RANGE, flame_range = 0, flash_range = 0, adminlog = TRUE, silent = TRUE, explosion_cause = src)
	user.spawn_gibs()

	for(var/turf/bloody_turf in view(LAST_RESORT_BLIND_RANGE, user))
		var/obj/effect/decal/cleanable/blood/blood_spot = new(bloody_turf)
		blood_spot.add_blood_DNA(user_DNA)

	for(var/mob/living/blinded in view(LAST_RESORT_BLIND_RANGE, user))
		if(blinded == user)
			continue
		blinded.visible_message(span_danger("[blinded] is splattered with blood!"), span_userdanger("You're splattered with blood!"))
		blinded.add_blood_DNA(user_DNA)
		playsound(blinded, 'sound/effects/splat.ogg', 50, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE)

		if(ishuman(blinded))
			var/mob/living/carbon/human/blinded_human = blinded
			var/obj/item/organ/eyes/eyes = blinded_human.get_organ_slot(ORGAN_SLOT_EYES)
			if(!eyes || blinded_human.is_blind())
				continue
			to_chat(blinded_human, span_userdanger("You are blinded by a shower of blood!"))
			blinded_human.Stun(4 SECONDS)
			blinded_human.set_eye_blur_if_lower(40 SECONDS)
			blinded_human.adjust_confusion(12 SECONDS)
		if(issilicon(blinded))
			var/mob/living/silicon/blinded_silicon = blinded
			to_chat(blinded_silicon, span_userdanger("Your sensors are disabled by a shower of blood!"))
			blinded_silicon.Paralyze(6 SECONDS)

/// Creates the headrab to occupy
/datum/action/changeling/headcrab/proc/spawn_headcrab(datum/mind/stored_mind, turf/spawn_location, list/organs)
	var/mob/living/basic/headslug/crab = new(spawn_location)
	for(var/obj/item/organ/I in organs)
		I.forceMove(crab)

	stored_mind.transfer_to(crab, force_key_move = TRUE)
	spawn_location.transfer_observers_to(crab)
	to_chat(crab, span_warning("We burst out of the remains of our former body in a shower of gore!"))
	active = FALSE

/// Ruptures nearby walls using the torn_wall component. Also it destroys objects with density.
/datum/action/changeling/headcrab/proc/escaping_prison(mob/living/user)
	user.visible_message(span_boldwarning("[user]'s expanding form begins crushing the surrounding obstacles!"))
	var/list/walls_to_destroy = list()

	for(var/turf/nearby_turf in range(1, user))
		if(iswallturf(nearby_turf))
			var/turf/closed/wall/nearby_wall = nearby_turf
			var/datum/component/torn_wall/torn_comp = nearby_wall.GetComponent(/datum/component/torn_wall)
			if(!torn_comp)
				nearby_wall.AddComponent(/datum/component/torn_wall, current_stage = 1)
			else
				torn_comp.current_stage = 1
			walls_to_destroy += nearby_wall
			continue
		for(var/obj/obj_obstacle in nearby_turf)
			if(!obj_obstacle.density || (obj_obstacle.resistance_flags & INDESTRUCTIBLE) || !obj_obstacle.anchored)
				continue
			if(obj_obstacle.uses_integrity)
				obj_obstacle.take_damage(300)

	addtimer(CALLBACK(src, PROC_REF(finalize_destruction), walls_to_destroy, user, user.loc), 1 SECONDS)

/// Completes the destruction of the walls after a 1-second delay for more drama
/datum/action/changeling/headcrab/proc/finalize_destruction(list/affected_walls, mob/living/user, atom/user_prev_loc)
	if(QDELETED(user) || (user.loc != user_prev_loc))
		active = FALSE
		return
	for(var/turf/closed/wall/wall in affected_walls)
		if(QDELETED(wall))
			continue
		wall.AddComponent(/datum/component/torn_wall)

/datum/action/changeling/headcrab/proc/is_walled(mob/living/user)
	var/turf/ling_turf = get_turf(user)
	if(!ling_turf)
		return FALSE
	var/blocked_directions

	for(var/dir in GLOB.cardinals)
		var/turf/neighbor = get_step(ling_turf, dir)
		if(!neighbor || neighbor.is_blocked_turf(exclude_mobs = TRUE))
			blocked_directions++
	return blocked_directions >= 3 //1x2 cage won't be able to contain linga

#undef LAST_RESORT_EXPLOSION_RANGE
#undef LAST_RESORT_BLIND_RANGE
