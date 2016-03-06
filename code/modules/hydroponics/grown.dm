// ***********************************************************
// Foods that are produced from hydroponics ~~~~~~~~~~
// Data from the seeds carry over to these grown foods
// ***********************************************************

// Base type. Subtypes are found in /grown.
/obj/item/weapon/reagent_containers/food/snacks/grown
	icon = 'icons/obj/hydroponics/harvest.dmi'
	var/seed = null
	var/plantname = ""
	var/product	//a type path
	var/lifespan = 0
	var/endurance = 0
	var/maturation = 0
	var/production = 0
	var/yield = 0
	var/plant_type = PLANT_NORMAL
	var/bitesize_mod = 0
	// If set, bitesize = 1 + round(reagents.total_volume / bitesize_mod)
	var/list/reagents_add = list()
	// A list of reagents to add.
	// Format: "reagent_id" = potency multiplier
	// Stronger reagents must always come first to avoid being displaced by weaker ones.
	// Total amount of any reagent in plant is calculated by formula: 1 + round(potency * multiplier)
	potency = -1
	dried_type = -1
	// Saves us from having to define each stupid grown's dried_type as itself.
	// If you don't want a plant to be driable (watermelons) set this to null in the time definition.
	burn_state = FLAMMABLE

/obj/item/weapon/reagent_containers/food/snacks/grown/New(newloc, new_potency = 50)
	..()
	potency = new_potency
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

	if(dried_type == -1)
		dried_type = src.type

	if(seed && lifespan == 0)
		// This is for adminspawn or map-placed growns. They get the default stats of their seed type. This feels like a hack but people insist on putting these things on the map...
		var/obj/item/seeds/S = new seed(src)
		lifespan = S.lifespan
		endurance = S.endurance
		maturation = S.maturation
		production = S.production
		yield = S.yield
		qdel(S) //Foods drop their contents when eaten, so delete the default seed.

	add_juice()

	transform *= TransformUsingVariable(potency, 100, 0.5) //Makes the resulting produce's sprite larger or smaller based on potency!


/obj/item/weapon/reagent_containers/food/snacks/grown/proc/add_juice()
	if(reagents)
		for(var/reagent_id in reagents_add)
			if(reagent_id == "blood") // Hack to make blood in plants always O-
				reagents.add_reagent(reagent_id, 1 + round(potency * reagents_add[reagent_id]), list("blood_type"="O-"))
				continue
			reagents.add_reagent(reagent_id, 1 + round(potency * reagents_add[reagent_id]))
		if(bitesize_mod)
			bitesize = 1 + round(reagents.total_volume / bitesize_mod)
		return 1
	return 0

/obj/item/weapon/reagent_containers/food/snacks/grown/attackby(obj/item/O, mob/user, params)
	..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		var/msg
		msg = "<span class='info'>*---------*\n This is \a <span class='name'>[src]</span>\n"
		switch(plant_type)
			if(PLANT_NORMAL)
				msg += "- Plant type: <i>Normal plant</i>\n"
			if(PLANT_WEED)
				msg += "- Plant type: <i>Weed</i>.  Can grow in nutrient-poor soil.\n"
			if(PLANT_MUSHROOM)
				msg += "- Plant type: <i>Mushroom</i>.  Can grow in dry soil.\n"
			else
				msg += "- Plant type: <i>UNKNOWN</i>. \n"
		msg += "- Potency: <i>[potency]</i>\n"
		msg += "- Yield: <i>[yield]</i>\n"
		msg += "- Maturation speed: <i>[maturation]</i>\n"
		msg += "- Production speed: <i>[production]</i>\n"
		msg += "- Endurance: <i>[endurance]</i>\n"
		msg += "- Nutritional value: <i>[reagents.get_reagent_amount("nutriment")]</i>\n"
		msg += "- Other substances: <i>[reagents.total_volume-reagents.get_reagent_amount("nutriment")]</i>\n"
		msg += "*---------*</span>"

		var/list/scannable_reagents = list("charcoal" = "Anti-Toxin", "morphine" = "Morphine", "amatoxin" = "Amatoxins",
			"toxin" = "Toxins", "mushroomhallucinogen" = "Mushroom Hallucinogen", "condensedcapsaicin" = "Condensed Capsaicin",
			"capsaicin" = "Capsaicin", "frostoil" = "Frost Oil", "gold" = "Mineral Content",
			"radium" = "Highly Radioactive Material", "uranium" = "Radioactive Material")
		var/reag_txt = ""
		for(var/reagent_id in scannable_reagents)
			if(reagent_id in reagents_add)
				var/amt = reagents.get_reagent_amount(reagent_id)
				reag_txt += "<span class='info'>- [scannable_reagents[reagent_id]]: [amt*100/reagents.maximum_volume]%</span>\n"

		user << msg
		if(reag_txt)
			user << reag_txt
			user << "<span class='info'>*---------*</span>"
		return
	return


/obj/item/weapon/reagent_containers/food/snacks/grown/shell/attack_self(mob/user as mob)
	if(trash)
		new trash(user.loc)
	user.unEquip(src)
	qdel(src)