/obj/item/botanical_lexicon
	name = "Botanical Lexicon"
	desc = "A transcribed list of all known plant mutations and how to aquire them"
	icon = 'monkestation/icons/obj/ranching.dmi'
	icon_state = "chicken_book"

/obj/item/botanical_lexicon/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user,src,ui)
	if(!ui)
		ui = new(user,src,"BotanicalLexicon")
		ui.open()

/obj/item/botanical_lexicon/ui_act(action,list/params)
	if(..())
		return


/obj/item/botanical_lexicon/ui_static_data(mob/user)
	var/list/data = list()
	var/list/plant_list = list()
	for(var/datum/hydroponics/plant_mutation/mutation as anything in (subtypesof(/datum/hydroponics/plant_mutation) - /datum/hydroponics/plant_mutation/spliced_mutation - /datum/hydroponics/plant_mutation/infusion))
		var/datum/hydroponics/plant_mutation/listed_mutation = new mutation
		var/list/details = list()
		if(!listed_mutation.created_seed)
			continue

		var/obj/item/seeds/created_seed = new listed_mutation.created_seed

		details["name"] = created_seed.name
		details["desc"] = created_seed.desc

		if(listed_mutation.required_potency.len)
			details["potency_low"] = listed_mutation.required_potency[1]
			details["potency_high"] = listed_mutation.required_potency[2]
		if(listed_mutation.required_yield.len)
			details["yield_low"] = listed_mutation.required_yield[1]
			details["yield_high"] = listed_mutation.required_yield[2]
		if(listed_mutation.required_production.len)
			details["production_low"] = listed_mutation.required_production[1]
			details["production_high"] = listed_mutation.required_production[2]
		if(listed_mutation.required_endurance.len)
			details["endurance_low"] = listed_mutation.required_endurance[1]
			details["endurance_high"] = listed_mutation.required_endurance[2]
		if(listed_mutation.required_lifespan.len)
			details["lifespan_low"] = listed_mutation.required_lifespan[1]
			details["lifespan_high"] = listed_mutation.required_lifespan[2]

		if(listed_mutation.mutates_from.len)
			var/list/parents = list()
			for(var/item in listed_mutation.mutates_from)
				var/obj/item/seeds/linked_seeds = item
				parents += initial(linked_seeds.name)

			details["mutates_from"] = parents.Join(",")

		if(istype(listed_mutation, /datum/hydroponics/plant_mutation/infusion))
			var/datum/hydroponics/plant_mutation/infusion/infused_type = listed_mutation
			var/list/reagent_names = list()
			for(var/datum/reagent/listed_reagent as anything in infused_type.reagent_requirement)
				reagent_names += initial(listed_reagent.name)
			details["required_reagents"] = reagent_names.Join(",")


		var/icon/plant_icon = getFlatIcon(created_seed)
		var/md5 = md5(fcopy_rsc(plant_icon))
		if(!SSassets.cache["photo_[md5]_[created_seed.name]_icon.png"])
			SSassets.transport.register_asset("photo_[md5]_[created_seed.name]_icon.png", plant_icon)
		SSassets.transport.send_assets(user, list("photo_[md5]_[created_seed.name]_icon.png" = plant_icon))
		details["plant_icon"] = SSassets.transport.get_asset_url("photo_[md5]_[created_seed.name]_icon.png")

		qdel(created_seed)
		plant_list += list(details)
		qdel(listed_mutation)

	data["plant_list"] = plant_list

	return data
