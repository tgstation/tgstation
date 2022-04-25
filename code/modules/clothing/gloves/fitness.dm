/// The max number of networked fitness watches, so
#define FATSTAT_MAX_NETWORKED 20

/obj/item/clothing/gloves/fitness
	name = "\improper FatStat tracker"
	desc = "A "
	icon_state = "black"
	inhand_icon_state = "blackgloves"
	/// How many steps this has registered since last being reset
	var/step_count = 0

	var/list/static/fatstat_trackers

	var/milestone_interval = 500

	var/mob/living/tracked_owner

	COOLDOWN_DECLARE(action_cd)

/obj/item/clothing/gloves/fitness/Initialize(mapload)
	. = ..()
	if(LAZYLEN(fatstat_trackers) < FATSTAT_MAX_NETWORKED)
		LAZYADD(fatstat_trackers, src)
	else
		desc += " This model does not have a "

/obj/item/clothing/gloves/fitness/Destroy()
	LAZYREMOVE(fatstat_trackers, src)
	return ..()

/obj/item/clothing/gloves/fitness/equipped(mob/living/user, slot)
	. = ..()

	start_tracking(user)

/obj/item/clothing/gloves/fitness/dropped(mob/living/user)
	. = ..()
	stop_tracking()

/obj/item/clothing/gloves/fitness/examine(mob/user)
	. = ..()
	. += span_info("The display ")

/obj/item/clothing/gloves/fitness/attack_self(mob/user, modifiers)
	. = ..()
	if(!COOLDOWN_FINISHED(src, action_cd))
		return

	COOLDOWN_START(src, action_cd, 5 SECONDS)
	audible_message(span_robotic("You have taken: [step_count] steps!", hearing_distance = COMBAT_MESSAGE_RANGE)

/obj/item/clothing/gloves/fitness/attack_self_secondary(mob/user, modifiers)
	. = ..()
	if(!COOLDOWN_FINISHED(src, action_cd))
		return

	COOLDOWN_START(src, action_cd, 5 SECONDS)
	audible_message(span_robotic("You have successfully reset your step count!"), hearing_distance = COMBAT_MESSAGE_RANGE)
	step_count = 0


/obj/item/clothing/gloves/fitness/proc/start_tracking(mob/living/user)
	if(!istype(user))
		return

	stop_tracking()

	tracked_owner = user
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/increment_step)
	RegisterSignal(user, COMSIG_PARENT_QDELETING, .proc/stop_tracking)

/obj/item/clothing/gloves/fitness/proc/stop_tracking()
	SIGNAL_HANDLER

	if(tracked_owner)
		UnregisterSignal(tracked_owner, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
	tracked_owner = null

/obj/item/clothing/gloves/fitness/proc/increment_step(mob/living/mover, old_loc, movement_dir, forced, old_locs)
	SIGNAL_HANDLER

	if(!istype(mover) || forced)
		return

	step_count++
	if(step_count % milestone_interval == 0)
		audible_message(span_robotic("You have reached [step_count] steps!", hearing_distance = COMBAT_MESSAGE_RANGE))
