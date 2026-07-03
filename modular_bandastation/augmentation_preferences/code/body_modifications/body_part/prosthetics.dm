/datum/body_modification/bodypart_prosthesis
	name = "Body Part Prosthesis"
	abstract_type = /datum/body_modification/bodypart_prosthesis
	var/replacement_bodypart_type = null
	var/manufacturers = list(
		"General",
		"Bishop",
		"Bishop MK2",
		"Bishop Nano",
		"Etamin Industry",
		"Etamin Industry Lumineux",
		"Gromtech",
		"Hephaestus",
		"Hephaestus Titan",
		"Interdyne",
		"Morpheus",
		"Shellguard",
		"Wardtakahashi",
		"Wardtakahashi Pro",
		"Xion",
		"Xion Light",
		"Zeng-Hu",
	)

	var/static/list/manufacturer_suffixes = list(
		"General" = null,
		"Bishop" = "bishop",
		"Bishop MK2" = "bishop_mk2",
		"Bishop Nano" = "bishop_nano",
		"Etamin Industry" = "etamin_industry",
		"Etamin Industry Lumineux" = "etamin_industry_lumineux",
		"Gromtech" = "gromtech",
		"Hephaestus" = "hephaestus",
		"Hephaestus Titan" = "hephaestus_titan",
		"Interdyne" = "interdyne",
		"Morpheus" = "morpheus",
		"Shellguard" = "shellguard",
		"Wardtakahashi" = "wardtakahashi",
		"Wardtakahashi Pro" = "wardtakahashi_pro",
		"Xion" = "xion",
		"Xion Light" = "xion_light",
		"Zeng-Hu" = "zenghu",
	)

/datum/body_modification/bodypart_prosthesis/apply_to_human(mob/living/carbon/target, additional_params)
	. = ..()
	if(!.)
		return

	var/manufacturer = additional_params["selected_manufacturer"] || get_default_manufacturer()
	var/type_to_spawn = get_replacement_type(manufacturer)
	if(!ispath(type_to_spawn))
		stack_trace("Failed to resolve prosthesis type for [type], manufacturer '[manufacturer]' and replacement type '[replacement_bodypart_type]'.")
		return FALSE

	var/body_zone = get_body_zone()
	if(!body_zone)
		stack_trace("[type] has no valid body zone for replacement type [replacement_bodypart_type].")
		return FALSE

	var/obj/item/bodypart/current_bodypart = target.get_bodypart(body_zone)
	if(current_bodypart?.type == type_to_spawn)
		return TRUE

	var/obj/item/bodypart/replacement_bodypart = new type_to_spawn()
	replacement_bodypart.replace_limb(target, TRUE)

	if(current_bodypart)
		qdel(current_bodypart)

	return TRUE

/datum/body_modification/bodypart_prosthesis/preference_value_valid(value)
	if(!islist(value))
		return FALSE

	var/list/value_list = value
	var/brand = value_list["selected_manufacturer"]
	return !isnull(brand) && (brand in manufacturers)

/datum/body_modification/bodypart_prosthesis/default_preference_value(params)
	return list("selected_manufacturer" = get_default_manufacturer())

/datum/body_modification/bodypart_prosthesis/ui_params_valid(params)
	var/brand = params["manufacturer"]
	return !isnull(brand) && (brand in manufacturers)

/datum/body_modification/bodypart_prosthesis/handle_ui_params(params)
	var/brand = params["manufacturer"]
	return list("selected_manufacturer" = brand)

/datum/body_modification/bodypart_prosthesis/proc/get_replacement_type(manufacturer)
	var/base_type_str = "[replacement_bodypart_type]"
	if(!findtext(base_type_str, "/"))
		base_type_str = "/[base_type_str]"

	if(isnull(manufacturer) || manufacturer == get_default_manufacturer())
		return text2path(base_type_str)

	var/suffix = manufacturer_suffixes[manufacturer]
	if(isnull(suffix) || !length(suffix))
		return text2path(base_type_str)

	return text2path("[base_type_str]/[suffix]")

/datum/body_modification/bodypart_prosthesis/proc/get_default_manufacturer()
	return length(manufacturers) ? manufacturers[1] : ""

/datum/body_modification/bodypart_prosthesis/proc/get_body_zone()
	var/obj/item/bodypart/probe = new replacement_bodypart_type()
	. = probe.body_zone
	qdel(probe)

/datum/body_modification/bodypart_prosthesis/arm
	abstract_type = /datum/body_modification/bodypart_prosthesis/arm

/datum/body_modification/bodypart_prosthesis/arm/left
	key = "left_arm_prosthesis"
	name = "Протез левой руки"
	replacement_bodypart_type = /obj/item/bodypart/arm/left/robot
	incompatible_body_modifications = list("left_arm_amputation")
	category = "Левая рука"

/datum/body_modification/bodypart_prosthesis/arm/right
	key = "right_arm_prosthesis"
	name = "Протез правой руки"
	replacement_bodypart_type = /obj/item/bodypart/arm/right/robot
	incompatible_body_modifications = list("right_arm_amputation")
	category = "Правая рука"

/datum/body_modification/bodypart_prosthesis/leg
	abstract_type = /datum/body_modification/bodypart_prosthesis/leg

/datum/body_modification/bodypart_prosthesis/leg/left
	key = "left_leg_prosthesis"
	name = "Протез левой ноги"
	replacement_bodypart_type = /obj/item/bodypart/leg/left/robot
	incompatible_body_modifications = list("left_leg_amputation")
	category = "Левая нога"

/datum/body_modification/bodypart_prosthesis/leg/right
	key = "right_leg_prosthesis"
	name = "Протез правой ноги"
	replacement_bodypart_type = /obj/item/bodypart/leg/right/robot
	incompatible_body_modifications = list("right_leg_amputation")
	category = "Правая нога"
