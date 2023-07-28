///Wing base type. doesn't really do anything
/obj/item/organ/external/wings
	name = "wings"
	desc = "Spread your wings and FLLLLLLLLYYYYY!"

	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_EXTERNAL_WINGS

	use_mob_sprite_as_obj_sprite = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/wings

///Checks if the wings can soften short falls
/obj/item/organ/external/wings/proc/can_soften_fall()
	return TRUE

///Bodypart overlay of default wings. Does not have any wing functionality
/datum/bodypart_overlay/mutant/wings
	layers = ALL_EXTERNAL_OVERLAYS
	feature_key = "wings"
	color_source = ORGAN_COLOR_OVERRIDE /// SKYRAPTOR EDIT

/// SKYRAPTOR ADDITIONS BEGIN: we're trying to make moth wings recolorable with a matrix and it's going to be fucking COMPLICATED AS BALLS
/datum/bodypart_overlay/mutant/wings/override_color(rgb_value)
	return COLOR_WHITE

/datum/bodypart_overlay/mutant/wings/inherit_color(obj/item/bodypart/ownerlimb, force)
	. = ..()
	//to_chat(world, "WING GAMING")
	if(isnull(ownerlimb))
		//to_chat(world, "Couldn't find a matching limb")
		return
	//to_chat(world, "Ownerlimb found, its loc is: [ownerlimb.owner.name]")
	var/mob/living/carbon/human/the_humie = ownerlimb.owner
	//to_chat(world, "Double checking: [the_humie.name]")
	if(!isnull(the_humie))
		//to_chat(world, "FOUND A HUMIE TO APPLY SETTINGS TO")
		var/tcol_1 = the_humie.dna.features["tricolor-b1"]
		var/tcol_2 = the_humie.dna.features["tricolor-b2"]
		var/tcol_3 = the_humie.dna.features["tricolor-b3"]
		//to_chat(world, "FOUND THE TRICOLOR DNA FEATURES: APPLYING (it's [tcol_1],[tcol_2],[tcol_3])")
		if(tcol_1 && tcol_2 && tcol_3)
			//this is beyond ugly but it works
			var/r1 = hex2num(copytext(tcol_1, 2, 4)) / 255.0
			var/g1 = hex2num(copytext(tcol_1, 4, 6)) / 255.0
			var/b1 = hex2num(copytext(tcol_1, 6, 8)) / 255.0
			var/r2 = hex2num(copytext(tcol_2, 2, 4)) / 255.0
			var/g2 = hex2num(copytext(tcol_2, 4, 6)) / 255.0
			var/b2 = hex2num(copytext(tcol_2, 6, 8)) / 255.0
			var/r3 = hex2num(copytext(tcol_3, 2, 4)) / 255.0
			var/g3 = hex2num(copytext(tcol_3, 4, 6)) / 255.0
			var/b3 = hex2num(copytext(tcol_3, 6, 8)) / 255.0
			draw_color = list(r1,g1,b1, r2,g2,b2, r3,g3,b3)
			ownerlimb.update_overlays()

/datum/bodypart_overlay/mutant/wings/color_image(image/overlay, draw_layer, obj/item/bodypart/limb)
	. = ..()
	overlay.color = draw_color
/// SKYRAPTOR ADDITIONS END


/datum/bodypart_overlay/mutant/wings/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(!human.wear_suit)
		return TRUE
	if(!(human.wear_suit.flags_inv & HIDEJUMPSUIT))
		return TRUE
	if(human.wear_suit.species_exception && is_type_in_list(src, human.wear_suit.species_exception))
		return TRUE
	return FALSE


