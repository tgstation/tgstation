/obj/item/clothing/mask/breath
	desc = "A close-fitting mask that can be connected to an air supply."
	name = "breath mask"
	icon_state = "breath"
	item_state = "breath"
	flags = FPRINT | TABLEPASS | MASKCOVERSMOUTH | MASKINTERNALS
	w_class = 2
	gas_transfer_coefficient = 0.10
	permeability_coefficient = 0.50
	species_fit = list("Vox")
	var/hanging = 0

	verb/toggle()
		set category = "Object"
		set name = "Adjust mask"
		set src in usr

		if(usr.canmove && !usr.stat && !usr.restrained())
			if(!src.hanging)
				src.hanging = !src.hanging
				gas_transfer_coefficient = 1 //gas is now escaping to the turf and vice versa
				flags &= ~(MASKCOVERSMOUTH | MASKINTERNALS)
				icon_state = "[initial(icon_state)]down"
				usr << "Your mask is now hanging on your neck."

			else
				src.hanging = !src.hanging
				gas_transfer_coefficient = 0.10
				flags |= MASKCOVERSMOUTH | MASKINTERNALS
				icon_state = "[initial(icon_state)]"
				usr << "You pull the mask up to cover your face."
			usr.update_inv_wear_mask()

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