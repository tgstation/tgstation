//Icemoon megafauna trophies go here.


/**
 * Demonic frost miner
 * Detonating a mark causes the victim to be encased in an ice block, preventing movement for 4 seconds.
 */
/obj/item/crusher_trophy/ice_block_talisman
	name = "ice block talisman"
	desc = "A glowing trinket that a demonic miner had on him, it seems he couldn't utilize it for whatever reason. Suitable as a trophy for a kinetic crusher."
	icon_state = "ice_trap_talisman"
	denied_types = list(/obj/item/crusher_trophy/ice_block_talisman)
	///How long does the freeze effect last on an affected mob
	var/freeze_duration = 4 SECONDS

/obj/item/crusher_trophy/ice_block_talisman/effect_desc()
	return "mark detonation to <b>freeze a creature</b> in a block of ice for <b>[DisplayTimeText(freeze_duration)]</b>, preventing them from moving"

/obj/item/crusher_trophy/ice_block_talisman/on_mark_detonation(datum/source, mob/living/target, mob/living/user)
	. = ..()

	target.apply_status_effect(/datum/status_effect/ice_block_talisman, freeze_duration)

/datum/status_effect/ice_block_talisman
	id = "ice_block_talisman"
	duration = 4 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /atom/movable/screen/alert/status_effect/ice_block_talisman
	/// Stored icon overlay for the hit mob, removed when effect is removed
	var/icon/cube

/datum/status_effect/ice_block_talisman/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		duration = set_duration
	return ..()

/atom/movable/screen/alert/status_effect/ice_block_talisman
	name = "Frozen Solid"
	desc = "You're frozen inside an ice cube, and cannot move!"
	icon_state = "frozen"

/datum/status_effect/ice_block_talisman/on_apply()
	RegisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(owner_moved))
	if(!owner.stat)
		to_chat(owner, span_userdanger("You become frozen in a cube!"))
	cube = icon('icons/effects/freeze.dmi', "ice_cube")
	var/list/icon_dimensions = get_icon_dimensions(owner.icon)
	cube.Scale(icon_dimensions["width"], icon_dimensions["height"])
	owner.add_overlay(cube)
	return ..()

/// Blocks movement from the status effect owner
/datum/status_effect/ice_block_talisman/proc/owner_moved()
	SIGNAL_HANDLER
	return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/datum/status_effect/ice_block_talisman/be_replaced()
	owner.cut_overlay(cube)
	UnregisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE)
	return ..()

/datum/status_effect/ice_block_talisman/on_remove()
	if(!owner.stat)
		to_chat(owner, span_notice("The cube melts!"))
	owner.cut_overlay(cube)
	UnregisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE)

/**
 * Wendigo
 * Doubles melee damage of the crusher when wielded.
 */
/obj/item/crusher_trophy/wendigo_horn
	name = "wendigo horn"
	desc = "A gnarled horn ripped from the skull of a wendigo. Suitable as a trophy for a kinetic crusher."
	icon_state = "wendigo_horn"
	denied_types = list(/obj/item/crusher_trophy/wendigo_horn)

/obj/item/crusher_trophy/wendigo_horn/effect_desc()
	return "melee hits to inflict <b>twice as much damage</b>"

/obj/item/crusher_trophy/wendigo_horn/add_to(obj/item/kinetic_crusher/crusher, mob/living/user)
	. = ..()
	if(!.)
		return
	crusher.AddComponent(/datum/component/two_handed, force_unwielded = 0, force_wielded = 40)

/obj/item/crusher_trophy/wendigo_horn/remove_from(obj/item/kinetic_crusher/crusher, mob/living/user)
	. = ..()
	if(!.)
		return
	crusher.AddComponent(/datum/component/two_handed, force_unwielded = 0, force_wielded = 20)
