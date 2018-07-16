
/obj/item/bodypart
	name = "limb"
	desc = "Why is it detached..."
	force = 3
	throwforce = 3
	icon = 'icons/mob/human_parts.dmi'
	icon_state = ""
	layer = BELOW_MOB_LAYER //so it isn't hidden behind objects when on the floor
	var/mob/living/carbon/owner = null
	var/mob/living/carbon/original_owner = null
	var/status = BODYPART_ORGANIC
	var/body_zone //BODY_ZONE_CHEST, BODY_ZONE_L_ARM, etc , used for def_zone
	var/aux_zone // used for hands
	var/aux_layer
	var/body_part = null //bitflag used to check which clothes cover this bodypart
	var/use_digitigrade = NOT_DIGITIGRADE //Used for alternate legs, useless elsewhere
	var/brutestate = 0
	var/burnstate = 0
	var/brute_dam = 0
	var/burn_dam = 0
	var/stamina_dam = 0
	var/max_damage = 0
	var/list/embedded_objects = list()
	var/held_index = 0 //are we a hand? if so, which one!
	var/is_pseudopart = FALSE //For limbs that don't really exist, eg chainsaws

	//Coloring and proper item icon update
	var/skin_tone = ""
	var/body_gender = ""
	var/species_id = ""
	var/should_draw_gender = FALSE
	var/should_draw_greyscale = FALSE
	var/species_color = ""
	var/mutation_color = ""
	var/no_update = 0

	var/animal_origin = null //for nonhuman bodypart (e.g. monkey)
	var/dismemberable = 1 //whether it can be dismembered with a weapon.

	var/px_x = 0
	var/px_y = 0

	var/species_flags_list = list()
	var/dmg_overlay_type //the type of damage overlay (if any) to use when this bodypart is bruised/burned.

	//Damage messages used by help_shake_act()
	var/light_brute_msg = "bruised"
	var/medium_brute_msg = "battered"
	var/heavy_brute_msg = "mangled"

	var/light_burn_msg = "numb"
	var/medium_burn_msg = "blistered"
	var/heavy_burn_msg = "peeling away"

/obj/item/bodypart/examine(mob/user)
	..()
	if(brute_dam > 0)
		to_chat(user, "<span class='warning'>This limb has [brute_dam > 30 ? "severe" : "minor"] bruising.</span>")
	if(burn_dam > 0)
		to_chat(user, "<span class='warning'>This limb has [burn_dam > 30 ? "severe" : "minor"] burns.</span>")

/obj/item/bodypart/blob_act()
	take_damage(max_damage)

/obj/item/bodypart/Destroy()
	if(owner)
		owner.bodyparts -= src
		owner = null
	return ..()

/obj/item/bodypart/attack(mob/living/carbon/C, mob/user)
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(C.has_trait(TRAIT_LIMBATTACHMENT))
			if(!H.get_bodypart(body_zone) && !animal_origin)
				if(H == user)
					H.visible_message("<span class='warning'>[H] jams [src] into [H.p_their()] empty socket!</span>",\
					"<span class='notice'>You force [src] into your empty socket, and it locks into place!</span>")
				else
					H.visible_message("<span class='warning'>[user] jams [src] into [H]'s empty socket!</span>",\
					"<span class='notice'>[user] forces [src] into your empty socket, and it locks into place!</span>")
				user.temporarilyRemoveItemFromInventory(src, TRUE)
				attach_limb(C)
				return
	..()

/obj/item/bodypart/attackby(obj/item/W, mob/user, params)
	if(W.sharpness)
		add_fingerprint(user)
		if(!contents.len)
			to_chat(user, "<span class='warning'>There is nothing left inside [src]!</span>")
			return
		playsound(loc, 'sound/weapons/slice.ogg', 50, 1, -1)
		user.visible_message("<span class='warning'>[user] begins to cut open [src].</span>",\
			"<span class='notice'>You begin to cut open [src]...</span>")
		if(do_after(user, 54, target = src))
			drop_organs(user)
	else
		return ..()

/obj/item/bodypart/throw_impact(atom/hit_atom)
	..()
	if(status != BODYPART_ROBOTIC)
		playsound(get_turf(src), 'sound/misc/splort.ogg', 50, 1, -1)
	pixel_x = rand(-3, 3)
	pixel_y = rand(-3, 3)

//empties the bodypart from its organs and other things inside it
/obj/item/bodypart/proc/drop_organs(mob/user)
	var/turf/T = get_turf(src)
	if(status != BODYPART_ROBOTIC)
		playsound(T, 'sound/misc/splort.ogg', 50, 1, -1)
	for(var/obj/item/I in src)
		I.forceMove(T)

//Applies brute and burn damage to the organ. Returns 1 if the damage-icon states changed at all.
//Damage will not exceed max_damage using this proc
//Cannot apply negative damage
/obj/item/bodypart/proc/receive_damage(brute = 0, burn = 0, stamina = 0, updating_health = TRUE)
	if(owner && (owner.status_flags & GODMODE))
		return FALSE	//godmode
	var/dmg_mlt = CONFIG_GET(number/damage_multiplier)
	brute = round(max(brute * dmg_mlt, 0),DAMAGE_PRECISION)
	burn = round(max(burn * dmg_mlt, 0),DAMAGE_PRECISION)
	stamina = round(max(stamina * dmg_mlt, 0),DAMAGE_PRECISION)
	if(status == BODYPART_ROBOTIC) //This makes robolimbs not damageable by chems and makes it stronger
		brute = max(0, brute - 5)
		burn = max(0, burn - 4)
		//No stamina scaling.. for now..

	if(!brute && !burn && !stamina)
		return FALSE

	switch(animal_origin)
		if(ALIEN_BODYPART,LARVA_BODYPART) //aliens take double burn
			burn *= 2

	var/can_inflict = max_damage - (brute_dam + burn_dam)
	if(can_inflict <= 0)
		return FALSE

	var/total_damage = brute + burn

	if(total_damage > can_inflict)
		var/excess = total_damage - can_inflict
		brute = round(brute * (excess / total_damage),DAMAGE_PRECISION)
		burn = round(burn * (excess / total_damage),DAMAGE_PRECISION)

	brute_dam += brute
	burn_dam += burn

	//We've dealt the physical damages, if there's room lets apply the stamina damage.
	var/current_damage = brute_dam + burn_dam + stamina_dam		//This time around, count stamina loss too.
	var/available_damage = max_damage - current_damage
	stamina_dam += CLAMP(stamina, 0, available_damage)

	if(owner && updating_health)
		owner.updatehealth()
		if(stamina)
			owner.update_stamina()
	return update_bodypart_damage_state()

//Heals brute and burn damage for the organ. Returns 1 if the damage-icon states changed at all.
//Damage cannot go below zero.
//Cannot remove negative damage (i.e. apply damage)
/obj/item/bodypart/proc/heal_damage(brute, burn, stamina, only_robotic = FALSE, only_organic = TRUE, updating_health = TRUE)

	if(only_robotic && status != BODYPART_ROBOTIC) //This makes organic limbs not heal when the proc is in Robotic mode.
		return

	if(only_organic && status != BODYPART_ORGANIC) //This makes robolimbs not healable by chems.
		return

	brute_dam	= round(max(brute_dam - brute, 0), DAMAGE_PRECISION)
	burn_dam	= round(max(burn_dam - burn, 0), DAMAGE_PRECISION)
	stamina_dam = round(max(stamina_dam - stamina, 0), DAMAGE_PRECISION)
	if(owner && updating_health)
		owner.updatehealth()
	return update_bodypart_damage_state()


//Returns total damage...kinda pointless really
/obj/item/bodypart/proc/get_damage()
	return brute_dam + burn_dam


//Updates an organ's brute/burn states for use by update_damage_overlays()
//Returns 1 if we need to update overlays. 0 otherwise.
/obj/item/bodypart/proc/update_bodypart_damage_state()
	var/tbrute	= round( (brute_dam/max_damage)*3, 1 )
	var/tburn	= round( (burn_dam/max_damage)*3, 1 )
	if((tbrute != brutestate) || (tburn != burnstate))
		brutestate = tbrute
		burnstate = tburn
		return TRUE
	return FALSE



//Change organ status
/obj/item/bodypart/proc/change_bodypart_status(new_limb_status, heal_limb, change_icon_to_default)
	status = new_limb_status
	if(heal_limb)
		burn_dam = 0
		brute_dam = 0
		brutestate = 0
		burnstate = 0

	if(change_icon_to_default)
		if(status == BODYPART_ORGANIC)
			icon = DEFAULT_BODYPART_ICON_ORGANIC
		else if(status == BODYPART_ROBOTIC)
			icon = DEFAULT_BODYPART_ICON_ROBOTIC

	if(owner)
		owner.updatehealth()
		owner.update_body() //if our head becomes robotic, we remove the lizard horns and human hair.
		owner.update_hair()
		owner.update_damage_overlays()

/obj/item/bodypart/proc/is_organic_limb()
	return (status == BODYPART_ORGANIC)

//we inform the bodypart of the changes that happened to the owner, or give it the informations from a source mob.
/obj/item/bodypart/proc/update_limb(dropping_limb, mob/living/carbon/source)
	var/mob/living/carbon/C
	if(source)
		C = source
		if(!original_owner)
			original_owner = source
	else if(original_owner && owner != original_owner) //Foreign limb
		no_update = TRUE
	else
		C = owner
		no_update = FALSE

	if(C.has_trait(TRAIT_HUSK) && is_organic_limb())
		species_id = "husk" //overrides species_id
		dmg_overlay_type = "" //no damage overlay shown when husked
		should_draw_gender = FALSE
		should_draw_greyscale = FALSE
		no_update = TRUE

	if(no_update)
		return

	if(!animal_origin)
		var/mob/living/carbon/human/H = C
		should_draw_greyscale = FALSE

		var/datum/species/S = H.dna.species
		species_id = S.limbs_id
		species_flags_list = H.dna.species.species_traits

		if(S.use_skintones)
			skin_tone = H.skin_tone
			should_draw_greyscale = TRUE
		else
			skin_tone = ""

		body_gender = H.gender
		should_draw_gender = S.sexes

		if(MUTCOLORS in S.species_traits)
			if(S.fixed_mut_color)
				species_color = S.fixed_mut_color
			else
				species_color = H.dna.features["mcolor"]
			should_draw_greyscale = TRUE
		else
			species_color = ""

		if(!dropping_limb && H.dna.check_mutation(HULK))
			mutation_color = "00aa00"
		else
			mutation_color = ""

		dmg_overlay_type = S.damage_overlay_type

	else if(animal_origin == MONKEY_BODYPART) //currently monkeys are the only non human mob to have damage overlays.
		dmg_overlay_type = animal_origin

	if(status == BODYPART_ROBOTIC)
		dmg_overlay_type = "robotic"

	if(dropping_limb)
		no_update = TRUE //when attached, the limb won't be affected by the appearance changes of its mob owner.

//to update the bodypart's icon when not attached to a mob
/obj/item/bodypart/proc/update_icon_dropped()
	cut_overlays()
	var/list/standing = get_limb_icon(1)
	if(!standing.len)
		icon_state = initial(icon_state)//no overlays found, we default back to initial icon.
		return
	for(var/image/I in standing)
		I.pixel_x = px_x
		I.pixel_y = px_y
	add_overlay(standing)

//Gives you a proper icon appearance for the dismembered limb
/obj/item/bodypart/proc/get_limb_icon(dropped)
	icon_state = "" //to erase the default sprite, we're building the visual aspects of the bodypart through overlays alone.

	. = list()

	var/image_dir = 0
	if(dropped)
		image_dir = SOUTH
		if(dmg_overlay_type)
			if(brutestate)
				. += image('icons/mob/dam_mob.dmi', "[dmg_overlay_type]_[body_zone]_[brutestate]0", -DAMAGE_LAYER, image_dir)
			if(burnstate)
				. += image('icons/mob/dam_mob.dmi', "[dmg_overlay_type]_[body_zone]_0[burnstate]", -DAMAGE_LAYER, image_dir)

	var/image/limb = image(layer = -BODYPARTS_LAYER, dir = image_dir)
	var/image/aux
	. += limb

	if(animal_origin)
		if(is_organic_limb())
			limb.icon = 'icons/mob/animal_parts.dmi'
			if(species_id == "husk")
				limb.icon_state = "[animal_origin]_husk_[body_zone]"
			else
				limb.icon_state = "[animal_origin]_[body_zone]"
		else
			limb.icon = 'icons/mob/augmentation/augments.dmi'
			limb.icon_state = "[animal_origin]_[body_zone]"
		return

	var/icon_gender = (body_gender == FEMALE) ? "f" : "m" //gender of the icon, if applicable

	if((body_zone != BODY_ZONE_HEAD && body_zone != BODY_ZONE_CHEST))
		should_draw_gender = FALSE

	if(is_organic_limb())
		if(should_draw_greyscale)
			limb.icon = 'icons/mob/human_parts_greyscale.dmi'
			if(should_draw_gender)
				limb.icon_state = "[species_id]_[body_zone]_[icon_gender]"
			else if(use_digitigrade)
				limb.icon_state = "digitigrade_[use_digitigrade]_[body_zone]"
			else
				limb.icon_state = "[species_id]_[body_zone]"
		else
			limb.icon = 'icons/mob/human_parts.dmi'
			if(should_draw_gender)
				limb.icon_state = "[species_id]_[body_zone]_[icon_gender]"
			else
				limb.icon_state = "[species_id]_[body_zone]"
		if(aux_zone)
			aux = image(limb.icon, "[species_id]_[aux_zone]", -aux_layer, image_dir)
			. += aux

	else
		limb.icon = icon
		if(should_draw_gender)
			limb.icon_state = "[body_zone]_[icon_gender]"
		else
			limb.icon_state = "[body_zone]"
		if(aux_zone)
			aux = image(limb.icon, "[aux_zone]", -aux_layer, image_dir)
			. += aux
		return


	if(should_draw_greyscale)
		var/draw_color = mutation_color || species_color || (skin_tone && skintone2hex(skin_tone))
		if(draw_color)
			limb.color = "#[draw_color]"
			if(aux_zone)
				aux.color = "#[draw_color]"

/obj/item/bodypart/deconstruct(disassembled = TRUE)
	drop_organs()
	qdel(src)

/obj/item/bodypart/chest
	name = BODY_ZONE_CHEST
	desc = "It's impolite to stare at a person's chest."
	icon_state = "default_human_chest"
	max_damage = 200
	body_zone = BODY_ZONE_CHEST
	body_part = CHEST
	px_x = 0
	px_y = 0
	var/obj/item/cavity_item

/obj/item/bodypart/chest/Destroy()
	if(cavity_item)
		qdel(cavity_item)
	return ..()

/obj/item/bodypart/chest/drop_organs(mob/user)
	if(cavity_item)
		cavity_item.forceMove(user.loc)
		cavity_item = null
	..()

/obj/item/bodypart/chest/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_chest"
	animal_origin = MONKEY_BODYPART

/obj/item/bodypart/chest/alien
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "alien_chest"
	dismemberable = 0
	max_damage = 500
	animal_origin = ALIEN_BODYPART

/obj/item/bodypart/chest/devil
	dismemberable = 0
	max_damage = 5000
	animal_origin = DEVIL_BODYPART

/obj/item/bodypart/chest/larva
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "larva_chest"
	dismemberable = 0
	max_damage = 50
	animal_origin = LARVA_BODYPART

/obj/item/bodypart/l_arm
	name = "left arm"
	desc = "Did you know that the word 'sinister' stems originally from the \
		Latin 'sinestra' (left hand), because the left hand was supposed to \
		be possessed by the devil? This arm appears to be possessed by no \
		one though."
	icon_state = "default_human_l_arm"
	attack_verb = list("slapped", "punched")
	max_damage = 50
	body_zone =BODY_ZONE_L_ARM
	body_part = ARM_LEFT
	aux_zone = BODY_ZONE_PRECISE_L_HAND
	aux_layer = HANDS_PART_LAYER
	held_index = 1
	px_x = -6
	px_y = 0

/obj/item/bodypart/l_arm/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_l_arm"
	animal_origin = MONKEY_BODYPART
	px_x = -5
	px_y = -3

/obj/item/bodypart/l_arm/alien
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "alien_l_arm"
	px_x = 0
	px_y = 0
	dismemberable = 0
	max_damage = 100
	animal_origin = ALIEN_BODYPART

/obj/item/bodypart/l_arm/devil
	dismemberable = 0
	max_damage = 5000
	animal_origin = DEVIL_BODYPART

/obj/item/bodypart/r_arm
	name = "right arm"
	desc = "Over 87% of humans are right handed. That figure is much lower \
		among humans missing their right arm."
	icon_state = "default_human_r_arm"
	attack_verb = list("slapped", "punched")
	max_damage = 50
	body_zone = BODY_ZONE_R_ARM
	body_part = ARM_RIGHT
	aux_zone = BODY_ZONE_PRECISE_R_HAND
	aux_layer = HANDS_PART_LAYER
	held_index = 2
	px_x = 6
	px_y = 0

/obj/item/bodypart/r_arm/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_r_arm"
	animal_origin = MONKEY_BODYPART
	px_x = 5
	px_y = -3

/obj/item/bodypart/r_arm/alien
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "alien_r_arm"
	px_x = 0
	px_y = 0
	dismemberable = 0
	max_damage = 100
	animal_origin = ALIEN_BODYPART

/obj/item/bodypart/r_arm/devil
	dismemberable = 0
	max_damage = 5000
	animal_origin = DEVIL_BODYPART

/obj/item/bodypart/l_leg
	name = "left leg"
	desc = "Some athletes prefer to tie their left shoelaces first for good \
		luck. In this instance, it probably would not have helped."
	icon_state = "default_human_l_leg"
	attack_verb = list("kicked", "stomped")
	max_damage = 50
	body_zone = BODY_ZONE_L_LEG
	body_part = LEG_LEFT
	px_x = -2
	px_y = 12

/obj/item/bodypart/l_leg/digitigrade
	name = "left digitigrade leg"
	use_digitigrade = FULL_DIGITIGRADE

/obj/item/bodypart/l_leg/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_l_leg"
	animal_origin = MONKEY_BODYPART
	px_y = 4

/obj/item/bodypart/l_leg/alien
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "alien_l_leg"
	px_x = 0
	px_y = 0
	dismemberable = 0
	max_damage = 100
	animal_origin = ALIEN_BODYPART

/obj/item/bodypart/l_leg/devil
	dismemberable = 0
	max_damage = 5000
	animal_origin = DEVIL_BODYPART

/obj/item/bodypart/r_leg
	name = "right leg"
	desc = "You put your right leg in, your right leg out. In, out, in, out, \
		shake it all about. And apparently then it detaches.\n\
		The hokey pokey has certainly changed a lot since space colonisation."
	// alternative spellings of 'pokey' are availible
	icon_state = "default_human_r_leg"
	attack_verb = list("kicked", "stomped")
	max_damage = 50
	body_zone = BODY_ZONE_R_LEG
	body_part = LEG_RIGHT
	px_x = 2
	px_y = 12

/obj/item/bodypart/r_leg/digitigrade
	name = "right digitigrade leg"
	use_digitigrade = FULL_DIGITIGRADE

/obj/item/bodypart/r_leg/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_r_leg"
	animal_origin = MONKEY_BODYPART
	px_y = 4

/obj/item/bodypart/r_leg/alien
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "alien_r_leg"
	px_x = 0
	px_y = 0
	dismemberable = 0
	max_damage = 100
	animal_origin = ALIEN_BODYPART

/obj/item/bodypart/r_leg/devil
	dismemberable = 0
	max_damage = 5000
	animal_origin = DEVIL_BODYPART
