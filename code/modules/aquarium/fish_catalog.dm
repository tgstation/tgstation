///Book detailing where to get the fish and their properties.
/obj/item/book/fish_catalog
	name = "Fish Encyclopedia"
	desc = "Indexes all fish known to mankind (and related species)."
	icon_state = "fishbook"
	dat = "Lot of fish stuff" //book wrappers could use cleaning so this is not necessary
	var/static/list/behaviors

/obj/item/book/fish_catalog/Initialize(mapload)
	. = ..()
	if(!behaviors)
		behaviors = list()
		for(var/subtype in subtypesof(/datum/aquarium_behaviour/fish))
			behaviors += new subtype

/obj/item/book/fish_catalog/on_read(mob/user)
	ui_interact(user)

/obj/item/book/fish_catalog/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FishCatalog", name)
		ui.open()

/obj/item/book/fish_catalog/ui_static_data(mob/user)
	. = ..()
	var/static/fish_info
	if(!fish_info)
		fish_info = list()
		for(var/datum/aquarium_behaviour/fish/fish_behaviour as anything in behaviors)
			var/list/fish_data = list()
			if(!fish_behaviour.show_in_catalog)
				continue
			fish_data["name"] = fish_behaviour.name
			fish_data["desc"] = fish_behaviour.desc
			fish_data["fluid"] = fish_behaviour.required_fluid_type
			fish_data["temp_min"] = fish_behaviour.required_temperature_min
			fish_data["temp_max"] = fish_behaviour.required_temperature_max
			fish_data["icon"] = sanitize_css_class_name("[fish_behaviour.icon][fish_behaviour.icon_state]")
			fish_data["color"] = fish_behaviour.color
			fish_data["source"] = get_fish_sources(fish_behaviour)
			if(ispath(fish_behaviour.food, /datum/reagent/consumable/nutriment))
				fish_data["feed"] = "[AQUARIUM_COMPANY] Fish Feed"
			else
				fish_data["feed"] = fish_behaviour.food
			fish_info += list(fish_data)

	.["fish_info"] = fish_info
	.["sponsored_by"] = AQUARIUM_COMPANY

/obj/item/book/fish_catalog/proc/get_fish_sources(datum/aquarium_behaviour/fish/fish)
	var/list/sources = list()
	//only common and rare fish are shown as showing up in fish packs, letting really rare fish exist in the pool but not be shown as such
	if(fish.available_in_random_cases && fish.random_case_rarity >= FISH_RARITY_RARE)
		sources += "[AQUARIUM_COMPANY] Fish Packs"
	if(!sources.len)
		sources += "Unknown"
	return english_list(sources)

/obj/item/book/fish_catalog/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/fish)
	)
