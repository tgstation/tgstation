#define LAST_RESORT_EXPLOSION_RANGE 2
#define LAST_RESORT_BLIND_RANGE 3

/datum/action/changeling/headcrab
	name = "Last Resort"
	desc = "We sacrifice our current body in a moment of need, violently expanding to break through obstacles and reforming as a headslug. Costs 20 chemicals."
	helptext = "We will violently expand, destroying weak walls around us, then be placed in control of a small, fragile creature. We may attack a corpse like this to plant an egg which will slowly mature into a new form for us."
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
	if(confirm != "Yes")
		return

	..()
	user.anchored = TRUE
	user.visible_message(span_boldwarning("[user]'s body begins to pulsate and swell unnaturally!"))
	playsound(user, 'sound/effects/wounds/crack1.ogg', 100, TRUE)
	animate(user, transform = user.transform * 1.5, color = COLOR_RED, time = 1 SECONDS)
	stoplag(1 SECONDS)
	if(is_walled(user))
		escaping_prison(user)
		stoplag(1.1 SECONDS)
	blood_explosion(user)

	var/datum/mind/stored_mind = user.mind
	var/list/organs = user.get_organs_for_zone(BODY_ZONE_HEAD, TRUE)
	var/turf/user_turf = get_turf(user)

	user.transfer_observers_to(user_turf) // user is about to be deleted, store orbiters on the turf
	if(user.stat != DEAD)
		user.investigate_log("has been gibbed by headslug burst.", INVESTIGATE_DEATHS)
	user.gib(DROP_ALL_REMAINS)
	addtimer(CALLBACK(src, PROC_REF(spawn_headcrab), stored_mind, user_turf, organs), 0.5 SECONDS) // without this delay the worm will be almost dead due to the limbs thrown at it from the explosion :(

/datum/action/changeling/headcrab/proc/blood_explosion(mob/living/user)
	user.visible_message(span_boldwarning("[user]'s body ruptures in a violent explosion of biomass!"))
	playsound(user, 'sound/effects/goresplat.ogg', 100, TRUE)
	explosion(user, light_impact_range = LAST_RESORT_EXPLOSION_RANGE, flame_range = 0, flash_range = 0, adminlog = TRUE, silent = TRUE, explosion_cause = src)
	var/view_range = view(LAST_RESORT_BLIND_RANGE, user)

	for(var/turf/bloody_turf in view_range)
		new /obj/effect/decal/cleanable/blood(bloody_turf)
		for(var/mob/living/mob_in_turf in bloody_turf)
			if(mob_in_turf == user)
				continue
			mob_in_turf.visible_message(span_danger("[mob_in_turf] is splattered with blood!"), span_userdanger("You're splattered with blood!"))
			mob_in_turf.add_blood_DNA(user.get_blood_dna_list())
			playsound(mob_in_turf, 'sound/effects/splat.ogg', 50, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE)

	for(var/mob/living/carbon/human/blinded_human in view_range)
		if(blinded_human == user)
			continue
		var/obj/item/organ/eyes/eyes = blinded_human.get_organ_slot(ORGAN_SLOT_EYES)
		if(!eyes || blinded_human.is_blind())
			continue
		to_chat(blinded_human, span_userdanger("You are blinded by a shower of blood!"))
		blinded_human.Stun(4 SECONDS)
		blinded_human.set_eye_blur_if_lower(40 SECONDS)
		blinded_human.adjust_confusion(12 SECONDS)

	for(var/mob/living/silicon/blinded_silicon in view_range)
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

/datum/action/changeling/headcrab/proc/escaping_prison(mob/living/user)
	user.visible_message(span_boldwarning("[user]'s expanding form begins crushing the surrounding walls!"))
	var/list/obstacles = list()
	var/list/walls = list()
	for(var/turf/nearby_turf in range(1, user))
		if(nearby_turf.density && !istype(nearby_turf, /turf/closed/wall/r_wall)) //can be contained in reinforced walls
			obstacles += nearby_turf
		else
			for(var/obj/obstacle in nearby_turf)
				if(obstacle.density)
					obstacles += obstacle

	for(var/atom/obstacle as anything in obstacles)
		if(istype(obstacle, /turf/closed/wall))
			var/datum/component/torn_wall/torn_comp = obstacle.AddComponent(/datum/component/torn_wall)
			if(torn_comp)
				torn_comp.increase_stage()
			walls += obstacle
		else if(isobj(obstacle))
			var/obj/obj_obstacle = obstacle
			if(istype(obj_obstacle))
				obj_obstacle.atom_destruction()

	addtimer(CALLBACK(src, PROC_REF(finalize_destruction), walls), 1 SECONDS)

/datum/action/changeling/headcrab/proc/finalize_destruction(list/affected_walls)
	for(var/turf/closed/wall/W in affected_walls)
		var/datum/component/torn_wall/torn_comp = W.GetComponent(/datum/component/torn_wall)
		if(torn_comp)
			torn_comp.increase_stage()

/datum/action/changeling/headcrab/proc/is_walled(mob/living/user)
	var/turf/ling_turf = get_turf(user)
	if(!ling_turf)
		return FALSE
	for(var/dir in GLOB.cardinals)
		var/turf/neighbor = get_step(ling_turf, dir)
		if(!neighbor)
			continue
		if(!neighbor.is_blocked_turf(exclude_mobs = TRUE))
			return FALSE
	return TRUE

#undef LAST_RESORT_EXPLOSION_RANGE
#undef LAST_RESORT_BLIND_RANGE
