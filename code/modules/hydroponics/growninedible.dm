// **********************
// Other harvested materials from plants (that are not food)
// **********************

/obj/item/weapon/grown // Grown weapons
	name = "grown_weapon"
	icon = 'icons/obj/hydroponics/harvest.dmi'
	burn_state = FLAMMABLE
	var/seed = null
	var/plantname = ""
	var/product	//a type path
	var/lifespan = 0
	var/endurance = 15
	var/maturation = 7
	var/production = 7
	var/yield = 2
	var/potency = 20
	var/plant_type = PLANT_NORMAL

/obj/item/weapon/grown/New(newloc, new_potency = 50)
	..()
	potency = new_potency
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

	transform *= TransformUsingVariable(potency, 100, 0.5)

	if(seed && lifespan == 0) //This is for adminspawn or map-placed growns. They get the default stats of their seed type. This feels like a hack but people insist on putting these things on the map...
		var/obj/item/seeds/S = new seed(src)
		lifespan = S.lifespan
		endurance = S.endurance
		maturation = S.maturation
		production = S.production
		yield = S.yield
		qdel(S) //Foods drop their contents when eaten, so delete the default seed.

	create_reagents(50)
	add_juice()

/obj/item/weapon/grown/attackby(obj/item/O, mob/user, params)
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
		msg += "- Potency: <i>[potency]</i>\n"
		msg += "- Yield: <i>[yield]</i>\n"
		msg += "- Maturation speed: <i>[maturation]</i>\n"
		msg += "- Production speed: <i>[production]</i>\n"
		msg += "- Endurance: <i>[endurance]</i>\n"
		msg += "*---------*</span>"
		usr << msg
		return

/obj/item/weapon/grown/proc/add_juice()
	if(reagents)
		return 1
	return 0