// ***********************************************************
// Foods that are produced from hydroponics ~~~~~~~~~~
// Data from the seeds carry over to these grown foods
// ***********************************************************

// Base type. Subtypes are found in /grown dir.
/obj/item/weapon/reagent_containers/food/snacks/grown
	icon = 'icons/obj/hydroponics/harvest.dmi'
	var/obj/item/seeds/seed = null // type path, gets converted to item on New(). It's safe to assume it's always a seed item.
	var/plantname = ""
	var/bitesize_mod = 0
	// If set, bitesize = 1 + round(reagents.total_volume / bitesize_mod)
	dried_type = -1
	// Saves us from having to define each stupid grown's dried_type as itself.
	// If you don't want a plant to be driable (watermelons) set this to null in the time definition.
	burn_state = FLAMMABLE

/obj/item/weapon/reagent_containers/food/snacks/grown/New(newloc, var/obj/item/seeds/new_seed = null)
	..()
	if(new_seed)
		seed = new_seed.Copy()
	else if(ispath(seed))
		// This is for adminspawn or map-placed growns. They get the default stats of their seed type.
		seed = new seed()
		seed.potency = 50
		seed.prepare_result(src)
	else // Something is terribly wrong
		qdel(src)
		return

	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

	if(dried_type == -1)
		dried_type = src.type

	add_juice()

	transform *= TransformUsingVariable(seed.potency, 100, 0.5) //Makes the resulting produce's sprite larger or smaller based on potency!


/obj/item/weapon/reagent_containers/food/snacks/grown/proc/add_juice()
	if(reagents)
		if(bitesize_mod)
			bitesize = 1 + round(reagents.total_volume / bitesize_mod)
		return 1
	return 0

/obj/item/weapon/reagent_containers/food/snacks/grown/attackby(obj/item/O, mob/user, params)
	..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		var/msg = "<span class='info'>*---------*\n This is \a <span class='name'>[src]</span>.\n"
		msg += seed.get_analyzer_text()
		msg += "\n- Nutritional value: [reagents.get_reagent_amount("nutriment")]\n"
		msg += "- Other substances: [reagents.total_volume-reagents.get_reagent_amount("nutriment")]\n"
		msg += "*---------*</span>"

		var/list/scannable_reagents = list("charcoal" = "Anti-Toxin", "morphine" = "Morphine", "amatoxin" = "Amatoxins",
			"toxin" = "Toxins", "mushroomhallucinogen" = "Mushroom Hallucinogen", "condensedcapsaicin" = "Condensed Capsaicin",
			"capsaicin" = "Capsaicin", "frostoil" = "Frost Oil", "gold" = "Mineral Content", "glycerol" = "Glycerol",
			"radium" = "Highly Radioactive Material", "uranium" = "Radioactive Material")
		var/reag_txt = ""
		for(var/reagent_id in scannable_reagents)
			if(reagent_id in seed.reagents_add)
				var/amt = reagents.get_reagent_amount(reagent_id)
				reag_txt += "\n<span class='info'>- [scannable_reagents[reagent_id]]: [amt*100/reagents.maximum_volume]%</span>"

		if(reag_txt)
			msg += reag_txt
			msg += "<span class='info'>*---------*</span>"
		user << msg
		return
	return

// For item-containing growns such as eggy or gatfruit
/obj/item/weapon/reagent_containers/food/snacks/grown/shell/attack_self(mob/user as mob)
	user.unEquip(src)
	if(trash)
		var/obj/item/weapon/T
		if(ispath(trash, /obj/item/weapon/grown))
			T = new trash(user.loc, seed)
		else
			T = new trash(user.loc)
		user.put_in_hands(T)
		user << "<span class='notice'>You open [src]\'s shell, revealing [T].</span>"
	qdel(src)