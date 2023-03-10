#define GONDOLA_ORGAN_COLOR "#7a503d"
#define GONDOLA_SCLERA_COLOR "#000000"
#define GONDOLA_PUPIL_COLOR "#000000"
#define GONDOLA_COLORS GONDOLA_ORGAN_COLOR + GONDOLA_SCLERA_COLOR + GONDOLA_PUPIL_COLOR

/*
Fluoride Stare: After someone says 5 words, blah blah blah...
*/

///bonus of the observing gondola: you can ignore environmental hazards
/datum/status_effect/organ_set_bonus/gondola
	id = "organ_set_bonus_gondola"
	organs_needed = 3
	bonus_activate_text = span_notice("Gondola DNA is deeply infused with you! You are the ultimate observer, uncaring of the environment around you...")
	bonus_deactivate_text = span_notice("Your DNA is no longer serene and gondola-like, and so you begin remembering that breathing is like, important...")
	bonus_traits = list(TRAIT_RESISTHEAT, TRAIT_RESISTCOLD, TRAIT_NOBREATH, TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTHIGHPRESSURE)

/// makes you a pacifist and turns most mobs neutral towards you
/obj/item/organ/internal/heart/gondola
	name = "mutated gondola-heart"
	desc = "Gondola DNA infused into what was once a normal heart."

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "heart"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = GONDOLA_COLORS
	organ_traits = TRAIT_PACIFISM
	///keeps track of whether the reciever actually gained factions
	var/list/factions_to_remove = list()

/obj/item/organ/internal/heart/gondola/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/gondola)
	AddElement(/datum/element/noticable_organ, "radiates an aura of serenity.")

/obj/item/organ/internal/heart/gondola/Insert(mob/living/carbon/receiver, special, drop_if_replaced)
	. = ..()
	if(!(FACTION_HOSTILE in receiver.faction))
		factions_to_remove += FACTION_HOSTILE
	if(!(FACTION_MINING in receiver.faction))
		factions_to_remove += FACTION_MINING
	receiver.faction |= list(FACTION_HOSTILE, FACTION_MINING)

/obj/item/organ/internal/heart/gondola/Remove(mob/living/carbon/heartless, special)
	. = ..()
	for(var/faction in factions_to_remove)
		heartless.faction -= faction
	//reset this for a different target
	factions_to_remove = list()

/// Zen (tounge): You can no longer speak, but get a powerful positive moodlet
/obj/item/organ/internal/tongue/gondola
	name = "mutated gondola-tongue"
	desc = "Gondola DNA infused into what was once a normal tongue."
	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "tongue"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = GONDOLA_COLORS
	organ_traits = TRAIT_MUTE

/obj/item/organ/internal/tongue/gondola/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "mouth is permanently affixed into a relaxed smile.", BODY_ZONE_PRECISE_MOUTH)
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/gondola)

/obj/item/organ/internal/tongue/gondola/Insert(mob/living/carbon/tongue_owner, special, drop_if_replaced)
	. = ..()
	tongue_owner.add_mood_event("gondola_zen", /datum/mood_event/gondola_serenity)

/obj/item/organ/internal/tongue/gondola/Remove(mob/living/carbon/tongue_owner, special)
	tongue_owner.clear_mood_event("gondola_zen")
	return ..()

/// Loving arms: your hands become unable to hold much of anything but your hugs now infuse the subject with pax.
/obj/item/organ/internal/liver/gondola
	name = "mutated gondola-liver"
	desc = "Gondola DNA infused into what was once a normal liver."
	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "liver"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = GONDOLA_COLORS
	/// instance of the martial art granted on insertion
	var/datum/martial_art/hugs_of_the_gondola/pax_hugs

/obj/item/organ/internal/liver/gondola/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/gondola)
	AddElement(/datum/element/noticable_organ, "left arm has small needles breaching the skin all over it.", BODY_ZONE_L_ARM)
	AddElement(/datum/element/noticable_organ, "right arm has small needles breaching the skin all over it.", BODY_ZONE_R_ARM)
	pax_hugs = new

/obj/item/organ/internal/liver/gondola/Insert(mob/living/carbon/liver_owner, special, drop_if_replaced)
	. = ..()
	var/has_left = liver_owner.has_left_hand(check_disabled = FALSE)
	var/has_right = liver_owner.has_right_hand(check_disabled = FALSE)
	if(has_left && has_right)
		to_chat(liver_owner, span_warning("Your arms grow terribly weak as small, needle-like pricks grow all over them!"))
	else if(has_left || has_right)
		to_chat(liver_owner, span_warning("Your arm grows terribly weak as small, needle-like pricks grow all over it!"))
	else
		to_chat(liver_owner, span_warning("You feel like something would be happening to your arms right now... if you still had them."))
	to_chat(liver_owner, span_notice("Hugging a target will pacify them, but you won't be able to carry much of anything anymore."))
	pax_hugs.teach(liver_owner)
	RegisterSignal(liver_owner, COMSIG_LIVING_PICKED_UP_ITEM, PROC_REF(on_owner_picked_up_item))
	RegisterSignal(liver_owner, COMSIG_LIVING_TRY_PULL, PROC_REF(on_owner_try_pull))

/obj/item/organ/internal/liver/gondola/Remove(mob/living/carbon/liver_owner, special)
	. = ..()
	pax_hugs.remove(liver_owner)
	UnregisterSignal(liver_owner, list(COMSIG_LIVING_PICKED_UP_ITEM, COMSIG_LIVING_TRY_PULL))

/obj/item/organ/internal/liver/gondola/proc/on_owner_picked_up_item(mob/living/carbon/owner, obj/item/picked_up)
	SIGNAL_HANDLER
	if(picked_up.w_class > WEIGHT_CLASS_TINY)
		owner.dropItemToGround(picked_up)
		picked_up.balloon_alert(owner, "too weak to hold this!")

/obj/item/organ/internal/liver/gondola/proc/on_owner_try_pull(mob/living/carbon/owner, atom/movable/target, force)
	SIGNAL_HANDLER
	if(isliving(target))
		var/mob/living/living_target = target
		if(living_target.mob_size > MOB_SIZE_TINY)
			living_target.balloon_alert(owner, "too weak to pull this!")
			return COMSIG_LIVING_CANCEL_PULL
	if(isitem(target))
		var/obj/item/item_target = target
		if(item_target.w_class > WEIGHT_CLASS_TINY)
			item_target.balloon_alert(owner, "too weak to pull this!")
			return COMSIG_LIVING_CANCEL_PULL

#undef GONDOLA_ORGAN_COLOR
#undef GONDOLA_SCLERA_COLOR
#undef GONDOLA_PUPIL_COLOR
#undef GONDOLA_COLORS
