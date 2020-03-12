/mob/living/carbon/alien
	name = "alien"
	icon = 'icons/mob/alien.dmi'
	gender = FEMALE //All xenos are girls!!
	dna = null
	faction = list(ROLE_ALIEN)
	ventcrawler = VENTCRAWLER_ALWAYS
	sight = SEE_MOBS
	see_in_dark = 4
	verb_say = "hisses"
	initial_language_holder = /datum/language_holder/alien
	bubble_icon = "alien"
	type_of_meat = /obj/item/reagent_containers/food/snacks/meat/slab/xeno

	var/obj/item/card/id/wear_id = null // Fix for station bounced radios -- Skie
	var/has_fine_manipulation = 0
	var/move_delay_add = 0 // movement delay to add
	var/list/evolution_paths

	status_flags = CANUNCONSCIOUS|CANPUSH

	heat_protection = 0.5 // minor heat insulation

	var/leaping = 0
	gib_type = /obj/effect/decal/cleanable/xenoblood/xgibs
	unique_name = 1

	var/static/regex/alien_name_regex = new("alien (larva|sentinel|drone|hunter|praetorian|queen)( \\(\\d+\\))?")

/mob/living/carbon/alien/Initialize()
	verbs += /mob/living/proc/mob_sleep
	verbs += /mob/living/proc/lay_down

	create_bodyparts() //initialize bodyparts

	create_internal_organs()
	if(evolution_paths)
		AddAbility(new/obj/effect/proc_holder/alien/evolve(null))
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
	// this balances body temp to the enviroment and natural stabilization
	. = ..()

	if(bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT)
		//Body temperature is too hot.
		throw_alert("alien_fire", /obj/screen/alert/alien_fire)
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

/mob/living/carbon/alien/IsAdvancedToolUser()
	return has_fine_manipulation

/mob/living/carbon/alien/Stat()
	..()

	if(statpanel("Status"))
		stat(null, "Intent: [a_intent]")

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
	return 1

/mob/living/carbon/alien/get_standard_pixel_y_offset(lying = 0)
	return initial(pixel_y)

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

/mob/living/carbon/alien/can_hold_items()
	return has_fine_manipulation

/obj/effect/proc_holder/alien/evolve
	name = "Evolve"
	desc = "Evolve into a higher alien caste."
	plasma_cost = 0

	action_icon_state = "alien_evolve_larva"

/obj/effect/proc_holder/alien/evolve/fire(mob/living/carbon/alien/user)
	if(user.handcuffed || user.legcuffed)
		to_chat(user, "<span class='warning'>You cannot evolve when you are cuffed!</span>")
		return
	if(islarva(user))
		var/mob/living/carbon/alien/larva/L = user
		if(!(L.amount_grown >= L.max_grown))	//TODO ~Carn //TODO WHAT YOU FUCK ~Fikou
			to_chat(user, "<span class='warning'>You are not fully grown!</span>")
			return 0
	else
		var/obj/item/organ/alien/plasmavessel/vessel = user.getorgan(/obj/item/organ/alien/plasmavessel)
		if(vessel.storedPlasma < vessel.max_plasma)
			to_chat(user, "<span class='warning'>You do not have enough plasma to grow!</span>")
			return 0
	to_chat(user, "<span class='name'>You are growing! It is time to choose a caste.</span>")
	var/evolutions = user.evolution_paths
	var/alien_caste = input(user, "Please choose which alien caste you shall belong to.", "Text") as null|anything in evolutions
	if(user.incapacitated()) //something happened to us while we were choosing.
		return
	var/mob/living/carbon/alien/new_xeno
	if(!alien_caste || !(alien_caste in evolutions))
		return 0
	if(!isturf(user.loc))
		to_chat(user, "<span class='warning'>You can't evolve here!</span>")
		return 0
	switch(alien_caste)
		if("Larva")
			new_xeno = new /mob/living/carbon/alien/larva(user.loc)
		if("Sentinel")
			new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(user.loc)
		if("Drone")
			new_xeno = new /mob/living/carbon/alien/humanoid/drone(user.loc)
		if("Hunter")
			new_xeno = new /mob/living/carbon/alien/humanoid/hunter(user.loc)
		if("Praetorian")
			var/obj/item/organ/alien/hivenode/node = user.getorgan(/obj/item/organ/alien/hivenode)
			if(!node) //Players are Murphy's Law. We may not expect there to ever be a living xeno with no hivenode, but they _WILL_ make it happen.
				to_chat(user, "<span class='danger'>Without the hivemind, you can't possibly hold the responsibility of leadership!</span>")
				return 0
			if(!get_alien_type(/mob/living/carbon/alien/humanoid/royal))
				new_xeno = new /mob/living/carbon/alien/humanoid/royal/praetorian(user.loc)
			else
				to_chat(user, "<span class='warning'>We already have a living royal!</span>")
				return 0
		if("Queen")
			var/obj/item/organ/alien/hivenode/node = user.getorgan(/obj/item/organ/alien/hivenode)
			if(!node) //Just in case this particular Praetorian gets violated and kept by the RD as a replacement for Lamarr.
				to_chat(user, "<span class='warning'>Without the hivemind, you would be unfit to rule as queen!</span>")
				return 0
			if(node.recent_queen_death)
				to_chat(user, "<span class='warning'>You are still too burdened with guilt to evolve into a queen.</span>")
				return 0
			if(!get_alien_type(/mob/living/carbon/alien/humanoid/royal/queen))
				new_xeno = new /mob/living/carbon/alien/humanoid/royal/queen(user.loc)
			else
				to_chat(user, "<span class='warning'>We already have an alive queen!</span>")
				return 0
		else
			to_chat(user, "<span class='warning'>Something went very wrong, you tried to become a xeno type you shouldn't be! Yell at the coders.</span>")
			return 0
	user.alien_evolve(new_xeno)

