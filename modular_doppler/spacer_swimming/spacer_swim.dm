// if we're a spacer and have sufficient air pressure on our turf (>50kPa)
// attempt to "space swim" slowly to our salvation tile if all other methods have failed
#define SPACE_SWIM_DELAY_SECONDS 1.5 SECONDS

/mob/living/carbon/human/Process_Spacemove(movement_dir, continuous_move)
	. = ..()
	if (HAS_TRAIT(src, TRAIT_SPACER_SWIM) && movement_dir && isnull(continuous_move))
		var/drifting = !isnull(drift_handler)
		// need to find some way of checking if we're still doing continuous drifting motion
		// can we just check for an active drift_handler? do they delete themselves once finished?
		if (!. && !drifting && !has_gravity() && !incapacitated) // have we failed all previous movement paths and are not on a forced movement pattern?
			var/turf/our_turf = get_turf(src)
			var/turf/destination = get_step(src, movement_dir)
			if (destination.density)
				return FALSE
			var/datum/gas_mixture/environment = our_turf.return_air()
			var/environment_pressure = environment.return_pressure()
			if (environment_pressure >= LAVALAND_EQUIPMENT_EFFECT_PRESSURE)
				if (do_after(src, SPACE_SWIM_DELAY_SECONDS, target = destination, interaction_key = "space_swim", max_interact_count = 1))
					visible_message(span_notice("[src] deftly spacer-swims towards [destination]."), span_notice("You deftly spacer-swim towards [destination]."))
					return TRUE
				else
					return FALSE

/datum/quirk/spacer_born
	mob_trait = TRAIT_SPACER_SWIM

#undef SPACE_SWIM_DELAY_SECONDS
