/obj/item/anomaly_neutralizer
	name = "anomaly neutralizer"
	desc = "A one-use device capable of instantly neutralizing anomalies."
	icon = 'icons/obj/device.dmi'
	icon_state = "memorizer2"
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	item_flags = NOBLUDGEON

/obj/item/anomaly_neutralizer/Initialize(mapload)
	. = ..()
	// Can be used to delete drained heretic influences
	AddComponent(/datum/component/effect_remover, \
		success_feedback = "You close %THEEFFECT with %THEWEAPON, frying its circuitry in the process.",
		on_clear_callback = CALLBACK(src, .proc/on_use), \
		effects_we_clear = list(/obj/effect/visible_heretic_influence))

/obj/item/anomaly_neutralizer/afterattack(atom/target, mob/user, proximity)
	..()
	if(!proximity || !target)
		return
	if(istype(target, /obj/effect/anomaly))
		var/obj/effect/anomaly/A = target
		to_chat(user, span_notice("The circuitry of [src] fries from the strain of neutralizing [A]!"))
		A.anomalyNeutralize()
		qdel(src)

/*
 * Callback for the effect remover component to delete after use.
 */
/obj/item/anomaly_neutralizer/proc/on_use(obj/effect/target, mob/living/user)
	do_sparks(3, FALSE, user)
	qdel(src)
