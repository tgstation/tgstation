/datum/disease/parrot_possession
	name = "Parrot Possession"
	max_stages = 1
	spread_text = "Paranormal"
	spread_flags = DISEASE_SPREAD_SPECIAL
	disease_flags = CURABLE
	cure_text = "Holy Water."
	cures = list(/datum/reagent/water/holywater)
	cure_chance = 10
	agent = "Avian Vengence"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "Subject is possessed by the vengeful spirit of a parrot. Call the priest."
	severity = DISEASE_SEVERITY_MEDIUM
	infectable_biotypes = MOB_ORGANIC|MOB_UNDEAD|MOB_ROBOTIC|MOB_MINERAL
	bypasses_immunity = TRUE //2spook
	///chance we speak
	var/speak_chance = 5
	///controller we speak from
	var/datum/ai_controller/basic_controller/parrot_controller


/datum/disease/parrot_possession/stage_act(seconds_per_tick, times_fired)
	. = ..()

	if(!. || isnull(parrot_controller))
		return

	var/potential_phrase = parrot_controller.blackboard[BB_PARROT_REPEAT_STRING]

	if(SPT_PROB(speak_chance, seconds_per_tick) && !isnull(potential_phrase))
		affected_mob.say(potential_phrase, forced = "parrot possession")


/datum/disease/parrot_possession/cure(add_resistance = FALSE)
	var/atom/movable/inside_parrot = locate(/mob/living/basic/parrot/poly/ghost) in affected_mob
	if(inside_parrot)
		UnregisterSignal(inside_parrot, list(COMSIG_PREQDELETED, COMSIG_MOVABLE_MOVED))
		inside_parrot.forceMove(affected_mob.drop_location())
		affected_mob.visible_message(
			span_danger("[inside_parrot] is violently driven out of [affected_mob]!"),
			span_userdanger("[inside_parrot] bursts out of your chest!"),
		)
	parrot_controller = null
	return ..()

/datum/disease/parrot_possession/proc/set_parrot(mob/living/parrot)
	parrot_controller = parrot.ai_controller
	RegisterSignals(parrot, list(COMSIG_PREQDELETED, COMSIG_MOVABLE_MOVED), PROC_REF(on_parrot_exit))

/datum/disease/parrot_possession/proc/on_parrot_exit(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(COMSIG_PREQDELETED, COMSIG_MOVABLE_MOVED))
	cure()
