#define ROACH_ORGAN_COLOR "#7c4200"
// Yeah i'm lazy and we don't use any of the other color slots
#define ROACH_COLORS ROACH_ORGAN_COLOR + ROACH_ORGAN_COLOR + ROACH_ORGAN_COLOR

/datum/status_effect/organ_set_bonus/roach
	organs_needed = 4
	bonus_activate_text = span_notice("Roach DNA is deeply infused with you! \
		You feel increasingly resistant to explosives, radiation, and viral agents.")
	bonus_deactivate_text = span_notice("You are no longer majority roach, and you feel vulnerable to nuclear apocalypses.")

	/// The stats given out to roach enabled mobs
	var/static/list/given_armor_stats = list(
		MELEE = 0,
		BULLET = 0,
		LASER = 0,
		ENERGY = 0,
		BOMB = 100, // Prevents gibbing from explosions (you'll stil die though)
		BIO = 90, // Some resistance to bio events
		FIRE = 0,
		ACID = 0,
	)
	/// And the actual armor datum from the stats above
	var/datum/armor/given_armor

/datum/status_effect/organ_set_bonus/roach/on_creation(mob/living/new_owner, ...)
	. = ..()
	given_armor = getArmor(arglist(given_armor_stats))

/datum/status_effect/organ_set_bonus/roach/Destroy()
	given_armor = null // I don't even know if these can stop GC
	return ..()

/datum/status_effect/organ_set_bonus/roach/enable_bonus()
	. = ..()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.armor.attachArmor(given_armor) // Gives armor from above
	ADD_TRAIT(owner, TRAIT_NUKEIMMUNE, id) // Immunity to nuke gibs
	ADD_TRAIT(owner, TRAIT_RADIMMUNE, id) // Nukes come with radiation (not actually but yknow)
	ADD_TRAIT(owner, TRAIT_VIRUS_RESISTANCE, id) // Viral resistance

/datum/status_effect/organ_set_bonus/roach/disable_bonus()
	. = ..()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology?.armor.detachArmor(given_armor)
	REMOVE_TRAIT(owner, TRAIT_NUKEIMMUNE, id)
	REMOVE_TRAIT(owner, TRAIT_RADIMMUNE, id)
	REMOVE_TRAIT(owner, TRAIT_VIRUS_RESISTANCE, id)


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

	var/defense_timerid

/obj/item/organ/internal/heart/roach/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "has hardened, somewhat translucent skin.")
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/roach)

/obj/item/organ/internal/heart/roach/Insert(mob/living/carbon/reciever, special, drop_if_replaced)
	. = ..()
	if(!.)
		return
	if(!ishuman(owner))
		return

	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(modify_damage))
	// 3x as long knockdowns
	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.knockdown_mod *= 3

/obj/item/organ/internal/heart/roach/Remove(mob/living/carbon/heartless, special)
	UnregisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE)
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology?.knockdown_mod /= 3
	if(defense_timerid)
		reset_damage(owner)
	return ..()

/**
 * Signal proc for [COMSIG_MOB_APPLY_DAMAGE]
 *
 * Being hit with brute damage in the back will impart a large damage resistance bonus for a very short period.
 */
/obj/item/organ/internal/heart/roach/proc/modify_damage(datum/source, damage, damagetype, def_zone, wound_bonus, bare_wound_bonus, sharpness, attack_direction)
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
		playsound(human_owner, 'sound/effects/constructform.ogg', 25)
	defense_timerid = addtimer(CALLBACK(src, PROC_REF(reset_damage), owner), 5 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)

/obj/item/organ/internal/heart/roach/proc/reset_damage(mob/living/carbon/human/human_owner)
	human_owner.physiology?.brute_mod *= 2
	defense_timerid = null


/// Roach stomach:
/// Makes disgust a non-issue, very slightly worse at passing off reagents
/obj/item/organ/internal/stomach/roach
	name = "mutated roach-stomach"
	desc = "Roach DNA infused into what was once a normal stomach."
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD
	disgust_metabolism = 32 // Demolishes any disgust we have
	metabolism_efficiency = 0.033 // Slightly worse at transferring reagents

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
	toxLethality = 4 * LIVER_DEFAULT_TOX_LETHALITY // But if they manage to get in you're screwed

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "liver"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = ROACH_COLORS

/obj/item/organ/internal/liver/roach/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/roach)

/obj/item/organ/internal/liver/roach/Insert(mob/living/carbon/reciever, special, drop_if_replaced)
	. = ..()
	if(!. || !ishuman(owner))
		return

	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.tox_mod *= 2

/obj/item/organ/internal/liver/roach/Remove(mob/living/carbon/organ_owner, special)
	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology?.tox_mod /= 2
	return ..()

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
