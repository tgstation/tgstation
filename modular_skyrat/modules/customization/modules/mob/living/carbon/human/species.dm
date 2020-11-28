/datum/species
	mutant_bodyparts = list()
	///Self explanatory
	var/can_have_genitals = TRUE
	///Override of icon file of which we're taking the icons from for our limbs
	var/limbs_icon
	///A list of actual body markings on the owner of the species. Associative lists with keys named by limbs defines, pointing to a list with names and colors for the marking to be rendered. This is also stored in the DNA
	var/list/list/body_markings = list()
	///Override of the eyes icon file, used for Vox and maybe more in the future
	var/eyes_icon
	///How are we treated regarding processing reagents, by default we process them as if we're organic
	var/reagent_flags = PROCESS_ORGANIC
	///Whether a species can use augmentations in preferences
	var/can_augment = TRUE

/datum/species/proc/handle_mutant_bodyparts(mob/living/carbon/human/H, forced_colour)
	var/list/standing	= list()

	var/obj/item/bodypart/head/HD = H.get_bodypart(BODY_ZONE_HEAD)

	//Digitigrade legs are stuck in the phantom zone between true limbs and mutant bodyparts. Mainly it just needs more agressive updating than most limbs.
	var/update_needed = FALSE
	var/not_digitigrade = TRUE
	for(var/X in H.bodyparts)
		var/obj/item/bodypart/O = X
		if(!O.use_digitigrade)
			continue
		not_digitigrade = FALSE
		if(!(DIGITIGRADE in species_traits)) //Someone cut off a digitigrade leg and tacked it on
			species_traits += DIGITIGRADE
		var/should_be_squished = FALSE
		if((H.wear_suit && H.wear_suit.flags_inv & HIDEJUMPSUIT && !(H.wear_suit.mutant_variants & STYLE_DIGITIGRADE) && (H.wear_suit.body_parts_covered & LEGS)) || (H.w_uniform && (H.w_uniform.body_parts_covered & LEGS) && !(H.w_uniform.mutant_variants & STYLE_DIGITIGRADE)))
			should_be_squished = TRUE
		if(O.use_digitigrade == FULL_DIGITIGRADE && should_be_squished)
			O.use_digitigrade = SQUISHED_DIGITIGRADE
			update_needed = TRUE
		else if(O.use_digitigrade == SQUISHED_DIGITIGRADE && !should_be_squished)
			O.use_digitigrade = FULL_DIGITIGRADE
			update_needed = TRUE
	if(update_needed)
		H.update_body_parts()
	if(not_digitigrade && (DIGITIGRADE in species_traits)) //Curse is lifted
		species_traits -= DIGITIGRADE

	if(!mutant_bodyparts)
		H.remove_overlay(BODY_BEHIND_LAYER)
		H.remove_overlay(BODY_ADJ_LAYER)
		H.remove_overlay(BODY_FRONT_LAYER)
		return

	var/list/bodyparts_to_add = list()
	var/new_renderkey = "[id]"

	for(var/key in mutant_bodyparts)
		var/datum/sprite_accessory/S = GLOB.sprite_accessories[key][mutant_bodyparts[key][MUTANT_INDEX_NAME]]
		if(!S || S.icon_state == "none")
			continue
		if(S.is_hidden(H, HD))
			continue
		var/render_state
		if(S.special_render_case)
			render_state = S.get_special_render_state(H, S.icon_state)
		else
			render_state = S.icon_state
		new_renderkey += "-[key]-[render_state]"
		bodyparts_to_add[S] = render_state

	if(new_renderkey == H.mutant_renderkey)
		return
	H.mutant_renderkey = new_renderkey

	H.remove_overlay(BODY_BEHIND_LAYER)
	H.remove_overlay(BODY_ADJ_LAYER)
	H.remove_overlay(BODY_FRONT_LAYER)

	var/g = (H.body_type == FEMALE) ? "f" : "m"

	for(var/bodypart in bodyparts_to_add)
		var/datum/sprite_accessory/S = bodypart
		var/key = S.key

		var/icon_to_use
		var/x_shift
		if(S.special_icon_case)
			icon_to_use = S.get_special_icon(H, S.icon)
		else
			icon_to_use = S.icon

		if(S.special_x_dimension)
			x_shift = S.get_special_x_dimension(H, S.icon)
		else
			x_shift = S.dimension_x

		var/render_state = bodyparts_to_add[S]
		if(S.gender_specific)
			render_state = "[g]_[key]_[render_state]"
		else
			render_state = "m_[key]_[render_state]"

		for(var/layer in S.relevent_layers)
			var/layertext = mutant_bodyparts_layertext(layer)

			var/mutable_appearance/accessory_overlay = mutable_appearance(icon_to_use, layer = -layer)

			accessory_overlay.icon_state = "[render_state]_[layertext]"

			if(S.center)
				accessory_overlay = center_image(accessory_overlay, x_shift, S.dimension_y)

			if(!forced_colour)
				if(!S.special_colorize || S.do_colorize(H))
					if(HAS_TRAIT(H, TRAIT_HUSK))
						if(S.color_src == USE_MATRIXED_COLORS) //Matrixed+husk needs special care, otherwise we get sparkle dogs
							accessory_overlay.color = HUSK_COLOR_LIST
						else
							accessory_overlay.color = "#AAA" //The gray husk color
					else
						switch(S.color_src)
							if(USE_ONE_COLOR)
								accessory_overlay.color = "#"+mutant_bodyparts[key][MUTANT_INDEX_COLOR_LIST][1]
							if(USE_MATRIXED_COLORS)
								var/list/color_list = mutant_bodyparts[key][MUTANT_INDEX_COLOR_LIST]
								var/list/finished_list = list()
								finished_list += ReadRGB("[color_list[1]]0")
								finished_list += ReadRGB("[color_list[2]]0")
								finished_list += ReadRGB("[color_list[3]]0")
								finished_list += list(0,0,0,255)
								for(var/index in 1 to finished_list.len)
									finished_list[index] /= 255
								accessory_overlay.color = finished_list
							if(MUTCOLORS)
								if(fixed_mut_color)
									accessory_overlay.color = "#[fixed_mut_color]"
								else
									accessory_overlay.color = "#[H.dna.features["mcolor"]]"
							if(HAIR)
								if(hair_color == "mutcolor")
									accessory_overlay.color = "#[H.dna.features["mcolor"]]"
								else if(hair_color == "fixedmutcolor")
									accessory_overlay.color = "#[fixed_mut_color]"
								else
									accessory_overlay.color = "#[H.hair_color]"
							if(FACEHAIR)
								accessory_overlay.color = "#[H.facial_hair_color]"
							if(EYECOLOR)
								accessory_overlay.color = "#[H.eye_color]"
			else
				accessory_overlay.color = forced_colour
			standing += accessory_overlay

			if(S.hasinner)
				var/mutable_appearance/inner_accessory_overlay = mutable_appearance(S.icon, layer = -layer)
				if(S.gender_specific)
					inner_accessory_overlay.icon_state = "[g]_[key]inner_[S.icon_state]_[layertext]"
				else
					inner_accessory_overlay.icon_state = "m_[key]inner_[S.icon_state]_[layertext]"

				if(S.center)
					inner_accessory_overlay = center_image(inner_accessory_overlay, S.dimension_x, S.dimension_y)

				standing += inner_accessory_overlay

			//Here's EXTRA parts of accessories which I should get rid of sometime TODO i guess
			if(S.extra) //apply the extra overlay, if there is one
				var/mutable_appearance/extra_accessory_overlay = mutable_appearance(S.icon, layer = -layer)
				if(S.gender_specific)
					extra_accessory_overlay.icon_state = "[g]_[key]_extra_[S.icon_state]_[layertext]"
				else
					extra_accessory_overlay.icon_state = "m_[key]_extra_[S.icon_state]_[layertext]"
				if(S.center)
					extra_accessory_overlay = center_image(extra_accessory_overlay, S.dimension_x, S.dimension_y)


				switch(S.extra_color_src) //change the color of the extra overlay
					if(MUTCOLORS)
						if(fixed_mut_color)
							extra_accessory_overlay.color = "#[fixed_mut_color]"
						else
							extra_accessory_overlay.color = "#[H.dna.features["mcolor"]]"
					if(MUTCOLORS2)
						extra_accessory_overlay.color = "#[H.dna.features["mcolor2"]]"
					if(MUTCOLORS3)
						extra_accessory_overlay.color = "#[H.dna.features["mcolor3"]]"
					if(HAIR)
						if(hair_color == "mutcolor")
							extra_accessory_overlay.color = "#[H.dna.features["mcolor3"]]"
						else
							extra_accessory_overlay.color = "#[H.hair_color]"
					if(FACEHAIR)
						extra_accessory_overlay.color = "#[H.facial_hair_color]"
					if(EYECOLOR)
						extra_accessory_overlay.color = "#[H.eye_color]"

				standing += extra_accessory_overlay

			if(S.extra2) //apply the extra overlay, if there is one
				var/mutable_appearance/extra2_accessory_overlay = mutable_appearance(S.icon, layer = -layer)
				if(S.gender_specific)
					extra2_accessory_overlay.icon_state = "[g]_[key]_extra2_[S.icon_state]_[layertext]"
				else
					extra2_accessory_overlay.icon_state = "m_[key]_extra2_[S.icon_state]_[layertext]"
				if(S.center)
					extra2_accessory_overlay = center_image(extra2_accessory_overlay, S.dimension_x, S.dimension_y)

				switch(S.extra2_color_src) //change the color of the extra overlay
					if(MUTCOLORS)
						if(fixed_mut_color)
							extra2_accessory_overlay.color = "#[fixed_mut_color]"
						else
							extra2_accessory_overlay.color = "#[H.dna.features["mcolor"]]"
					if(MUTCOLORS2)
						extra2_accessory_overlay.color = "#[H.dna.features["mcolor2"]]"
					if(MUTCOLORS3)
						extra2_accessory_overlay.color = "#[H.dna.features["mcolor3"]]"
					if(HAIR)
						if(hair_color == "mutcolor3")
							extra2_accessory_overlay.color = "#[H.dna.features["mcolor"]]"
						else
							extra2_accessory_overlay.color = "#[H.hair_color]"

				standing += extra2_accessory_overlay

			H.overlays_standing[layer] += standing
			standing = list()

	H.apply_overlay(BODY_BEHIND_LAYER)
	H.apply_overlay(BODY_ADJ_LAYER)
	H.apply_overlay(BODY_FRONT_LAYER)

/datum/species
	///What accessories can a species have aswell as their default accessory of such type e.g. "frills" = "Aquatic". Default accessory colors is dictated by the accessory properties and mutcolors of the specie
	var/list/default_mutant_bodyparts = list()

/datum/species/New()
	. = ..()
	if(can_have_genitals)
		default_mutant_bodyparts["vagina"] = "None"
		default_mutant_bodyparts["womb"] = "None"
		default_mutant_bodyparts["testicles"] = "None"
		default_mutant_bodyparts["breasts"] = "None"
		default_mutant_bodyparts["penis"] = "None"

/datum/species/dullahan
	mutant_bodyparts = list()

/datum/species/human/felinid
	mutant_bodyparts = list()
	default_mutant_bodyparts = list("tail" = "Cat", "ears" = "Cat")

/datum/species/human
	mutant_bodyparts = list()
	default_mutant_bodyparts = list("ears" = "None", "tail" = "None", "wings" = "None")

/datum/species/mush
	mutant_bodyparts = list()

/datum/species/vampire
	mutant_bodyparts = list()

/datum/species/plasmaman
	mutant_bodyparts = list()
	can_have_genitals = FALSE
	can_augment = FALSE

/datum/species/ethereal
	mutant_bodyparts = list()
	can_have_genitals = FALSE
	can_augment = FALSE

/datum/species/proc/get_random_features()
	var/list/returned = MANDATORY_FEATURE_LIST
	returned["mcolor"] = random_short_color()
	returned["mcolor2"] = random_short_color()
	returned["mcolor3"] = random_short_color()
	return returned

/datum/species/proc/get_random_mutant_bodyparts(list/features) //Needs features to base the colour off of
	var/list/mutantpart_list = list()
	var/list/bodyparts_to_add = default_mutant_bodyparts.Copy()
	for(var/key in bodyparts_to_add)
		var/datum/sprite_accessory/SP
		if(bodyparts_to_add[key] == ACC_RANDOM)
			SP = random_accessory_of_key_for_species(key, src)
		else
			SP = GLOB.sprite_accessories[key][bodyparts_to_add[key]]
			if(!SP)
				CRASH("Cant find accessory of [key] key, [bodyparts_to_add[key]] name, for species [id]")
		var/list/color_list = SP.get_default_color(features, src)
		var/list/final_list = list()
		final_list[MUTANT_INDEX_NAME] = SP.name
		final_list[MUTANT_INDEX_COLOR_LIST] = color_list
		mutantpart_list[key] = final_list

	return mutantpart_list

/datum/species/proc/get_random_body_markings(list/features) //Needs features to base the colour off of
	return list()

/datum/species/proc/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	// Drop the items the new species can't wear
	if((AGENDER in species_traits))
		C.gender = PLURAL
	for(var/slot_id in no_equip)
		var/obj/item/thing = C.get_item_by_slot(slot_id)
		if(thing && (!thing.species_exception || !is_type_in_list(src,thing.species_exception)))
			C.dropItemToGround(thing)
	if(C.hud_used)
		C.hud_used.update_locked_slots()

	// this needs to be FIRST because qdel calls update_body which checks if we have DIGITIGRADE legs or not and if not then removes DIGITIGRADE from species_traits
	if(C.dna.species.mutant_bodyparts["legs"] && C.dna.species.mutant_bodyparts["legs"][MUTANT_INDEX_NAME] == "Digitigrade Legs")
		species_traits += DIGITIGRADE
	if(DIGITIGRADE in species_traits)
		C.Digitigrade_Leg_Swap(FALSE)

	C.mob_biotypes = inherent_biotypes

	regenerate_organs(C,old_species)

	if(exotic_bloodtype && C.dna.blood_type != exotic_bloodtype)
		C.dna.blood_type = exotic_bloodtype

	if(old_species.mutanthands)
		for(var/obj/item/I in C.held_items)
			if(istype(I, old_species.mutanthands))
				qdel(I)

	if(mutanthands)
		// Drop items in hands
		// If you're lucky enough to have a TRAIT_NODROP item, then it stays.
		for(var/V in C.held_items)
			var/obj/item/I = V
			if(istype(I))
				C.dropItemToGround(I)
			else	//Entries in the list should only ever be items or null, so if it's not an item, we can assume it's an empty hand
				C.put_in_hands(new mutanthands())

	for(var/X in inherent_traits)
		ADD_TRAIT(C, X, SPECIES_TRAIT)

	if(TRAIT_VIRUSIMMUNE in inherent_traits)
		for(var/datum/disease/A in C.diseases)
			A.cure(FALSE)

	if(TRAIT_TOXIMMUNE in inherent_traits)
		C.setToxLoss(0, TRUE, TRUE)

	if(TRAIT_OXYIMMUNE in inherent_traits)
		C.setOxyLoss(0, TRUE, TRUE)

	if(TRAIT_NOMETABOLISM in inherent_traits)
		C.reagents.end_metabolization(C, keep_liverless = TRUE)

	if(TRAIT_GENELESS in inherent_traits)
		C.dna.remove_all_mutations() // Radiation immune mobs can't get mutations normally

	if(inherent_factions)
		for(var/i in inherent_factions)
			C.faction += i //Using +=/-= for this in case you also gain the faction from a different source.

	if(flying_species && isnull(fly))
		fly = new
		fly.Grant(C)

	var/robotic_limbs
	if(ROBOTIC_LIMBS in species_traits)
		robotic_limbs = TRUE
	for(var/obj/item/bodypart/B in C.bodyparts)
		if(robotic_limbs)
			B.change_bodypart_status(BODYPART_ROBOTIC, FALSE, TRUE)
			B.organic_render = TRUE
		else if (B.status == BODYPART_ORGANIC)
			B.organic_render = TRUE

	C.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/species, multiplicative_slowdown=speedmod)

	SEND_SIGNAL(C, COMSIG_SPECIES_GAIN, src, old_species)

/datum/species/proc/handle_body(mob/living/carbon/human/H)
	H.remove_overlay(BODY_LAYER)

	var/list/standing = list()

	var/obj/item/bodypart/head/HD = H.get_bodypart(BODY_ZONE_HEAD)

	if(HD && !(HAS_TRAIT(H, TRAIT_HUSK)))
		// lipstick
		if(H.lip_style && (LIPS in species_traits))
			var/mutable_appearance/lip_overlay = mutable_appearance('icons/mob/human_face.dmi', "lips_[H.lip_style]", -BODY_LAYER)
			lip_overlay.color = H.lip_color
			if(OFFSET_FACE in H.dna.species.offset_features)
				lip_overlay.pixel_x += H.dna.species.offset_features[OFFSET_FACE][1]
				lip_overlay.pixel_y += H.dna.species.offset_features[OFFSET_FACE][2]
			standing += lip_overlay

		// eyes
		if(!(NOEYESPRITES in species_traits))
			var/obj/item/organ/eyes/E = H.getorganslot(ORGAN_SLOT_EYES)
			var/mutable_appearance/eye_overlay
			var/eye_icon = eyes_icon || 'icons/mob/human_face.dmi'
			if(!E)
				eye_overlay = mutable_appearance(eye_icon, "eyes_missing", -BODY_LAYER)
			else
				eye_overlay = mutable_appearance(eye_icon, E.eye_icon_state, -BODY_LAYER)
			if((EYECOLOR in species_traits) && E)
				eye_overlay.color = "#" + H.eye_color
			if(OFFSET_FACE in H.dna.species.offset_features)
				eye_overlay.pixel_x += H.dna.species.offset_features[OFFSET_FACE][1]
				eye_overlay.pixel_y += H.dna.species.offset_features[OFFSET_FACE][2]
			standing += eye_overlay

	//Underwear, Undershirts & Socks
	if(!(NO_UNDERWEAR in species_traits))
		if(H.underwear && !(H.underwear_visibility & UNDERWEAR_HIDE_UNDIES))
			var/datum/sprite_accessory/underwear/underwear = GLOB.underwear_list[H.underwear]
			var/mutable_appearance/underwear_overlay
			if(underwear)
				var/icon_state = underwear.icon_state
				if(underwear.has_digitigrade && (DIGITIGRADE in species_traits))
					icon_state += "_d"
				underwear_overlay = mutable_appearance(underwear.icon, icon_state, -BODY_LAYER)
				if(!underwear.use_static)
					underwear_overlay.color = "#" + H.underwear_color
				standing += underwear_overlay

		if(H.undershirt && !(H.underwear_visibility & UNDERWEAR_HIDE_SHIRT))
			var/datum/sprite_accessory/undershirt/undershirt = GLOB.undershirt_list[H.undershirt]
			if(undershirt)
				var/mutable_appearance/undershirt_overlay
				if(H.dna.species.sexes && H.gender == FEMALE)
					undershirt_overlay = wear_female_version(undershirt.icon_state, undershirt.icon, BODY_LAYER)
				else
					undershirt_overlay = mutable_appearance(undershirt.icon, undershirt.icon_state, -BODY_LAYER)
				if(!undershirt.use_static)
					undershirt_overlay.color = "#" + H.undershirt_color
				standing += undershirt_overlay

		if(H.socks && H.num_legs >= 2 && !(mutant_bodyparts["taur"]) && !(H.underwear_visibility & UNDERWEAR_HIDE_SOCKS))
			var/datum/sprite_accessory/socks/socks = GLOB.socks_list[H.socks]
			if(socks)
				var/mutable_appearance/socks_overlay
				var/icon_state = socks.icon_state
				if(DIGITIGRADE in species_traits)
					icon_state += "_d"
				socks_overlay = mutable_appearance(socks.icon, icon_state, -BODY_LAYER)
				if(!socks.use_static)
					socks_overlay.color = "#" + H.socks_color
				standing += socks_overlay

	if(standing.len)
		H.overlays_standing[BODY_LAYER] = standing

	H.apply_overlay(BODY_LAYER)
	handle_mutant_bodyparts(H)

//I wag in death
/datum/species/spec_death(gibbed, mob/living/carbon/human/H)
	if(H)
		stop_wagging_tail(H)

/datum/species/spec_stun(mob/living/carbon/human/H,amount)
	if(H)
		stop_wagging_tail(H)
	. = ..()

////////////////
//Tail Wagging//
////////////////

/datum/species/proc/can_wag_tail(mob/living/carbon/human/H)
	if(!H) //Somewhere in the core code we're getting those procs with H being null
		return FALSE
	var/obj/item/organ/tail/T = H.getorganslot(ORGAN_SLOT_TAIL)
	if(!T)
		return FALSE
	if(T.can_wag)
		return TRUE
	return FALSE

/datum/species/proc/is_wagging_tail(mob/living/carbon/human/H)
	if(!H) //Somewhere in the core code we're getting those procs with H being null
		return FALSE
	var/obj/item/organ/tail/T = H.getorganslot(ORGAN_SLOT_TAIL)
	if(!T)
		return FALSE
	return T.wagging

/datum/species/proc/start_wagging_tail(mob/living/carbon/human/H)
	if(!H) //Somewhere in the core code we're getting those procs with H being null
		return
	var/obj/item/organ/tail/T = H.getorganslot(ORGAN_SLOT_TAIL)
	if(!T)
		return FALSE
	T.wagging = TRUE
	H.update_body()

/datum/species/proc/stop_wagging_tail(mob/living/carbon/human/H)
	if(!H) //Somewhere in the core code we're getting those procs with H being null
		return
	var/obj/item/organ/tail/T = H.getorganslot(ORGAN_SLOT_TAIL)
	if(!T)
		return
	T.wagging = FALSE
	H.update_body()

/datum/species/regenerate_organs(mob/living/carbon/C,datum/species/old_species,replace_current=TRUE,list/excluded_zones)
	. = ..()
	var/robot_organs = (ROBOTIC_DNA_ORGANS in C.dna.species.species_traits)
	for(var/key in C.dna.mutant_bodyparts)
		var/datum/sprite_accessory/SA = GLOB.sprite_accessories[key][C.dna.mutant_bodyparts[key][MUTANT_INDEX_NAME]]
		if(SA.factual && SA.organ_type)
			var/obj/item/organ/path = new SA.organ_type
			if(robot_organs)
				path.status = ORGAN_ROBOTIC
				path.organ_flags |= ORGAN_SYNTHETIC
			var/obj/item/organ/oldorgan = C.getorganslot(path.slot)
			if(oldorgan)
				oldorgan.Remove(C,TRUE)
				QDEL_NULL(oldorgan)
			path.build_from_dna(C.dna, key)
			path.Insert(C, 0, FALSE)

/datum/species/on_species_loss(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	if(ROBOTIC_LIMBS in species_traits)
		for(var/obj/item/bodypart/B in C.bodyparts)
			B.change_bodypart_status(BODYPART_ORGANIC, FALSE, TRUE)

/datum/species/proc/spec_revival(mob/living/carbon/human/H)
	return
