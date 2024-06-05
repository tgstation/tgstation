/datum/bodypart_overlay/mutant/get_extended_overlay(layer, obj/item/bodypart/limb) // MASSMETA ADDITION
	layer = bitflag_to_layer(layer)
	var/passed_color = sprite_datum.color_src ? draw_color : null
	var/mob/living/carbon/human/owner = limb.owner
	if(!owner)
		return
	var/datum/species/owner_species = owner.dna.species

	return owner_species.return_accessory_layer(-layer, sprite_datum, owner, passed_color)