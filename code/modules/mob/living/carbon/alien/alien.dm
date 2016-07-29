<<<<<<< HEAD
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
	languages_spoken = ALIEN
	languages_understood = ALIEN
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

	var/static/regex/alien_name_regex = new("alien (larva|sentinel|drone|hunter|praetorian|queen)( \\(\\d+\\))?")

/mob/living/carbon/alien/New()
	verbs += /mob/living/proc/mob_sleep
	verbs += /mob/living/proc/lay_down

	internal_organs += new /obj/item/organ/brain/alien
	internal_organs += new /obj/item/organ/alien/hivenode
	internal_organs += new /obj/item/organ/tongue/alien

	for(var/obj/item/organ/I in internal_organs)
		I.Insert(src)

	AddAbility(new/obj/effect/proc_holder/alien/nightvisiontoggle(null))
	..()

/mob/living/carbon/alien/assess_threat() // beepsky won't hunt aliums
	return -10

/mob/living/carbon/alien/adjustToxLoss(amount)
	return 0

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
				var/obj/item/organ/body_egg/alien_embryo/A = C.getorgan(/obj/item/organ/body_egg/alien_embryo)
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
	new_xeno.setDir(dir)
	if(!alien_name_regex.Find(name))
		new_xeno.name = name
		new_xeno.real_name = real_name
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

	for(var/obj/item/organ/cyberimp/eyes/E in internal_organs)
		sight |= E.sight_flags
		if(E.dark_view)
			see_in_dark = max(see_in_dark, E.dark_view)
		if(E.see_invisible)
			see_invisible = min(see_invisible, E.see_invisible)

	if(see_override)
		see_invisible = see_override

/mob/living/carbon/alien/can_hold_items()
	return has_fine_manipulation
=======
#define HEAT_DAMAGE_LEVEL_1 2 //Amount of damage applied when your body temperature just passes the 360.15k safety point
#define HEAT_DAMAGE_LEVEL_2 4 //Amount of damage applied when your body temperature passes the 400K point
#define HEAT_DAMAGE_LEVEL_3 8 //Amount of damage applied when your body temperature passes the 460K point and you are on fire

/mob/living/carbon/alien
	name = "alien" //The alien, not Alien
	voice_name = "alien"
	//speak_emote = list("hisses")
	icon = 'icons/mob/alien.dmi'
	gender = NEUTER
	dna = null

	mob_bump_flag = ALIEN
	mob_swap_flags = ALLMOBS
	mob_push_flags = ALLMOBS ^ ROBOT

	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat

	var/storedPlasma = 250
	var/max_plasma = 500
	var/neurotoxin_cooldown = 0

	var/obj/item/weapon/card/id/wear_id = null // Fix for station bounced radios -- Skie
	var/has_fine_manipulation = 0

	var/move_delay_add = 0 // movement delay to add

	status_flags = CANPARALYSE|CANPUSH
	var/heal_rate = 2.5
	var/plasma_rate = 5

	var/oxygen_alert = 0
	var/toxins_alert = 0
	var/fire_alert = 0

	var/heat_protection = 0.5

/mob/living/carbon/alien/adjustToxLoss(amount)
	storedPlasma = min(max(storedPlasma + amount,0),max_plasma) //upper limit of max_plasma, lower limit of 0
	updatePlasmaHUD()
	return

/mob/living/carbon/alien/proc/updatePlasmaHUD()
	if(hud_used)
		if(!hud_used.vampire_blood_display)
			hud_used.plasma_hud()
			//hud_used.human_hud(hud_used.ui_style)
		hud_used.vampire_blood_display.maptext_width = 64
		hud_used.vampire_blood_display.maptext_height = 32
		hud_used.vampire_blood_display.maptext = "<div align='left' valign='top' style='position:relative; top:0px; left:6px'> P:<font color='#E9DAE9' size='1'>[storedPlasma]</font><br>  / <font color='#BE7DBE' size='1'>[max_plasma]</font></div>"
	return

/*
/mob/living/carbon/alien/adjustFireLoss(amount) // Weak to Fire
	if(amount > 0)
		..(amount * 2)
	else
		..(amount)
	return
*/
//No longer weak to fire

/mob/living/carbon/alien/proc/getPlasma()
	return storedPlasma

/mob/living/carbon/alien/eyecheck()
	return 2

/mob/living/carbon/alien/earprot()
	return 1

// MULEBOT SMASH
/mob/living/carbon/alien/Crossed(var/atom/movable/AM)
	var/obj/machinery/bot/mulebot/MB = AM
	if(istype(MB))
		MB.RunOverCreature(src,"#00ff00")
		var/obj/effect/decal/cleanable/blood/xeno/X = getFromPool(/obj/effect/decal/cleanable/blood/xeno, src.loc) //new /obj/effect/decal/cleanable/blood/xeno(src.loc)
		X.New(src.loc)

/mob/living/carbon/alien/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
	else
		//oxyloss is only used for suicide
		//toxloss isn't used for aliens, its actually used as alien powers!!
		health = maxHealth - getOxyLoss() - getFireLoss() - getBruteLoss() - getCloneLoss()

/mob/living/carbon/alien/proc/handle_environment(var/datum/gas_mixture/environment)


	//If there are alien weeds on the ground then heal if needed or give some toxins
	if(locate(/obj/effect/alien/weeds) in loc)
		if(health < maxHealth - getCloneLoss())
			adjustBruteLoss(-heal_rate)
			adjustFireLoss(-heal_rate)
			adjustOxyLoss(-heal_rate)
		adjustToxLoss(plasma_rate)

	if(!environment || (flags & INVULNERABLE))
		return
	var/loc_temp = T0C
	if(istype(loc, /obj/mecha))
		var/obj/mecha/M = loc
		loc_temp =  M.return_temperature()
	else if(istype(get_turf(src), /turf/space))
		var/turf/heat_turf = get_turf(src)
		loc_temp = heat_turf.temperature
	else if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
		loc_temp = loc:air_contents.temperature
	else
		loc_temp = environment.temperature

//	to_chat(world, "Loc temp: [loc_temp] - Body temp: [bodytemperature] - Fireloss: [getFireLoss()] - Fire protection: [heat_protection] - Location: [loc] - src: [src]")

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
		fire_alert = max(fire_alert, 1)
		switch(bodytemperature)
			if(360 to 400)
				apply_damage(HEAT_DAMAGE_LEVEL_1, BURN)
				fire_alert = max(fire_alert, 2)
			if(400 to 460)
				apply_damage(HEAT_DAMAGE_LEVEL_2, BURN)
				fire_alert = max(fire_alert, 2)
			if(460 to INFINITY)
				if(on_fire)
					apply_damage(HEAT_DAMAGE_LEVEL_3, BURN)
					fire_alert = max(fire_alert, 2)
				else
					apply_damage(HEAT_DAMAGE_LEVEL_2, BURN)
					fire_alert = max(fire_alert, 2)
	return

/mob/living/carbon/alien/proc/handle_mutations_and_radiation()


	if(getFireLoss())
		if((M_RESIST_HEAT in mutations) || prob(5))
			adjustFireLoss(-1)

	// Aliens love radiation nom nom nom
	if (radiation)
		if (radiation > 100)
			radiation = 100

		if (radiation < 0)
			radiation = 0

		switch(radiation)
			if(1 to 49)
				radiation--
				if(prob(25))
					adjustToxLoss(1)

			if(50 to 74)
				radiation -= 2
				adjustToxLoss(1)
				if(prob(5))
					radiation -= 5

			if(75 to 100)
				radiation -= 3
				adjustToxLoss(3)

/mob/living/carbon/alien/handle_fire()//Aliens on fire code
	if(..())
		return
	bodytemperature += BODYTEMP_HEATING_MAX //If you're on fire, you heat up!
	return

/mob/living/carbon/alien/IsAdvancedToolUser()
	return has_fine_manipulation

/mob/living/carbon/alien/Process_Spaceslipping()
	return 0 // Don't slip in space.

/mob/living/carbon/alien/Stat()

	if(statpanel("Status"))
		stat(null, "Intent: [a_intent]")
		stat(null, "Move Mode: [m_intent]")

	..()

	if(statpanel("Status"))
		stat(null, "Plasma Stored: [getPlasma()]/[max_plasma]")

		if(emergency_shuttle)
			if(emergency_shuttle.online && emergency_shuttle.location < 2)
				var/timeleft = emergency_shuttle.timeleft()
				if (timeleft)
					stat(null, "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")

/mob/living/carbon/alien/Stun(amount)
	if(status_flags & CANSTUN)
		stunned = max(max(stunned,amount),0) //can't go below 0, getting a low amount of stun doesn't lower your current stun
	else
		// add some movement delay
		move_delay_add = min(move_delay_add + round(amount / 2), 10) // a maximum delay of 10
	return

/mob/living/carbon/alien/getDNA()
	return null

/mob/living/carbon/alien/setDNA()
	return

//This proc is NOT useless, we make it so that aliens have an halved siemens_coeff. Which means they take half damage
//I will personally find the retard who made all these VARIABLES into FUCKING CONSTANTS. THE FUCKING SOURCE AND THE SHOCK DAMAGE, CONSTANTS ? YOU THINK ?
/mob/living/carbon/alien/electrocute_act(const/shock_damage, const/obj/source, const/siemens_coeff = 1)

	var/damage = shock_damage * siemens_coeff

	if(damage <= 0)
		damage = 0

	if(take_overall_damage(0, damage, "[source]") == 0) // godmode
		return 0

	//src.burn_skin(shock_damage)
	//src.adjustFireLoss(shock_damage) //burn_skin will do this for us
	//src.updatehealth()

	visible_message( \
		"<span class='warning'>[src] was shocked by the [source]!</span>", \
		"<span class='danger'>You feel a powerful shock course through your body!</span>", \
		"<span class='warning'>You hear a heavy electrical crack.</span>", \
		"<span class='notice'>[src] starts raving!</span>", \
		"<span class='notice'>You feel butterflies in your stomach!</span>", \
		"<span class='warning'>You hear a policeman whistling!</span>"
	)

	//if(src.stunned < shock_damage)	src.stunned = shock_damage

	Stun(10) // this should work for now, more is really silly and makes you lay there forever

	//if(src.weakened < 20*siemens_coeff)	src.weakened = 20*siemens_coeff

	Weaken(10)

	var/datum/effect/effect/system/spark_spread/SparkSpread = new
	SparkSpread.set_up(5, 1, loc)
	SparkSpread.start()

	return damage/2 //Fuck this I'm not reworking your abortion of a proc, here's a copy-paste with not fucked code

/*----------------------------------------
Proc: AddInfectionImages()
Des: Gives the client of the alien an image on each infected mob.
----------------------------------------*/
/mob/living/carbon/alien/proc/AddInfectionImages()
	if (client)
		for (var/mob/living/C in mob_list)
			if(C.status_flags & XENO_HOST)
				var/obj/item/alien_embryo/A = locate() in C
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
				//del(I)
				client.images -= I
	return

/mob/living/carbon/alien/has_eyes()
	return 0

#undef HEAT_DAMAGE_LEVEL_1
#undef HEAT_DAMAGE_LEVEL_2
#undef HEAT_DAMAGE_LEVEL_3
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
