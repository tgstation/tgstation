
/obj/item/bodypart
	name = "limb"
	desc = "why is it detached..."
	force = 3
	throwforce = 3
	icon = 'icons/mob/human_parts.dmi'
	icon_state = ""
	layer = BELOW_MOB_LAYER //so it isn't hidden behind objects when on the floor
	var/mob/living/carbon/owner = null
	var/mob/living/carbon/original_owner = null
	var/status = BODYPART_ORGANIC
	var/body_zone //"chest", "l_arm", etc , used for def_zone
	var/body_part = null //bitflag used to check which clothes cover this bodypart
	var/use_digitigrade = NOT_DIGITIGRADE //Used for alternate legs, useless elsewhere
	var/brutestate = 0
	var/burnstate = 0
	var/brute_dam = 0
	var/burn_dam = 0
	var/max_damage = 0
	var/list/embedded_objects = list()
	var/held_index = 0 //are we a hand? if so, which one!

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

/obj/item/bodypart/examine(mob/user)
	..()
	if(brute_dam > 0)
		user << "<span class='warning'>This limb has [brute_dam > 30 ? "severe" : "minor"] bruising.</span>"
	if(burn_dam > 0)
		user << "<span class='warning'>This limb has [burn_dam > 30 ? "severe" : "minor"] burns.</span>"

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
		if(EASYLIMBATTACHMENT in H.dna.species.species_traits)
			if(!H.get_bodypart(body_zone) && !animal_origin)
				if(H == user)
					H.visible_message("<span class='warning'>[H] jams [src] into [H.p_their()] empty socket!</span>",\
					"<span class='notice'>You force [src] into your empty socket, and it locks into place!</span>")
				else
					H.visible_message("<span class='warning'>[user] jams [src] into [H]'s empty socket!</span>",\
					"<span class='notice'>[user] forces [src] into your empty socket, and it locks into place!</span>")
				user.unEquip(src,1)
				attach_limb(C)
				return
	..()

/obj/item/bodypart/attackby(obj/item/W, mob/user, params)
	if(W.sharpness)
		add_fingerprint(user)
		if(!contents.len)
			user << "<span class='warning'>There is nothing left inside [src]!</span>"
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
/obj/item/bodypart/proc/receive_damage(brute, burn, updating_health = 1)
	if(owner && (owner.status_flags & GODMODE))
		return 0	//godmode
	brute	= max(brute * config.damage_multiplier,0)
	burn	= max(burn * config.damage_multiplier,0)


	if(status == BODYPART_ROBOTIC) //This makes robolimbs not damageable by chems and makes it stronger
		brute = max(0, brute - 5)
		burn = max(0, burn - 4)

	var/can_inflict = max_damage - (brute_dam + burn_dam)
	if(!can_inflict)
		return 0

	if((brute + burn) < can_inflict)
		brute_dam	+= brute
		burn_dam	+= burn
	else
		if(brute > 0)
			if(burn > 0)
				brute	= round( (brute/(brute+burn)) * can_inflict, 1 )
				burn	= can_inflict - brute	//gets whatever damage is left over
				brute_dam	+= brute
				burn_dam	+= burn
			else
				brute_dam	+= can_inflict
		else
			if(burn > 0)
				burn_dam	+= can_inflict
			else
				return 0
	if(owner && updating_health)
		owner.updatehealth()
	return update_bodypart_damage_state()


//Heals brute and burn damage for the organ. Returns 1 if the damage-icon states changed at all.
//Damage cannot go below zero.
//Cannot remove negative damage (i.e. apply damage)
/obj/item/bodypart/proc/heal_damage(brute, burn, only_robotic = 0, only_organic = 1, updating_health = 1)

	if(only_robotic && status != BODYPART_ROBOTIC) //This makes organic limbs not heal when the proc is in Robotic mode.
		return

	if(only_organic && status != BODYPART_ORGANIC) //This makes robolimbs not healable by chems.
		return

	brute_dam	= max(brute_dam - brute, 0)
	burn_dam	= max(burn_dam - burn, 0)
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
		return 1
	return 0



//Change organ status
/obj/item/bodypart/proc/change_bodypart_status(new_limb_status, heal_limb)
	status = new_limb_status
	if(heal_limb)
		burn_dam = 0
		brute_dam = 0
		brutestate = 0
		burnstate = 0
	if(owner)
		owner.updatehealth()
		owner.update_body() //if our head becomes robotic, we remove the lizard horns and human hair.
		owner.update_hair()
		owner.update_damage_overlays()

//we inform the bodypart of the changes that happened to the owner, or give it the informations from a source mob.
/obj/item/bodypart/proc/update_limb(dropping_limb, mob/living/carbon/source)
	var/mob/living/carbon/C
	if(source)
		C = source
		if(!original_owner)
			original_owner = source
	else if(original_owner && owner != original_owner) //Foreign limb
		no_update = 1
	else
		C = owner
		no_update = 0

	if(C.disabilities & HUSK)
		species_id = "husk" //overrides species_id
		dmg_overlay_type = "" //no damage overlay shown when husked
		should_draw_gender = FALSE
		should_draw_greyscale = FALSE
		no_update = 1

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
		no_update = 1 //when attached, the limb won't be affected by the appearance changes of its mob owner.

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

	var/list/standing = list()

	var/image_dir
	if(dropped)
		image_dir = SOUTH
		if(dmg_overlay_type)
			if(brutestate)
				standing	+= image("icon"='icons/mob/dam_mob.dmi', "icon_state"="[dmg_overlay_type]_[body_zone]_[brutestate]0", "layer"=-DAMAGE_LAYER, "dir"=image_dir)
			if(burnstate)
				standing	+= image("icon"='icons/mob/dam_mob.dmi', "icon_state"="[dmg_overlay_type]_[body_zone]_0[burnstate]", "layer"=-DAMAGE_LAYER, "dir"=image_dir)


	if(animal_origin)
		if(status == BODYPART_ORGANIC)
			if(species_id == "husk")
				standing += image("icon"='icons/mob/animal_parts.dmi', "icon_state"="[animal_origin]_husk_[body_zone]_s", "layer"=-BODYPARTS_LAYER, "dir"=image_dir)
			else
				standing += image("icon"='icons/mob/animal_parts.dmi', "icon_state"="[animal_origin]_[body_zone]_s", "layer"=-BODYPARTS_LAYER, "dir"=image_dir)
		else
			standing += image("icon"='icons/mob/augments.dmi', "icon_state"="[animal_origin]_[body_zone]_s", "layer"=-BODYPARTS_LAYER, "dir"=image_dir)
		return standing

	var/icon_gender = (body_gender == FEMALE) ? "f" : "m" //gender of the icon, if applicable

	if((body_zone != "head" && body_zone != "chest"))
		should_draw_gender = FALSE

	var/image/I

	if(status == BODYPART_ORGANIC)
		if(should_draw_greyscale)
			if(should_draw_gender)
				I = image("icon"='icons/mob/human_parts_greyscale.dmi', "icon_state"="[species_id]_[body_zone]_[icon_gender]_s", "layer"=-BODYPARTS_LAYER, "dir"=image_dir)
			else if(use_digitigrade)
				I = image("icon"='icons/mob/human_parts_greyscale.dmi', "icon_state"="digitigrade_[use_digitigrade]_[body_zone]_s", "layer"=-BODYPARTS_LAYER, "dir"=image_dir)
			else
				I = image("icon"='icons/mob/human_parts_greyscale.dmi', "icon_state"="[species_id]_[body_zone]_s", "layer"=-BODYPARTS_LAYER, "dir"=image_dir)
		else
			if(should_draw_gender)
				I = image("icon"='icons/mob/human_parts.dmi', "icon_state"="[species_id]_[body_zone]_[icon_gender]_s", "layer"=-BODYPARTS_LAYER, "dir"=image_dir)
			else
				I = image("icon"='icons/mob/human_parts.dmi', "icon_state"="[species_id]_[body_zone]_s", "layer"=-BODYPARTS_LAYER, "dir"=image_dir)
	else
		if(should_draw_gender)
			I = image("icon"='icons/mob/augments.dmi', "icon_state"="[body_zone]_[icon_gender]_s", "layer"=-BODYPARTS_LAYER, "dir"=image_dir)
		else
			I = image("icon"='icons/mob/augments.dmi', "icon_state"="[body_zone]_s", "layer"=-BODYPARTS_LAYER, "dir"=image_dir)
		standing += I
		return standing


	if(!should_draw_greyscale)
		standing += I
		return standing

	//Greyscale Colouring
	var/draw_color

	if(skin_tone) //Limb has skin color variable defined, use it
		draw_color = skintone2hex(skin_tone)
	if(species_color)
		draw_color = species_color
	if(mutation_color)
		draw_color = mutation_color

	if(draw_color)
		I.color = "#[draw_color]"
	//End Greyscale Colouring
	standing += I

	return standing



/obj/item/bodypart/deconstruct(disassembled = TRUE)
	drop_organs()
	qdel(src)

/obj/item/bodypart/chest
	name = "chest"
	desc = "It's impolite to stare at a person's chest."
	icon_state = "default_human_chest"
	max_damage = 200
	body_zone = "chest"
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
	icon_state = "alien_chest_s"
	dismemberable = 0
	max_damage = 500
	animal_origin = ALIEN_BODYPART

/obj/item/bodypart/chest/devil
	dismemberable = 0
	max_damage = 5000
	animal_origin = DEVIL_BODYPART

/obj/item/bodypart/chest/larva
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "larva_chest_s"
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
	body_zone ="l_arm"
	body_part = ARM_LEFT
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
	icon_state = "alien_l_arm_s"
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
	body_zone = "r_arm"
	body_part = ARM_RIGHT
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
	icon_state = "alien_r_arm_s"
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
	body_zone = "l_leg"
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
	icon_state = "alien_l_leg_s"
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
	body_zone = "r_leg"
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
	icon_state = "alien_r_leg_s"
	px_x = 0
	px_y = 0
	dismemberable = 0
	max_damage = 100
	animal_origin = ALIEN_BODYPART

/obj/item/bodypart/r_leg/devil
	dismemberable = 0
	max_damage = 5000
	animal_origin = DEVIL_BODYPART


/////////////////////////////////////////////////////////////////////////

/obj/item/severedtail
	name = "tail"
	desc = "A severed tail. Somewhere, no doubt, a lizard hater is very \
		pleased with themselves."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "severedtail"
	color = "#161"
	var/markings = "Smooth"
