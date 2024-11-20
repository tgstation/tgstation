#define MODPACKS_SET 'modular_meta/mods_icon_placeholder.dmi'

/datum/asset/spritesheet/simple/modpacks
	name = "modpacks"

/datum/asset/spritesheet/simple/modpacks/create_spritesheets()
	InsertAll("modpack", MODPACKS_SET) // default image
	// catch all modpack's previews
	for(var/datum/modpack/this_modpack as anything in subtypesof(/datum/modpack))
		var/icon = initial(this_modpack.icon)
		if (icon != MODPACKS_SET)
			var/icon_state = initial(this_modpack.id)
			Insert("modpack-[icon_state]", icon, icon_state=icon_state)

#undef MODPACKS_SET
