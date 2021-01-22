
// Fish feed can
/obj/item/fish_feed
	name = "fish feed can"
	desc = "Autogenerates nutritious fish feed based on sample inside."
	icon = 'icons/obj/aquarium.dmi'
	icon_state = "fish_feed"
	w_class = WEIGHT_CLASS_TINY

/obj/item/fish_feed/Initialize()
	. = ..()
	create_reagents(5, OPENCONTAINER)
	reagents.add_reagent(/datum/reagent/consumable/nutriment,1) //Default fish diet

// Stasis fish case container for moving fish between aquariums safely.
/obj/item/storage/fish_case
	name = "stasis fish case"
	desc = "A small case keeping the fish inside in stasis."
	icon_state = "fishbox"

	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'

	component_type = /datum/component/storage/concrete/fish_case

/// Fish case with single random fish inside.
/obj/item/storage/fish_case/random/PopulateContents()
	. = ..()
	generate_fish(src,random_fish_type())


/// Book detailing where to get the fish and their properties.
/obj/item/book/fish_catalog
	name = "Fish Encyclopedia"
	desc = "Indexes all fish known to mankind (and related species)"
	dat = "Lot of fish stuff" //book wrappers could use cleaning so this is not necessary

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
		for(var/T in subtypesof(/datum/aquarium_behaviour/fish))
			var/datum/aquarium_behaviour/fish/F = T
			var/list/fish_data = list()
			if(!initial(F.show_in_catalog))
				continue
			fish_data["name"] = initial(F.name)
			fish_data["desc"] = initial(F.desc)
			fish_data["fluid"] = initial(F.required_fluid_type)
			fish_data["temp_min"] = initial(F.required_temperature_min)
			fish_data["temp_max"] = initial(F.required_temperature_max)
			fish_data["icon"] = sanitize_css_class_name("[initial(F.icon)][initial(F.icon_state)]")
			fish_data["color"] = initial(F.color)
			fish_data["source"] = initial(F.availible_in_random_cases) ? "[AQUARIUM_COMPANY] Fish Packs" : "Unknown"
			var/datum/reagent/food_type = initial(F.food)
			if(food_type != /datum/reagent/consumable/nutriment)
				fish_data["feed"] = initial(food_type.name)
			else
				fish_data["feed"] = "[AQUARIUM_COMPANY] Fish Feed"
			fish_info += list(fish_data)

	.["fish_info"] = fish_info
	.["sponsored_by"] = AQUARIUM_COMPANY

/obj/item/book/fish_catalog/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/fish)
	)

/obj/item/aquarium_kit
	name = "DIY Aquarium Construction Kit"
	desc = "Everything you need to build your own aquarium.(Raw materials sold separately)"
	icon = 'icons/obj/aquarium.dmi'
	icon_state = "construction_kit"
	w_class = WEIGHT_CLASS_TINY

/obj/item/aquarium_kit/attack_self(mob/user)
	. = ..()
	to_chat(user,"<span class='notice'>There's instruction and tools necessary to build aquarium inside. All you need is to start crafting.</span>")


/obj/item/aquarium_prop
	name = "generic aquarium prop"
	desc = "very boring"
	w_class = WEIGHT_CLASS_TINY

/obj/item/storage/box/aquarium_props
	name = "aquarium props box"
	desc = "All you need to make your aquarium look good"

/obj/item/storage/box/aquarium_props/PopulateContents()
	for(var/T in subtypesof(/datum/aquarium_behaviour/prop))
		generate_fish(src,T,/obj/item/aquarium_prop)

/obj/item/storage/box/fish_debug
	name = "box full of fish"

/obj/item/storage/box/fish_debug/PopulateContents()
	for(var/T in subtypesof(/datum/aquarium_behaviour/fish))
		generate_fish(src,T)
