/obj/item/clothing/mask/breath
	desc = "A close-fitting mask that can be connected to an air supply."
	name = "breath mask"
	icon_state = "breath"
	item_state = "breath"
	flags = FPRINT | MASKINTERNALS
	w_class = 2
	gas_transfer_coefficient = 0.10
	permeability_coefficient = 0.50
	species_fit = list("Vox")
	body_parts_covered = HEAD|MOUTH
	can_flip = 1



/obj/item/clothing/mask/breath/medical
	desc = "A close-fitting sterile mask that can be connected to an air supply."
	name = "medical mask"
	icon_state = "medical"
	item_state = "medical"
	permeability_coefficient = 0.01
	species_fit = list("Vox")

/obj/item/clothing/mask/breath/vox
	desc = "A weirdly-shaped breath mask."
	name = "vox breath mask"
	icon_state = "voxmask"
	item_state = "voxmask"
	permeability_coefficient = 0.01
	species_restricted = list("Vox")