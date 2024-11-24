/datum/asset/spritesheet/simple/modpacks
	name = "modpacks"

/datum/asset/spritesheet/simple/modpacks/create_spritesheets()
	InsertAll("modpack", 'modular_meta/__modpack/mods_icon_placeholder.dmi')
	// catch all modpack's previews which are pulling icons from another file
	for(var/datum/modpack/this_modpack as anything in subtypesof(/datum/modpack))
		var/icon = initial(this_modpack.icon)
		var/icon_state = initial(this_modpack.id)
		if(icon != 'modular_meta/__modpack/mods_icon_placeholder.dmi' || !this_modpack.visible)
			Insert("modpack-[icon_state]", icon, icon_state=icon_state)
