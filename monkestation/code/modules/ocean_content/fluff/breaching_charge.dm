/obj/item/mining_charge
	name = "sea floor breaching charge"
	desc = "Mining grade explosives, useful for busting a hole down to the trench."

	icon = 'goon/icons/breaching_charge.dmi'
	icon_state = "bcharge"

	///how long until kaboom
	var/prime_time = 5 SECONDS

	///explosion vars
	var/flash_range = 2
	var/minor_range = 3


/obj/item/mining_charge/proc/set_explosion()
	anchored = TRUE
	icon_state = "bcharge2"
	addtimer(CALLBACK(src, PROC_REF(kaboom)), prime_time)

/obj/item/mining_charge/proc/kaboom()
	var/turf/turf = get_turf(src)
	explosion(turf, 0, 0, minor_range, 0, flash_range, TRUE)
	if(istype(turf, /turf/open/floor/plating/ocean))
		turf.TerraformTurf(/turf/open/floor/plating/ocean/pit, /turf/open/floor/plating/ocean/pit,  flags = CHANGETURF_INHERIT_AIR)
		turf.get_sky_and_weather_states()
		turf.reconsider_sunlight()
		turf.outdoor_effect.Move(turf)
		turf.contents |= turf.outdoor_effect
	qdel(src)
