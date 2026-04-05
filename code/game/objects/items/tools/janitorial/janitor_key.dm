///The time limit on the keys before the access it's been given clears itself.
#define ACCESS_TIMER_LIMIT (10 MINUTES)

/obj/item/access_key
	name = "access key ring"
	desc = "A key ring with a beeper, allowing the keys to change shape depending on which department it has access to."
	icon_state = "access_key"
	inhand_icon_state = "access_key"
	icon = 'icons/obj/service/janitor.dmi'
	lefthand_file = 'icons/mob/inhands/items/keys_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/keys_righthand.dmi'
	hitsound = 'sound/items/rattling_keys_attack.ogg'
	force = 2
	verb_say = "beeps" //it has a beeper
	verb_ask = "questionably beeps"
	verb_exclaim = "beeps loudly"
	w_class = WEIGHT_CLASS_TINY

	///The departmental access given to the key.
	var/list/department_access

/obj/item/access_key/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_ON_DEPARTMENT_ACCESS, PROC_REF(department_access_given))
	GLOB.janitor_devices += src

/obj/item/access_key/Destroy()
	GLOB.janitor_devices -= src
	return ..()

/obj/item/access_key/examine(mob/user)
	. = ..()
	if(department_access)
		. += "It currently holds access to the [department_access] region."

/obj/item/access_key/examine_more(mob/user)
	. = ..()
	. += span_notice("Access can be granted through a Keycard Authentication Device.")
	. += span_notice("This access is limited to one department at a time.")

/**
 * Called when attempting to open an airlock.
 * Checks if the keys have access, returns try_to_activate_door if it does, returns FALSE otherwise.
 * Args:
 * user - The person attempting to open the door
 * airlock - The door we're attempting to open
 */
/obj/item/access_key/proc/attempt_open_door(mob/living/user, obj/machinery/door/airlock)
	if(DOING_INTERACTION_WITH_TARGET(user, airlock))
		return
	user.balloon_alert_to_viewers("fumbles with keys...", "finding key...")
	user.playsound_local(src, 'sound/items/rattling_keys.ogg', 25, TRUE)
	if(!do_after(user, 3 SECONDS, airlock))
		return FALSE
	if(!department_access || !airlock.check_access_list(SSid_access.accesses_by_region[department_access]))
		airlock.balloon_alert(user, "no access!")
		return FALSE
	return airlock.try_to_activate_door(user, access_bypass = TRUE)

/**
 * Called when a keycard authenticator sends region access
 * Stores it on the key to use for access, then sets a timer to clear it.
 * Args:
 * source - the keycard authenticator giving us the access
 * region_access - the list of access we're being sent, we only take the first entry in the list as there should only have one department at a time.
 */
/obj/item/access_key/proc/department_access_given(obj/machinery/keycard_auth/source, list/region_access)
	SIGNAL_HANDLER
	department_access = region_access[1]
	say("Access granted to [department_access] area.")
	playsound(src, 'sound/machines/ding.ogg', 25, TRUE)
	addtimer(CALLBACK(src, PROC_REF(clear_access)), ACCESS_TIMER_LIMIT, TIMER_UNIQUE|TIMER_OVERRIDE)
	log_game("Access to the [department_access] department was given to [src] [(ismob(loc)) ? "held by [loc]" : "which is not being held"]")
	investigate_log("Access to the [department_access] department was given to [src] [(ismob(loc)) ? "held by [loc]" : "which is not being held"]", INVESTIGATE_ACCESSCHANGES)

/**
 * Called when a keycard authenticator runs out of time
 * Clears the department access and alerts nearby people of such.
 */
/obj/item/access_key/proc/clear_access()
	log_game("Access to the [department_access] department on [src] has expired.")
	investigate_log("Access to the [department_access] department on [src] has expired.]", INVESTIGATE_ACCESSCHANGES)
	department_access = null
	say("Access revoked, time ran out.")
	playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE)

#undef ACCESS_TIMER_LIMIT
