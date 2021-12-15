GLOBAL_LIST_INIT(strippable_alien_humanoid_items, create_strippable_list(list(
	/datum/strippable_item/hand/left,
	/datum/strippable_item/hand/right,
	/datum/strippable_item/mob_item_slot/handcuffs,
	/datum/strippable_item/mob_item_slot/legcuffs,
)))

/mob/living/carbon/human/species/alien
	name = "alien"
	icon = 'icons/mob/alien.dmi'
	race = /datum/species/alien
	gender = FEMALE //All xenos are girls!!
	faction = list(ROLE_ALIEN)
	limb_destroyer = TRUE
	bubble_icon = "alien"
	hud_type = /datum/hud/human/alien
	blocks_emissive = EMISSIVE_BLOCK_UNIQUE
	pass_flags = PASSTABLE
	status_flags = (CANUNCONSCIOUS | CANPUSH)
	unique_name = TRUE

	///Xenomorph names, changed overtime through evolution
	var/static/regex/alien_name_regex = new("alien (larva|sentinel|drone|hunter|praetorian|queen)( \\(\\d+\\))?")

	var/caste = ""
	var/sneaking = 0 //For sneaky-sneaky mode and appropriate slowdown
	var/drooling = 0 //For Neruotoxic spit overlays


/**
 * These should eventually get removed
 */

/mob/living/carbon/human/species/alien/update_damage_overlays() //aliens don't have damage overlays.
	return

/mob/living/carbon/human/species/alien/update_body() // we don't use the bodyparts or body layers for aliens.
	return

/mob/living/carbon/human/species/alien/update_body_parts()//we don't use the bodyparts layer for aliens.
	return

/mob/living/carbon/human/species/alien/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	..(AM, skipcatch = TRUE, hitpush = FALSE)

/mob/living/carbon/human/species/alien/set_name()
	if(numba)
		name = "[name] ([numba])"
		real_name = name

/mob/living/carbon/human/species/alien/update_icons()
	cut_overlays()
	for(var/I in overlays_standing)
		add_overlay(I)

	var/asleep = IsSleeping()
	if(stat == DEAD)
		//If we mostly took damage from fire
		if(getFireLoss() > 125)
			icon_state = "alien[caste]_husked"
		else
			icon_state = "alien[caste]_dead"

	else if((stat == UNCONSCIOUS && !asleep) || stat == HARD_CRIT || stat == SOFT_CRIT || IsParalyzed())
		icon_state = "alien[caste]_unconscious"

	else if(body_position == LYING_DOWN)
		icon_state = "alien[caste]_sleep"
	else if(mob_size == MOB_SIZE_LARGE)
		icon_state = "alien[caste]"
		if(drooling)
			add_overlay("alienspit_[caste]")
	else
		icon_state = "alien[caste]"
		if(drooling)
			add_overlay("alienspit")

	pixel_x = base_pixel_x + body_position_pixel_x_offset
	pixel_y = base_pixel_y + body_position_pixel_y_offset
	update_inv_hands()
	update_inv_handcuffed()

/mob/living/carbon/human/species/alien/update_inv_handcuffed()
	remove_overlay(HANDCUFF_LAYER)
	var/cuff_icon = "aliencuff"
	var/dmi_file = 'icons/mob/alien.dmi'

	if(mob_size == MOB_SIZE_LARGE)
		cuff_icon = "aliencuff_[caste]"
		dmi_file = 'icons/mob/alienqueen.dmi'

	if(handcuffed)
		var/mutable_appearance/handcuff_overlay = mutable_appearance(dmi_file, cuff_icon, -HANDCUFF_LAYER)
		if(handcuffed.blocks_emissive)
			handcuff_overlay += emissive_blocker(handcuff_overlay.icon, handcuff_overlay.icon_state, alpha = handcuff_overlay.alpha)

		overlays_standing[HANDCUFF_LAYER] = handcuff_overlay
		apply_overlay(HANDCUFF_LAYER)

/mob/living/carbon/human/species/alien/spawn_gibs(with_bodyparts)
	if(with_bodyparts)
		new /obj/effect/gibspawner/xeno(drop_location(), src)
	else
		new /obj/effect/gibspawner/xeno/bodypartless(drop_location(), src)

/mob/living/carbon/human/species/alien/assess_threat(judgement_criteria, lasercolor = "", datum/callback/weaponcheck=null) // beepsky won't hunt aliums
	return -10

/mob/living/carbon/human/species/alien/check_breath(datum/gas_mixture/breath)
	if(status_flags & GODMODE)
		return

	if(!breath || (breath.total_moles() == 0))
		//Aliens breathe in vaccuum
		return FALSE

	if(breath.total_moles() > 0 && !sneaking)
		playsound(get_turf(src), pick('sound/voice/lowHiss2.ogg', 'sound/voice/lowHiss3.ogg', 'sound/voice/lowHiss4.ogg'), 50, FALSE, -5)

	if(health <= HEALTH_THRESHOLD_CRIT)
		adjustOxyLoss(2)

	var/plasma_used = 0
	var/plas_detect_threshold = 0.02
	var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME
	var/list/breath_gases = breath.gases

	breath.assert_gases(/datum/gas/plasma, /datum/gas/oxygen)

	//Partial pressure of the plasma in our breath
	var/Plasma_pp = (breath_gases[/datum/gas/plasma][MOLES]/breath.total_moles())*breath_pressure

	if(Plasma_pp > plas_detect_threshold) // Detect plasma in air
		adjustPlasma(breath_gases[/datum/gas/plasma][MOLES]*250)
		throw_alert("alien_plas", /atom/movable/screen/alert/alien_plas)

		plasma_used = breath_gases[/datum/gas/plasma][MOLES]

	else
		clear_alert("alien_plas")

	//Breathe in plasma and out oxygen
	breath_gases[/datum/gas/plasma][MOLES] -= plasma_used
	breath_gases[/datum/gas/oxygen][MOLES] += plasma_used

	breath.garbage_collect()

	//BREATH TEMPERATURE
	handle_breath_temperature(breath)

/mob/living/carbon/human/species/alien/getTrail()
	if(getBruteLoss() < 200)
		return pick (list("xltrails_1", "xltrails2"))
	else
		return pick (list("xttrails_1", "xttrails2"))

//Royals have bigger sprites, so inhand things must be handled differently.
/mob/living/carbon/human/species/alien/royal/update_inv_hands()
	..()
	remove_overlay(HANDS_LAYER)
	var/list/hands = list()

	var/obj/item/l_hand = get_item_for_held_index(1)
	if(l_hand)
		var/itm_state = l_hand.inhand_icon_state
		if(!itm_state)
			itm_state = l_hand.icon_state
		var/mutable_appearance/l_hand_item = mutable_appearance(alt_inhands_file, "[itm_state][caste]_l", -HANDS_LAYER)
		if(l_hand.blocks_emissive)
			l_hand_item.overlays += emissive_blocker(l_hand_item.icon, l_hand_item.icon_state, alpha = l_hand_item.alpha)
		hands += l_hand_item

	var/obj/item/r_hand = get_item_for_held_index(2)
	if(r_hand)
		var/itm_state = r_hand.inhand_icon_state
		if(!itm_state)
			itm_state = r_hand.icon_state
		var/mutable_appearance/r_hand_item = mutable_appearance(alt_inhands_file, "[itm_state][caste]_r", -HANDS_LAYER)
		if(r_hand.blocks_emissive)
			r_hand_item.overlays += emissive_blocker(r_hand_item.icon, r_hand_item.icon_state, alpha = r_hand_item.alpha)
		hands += r_hand_item

	overlays_standing[HANDS_LAYER] = hands
	apply_overlay(HANDS_LAYER)



/*----------------------------------------
Proc: AddInfectionImages()
Des: Gives the client of the alien an image on each infected mob.
Todo: remove this
----------------------------------------*/
/mob/living/carbon/human/species/alien/proc/AddInfectionImages()
	if(!client)
		return
	for(var/mob/living/L as anything in GLOB.mob_living_list)
		if(!HAS_TRAIT(L, TRAIT_XENO_HOST))
			continue
		var/obj/item/organ/body_egg/alien_embryo/A = L.getorgan(/obj/item/organ/body_egg/alien_embryo)
		if(A)
			var/I = image('icons/mob/alien.dmi', loc = L, icon_state = "infected[A.stage]")
			client.images += I


/*----------------------------------------
Proc: RemoveInfectionImages()
Des: Removes all infected images from the alien.
----------------------------------------*/
/mob/living/carbon/human/species/alien/proc/RemoveInfectionImages()
	if(!client)
		return
	for(var/image/I in client.images)
		var/searchfor = "infected"
		if(findtext(I.icon_state, searchfor, 1, length(searchfor) + 1))
			qdel(I)

/mob/living/carbon/human/species/alien/can_hold_items(obj/item/I)
	return (I && (I.item_flags & XENOMORPH_HOLDABLE || ISADVANCEDTOOLUSER(src)) && ..())

/mob/living/carbon/human/species/alien/proc/alien_evolve(mob/living/carbon/human/species/alien/new_xeno)
	to_chat(src, span_noticealien("You begin to evolve!"))
	visible_message(span_alertalien("[src] begins to twist and contort!"))
	drop_all_held_items()
	new_xeno.setDir(dir)
	if(numba && unique_name)
		new_xeno.numba = numba
		new_xeno.set_name()
	if(!alien_name_regex.Find(name))
		new_xeno.name = name
		new_xeno.real_name = real_name
	if(mind)
		mind.name = new_xeno.real_name
		mind.transfer_to(new_xeno)
	qdel(src)

//For alien evolution/promotion/queen finder procs. Checks for an active alien of that type
/proc/get_alien_type(alienpath)
	for(var/mob/living/carbon/human/species/alien/A in GLOB.alive_mob_list)
		if(!istype(A, alienpath))
			continue
		if(!A.key || A.stat == DEAD) //Only living aliens with a ckey are valid.
			continue
		return A
	return FALSE


/**
 * ALIEN SUBTYPES
 *
 * - Drone
 * - Hunter
 * - Sentinel
 * - Praetorian
 * - Queen
 */

/mob/living/carbon/human/species/alien/drone
	name = "alien drone"
	race = /datum/species/alien/drone
	caste = "d"
	maxHealth = 125
	health = 125
	icon_state = "aliend"

/mob/living/carbon/human/species/alien/hunter
	name = "alien hunter"
	race = /datum/species/alien/hunter
	caste = "h"
	maxHealth = 125
	health = 125
	icon_state = "alienh"

/mob/living/carbon/human/species/alien/sentinel
	name = "alien sentinel"
	race = /datum/species/alien/sentinel
	caste = "s"
	maxHealth = 150
	health = 150
	icon_state = "aliens"

/mob/living/carbon/human/species/alien/praetorian
	icon = 'icons/mob/alienqueen.dmi'
	race = /datum/species/alien/praetorian
	status_flags = NONE // CANSTUN|CANKNOCKDOWN|CANUNCONSCIOUS|CANPUSH
	pixel_x = -16
	base_pixel_x = -16
	bubble_icon = "alienroyal"
	mob_size = MOB_SIZE_LARGE
	layer = LARGE_MOB_LAYER //above most mobs, but below speechbubbles
	pressure_resistance = 200 //Because big, stompy xenos should not be blown around like paper.

	var/alt_inhands_file = 'icons/mob/alienqueen.dmi'


/mob/living/carbon/human/species/alien/praetorian/queen
	name = "alien queen"
	race = /datum/species/alien/praetorian/queen
	caste = "q"
	maxHealth = 400
	health = 400
	icon_state = "alienq"
