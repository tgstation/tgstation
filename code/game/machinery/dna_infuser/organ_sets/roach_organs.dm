#define ROACH_ORGAN_COLOR "#7c4200"

/datum/status_effect/organ_set_bonus/roach
	organs_needed = 4
	bonus_activate_text = span_notice("Roach DNA is deeply infused with you! You feel increasingly resistant explosives.")
	bonus_deactivate_text = span_notice("You are no longer majority roach, and you feel vulnerable to nuclear apocalypses.")

	/// The stats given out to roach enabled mobs
	var/static/list/given_armor_stats = list(
		MELEE = 0,
		BULLET = 0,
		LASER = 0,
		ENERGY = 0,
		BOMB = 100, // Prevents gibbing from explosions
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
	given_armor = null // I don't even know if these can hold references
	return ..()

/datum/status_effect/organ_set_bonus/roach/enable_bonus()
	. = ..()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.armor.attachArmor(given_armor) // Provices immunity to explosion gibbing, and also bio resistance
	ADD_TRAIT(owner, TRAIT_NUKEIMMUNE, id) // Immunity to nuke gibs
	ADD_TRAIT(owner, TRAIT_RADIMMUNE, id) // Nukes come with radiation (not actually but yknow)
	ADD_TRAIT(owner, TRAIT_VIRUS_RESISTANCE, id) // Viral resistance

/datum/status_effect/organ_set_bonus/roach/disable_bonus()
	. = ..()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.armor.detachArmor(given_armor)
	REMOVE_TRAIT(owner, TRAIT_NUKEIMMUNE, id)
	REMOVE_TRAIT(owner, TRAIT_RADIMMUNE, id)
	REMOVE_TRAIT(owner, TRAIT_VIRUS_RESISTANCE, id)



/obj/item/organ/internal/heart/roach
	name = "mutated roach-heart"
	desc = "Roach DNA infused into what was once a normal heart."

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "heart"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = ROACH_ORGAN_COLOR

	var/defense_timerid

/obj/item/organ/internal/heart/roach/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "has a thick carapace spouting from their back!")
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/roach)

/obj/item/organ/internal/heart/roach/Insert(mob/living/carbon/reciever, special, drop_if_replaced)
	. = ..()
	if(!.)
		return

	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(modify_damage))

/obj/item/organ/internal/heart/roach/Remove(mob/living/carbon/heartless, special)
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE)
	if(defense_timerid)
		reset_damage()
	return ..()

/obj/item/organ/internal/heart/roach/proc/modify_damage(datum/source, damage, damagetype, def_zone, wound_bonus, bare_wound_bonus, sharpness, attack_direction)
	SIGNAL_HANDLER

	if(!ishuman(owner) || !attack_direction || damagetype != BRUTE)
		return

	var/mob/living/carbon/human/human_owner = owner
	var/are_we_behind = (human_owner.flags_1 & IS_SPINNING_1) || (human_owner.body_position == LYING_DOWN) || (human_owner.dir & attack_direction)
	if(!are_we_behind)
		return

	// Take 50% less damage from attack behind us
	if(!defense_timerid)
		human_owner.physiology.brute_mod /= 2
		human_owner.visible_message(span_warning("[human_owner]'s back hardens against the blow!"))
	defense_timerid = addtimer(CALLBACK(src, PROC_REF(reset_damage)), 0.2 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)

/obj/item/organ/internal/heart/roach/proc/reset_damage()
	if(QDELETED(src) || QDELETED(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.brute_mod *= 2
	defense_timerid = null

/obj/item/organ/internal/ears/roach
