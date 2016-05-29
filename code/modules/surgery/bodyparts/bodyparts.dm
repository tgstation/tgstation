
/obj/item/bodypart
	name = "limb"
	desc = "why is it detached..."
	force = 3
	throwforce = 3
	var/mob/living/carbon/human/owner = null
	var/status = ORGAN_ORGANIC
	var/body_zone //"chest", "l_arm", etc , used for def_zone
	var/body_part = null //bitflag used to check which clothes cover this bodypart
	var/brutestate = 0
	var/burnstate = 0
	var/brute_dam = 0
	var/burn_dam = 0
	var/max_damage = 0
	var/list/embedded_objects = list()

	//Coloring and proper item icon update
	var/skin_tone = ""
	var/body_gender = ""
	var/species_id = ""
	var/should_draw_gender = FALSE
	var/should_draw_greyscale = FALSE
	var/species_color = ""
	var/mutation_color = ""
	var/no_update = 0

	var/px_x = 0
	var/px_y = 0

	var/state_flags

/obj/item/bodypart/examine(mob/user)
	..()
	if(brute_dam > 0)
		user << "<span class='warning'>This limb has [brute_dam > 30 ? "severe" : "minor"] bruising.</span>"
	if(burn_dam > 0)
		user << "<span class='warning'>This limb has [burn_dam > 30 ? "severe" : "minor"] burns.</span>"


/obj/item/bodypart/Destroy()
	if(owner)
		owner.bodyparts -= src
		owner = null
	return ..()

/obj/item/bodypart/attackby(obj/item/W, mob/user, params)
	if(W.sharpness)
		add_fingerprint(user)
		if(!contents.len)
			user << "<span class='warning'>There is nothing left inside [src]!</span>"
			return
		playsound(loc, 'sound/weapons/slice.ogg', 50, 1, -1)
		user.visible_message("<span class='warning'>[user] begins to cut through the bone in [src].</span>",\
			"<span class='notice'>You begin to cut through the bone in [src]...</span>")
		if(do_after(user, 54, target = src))
			drop_organs(user)
	else
		return ..()

/obj/item/bodypart/throw_impact(atom/hit_atom)
	..()
	playsound(get_turf(src), 'sound/misc/splort.ogg', 50, 1, -1)

/obj/item/bodypart/proc/drop_organs(mob/user)
	var/turf/T = get_turf(src)
	playsound(T, 'sound/misc/splort.ogg', 50, 1, -1)
	for(var/obj/item/I in src)
		I.loc = T

//Applies brute and burn damage to the organ. Returns 1 if the damage-icon states changed at all.
//Damage will not exceed max_damage using this proc
//Cannot apply negative damage
/obj/item/bodypart/proc/take_damage(brute, burn)
	if(owner && (owner.status_flags & GODMODE))
		return 0	//godmode
	brute	= max(brute,0)
	burn	= max(burn,0)


	if(status == ORGAN_ROBOTIC) //This makes robolimbs not damageable by chems and makes it stronger
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
	if(owner)
		owner.updatehealth()
	return update_bodypart_damage_state()


//Heals brute and burn damage for the organ. Returns 1 if the damage-icon states changed at all.
//Damage cannot go below zero.
//Cannot remove negative damage (i.e. apply damage)
/obj/item/bodypart/proc/heal_damage(brute, burn, robotic)

	if(robotic && status != ORGAN_ROBOTIC) // This makes organic limbs not heal when the proc is in Robotic mode.
		brute = max(0, brute - 3)
		burn = max(0, burn - 3)

	if(!robotic && status == ORGAN_ROBOTIC) // This makes robolimbs not healable by chems.
		brute = max(0, brute - 3)
		burn = max(0, burn - 3)

	brute_dam	= max(brute_dam - brute, 0)
	burn_dam	= max(burn_dam - burn, 0)
	if(owner)
		owner.updatehealth()
	return update_bodypart_damage_state()


//Returns total damage...kinda pointless really
/obj/item/bodypart/proc/get_damage()
	return brute_dam + burn_dam


//Updates an organ's brute/burn states for use by update_damage_overlays()
//Returns 1 if we need to update overlays. 0 otherwise.
/obj/item/bodypart/proc/update_bodypart_damage_state()
	if(status == ORGAN_ORGANIC) //Robotic limbs show no damage - RR
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
/obj/item/bodypart/proc/update_limb(dropping_limb, mob/living/carbon/human/source)
	var/mob/living/carbon/human/H
	if(source)
		H = source
	else
		H = owner
	if(!istype(H))
		return

	should_draw_greyscale = FALSE

	var/datum/species/S = H.dna.species
	species_id = S.limbs_id

	if(S.use_skintones)
		skin_tone = H.skin_tone
		should_draw_greyscale = TRUE
	else
		skin_tone = ""

	body_gender = H.gender
	should_draw_gender = S.sexes

	if(MUTCOLORS in S.specflags)
		species_color = H.dna.features["mcolor"]
		should_draw_greyscale = TRUE
	else
		species_color = ""

	if(H.disabilities & HUSK)
		species_id = "husk"
		should_draw_gender = FALSE
		should_draw_greyscale = FALSE

	if(!dropping_limb && H.dna.check_mutation(HULK))
		mutation_color = "00aa00"
	else
		mutation_color = ""

	if(dropping_limb)
		no_update = 1 //when attached, the limb won't be affected by the appearance changes of its mob owner.

//to update the bodypart's icon when not attached to a mob
/obj/item/bodypart/proc/update_icon_dropped()
	overlays.Cut()
	var/image/I = get_limb_icon(1)
	if(I)
		I.pixel_x = px_x
		I.pixel_y = px_y
		overlays += I

//Gives you a proper icon appearance for the dismembered limb
/obj/item/bodypart/proc/get_limb_icon(dropped)
	var/image/I

	var/icon_gender = (body_gender == FEMALE) ? "f" : "m" //gender of the icon, if applicable

	if((body_zone != "head" && body_zone != "chest"))
		should_draw_gender = FALSE

	var/image_dir
	if(dropped)
		image_dir = SOUTH
	if(status == ORGAN_ORGANIC)
		if(should_draw_greyscale)
			if(should_draw_gender)
				I = image("icon"='icons/mob/human_parts_greyscale.dmi', "icon_state"="[species_id]_[body_zone]_[icon_gender]_s", "layer"=-BODYPARTS_LAYER, "dir"=image_dir)
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
		return I


	if(!should_draw_greyscale)
		return I

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

	return I



/obj/item/bodypart/chest
	name = "chest"
	desc = "It's impolite to stare at a person's chest."
	icon_state = "chest"
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

/obj/item/bodypart/l_arm
	name = "left arm"
	desc = "Did you know that the word 'sinister' stems originally from the \
		Latin 'sinestra' (left hand), because the left hand was supposed to \
		be possessed by the devil? This arm appears to be possessed by no \
		one though."
	icon_state = "l_arm"
	max_damage = 50
	body_zone ="l_arm"
	body_part = ARM_LEFT
	px_x = -6
	px_y = 0

/obj/item/bodypart/r_arm
	name = "right arm"
	desc = "Over 87% of humans are right handed. That figure is much lower \
		among humans missing their right arm."
	icon_state = "r_arm"
	max_damage = 50
	body_zone = "r_arm"
	body_part = ARM_RIGHT
	px_x = 6
	px_y = 0

/obj/item/bodypart/l_leg
	name = "left leg"
	desc = "Some athletes prefer to tie their left shoelaces first for good \
		luck. In this instance, it probably would not have helped."
	icon_state = "l_leg"
	max_damage = 50
	body_zone = "l_leg"
	body_part = LEG_LEFT
	px_x = -2
	px_y = 12

/obj/item/bodypart/r_leg
	name = "right leg"
	desc = "You put your right leg in, your right leg out. In, out, in, out, \
		shake it all about. And apparently then it detaches.\n\
		The hokey pokey has certainly changed a lot since space colonisation."
	// alternative spellings of 'pokey' are availible
	icon_state = "r_leg"
	max_damage = 50
	body_zone = "r_leg"
	body_part = LEG_RIGHT
	px_x = 2
	px_y = 12


/////////////////////////////////////////////////////////////////////////

/obj/item/severedtail
	name = "tail"
	desc = "A severed tail. Somewhere, no doubt, a lizard hater is very \
		pleased with themselves."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "severedtail"
	color = "#161"
	var/markings = "Smooth"
