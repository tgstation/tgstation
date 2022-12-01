
#define GOLIATH_ORGAN_COLOR "#4caee7"
#define GOLIATH_SCLERA_COLOR "#ffffff"
#define GOLIATH_PUPIL_COLOR "#00b1b1"

#define GOLIATH_COLORS GOLIATH_ORGAN_COLOR + GOLIATH_SCLERA_COLOR + GOLIATH_PUPIL_COLOR

///bonus of the goliath: you can swim through space!
/datum/status_effect/organ_set_bonus/goliath
	organs_needed = 4
	bonus_activate_text = span_notice("goliath DNA is deeply infused with you! You've learned how to propel yourself through space!")
	bonus_deactivate_text = span_notice("Your DNA is once again mostly yours, and so fades your ability to space-swim...")

/datum/status_effect/organ_set_bonus/goliath/enable_bonus()
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, REF(src))

/datum/status_effect/organ_set_bonus/goliath/disable_bonus()
	. = ..()
	REMOVE_TRAIT(src, TRAIT_SPACEWALK, REF(src))

///goliath lungs! You can breathe in space! Oh... you can't breathe on the station, you need low oxygen environments.
/obj/item/organ/internal/lungs/lavaland/goliath
	name = "mutated goliath-lungs"
	desc = "goliath DNA infused into what was once some normal lungs."

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "lungs"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = GOLIATH_COLORS

/obj/item/organ/internal/lungs/lavaland/goliath/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "has odd neck gills.", BODY_ZONE_HEAD)
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/goliath)

///goliath brain. you can't use gloves but one of your arms becomes a tentacle hammer!
/obj/item/organ/internal/brain/goliath
	name = "mutated goliath-brain"
	desc = "goliath DNA infused into what was once a normal brain."

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "brain"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = GOLIATH_COLORS

	var/obj/item/goliath_infuser_hammer/hammer

/obj/item/organ/internal/brain/goliath/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "arm is just a tentacle hammer...")
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/goliath)

/obj/item/organ/internal/brain/goliath/Insert(mob/living/carbon/brain_owner, special, drop_if_replaced, no_id_transfer)
	. = ..()
	if(!ishuman(brain_owner))
		return
	var/mob/living/carbon/human/human_receiver = brain_owner
	var/datum/species/rec_species = human_receiver.dna.species
	if(!(rec_species.no_equip_flags & ITEM_SLOT_GLOVES))
		rec_species.no_equip_flags += ITEM_SLOT_GLOVES

	hammer = new/obj/item/goliath_infuser_hammer
	brain_owner.put_in_hands(hammer)

//technically you could get around the mood issue by extracting and reimplanting the brain but it will be far easier to just go one z there and back
/obj/item/organ/internal/brain/goliath/Remove(mob/living/carbon/brain_owner, special, no_id_transfer)
	. = ..()
	UnregisterSignal(brain_owner)
	if(!ishuman(brain_owner))
		return
	var/mob/living/carbon/human/human_receiver = brain_owner
	var/datum/species/rec_species = human_receiver.dna.species
	if(!(initial(rec_species.no_equip_flags) & ITEM_SLOT_GLOVES))
		rec_species.no_equip_flags -= ITEM_SLOT_GLOVES
	if(hammer)
		brain_owner.visible_message(span_warning("\The [hammer] disintegrates!"))
		QDEL_NULL(hammer)
	return ..()

/obj/item/goliath_infuser_hammer
	name = "tentacle hammer"
	desc = "A mass of tentacles has replaced your arm."
	icon_state = "goliath_hammer"
	inhand_icon_state = "goliath_hammer"
	lefthand_file = 'icons/mob/inhands/weapons/goliath_hammer_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/goliath_hammer_righthand.dmi'
	item_flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	force = 20
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	attack_verb_continuous = list("smashes", "bashes", "hammers", "crunches")
	attack_verb_simple = list("smash", "bash", "hammer", "crunch")
	hitsound = 'sound/effects/bamf.ogg'
	tool_behaviour = TOOL_MINING
	toolspeed = 0.2
	/// List of factions we deal bonus damage to
	var/list/nemesis_factions = list("mining", "boss")
	/// Amount of damage we deal to the above factions
	var/faction_bonus_force = 80

/obj/item/goliath_infuser_hammer/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/goliath_infuser_hammer/melee_attack_chain(mob/user, atom/target, params)
	. = ..()
	user.changeNext_move(CLICK_CD_MELEE * 3) //hits slowly but HARD

/// makes you cold resistant, but heat-weak.
/obj/item/organ/internal/heart/goliath
	name = "mutated goliath-heart"
	desc = "goliath DNA infused into what was once a normal heart."

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "heart"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = GOLIATH_COLORS

	organ_traits = list(TRAIT_LAVA_IMMUNE, TRAIT_ASHSTORM_IMMUNE)

/obj/item/organ/internal/heart/goliath/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "skin has small tentacles growing...")
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/goliath)

#undef GOLIATH_COLORS
