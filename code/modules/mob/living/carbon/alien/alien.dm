#define HEAT_DAMAGE_LEVEL_1 2 //Amount of damage applied when your body temperature just passes the 360.15k safety point
#define HEAT_DAMAGE_LEVEL_2 3 //Amount of damage applied when your body temperature passes the 400K point
#define HEAT_DAMAGE_LEVEL_3 8 //Amount of damage applied when your body temperature passes the 460K point and you are on fire

/mob/living/carbon/alien
	name = "alien"
	voice_name = "alien"
	icon = 'icons/mob/alien.dmi'
	gender = NEUTER
	dna = null
	faction = list("alien")
	ventcrawler = 2
	languages = ALIEN
	sight = SEE_MOBS
	see_in_dark = 4
	verb_say = "hisses"
	bubble_icon = "alien"
	type_of_meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/xeno
	var/nightvision = 1

	var/obj/item/weapon/card/id/wear_id = null // Fix for station bounced radios -- Skie
	var/has_fine_manipulation = 0
	var/move_delay_add = 0 // movement delay to add

	status_flags = CANPARALYSE|CANPUSH

	var/heat_protection = 0.5
	var/leaping = 0
	gib_type = /obj/effect/decal/cleanable/xenoblood/xgibs
	unique_name = 1

/mob/living/carbon/alien/New()
	verbs += /mob/living/proc/mob_sleep
	verbs += /mob/living/proc/lay_down

	internal_organs += new /obj/item/organ/internal/brain/alien
	internal_organs += new /obj/item/organ/internal/alien/hivenode
	internal_organs += new /obj/item/organ/internal/tongue/alien

	for(var/obj/item/organ/internal/I in internal_organs)
		I.Insert(src)

	AddAbility(new/obj/effect/proc_holder/alien/nightvisiontoggle(null))
	..()

/mob/living/carbon/alien/assess_threat() // beepsky won't hunt aliums
	return -10

/mob/living/carbon/alien/adjustToxLoss(amount)
	return

/mob/living/carbon/alien/adjustFireLoss(amount) // Weak to Fire
	if(amount > 0)
		..(amount * 2)
	else
		..(amount)
	return

/mob/living/carbon/alien/check_eye_prot()
	return ..() + 2

/mob/living/carbon/alien/getToxLoss()
	return 0

/mob/living/carbon/alien/handle_environment(datum/gas_mixture/environment)
	if(!environment)
		return

	var/loc_temp = get_temperature(environment)

	// Aliens are now weak to fire.

	//After then, it reacts to the surrounding atmosphere based on your thermal protection
	if(!on_fire) // If you're on fire, ignore local air temperature
		if(loc_temp > bodytemperature)
			//Place is hotter than we are
			var/thermal_protection = heat_protection //This returns a 0 - 1 value, which corresponds to the percentage of heat protection.
			if(thermal_protection < 1)
				bodytemperature += (1-thermal_protection) * ((loc_temp - bodytemperature) / BODYTEMP_HEAT_DIVISOR)
		else
			bodytemperature += 1 * ((loc_temp - bodytemperature) / BODYTEMP_HEAT_DIVISOR)

	if(bodytemperature > 360.15)
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


/mob/living/carbon/alien/ex_act(severity, target)
	..()

	switch (severity)
		if (1)
			gib()
			return

		if (2)
			adjustBruteLoss(60)
			adjustFireLoss(60)
			adjustEarDamage(30,120)

		if(3)
			adjustBruteLoss(30)
			if (prob(50))
				Paralyse(1)
			adjustEarDamage(15,60)

	updatehealth()


/mob/living/carbon/alien/handle_fire()//Aliens on fire code
	if(..())
		return
	bodytemperature += BODYTEMP_HEATING_MAX //If you're on fire, you heat up!
	return

/mob/living/carbon/alien/reagent_check(datum/reagent/R) //can metabolize all reagents
	return 0

/mob/living/carbon/alien/IsAdvancedToolUser()
	return has_fine_manipulation

/mob/living/carbon/alien/Stat()
	..()

	if(statpanel("Status"))
		stat(null, "Intent: [a_intent]")

/mob/living/carbon/alien/Stun(amount)
	if(status_flags & CANSTUN)
		stunned = max(max(stunned,amount),0) //can't go below 0, getting a low amount of stun doesn't lower your current stun
	else
		// add some movement delay
		move_delay_add = min(move_delay_add + round(amount / 2), 10) // a maximum delay of 10
	return

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
		for (var/mob/living/C in mob_list)
			if(C.status_flags & XENO_HOST)
				var/obj/item/organ/internal/body_egg/alien_embryo/A = C.getorgan(/obj/item/organ/internal/body_egg/alien_embryo)
				if(A)
					var/I = image('icons/mob/alien.dmi', loc = C, icon_state = "infected[A.stage]")
					client.images += I
	return


/*----------------------------------------
Proc: RemoveInfectionImages()
Des: Removes all infected images from the alien.
----------------------------------------*/
/mob/living/carbon/alien/proc/RemoveInfectionImages()
	if (client)
		for(var/image/I in client.images)
			if(dd_hasprefix_case(I.icon_state, "infected"))
				qdel(I)
	return

/mob/living/carbon/alien/canBeHandcuffed()
	return 1

/mob/living/carbon/alien/get_standard_pixel_y_offset(lying = 0)
	return initial(pixel_y)

/mob/living/carbon/alien/proc/alien_evolve(mob/living/carbon/alien/new_xeno)
	src << "<span class='noticealien'>You begin to evolve!</span>"
	visible_message("<span class='alertalien'>[src] begins to twist and contort!</span>")
	if(mind)
		mind.transfer_to(new_xeno)
	qdel(src)

#undef HEAT_DAMAGE_LEVEL_1
#undef HEAT_DAMAGE_LEVEL_2
#undef HEAT_DAMAGE_LEVEL_3


/mob/living/carbon/alien/update_sight()
	if(!client)
		return
	if(stat == DEAD)
		sight |= SEE_TURFS
		sight |= SEE_MOBS
		sight |= SEE_OBJS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_OBSERVER
		return

	sight = SEE_MOBS
	if(nightvision)
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_MINIMUM
	else
		see_in_dark = 4
		see_invisible = SEE_INVISIBLE_LIVING

	if(client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src)) //returns 1 if we override all other sight updates.
			return

	for(var/obj/item/organ/internal/cyberimp/eyes/E in internal_organs)
		sight |= E.sight_flags
		if(E.dark_view)
			see_in_dark = max(see_in_dark, E.dark_view)
		if(E.see_invisible)
			see_invisible = min(see_invisible, E.see_invisible)

	if(see_override)
		see_invisible = see_override

