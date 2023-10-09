/obj/machinery/hydroponics/constructable/helper
	name = "hydro-hand 3000"
	desc = "A state of the art hydroponics tray that helps upcoming botanists by giving them challenges."

	cycledelay = 3 SECONDS /// wayyyy faster for simplicity
	helping_tray = TRUE
	var/datum/hydroponics/plant_mutation/current_challenge


/obj/machinery/hydroponics/proc/helpful_stuff()
	return

/obj/machinery/hydroponics/constructable/helper/helpful_stuff()
	waterlevel = maxwater // lets not worry about this
	if(check_completion_state())
		fast_foward_growth()
	else
		generate_helpful_messages()

/obj/machinery/hydroponics/constructable/helper/proc/check_completion_state()
	if(!current_challenge)
		return FALSE

	if(!current_challenge.check_viable(myseed))
		return FALSE
	return TRUE

/obj/machinery/hydroponics/constructable/helper/proc/fast_foward_growth()
	var/growth_mult = (1.01 ** -myseed.maturation)
	growth = myseed.harvest_age * growth_mult
	set_plant_status(HYDROTRAY_PLANT_HARVESTABLE)
	finish_challenge()

/obj/machinery/hydroponics/constructable/helper/proc/finish_challenge()
	maptext_height = 256
	maptext_width = 96
	maptext_x = -8
	maptext_y = 18

	maptext = "<span class='ol c pixel'><span style='color: #5EFB6E;'> Congratulations! \n You finished the Challenge! </span></span>"
	playsound(src, 'sound/items/party_horn.ogg', 50)
	qdel(current_challenge)

/obj/machinery/hydroponics/constructable/helper/proc/generate_helpful_messages()
	maptext_height = 256
	maptext_width = 96
	maptext_x = -32
	maptext_y = 32

	if(!current_challenge)
		maptext = "<span class='ol c pixel'><span style='color: #008000;text-align: center'> Please Interact to Begin. </span></span>"
	else
		var/built_string = "<span style='font-family:Times New Roman'> [initial(current_challenge.created_product.name)]"
		if(current_challenge.required_potency.len)
			var/low_end = current_challenge.required_potency[1]
			var/high_end = current_challenge.required_potency[2]
			if(!(low_end <= myseed.potency &&  myseed.potency <= high_end))
				built_string += "<span style='color: #FF0000;'> Potency: [myseed.potency] - [low_end <= myseed.potency ? "Over" : "Under"] </span> \n"
			else
				built_string += "<span style='color: #5EFB6E;'> Potency: [myseed.potency] </span> \n"

		if(current_challenge.required_yield.len)
			var/low_end = current_challenge.required_yield[1]
			var/high_end = current_challenge.required_yield[2]
			if(!(low_end <= myseed.yield && myseed.yield <= high_end))
				built_string += "<span style='color: #FF0000;'> Yield: [myseed.yield] - [low_end <= myseed.yield ? "Over" : "Under"] </span> \n"
			else
				built_string += "<span style='color: #5EFB6E;'> Yield: [myseed.yield] </span> \n"

		if(current_challenge.required_production.len)
			var/low_end = current_challenge.required_production[1]
			var/high_end = current_challenge.required_production[2]
			if(!(low_end <= myseed.production && myseed.production <= high_end))
				built_string += "<span style='color: #FF0000;'> Production: [myseed.production]  - [low_end <= myseed.production ? "Over" : "Under"] </span> \n"
			else
				built_string += "<span style='color: #5EFB6E;'> Production: [myseed.production] </span> \n"

		if(current_challenge.required_endurance.len)
			var/low_end = current_challenge.required_endurance[1]
			var/high_end = current_challenge.required_endurance[2]
			if(!(low_end <= myseed.endurance && myseed.endurance <= high_end))
				built_string += "<span style='color: #FF0000;'> Endurance: [myseed.endurance] - [low_end <= myseed.endurance ? "Over" : "Under"] </span> \n"
			else
				built_string += "<span style='color: #5EFB6E;'> Endurance: [myseed.endurance] </span> \n"

		if(current_challenge.required_lifespan.len)
			var/low_end = current_challenge.required_lifespan[1]
			var/high_end = current_challenge.required_lifespan[2]
			if(!(low_end <= myseed.lifespan && myseed.lifespan <= high_end))
				built_string += "<span style='color: #FF0000;'> Lifespan: [myseed.lifespan] - [low_end <= myseed.lifespan ? "Over" : "Under"] </span> \n"
			else
				built_string += "<span style='color: #5EFB6E;'> Lifespan: [myseed.lifespan] </span> \n"

		built_string += "</span>"
		maptext = built_string

/obj/machinery/hydroponics/constructable/helper/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!current_challenge)
		var/list/mutations = subtypesof(/datum/hydroponics/plant_mutation) - typesof(/datum/hydroponics/plant_mutation/infusion)

		var/datum/hydroponics/plant_mutation/picked_mutation = pick(mutations)
		current_challenge = new picked_mutation
		var/obj/item/seeds/picked_seeds = current_challenge.mutates_from[1]
		new picked_seeds(get_turf(src))
	else
		var/choice = tgui_alert(user, "Do you wish to cancel this challenge?", "[src.name]", list("Yes", "No"))
		if(choice != "Yes")
			return

		qdel(current_challenge)
		current_challenge = null
		generate_helpful_messages()

/obj/machinery/biogenerator/admin
	resistance_flags = INDESTRUCTIBLE
	biomass = INFINITY

/obj/machinery/biogenerator/admin/default_deconstruction_crowbar(obj/item/crowbar, ignore_panel, custom_deconstruct)
	return FALSE
