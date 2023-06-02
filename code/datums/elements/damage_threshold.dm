/// Applied to living mobs.
/// Adds a force threshold for which attacks will be blocked entirely.
/// IE, if they are hit with an attack that deals less than X damage, the attack does nothing.
/datum/element/damage_threshold
	element_flags = ELEMENT_BESPOKE
	/// Incoming attacks beneath this threshold, inclusive, will be blocked entirely
	var/force_threshold = -1

/datum/element/damage_threshold/Attach(datum/target, threshold)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	if(!isnum(threshold) || threshold <= 0)
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(check_block))
	force_threshold = threshold

/datum/element/damage_threshold/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_LIVING_CHECK_BLOCK)

/datum/element/damage_threshold/proc/check_block(
	mob/living/source,
	atom/hitby,
	damage,
	attack_text,
	attack_type,
	armour_penetration,
	damage_type,
)
	SIGNAL_HANDLER

	if(damage <= 0)
		return NONE

	var/damage_mult = 1
	// We take count simple/basic damage coefficients, but not armor. Whatever
	if(isanimal(source))
		var/mob/living/simple_animal/animal = source
		damage_mult = animal.damage_coeff[damage_type] || 1
	if(isbasicmob(source))
		var/mob/living/basic/animal = source
		damage_mult = animal.damage_coeff[damage_type] || 1

	if(damage * damage_mult <= force_threshold)
		var/obj/item/item_hitting = hitby
		var/tap_vol = istype(item_hitting) ? item_hitting.get_clamped_volume() : 50
		source.visible_message(
			span_warning("[src] looks unharmed!"),
			span_warning("[attack_text] deals no damage to you!"),
			span_hear("You hear a thud."),
			COMBAT_MESSAGE_RANGE,
		)
		playsound(source, 'sound/weapons/tap.ogg', tap_vol, TRUE, -1)
		return SUCCESSFUL_BLOCK

	return NONE
