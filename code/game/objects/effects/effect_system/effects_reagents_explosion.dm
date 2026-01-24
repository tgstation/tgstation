

//Reagent-based explosion effect

/datum/effect_system/reagents_explosion
	/// Explosive power
	var/amount
	/// Factor of how powerful the flash effect relatively to the explosion
	var/flashing_factor = null
	/// Factor of how powerful the flame effect is relatively to explosion
	var/flaming_factor = null
	/// Whether we show a message to mobs.
	var/explosion_message = 1

/datum/effect_system/reagents_explosion/New(turf/location, amount, flash_fact = null, flame_fact = null, message = TRUE)
	. = ..()
	src.amount = amount
	explosion_message = message
	if (!isturf(location))
		location = get_turf(location)
	flashing_factor = flash_fact
	flaming_factor = flame_fact

/// Starts the explosion. The explosion_source is as part of logging and identifying the source of the explosion for logs.
/datum/effect_system/reagents_explosion/start(atom/explosion_source = null)
	if(!explosion_source)
		stack_trace("Reagent explosion triggered without a source atom. This explosion may have incomplete logging.")
	if(explosion_message)
		location.visible_message(span_danger("The solution violently explodes!"), span_hear("You hear an explosion!"))
	dyn_explosion(location, amount, flash_range = flashing_factor, flame_range = flaming_factor, explosion_cause = explosion_source)
