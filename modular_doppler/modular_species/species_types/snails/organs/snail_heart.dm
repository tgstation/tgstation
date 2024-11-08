/obj/item/organ/heart/snail
	name = "twin gastropod hearts"
	desc = "A primary heart normally nestled inside a gastropod's shell, and another in the owner's actual chest; necessary to maintain ample bloodflow through essentially two torsos."
	icon = 'modular_doppler/modular_species/species_types/snails/icons/organs/snail_heart.dmi'
	icon_state = "heart-snail-on"
	base_icon_state = "heart-snail"
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD // There's two of them. Also, due to the special interaction below, it's best we make sure these aren't easily lost.
	now_fixed = span_info("Your hearts begin to beat again.") //For the sake of verisimilitude.

	COOLDOWN_DECLARE(shell_effect_cd)

/obj/item/organ/heart/snail/on_mob_insert(mob/living/carbon/organ_owner, special)
	. = ..()
	if(!ishuman(organ_owner))
		return

	if(!issnail(organ_owner)) //This is cleaner than checking for the shell, because there's not really going to be any non-horribly-bugged situation in which a snail will be lacking a shell.
		return

	var/mob/living/carbon/human/human_owner = organ_owner

	RegisterSignal(human_owner, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(modify_damage))
	RegisterSignal(human_owner, COMSIG_MOB_AFTER_APPLY_DAMAGE, PROC_REF(do_block_effect))

/obj/item/organ/heart/snail/on_mob_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	if(!ishuman(organ_owner) || QDELETED(organ_owner))
		return

	var/mob/living/carbon/human/human_owner = organ_owner

	UnregisterSignal(human_owner, list(COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, COMSIG_MOB_AFTER_APPLY_DAMAGE))

/**
 * Signal proc for [COMSIG_MOB_APPLY_DAMAGE_MODIFIERS]
 *
 * Adds a 0.5 modifier to attacks from the back, code borrowed (wholesale) from the roach heart.
 */
/obj/item/organ/heart/snail/proc/modify_damage(mob/living/carbon/human/source, list/damage_mods, damage_amount, damagetype, def_zone, sharpness, attack_direction, obj/item/attacking_item)
	SIGNAL_HANDLER

	if(!is_blocking(source, damage_amount, damagetype, attack_direction))
		return

	damage_mods += 0.5

/**
 * Signal proc for [COMSIG_MOB_AFTER_APPLY_DAMAGE]
 *
 * Does a special effect if we blocked damage with our shell.
 */
/obj/item/organ/heart/snail/proc/do_block_effect(mob/living/carbon/human/source, damage_dealt, damagetype, def_zone, blocked, wound_bonus, bare_wound_bonus, sharpness, attack_direction, obj/item/attacking_item)
	SIGNAL_HANDLER

	if(!is_blocking(source, damage_dealt, damagetype, attack_direction))
		return

	if(COOLDOWN_FINISHED(src, shell_effect_cd))
		source.visible_message(span_warning("[source]'s shell weathers the blow, absorbing most of the shock!"))
		playsound(source, 'sound/effects/parry.ogg', 50, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)

	COOLDOWN_START(src, shell_effect_cd, 3 SECONDS) // Cooldown resets EVERY time we get hit

/// Checks if the passed mob is in a valid state to be blocking damage with the snail shell
/obj/item/organ/heart/snail/proc/is_blocking(mob/living/carbon/human/blocker, damage_amount, damagetype, attack_direction)
	if(damage_amount < 5 || damagetype != BRUTE || !attack_direction)
		return
	if(!ishuman(blocker) || blocker.stat >= UNCONSCIOUS)
		return FALSE
	// No tactical spinning
	if(HAS_TRAIT(blocker, TRAIT_SPINNING))
		return FALSE
	if(blocker.body_position == LYING_DOWN || (blocker.dir & attack_direction))
		return TRUE
	return FALSE

