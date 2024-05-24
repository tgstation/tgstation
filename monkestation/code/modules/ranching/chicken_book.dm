/obj/item/chicken_book
	name = "chicken encyclopedia"
	desc = "The exciting sequel to the encyclopedia of twenty first century trains!"
	icon = 'monkestation/icons/obj/ranching.dmi'
	icon_state = "chicken_book"

/obj/item/chicken_book/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user,src,ui)
	if(!ui)
		ui = new(user,src,"RanchingEncyclopedia")
		ui.open()

/obj/item/chicken_book/ui_act(action,list/params)
	if(..())
		return

/obj/item/chicken_book/ui_static_data(mob/user)
	var/list/data = list()
	var/list/chicken_list = list()
	for(var/datum/mutation/ranching/chicken/chicken as anything in subtypesof(/datum/mutation/ranching/chicken))
		var/datum/mutation/ranching/chicken/created_mutation = new chicken
		var/mob/living/basic/chicken/F = new created_mutation.chicken_type(src)
		var/male_name
		var/female_name
		if(F.breed_name_male)
			male_name = F.breed_name_male
		else
			male_name = "[F.breed_name] Rooster"
		if(F.breed_name_female)
			female_name = F.breed_name_female
		else
			female_name = "[F.breed_name] Hen"

		var/list/details = list()

		var/list/food_names = list()
		for(var/obj/item/food/food_item as anything in created_mutation.food_requirements)
			food_names |= "[initial(food_item.name)]s"

		var/list/reagent_names = list()
		for(var/datum/reagent/listed_reagent as anything in created_mutation.reagent_requirements)
			reagent_names |= "[initial(listed_reagent.name)]"

		var/list/turf_names = list()
		for(var/turf/listed_turf as anything in created_mutation.needed_turfs)
			turf_names |= initial(listed_turf.name)

		var/list/obj_names = list()
		for(var/obj/item/listed_item as anything in created_mutation.nearby_items)
			obj_names |= initial(listed_item.name)

		var/rooster_string
		if(created_mutation.required_rooster)
			var/mob/living/basic/chicken/temp_chicken = new created_mutation.required_rooster
			rooster_string = "[temp_chicken.breed_name_male ? temp_chicken.breed_name_male : temp_chicken.breed_name]"
			QDEL_NULL(temp_chicken)

		var/species_string
		if(created_mutation.needed_species)
			species_string = created_mutation.needed_species.name

		details["name"] = "[female_name] / [male_name]"
		details["desc"] = F.book_desc
		details["max_age"] = 100
		details["happiness"] = created_mutation.happiness
		details["temperature"] = created_mutation.needed_temperature
		details["temperature_variance"] = created_mutation.temperature_variance
		details["needed_pressure"] = created_mutation.needed_pressure
		details["pressure_variance"] = created_mutation.pressure_variance
		details["food_requirements"] = food_names.Join(",")
		details["reagent_requirements"] = reagent_names.Join(",")
		details["player_job"] = created_mutation.player_job
		details["player_health"] = created_mutation.player_health
		details["needed_species"] = species_string
		details["required_atmos"] = created_mutation.required_atmos.Join(",")
		details["required_rooster"] = rooster_string
		details["liquid_depth"] = created_mutation.liquid_depth
		details["needed_turfs"] = turf_names.Join(",")
		details["nearby_items"] = obj_names.Join(",")
		details["comes_from"] = created_mutation.can_come_from_string

		var/icon/chicken_icon = getFlatIcon(F)
		var/md5 = md5(fcopy_rsc(chicken_icon))
		if(!SSassets.cache["photo_[md5]_[F.breed_name]_icon.png"])
			SSassets.transport.register_asset("photo_[md5]_[F.breed_name]_icon.png", chicken_icon)
		SSassets.transport.send_assets(user, list("photo_[md5]_[F.breed_name]_icon.png" = chicken_icon))
		details["chicken_icon"] = SSassets.transport.get_asset_url("photo_[md5]_[F.breed_name]_icon.png")
		chicken_list += list(details)
		qdel(F)
		qdel(created_mutation)
	data["chicken_list"] = chicken_list

	return data
