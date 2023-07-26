/**
 * ### Bitminer Trap
 * Places a proximity detection device which gives avatars a free sever
 */
/obj/item/bitminer_trap
	name = "intrusion detection assembly"

	desc = "Looks just like a bag of chips. Wait, is it?"
	icon = 'icons/obj/food/food.dmi'
	icon_state = "chips"
	lefthand_file = 'icons/mob/inhands/items/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/food_righthand.dmi'
	/// Whether this has been activated already. No reuse.
	var/used = FALSE
	/// The baited turf
	var/turf/baited_turf
	/// List of random icons to choose from
	var/static/list/icon_states = list(
		"boritos",
		"boritosgreen",
		"boritospurple",
		"boritosred",
		"chips",
		"cnds",
		"peanuts",
		"shrimp_chips",
		"cheesie_honkers",
		"sosjerky",
	)

/obj/item/bitminer_trap/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/bitminer_trap/LateInitialize()
	. = ..()
	icon_state = pick(icon_states)
	update_appearance()
	RegisterSignal(src, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/obj/item/bitminer_trap/update_icon_state()
	if(used)
		icon = 'icons/obj/service/janitor.dmi'
	else
		icon = 'icons/obj/food/food.dmi'

	return ..()

/obj/item/bitminer_trap/attack_self(mob/living/user, list/modifiers)
	. = ..()

	if(used)
		return

	if(get_area_name(user) != "Bitmining: Den")
		balloon_alert(user, "not valid here.")
		return

	baited_turf = get_turf(src)
	if(length(baited_turf.GetComponents(/datum/component/bitminer_trap_proximity)))
		balloon_alert(user, "already used here.")
		return

	if(!do_after(user, 3 SECONDS, src))
		return

	baited_turf.AddComponent(/datum/component/bitminer_trap_proximity)
	playsound(src, 'sound/effects/chipbagpop.ogg', 30, TRUE)
	balloon_alert(user, "nanites released.")
	used = TRUE
	update_appearance()

/// Adds examination text to explain how this works
/obj/item/bitminer_trap/proc/on_examine(datum/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER

	if(used)
		examine_text += span_info("Aw shucks, it's just a bag of chips.")
		return

	examine_text += span_info("No ordinary snack. Activating this in hand will release experimental nanite dust on the ground.")
	examine_text += span_infoplain("When a person steps on the tile, the quantum server will alert every bitminer it's hosting, \
	allowing them to disconnect without injury.")

/// Component for the proximity alert effect
/datum/component/bitminer_trap_proximity
	/// The amount of time between alerts
	var/cooldown_time = 30 SECONDS
	/// The actual cooldown between alerting bitminers
	COOLDOWN_DECLARE(alert_cooldown)

/datum/component/bitminer_trap_proximity/Initialize()
	. = ..()

	var/turf/tile = parent
	if(!isturf(tile))
		return

	tile.spawn_unique_cleanable(/obj/effect/decal/cleanable/dirt)

/datum/component/bitminer_trap_proximity/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))

/datum/component/bitminer_trap_proximity/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))

/// Chains the signalling proc to send proximity alerts to every listener
/datum/component/bitminer_trap_proximity/proc/on_entered(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, alert_cooldown))
		return

	var/mob/living/intruder = arrived
	if(!isliving(intruder))
		return

	signal_proximity(intruder)
	COOLDOWN_START(src, alert_cooldown, cooldown_time)

/datum/component/bitminer_trap_proximity/proc/on_broken(datum/source)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, alert_cooldown))
		return

	signal_broken()
	UnregisterFromParent()

/// Is it a person? If so, sound the alarms
/datum/component/bitminer_trap_proximity/proc/signal_proximity(mob/living/intruder)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_BITMINING_PROXIMITY, intruder)

/// Someone broke it. Sound the alarms
/datum/component/bitminer_trap_proximity/proc/signal_broken()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_BITMINING_PROXIMITY, parent)

/atom/movable/screen/alert/bitmining_proximity
	name = "Proximity Alert"
	icon_state = "template"
	desc = "Activate to sever the connection."
	timeout = 6 SECONDS

/atom/movable/screen/alert/bitmining_proximity/Click()
	var/mob/living/living_owner = owner
	if(!isliving(living_owner))
		return

	if(tgui_alert(living_owner, "Emergency disconnect from the server?", "Sever Connection", list("Yes", "No"), 5 SECONDS) != "Yes")
		return

	living_owner.mind.sever_avatar()
