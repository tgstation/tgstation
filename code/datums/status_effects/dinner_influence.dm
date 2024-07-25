/datum/status_effect/dinner_influence
	id = "dinner_influence"
	duration = 5 MINUTES // five minutes to have lunch and then back to work.
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/dinner_influence
	show_duration = TRUE
	/// Areas where we can dinner with others.
	var/list/areas_to_dinner
	/// Two minutes timer after which it is considered that you are late for lunch.
	var/two_minutes_left = FALSE
	/// If two mintures timer and after that we came and ate.
	var/wa_late_on_dinner = FALSE
	/// Var check if we on dinner place when entering new area.
	var/we_on_dinner_place = FALSE
	/// If we have eaten at least one dish entirely, then we have dinner.
	var/we_ate_on_dinner = FALSE
	/// Remembers what mood we received and gives it out at the end of dinner.
	var/datum/mood_event/what_mood_event_we_got

/atom/movable/screen/alert/status_effect/dinner_influence
	name = "Dinner Time"
	desc = "Time to go to the cafeteria and have some food."
	icon_state = "dinner_influence"

/datum/status_effect/dinner_influence/on_creation(mob/living/new_owner, list/areas_to_dinner)
	. = ..()
	if(new_owner.nutrition >= NUTRITION_LEVEL_FED)
		new_owner.adjust_nutrition(-100)
	addtimer(VARSET_CALLBACK(src, two_minutes_left, TRUE), 2 MINUTES)
	src.areas_to_dinner = areas_to_dinner

/datum/status_effect/dinner_influence/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_LIVING_FINISH_EAT, PROC_REF(eating_on_dinner_time))
	RegisterSignal(owner, COMSIG_ENTER_AREA, PROC_REF(enter_area_on_dinner_time))

/// We also have 3 mood types that override mood_event_we_got:
//-// if we don't ate anything.
//-// if we have full diner(we dont late on dinner, we ate somthing and we was in dinner place when dinner end).
//-// if we don't have any mood events in mood_event_we_got.
/datum/status_effect/dinner_influence/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_LIVING_FINISH_EAT)
	UnregisterSignal(owner, COMSIG_ENTER_AREA)

	if(!we_ate_on_dinner)
		owner.add_mood_event(id, /datum/mood_event/dont_eat_on_dinner)
		return
	if(!wa_late_on_dinner && we_on_dinner_place)
		if(HAS_TRAIT(owner, TRAIT_INTROVERT))
			owner.add_mood_event(id, /datum/mood_event/introvert_on_dinner)
			return
		owner.add_mood_event(id, /datum/mood_event/full_dinner)
		return
	if(!what_mood_event_we_got)
		owner.add_mood_event(id, /datum/mood_event/dinner_left_early)
		return
	owner.add_mood_event(id, what_mood_event_we_got)

/// Proc check when we ate somthing. Checks where we ate food, whether we are late and remembers a new mood.
/datum/status_effect/dinner_influence/proc/eating_on_dinner_time(mob/living/carbon/human/hungry_human, datum/what_we_ate)
	SIGNAL_HANDLER
	if(we_ate_on_dinner)
		UnregisterSignal(owner, COMSIG_LIVING_FINISH_EAT)
		return
	if(!we_on_dinner_place)
		if(HAS_TRAIT(hungry_human, TRAIT_INTROVERT))
			new_mood_event(hungry_human, /datum/mood_event/out_dinner_room_eating_introvert)
			we_ate_on_dinner = TRUE
			return
		new_mood_event(hungry_human, /datum/mood_event/out_dinner_room_eating)
		we_ate_on_dinner = TRUE
		return
	if(two_minutes_left)
		new_mood_event(hungry_human, /datum/mood_event/came_late_dinner)
		we_ate_on_dinner = wa_late_on_dinner = TRUE
		return
	we_ate_on_dinner = TRUE

/// Proc check when we entering area. Checks if we come to dinner zone and update we_on_dinner_place var.
/datum/status_effect/dinner_influence/proc/enter_area_on_dinner_time(mob/living/carbon/human/hungry_human, area/new_area)
	SIGNAL_HANDLER
	if(we_on_dinner_place && is_type_in_list(new_area, areas_to_dinner))
		return
	if(we_on_dinner_place && !is_type_in_list(new_area, areas_to_dinner))
		we_on_dinner_place = FALSE
		return
	if(!we_on_dinner_place && is_type_in_list(new_area, areas_to_dinner))
		we_on_dinner_place = TRUE
		return

/// Calculate new mood we have and writes it down if its influence is higher.
/datum/status_effect/dinner_influence/proc/new_mood_event(mob/living/give_my_mood_event, datum/mood_event/event_type)
	if(!what_mood_event_we_got)
		what_mood_event_we_got = event_type
		return
	if(what_mood_event_we_got.mood_change > event_type.mood_change)
		return
	what_mood_event_we_got = event_type
