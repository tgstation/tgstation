/obj/item/bodypart/head
	name = BODY_ZONE_HEAD
	desc = "Didn't make sense not to live for fun, your brain gets smart but your head gets dumb."
	icon = 'icons/mob/human_parts.dmi'
	icon_state = "default_human_head"
	max_damage = 200
	body_zone = BODY_ZONE_HEAD
	body_part = HEAD
	plaintext_zone = "head"
	w_class = WEIGHT_CLASS_BULKY //Quite a hefty load
	slowdown = 1 //Balancing measure
	throw_range = 2 //No head bowling
	px_x = 0
	px_y = -8
	stam_damage_coeff = 1
	max_stamina_damage = 100
	wound_resistance = 5
	disabled_wound_penalty = 25
	scars_covered_by_clothes = FALSE
	grind_results = null
	is_dimorphic = TRUE

	var/mob/living/brain/brainmob //The current occupant.
	var/obj/item/organ/internal/brain/brain //The brain organ
	var/obj/item/organ/internal/eyes/eyes
	var/obj/item/organ/internal/ears/ears
	var/obj/item/organ/internal/tongue/tongue

	/// Do we show the information about missing organs upon being examined? Defaults to TRUE, useful for Dullahan heads.
	var/show_organs_on_examine = TRUE

	//Limb appearance info:
	var/real_name = "" //Replacement name
	///Hair color source
	var/hair_color_source = null
	///Hair colour and style
	var/hair_color = "#000000"
	///An override color that can be cleared later.
	var/override_hair_color = null
	///An override that cannot be cleared under any circumstances
	var/fixed_hair_color = null

	var/hair_style = "Bald"
	var/hair_alpha = 255
	var/hair_gradient_style = null
	var/hair_gradient_color = null
	//Facial hair colour and style
	var/facial_hair_color = "#000000"
	var/facial_hairstyle = "Shaved"
	var/facial_hair_gradient_style = null
	var/facial_hair_gradient_color = null
	///Is the hair currently hidden by something?
	var/hair_hidden
	///Is the facial hair currently hidden by something?
	var/facial_hair_hidden
	///Draw this head as "debrained"
	VAR_PROTECTED/show_debrained = FALSE



	var/lip_style
	var/lip_color = "white"

	var/stored_lipstick_trait
	///The image for hair
	var/mutable_appearance/hair_overlay
	///The image for hair gradient
	var/mutable_appearance/hair_gradient_overlay
	///The image for face hair
	var/mutable_appearance/facial_overlay
	///The image for facial hair gradient
	var/mutable_appearance/facial_gradient_overlay




/obj/item/bodypart/head/Destroy()
	QDEL_NULL(brainmob) //order is sensitive, see warning in handle_atom_del() below
	QDEL_NULL(brain)
	QDEL_NULL(eyes)
	QDEL_NULL(ears)
	QDEL_NULL(tongue)
	return ..()

/obj/item/bodypart/head/handle_atom_del(atom/head_atom)
	if(head_atom == brain)
		brain = null
		update_icon_dropped()
		if(!QDELETED(brainmob)) //this shouldn't happen without badminnery.
			message_admins("Brainmob: ([ADMIN_LOOKUPFLW(brainmob)]) was left stranded in [src] at [ADMIN_VERBOSEJMP(src)] without a brain!")
			log_game("Brainmob: ([key_name(brainmob)]) was left stranded in [src] at [AREACOORD(src)] without a brain!")
	if(head_atom == brainmob)
		brainmob = null
	if(head_atom == eyes)
		eyes = null
		update_icon_dropped()
	if(head_atom == ears)
		ears = null
	if(head_atom == tongue)
		tongue = null
	return ..()

/obj/item/bodypart/head/examine(mob/user)
	. = ..()
	if(IS_ORGANIC_LIMB(src) && show_organs_on_examine)
		if(!brain)
			. += span_info("The brain has been removed from [src].")
		else if(brain.suicided || brainmob?.suiciding)
			. += span_info("There's a miserable expression on [real_name]'s face; they must have really hated life. There's no hope of recovery.")
		else if(brainmob?.health <= HEALTH_THRESHOLD_DEAD)
			. += span_info("It's leaking some kind of... clear fluid? The brain inside must be in pretty bad shape.")
		else if(brainmob)
			if(brainmob.key || brainmob.get_ghost(FALSE, TRUE))
				. += span_info("Its muscles are twitching slightly... It seems to have some life still in it.")
			else
				. += span_info("It's completely lifeless. Perhaps there'll be a chance for them later.")
		else if(brain?.decoy_override)
			. += span_info("It's completely lifeless. Perhaps there'll be a chance for them later.")
		else
			. += span_info("It's completely lifeless.")

		if(!eyes)
			. += span_info("[real_name]'s eyes have been removed.")

		if(!ears)
			. += span_info("[real_name]'s ears have been removed.")

		if(!tongue)
			. += span_info("[real_name]'s tongue has been removed.")


/obj/item/bodypart/head/can_dismember(obj/item/item)
	if(owner.stat < HARD_CRIT)
		return FALSE
	return ..()

/obj/item/bodypart/head/drop_organs(mob/user, violent_removal)
	var/atom/drop_loc = drop_location()
	for(var/obj/item/head_item in src)
		if(head_item == brain)
			if(user)
				user.visible_message(span_warning("[user] saws [src] open and pulls out a brain!"), span_notice("You saw [src] open and pull out a brain."))
			if(brainmob)
				brainmob.container = null
				brainmob.forceMove(brain)
				brain.brainmob = brainmob
				brainmob = null
			if(violent_removal && prob(rand(80, 100))) //ghetto surgery can damage the brain.
				to_chat(user, span_warning("[brain] was damaged in the process!"))
				brain.setOrganDamage(brain.maxHealth)
			brain.forceMove(drop_loc)
			brain = null
			update_icon_dropped()
		else
			if(istype(head_item, /obj/item/reagent_containers/pill))
				for(var/datum/action/item_action/hands_free/activate_pill/pill_action in head_item.actions)
					qdel(pill_action)
			else if(istype(head_item, /obj/item/organ))
				var/obj/item/organ/organ = head_item
				if(organ.organ_flags & ORGAN_UNREMOVABLE)
					continue
			head_item.forceMove(drop_loc)
	eyes = null
	ears = null
	tongue = null

	return ..()

#define SET_OVERLAY_VALUE(X,Y,Z) if(X) X.Y = Z
/obj/item/bodypart/head/update_limb(dropping_limb, is_creating)
	. = ..()

	real_name = owner.real_name
	if(HAS_TRAIT(owner, TRAIT_HUSK))
		real_name = "Unknown"
		hair_style = "Bald"
		facial_hairstyle = "Shaved"
		lip_style = null
		stored_lipstick_trait = null

	else if(!animal_origin && ishuman(owner))

		var/mob/living/carbon/human/human_head_owner = owner
		var/datum/species/owner_species = human_head_owner.dna.species

		if(human_head_owner.lip_style && (LIPS in owner_species.species_traits))
			lip_style = human_head_owner.lip_style
			lip_color = human_head_owner.lip_color
		else
			lip_style = null
			lip_color = "white"

		///FACIAL HAIR CHECKS START
		//we check if our hat or helmet hides our facial hair.
		facial_hair_hidden = FALSE
		if(human_head_owner.head)
			var/obj/item/hat = human_head_owner.head
			if(hat.flags_inv & HIDEFACIALHAIR)
				facial_hair_hidden = TRUE

		if(human_head_owner.wear_mask)
			var/obj/item/mask = human_head_owner.wear_mask
			if(mask.flags_inv & HIDEFACIALHAIR)
				facial_hair_hidden = TRUE
		///FACIAL HAIR CHECKS END
		///HAIR CHECKS START
		hair_hidden = FALSE
		if(human_head_owner.head)
			var/obj/item/hat = human_head_owner.head
			if(hat.flags_inv & HIDEHAIR)
				hair_hidden = TRUE

		if(human_head_owner.w_uniform)
			var/obj/item/item_uniform = human_head_owner.w_uniform
			if(item_uniform.flags_inv & HIDEHAIR)
				hair_hidden = TRUE

		if(human_head_owner.wear_mask)
			var/obj/item/mask = human_head_owner.wear_mask
			if(mask.flags_inv & HIDEHAIR)
				hair_hidden = TRUE
		///HAIR CHECKS END

		if(!hair_hidden && !owner.getorgan(/obj/item/organ/internal/brain) && !(NOBLOOD in species_flags_list))
			show_debrained = TRUE
		else
			show_debrained = FALSE

		//CREATION-ONLY START
		if(is_creating)
			var/datum/sprite_accessory/sprite_accessory

			facial_overlay = null
			facial_gradient_overlay = null
			hair_overlay = null
			hair_gradient_overlay = null

			hair_alpha = owner_species.hair_alpha
			hair_color = human_head_owner.hair_color
			facial_hair_color = human_head_owner.facial_hair_color
			fixed_hair_color = owner_species.fixed_mut_color //Can be null
			hair_style = human_head_owner.hairstyle
			facial_hairstyle = human_head_owner.facial_hairstyle


			if(facial_hairstyle && !facial_hair_hidden && (FACEHAIR in species_flags_list))
				sprite_accessory = GLOB.facial_hairstyles_list[facial_hairstyle]
				if(sprite_accessory)
					//Create the overlay
					facial_overlay = mutable_appearance(sprite_accessory.icon, sprite_accessory.icon_state, -HAIR_LAYER)
					facial_overlay.overlays += emissive_blocker(facial_overlay.icon, facial_overlay.icon_state, alpha = hair_alpha)
					//Gradients
					facial_hair_gradient_style = LAZYACCESS(human_head_owner.grad_style, GRADIENT_FACIAL_HAIR_KEY)
					if(facial_hair_gradient_style)
						facial_hair_gradient_color = LAZYACCESS(human_head_owner.grad_color, GRADIENT_FACIAL_HAIR_KEY)
						facial_gradient_overlay = make_gradient_overlay(sprite_accessory.icon, sprite_accessory.icon_state, HAIR_LAYER, GLOB.facial_hair_gradients_list[facial_hair_gradient_style], facial_hair_gradient_color)

					facial_overlay.overlays += emissive_blocker(sprite_accessory.icon, sprite_accessory.icon_state, alpha = hair_alpha)

			if(!hair_hidden && !show_debrained && (HAIR in species_flags_list))
				sprite_accessory = GLOB.hairstyles_list[hair_style]
				if(sprite_accessory)
					hair_overlay = mutable_appearance(sprite_accessory.icon, sprite_accessory.icon_state, -HAIR_LAYER)
					hair_overlay.overlays += emissive_blocker(hair_overlay.icon, hair_overlay.icon_state, alpha = hair_alpha)
					hair_gradient_style = LAZYACCESS(human_head_owner.grad_style, GRADIENT_HAIR_KEY)
					if(hair_gradient_style)
						hair_gradient_color = LAZYACCESS(human_head_owner.grad_color, GRADIENT_HAIR_KEY)
						hair_gradient_overlay = make_gradient_overlay(sprite_accessory.icon, sprite_accessory.icon_state, HAIR_LAYER, GLOB.hair_gradients_list[hair_gradient_style], hair_gradient_color)

		//CREATION-ONLY END
		//HAIR COLOR START
		if(!override_hair_color)
			if(hair_color_source)
				if(hair_color_source == "fixedmutcolor")
					SET_OVERLAY_VALUE(facial_overlay, color, fixed_hair_color)
					SET_OVERLAY_VALUE(hair_overlay, color, fixed_hair_color)
				else if(hair_color_source == "mutcolor")
					SET_OVERLAY_VALUE(facial_overlay, color, facial_hair_color)
					SET_OVERLAY_VALUE(hair_overlay, color, hair_color)
				else
					SET_OVERLAY_VALUE(facial_overlay, color, hair_color_source)
					SET_OVERLAY_VALUE(hair_overlay, color, hair_color_source)
			else
				SET_OVERLAY_VALUE(facial_overlay, color, facial_hair_color)
				SET_OVERLAY_VALUE(hair_overlay, color, hair_color)
		else
			SET_OVERLAY_VALUE(facial_overlay, color, override_hair_color)
			SET_OVERLAY_VALUE(hair_overlay, color, override_hair_color)
		//HAIR COLOR END

#undef SET_OVERLAY_VALUE
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/item/bodypart/head/get_limb_icon(dropped, draw_external_organs)
	cut_overlays()
	. = ..()
	if(dropped) //certain overlays only appear when the limb is being detached from its owner.

		if(IS_ORGANIC_LIMB(src)) //having a robotic head hides certain features.
			//facial hair
			if(facial_hairstyle && (FACEHAIR in species_flags_list))
				var/datum/sprite_accessory/sprite = GLOB.facial_hairstyles_list[facial_hairstyle]
				if(sprite)
					var/image/facial_overlay = image(sprite.icon, "[sprite.icon_state]", -HAIR_LAYER, SOUTH)
					facial_overlay.color = facial_hair_color
					facial_overlay.alpha = hair_alpha
					. += facial_overlay

			//Applies the debrained overlay if there is no brain
			if(!brain)
				var/image/debrain_overlay = image(layer = -HAIR_LAYER, dir = SOUTH)
				if(animal_origin == ALIEN_BODYPART)
					debrain_overlay.icon = 'icons/mob/animal_parts.dmi'
					debrain_overlay.icon_state = "debrained_alien"
				else if(animal_origin == LARVA_BODYPART)
					debrain_overlay.icon = 'icons/mob/animal_parts.dmi'
					debrain_overlay.icon_state = "debrained_larva"
				else if(!(NOBLOOD in species_flags_list))
					debrain_overlay.icon = 'icons/mob/human_face.dmi'
					debrain_overlay.icon_state = "debrained"
				. += debrain_overlay
			else
				var/datum/sprite_accessory/sprite2 = GLOB.hairstyles_list[hair_style]
				if(sprite2 && (HAIR in species_flags_list))
					var/image/hair_overlay = image(sprite2.icon, "[sprite2.icon_state]", -HAIR_LAYER, SOUTH)
					hair_overlay.color = hair_color
					hair_overlay.alpha = hair_alpha
					. += hair_overlay


		// lipstick
		if(lip_style)
			var/image/lips_overlay = image('icons/mob/human_face.dmi', "lips_[lip_style]", -BODY_LAYER, SOUTH)
			lips_overlay.color = lip_color
			. += lips_overlay

		// eyes
		if(eyes) // This is a bit of copy/paste code from eyes.dm:generate_body_overlay
			var/image/eye_left = image('icons/mob/human_face.dmi', "[eyes.eye_icon_state]_l", -BODY_LAYER, SOUTH)
			var/image/eye_right = image('icons/mob/human_face.dmi', "[eyes.eye_icon_state]_r", -BODY_LAYER, SOUTH)
			if(eyes.eye_color_left)
				eye_left.color = eyes.eye_color_left
			if(eyes.eye_color_right)
				eye_right.color = eyes.eye_color_right
			. += eye_left
			. += eye_right
		else
			. += image('icons/mob/human_face.dmi', "eyes_missing", -BODY_LAYER, SOUTH)
	else
		if(!facial_hair_hidden && facial_overlay && (FACEHAIR in species_flags_list))
			facial_overlay.alpha = hair_alpha
			. += facial_overlay
			if(facial_gradient_overlay)
				. += facial_gradient_overlay

		if(show_debrained)
			. += mutable_appearance('icons/mob/human_face.dmi', "debrained", HAIR_LAYER)

		else if(!hair_hidden && hair_overlay && (HAIR in species_flags_list))
			hair_overlay.alpha = hair_alpha
			. += hair_overlay
			if(hair_gradient_overlay)
				. += hair_gradient_overlay
///Set the haircolor of a human. Override instead sets the override value, it will not be changed away from the override value until override is set to null.
/mob/proc/set_haircolor(hex_string, override)
	return

/mob/living/carbon/human/set_haircolor(hex_string, override)
	var/obj/item/bodypart/head/my_head = get_bodypart(BODY_ZONE_HEAD)
	if(!my_head)
		return

	if(override)
		my_head.override_hair_color = hex_string
	else
		my_head.hair_color = hex_string
	update_hair(is_creating = TRUE)

/obj/item/bodypart/head/proc/make_gradient_overlay(file, icon, layer, datum/sprite_accessory/gradient, grad_color)
	RETURN_TYPE(/mutable_appearance)

	var/mutable_appearance/gradient_overlay = mutable_appearance(layer = -layer)
	var/icon/temp = icon(gradient.icon, gradient.icon_state)
	var/icon/temp_hair = icon(file, icon)
	temp.Blend(temp_hair, ICON_ADD)
	gradient_overlay.icon = temp
	gradient_overlay.color = grad_color
	return gradient_overlay

/obj/item/bodypart/head/talk_into(mob/holder, message, channel, spans, datum/language/language, list/message_mods)
	var/mob/headholder = holder
	if(istype(headholder))
		headholder.log_talk(message, LOG_SAY, tag = "beheaded talk")

	say(message, language, sanitize = FALSE)
	return NOPASS

/obj/item/bodypart/head/GetVoice()
	return "The head of [real_name]"

/obj/item/bodypart/head/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_head"
	limb_id = SPECIES_MONKEY
	animal_origin = MONKEY_BODYPART
	bodytype = BODYTYPE_MONKEY | BODYTYPE_ORGANIC

/obj/item/bodypart/head/alien
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "alien_head"
	px_x = 0
	px_y = 0
	dismemberable = 0
	max_damage = 500
	animal_origin = ALIEN_BODYPART

/obj/item/bodypart/head/larva
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "larva_head"
	px_x = 0
	px_y = 0
	dismemberable = 0
	max_damage = 50
	animal_origin = LARVA_BODYPART
