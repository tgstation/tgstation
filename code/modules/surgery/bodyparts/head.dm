/obj/item/bodypart/head
	name = BODY_ZONE_HEAD
	desc = "Didn't make sense not to live for fun, your brain gets smart but your head gets dumb."
	icon = 'icons/mob/species/human/bodyparts.dmi'
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
	wound_resistance = 5
	disabled_wound_penalty = 25
	scars_covered_by_clothes = FALSE
	grind_results = null
	is_dimorphic = TRUE
	unarmed_attack_verb = "bite"
	unarmed_attack_effect = ATTACK_EFFECT_BITE
	unarmed_attack_sound = 'sound/weapons/bite.ogg'
	unarmed_miss_sound = 'sound/weapons/bite.ogg'
	unarmed_damage_low = 1 // Yeah, biteing is pretty weak, blame the monkey super-nerf
	unarmed_damage_high = 3
	unarmed_stun_threshold = 4
	bodypart_trait_source = HEAD_TRAIT

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
			brainmob.log_message(", brainmob, was left stranded in [src] without a brain", LOG_GAME)
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
			else if(isorgan(head_item))
				var/obj/item/organ/organ = head_item
				if(organ.organ_flags & ORGAN_UNREMOVABLE)
					continue
			head_item.forceMove(drop_loc)
	eyes = null
	ears = null
	tongue = null

	return ..()

/obj/item/bodypart/head/update_limb(dropping_limb, is_creating)
	. = ..()

	real_name = owner.real_name
	if(HAS_TRAIT(owner, TRAIT_HUSK))
		real_name = "Unknown"
		hair_style = "Bald"
		facial_hairstyle = "Shaved"
		lip_style = null
		stored_lipstick_trait = null
	update_hair_and_lips()

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

			if(!eyes)
				. += image('icons/mob/species/human/human_face.dmi', "eyes_missing", -BODY_LAYER, SOUTH)

			//Applies the debrained overlay if there is no brain
			if(!brain)
				var/image/debrain_overlay = image(layer = -HAIR_LAYER, dir = SOUTH)
				if(bodytype & BODYTYPE_ALIEN)
					debrain_overlay.icon = 'icons/mob/species/alien/bodyparts.dmi'
					debrain_overlay.icon_state = "debrained_alien"
				else if(bodytype & BODYTYPE_LARVA_PLACEHOLDER)
					debrain_overlay.icon = 'icons/mob/species/alien/bodyparts.dmi'
					debrain_overlay.icon_state = "debrained_larva"
				else if(!(TRAIT_NOBLOOD in species_flags_list))
					debrain_overlay.icon = 'icons/mob/species/human/human_face.dmi'
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
			var/image/lips_overlay = image('icons/mob/species/human/human_face.dmi', "lips_[lip_style]", -BODY_LAYER, SOUTH)
			lips_overlay.color = lip_color
			. += lips_overlay

		// eyes
		if(eyes) // This is a bit of copy/paste code from eyes.dm:generate_body_overlay
			var/image/eye_left = image('icons/mob/species/human/human_face.dmi', "[eyes.eye_icon_state]_l", -BODY_LAYER, SOUTH)
			var/image/eye_right = image('icons/mob/species/human/human_face.dmi', "[eyes.eye_icon_state]_r", -BODY_LAYER, SOUTH)
			if(eyes.eye_color_left)
				eye_left.color = eyes.eye_color_left
			if(eyes.eye_color_right)
				eye_right.color = eyes.eye_color_right
			. += eye_left
			. += eye_right
	else
		if(!facial_hair_hidden && facial_overlay && (FACEHAIR in species_flags_list))
			facial_overlay.alpha = hair_alpha
			. += facial_overlay
			if(facial_gradient_overlay)
				. += facial_gradient_overlay

		if(show_debrained)
			. += mutable_appearance('icons/mob/species/human/human_face.dmi', "debrained", HAIR_LAYER)

		else if(!hair_hidden && hair_overlay && (HAIR in species_flags_list))
			hair_overlay.alpha = hair_alpha
			. += hair_overlay
			if(hair_gradient_overlay)
				. += hair_gradient_overlay

/mob/living/proc/set_haircolor(hex_string, override)
	return

///Set the haircolor of a human. Override instead sets the override value, it will not be changed away from the override value until override is set to null.
/mob/living/carbon/human/set_haircolor(hex_string, override)
	var/obj/item/bodypart/head/my_head = get_bodypart(BODY_ZONE_HEAD)
	if(!my_head)
		return

	if(override)
		my_head.override_hair_color = hex_string
	else
		hair_color = hex_string
	update_body_parts()

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
	icon = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_static = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_husk = 'icons/mob/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "default_monkey_head"
	limb_id = SPECIES_MONKEY
	bodytype = BODYTYPE_MONKEY | BODYTYPE_ORGANIC
	should_draw_greyscale = FALSE
	dmg_overlay_type = SPECIES_MONKEY
	is_dimorphic = FALSE

/obj/item/bodypart/head/alien
	icon = 'icons/mob/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/species/alien/bodyparts.dmi'
	icon_state = "alien_head"
	limb_id = BODYPART_ID_ALIEN
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	px_x = 0
	px_y = 0
	dismemberable = FALSE
	max_damage = 500
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ALIEN | BODYTYPE_ORGANIC

/obj/item/bodypart/head/larva
	icon = 'icons/mob/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/species/alien/bodyparts.dmi'
	icon_state = "larva_head"
	limb_id = BODYPART_ID_LARVA
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	px_x = 0
	px_y = 0
	dismemberable = FALSE
	max_damage = 50
	bodytype = BODYTYPE_LARVA_PLACEHOLDER | BODYTYPE_ORGANIC
