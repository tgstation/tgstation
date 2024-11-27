#define MODPACKS_SET 'modular_meta/__modpack/mods_icon_placeholder.dmi'

/datum/asset/spritesheet/simple/modpacks
	name = "modpacks"

/datum/asset/spritesheet/simple/modpacks/create_spritesheets()
	InsertAll("modpack", MODPACKS_SET)
	// catch all modpack's previews which are pulling icons from preview.dmi files
	var/icon_placeholder = "default"
	for(var/datum/modpack/this_modpack as anything in subtypesof(/datum/modpack))
		if(!this_modpack.visible)
			continue
		
		var/icon = initial(this_modpack.icon)
		var/icon_state = initial(this_modpack.id)
		if(icon == MODPACKS_SET)
			Insert("modpack-[icon_state]", icon, icon_state=icon_placeholder)
		else
			Insert("modpack-[icon_state]", icon, icon_state=icon_state)

#undef MODPACKS_SET
