/obj/item/bodypart/head
	name = BODY_ZONE_HEAD
	desc = "Didn't make sense not to live for fun, your brain gets smart but your head gets dumb."
	icon = 'icons/mob/human_parts.dmi'
	icon_state = "default_human_head"
	max_damage = 200
	body_zone = BODY_ZONE_HEAD
	body_part = HEAD
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

	var/mob/living/brain/brainmob //The current occupant.
	var/obj/item/organ/brain/brain //The brain organ
	var/obj/item/organ/eyes/eyes
	var/obj/item/organ/ears/ears
	var/obj/item/organ/tongue/tongue

	/// Do we show the information about missing organs upon being examined? Defaults to TRUE, useful for Dullahan heads.
	var/show_organs_on_examine = TRUE

	//Limb appearance info:
	var/real_name = "" //Replacement name
	//Hair colour and style
	var/hair_color = "#000000"
	var/hairstyle = "Bald"
	var/hair_alpha = 255
	//Facial hair colour and style
	var/facial_hair_color = "#000000"
	var/facial_hairstyle = "Shaved"
	//Eye Colouring

	var/lip_style
	var/lip_color = "white"

	var/stored_lipstick_trait


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
	if(status == BODYPART_ORGANIC && show_organs_on_examine)
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
	var/turf/head_turf = get_turf(src)
	if(status != BODYPART_ROBOTIC)
		playsound(head_turf, 'sound/misc/splort.ogg', 50, TRUE, -1)
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
			brain.forceMove(head_turf)
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
			head_item.forceMove(head_turf)
	eyes = null
	ears = null
	tongue = null

/obj/item/bodypart/head/update_limb(dropping_limb, mob/living/carbon/source)
	var/mob/living/carbon/head_owner
	if(source)
		head_owner = source
	else
		head_owner = owner

	real_name = head_owner.real_name
	if(HAS_TRAIT(head_owner, TRAIT_HUSK))
		real_name = "Unknown"
		hairstyle = "Bald"
		facial_hairstyle = "Shaved"
		lip_style = null
		stored_lipstick_trait = null

	else if(!animal_origin)
		var/mob/living/carbon/human/human_head_owner = head_owner
		var/datum/species/owner_species = human_head_owner.dna.species

		//Facial hair
		if(human_head_owner.facial_hairstyle && (FACEHAIR in owner_species.species_traits))
			facial_hairstyle = human_head_owner.facial_hairstyle
			if(owner_species.hair_color)
				if(owner_species.hair_color == "mutcolor")
					facial_hair_color = human_head_owner.dna.features["mcolor"]
				else if(hair_color == "fixedmutcolor")
					facial_hair_color = owner_species.fixed_mut_color
				else
					facial_hair_color = owner_species.hair_color
			else
				facial_hair_color = human_head_owner.facial_hair_color
			hair_alpha = owner_species.hair_alpha
		else
			facial_hairstyle = "Shaved"
			facial_hair_color = "#000000"
			hair_alpha = 255
		//Hair
		if(human_head_owner.hairstyle && (HAIR in owner_species.species_traits))
			hairstyle = human_head_owner.hairstyle
			if(owner_species.hair_color)
				if(owner_species.hair_color == "mutcolor")
					hair_color = human_head_owner.dna.features["mcolor"]
				else if(hair_color == "fixedmutcolor")
					hair_color = owner_species.fixed_mut_color
				else
					hair_color = owner_species.hair_color
			else
				hair_color = human_head_owner.hair_color
			hair_alpha = owner_species.hair_alpha
		else
			hairstyle = "Bald"
			hair_color = "#000000"
			hair_alpha = initial(hair_alpha)
		// lipstick
		if(human_head_owner.lip_style && (LIPS in owner_species.species_traits))
			lip_style = human_head_owner.lip_style
			lip_color = human_head_owner.lip_color
		else
			lip_style = null
			lip_color = "white"
	..()

/obj/item/bodypart/head/update_icon_dropped()
	var/list/standing = get_limb_icon(TRUE)
	if(!standing.len)
		icon_state = initial(icon_state)//no overlays found, we default back to initial icon.
		return
	for(var/image/img in standing)
		img.pixel_x = px_x
		img.pixel_y = px_y
	add_overlay(standing)

/obj/item/bodypart/head/get_limb_icon(dropped, draw_external_organs)
	cut_overlays()
	. = ..()
	if(dropped) //certain overlays only appear when the limb is being detached from its owner.

		if(status != BODYPART_ROBOTIC) //having a robotic head hides certain features.
			//facial hair
			if(facial_hairstyle)
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
				var/datum/sprite_accessory/sprite2 = GLOB.hairstyles_list[hairstyle]
				if(sprite2)
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
		var/image/eyes_overlay = image('icons/mob/human_face.dmi', "eyes_missing", -BODY_LAYER, SOUTH)
		. += eyes_overlay
		if(eyes)
			eyes_overlay.icon_state = eyes.eye_icon_state

			if(eyes.eye_color)
				eyes_overlay.color = eyes.eye_color

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
	animal_origin = MONKEY_BODYPART

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
