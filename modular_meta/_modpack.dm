/datum/modpack
	/// A string unique ID for the modpack. Used for self-cheсks, must be same as modpack name in code. /datum/modpack/ru_crayons -> "id = ru_crayons"
	var/id
	/// An icon for modpack preview,
	var/icon = 'modular_meta/mods_icon_placeholder.dmi'
	/// A string name for the modpack. Used for looking up other modpacks in init.
	var/name
	/// A string desc for the modpack. Can be used for modpack verb list as description.
	var/desc
	/// A string with authors of this modpack.
	var/author
	/// A string with group of this modpack. Choose between "Features", "Translations" and "Reverts"
	var/group
	/// A list of your modpack's dependencies. If you use obj from another modpack - put it here.
	var/list/mod_depends = list()


// Modpacks initialization steps
/datum/modpack/proc/pre_initialize() // Basic modpack fuctions
	if(!name)
		return "Modpack name is unset."

/datum/modpack/proc/initialize() // Mods dependencies-checks
	if(!mod_depends)
		return
	var/passed = 0
	for(var/depend_id in mod_depends)
		passed = 0
		if(depend_id == id)
			return "Mod depends on itself, ok and?"
		for(var/datum/modpack/package as anything in SSmodpacks.loaded_modpacks)
			if(package.id == depend_id)
				if(passed >= 1)
					return "Multiple include of one module in [id] mod dependencies."
				passed++
		if(passed == 0)
			return "Module [id] depends on [depend_id], please include it in your game."

// Modpacks TGUI
/datum/modpack/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/simple/modpacks),
	)

/datum/modpack/ui_state()
	return GLOB.always_state

/datum/modpack/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Modpacks")
		ui.open()

/datum/modpack/ui_static_data(mob/user)
	. = ..()
	.["categories"] = list("Features", "Translations", "Reverts")
	.["features"] = list()
	.["translations"] = list()
	.["reverts"] = list()
	
	var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/simple/modpacks)
	for(var/datum/modpack/modpack as anything in SSmodpacks.loaded_modpacks)
		var/list/modpack_data = list(
			"name" = modpack.name,
			"desc" = modpack.desc,
			"author" = modpack.author,
			"id" = modpack.id,
			)
		if(modpack.icon != "modular_meta/mods_icon_placeholder.dmi")
			modpack_data += list ("icon_class" = assets.icon_class_name("modpack-[modpack.id]"))
		else
			modpack_data += list ("icon_class" = assets.icon_class_name("modpack-default"))

		if (modpack.group == "Фичи" || modpack.group == "Features")
			.["features"] += list(modpack_data)
		else if (modpack.group == "Переводы" || modpack.group == "Translations")
			.["translations"] += list(modpack_data)
		else if (modpack.group == "Баланс" || modpack.group == "Reverts")
			.["reverts"] += list(modpack_data)
		else
			CRASH("Modpack [modpack.name] has bad group name or queued for deletion.")
