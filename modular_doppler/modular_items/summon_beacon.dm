/obj/item/choice_beacon/coffee
	name = "coffeemaker beacon"
	desc = "Summons coffee, because who can function without it?"
	icon_state = "sb_delivery"
	inhand_icon_state = "sb_delivery"
	company_source = "Piccionaia Home Appliances"
	company_message = span_bold("Please enjoy your Piccionaia Home Appliances Impressa Modello 5 Coffeemaker, from our premium product line. You little sycophant, you.")

/obj/item/choice_beacon/coffee/generate_display_names()
	var/static/list/coffee_crate_list
	if(!coffee_crate_list)
		coffee_crate_list = list()
		for(var/obj/structure/closet/crate/silvercrate/coffeemaker/box as anything in typesof(/obj/structure/closet/crate/silvercrate/coffeemaker))
			coffee_crate_list[initial(box.name)] = box
	return coffee_crate_list

/obj/structure/closet/crate/silvercrate/coffeemaker
	name = "Impressa Modello 5 Coffeemaker - Unbranded Package"
	desc = "Neutral. Non-corporate. Non-government. It's pretty good."

/obj/structure/closet/crate/silvercrate/coffeemaker/PopulateContents()
	new /obj/machinery/coffeemaker/impressa(src)
	new /obj/item/storage/box/coffeepack/robusta(src)
	new /obj/item/storage/box/coffeepack(src)
	new /obj/item/reagent_containers/cup/coffeepot(src)
	new /obj/item/storage/fancy/coffee_condi_display(src)
	new /obj/item/reagent_containers/cup/glass/bottle/juice/cream(src)
	new /obj/item/reagent_containers/condiment/milk(src)
	new /obj/item/reagent_containers/condiment/soymilk(src)
	new /obj/item/reagent_containers/condiment/sugar(src)
	new /obj/item/reagent_containers/cup/bottle/syrup_bottle/caramel(src)
	new /obj/item/reagent_containers/cup/glass/mug (src)
	new /obj/item/reagent_containers/cup/glass/mug (src)
	new /obj/item/reagent_containers/cup/glass/mug (src)
	new /obj/item/reagent_containers/cup/glass/mug (src)
	new /obj/item/reagent_containers/cup/glass/mug (src)
	new /obj/item/reagent_containers/cup/glass/mug (src)
	new /obj/item/reagent_containers/cup/glass/mug (src)
	new /obj/item/storage/coffee (src)
	new /obj/item/storage/coffee (src)

/obj/structure/closet/crate/silvercrate/coffeemaker/nanotrasen
	name = "Impressa Modello 5 Coffeemaker - NanoTrasen Corporate Package"
	desc = "This particular one contains a bunch of NanoTrasen branded mugs. You don't like this."

/obj/structure/closet/crate/silvercrate/coffeemaker/nanotrasen/PopulateContents()
	new /obj/item/reagent_containers/cup/glass/mug/nanotrasen (src)
	new /obj/item/reagent_containers/cup/glass/mug/nanotrasen (src)
	new /obj/item/reagent_containers/cup/glass/mug/nanotrasen (src)
	new /obj/item/reagent_containers/cup/glass/mug/nanotrasen (src)
	new /obj/item/reagent_containers/cup/glass/mug/nanotrasen (src)
	new /obj/item/reagent_containers/cup/glass/mug/nanotrasen (src)
	new /obj/item/reagent_containers/cup/glass/mug/nanotrasen (src)
	new /obj/machinery/coffeemaker/impressa(src)
	new /obj/item/storage/box/coffeepack/robusta(src)
	new /obj/item/storage/box/coffeepack(src)
	new /obj/item/reagent_containers/cup/coffeepot(src)
	new /obj/item/storage/fancy/coffee_condi_display(src)
	new /obj/item/reagent_containers/cup/glass/bottle/juice/cream(src)
	new /obj/item/reagent_containers/condiment/milk(src)
	new /obj/item/reagent_containers/condiment/soymilk(src)
	new /obj/item/reagent_containers/condiment/sugar(src)
	new /obj/item/reagent_containers/cup/bottle/syrup_bottle/caramel(src)
	new /obj/item/storage/coffee (src)
	new /obj/item/storage/coffee (src)

/obj/item/reagent_containers/cup/glass/mug/nanotrasen
	desc = "Look at this shit. A cobalt monument to mid-level managerial despair, slathered in NT's signature 'corporate pacification blue' guaranteed to drain the soul 12% faster. Note the ergonomic handle designed by someone who's definitely never held hands with another sapient being. The rim's perfectly calibrated to burn your lips while you choke down overpriced synthcaf, because even your breaks belong to NanoTrasen. The bottom of the cup's got that subtle 'ethical violations' stain pattern that never quite scrubs out. Freedom of choice sold separately."
