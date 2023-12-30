/obj/item/organ/internal/eyes/robotic/clockwork
	name = "biometallic receptors"
	desc = "A fragile set of small, mechanical cameras."
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'
	icon_state = "clockwork_eyeballs"

/obj/item/organ/internal/eyes/night_vision/arachnid
	name = "arachnid eyes"
	desc = "So many eyes!"
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'
	eye_icon_state = "arachnideyes"
	icon_state = "arachnid_eyeballs"
	overlay_ignore_lighting = TRUE
	no_glasses = TRUE
	low_light_cutoff = list(20, 15, 0)
	medium_light_cutoff = list(35, 30, 0)
	high_light_cutoff = list(50, 40, 0)

/obj/item/organ/internal/eyes/night_vision/arachnid/on_insert(mob/living/carbon/tongue_owner)
	. = ..()
	if(!ishuman(tongue_owner))
		return
	var/mob/living/carbon/human/human_receiver = tongue_owner
	if(!human_receiver.can_mutate())
		return
	var/datum/species/rec_species = human_receiver.dna.species
	rec_species.update_no_equip_flags(tongue_owner, rec_species.no_equip_flags | ITEM_SLOT_EYES)

/obj/item/organ/internal/eyes/night_vision/arachnid/on_remove(mob/living/carbon/tongue_owner)
	. = ..()
	if(!ishuman(tongue_owner))
		return
	var/mob/living/carbon/human/human_receiver = tongue_owner
	if(!human_receiver.can_mutate())
		return
	var/datum/species/rec_species = human_receiver.dna.species
	rec_species.update_no_equip_flags(tongue_owner, initial(rec_species.no_equip_flags))

/obj/item/organ/internal/eyes/floran
	name = "phytoid eyes"
	desc = "They look like big berries..."
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'
	eye_icon_state = "floraneyes"
	icon_state = "floran_eyeballs"
