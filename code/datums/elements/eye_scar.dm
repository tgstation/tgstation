/// Adds an overlay to a pair of eyes and their owner and makes the owner nearsighted (or blind if both eyeballs are scarred)
/datum/element/eye_scar
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Side on which we have our eye scar
	var/right_side = FALSE

/datum/element/eye_scar/Attach(datum/target, right_side = FALSE)
	. = ..()
	if (!istype(target, /obj/item/organ/internal/eyes))
		return ELEMENT_INCOMPATIBLE

	src.right_side = right_side
	var/obj/item/organ/internal/eyes/eyeballs = target
	ADD_TRAIT(eyeballs, right_side ? TRAIT_RIGHT_EYE_SCAR : TRAIT_LEFT_EYE_SCAR, REF(src))
	RegisterSignal(eyeballs, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(organ_overlays))
	RegisterSignal(eyeballs, COMSIG_ORGAN_EYE_OVERLAY, PROC_REF(eye_overlays))
	RegisterSignal(eyeballs, COMSIG_ORGAN_IMPLANTED, PROC_REF(on_implanted))
	RegisterSignal(eyeballs, COMSIG_ORGAN_REMOVED, PROC_REF(on_removed))
	eyeballs.update_appearance()
	if (!isnull(eyeballs.owner))
		on_implanted(eyeballs, eyeballs.owner)
		eyeballs.owner.update_body()

/datum/element/eye_scar/Detach(obj/item/organ/internal/eyes/source, ...)
	. = ..()
	UnregisterSignal(source, list(COMSIG_ATOM_UPDATE_OVERLAYS, COMSIG_ORGAN_EYE_OVERLAY, COMSIG_ORGAN_IMPLANTED, COMSIG_ORGAN_REMOVED))
	REMOVE_TRAIT(source, right_side ? TRAIT_LEFT_EYE_SCAR : TRAIT_RIGHT_EYE_SCAR, REF(src))

/datum/element/eye_scar/proc/organ_overlays(datum/source, list/overlays)
	SIGNAL_HANDLER
	overlays += mutable_appearance('icons/obj/medical/organs/organs.dmi', "eye_scar_[right_side ? "right" : "left"]")

/datum/element/eye_scar/proc/eye_overlays(datum/source, mob/living/carbon/human/parent, list/overlays)
	SIGNAL_HANDLER
	var/mutable_appearance/scar_overlay = mutable_appearance('icons/mob/human/human_face.dmi', "eye_scar_[right_side ? "right" : "left"]", -BODY_LAYER)
	var/obj/item/bodypart/head/head = parent.get_bodypart(BODY_ZONE_HEAD)
	if (istype(head))
		scar_overlay.color = head.draw_color
	overlays += scar_overlay

/datum/element/eye_scar/proc/on_implanted(obj/item/organ/source, mob/living/carbon/receiver)
	SIGNAL_HANDLER
	var/scar_trait = right_side ? TRAIT_RIGHT_EYE_SCAR : TRAIT_LEFT_EYE_SCAR
	ADD_TRAIT(receiver, scar_trait, REF(source))
	var/datum/status_effect/grouped/nearsighted/nearsightedness = receiver.is_nearsighted()
	// Even if eyes have enough health, our owner still becomes nearsighted
	receiver.become_nearsighted(scar_trait)
	if (isnull(nearsightedness)) // We aren't nearsighted from any other source
		nearsightedness = receiver.is_nearsighted()
		nearsightedness.set_nearsighted_severity(1)
	// If our owner has a scar on the opposite side of the face as well, they go blind
	if (HAS_TRAIT(receiver, right_side ? TRAIT_LEFT_EYE_SCAR : TRAIT_RIGHT_EYE_SCAR))
		receiver.become_blind(EYE_SCARRING_TRAIT) // We don't care which scar caused blindness when removing it

/datum/element/eye_scar/proc/on_removed(obj/item/organ/source, mob/living/carbon/loser)
	SIGNAL_HANDLER
	var/scar_trait = right_side ? TRAIT_RIGHT_EYE_SCAR : TRAIT_LEFT_EYE_SCAR
	REMOVE_TRAIT(loser, scar_trait, REF(source))
	loser.cure_nearsighted(scar_trait)
	loser.cure_blind(EYE_SCARRING_TRAIT)
