

/mob/living/carbon/monkey


/mob/living/carbon/monkey/Life()
	set invisibility = 0
	set background = BACKGROUND_ENABLED

	if (notransform)
		return

	if(..())

		if(!client)
			if(stat == CONSCIOUS)
				if(!handle_combat())
					if(prob(33) && canmove && isturf(loc) && !pulledby)
						step(src, pick(GLOB.cardinals))
					if(prob(1))
						emote(pick("scratch","jump","roll","tail"))
			else
				walk_to(src,0)

/mob/living/carbon/monkey/handle_mutations_and_radiation()

	if (radiation)
		if (radiation > 100)
			if(!IsKnockdown())
				emote("collapse")
			Knockdown(200)
			to_chat(src, "<span class='danger'>You feel weak.</span>")

		switch(radiation)

			if(50 to 75)
				if(prob(5))
					if(!IsKnockdown())
						emote("collapse")
					Knockdown(60)
					to_chat(src, "<span class='danger'>You feel weak.</span>")

			if(75 to 100)
				if(prob(1))
					to_chat(src, "<span class='danger'>You mutate!</span>")
					randmutb()
					emote("gasp")
					domutcheck()
		..()

/mob/living/carbon/monkey/handle_breath_temperature(datum/gas_mixture/breath)
	if(abs(310.15 - breath.temperature) > 50)
		switch(breath.temperature)
			if(-INFINITY to 120)
				adjustFireLoss(3)
			if(120 to 200)
				adjustFireLoss(1.5)
			if(200 to 260)
				adjustFireLoss(0.5)
			if(360 to 400)
				adjustFireLoss(2)
			if(400 to 1000)
				adjustFireLoss(3)
			if(1000 to INFINITY)
				adjustFireLoss(8)

/mob/living/carbon/monkey/handle_environment(datum/gas_mixture/environment)
	if(!environment)
		return

	var/loc_temp = get_temperature(environment)

	if(stat != DEAD)
		natural_bodytemperature_stabilization()

	if(!on_fire) //If you're on fire, you do not heat up or cool down based on surrounding gases
		if(loc_temp < bodytemperature)
			bodytemperature += min(((loc_temp - bodytemperature) / BODYTEMP_COLD_DIVISOR), BODYTEMP_COOLING_MAX)
		else
			bodytemperature += min(((loc_temp - bodytemperature) / BODYTEMP_HEAT_DIVISOR), BODYTEMP_HEATING_MAX)

	if(bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT)
		switch(bodytemperature)
			if(360 to 400)
				throw_alert("temp", /obj/screen/alert/hot, 1)
				apply_damage(HEAT_DAMAGE_LEVEL_1, BURN)
			if(400 to 460)
				throw_alert("temp", /obj/screen/alert/hot, 2)
				apply_damage(HEAT_DAMAGE_LEVEL_2, BURN)
			if(460 to INFINITY)
				throw_alert("temp", /obj/screen/alert/hot, 3)
				if(on_fire)
					apply_damage(HEAT_DAMAGE_LEVEL_3, BURN)
				else
					apply_damage(HEAT_DAMAGE_LEVEL_2, BURN)

	else if(bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT)
		if(!istype(loc, /obj/machinery/atmospherics/components/unary/cryo_cell))
			switch(bodytemperature)
				if(200 to 260)
					throw_alert("temp", /obj/screen/alert/cold, 1)
					apply_damage(COLD_DAMAGE_LEVEL_1, BURN)
				if(120 to 200)
					throw_alert("temp", /obj/screen/alert/cold, 2)
					apply_damage(COLD_DAMAGE_LEVEL_2, BURN)
				if(-INFINITY to 120)
					throw_alert("temp", /obj/screen/alert/cold, 3)
					apply_damage(COLD_DAMAGE_LEVEL_3, BURN)
		else
			clear_alert("temp")

	else
		clear_alert("temp")

	//Account for massive pressure differences

	var/pressure = environment.return_pressure()
	var/adjusted_pressure = calculate_affecting_pressure(pressure) //Returns how much pressure actually affects the mob.
	switch(adjusted_pressure)
		if(HAZARD_HIGH_PRESSURE to INFINITY)
			adjustBruteLoss( min( ( (adjusted_pressure / HAZARD_HIGH_PRESSURE) -1 )*PRESSURE_DAMAGE_COEFFICIENT , MAX_HIGH_PRESSURE_DAMAGE) )
			throw_alert("pressure", /obj/screen/alert/highpressure, 2)
		if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
			throw_alert("pressure", /obj/screen/alert/highpressure, 1)
		if(WARNING_LOW_PRESSURE to WARNING_HIGH_PRESSURE)
			clear_alert("pressure")
		if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
			throw_alert("pressure", /obj/screen/alert/lowpressure, 1)
		else
			adjustBruteLoss( LOW_PRESSURE_DAMAGE )
			throw_alert("pressure", /obj/screen/alert/lowpressure, 2)

	return

/mob/living/carbon/monkey/handle_random_events()
	if (prob(1) && prob(2))
		emote("scratch")

/mob/living/carbon/monkey/has_smoke_protection()
	if(wear_mask)
		if(wear_mask.flags_1 & BLOCK_GAS_SMOKE_EFFECT_1)
			return 1

/mob/living/carbon/monkey/handle_fire()
	. = ..()
	if(on_fire)

		//the fire tries to damage the exposed clothes and items
		var/list/burning_items = list()
		//HEAD//
		var/obj/item/clothing/head_clothes = null
		if(wear_mask)
			head_clothes = wear_mask
		if(wear_neck)
			head_clothes = wear_neck
		if(head)
			head_clothes = head
		if(head_clothes)
			burning_items += head_clothes

		if(back)
			burning_items += back

		for(var/X in burning_items)
			var/obj/item/I = X
			if(!(I.resistance_flags & FIRE_PROOF))
				I.take_damage(fire_stacks, BURN, "fire", 0)

		bodytemperature += BODYTEMP_HEATING_MAX

