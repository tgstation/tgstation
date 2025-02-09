/obj/item/clothing/head/mob_holder

	//this gets called during several points in the breath chain and is responsible for why we can breathe in crates and lockers for example
	//But that presents an issue, when this mob is already inside a placeholder item that will be inside ANOTHER item that probably doesn't have a gas mixture var
	handle_internal_lifeform(mob/lifeform_inside_me, breath_request)
		if(breath_request>0)
			var/datum/gas_mixture/environment = loc.return_air() //Code is entirely the same except for this silly double loc thing to get the turf
			var/breath_percentage = BREATH_VOLUME / environment.return_volume()
			return remove_air(environment.total_moles() * breath_percentage)
		else
			return null
