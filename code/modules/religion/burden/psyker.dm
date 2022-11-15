/obj/item/organ/internal/brain/psyker
	name = "psyker brain"
	desc = "This brain is blue, split into two hemispheres, and has immense psychic powers. Why does that even exist?"
	icon_state = "brain-psyker"

/obj/item/organ/internal/brain/psyker/Insert(mob/living/carbon/inserted_into, special, drop_if_replaced, no_id_transfer)
	if(!istype(inserted_into.get_bodypart(BODY_ZONE_HEAD), /obj/item/bodypart/head/psyker))
		return
	. = ..()
	inserted_into.AddComponent(/datum/component/echolocation)

/obj/item/bodypart/head/psyker
	limb_id = BODYPART_ID_PSYKER
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodypart_traits = list(TRAIT_DISFIGURED, TRAIT_BALD, TRAIT_SHAVED, TRAIT_BLIND)

/mob/living/carbon/human/proc/psykerize()
	if(stat == DEAD || !get_bodypart(BODY_ZONE_HEAD))
		return
	to_chat(src, span_userdanger("You feel unwell..."))
	sleep(5 SECONDS)
	if(stat == DEAD || !get_bodypart(BODY_ZONE_HEAD))
		return
	to_chat(src, span_userdanger("It hurts!"))
	emote("scream")
	apply_damage(30, BRUTE, BODY_ZONE_HEAD)
	sleep(5 SECONDS)
	var/obj/item/bodypart/head/old_head = get_bodypart(BODY_ZONE_HEAD)
	var/obj/item/organ/internal/brain/old_brain = getorganslot(ORGAN_SLOT_BRAIN)
	var/obj/item/organ/internal/old_eyes = getorganslot(ORGAN_SLOT_EYES)
	var/obj/item/organ/internal/old_tongue = getorganslot(ORGAN_SLOT_TONGUE)
	if(stat == DEAD || !old_head || !old_brain)
		return
	to_chat(src, span_userdanger("Your head splits open! Your brain mutates!"))
	emote("scream")
	var/obj/item/bodypart/head/psyker/psyker_head = new()
	psyker_head.receive_damage(brute = 50)
	if(!psyker_head.replace_limb(src, special = TRUE))
		return
	qdel(old_head)
	var/obj/item/organ/internal/brain/psyker/psyker_brain = new()
	old_brain.before_organ_replacement(psyker_brain)
	old_brain.Remove(src, special = TRUE, no_id_transfer = TRUE)
	qdel(old_brain)
	psyker_brain.Insert(src, special = TRUE, drop_if_replaced = FALSE)
	if(old_eyes)
		qdel(old_eyes)
	if(old_tongue)
		var/obj/item/organ/internal/tongue/tied/new_tongue = new()
		new_tongue.Insert(src, special = TRUE, drop_if_replaced = FALSE)

/atom/movable/screen/fullscreen/echo
	icon_state = "echo"

/atom/movable/screen/fullscreen/warped
	plane = GRAVITY_PULSE_PLANE
	icon_state = "screen_warp"
