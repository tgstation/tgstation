/proc/generate_genitals_shot(datum/sprite_accessory/sprite_accessory, key)
	var/icon/final_icon = icon('icons/mob/human/bodyparts_greyscale.dmi', "human_chest_f", SOUTH)

	if (!isnull(sprite_accessory))
		var/icon/accessory_icon = icon(sprite_accessory.icon, "m_[key]_[sprite_accessory.icon_state]_ADJ", SOUTH)
		var/icon/accessory_icon_2 = icon(sprite_accessory.icon, "m_[key]_[sprite_accessory.icon_state]_ADJ_2", SOUTH)
		accessory_icon_2.Blend(COLOR_RED, ICON_MULTIPLY)
		var/icon/accessory_icon_3 = icon(sprite_accessory.icon, "m_[key]_[sprite_accessory.icon_state]_ADJ_3", SOUTH)
		accessory_icon_3.Blend(COLOR_VIBRANT_LIME, ICON_MULTIPLY)
		final_icon.Blend(accessory_icon, ICON_OVERLAY)
		final_icon.Blend(accessory_icon_2, ICON_OVERLAY)
		final_icon.Blend(accessory_icon_3, ICON_OVERLAY)

	final_icon.Crop(10, 8, 22, 23)
	final_icon.Scale(26, 32)
	final_icon.Crop(-2, 1, 29, 32)

	return final_icon



/// === BASE ORGAN TYPE.  HELPS WITH THE BULLSHITTERY ===
/obj/item/organ/external/nsfw
	name = "nsfw organ"
	desc = "If you see this, yell at Naaka. Shit's fucked."
	icon = 'modular_doppler/enterprise_resource_planning/icons/organs.dmi'
	icon_state = ""
	zone = BODY_ZONE_CHEST

	var/baselayer_name = "Below Uniform"
	var/list/valid_layers = list("Below Uniform" = UNIFORM_LAYER, "Above Uniform" = BANDAGE_LAYER, "Above All Clothes" = HANDS_LAYER, "Above Everything" = WOUND_LAYER)

/datum/bodypart_overlay/mutant/nsfw
	layers = EXTERNAL_ADJACENT | EXTERNAL_ADJACENT_2 | EXTERNAL_ADJACENT_3 | EXTERNAL_BEHIND | EXTERNAL_BEHIND_2 | EXTERNAL_BEHIND_3

	var/visibility = ORGAN_VISIBILITY_MODE_NORMAL

	var/organ_slot = ORGAN_SLOT_EARS //why ears by default?  why not?

	var/baselayer = UNIFORM_LAYER
	var/offset1 = 0.03
	var/offset2 = 0.02
	var/offset3 = 0.01

/datum/bodypart_overlay/mutant/nsfw/mutant_bodyparts_layertext(layer)
	if(layer == -(baselayer + offset1))
		return "ADJ"
	if(layer == -(baselayer + offset2))
		return "ADJ_2"
	if(layer == -(baselayer + offset3))
		return "ADJ_3"
	return ..()

/datum/bodypart_overlay/mutant/nsfw/bitflag_to_layer(layer)
	switch(layer)
		if(EXTERNAL_ADJACENT)
			return -(baselayer + offset1)
		if(EXTERNAL_ADJACENT_2)
			return -(baselayer + offset2)
		if(EXTERNAL_ADJACENT_3)
			return -(baselayer + offset3)
	return ..()



/// === LAYERING ADJUST VERB ===
/mob/living/carbon/human/verb/adjust_genitals()
	set category = "IC"
	set name = "Adjust Parts"
	set desc = "Allows you to adjust the layering and visibility of your NSFW parts."

	if(stat != CONSCIOUS)
		to_chat(usr, span_warning("You're not conscious enough to do this!"))
		return

	var/list/part_list = list()
	for(var/obj/item/organ/external/nsfw/part in organs)
		part_list += part

	if(!part_list.len) //There is nothing to expose
		update_body()
		return

	var/obj/item/organ/external/nsfw/picked_organ = tgui_input_list(src, "Choose which part to adjust", "Part Adjuster", part_list)

	if(!picked_organ || !(picked_organ in organs))
		update_body()
		return

	var/static/list/adjust_modes = list(
		"Show/Hide part",
		"Adjust Part Layer"
	)
	var/picked_mode = tgui_input_list(src, "Choose how to adjust [picked_organ]", "Part Adjuster", adjust_modes)

	if(picked_mode == adjust_modes[1]) //show/hide
		var/static/list/vis_states = list(
			"Always Show" = ORGAN_VISIBILITY_MODE_ALWAYS_SHOW,
			"Normal" = ORGAN_VISIBILITY_MODE_NORMAL,
			"Always Hide" = ORGAN_VISIBILITY_MODE_ALWAYS_HIDE
		)
		var/picked_vis = tgui_input_list(src, "Choose a visibility mode for [picked_organ]; normal is hidden when under clothing", "Part Adjuster", vis_states)

		if(picked_vis)
			var/datum/bodypart_overlay/mutant/nsfw/overlay = picked_organ.bodypart_overlay
			if(istype(overlay))
				overlay.visibility = picked_vis
				balloon_alert(src, "set visibility to [lowertext(picked_vis)]")
			else
				balloon_alert(src, "wrong overlay type!  yell at coders!")
	else if(picked_mode == adjust_modes[2]) //change layer
		var/picked_layer = tgui_input_list(src, "Choose a rendering layer for [picked_organ]; it's currently on [picked_organ.baselayer_name]", "Part Adjuster", picked_organ.valid_layers)

		if(picked_layer)
			var/datum/bodypart_overlay/mutant/nsfw/overlay = picked_organ.bodypart_overlay
			if(istype(overlay))
				overlay.baselayer = picked_organ.valid_layers[picked_layer]
				picked_organ.baselayer_name = picked_layer
				balloon_alert(src, "set layer to [lowertext(picked_organ.baselayer_name)]")
			else
				balloon_alert(src, "wrong overlay type!  yell at coders!")
	else
		update_body()
		return

	update_body()
