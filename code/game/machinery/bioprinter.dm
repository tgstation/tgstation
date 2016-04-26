//These machines are mostly just here for debugging/spawning. Skeletons of the feature to come.

/obj/machinery/bioprinter
	name = "bioprinter"
	desc = "It's a machine that grows replacement organs using meat and metal."
	icon = 'icons/obj/surgery.dmi'

	icon_state = "bioprinter"

	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 50

	light_color = LIGHT_COLOR_CYAN
	light_range_on = 3
	light_power_on = 2
	use_auto_lights = 1

	var/prints_prosthetics
	var/stored_matter = 200
	var/loaded_dna //Blood sample for DNA hashing.
	var/list/products = list(
		"heart"            = list(/obj/item/organ/heart,  50),
		"human lungs"      = list(/obj/item/organ/lungs,  30),
		"vox lungs"        = list(/obj/item/organ/lungs/vox,  30),
		"plasmaman lungs"  = list(/obj/item/organ/lungs/plasmaman,  30),
		"kidneys"          = list(/obj/item/organ/kidneys,20),
		"human eyes"       = list(/obj/item/organ/eyes,   30),
		"grey eyes"        = list(/obj/item/organ/eyes/grey,   30),
		"vox eyes"        = list(/obj/item/organ/eyes/vox,   30),
		"liver"            = list(/obj/item/organ/liver,  50)
	)

/obj/machinery/bioprinter/New()
	. = ..()

	component_parts = newlist(\
		/obj/item/weapon/circuitboard/bioprinter,\
		/obj/item/weapon/stock_parts/manipulator,\
		/obj/item/weapon/stock_parts/manipulator,\
		/obj/item/weapon/stock_parts/matter_bin,\
		/obj/item/weapon/stock_parts/matter_bin,\
		/obj/item/weapon/stock_parts/micro_laser,\
		/obj/item/weapon/stock_parts/micro_laser,\
		/obj/item/weapon/stock_parts/micro_laser,\
		/obj/item/weapon/stock_parts/scanning_module,\
		/obj/item/weapon/stock_parts/scanning_module,\
		/obj/item/weapon/stock_parts/console_screen\
	)

	RefreshParts()

/obj/machinery/bioprinter/prosthetics
	name = "prosthetics fabricator"
	desc = "It's a machine that prints prosthetic organs."
	prints_prosthetics = 1

/obj/machinery/bioprinter/attack_hand(mob/user)
	if(!ishuman(user))
		return

	var/choice = input("What would you like to print?") as null|anything in products
	if(!choice)
		return

	if(stored_matter >= products[choice][2])

		stored_matter -= products[choice][2]
		var/new_organ = products[choice][1]
		var/obj/item/organ/O = new new_organ(get_turf(src))

		if(prints_prosthetics)
			O.robotic = 2
		//else if(loaded_dna)
			//visible_message("<span class='notice'>The printer would be using the DNA sample if it was coded.</span>")
			//TODO: Copy DNA hash or donor reference over to new organ.

		visible_message("<span class='notice'>\The [src] spits out a brand new organ.</span>")

	else
		visible_message("<span class='warning'>\The [src]'s error light flickers. It can't make new organs out of thin air, fill it up first.</span>")

/obj/machinery/bioprinter/attackby(obj/item/weapon/W, mob/user)

	// DNA sample from syringe.
	if(!prints_prosthetics && istype(W, /obj/item/weapon/reagent_containers/syringe))
		//Finish the feature first, muh immulsions
//		to_chat(user, "<span class='notice'>You inject the blood sample into \the [src], but it simply drains away through a tube in the back.</span>.")
		return
	// Meat for biomass.
	else if(!prints_prosthetics && istype(W, /obj/item/weapon/reagent_containers/food/snacks/meat))
		if(user.drop_item(W))
			visible_message("<span class='notice'>\The [src] processes \the [W].</span>")
			stored_matter += 50
			qdel(W)
			return
	// Steel for matter.
	else if(prints_prosthetics && istype(W, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = W
		if(user.drop_item(M))
			visible_message("<span class='notice'>\The [src] processes \the [W].</span>")
			stored_matter += M.amount * 10
			returnToPool(M)
			return
	else if(iswrench(W))
		user.visible_message("<span class='notice'>[user] begins to [anchored? "unfasten" : "fasten"] \the [src].</span>", "<span class='notice'>You begin to [anchored? "unfasten" : "fasten"] \the [src].</span>", "<span class='notice'>You hear a ratchet.</span>")
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user, src, 30))
			user.visible_message("<span class='notice'>[user] begins to [anchored? "unfasten" : "fasten"] \the [src].</span>", "<span class='notice'>You [anchored? "unfasten" : "fasten"] \the [src].</span>", "<span class='notice'>You hear a ratchet.</span>")
			if(anchored)
				src.anchored = 0
			else
				src.anchored = 1
	else
		return..()
