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
	verb_say = "hisses"
	ventcrawler = 2
	languages = ALIEN
//	var/nightvision = 1


	var/obj/item/weapon/card/id/wear_id = null // Fix for station bounced radios -- Skie
	var/has_fine_manipulation = 0

	var/move_delay_add = 0 // movement delay to add
	type_of_meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/xeno
	gib_type = /obj/effect/decal/cleanable/blood/gibs/xgibs

	status_flags = CANPARALYSE|CANPUSH
	var/heat_protection = 0.5
	var/leaping = 0
	unique_name = 1

/mob/living/carbon/alien/New()
	verbs += /mob/living/proc/mob_sleep
	verbs += /mob/living/proc/lay_down

	//Organsystem created by castes

	..()

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

/mob/living/carbon/alien/handle_environment(var/datum/gas_mixture/environment)

	if(!environment)
		return

	var/loc_temp = get_temperature(environment)

	//world << "Loc temp: [loc_temp] - Body temp: [bodytemperature] - Fireloss: [getFireLoss()] - Fire protection: [heat_protection] - Location: [loc] - src: [src]"

	// Aliens are now weak to fire.

	//After then, it reacts to the surrounding atmosphere based on your thermal protection
	if(!on_fire) // If you're on fire, ignore local air temperature
		if(loc_temp > bodytemperature)
			//Place is hotter than we are
			var/thermal_protection = heat_protection //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(thermal_protection < 1)
				bodytemperature += (1-thermal_protection) * ((loc_temp - bodytemperature) / BODYTEMP_HEAT_DIVISOR)
		else
			bodytemperature += 1 * ((loc_temp - bodytemperature) / BODYTEMP_HEAT_DIVISOR)
		//	bodytemperature -= max((loc_temp - bodytemperature / BODYTEMP_AUTORECOVERY_DIVISOR), BODYTEMP_AUTORECOVERY_MINIMUM)

	// +/- 50 degrees from 310.15K is the 'safe' zone, where no damage is dealt.
	if(bodytemperature > 360.15)
		//Body temperature is too hot.
		throw_alert("alien_fire")
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
		if (1.0)
			gib()
			return

		if (2.0)
			adjustBruteLoss(60)
			adjustFireLoss(60)
			adjustEarDamage(30,120)

		if(3.0)
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

/mob/living/carbon/alien/IsAdvancedToolUser()
	return has_fine_manipulation

/mob/living/carbon/alien/SpeciesCanConsume()
	return 1 // Aliens can eat, and they can be fed food/drink

/mob/living/carbon/alien/Stat()
	..()

	if(statpanel("Status"))
		stat(null, "Intent: [a_intent]")
		stat(null, "Move Mode: [m_intent]")


/mob/living/carbon/alien/Stun(amount)
	if(status_flags & CANSTUN)
		stunned = max(max(stunned,amount),0) //can't go below 0, getting a low amount of stun doesn't lower your current stun
	else
		// add some movement delay
		move_delay_add = min(move_delay_add + round(amount / 2), 10) // a maximum delay of 10
	return

/mob/living/carbon/alien/getTrail()
	return "xltrails"

/mob/living/carbon/alien/cuff_break(obj/item/I, mob/living/carbon/C)
	playsound(C, 'sound/voice/hiss5.ogg', 40, 1, 1)  //Alien roars when breaking free.
	..()

/*----------------------------------------
Proc: AddInfectionImages()
Des: Gives the client of the alien an image on each infected mob.
----------------------------------------*/
/mob/living/carbon/alien/proc/AddInfectionImages()
	if (client)
		for (var/mob/living/C in mob_list)
			if(C.status_flags & XENO_HOST)
				var/obj/item/organ/internal/body_egg/alien_embryo/A = C.get_organ("egg")
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

/mob/living/carbon/alien/get_standard_pixel_y_offset(lying = 0)
	return initial(pixel_y)

/mob/living/carbon/alien/canBeHandcuffed()
	return 1

#undef HEAT_DAMAGE_LEVEL_1
#undef HEAT_DAMAGE_LEVEL_2
#undef HEAT_DAMAGE_LEVEL_3
