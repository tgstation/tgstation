/// This divisor controls how fast body temperature changes to match the environment
#define BODYTEMP_DIVISOR 8

/**
  * Handles all mob updates
  */
/mob/living/proc/life_process()
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(TRUE)

	if(notransform)
		return FALSE

	if((movement_type & FLYING) && !(movement_type & FLOATING))	//TODO: Better floating //todo tivi
		INVOKE_ASYNC(src, /atom/movable.proc/float, TRUE)

	if(!loc)//we check this in ssmob every 5 ticks but lets check regularily too just in case
		return FALSE

	if(!IS_IN_STASIS(src))
		if(stat != DEAD)
			handle_traits() // eye, ear, brain damages
			handle_status_effects() //all special effects, stun, knockdown, jitteryness, hallucination, sleeping, etc
			handle_mutations_and_radiation()

		//Handle temperature/pressure differences between body and environment
		var/datum/gas_mixture/environment = loc.return_air()
		if(environment)
			handle_environment(environment)

		handle_gravity()

	handle_fire()
	if(machine)
		machine.check_eye(src)

	if(stat != DEAD)
		return TRUE
	return FALSE


///handles mutations and radiation, not much to say here
/mob/living/proc/handle_mutations_and_radiation()
	radiation = 0 //so radiation don't accumulate in simple animals
	return

///Base mob environment handler for body temperature
/mob/living/proc/handle_environment(datum/gas_mixture/environment)
	var/loc_temp = get_temperature(environment)

	if(loc_temp < bodytemperature) // it is cold here
		if(!on_fire) // do not reduce body temp when on fire
			adjust_bodytemperature(max((loc_temp - bodytemperature) / BODYTEMP_DIVISOR, BODYTEMP_COOLING_MAX))
	else // this is a hot place
		adjust_bodytemperature(min((loc_temp - bodytemperature) / BODYTEMP_DIVISOR, BODYTEMP_HEATING_MAX))

///Handles the mob being on fire and not being on fire
/mob/living/proc/handle_fire()
	if(fire_stacks < 0) //If we've doused ourselves in water to avoid fire, dry off slowly
		set_fire_stacks(min(0, fire_stacks + 1)) //So we dry ourselves back to default, nonflammable.
	if(!on_fire)
		return TRUE //the mob is no longer on fire, no need to do the rest.
	if(fire_stacks > 0)
		adjust_fire_stacks(-0.1) //the fire is slowly consumed
	else
		extinguish_mob()
		return TRUE //mob was put out, on_fire = FALSE via extinguish_mob(), no need to update everything down the chain.
	var/datum/gas_mixture/G = loc.return_air() // Check if we're standing in an oxygenless environment
	if(!G.gases[/datum/gas/oxygen] || G.gases[/datum/gas/oxygen][MOLES] < 1)
		extinguish_mob() //If there's no oxygen in the tile we're on, put out the fire
		return TRUE
	var/turf/location = get_turf(src)
	location.hotspot_expose(700, 50, 1)

/**
 * Get the fullness of the mob
 *
 * This returns a value form 0 upwards to represent how full the mob is.
 * The value is a total amount of consumable reagents in the body combined
 * with the total amount of nutrition they have.
 * This does not have an upper limit.
 */
/mob/living/proc/get_fullness()
	var/fullness = nutrition
	// we add the nutrition value of what we're currently digesting
	for(var/bile in reagents.reagent_list)
		var/datum/reagent/consumable/bits = bile
		if(bits)
			fullness += bits.nutriment_factor * bits.volume / bits.metabolization_rate
	return fullness

/**
 * Check if the mob contains this reagent.
 *
 * This will validate the the reagent holder for the mob and any sub holders contain the requested reagent.
 * Vars:
 * * reagent (typepath) takes a PATH to a reagent.
 * * amount (int) checks for having a specific amount of that chemical.
 * * needs_metabolizing (bool) takes into consideration if the chemical is matabolizing when it's checked.
 */
/mob/living/proc/has_reagent(reagent, amount = -1, needs_metabolizing = FALSE)
	return reagents.has_reagent(reagent, amount, needs_metabolizing)

/**
 * Removes reagents from the mob
 *
 * This will locate the reagent in the mob and remove it from reagent holders
 * Vars:
 * * reagent (typepath) takes a PATH to a reagent.
 * * custom_amount (int)(optional) checks for having a specific amount of that chemical.
 * * safety (bool) check for the trans_id_to
 */
/mob/living/proc/remove_reagent(reagent, custom_amount, safety)
	if(!custom_amount)
		custom_amount = get_reagent_amount(reagent)
	return reagents.remove_reagent(reagent, custom_amount, safety)

/**
 * Returns the amount of a reagent from the mob
 *
 * This will locate the reagent in the mob and return the total amount from all reagent holders
 * Vars:
 * * reagent (typepath) takes a PATH to a reagent.
 */
/mob/living/proc/get_reagent_amount(reagent)
	return reagents.get_reagent_amount(reagent)

///Handles traits such as blindness, deaf etc etc
/mob/living/proc/handle_traits()
	//Eyes
	if(eye_blind)	//blindness, heals slowly over time
		if(HAS_TRAIT_FROM(src, TRAIT_BLIND, EYES_COVERED)) //covering your eyes heals blurry eyes faster
			adjust_blindness(-3)
		else if(!stat && !(HAS_TRAIT(src, TRAIT_BLIND)))
			adjust_blindness(-1)
	else if(eye_blurry)			//blurry eyes heal slowly
		adjust_blurriness(-1)


///this updates all special effects: knockdown, druggy, stuttering, etc..
/mob/living/proc/handle_status_effects()
	return

/mob/living/proc/handle_gravity()
	var/gravity = mob_has_gravity()
	update_gravity(gravity)

	if(gravity > STANDARD_GRAVITY)
		gravity_animate()
		handle_high_gravity(gravity)

/mob/living/proc/gravity_animate()
	if(!get_filter("gravity"))
		add_filter("gravity",1,list("type"="motion_blur", "x"=0, "y"=0))
	INVOKE_ASYNC(src, .proc/gravity_pulse_animation)

/mob/living/proc/gravity_pulse_animation()
	animate(get_filter("gravity"), y = 1, time = 10)
	sleep(10)
	animate(get_filter("gravity"), y = 0, time = 10)

/mob/living/proc/handle_high_gravity(gravity)
	if(gravity >= GRAVITY_DAMAGE_TRESHOLD) //Aka gravity values of 3 or more
		var/grav_stregth = gravity - GRAVITY_DAMAGE_TRESHOLD
		adjustBruteLoss(min(grav_stregth,3))

#undef BODYTEMP_DIVISOR
