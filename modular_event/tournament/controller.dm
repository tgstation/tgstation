/// Tournament controllers mapped to arena ID
GLOBAL_LIST_EMPTY(tournament_controllers)

/// Controller for the tournament
/obj/machinery/computer/tournament_controller
	name = "tournament controller"
	desc = "contact mothblocks if you want to learn more"

	/// The arena ID to be looking for
	var/arena_id = ARENA_DEFAULT_ID

	var/list/contestants = list()
	var/list/toolboxes = list()

	var/list/valid_team_spawns = list()

	/// Shutters that separate teams from the arena
	var/list/obj/machinery/door/poddoor/arena_shutters = list()

	/// The places to spawn toolboxes
	var/list/toolbox_spawns = list()

	var/static/list/arena_templates

	var/countdown_started = FALSE
	var/loading = FALSE

/obj/machinery/computer/tournament_controller/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()

	if (arena_id in GLOB.tournament_controllers)
		stack_trace("Tournament controller had arena_id \"[arena_id]\", which is reused!")
		return INITIALIZE_HINT_QDEL

	GLOB.tournament_controllers[arena_id] = src

	if (isnull(arena_templates))
		arena_templates = list()
		INVOKE_ASYNC(src, .proc/load_arena_templates)

/obj/machinery/computer/tournament_controller/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "TournamentController")
		ui.open()

/obj/machinery/computer/tournament_controller/ui_static_data(mob/user)
	return list(
		"arena_templates" = assoc_to_keys(arena_templates),
		"team_names" = assoc_to_keys(GLOB.tournament_teams),
	)

/obj/machinery/computer/tournament_controller/ui_act(action, list/params)
	. = ..()
	if (.)
		return .

	switch (action)
		if ("close_shutters")
			close_shutters()
			return TRUE
		if ("open_shutters")
			open_shutters()
			return TRUE
		if ("start_countdown")
			start_countdown(usr)
			return TRUE
		if ("load_arena")
			load_arena(usr, params["arena_template"])
			return TRUE
		if ("spawn_teams")
			spawn_teams(usr, list(params["team_a"], params["team_b"]))
			return TRUE

/obj/machinery/computer/tournament_controller/ui_state(mob/user)
	return GLOB.admin_state

/obj/machinery/computer/tournament_controller/ui_status(mob/user)
	return GLOB.admin_state.can_use_topic(src, user)

/obj/machinery/computer/tournament_controller/proc/get_landmark_turf(landmark_tag)
	for(var/obj/effect/landmark/arena/arena_landmark in GLOB.landmarks_list)
		if (arena_landmark.arena_id == arena_id && arena_landmark.landmark_tag == landmark_tag && isturf(arena_landmark.loc))
			return arena_landmark.loc

/obj/machinery/computer/tournament_controller/proc/get_load_point()
	var/turf/corner_a = get_landmark_turf(ARENA_CORNER_A)
	var/turf/corner_b = get_landmark_turf(ARENA_CORNER_B)
	return locate(min(corner_a.x, corner_b.x), min(corner_a.y, corner_b.y), corner_a.z)

/obj/machinery/computer/tournament_controller/proc/close_shutters()
	for(var/obj/machinery/door/poddoor/door in arena_shutters)
		INVOKE_ASYNC(door, /obj/machinery/door/poddoor.proc/close)

/obj/machinery/computer/tournament_controller/proc/open_shutters()
	for(var/obj/machinery/door/poddoor/door in arena_shutters)
		INVOKE_ASYNC(door, /obj/machinery/door/poddoor.proc/open)

/obj/machinery/computer/tournament_controller/proc/get_arena_turfs()
	var/load_point = get_load_point()
	var/turf/corner_a = get_landmark_turf(ARENA_CORNER_A)
	var/turf/corner_b = get_landmark_turf(ARENA_CORNER_B)
	var/turf/high_point = locate(max(corner_a.x, corner_b.x),max(corner_a.y, corner_b.y), corner_a.z)
	return block(load_point, high_point)

/obj/machinery/computer/tournament_controller/proc/load_arena_templates()
	var/arena_dir = "_maps/toolbox_arenas/"
	var/list/default_arenas = flist(arena_dir)
	for(var/arena_file in default_arenas)
		var/simple_name = replacetext(replacetext(arena_file, arena_dir, ""), ".dmm", "")
		var/datum/map_template/map_template = new("[arena_dir]/[arena_file]", simple_name)
		arena_templates[simple_name] = map_template

/obj/machinery/computer/tournament_controller/proc/load_arena(mob/user, arena_template_name)
	if (loading)
		to_chat(user, span_warning("An arena is already loading."))
		return

	var/datum/map_template/template = arena_templates[arena_template_name]
	if(!template)
		to_chat(user, span_warning("The arena \"[arena_template_name]\" does not exist."))
		return

	clear_arena()
	close_shutters()

	var/turf/corner_a = get_landmark_turf(ARENA_CORNER_A)
	var/turf/corner_b = get_landmark_turf(ARENA_CORNER_B)
	var/width = abs(corner_a.x - corner_b.x) + 1
	var/height = abs(corner_a.y - corner_b.y) + 1
	if(template.width > width || template.height > height)
		to_chat(user, span_warning("Arena template is too big for the current arena!"))
		return

	loading = TRUE
	var/bounds = template.load(get_load_point())
	loading = FALSE

	if (!bounds)
		to_chat(user, span_warning("Something went wrong while loading the map."))
		return

	message_admins("[key_name_admin(user)] loaded [arena_template_name] event arena for [arena_id] arena.")
	log_admin("[key_name(user)] loaded [arena_template_name] event arena for [arena_id] arena.")

/obj/machinery/computer/tournament_controller/proc/clear_arena()
	for (var/turf/arena_turf in get_arena_turfs())
		arena_turf.empty(turf_type = /turf/open/floor/plating)

	QDEL_LIST(contestants)
	QDEL_LIST(toolboxes)

/obj/machinery/computer/tournament_controller/proc/spawn_teams(mob/user, list/team_names)
	var/index = 1

	for (var/team_name in team_names)
		var/datum/tournament_team/team = GLOB.tournament_teams[team_name]
		if (!istype(team))
			to_chat(user, span_warning("Couldn't find team: [team_name]"))
			return

		var/team_spawn_id = valid_team_spawns[index]

		var/list/clients = team.get_clients()

		for (var/client/client as anything in clients)
			var/old_mob = client?.mob
			var/mob/living/carbon/human/contestant_mob = new

			client?.prefs?.apply_prefs_to(contestant_mob)
			contestant_mob.equipOutfit(team.outfit)
			// MOTHBLOCKS TODO: Spawn in the setup room beforehand?
			contestant_mob.forceMove(pick(valid_team_spawns[team_spawn_id]))
			contestant_mob.key = client?.key
			contestant_mob.reset_perspective()

			qdel(old_mob)

			contestants += contestant_mob

		spawn_toolboxes(team.toolbox_color, team_spawn_id, clients.len)

		index += 1

	var/message = "loaded [team_names.len] teams ([team_names.Join(", ")]) for [arena_id] arena."
	message_admins("[key_name_admin(user)] [message]")
	log_admin("[key_name(user)] [message]")

/obj/machinery/computer/tournament_controller/proc/spawn_toolboxes(toolbox_color, team_spawn_id, number_to_spawn)
	var/list/spawns = toolbox_spawns[team_spawn_id]
	spawns = spawns.Copy()

	for (var/_ in 1 to number_to_spawn)
		var/obj/spawn_landmark = pick_n_take(spawns)

		var/obj/item/storage/toolbox/toolbox = new
		toolbox.color = toolbox_color
		toolbox.forceMove(get_turf(spawn_landmark))

		toolboxes += toolbox
