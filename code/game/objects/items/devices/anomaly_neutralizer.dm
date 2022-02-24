/obj/item/anomaly_neutralizer
	name = "anomaly neutralizer"
	desc = "A one-use device capable of instantly neutralizing anomalous or otherworldly entities."
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

	// Primarily used to delete and neutralize anomalies.
	AddComponent(/datum/component/effect_remover, \
		success_feedback = "You neutralize %THEEFFECT with %THEWEAPON, frying its circuitry in the process.", \
		on_clear_callback = CALLBACK(src, .proc/on_anomaly_neutralized), \
		effects_we_clear = list(/obj/effect/anomaly))

	// Can also be used to delete drained heretic influences, to stop fools from losing arms.
	AddComponent(/datum/component/effect_remover, \
		success_feedback = "You close %THEEFFECT with %THEWEAPON, frying its circuitry in the process.", \
		on_clear_callback = CALLBACK(src, .proc/on_use), \
		effects_we_clear = list(/obj/effect/visible_heretic_influence))

/**
 * Callback for the effect remover component to handle neutralizing anomalies.
 */
/obj/item/anomaly_neutralizer/proc/on_anomaly_neutralized(obj/effect/anomaly/target, mob/living/user)
	target.anomalyNeutralize()
	on_use(target, user)

/**
 * Use up the anomaly neutralizer. Cause some sparks and delete it.
 */
/obj/item/anomaly_neutralizer/proc/on_use(obj/effect/target, mob/living/user)
	do_sparks(3, FALSE, user)
	qdel(src)
