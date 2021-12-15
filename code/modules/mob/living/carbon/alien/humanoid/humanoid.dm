GLOBAL_LIST_INIT(strippable_alien_humanoid_items, create_strippable_list(list(
	/datum/strippable_item/hand/left,
	/datum/strippable_item/hand/right,
	/datum/strippable_item/mob_item_slot/handcuffs,
	/datum/strippable_item/mob_item_slot/legcuffs,
)))

/mob/living/carbon/human/species/alien/humanoid
	name = "alien"
	icon_state = "alien"
	butcher_results = list(/obj/item/food/meat/slab/xeno = 5, /obj/item/stack/sheet/animalhide/xeno = 1)
	limb_destroyer = TRUE
	hud_type = /datum/hud/human/alien
	melee_damage_lower = 20 //Refers to unarmed damage, aliens do unarmed attacks.
	melee_damage_upper = 20
	deathsound = 'sound/voice/hiss6.ogg'
	bodyparts = list(
		/obj/item/bodypart/chest/alien,
		/obj/item/bodypart/head/alien,
		/obj/item/bodypart/l_arm/alien,
		/obj/item/bodypart/r_arm/alien,
		/obj/item/bodypart/r_leg/alien,
		/obj/item/bodypart/l_leg/alien,
	)

	var/caste = ""
	var/alt_icon = 'icons/mob/alienleap.dmi' //used to switch between the two alien icon files.
	var/leap_on_click = 0
	var/pounce_cooldown = 0
	var/pounce_cooldown_time = 30
	var/sneaking = 0 //For sneaky-sneaky mode and appropriate slowdown
	var/drooling = 0 //For Neruotoxic spit overlays

/mob/living/carbon/human/species/alien/humanoid/resist_grab(moving_resist)
	if(pulledby.grab_state)
		visible_message(span_danger("[src] breaks free of [pulledby]'s grip!"), \
						span_danger("You break free of [pulledby]'s grip!"))
	pulledby.stop_pulling()
	. = 0

/mob/living/carbon/human/species/alien/humanoid/get_permeability_protection(list/target_zones)
	return 0.8

/mob/living/carbon/human/species/alien/humanoid/alien_evolve(mob/living/carbon/human/species/alien/humanoid/new_xeno)
	drop_all_held_items()
	..()

//For alien evolution/promotion/queen finder procs. Checks for an active alien of that type
/proc/get_alien_type(alienpath)
	for(var/mob/living/carbon/human/species/alien/humanoid/A in GLOB.alive_mob_list)
		if(!istype(A, alienpath))
			continue
		if(!A.key || A.stat == DEAD) //Only living aliens with a ckey are valid.
			continue
		return A
	return FALSE


/mob/living/carbon/human/species/alien/humanoid/check_breath(datum/gas_mixture/breath)
	if(breath && breath.total_moles() > 0 && !sneaking)
		playsound(get_turf(src), pick('sound/voice/lowHiss2.ogg', 'sound/voice/lowHiss3.ogg', 'sound/voice/lowHiss4.ogg'), 50, FALSE, -5)
	..()

/mob/living/carbon/human/species/alien/humanoid/set_name()
	if(numba)
		name = "[name] ([numba])"
		real_name = name
