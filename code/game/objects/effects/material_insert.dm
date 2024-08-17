/**
 * Creates a mutable appearance with the material color applied for its insertion animation into an autolathe or techfab
 * Arguments
 *
 * * color - the material color that will be applied
 */
/proc/material_insertion_animation(color)
	RETURN_TYPE(/mutable_appearance)

	var/static/list/mutable_appearance/apps = list()

	var/mutable_appearance/cached_app = apps[color]
	if(isnull(cached_app))
		var/icon/modified_icon = icon('icons/obj/machines/research.dmi', "material_insertion")

		//assuming most of the icon is white we find what ratio to scale the intensity of each part roughly
		var/list/rgb_list = rgb2num(color)
		modified_icon.SetIntensity(rgb_list[1] / 255, rgb_list[2] / 255, rgb_list[3] / 255)
		cached_app = mutable_appearance(modified_icon, "material_insertion")

		apps[color] = cached_app
	return cached_app
