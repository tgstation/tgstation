/mob/living/carbon/alien
	name = "alien"
	icon = 'icons/mob/alien.dmi'
	gender = FEMALE //All xenos are girls!!
	dna = null
	faction = list(ROLE_ALIEN)
	sight = SEE_MOBS
	see_in_dark = 4
	verb_say = "hisses"
	initial_language_holder = /datum/language_holder/alien
	bubble_icon = "alien"
	type_of_meat = /obj/item/food/meat/slab/xeno

	var/move_delay_add = 0 // movement delay to add

	status_flags = CANUNCONSCIOUS|CANPUSH

	heat_protection = 0.5 // minor heat insulation

	var/leaping = FALSE
	gib_type = /obj/effect/decal/cleanable/xenoblood/xgibs
	unique_name = TRUE

	var/static/regex/alien_name_regex = new("alien (larva|sentinel|drone|hunter|praetorian|queen)( \\(\\d+\\))?")

/mob/living/carbon/alien/Initialize()
	add_verb(src, /mob/living/proc/mob_sleep)
	add_verb(src, /mob/living/proc/toggle_resting)

	create_bodyparts() //initialize bodyparts

	create_internal_organs()

	ADD_TRAIT(src, TRAIT_NEVER_WOUNDED, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	. = ..()

/mob/living/carbon/alien/create_internal_organs()
	internal_organs += new /obj/item/organ/brain/alien
	internal_organs += new /obj/item/organ/alien/hivenode
	internal_organs += new /obj/item/organ/tongue/alien
	internal_organs += new /obj/item/organ/eyes/night_vision/alien
	internal_organs += new /obj/item/organ/liver/alien
	internal_organs += new /obj/item/organ/ears
	..()

/mob/living/carbon/alien/assess_threat(judgement_criteria, lasercolor = "", datum/callback/weaponcheck=null) // beepsky won't hunt aliums
	return -10

/mob/living/carbon/alien/handle_environment(datum/gas_mixture/environment)
	// Run base mob body temperature proc before taking damage
	// this balances body temp to the environment and natural stabilization
	. = ..()

	if(bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT)
		//Body temperature is too hot.
		throw_alert("alien_fire", /atom/movable/screen/alert/alien_fire)
		switch(bodytemperature)
			if(360 to 400)
				apply_damage(HEAT_DAMAGE_LEVEL_1, BURN)
			if(400 to 460)
				apply_damage(HEAT_DAMAGE_LEVEL_2, BURN)
			if(460 to INFINITY)
				if(on_fire)
					apply_damage(HEAT_DAMAGE_LEVEL_3, BURN)
				else
					apply_damage(HEAT_DAMAGE_LEVEL_2, BURN)
	else
		clear_alert("alien_fire")

/mob/living/carbon/alien/reagent_check(datum/reagent/R) //can metabolize all reagents
	return 0

/mob/living/carbon/alien/get_status_tab_items()
	. = ..()
	. += "Intent: [a_intent]"

/mob/living/carbon/alien/getTrail()
	if(getBruteLoss() < 200)
		return pick (list("xltrails_1", "xltrails2"))
	else
		return pick (list("xttrails_1", "xttrails2"))
/*----------------------------------------
Proc: AddInfectionImages()
Des: Gives the client of the alien an image on each infected mob.
----------------------------------------*/
/mob/living/carbon/alien/proc/AddInfectionImages()
	if (client)
		for (var/i in GLOB.mob_living_list)
			var/mob/living/L = i
			if(HAS_TRAIT(L, TRAIT_XENO_HOST))
				var/obj/item/organ/body_egg/alien_embryo/A = L.getorgan(/obj/item/organ/body_egg/alien_embryo)
				if(A)
					var/I = image('icons/mob/alien.dmi', loc = L, icon_state = "infected[A.stage]")
					client.images += I
	return


/*----------------------------------------
Proc: RemoveInfectionImages()
Des: Removes all infected images from the alien.
----------------------------------------*/
/mob/living/carbon/alien/proc/RemoveInfectionImages()
	if (client)
		for(var/image/I in client.images)
			var/searchfor = "infected"
			if(findtext(I.icon_state, searchfor, 1, length(searchfor) + 1))
				qdel(I)
	return

/mob/living/carbon/alien/canBeHandcuffed()
	if(num_hands < 2)
		return FALSE
	return TRUE

/mob/living/carbon/alien/proc/alien_evolve(mob/living/carbon/alien/new_xeno)
	to_chat(src, "<span class='noticealien'>You begin to evolve!</span>")
	visible_message("<span class='alertalien'>[src] begins to twist and contort!</span>")
	new_xeno.setDir(dir)
	if(numba && unique_name)
		new_xeno.numba = numba
		new_xeno.set_name()
	if(!alien_name_regex.Find(name))
		new_xeno.name = name
		new_xeno.real_name = real_name
	if(mind)
		mind.transfer_to(new_xeno)
	var/datum/component/nanites/nanites = GetComponent(/datum/component/nanites)
	if(nanites)
		new_xeno.AddComponent(/datum/component/nanites, nanites.nanite_volume)
		SEND_SIGNAL(new_xeno, COMSIG_NANITE_SYNC, nanites)
	qdel(src)

/mob/living/carbon/alien/can_hold_items(obj/item/I)
	return (I && (I.item_flags & XENOMORPH_HOLDABLE || ISADVANCEDTOOLUSER(src)) && ..())

/mob/living/carbon/alien/on_lying_down(new_lying_angle)
	. = ..()
	update_icons()

/mob/living/carbon/alien/on_standing_up()
	. = ..()
	update_icons()
