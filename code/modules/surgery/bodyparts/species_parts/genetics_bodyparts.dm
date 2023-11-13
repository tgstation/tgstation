/datum/action/cooldown/spell/bunny_hop
	name = "Bunny Hop"
	desc = "Hop a distance with your bunny leg(s)! Go further the more bunny limbs you've got."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "jetboot"
	cooldown_time = 10 SECONDS
	spell_requirements = NONE

/datum/action/cooldown/spell/bunny_hop/cast(mob/living/cast_on)
	. = ..()
	var/bnuuy_multiplier = 0
	var/mob/living/carbon/human/bnuuy = cast_on
	for(var/obj/item/bodypart/bodypart in bnuuy.bodyparts)
		if(bodypart.limb_id == BODYPART_ID_RABBIT || bodypart.limb_id == BODYPART_ID_DIGITIGRADE)
			bnuuy_multiplier++
	var/atom/target = get_edge_target_turf(cast_on, cast_on.dir)

	ADD_TRAIT(cast_on, TRAIT_MOVE_FLOATING, LEAPING_TRAIT)
	if (cast_on.throw_at(target, 2 * bnuuy_multiplier, 1 * bnuuy_multiplier, spin = FALSE, diagonals_first = TRUE, callback = TRAIT_CALLBACK_REMOVE(cast_on, TRAIT_MOVE_FLOATING, LEAPING_TRAIT)))
		playsound(cast_on, 'sound/effects/arcade_jump.ogg', 50, TRUE, TRUE)
		cast_on.visible_message(span_warning("[cast_on] hops forward with their genetically-engineered rabbit legs!"))
	else
		to_chat(cast_on, span_warning("Something prevents you from hopping!"))

/obj/item/bodypart/leg/left/digitigrade/bunny
	name = "rabbit left leg"
	desc = "Helps you jump!"
	icon_greyscale = 'icons/mob/human/species/misc/genetics_limbs.dmi'
	base_limb_id = BODYPART_ID_RABBIT
	var/datum/action/cooldown/spell/bunny_hop/jumping_power

/obj/item/bodypart/leg/left/digitigrade/bunny/try_attach_limb(mob/living/carbon/new_head_owner, special)
	. = ..()
	if(!.)
		return
	var/potential_action = locate(/datum/action/cooldown/spell/bunny_hop) in new_head_owner.actions
	if(potential_action)
		jumping_power = potential_action
	else
		jumping_power = new /datum/action/cooldown/spell/bunny_hop(src)
		jumping_power.background_icon_state = "bg_tech_blue"
		jumping_power.base_background_icon_state = jumping_power.background_icon_state
		jumping_power.active_background_icon_state = "[jumping_power.base_background_icon_state]_active"
		jumping_power.overlay_icon_state = "bg_tech_blue_border"
		jumping_power.active_overlay_icon_state = null
		jumping_power.panel = "Genetic"
		jumping_power.Grant(new_head_owner)

/obj/item/bodypart/leg/left/digitigrade/bunny/on_removal()
	var/mob/living/carbon/human/bnuuy = owner
	var/has_rabbit_leg_still = FALSE
	for(var/obj/item/bodypart/bodypart in bnuuy.bodyparts)
		if(bodypart == src)
			continue
		if(istype(bodypart, /obj/item/bodypart/leg) && (bodypart.limb_id == BODYPART_ID_RABBIT || bodypart.limb_id == BODYPART_ID_DIGITIGRADE))
			has_rabbit_leg_still = TRUE
			break
	if(!has_rabbit_leg_still)
		jumping_power.Remove(owner)
	. = ..()

/obj/item/bodypart/leg/right/digitigrade/bunny
	name = "rabbit right leg"
	desc = "Helps you jump!"
	icon_greyscale = 'icons/mob/human/species/misc/genetics_limbs.dmi'
	base_limb_id = BODYPART_ID_RABBIT
	var/datum/action/cooldown/spell/bunny_hop/jumping_power

/obj/item/bodypart/leg/right/digitigrade/bunny/try_attach_limb(mob/living/carbon/new_head_owner, special)
	. = ..()
	if(!.)
		return
	var/potential_action = locate(/datum/action/cooldown/spell/bunny_hop) in new_head_owner.actions
	if(potential_action)
		jumping_power = potential_action
	else
		jumping_power = new /datum/action/cooldown/spell/bunny_hop(src)
		jumping_power.background_icon_state = "bg_tech_blue"
		jumping_power.base_background_icon_state = jumping_power.background_icon_state
		jumping_power.active_background_icon_state = "[jumping_power.base_background_icon_state]_active"
		jumping_power.overlay_icon_state = "bg_tech_blue_border"
		jumping_power.active_overlay_icon_state = null
		jumping_power.panel = "Genetic"
		jumping_power.Grant(new_head_owner)

/obj/item/bodypart/leg/right/digitigrade/bunny/on_removal()
	var/mob/living/carbon/human/bnuuy = owner
	var/has_rabbit_leg_still = FALSE
	for(var/obj/item/bodypart/bodypart in bnuuy.bodyparts)
		if(bodypart == src)
			continue
		if(istype(bodypart, /obj/item/bodypart/leg) && (bodypart.limb_id == BODYPART_ID_RABBIT || bodypart.limb_id == BODYPART_ID_DIGITIGRADE))
			has_rabbit_leg_still = TRUE
			break
	if(!has_rabbit_leg_still)
		jumping_power.Remove(owner)
	. = ..()

/obj/item/bodypart/head/bunny
	name = "rabbit head"
	desc = "Comes with a sniffer for carrots."
	icon_greyscale = 'icons/mob/human/species/misc/genetics_limbs.dmi'
	is_dimorphic = TRUE
	limb_id = BODYPART_ID_RABBIT
	head_flags = HEAD_HAIR|HEAD_LIPS|HEAD_EYESPRITES|HEAD_EYECOLOR|HEAD_EYEHOLES|HEAD_DEBRAIN
	var/datum/action/cooldown/spell/olfaction/sniffing_power

/obj/item/bodypart/head/bunny/try_attach_limb(mob/living/carbon/new_head_owner, special)
	. = ..()
	if(!.)
		return
	var/obj/item/organ/external/snout/bunny/bunny_snout = new
	bunny_snout.transfer_to_limb(src, new_head_owner)

	sniffing_power = new /datum/action/cooldown/spell/olfaction(src)
	sniffing_power.background_icon_state = "bg_tech_blue"
	sniffing_power.base_background_icon_state = sniffing_power.background_icon_state
	sniffing_power.active_background_icon_state = "[sniffing_power.base_background_icon_state]_active"
	sniffing_power.overlay_icon_state = "bg_tech_blue_border"
	sniffing_power.active_overlay_icon_state = null
	sniffing_power.panel = "Genetic"
	sniffing_power.Grant(new_head_owner)

/obj/item/bodypart/head/bunny/on_removal()
	sniffing_power.Remove(owner)
	. = ..()

/obj/item/bodypart/chest/bunny
	name = "rabbit chest"
	desc = "Ensures the fluffiest hugs are possible."
	icon_greyscale = 'icons/mob/human/species/misc/genetics_limbs.dmi'
	limb_id = BODYPART_ID_RABBIT
	is_dimorphic = TRUE

/obj/item/bodypart/chest/bunny/try_attach_limb(mob/living/carbon/new_limb_owner, special)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(new_limb_owner, TRAIT_FRIENDLY, ORGAN_TRAIT)

/obj/item/bodypart/chest/bunny/on_removal()
	REMOVE_TRAIT(owner, TRAIT_FRIENDLY, ORGAN_TRAIT)
	. = ..()

/obj/item/bodypart/arm/left/bunny
	name = "rabbit left arm"
	desc = "Ensures the fluffiest hugs are possible."
	icon_greyscale = 'icons/mob/human/species/misc/genetics_limbs.dmi'
	limb_id = BODYPART_ID_RABBIT

/obj/item/bodypart/arm/left/bunny/try_attach_limb(mob/living/carbon/new_limb_owner, special)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(new_limb_owner, TRAIT_FRIENDLY, ORGAN_TRAIT)

/obj/item/bodypart/arm/left/bunny/on_removal()
	REMOVE_TRAIT(owner, TRAIT_FRIENDLY, ORGAN_TRAIT)
	. = ..()

/obj/item/bodypart/arm/right/bunny
	name = "rabbit right arm"
	desc = "Ensures the fluffiest hugs are possible."
	icon_greyscale = 'icons/mob/human/species/misc/genetics_limbs.dmi'
	limb_id = BODYPART_ID_RABBIT

/obj/item/bodypart/arm/right/bunny/try_attach_limb(mob/living/carbon/new_limb_owner, special)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(new_limb_owner, TRAIT_FRIENDLY, ORGAN_TRAIT)

/obj/item/bodypart/arm/right/bunny/on_removal()
	REMOVE_TRAIT(owner, TRAIT_FRIENDLY, ORGAN_TRAIT)
	. = ..()
