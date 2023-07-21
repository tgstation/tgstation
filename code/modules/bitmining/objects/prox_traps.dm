/**
 * ### Bitminer Trap
 * Places a proximity detection device which gives avatars a free sever
 */
/obj/item/assembly/bitminer_trap
	name = "proximity detection module"

	attachable = TRUE
	desc = "When placed on a tile, gives proximity alerts while connected to the virtual domain."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "chips"
	lefthand_file = 'icons/mob/inhands/items/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/food_righthand.dmi'
	/// Whether this has been activated already. No reuse.
	var/used = FALSE
	/// The baited turf
	var/turf/baited_turf

/obj/item/assembly/bitminer_trap/attack_self(mob/living/user, list/modifiers)
	. = ..()

	if(used)
		return

	if(get_area_name(user) != "Bitmining Den")
		balloon_alert(user, "not valid here.")
		return

	if(!do_after(user, 3 SECONDS, src))
		return

	baited_turf = get_turf(src)
	RegisterSignal(baited_turf, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	playsound(src, 'sound/effects/chipbagpop.ogg', 30, TRUE)
	balloon_alert(user, "tile marked.")
	used = TRUE
	update_appearance()

/obj/item/assembly/bitminer_trap/update_icon_state()
	if(used)
		icon = 'icons/obj/service/janitor.dmi'
	else
		icon = 'icons/obj/food/food.dmi'

	return ..()

/// Chains the signalling proc to send proximity alerts to every listener
/obj/item/assembly/bitminer_trap/proc/on_entered(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER

	var/mob/living/intruder = arrived
	if(!isliving(intruder))
		return

	signal_proximity(intruder)

/// Is it a person? If so, sound the alarms
/obj/item/assembly/bitminer_trap/proc/signal_proximity(mob/living/intruder)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_BITMINING_PROXIMITY, intruder)

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
