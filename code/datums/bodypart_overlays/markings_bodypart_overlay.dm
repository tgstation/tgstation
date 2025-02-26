/// For body markings applied on the species, which need some extra code
/datum/bodypart_overlay/simple/body_marking
	layers = EXTERNAL_ADJACENT
	/// Listen to the gendercode, if the limb is bimorphic
	var/use_gender = FALSE
	/// Which dna feature key to draw from
	var/dna_feature_key
	/// Which bodyparts do we apply ourselves to?
	var/list/applies_to = list(
		/obj/item/bodypart/arm/left,
		/obj/item/bodypart/arm/right,
		/obj/item/bodypart/chest,
		/obj/item/bodypart/head,
		/obj/item/bodypart/leg/left,
		/obj/item/bodypart/leg/right,
	)

/// Get the accessory list from SSaccessories. Used in species.dm to get the right sprite
/datum/bodypart_overlay/simple/body_marking/proc/get_accessory(name)
	CRASH("get_accessories() not overriden on [type] !")

/datum/bodypart_overlay/simple/body_marking/set_appearance(name, set_color)
	var/datum/sprite_accessory/accessory = get_accessory(name)
	if(isnull(accessory))
		return

	icon = accessory.icon
	icon_state = accessory.icon_state
	use_gender = accessory.gender_specific
	draw_color = accessory.color_src ? set_color : null
	cache_key = jointext(generate_icon_cache(), "_")

/datum/bodypart_overlay/simple/body_marking/generate_icon_cache()
	. = ..()
	. += use_gender
	. += draw_color

/datum/bodypart_overlay/simple/body_marking/can_draw_on_bodypart(mob/living/carbon/human/human)
	return icon_state != SPRITE_ACCESSORY_NONE

/datum/bodypart_overlay/simple/body_marking/get_image(layer, obj/item/bodypart/limb)
	var/gender_string = (use_gender && limb.is_dimorphic) ? (limb.gender == MALE ? MALE : FEMALE + "_") : "" //we only got male and female sprites
	return mutable_appearance(icon, gender_string + icon_state + "_" + limb.body_zone, layer = layer)

/datum/bodypart_overlay/simple/body_marking/moth
	dna_feature_key = "moth_markings"

/datum/bodypart_overlay/simple/body_marking/moth/get_accessory(name)
	return SSaccessories.moth_markings_list[name]

/datum/bodypart_overlay/simple/body_marking/lizard
	dna_feature_key = "lizard_markings"
	applies_to = list(/obj/item/bodypart/chest)

/datum/bodypart_overlay/simple/body_marking/lizard/get_accessory(name)
	return SSaccessories.lizard_markings_list[name]
