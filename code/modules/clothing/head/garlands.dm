/obj/item/clothing/head/garland
	name = "floral garland"
	desc = "Someone, somewhere, is starving while wearing this. And it's definitely not you."
	icon_state = "garland"
	worn_icon_state = "garland"

/obj/item/clothing/head/garland/equipped(mob/user, slot)
	. = ..()
	if(slot_flags & slot)
		START_PROCESSING(SSobj, src)
		RegisterSignal(src, COMSIG_ATOM_FIRE_ACT, .proc/stop_sanity_boost)
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "garland", /datum/mood_event/garland)

/obj/item/clothing/head/garland/dropped(mob/user)
	. = ..()
	SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "garland")
	stop_sanity_boost()

/obj/item/clothing/head/garland/Destroy()
	stop_sanity_boost()
	return ..()

/// When equipped, the garland will slowly restore sanity up to neutral of non-unstable characters, as it does in Don't Starve.
/obj/item/clothing/head/garland/process(delta_time)
	var/mob/living/carbon/carbon_loc = loc
	if(!istype(carbon_loc))
		stop_sanity_boost()
		return

	// Under no circumstances do I recommend the use of GetComponent in this way, for anyone thinking about copy+pasting.
	var/datum/component/mood/our_mood = carbon_loc.GetComponent(/datum/component/mood)
	if(our_mood?.sanity < SANITY_NEUTRAL)
		our_mood.setSanity(our_mood.sanity + 0.05 * delta_time, SANITY_UNSTABLE, SANITY_NEUTRAL)


/// Disables our sanity boost processing and unregisters signals.
/obj/item/clothing/head/garland/proc/stop_sanity_boost(datum/source)
	SIGNAL_HANDLER

	UnregisterSignal(src, COMSIG_ATOM_FIRE_ACT)
	STOP_PROCESSING(SSobj, src)
