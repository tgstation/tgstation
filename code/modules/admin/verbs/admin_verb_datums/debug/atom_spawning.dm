ADMIN_VERB(spawn_atom_as_mob, "Spawn Object-Mob", "Spawn an object path as a mob.", R_SPAWN, VERB_CATEGORY_DEBUG, object_path as text)
	var/chosen = pick_closest_path(object_path, make_types_fancy(subtypesof(/obj)))
	if (!chosen)
		return

	var/mob/living/simple_animal/hostile/mimic/copy/basemob = /mob/living/simple_animal/hostile/mimic/copy

	var/obj/chosen_obj = text2path(chosen)

	var/list/settings = list(
	"mainsettings" = list(
	"name" = list("desc" = "Name", "type" = "string", "value" = "Bob"),
			"maxhealth" = list("desc" = "Max. health", "type" = "number", "value" = 100),
	"access" = list("desc" = "Access ID", "type" = "datum", "path" = "/obj/item/card/id", "value" = "Default"),
			"objtype" = list("desc" = "Base obj type", "type" = "datum", "path" = "/obj", "value" = "[chosen]"),
			"googlyeyes" = list("desc" = "Googly eyes", "type" = "boolean", "value" = "No"),
			"disableai" = list("desc" = "Disable AI", "type" = "boolean", "value" = "Yes"),
			"idledamage" = list("desc" = "Damaged while idle", "type" = "boolean", "value" = "No"),
			"dropitem" = list("desc" = "Drop obj on death", "type" = "boolean", "value" = "Yes"),
			"mobtype" = list("desc" = "Base mob type", "type" = "datum", "path" = "/mob/living/simple_animal/hostile/mimic/copy", "value" = "/mob/living/simple_animal/hostile/mimic/copy"),
			"ckey" = list("desc" = "ckey", "type" = "ckey", "value" = "none"),
	))

	var/list/prefreturn = presentpreflikepicker(user.mob,"Customize mob", "Customize mob", Button1="Ok", width = 450, StealFocus = 1,Timeout = 0, settings=settings)
	if(prefreturn["button"] != 1)
		return

	settings = prefreturn["settings"]
	var/mainsettings = settings["mainsettings"]
	chosen_obj = text2path(mainsettings["objtype"]["value"])

	basemob = text2path(mainsettings["mobtype"]["value"])
	if (!ispath(basemob, /mob/living/simple_animal/hostile/mimic/copy) || !ispath(chosen_obj, /obj))
		to_chat(user, "Mob or object path invalid", confidential = TRUE)

	basemob = new basemob(get_turf(user.mob), new chosen_obj(get_turf(user.mob)), user.mob, mainsettings["dropitem"]["value"] == "Yes" ? FALSE : TRUE, (mainsettings["googlyeyes"]["value"] == "Yes" ? FALSE : TRUE))

	if (mainsettings["disableai"]["value"] == "Yes")
		basemob.toggle_ai(AI_OFF)

	if (mainsettings["idledamage"]["value"] == "No")
		basemob.idledamage = FALSE

	if (mainsettings["access"])
		var/newaccess = text2path(mainsettings["access"]["value"])
		if (ispath(newaccess))
			basemob.access_card = new newaccess

	if (mainsettings["maxhealth"]["value"])
		if (!isnum(mainsettings["maxhealth"]["value"]))
			mainsettings["maxhealth"]["value"] = text2num(mainsettings["maxhealth"]["value"])
		if (mainsettings["maxhealth"]["value"] > 0)
			basemob.maxHealth = basemob.maxHealth = mainsettings["maxhealth"]["value"]

	if (mainsettings["name"]["value"])
		basemob.name = basemob.real_name = html_decode(mainsettings["name"]["value"])

	if (mainsettings["ckey"]["value"] != "none")
		basemob.ckey = mainsettings["ckey"]["value"]

	log_admin("[key_name(user)] spawned a sentient object-mob [basemob] from [chosen_obj] at [AREACOORD(user.mob)]")

ADMIN_VERB(spawn_atom, "Spawn", "Spawn an atom path in world.", R_SPAWN, VERB_CATEGORY_DEBUG, atom_path as text)
	if(isnull(atom_path))
		return

	var/list/preparsed = splittext(atom_path, ":")
	var/path = preparsed[1]
	var/amount = 1
	if(preparsed.len > 1)
		amount = clamp(text2num(preparsed[2]),1,ADMIN_SPAWN_CAP)

	var/chosen = pick_closest_path(path)
	if(!chosen)
		return
	var/turf/spawn_location = get_turf(user.mob)

	if(ispath(chosen, /turf))
		spawn_location.ChangeTurf(chosen)
	else
		for(var/i in 1 to amount)
			var/atom/A = new chosen(spawn_location)
			A.flags_1 |= ADMIN_SPAWNED_1

	log_admin("[key_name(user)] spawned [amount] x [chosen] at [AREACOORD(spawn_location)]")

ADMIN_VERB(spawn_atom_pod, "PodSpawn", "Spawn an atom path in world via supply drop.", R_SPAWN, VERB_CATEGORY_DEBUG, atom_path as text)
	var/chosen = pick_closest_path(atom_path)
	if(!chosen)
		return
	var/turf/target_turf = get_turf(user.mob)

	if(ispath(chosen, /turf))
		target_turf.ChangeTurf(chosen)
	else
		var/obj/structure/closet/supplypod/pod = podspawn(list(
			"target" = target_turf,
			"path" = /obj/structure/closet/supplypod/centcompod,
		))
		//we need to set the admin spawn flag for the spawned items so we do it outside of the podspawn proc
		var/atom/A = new chosen(pod)
		A.flags_1 |= ADMIN_SPAWNED_1

	log_admin("[key_name(user)] pod-spawned [chosen] at [AREACOORD(user.mob)]")

ADMIN_VERB(spawn_cargo, "Spawn Cargo", "Spawn a cargo crate", R_SPAWN, VERB_CATEGORY_DEBUG, crate_path as text)
	var/chosen = pick_closest_path(crate_path, make_types_fancy(subtypesof(/datum/supply_pack)))
	if(!chosen)
		return
	var/datum/supply_pack/S = new chosen
	S.admin_spawned = TRUE
	S.generate(get_turf(user.mob))
	log_admin("[key_name(user.mob)] spawned cargo pack [chosen] at [AREACOORD(user.mob)]")
