/**
 * Creates a mutable appearance with the material color applied for its insertion animation into an autolathe or techfab
 * Arguments
 *
 * * material - the material used to generate the overlay
 */
/proc/material_insertion_animation(datum/material/material)
	RETURN_TYPE(/mutable_appearance)

	var/static/list/mutable_appearance/apps = list()

	var/mutable_appearance/cached_app = apps[material]
	if(isnull(cached_app))
		cached_app = mutable_appearance('icons/obj/machines/research.dmi', "material_insertion")
		cached_app.color = material.color
		cached_app.alpha = material.alpha

		apps[material] = cached_app
	return cached_app
