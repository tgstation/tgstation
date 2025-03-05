///Adds pheromones to a mob. If the target slime drains the mob to death, they might befriend the user
/datum/status_effect/slime_food
	id = "slime_food"
	alert_type = null
	var/befriend_chance = 30
	var/mob/living/carbon/human/feeder

/datum/status_effect/slime_food/on_creation(mob/living/new_owner, mob/living/carbon/human/feeder, befriend_chance = 100)
	src.befriend_chance = befriend_chance
	src.feeder = feeder
	return ..()

/datum/status_effect/slime_food/on_apply()
	if(isnull(feeder))
		return FALSE

	if(!ishuman(feeder)) //don't give the AI pheromones
		return FALSE

	RegisterSignal(feeder, COMSIG_QDELETING, PROC_REF(on_feeder_deleted))
	RegisterSignal(owner, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_feeder_deleted))
	RegisterSignal(owner, COMSIG_SLIME_DRAINED, PROC_REF(on_drained))
	RegisterSignal(owner, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	return ..()

/datum/status_effect/slime_food/on_remove()
	feeder = null

///Handles the source of the pheromones getting deleted, or the owner getting washed
/datum/status_effect/slime_food/proc/on_feeder_deleted(datum/source)
	SIGNAL_HANDLER
	qdel(src)

///Gaze upon the target
/datum/status_effect/slime_food/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(user == feeder)
		examine_list += span_boldnotice("Their smell reminds you of serenity and yourself.")
	else
		examine_list += span_boldnotice("Their smell reminds you of serenity and [feeder].")

///Handles a slime completely draining someone
/datum/status_effect/slime_food/proc/on_drained(datum/source, mob/living/basic/slime/draining_slime)
	SIGNAL_HANDLER
	if(isnull(draining_slime) || !isslime(draining_slime))
		qdel(src)
		return

	if(!prob(befriend_chance) || draining_slime.ai_controller.blackboard[BB_SLIME_RABID])
		qdel(src)
		return

	draining_slime.befriend(feeder)
	new /obj/effect/temp_visual/heart(draining_slime.loc)
	qdel(src)
