/mob/living/basic/pet/poppy
	name = "Poppy the Safety Inspector"
	desc = "Safety first!"
	icon = 'monkestation/code/modules/blueshift/icons/mob/pets.dmi'
	icon_state = "poppypossum"
	icon_living = "poppypossum"
	icon_dead = "poppypossum_dead"
	gender = FEMALE
	unique_pet = TRUE
	maxHealth = 30
	health = 30
	speak_emote = list("hisses")
	/// Is the inspection currently being passed?
	var/safety_inspection = TRUE
	/// Are they scared already?
	var/upset = FALSE
	/// Are they near the supermatter?
	var/near_engine = FALSE
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "stamps on"
	response_harm_simple = "stamp"
	density = FALSE
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	gold_core_spawnable = NO_SPAWN
	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_color = LIGHT_COLOR_BRIGHT_YELLOW
	light_outer_range = 2
	light_power = 0.8
	light_on = TRUE

/datum/ai_controller/basic_controller/poppy
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/poppy,
	)

/datum/ai_planning_subtree/random_speech/poppy
	speak = list("Hiss!", "HISS!", "Hissss?")
	emote_hear = list("hisses.")
	emote_see = list("runs in a circle.", "shakes.")
	speech_chance = 1

/mob/living/basic/pet/poppy/Initialize(mapload)
	. = ..()
	add_verb(src, /mob/living/proc/toggle_resting)
	become_area_sensitive(INNATE_TRAIT)

	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	RegisterSignal(src, COMSIG_ENTER_AREA, PROC_REF(check_area))

	qdel(GetComponent(/datum/component/butchering))

	var/datum/component/overlay_lighting/lighting_object = src.GetComponent(/datum/component/overlay_lighting)
	var/image/cone = lighting_object.cone
	cone.transform = cone.transform.Translate(0, -16) // adjust the little headlamp

/mob/living/basic/pet/poppy/death()
	lose_area_sensitivity(INNATE_TRAIT)
	set_light_on(FALSE)

	if(safety_inspection)
		var/list/sm_chamber = get_area_turfs(/area/station/engineering/supermatter)
		if(src.loc in sm_chamber)
			safety_inspection = FALSE
			priority_announce("This is a generated message due to an automated signal regarding the safety standards of the engineering department onboard [station_name()]. Due to the station engineers failing to meet the standard set by Central Command, each of them are now at risk of being forcefully enrolled in a re-evaluation program at later notice...", "Concerning the results of a safety inspection", type = "Priority")
			// It's just flavor, no tangible punishment
	return ..()

/mob/living/basic/pet/poppy/revive(full_heal_flags = NONE, excess_healing = 0, force_grab_ghost = FALSE)
	become_area_sensitive(INNATE_TRAIT)
	set_light_on(TRUE)
	..()

/mob/living/basic/pet/poppy/update_resting()
	. = ..()
	if(resting)
		icon_state = "[icon_living]_rest"
		set_light_on(FALSE)
	else
		icon_state = "[icon_living]"
		set_light_on(TRUE)
	regenerate_icons()

/mob/living/basic/pet/poppy/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	if(client || stat)
		return

	if(pulledby)
		set_resting(FALSE)

	if(near_engine)
		near_engine = FALSE
		panic()

	if(!SPT_PROB(0.5, seconds_per_tick))
		return
	if(!resting)
		manual_emote(pick("lets out a hiss before resting.", "catches a break.", "gives a simmering hiss before lounging.", "exams her surroundings before relaxing."))
		set_resting(TRUE)
		return
	else
		manual_emote(pick("stretches her claws, rising...", "diligently gets up, ready to inspect!", "stops her resting."))
		set_resting(FALSE)

	return ..()

/mob/living/basic/pet/poppy/proc/check_area()
	SIGNAL_HANDLER
	if(safety_inspection && !upset)
		var/list/sm_room = get_area_turfs(/area/station/engineering/supermatter/room)
		if(src.loc in sm_room)
			near_engine = TRUE

/mob/living/basic/pet/poppy/proc/panic()
	upset = TRUE
	icon_state = "poppypossum_aaa"

	emote("sweatdrop")
	do_jitter_animation(60)
	manual_emote("'s fur stands up, [src.p_their()] body trembling...")

	notify_ghosts(
		"[src] was startled by the supermatter!",
		source = src,
		notify_flags = NOTIFY_CATEGORY_NOFLASH,
		header = "Safety Inspection!",
	)
	addtimer(CALLBACK(src, PROC_REF(calm_down)), 60 SECONDS)

/mob/living/basic/pet/poppy/proc/calm_down()
	upset = FALSE
	icon_state = initial(icon_state)
