//These machines are mostly just here for debugging/spawning. Skeletons of the feature to come.

/obj/machinery/bioprinter
	name = "bioprinter"
	desc = "It's a machine that grows replacement organs."
	icon = 'icons/obj/surgery.dmi'

	icon_state = "bioprinter"

	var/prints_prosthetics
	var/stored_matter = 200
	var/loaded_dna //Blood sample for DNA hashing.
	var/list/products = list(
		"heart" =   list(/obj/item/organ/heart,  50),
		"lungs" =   list(/obj/item/organ/lungs,  40),
		"kidneys" = list(/obj/item/organ/kidneys,20),
		"eyes" =    list(/obj/item/organ/eyes,   30),
		"liver" =   list(/obj/item/organ/liver,  50)
		)

/obj/machinery/bioprinter/prosthetics
	name = "prosthetics fabricator"
	desc = "It's a machine that prints prosthetic organs."
	prints_prosthetics = 1

/obj/machinery/bioprinter/attack_hand(mob/user)

	var/choice = input("What would you like to print?") as null|anything in products
	if(!choice)
		return

	if(stored_matter >= products[choice][2])

		stored_matter -= products[choice][2]
		var/new_organ = products[choice][1]
		var/obj/item/organ/O = new new_organ(get_turf(src))

		if(prints_prosthetics)
			O.robotic = 2
		else if(loaded_dna)
			visible_message("The printer would be using the DNA sample if it was coded.")
			//TODO: Copy DNA hash or donor reference over to new organ.

		visible_message("The bioprinter spits out a new organ.")

	else
		user << "There is not enough matter in the printer."

/obj/machinery/bioprinter/attackby(obj/item/weapon/W, mob/user)

	// DNA sample from syringe.
	if(!prints_prosthetics && istype(W,/obj/item/weapon/reagent_containers/syringe))
		user << "You inject the blood sample into the bioprinter, but it isn't coded yet."
		return
	// Meat for biomass.
	else if(!prints_prosthetics && istype(W, /obj/item/weapon/reagent_containers/food/snacks/meat))
		user << "\blue \The [src] processes \the [W]."
		stored_matter += 50
		user.drop_item()
		del(W)
		return
	// Steel for matter.
	else if(prints_prosthetics && istype(W, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = W
		user << "\blue \The [src] processes \the [W]."
		stored_matter += M.amount * 10
		user.drop_item()
		del(W)
		return
	else
		return..()