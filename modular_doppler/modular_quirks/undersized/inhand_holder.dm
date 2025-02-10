//The breathing issue
//this gets called during several points in the breath chain and is responsible for why we can breathe in crates and lockers for example
//But that presents an issue, when this mob is already inside a placeholder item that will be inside ANOTHER item that probably doesn't have a gas mixture var
/obj/item/clothing/head/mob_holder/handle_internal_lifeform(mob/lifeform_inside_me, breath_request)
	if(breath_request>0)
		if(ismob(loc))
			//but we're not done yet, because if we call return_air() without declaring loc.loc as a turf variable, it will try to breathe from the turf using the wrong verison of return_air()
			var/turf/mobs_turf = loc.loc

			var/datum/gas_mixture/environment = mobs_turf.return_air()
			var/breath_percentage = BREATH_VOLUME / environment.return_volume()
			return mobs_turf.remove_air(environment.total_moles() * breath_percentage)

		else
			. = ..()
	else
		return null
