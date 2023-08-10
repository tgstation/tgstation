#define ROACH_ORGAN_COLOR "#7c4200"
// Yeah i'm lazy and we don't use any of the other color slots
#define ROACH_COLORS ROACH_ORGAN_COLOR + ROACH_ORGAN_COLOR + ROACH_ORGAN_COLOR

/datum/armor/roach_internal_armor
	bomb = 100
	bio = 90

/datum/status_effect/organ_set_bonus/roach
	id = "organ_set_bonus_roach"
	organs_needed = 4
	bonus_activate_text = span_notice("Roach DNA is deeply infused with you! \
		You feel increasingly resistant to explosives, radiation, and viral agents.")
	bonus_deactivate_text = span_notice("You are no longer majority roach, \
		and you feel much more vulnerable to nuclear apocalypses.")
	// - Immunity to nuke gibs
	// - Nukes come with radiation (not actually but yknow)
	bonus_traits = list(TRAIT_NUKEIMMUNE, TRAIT_RADIMMUNE, TRAIT_VIRUS_RESISTANCE)
	/// Armor type attached to the owner's physiology
	var/datum/armor/given_armor = /datum/armor/roach_internal_armor
	/// Storing biotypes pre-organ bonus applied so we don't remove bug from mobs which should have it.
	var/old_biotypes = NONE

/datum/status_effect/organ_set_bonus/roach/enable_bonus()
	. = ..()
	if(!ishuman(owner))
		return

	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.armor = human_owner.physiology.armor.add_other_armor(given_armor)

	old_biotypes = human_owner.mob_biotypes
	human_owner.mob_biotypes |= MOB_BUG

/datum/status_effect/organ_set_bonus/roach/disable_bonus()
	. = ..()
	if(!ishuman(owner) || QDELETED(owner))
		return

	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.armor = human_owner.physiology.armor.subtract_other_armor(given_armor)

	if(!(old_biotypes & MOB_BUG)) // only remove bug if it wasn't there before
		human_owner.mob_biotypes &= ~MOB_BUG

/// Roach heart:
/// Reduces damage taken from brute attacks from behind,
/// but increases duration of knockdowns
/obj/item/organ/internal/heart/roach
	name = "mutated roach-heart"
	desc = "Roach DNA infused into what was once a normal heart."
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "heart"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = ROACH_COLORS

	/// Timer ID for resetting the damage resistance applied from attacks from behind
	var/defense_timerid
	/// Bodypart overlay applied to the chest the heart is in
	var/datum/bodypart_overlay/simple/roach_shell/roach_shell

/obj/item/organ/internal/heart/roach/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "has hardened, somewhat translucent skin.")
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/roach)
	roach_shell = new()

/obj/item/organ/internal/heart/roach/Destroy()
	QDEL_NULL(roach_shell)
	return ..()

/obj/item/organ/internal/heart/roach/on_insert(mob/living/carbon/organ_owner, special)
	. = ..()
	if(!ishuman(organ_owner))
		return

	var/mob/living/carbon/human/human_owner = organ_owner

	RegisterSignal(human_owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(modify_damage))
	human_owner.physiology.knockdown_mod *= 3

	var/obj/item/bodypart/chest/chest = human_owner.get_bodypart(BODY_ZONE_CHEST)
	chest.add_bodypart_overlay(roach_shell)
	human_owner.update_body_parts()

/obj/item/organ/internal/heart/roach/on_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	if(!ishuman(organ_owner) || QDELETED(organ_owner))
		return

	var/mob/living/carbon/human/human_owner = organ_owner

	UnregisterSignal(human_owner, COMSIG_MOB_APPLY_DAMAGE)
	human_owner.physiology.knockdown_mod /= 3

	if(defense_timerid)
		reset_damage(human_owner)

	var/obj/item/bodypart/chest/chest = human_owner.get_bodypart(BODY_ZONE_CHEST)
	chest.remove_bodypart_overlay(roach_shell)
	human_owner.update_body_parts()

/**
 * Signal proc for [COMSIG_MOB_APPLY_DAMAGE]
 *
 * Being hit with brute damage in the back will impart a large damage resistance bonus for a very short period.
 */
/obj/item/organ/internal/heart/roach/proc/modify_damage(datum/source, damage, damagetype, def_zone, blocked, wound_bonus, bare_wound_bonus, sharpness, attack_direction, obj/item/attacking_item)
	SIGNAL_HANDLER

	if(!ishuman(owner) || !attack_direction || damagetype != BRUTE || owner.stat >= UNCONSCIOUS)
		return

	var/mob/living/carbon/human/human_owner = owner
	// No tactical spinning
	if(human_owner.flags_1 & IS_SPINNING_1)
		return

	// If we're lying down, or were attacked from the back, we get armor.
	var/should_armor_up = (human_owner.body_position == LYING_DOWN) || (human_owner.dir & attack_direction)
	if(!should_armor_up)
		return

	// Take 50% less damage from attack behind us
	if(!defense_timerid)
		human_owner.physiology.brute_mod /= 2
		human_owner.visible_message(span_warning("[human_owner]'s back hardens against the blow!"))
		playsound(human_owner, 'sound/effects/constructform.ogg', 25, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)

	defense_timerid = addtimer(CALLBACK(src, PROC_REF(reset_damage), owner), 5 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)

/obj/item/organ/internal/heart/roach/proc/reset_damage(mob/living/carbon/human/human_owner)
	defense_timerid = null
	if(!QDELETED(human_owner))
		human_owner.physiology.brute_mod *= 2
		human_owner.visible_message(span_warning("[human_owner]'s back softens again."))

// Simple overlay so we can add a roach shell to guys with roach hearts
/datum/bodypart_overlay/simple/roach_shell
	icon_state = "roach_shell"
	layers = EXTERNAL_FRONT|EXTERNAL_BEHIND

/datum/bodypart_overlay/simple/roach_shell/get_image(image_layer, obj/item/bodypart/limb)
	return image(
		icon = icon,
		icon_state = "[icon_state]_[mutant_bodyparts_layertext(image_layer)]",
		layer = image_layer,
	)

/// Roach stomach:
/// Makes disgust a non-issue, very slightly worse at passing off reagents
/// Also makes you more hungry
/obj/item/organ/internal/stomach/roach
	name = "mutated roach-stomach"
	desc = "Roach DNA infused into what was once a normal stomach."
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD
	disgust_metabolism = 32 // Demolishes any disgust we have
	metabolism_efficiency = 0.033 // Slightly worse at transferring reagents
	hunger_modifier = 3

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "stomach"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = ROACH_COLORS

/obj/item/organ/internal/stomach/roach/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/roach)

/// Roach liver:
/// Purges toxins at a higher threshold, but takes more damage from them if not purged
/obj/item/organ/internal/liver/roach
	name = "mutated roach-liver"
	desc = "Roach DNA infused into what was once a normal liver."
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD
	toxTolerance = 5 // More tolerance for toxins
	liver_resistance = 0.25 // But if they manage to get in you're screwed

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "liver"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = ROACH_COLORS

/obj/item/organ/internal/liver/roach/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/roach)

/obj/item/organ/internal/liver/roach/on_insert(mob/living/carbon/organ_owner, special)
	. = ..()
	if(!ishuman(organ_owner))
		return

	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.tox_mod *= 2

/obj/item/organ/internal/liver/roach/on_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	if(!ishuman(organ_owner) || QDELETED(organ_owner))
		return

	var/mob/living/carbon/human/human_owner = organ_owner
	human_owner.physiology.tox_mod /= 2

/// Roach appendix:
/// No appendicitus! weee!
/obj/item/organ/internal/appendix/roach
	name = "mutated roach-appendix"
	desc = "Roach DNA infused into what was once a normal appendix. It could get <i>worse</i>?"
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "appendix"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = ROACH_COLORS

/obj/item/organ/internal/appendix/roach/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/roach)

/obj/item/organ/internal/appendix/roach/become_inflamed()
	return

#undef ROACH_ORGAN_COLOR
#undef ROACH_COLORS
