/obj/item/clothing/mask/breath
	desc = "A close-fitting mask that can be connected to an air supply."
	name = "breath mask"
	icon_state = "breath"
	item_state = "breath"
	flags = FPRINT | TABLEPASS | MASKCOVERSMOUTH | MASKINTERNALS
	w_class = 2
	gas_transfer_coefficient = 0.10
	permeability_coefficient = 0.50
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
				icon_state = "breathdown"
				usr << "Your mask is now hanging on your neck."

			else
				src.hanging = !src.hanging
				gas_transfer_coefficient = 0.10
				flags |= MASKCOVERSMOUTH | MASKINTERNALS
				icon_state = "breath"
				usr << "You pull the mask up to cover your face."
			usr.update_inv_wear_mask()

/obj/item/clothing/mask/breath/medical
	desc = "A close-fitting sterile mask that can be connected to an air supply."
	name = "medical mask"
	icon_state = "medical"
	item_state = "medical"
	permeability_coefficient = 0.01

/obj/item/clothing/mask/breath/vox
	desc = "A weirdly-shaped breath mask."
	name = "vox breath mask"
	icon_state = "voxmask"
	item_state = "voxmask"
	permeability_coefficient = 0.01

	toggle()
		set category = "Object"
		set name = "Adjust mask"
		set src in usr

		usr << "You can't really adjust this mask - it's moulded to your beak!"

/obj/item/clothing/mask/breath/vox/mob_can_equip(M as mob, slot)
	var/mob/living/carbon/human/V = M
	if(V.species.name != "Vox")
		V << "<span class='warning'>This clearly isn't designed for your species!</span>"
		return 0

	return ..()
