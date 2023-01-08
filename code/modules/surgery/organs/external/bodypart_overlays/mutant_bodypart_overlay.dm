/datum/bodypart_overlay/mutant
	///Sprite datum we use to draw on the bodypart
	var/datum/sprite_accessory/sprite_datum

	///Defines what kind of 'organ' we're looking at. Sprites have names like 'm_mothwings_firemoth'. 'mothwings' would then be feature_key
	var/feature_key = ""

	///The color this organ draws with. Updated by bodypart/inherit_color()
	var/draw_color
	///Where does this organ inherit it's color from?
	var/color_source = ORGAN_COLOR_INHERIT

///random_appearance TRUE means it picks a random appearance, FALSE if you want to set it yourself ()
/datum/bodypart_overlay/mutant/New(random_appearance = TRUE)
	. = ..()

	randomize_sprite()

/datum/bodypart_overlay/mutant/proc/randomize_sprite()
	sprite_datum = get_random_appearance()

///Grab a random appearance datum (thats not locked)
/datum/bodypart_overlay/mutant/proc/get_random_appearance()
	var/list/valid_restyles = list()
	var/list/feature_list = get_global_feature_list()
	for(var/accessory in feature_list)
		var/datum/sprite_accessory/accessory_datum = feature_list[accessory]
		if(initial(accessory_datum.locked)) //locked is for stuff that shouldn't appear here
			continue
		valid_restyles += accessory_datum
	return pick(valid_restyles)

///Add the overlays we need to draw on a person. Called from _bodyparts.dm
/datum/bodypart_overlay/mutant/get_image(image_layer, obj/item/bodypart/limb)
	if(!sprite_datum)
		return

	var/gender = (limb.limb_gender == FEMALE) ? "f" : "m"
	var/list/icon_state_builder = list()
	icon_state_builder += sprite_datum.gender_specific ? gender : "m" //Male is default because sprite accessories are so ancient they predate the concept of not hardcoding gender
	icon_state_builder += feature_key
	icon_state_builder += sprite_datum.icon_state
	icon_state_builder += mutant_bodyparts_layertext(image_layer)

	var/finished_icon_state = icon_state_builder.Join("_")

	var/mutable_appearance/appearance = mutable_appearance(sprite_datum.icon, finished_icon_state, layer = -image_layer)

	if(sprite_datum.center)
		center_image(appearance, sprite_datum.dimension_x, sprite_datum.dimension_y)

	return appearance

/datum/bodypart_overlay/mutant/color_image(image/overlay, obj/item/bodypart/limb)
	overlay.color = sprite_datum.color_src ? draw_color : null

/datum/bodypart_overlay/mutant/proc/add_to_limb(obj/item/bodypart/limb)
	limb.bodypart_overlays += src
	inherit_color(limb)

///Change our accessory sprite, using the accesssory type. If you need to change the sprite for something, use simple_change_sprite()
/datum/bodypart_overlay/mutant/set_appearance(accessory_type)
	sprite_datum = accessory_type
	cache_key = jointext(generate_icon_cache(), "_")

///Generate a unique key based on our sprites. So that if we've aleady drawn these sprites, they can be found in the cache and wont have to be drawn again (blessing and curse)
/datum/bodypart_overlay/mutant/generate_icon_cache()
	. = list()
	. += "[sprite_datum?.icon_state]"
	. += "[feature_key]"
	. += "[draw_color]"
	return .

///Return a dumb glob list for this specific feature (called from parse_sprite)
/datum/bodypart_overlay/mutant/proc/get_global_feature_list()
	CRASH("External organ has no feature list, it will render invisible")

///Give the organ its color. Force will override the existing one.
/datum/bodypart_overlay/mutant/proc/inherit_color(obj/item/bodypart/ownerlimb, force)
	if(draw_color && !force)
		return
	switch(color_source)
		if(ORGAN_COLOR_OVERRIDE)
			draw_color = override_color(ownerlimb.draw_color)
		if(ORGAN_COLOR_INHERIT)
			draw_color = ownerlimb.draw_color
		if(ORGAN_COLOR_HAIR)
			if(!ishuman(ownerlimb.owner))
				return
			var/mob/living/carbon/human/human_owner = ownerlimb.owner
			draw_color = human_owner.hair_color
	return TRUE
