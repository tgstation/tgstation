ADMIN_VERB(spawn_obj_as_mob, R_SPAWN, "Spawn Object-Mob", "Spawn an object as if it were a mob.", ADMIN_CATEGORY_DEBUG, object as text)
	var/chosen = pick_closest_path(object, make_types_fancy(subtypesof(/obj)))

	if (!chosen)
		return

	var/mob/living/basic/mimic/copy/basemob = /mob/living/basic/mimic/copy

	var/obj/chosen_obj = text2path(chosen)

	var/list/settings = list("mainsettings" = list(
		"name" = list(
			"desc" = "Name",
			"type" = "string",
			"value" = "Bob",
		),
		"maxhealth" = list(
			"desc" = "Max. health",
			"type" = "number",
			"value" = 100,
		),
		"access" = list(
			"desc" = "Access ID",
			"type" = "datum",
			"path" = "/obj/item/card/id",
			"value" = "Default",
		),
		"objtype" = list(
			"desc" = "Base obj type",
			"type" = "datum",
			"path" = "/obj",
			"value" = "[chosen]",
		),
		"googlyeyes" = list(
			"desc" = "Googly eyes",
			"type" = "boolean",
			"value" = "No",
		),
		"disableai" = list(
			"desc" = "Disable AI",
			"type" = "boolean",
			"value" = "Yes",
		),
		"idledamage" = list(
			"desc" = "Damaged while idle",
			"type" = "boolean",
			"value" = "No",
		),
		"dropitem" = list(
			"desc" = "Drop obj on death",
			"type" = "boolean",
			"value" = "Yes",
		),
		"mobtype" = list(
			"desc" = "Base mob type",
			"type" = "datum",
			"path" = "/mob/living/basic/mimic/copy",
			"value" = "/mob/living/basic/mimic/copy",
		),
		"ckey" = list(
			"desc" = "ckey",
			"type" = "ckey",
			"value" = "none",
		),
	))

	var/list/pref_return = present_pref_like_picker(user.mob, "Customize mob", "Customize mob", width = 450, timeout = 0, settings = settings)
	if (pref_return["button"] != 1)
		return

	settings = pref_return["settings"]
	var/mainsettings = settings["mainsettings"]
	chosen_obj = text2path(mainsettings["objtype"]["value"])

	basemob = text2path(mainsettings["mobtype"]["value"])
	if (!ispath(basemob, /mob/living/basic/mimic/copy) || !ispath(chosen_obj, /obj))
		to_chat(user.mob, "Mob or object path invalid", confidential = TRUE)

	basemob = new basemob(get_turf(user.mob), new chosen_obj(get_turf(user.mob)), user.mob, mainsettings["dropitem"]["value"] == "Yes" ? FALSE : TRUE, (mainsettings["googlyeyes"]["value"] == "Yes" ? FALSE : TRUE))

	if (mainsettings["disableai"]["value"] == "Yes")
		qdel(basemob.ai_controller)
		basemob.ai_controller = null

	if (mainsettings["idledamage"]["value"] == "No")
		basemob.idledamage = FALSE

	if (mainsettings["access"])
		var/newaccess = text2path(mainsettings["access"]["value"])
		if (ispath(newaccess))
			var/obj/item/card/id/id = new newaccess //cant do initial on lists
			basemob.AddComponent(/datum/component/simple_access, id.access)
			qdel(id)

	if (mainsettings["maxhealth"]["value"])
		if (!isnum(mainsettings["maxhealth"]["value"]))
			mainsettings["maxhealth"]["value"] = text2num(mainsettings["maxhealth"]["value"])
		if (mainsettings["maxhealth"]["value"] > 0)
			basemob.maxHealth = basemob.maxHealth = mainsettings["maxhealth"]["value"]

	if (mainsettings["name"]["value"])
		basemob.name = basemob.real_name = html_decode(mainsettings["name"]["value"])

	if (mainsettings["ckey"]["value"] != "none")
		basemob.ckey = mainsettings["ckey"]["value"]


	log_admin("[key_name(user.mob)] spawned a sentient object-mob [basemob] from [chosen_obj] at [AREACOORD(user.mob)]")
	BLACKBOX_LOG_ADMIN_VERB("Spawn object-mob")
