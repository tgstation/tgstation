///An item that can be used to gather information on the fish, such as but not limited to: health, hunger and traits.
/obj/item/fish_analyzer
	name = "fish analyzer"
	icon = 'icons/obj/devices/scanner.dmi'
	icon_state = "fish_analyzer_map"
	base_icon_state = "fish_analyzer"
	inhand_icon_state = "fish_analyzer"
	worn_icon_state = "fish_analyzer"
	desc = "A fish-shaped scanner used to monitor fish's status and evolutionary traits."
	obj_flags = CONDUCTS_ELECTRICITY
	custom_price = PAYCHECK_CREW * 3
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron= SMALL_MATERIAL_AMOUNT *2)
	greyscale_config_inhand_left = /datum/greyscale_config/fish_analyzer_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/fish_analyzer_inhand_right
	greyscale_config_worn = /datum/greyscale_config/fish_analyzer_worn
	///The color of the case. Used by grayscale configs and update_overlays()
	var/case_color
	///the atom (aquarium or fish) we have scanned
	var/atom/scanned_object

/obj/item/fish_analyzer/Initialize(mapload)
	case_color = rgb(rand(16, 255), rand(16, 255), rand(16, 255))
	set_greyscale(colors = list(case_color))
	. = ..()

	var/static/list/fishe_signals = list(
		COMSIG_FISH_ANALYZER_ANALYZE_STATUS = TYPE_PROC_REF(/datum/component/experiment_handler, try_run_handheld_experiment),
	)
	AddComponent(/datum/component/experiment_handler, \
		config_mode = EXPERIMENT_CONFIG_ALTCLICK, \
		allowed_experiments = list(/datum/experiment/scanning/fish), \
		config_flags = EXPERIMENT_CONFIG_SILENT_FAIL|EXPERIMENT_CONFIG_IMMEDIATE_ACTION, \
		experiment_signals = fishe_signals, \
	)

	register_item_context()
	update_appearance()
	AddComponent(/datum/component/adjust_fishing_difficulty, -3, ITEM_SLOT_HANDS)

/obj/item/fish_analyzer/Destroy()
	scanned_object = null
	return ..()

/obj/item/fish_analyzer/examine(mob/user)
	. = ..()
	. += span_notice("<b>Alt-Click</b> to access the Experiment Configuration UI")

/obj/item/fish_analyzer/update_icon_state()
	. = ..()
	icon_state = base_icon_state

/obj/item/fish_analyzer/update_overlays()
	. = ..()
	var/mutable_appearance/case = mutable_appearance(icon, "fish_analyzer_case")
	case.color = case_color
	. += case
	. += emissive_appearance(icon, "fish_analyzer_emissive", src)

/obj/item/fish_analyzer/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!isfish(target) && !HAS_TRAIT(target, TRAIT_IS_AQUARIUM))
		return NONE
	if(!user.can_read(src) || user.is_blind())
		return ITEM_INTERACT_BLOCKING

	SEND_SIGNAL(src, COMSIG_FISH_ANALYZER_ANALYZE_STATUS, target, user)
	if(target != scanned_object)
		unregister_scanned()
		register_scanned(target)
	ui_interact(user)
	return ITEM_INTERACT_SUCCESS

/obj/item/fish_analyzer/proc/register_scanned(atom/target)
	scanned_object = target
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(on_target_deleted))

/obj/item/fish_analyzer/proc/unregister_scanned()
	if(!scanned_object)
		return
	UnregisterSignal(scanned_object, COMSIG_QDELETING)
	scanned_object = null

/obj/item/fish_analyzer/proc/on_target_deleted()
	SIGNAL_HANDLER
	unregister_scanned()

/obj/item/fish_analyzer/ui_interact(mob/living/user, datum/tgui/ui)
	if(isnull(scanned_object))
		balloon_alert(user, "no specimen data!")
		return TRUE
	if(istype(user) && !(scanned_object in (view(7, get_turf(src)) | user.get_equipped_items(INCLUDE_HELD))))
		balloon_alert(user, "specimen data lost!")
		unregister_scanned()
		return TRUE

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FishAnalyzer")
		ui.open()

/obj/item/fish_analyzer/ui_status(mob/living/user, datum/ui_state/state)
	if(!istype(user)) //observers shouldn't disrupt things.
		return ..()
	if(!scanned_object || !(scanned_object in (view(7, get_turf(src)) | user.get_equipped_items(INCLUDE_HELD))))
		balloon_alert(user, "specimen data lost!")
		unregister_scanned()
		return UI_CLOSE
	return ..()

/obj/item/fish_analyzer/ui_data(mob/user)
	var/list/data = list()
	data["fish_list"] = list()
	data["fish_scanned"] = FALSE

	if(isfish(scanned_object))
		data["fish_scanned"] = TRUE
		return extract_fish_info(data, scanned_object)

	for(var/obj/item/fish/fishie in scanned_object)
		extract_fish_info(data, fishie)

	return data

/obj/item/fish_analyzer/proc/extract_fish_info(list/data, obj/item/fish/fishie)
	var/list/fish_traits = list()
	var/list/fish_evolutions = list()

	for(var/evolution_type in fishie.evolution_types)
		var/datum/fish_evolution/evolution = GLOB.fish_evolutions[evolution_type]
		var/obj/item/evolution_fish = evolution.new_fish_type
		fish_evolutions += list(list(
			"evolution_name" = evolution.name,
			"evolution_icon" = evolution_fish::icon,
			"evolution_icon_state" = evolution_fish::icon_state,
			"evolution_probability" = evolution.probability,
			"evolution_conditions" = evolution.conditions_note,
		))

	for(var/trait_type in fishie.fish_traits)
		var/datum/fish_trait/trait = GLOB.fish_traits[trait_type]
		fish_traits += list(list("trait_name" = trait.name, "trait_desc" = trait.catalog_description, "trait_inherit" = trait.inheritability))

	data["fish_list"] += list(list(
		"fish_name" = fishie.name,
		"fish_icon" = fishie.icon,
		"fish_icon_state" = fishie.base_icon_state,
		"fish_food" = fishie.food.name,
		"fish_food_color" = fishie.food::color,
		"fish_min_temp" = fishie.required_temperature_min,
		"fish_max_temp" = fishie.required_temperature_max,
		"fish_fluid_compatible" = fishie.fish_flags & FISH_FLAG_SAFE_FLUID,
		"fish_fluid_type" = fishie.required_fluid_type,
		"fish_traits" = fish_traits,
		"fish_evolutions" = fish_evolutions,
		"fish_suitable_temp" = fishie.fish_flags & FISH_FLAG_SAFE_TEMPERATURE,
		"fish_health" = fishie.status == FISH_DEAD ? 0 : PERCENT(fishie.get_health_percentage()),
		"fish_size" = fishie.size,
		"fish_weight" = fishie.weight,
		"fish_hunger" = HAS_TRAIT(fishie, TRAIT_FISH_NO_HUNGER) ? 0 :  1 - fishie.get_hunger(),
		"fish_breed_timer" = round(max(fishie.breeding_wait - world.time, 0) / 10),
	))

	return data
