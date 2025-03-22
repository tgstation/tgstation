// This file contains all boxes used by the Medical department, or otherwise associated with the task of mob interactions.

/obj/item/storage/box/syringes
	name = "box of syringes"
	desc = "A box full of syringes."
	illustration = "syringe"

/obj/item/storage/box/syringes/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/reagent_containers/syringe

/obj/item/storage/box/syringes/variety
	name = "syringe variety box"

/obj/item/storage/box/syringes/variety/PopulateContents()
	return list(
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/syringe/lethal,
		/obj/item/reagent_containers/syringe/piercing,
		/obj/item/reagent_containers/syringe/bluespace,
	)

/obj/item/storage/box/medipens
	name = "box of medipens"
	desc = "A box full of epinephrine MediPens."
	illustration = "epipen"

/obj/item/storage/box/medipens/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/reagent_containers/hypospray/medipen

/obj/item/storage/box/medipens/utility
	name = "stimpack value kit"
	desc = "A box with several stimpack medipens for the economical miner."
	illustration = "epipen"

/obj/item/storage/box/medipens/utility/PopulateContents(datum/storage_config/config)
	config.compute_max_item_count = TRUE

	. = ..() // includes regular medipens.
	for(var/i in 1 to 5)
		. += /obj/item/reagent_containers/hypospray/medipen/stimpack

/obj/item/storage/box/beakers
	name = "box of beakers"
	illustration = "beaker"

/obj/item/storage/box/beakers/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/reagent_containers/cup/beaker

/obj/item/storage/box/beakers/bluespace
	name = "box of bluespace beakers"
	illustration = "beaker"

/obj/item/storage/box/beakers/bluespace/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/reagent_containers/cup/beaker/bluespace

/obj/item/storage/box/beakers/variety
	name = "beaker variety box"

/obj/item/storage/box/beakers/variety/PopulateContents()
	return list(
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/beaker/bluespace,
		/obj/item/reagent_containers/cup/beaker/large,
		/obj/item/reagent_containers/cup/beaker/meta,
		/obj/item/reagent_containers/cup/beaker/noreact,
		/obj/item/reagent_containers/cup/beaker/plastic,
	)

/obj/item/storage/box/medigels
	name = "box of medical gels"
	desc = "A box full of medical gel applicators, with unscrewable caps and precision spray heads."
	illustration = "medgel"

/obj/item/storage/box/medigels/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/reagent_containers/medigel

/obj/item/storage/box/injectors
	name = "box of DNA injectors"
	desc = "This box contains injectors, it seems."
	illustration = "dna"

/obj/item/storage/box/injectors/PopulateContents()
	var/static/items_inside = flatten_quantified_list(list(
		/obj/item/dnainjector/h2m = 3,
		/obj/item/dnainjector/m2h = 3,
	))

	return items_inside

/obj/item/storage/box/bodybags
	name = "body bags"
	desc = "The label indicates that it contains body bags."
	illustration = "bodybags"

/obj/item/storage/box/bodybags/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/bodybag

/obj/item/storage/box/pillbottles
	name = "box of pill bottles"
	desc = "It has pictures of pill bottles on its front."
	illustration = "pillbox"

/obj/item/storage/box/pillbottles/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/storage/pill_bottle

/obj/item/storage/box/plumbing/PopulateContents(datum/storage_config/config)
	config.compute_max_item_weight = TRUE

	return list(
		/obj/item/stock_parts/water_recycler,
		/obj/item/stock_parts/water_recycler,
		/obj/item/stack/ducts/fifty,
		/obj/item/stack/sheet/iron/ten,
	)

/obj/item/storage/box/evilmeds
	name = "box of premium medicine"
	desc = "Contains a large number of beakers filled with premium medical supplies. Straight from Interdyne Pharmaceutics!"
	icon_state = "syndiebox"
	illustration = "beaker"

/obj/item/storage/box/evilmeds/PopulateContents()
	var/static/list/items_inside = list(
		/obj/item/reagent_containers/cup/beaker/meta/omnizine,
		/obj/item/reagent_containers/cup/beaker/meta/sal_acid,
		/obj/item/reagent_containers/cup/beaker/meta/oxandrolone,
		/obj/item/reagent_containers/cup/beaker/meta/pen_acid,
		/obj/item/reagent_containers/cup/beaker/meta/atropine,
		/obj/item/reagent_containers/cup/beaker/meta/salbutamol,
		/obj/item/reagent_containers/cup/beaker/meta/rezadone,
	)

	return items_inside

/obj/item/storage/box/bandages
	name = "box of bandages"
	desc = "A box of DeForest brand gel bandages designed to treat blunt-force trauma."
	icon_state = "brutebox"
	base_icon_state = "brutebox"
	inhand_icon_state = "brutebox"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	drop_sound = 'sound/items/handling/matchbox_drop.ogg'
	pickup_sound = 'sound/items/handling/matchbox_pickup.ogg'
	illustration = null
	w_class = WEIGHT_CLASS_SMALL
	custom_price = PAYCHECK_CREW * 1.75
	storage_type = /datum/storage/box/bandages

/obj/item/storage/box/bandages/PopulateContents()
	. = list()
	for(var/i in 1 to 5)
		. += /obj/item/stack/medical/bandage

/obj/item/storage/box/bandages/update_icon_state()
	. = ..()
	switch(length(contents))
		if(5)
			icon_state = "[base_icon_state]_f"
		if(3 to 4)
			icon_state = "[base_icon_state]_almostfull"
		if(1 to 2)
			icon_state = "[base_icon_state]_almostempty"
		if(0)
			icon_state = base_icon_state
