/mob/living/carbon/alien
	name = "alien"
	icon = 'icons/mob/nonhuman-player/alien.dmi'
	gender = FEMALE //All xenos are girls!!
	dna = null
	faction = list(ROLE_ALIEN)
	sight = SEE_MOBS
	verb_say = "hisses"
	initial_language_holder = /datum/language_holder/alien
	bubble_icon = "alien"
	type_of_meat = /obj/item/food/meat/slab/xeno
	blocks_emissive = EMISSIVE_BLOCK_UNIQUE

	status_flags = CANUNCONSCIOUS|CANPUSH

	heat_protection = 0.5 // minor heat insulation

	///Whether or not the alien is leaping. Only used by hunters.
	var/leaping = FALSE
	///The speed this alien should move at.
	var/alien_speed = 0
	gib_type = /obj/effect/decal/cleanable/xenoblood/xgibs
	unique_name = TRUE

	var/static/regex/alien_name_regex = new("alien (larva|sentinel|drone|hunter|praetorian|queen)( \\(\\d+\\))?")
	var/static/list/xeno_allowed_items = typecacheof(list(
		/obj/item/clothing/mask/facehugger,
		/obj/item/toy/basketball, // playing ball against a xeno is rigged since they cannot be disarmed, their game is out of this world
		/obj/item/toy/toy_xeno,
		/obj/item/sticker, //funny ~Jimmyl
		/obj/item/toy/plush/rouny,
	))

/mob/living/carbon/alien/Initialize(mapload)
	add_verb(src, /mob/living/proc/mob_sleep)
	add_verb(src, /mob/living/proc/toggle_resting)

	create_bodyparts() //initialize bodyparts

	create_internal_organs()

	add_traits(list(TRAIT_NEVER_WOUNDED, TRAIT_VENTCRAWLER_ALWAYS), INNATE_TRAIT)

	. = ..()
	if(alien_speed)
		update_alien_speed()
	LoadComponent( \
		/datum/component/itempicky, \
		xeno_allowed_items, \
		span_alien("Your claws lack the dexterity to hold %TARGET."), \
		CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_has_trait), src, TRAIT_ADVANCEDTOOLUSER))

/mob/living/carbon/alien/create_internal_organs()
	organs += new /obj/item/organ/internal/brain/alien
	organs += new /obj/item/organ/internal/alien/hivenode
	organs += new /obj/item/organ/internal/tongue/alien
	organs += new /obj/item/organ/internal/eyes/alien
	organs += new /obj/item/organ/internal/liver/alien
	organs += new /obj/item/organ/internal/ears
	..()

/mob/living/carbon/alien/assess_threat(judgement_criteria, lasercolor = "", datum/callback/weaponcheck=null) // beepsky won't hunt aliums
	return -10

/mob/living/carbon/alien/handle_environment(datum/gas_mixture/environment, seconds_per_tick, times_fired)
	// Run base mob body temperature proc before taking damage
	// this balances body temp to the environment and natural stabilization
	. = ..()

	if(bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT)
		//Body temperature is too hot.
		throw_alert(ALERT_XENO_FIRE, /atom/movable/screen/alert/alien_fire)
		switch(bodytemperature)
			if(360 to 400)
				apply_damage(HEAT_DAMAGE_LEVEL_1 * seconds_per_tick, BURN)
			if(400 to 460)
				apply_damage(HEAT_DAMAGE_LEVEL_2 * seconds_per_tick, BURN)
			if(460 to INFINITY)
				if(on_fire)
					apply_damage(HEAT_DAMAGE_LEVEL_3 * seconds_per_tick, BURN)
				else
					apply_damage(HEAT_DAMAGE_LEVEL_2 * seconds_per_tick, BURN)
	else
		clear_alert(ALERT_XENO_FIRE)

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
				var/obj/item/organ/internal/body_egg/alien_embryo/A = L.get_organ_by_type(/obj/item/organ/internal/body_egg/alien_embryo)
				if(A)
					var/I = image('icons/mob/nonhuman-player/alien.dmi', loc = L, icon_state = "infected[A.stage]")
					client.images += I
	return


/*----------------------------------------
Proc: RemoveInfectionImages()
Des: Removes all infected images from the alien.
----------------------------------------*/
/mob/living/carbon/alien/proc/RemoveInfectionImages()
	if(client)
		var/list/image/to_remove
		for(var/image/client_image as anything in client.images)
			var/searchfor = "infected"
			if(findtext(client_image.icon_state, searchfor, 1, length(searchfor) + 1))
				to_remove += client_image
		client.images -= to_remove
	return

/mob/living/carbon/alien/canBeHandcuffed()
	if(num_hands < 2)
		return FALSE
	return TRUE

/mob/living/carbon/alien/get_visible_suicide_message()
	return "[src] is thrashing wildly! It looks like [p_theyre()] trying to commit suicide."

/mob/living/carbon/alien/get_blind_suicide_message()
	return "You hear thrashing."

/mob/living/carbon/alien/proc/alien_evolve(mob/living/carbon/alien/new_xeno)
	visible_message(
		span_alertalien("[src] begins to twist and contort!"),
		span_noticealien("You begin to evolve!"),
	)

	new_xeno.setDir(dir)
	new_xeno.change_name(name, real_name, numba)

	if(mind)
		mind.name = new_xeno.real_name
		mind.transfer_to(new_xeno)

	var/obj/item/organ/internal/stomach/alien/melting_pot = get_organ_slot(ORGAN_SLOT_STOMACH)
	var/obj/item/organ/internal/stomach/alien/frying_pan = new_xeno.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(istype(melting_pot) && istype(frying_pan))
		for (var/atom/movable/poor_sod as anything in melting_pot.stomach_contents)
			frying_pan.consume_thing(poor_sod)
	qdel(src)

/// Changes the name of the xeno we are evolving into in order to keep the same numerical identifier the old xeno had.
/mob/living/carbon/alien/proc/change_name(old_name, old_real_name, old_number)
	if(!alien_name_regex.Find(old_name)) // check to make sure there's no admins doing funny stuff with naming these aliens
		name = old_name
		real_name = old_real_name
		return

	if(!unique_name)
		return

	if(old_number != 0)
		numba = old_number
		name = initial(name) // prevent chicanery like two different numerical identifiers tied to the same mob

	set_name()

/mob/living/carbon/alien/on_lying_down(new_lying_angle)
	. = ..()
	update_icons()

/mob/living/carbon/alien/on_standing_up()
	. = ..()
	update_icons()

/mob/living/carbon/alien/proc/update_alien_speed()
	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/alien_speed, multiplicative_slowdown = alien_speed)

/mob/living/carbon/alien/get_footprint_sprite()
	return FOOTPRINT_SPRITE_CLAWS
