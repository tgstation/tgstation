// This file contains all boxes used by the Medical department, or otherwise associated with the task of mob interactions.

/obj/item/storage/box/syringes
	name = "box of syringes"
	desc = "A box full of syringes."
	illustration = "syringe"

/obj/item/storage/box/syringes/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/syringe(src)

/obj/item/storage/box/syringes/variety
	name = "syringe variety box"

/obj/item/storage/box/syringes/variety/PopulateContents()
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/reagent_containers/syringe/lethal(src)
	new /obj/item/reagent_containers/syringe/piercing(src)
	new /obj/item/reagent_containers/syringe/bluespace(src)

/obj/item/storage/box/medipens
	name = "box of medipens"
	desc = "A box full of epinephrine MediPens."
	illustration = "epipen"

/obj/item/storage/box/medipens/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/hypospray/medipen(src)

/obj/item/storage/box/medipens/utility
	name = "stimpack value kit"
	desc = "A box with several stimpack medipens for the economical miner."
	illustration = "epipen"

/obj/item/storage/box/medipens/utility/PopulateContents()
	..() // includes regular medipens.
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/hypospray/medipen/stimpack(src)

/obj/item/storage/box/beakers
	name = "box of beakers"
	illustration = "beaker"

/obj/item/storage/box/beakers/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/cup/beaker( src )

/obj/item/storage/box/beakers/bluespace
	name = "box of bluespace beakers"
	illustration = "beaker"

/obj/item/storage/box/beakers/bluespace/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/cup/beaker/bluespace(src)

/obj/item/storage/box/beakers/variety
	name = "beaker variety box"

/obj/item/storage/box/beakers/variety/PopulateContents()
	new /obj/item/reagent_containers/cup/beaker(src)
	new /obj/item/reagent_containers/cup/beaker/bluespace(src)
	new /obj/item/reagent_containers/cup/beaker/large(src)
	new /obj/item/reagent_containers/cup/beaker/meta(src)
	new /obj/item/reagent_containers/cup/beaker/noreact(src)
	new /obj/item/reagent_containers/cup/beaker/plastic(src)

/obj/item/storage/box/medigels
	name = "box of medical gels"
	desc = "A box full of medical gel applicators, with unscrewable caps and precision spray heads."
	illustration = "medgel"

/obj/item/storage/box/medigels/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/medigel( src )

/obj/item/storage/box/injectors
	name = "box of DNA injectors"
	desc = "This box contains injectors, it seems."
	illustration = "dna"

/obj/item/storage/box/injectors/PopulateContents()
	var/static/items_inside = list(
		/obj/item/dnainjector/h2m = 3,
		/obj/item/dnainjector/m2h = 3,
	)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/bodybags
	name = "body bags"
	desc = "The label indicates that it contains body bags."
	illustration = "bodybags"

/obj/item/storage/box/bodybags/PopulateContents()
	..()
	for(var/i in 1 to 7)
		new /obj/item/bodybag(src)

/obj/item/storage/box/pillbottles
	name = "box of pill bottles"
	desc = "It has pictures of pill bottles on its front."
	illustration = "pillbox"

/obj/item/storage/box/pillbottles/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/storage/pill_bottle(src)

/obj/item/storage/box/plumbing/PopulateContents()
	var/list/items_inside = list(
		/obj/item/stock_parts/water_recycler = 2,
		/obj/item/stack/ducts/fifty = 1,
		/obj/item/stack/sheet/iron/ten = 1,
		)
	generate_items_inside(items_inside, src)

/obj/item/storage/box/evilmeds
	name = "box of premium medicine"
	desc = "Contains a large number of beakers filled with premium medical supplies. Straight from Interdyne Pharmaceutics!"
	icon_state = "syndiebox"
	illustration = "beaker"

/obj/item/storage/box/evilmeds/PopulateContents()
	var/static/list/items_inside = list(
		/obj/item/reagent_containers/cup/beaker/meta/omnizine = 1,
		/obj/item/reagent_containers/cup/beaker/meta/sal_acid = 1,
		/obj/item/reagent_containers/cup/beaker/meta/oxandrolone = 1,
		/obj/item/reagent_containers/cup/beaker/meta/pen_acid = 1,
		/obj/item/reagent_containers/cup/beaker/meta/atropine = 1,
		/obj/item/reagent_containers/cup/beaker/meta/salbutamol = 1,
		/obj/item/reagent_containers/cup/beaker/meta/rezadone = 1,
	)
	generate_items_inside(items_inside, src)
