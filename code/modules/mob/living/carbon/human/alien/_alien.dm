/mob/living/carbon/human/species/alien
	name = "alien"
	icon = 'icons/mob/alien.dmi'
	race = /datum/species/alien
	gender = FEMALE //All xenos are girls!!
	faction = list(ROLE_ALIEN)
	sight = SEE_MOBS
	bubble_icon = "alien"
	blocks_emissive = EMISSIVE_BLOCK_UNIQUE
	pass_flags = PASSTABLE
	status_flags = (CANUNCONSCIOUS | CANPUSH)
	unique_name = TRUE

	///Xenomorph names, changed overtime through evolution
	var/static/regex/alien_name_regex = new("alien (larva|sentinel|drone|hunter|praetorian|queen)( \\(\\d+\\))?")


/**
 * ALL of these should be removed eventually...
 */

/mob/living/carbon/human/species/alien/update_damage_overlays() //aliens don't have damage overlays.
	return

/mob/living/carbon/human/species/alien/update_body() // we don't use the bodyparts or body layers for aliens.
	return

/mob/living/carbon/human/species/alien/update_body_parts()//we don't use the bodyparts layer for aliens.
	return

/mob/living/carbon/human/species/alien/spawn_gibs(with_bodyparts)
	if(with_bodyparts)
		new /obj/effect/gibspawner/xeno(drop_location(), src)
	else
		new /obj/effect/gibspawner/xeno/bodypartless(drop_location(), src)

/mob/living/carbon/human/species/alien/assess_threat(judgement_criteria, lasercolor = "", datum/callback/weaponcheck=null) // beepsky won't hunt aliums
	return -10

/mob/living/carbon/human/species/alien/handle_environment(datum/gas_mixture/environment, delta_time, times_fired)
	// Run base mob body temperature proc before taking damage
	// this balances body temp to the environment and natural stabilization
	. = ..()

	if(bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT)
		//Body temperature is too hot.
		throw_alert("alien_fire", /atom/movable/screen/alert/alien_fire)
		switch(bodytemperature)
			if(360 to 400)
				apply_damage(HEAT_DAMAGE_LEVEL_1 * delta_time, BURN)
			if(400 to 460)
				apply_damage(HEAT_DAMAGE_LEVEL_2 * delta_time, BURN)
			if(460 to INFINITY)
				if(on_fire)
					apply_damage(HEAT_DAMAGE_LEVEL_3 * delta_time, BURN)
				else
					apply_damage(HEAT_DAMAGE_LEVEL_2 * delta_time, BURN)
	else
		clear_alert("alien_fire")

/mob/living/carbon/human/species/alien/reagent_check(datum/reagent/R, delta_time, times_fired) //can metabolize all reagents
	return FALSE

/mob/living/carbon/human/species/alien/getTrail()
	if(getBruteLoss() < 200)
		return pick (list("xltrails_1", "xltrails2"))
	else
		return pick (list("xttrails_1", "xttrails2"))


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

/mob/living/carbon/human/species/alien/proc/alien_evolve(mob/living/carbon/human/species/alien/new_xeno)
	to_chat(src, span_noticealien("You begin to evolve!"))
	visible_message(span_alertalien("[src] begins to twist and contort!"))
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

/mob/living/carbon/human/species/alien/can_hold_items(obj/item/I)
	return (I && (I.item_flags & XENOMORPH_HOLDABLE || ISADVANCEDTOOLUSER(src)) && ..())


/**
 * ALIEN SUBTYPES
 *
 * - Drone
 * - Hunter
 * - Sentinel
 * - Praetorian
 * - Queen
 */

/mob/living/carbon/human/species/alien/humanoid/drone
	name = "alien drone"
	race = /datum/species/alien/drone
	caste = "d"
	maxHealth = 125
	health = 125
	icon_state = "aliend"
