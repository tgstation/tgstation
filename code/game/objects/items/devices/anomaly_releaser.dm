///Use on an anomaly core to "awake" the anomaly and stabilize it
/obj/item/anomaly_releaser
	name = "anomaly releaser"
	desc = "Single-use injector that releases and stabilizes anomalies by injecting an unknown substance."
	icon = 'icons/obj/devices/syndie_gadget.dmi'
	icon_state = "anomaly_releaser"
	inhand_icon_state = "stimpen"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5

	///icon state after being used up
	var/used_icon_state = "anomaly_releaser_used"
	///are we used? if used we can't be used again
	var/used = FALSE
	///Can we be used infinitely?
	var/infinite = FALSE

/obj/item/anomaly_releaser/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!istype(target, /obj/item/assembly/signaler/anomaly))
		return NONE

	if(used)
		return ITEM_INTERACT_BLOCKING
	if(!do_after(user, 3 SECONDS, target))
		return ITEM_INTERACT_BLOCKING
	if(used)
		return ITEM_INTERACT_BLOCKING

	var/obj/item/assembly/signaler/anomaly/core = target
	if(!core.anomaly_type)
		return ITEM_INTERACT_BLOCKING

	var/obj/effect/anomaly/anomaly = new core.anomaly_type(get_turf(core))
	anomaly.stabilize()
	log_combat(user, anomaly, "released", object = src, addition = "in [get_area(target)].")

	if(!infinite)
		icon_state = used_icon_state
		used = TRUE
		name = "used " + name
		qdel(core)
	return ITEM_INTERACT_SUCCESS
