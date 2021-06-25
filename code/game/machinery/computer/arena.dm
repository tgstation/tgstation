#define ARENA_DEFAULT_ID "arena_default"
#define ARENA_CORNER_A "cornerA"
#define ARENA_CORNER_B "cornerB"

/// Main page of the arena computer UI
#define ARENA_UI_MAIN "main"
/// The page of the arena computer UI for generating teams and handling matches
#define ARENA_UI_MATCH "match"
/// The page of the arena computer UI for managing teams
#define ARENA_UI_TEAMS "team"
/// The page of the arena computer UI for managing contestants
#define ARENA_UI_INDIV "contestant"
/// The page of the arena computer UI for managing the arena
#define ARENA_UI_ARENA "arena"

/// Arena related landmarks
/obj/effect/landmark/arena
	name = "arena landmark"
	var/landmark_tag
	var/arena_id = ARENA_DEFAULT_ID

/obj/effect/landmark/arena/start
	name = "arena corner A"
	landmark_tag = ARENA_CORNER_A

/obj/effect/landmark/arena/end
	name = "arena corner B"
	landmark_tag = ARENA_CORNER_B

/// Controller for admin event arenas
/obj/machinery/computer/arena
	name = "arena controller"
	use_power = FALSE
	/// Arena ID
	var/arena_id = ARENA_DEFAULT_ID
	/// Enables/disables spawning
	var/ready_to_spawn = FALSE
	/// Assoc list of map templates indexed by user friendly names
	var/static/list/arena_templates = list()
	/// Were the config directory arenas loaded
	var/static/default_arenas_loaded = FALSE
	/// Name of currently loaded template
	var/current_arena_template = "None"
	// What turf arena clears to
	var/empty_turf_type = /turf/open/indestructible

	/// List of ckeys indexed by team id
	var/list/team_keys = list()
	/// List of outfit datums/types indexed by team id, can be empty
	var/list/outfits = list()
	/// Default team outfit if `outfits[team]` is empty
	var/default_outfit = /datum/outfit/job/assistant

	/// Is the arena template loading in
	var/loading = FALSE

	//How long between admin pressing start and doors opening
	var/start_delay = 30 SECONDS
	//Value for the countdown
	var/start_time
	var/list/countdowns = list() //List of countdown effects ticking down to start

	//Sound played when the fight starts.
	var/start_sound = 'sound/items/airhorn2.ogg'
	var/start_sound_volume = 50
	/// What page of the arena UI we're on
	var/ui_mode = ARENA_UI_MAIN

/obj/machinery/computer/arena/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	LoadDefaultArenas()

/**
 * Loads the arenas from config directory.
 * THESE ARE FULLY CACHED FOR QUICK SWITCHING SO KEEP TRACK OF THE AMOUNT
 */
/obj/machinery/computer/arena/proc/LoadDefaultArenas()
	if(default_arenas_loaded)
		return
	var/arena_dir = "[global.config.directory]/arenas/"
	var/list/default_arenas = flist(arena_dir)
	for(var/arena_file in default_arenas)
		var/simple_name = replacetext(replacetext(arena_file,arena_dir,""),".dmm","")
		INVOKE_ASYNC(src, .proc/add_new_arena_template, null, arena_dir + arena_file, simple_name)

/obj/machinery/computer/arena/proc/get_landmark_turf(landmark_tag)
	for(var/obj/effect/landmark/arena/L in GLOB.landmarks_list)
		if(L.arena_id == arena_id && L.landmark_tag == landmark_tag && isturf(L.loc))
			return L.loc

/obj/machinery/computer/arena/proc/get_load_point()
	var/turf/A = get_landmark_turf(ARENA_CORNER_A)
	var/turf/B = get_landmark_turf(ARENA_CORNER_B)
	return locate(min(A.x,B.x),min(A.y,B.y),A.z)

/obj/machinery/computer/arena/proc/get_arena_turfs()
	var/lp = get_load_point()
	var/turf/A = get_landmark_turf(ARENA_CORNER_A)
	var/turf/B = get_landmark_turf(ARENA_CORNER_B)
	var/turf/hp = locate(max(A.x,B.x),max(A.y,B.y),A.z)
	return block(lp,hp)

//todo: make sure this actually gets any leftovers from things inside other things that got deleted
/obj/machinery/computer/arena/proc/clear_arena()
	for(var/turf/T in get_arena_turfs())
		T.empty(turf_type = /turf/open/indestructible)
	var/list/clear_turfs = get_arena_turfs()
	for(var/obj/iter_object in clear_turfs)
		//if(!istype()) // whatever we want to allow?
		qdel(iter_object)
	for(var/mob/living/iter_mob in clear_turfs)
		qdel(iter_mob)
	current_arena_template = "None"

/obj/machinery/computer/arena/proc/load_arena(arena_template,mob/user)
	if(loading)
		return
	var/datum/map_template/M = arena_templates[arena_template]
	if(!M)
		to_chat(user,span_warning("No such arena"))
		return
	clear_arena() //Clear current arena
	var/turf/A = get_landmark_turf(ARENA_CORNER_A)
	var/turf/B = get_landmark_turf(ARENA_CORNER_B)
	var/wh = abs(A.x - B.x) + 1
	var/hz = abs(A.y - B.y) + 1
	if(M.width > wh || M.height > hz)
		to_chat(user,span_warning("Arena template is too big for the current arena!"))
		return
	loading = TRUE
	var/bd = M.load(get_load_point())
	if(bd)
		current_arena_template = arena_template
	loading = FALSE

	message_admins("[key_name_admin(user)] loaded [arena_template] event arena for [arena_id] arena.")
	log_admin("[key_name(user)] loaded [arena_template] event arena for [arena_id] arena.")

	var/datum/roster/the_roster = GLOB.global_roster
	the_roster.spawns_team1 = null
	the_roster.spawns_team2 = null
	the_roster.spawns_br = null

	for(var/obj/machinery/arena_spawn/iter_spawn in GLOB.machines)
		if(iter_spawn.arena_id != arena_id)
			continue
		if(istype(iter_spawn, /obj/machinery/arena_spawn/battle_royale))
			LAZYADD(the_roster.spawns_br, iter_spawn)
		else if(iter_spawn.team == ARENA_RED_TEAM)
			LAZYADD(the_roster.spawns_team1, iter_spawn)
		else if(iter_spawn.team == ARENA_GREEN_TEAM)
			LAZYADD(the_roster.spawns_team2, iter_spawn)

	message_admins("[LAZYLEN(the_roster.spawns_br)] spawns for BR, [LAZYLEN(the_roster.spawns_team1)] spawns for team 1, [LAZYLEN(the_roster.spawns_team2)] spawns for team 2.")
	log_admin("[LAZYLEN(the_roster.spawns_br)] spawns for BR, [LAZYLEN(the_roster.spawns_team1)] spawns for team 1, [LAZYLEN(the_roster.spawns_team2)] spawns for team 2.")

/obj/machinery/computer/arena/proc/add_new_arena_template(user,fname,friendly_name)
	if(!fname)
		fname = input(user, "Upload dmm file to use as arena template","Upload Map Template") as null|file
	if(!fname)
		return
	if(!friendly_name)
		friendly_name = "[fname]" //Could ask the user for friendly name here

	var/datum/map_template/T = new(fname,friendly_name,TRUE)
	if(!T.cached_map)
		to_chat(user,"Map doesn't even exist, broh.")
		return
	var/datum/map_report/broken_map = T.cached_map.check_for_errors()

	if(broken_map)
		to_chat(user,"Map failed to parse check for errors.")
		var/mob/the_user = user
		broken_map.show_to(the_user.client)
		return

	arena_templates[T.name] = T
	message_admins("[key_name_admin(user)] uploaded new event arena: [friendly_name].")
	log_admin("[key_name(user)] uploaded new event arena: [friendly_name].")

/obj/machinery/computer/arena/proc/load_team(user,team)
	var/rawteam = stripped_multiline_input(user,"Enter team list (ckeys separated by newline)")
	for(var/i in splittext(rawteam,"\n"))
		var/key = ckey(i)
		if(!i)
			continue
		add_team_member(user,team,key)

/obj/machinery/computer/arena/proc/add_team_member(mob/user,team,key)
	if(!key)
		var/list/keys = list()
		for(var/mob/M in GLOB.player_list)
			keys += M.client
		var/client/selection = input("Please, select a player!", "Team member", null, null) as null|anything in sortKey(keys)
		//Could be freeform if you want to add disconnected i guess
		if(!selection)
			return
		key = selection.ckey
	if(!team_keys[team])
		team_keys[team] = list(key)
	else
		team_keys[team] |= key
	to_chat(user,"[key] added to [team] team.")

/obj/machinery/computer/arena/proc/remove_member(mob/user,ckey,team)
	team_keys[team] -= ckey
	to_chat(user,"[ckey] removed from [team] team.")

/obj/machinery/computer/arena/proc/spawn_member(obj/machinery/arena_spawn/spawnpoint,ckey,team)
	var/mob/oldbody = get_mob_by_key(ckey)
	if(!isobserver(oldbody))
		return
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(get_turf(spawnpoint))
	oldbody.client.prefs.copy_to(M)
	M.set_species(/datum/species/human) // Could use setting per team
	M.equipOutfit(outfits[team] ? outfits[team] : default_outfit)
	M.faction += team //In case anyone wants to add team based stuff to arena special effects
	M.key = ckey

/obj/machinery/computer/arena/proc/change_outfit(mob/user,team)
	outfits[team] = user.client.robust_dress_shop()

/obj/machinery/computer/arena/proc/toggle_spawn(mob/user)
	ready_to_spawn = !ready_to_spawn
	to_chat(user,"You [ready_to_spawn ? "enable" : "disable"] the spawners.")
	log_admin("[key_name(user)] toggled event arena spawning for [arena_id] arena.")
	// Could use update_appearance on spawnpoints here to show they're on
	if(ready_to_spawn)
		for(var/mob/M in all_contestants())
			to_chat(M,span_userdanger("Arena you're signed up for is ready!"))

/obj/machinery/computer/arena/proc/all_contestants()
	. = list()
	for(var/team in team_keys)
		for(var/key in team_keys[team])
			var/mob/M = get_mob_by_key(key)
			if(M)
				. += M

/obj/machinery/computer/arena/proc/reset_arena()
	clear_arena()
	set_doors(closed = TRUE)

/obj/machinery/computer/arena/proc/get_spawn(team)
	for(var/obj/machinery/arena_spawn/A in GLOB.machines)
		if(A.arena_id == arena_id && A.team == team)
			return A


/obj/machinery/computer/arena/proc/set_doors(closed = FALSE)
	for(var/obj/machinery/door/poddoor/D in GLOB.machines) //I really dislike pathing of these
		if(D.id != arena_id)
			continue
		if(closed)
			INVOKE_ASYNC(D, /obj/machinery/door/poddoor.proc/close)
		else
			INVOKE_ASYNC(D, /obj/machinery/door/poddoor.proc/open)

/obj/machinery/computer/arena/Topic(href, href_list)
	if(..())
		return
	var/mob/user = usr

	if(!user.client.holder) // Should it require specific perm ?
		return

	if(href_list["see_roster"])
		testing("see roster [user]")
		user.client.debug_variables(GLOB.global_roster)

	if(href_list["change_page"])
		switch(href_list["change_page"])
			if("main")
				ui_mode = ARENA_UI_MAIN
			if("match")
				ui_mode = ARENA_UI_MATCH
			if("team")
				ui_mode = ARENA_UI_TEAMS
			if("contestant")
				ui_mode = ARENA_UI_INDIV
			if("arena")
				ui_mode = ARENA_UI_ARENA

	if(href_list["add_empty"])
		if(href_list["add_empty"] == "contestant")
			GLOB.global_roster.add_empty_contestant(usr)
		else if(href_list["add_empty"] == "team")
			GLOB.global_roster.create_team(usr)

	if(href_list["toggle_wounds"])
		GLOB.global_roster.toggle_wounds(usr)

	if(href_list["remove_ckey_at_large"])
		testing("[usr] trying to remove [href_list["remove_ckey_at_large"]]")
		GLOB.global_roster.remove_ckey_at_large(usr, href_list["remove_ckey_at_large"])

	if(href_list["eliminate_contestant"])
		GLOB.global_roster.eliminate_contestant(usr, href_list["eliminate_contestant"])

	if(href_list["unmark_contestant"])
		GLOB.global_roster.unmark_contestant(usr, href_list["unmark_contestant"])

	if(href_list["delete_contestant"])
		GLOB.global_roster.delete_contestant(usr, href_list["delete_contestant"])

	if(href_list["add_specific_contestant"])
		GLOB.global_roster.add_specific_contestant(usr)

	if(href_list["reset_roster"])
		GLOB.global_roster.reset_roster(usr)

	if(href_list["load_roster"])
		GLOB.global_roster.load_contestants_from_file(usr, "sample_roster.json")

	if(href_list["setup_match"])
		GLOB.global_roster.try_setup_match(usr)

	if(href_list["resolve_match"])
		GLOB.global_roster.try_resolve_match(usr)

	if(href_list["set_freeze_all"])
		GLOB.global_roster.set_frozen_all(usr, href_list["set_freeze_all"])

	if(href_list["set_freeze"])
		var/freeze_arg = href_list["set_freeze"]
		var/datum/event_team/try_team = locate(freeze_arg) in GLOB.global_roster.active_teams
		if(istype(try_team)) // team
			try_team.set_frozen(usr, !try_team.frozen)
		else
			var/datum/contestant/try_contestant = locate(freeze_arg) in GLOB.global_roster.all_contestants
			if(istype(try_contestant)) // contestant (not currently used)
				try_contestant.set_frozen(usr, !try_contestant.frozen)

	if(href_list["set_godmode_all"])
		GLOB.global_roster.set_godmode_all(usr, href_list["set_godmode_all"])

	if(href_list["set_godmode"])
		var/godmode_arg = href_list["set_godmode"]
		var/datum/event_team/try_team = locate(godmode_arg) in GLOB.global_roster.active_teams
		if(istype(try_team)) // team
			try_team.set_godmode(usr, !try_team.godmode)
		else
			var/datum/contestant/try_contestant = locate(godmode_arg) in GLOB.global_roster.all_contestants
			if(istype(try_contestant)) // contestant (not currently used)
				try_contestant.set_godmode(usr, !try_contestant.godmode)

	if(href_list["spawn_team"])
		var/datum/event_team/check_team = locate(href_list["spawn_team"]) in GLOB.global_roster.active_teams

		if(istype(check_team))
			GLOB.global_roster.spawn_team(usr, check_team)
		else
			GLOB.global_roster.spawn_team(usr)

	//if(href_list["despawn_all"])
		//GLOB.global_roster.despawn_everyone(usr)

	if(href_list["select_team_slot"])
		GLOB.global_roster.try_load_team_slot(usr, text2num(href_list["select_team_slot"]))

	if(href_list["remove_team_slot"])
		GLOB.global_roster.try_remove_team_slot(usr, text2num(href_list["remove_team_slot"]))

	if(href_list["clear_teams"])
		GLOB.global_roster.clear_teams(usr)

	if(href_list["confirm_elim_team"])
		var/datum/event_team/elim_team = locate(href_list["confirm_elim_team"]) in GLOB.global_roster.active_teams
		if(!istype(elim_team) || !LAZYLEN(elim_team.members))
			testing("failed to find team")
			return
		GLOB.global_roster.eliminate_team(usr, elim_team)

	if(href_list["unmark_team"])
		var/datum/event_team/unmark_team = locate(href_list["unmark_team"]) in GLOB.global_roster.active_teams
		if(!istype(unmark_team) || !LAZYLEN(unmark_team.members))
			testing("failed to find team")
			return
		unmark_team.match_result(TRUE)

	if(href_list["unteam_member"] && href_list["unteam_team_target"])
		var/datum/event_team/unteam_team = locate(href_list["unteam_team_target"]) in GLOB.global_roster.active_teams
		if(!istype(unteam_team) || !LAZYLEN(unteam_team.members))
			testing("failed to find team")
			return
		var/datum/contestant/unteam_member = locate(href_list["unteam_member"]) in unteam_team.members
		if(!istype(unteam_member))
			testing("failed to find team member")
			return
		unteam_team.remove_member(unteam_member)

	if(href_list["query_add_member"])
		var/datum/event_team/target_team = locate(href_list["query_add_member"]) in GLOB.global_roster.active_teams
		if(!istype(target_team))
			testing("failed to find team")
			return
		target_team.query_add_member(usr)

	if(href_list["upload"])
		add_new_arena_template(user)
	if(href_list["change_arena"])
		load_arena(href_list["change_arena"],user)
	if(href_list["special"])
		switch(href_list["special"])
			if("reset")
				reset_arena()
			//Just example in case you want to add more
			if("randomarena")
				load_random_arena(user)
			if("spawntrophy")
				trophy_for_last_man_standing(user)
	if(href_list["member_action"])
		var/ckey = href_list["ckey"]
		var/team = href_list["team"]
		switch(href_list["member_action"])
			if("remove")
				remove_member(user,ckey,team)
	updateUsrDialog()

// Special functions

/obj/machinery/computer/arena/proc/load_random_arena(mob/user)
	if(!length(arena_templates))
		to_chat(user,span_warning("No arenas present"))
		return
	var/picked = pick(arena_templates)
	load_arena(picked,user)

/obj/machinery/computer/arena/proc/trophy_for_last_man_standing()
	var/arena_turfs = get_arena_turfs()
	for(var/mob/living/L in GLOB.mob_living_list)
		if(L.stat != DEAD && (get_turf(L) in arena_turfs))
			var/obj/item/reagent_containers/food/drinks/trophy/gold_cup/G = new(get_turf(L))
			G.name = "[L.real_name]'s Trophy"

/obj/machinery/computer/arena/ui_interact(mob/user)
	. = ..()
	var/list/dat = list()
	/*dat += "<div>Spawning is currently [ready_to_spawn ? "<span class='good'>enabled</span>" : "<span class='bad'>disabled</span>"] <a href='?src=[REF(src)];toggle_spawn=1'>Toggle</a></div>"
	dat += "<div><a href='?src=[REF(src)];start=1'>[start_time ? "Stop countdown" : "Start!"]</a></div>"
	*/
	dat += "<a href='?src=[REF(src)];see_roster=1'>See Roster</a>"
	if(ui_mode != ARENA_UI_MAIN)
		dat += "<a href='?src=[REF(src)];change_page=main'><b>\<\<Back to Main</b></a>"



	switch(ui_mode)
		if(ARENA_UI_MAIN)
			dat += "<b>Main menu</b>"
			dat += "-----------------------------------------"
			dat += "<a href='?src=[REF(src)];add_empty=contestant'>Add Empty Contestant</a>"
			dat += "<a href='?src=[REF(src)];add_empty=team'>Add Empty Team</a>"
			dat += "Random Wounds are currently: <a href='?src=[REF(src)];toggle_wounds=1'><b>[GLOB.global_roster.enable_random_wounds ? "<span class='green'>ENABLED" : "<span class='red'>DISABLED"]</span></b></a>"
			dat += "-----------------------------------------"
			dat += "<a href='?src=[REF(src)];change_page=match'>Go to Match</a>"
			dat += "<a href='?src=[REF(src)];change_page=team'>Go to Teams</a>"
			dat += "<a href='?src=[REF(src)];change_page=contestant'>Go to Contestant List</a>"

			dat += "<br>-----------------------------------------"
			dat += "\t<a href='?src=[REF(src)];set_freeze_all=on'>FREEZE EVERYONE</a> <a href='?src=[REF(src)];set_freeze_all=off'>UNFREEZE EVERYONE</a>"
			dat += "\t<a href='?src=[REF(src)];set_godmode_all=on'>GODMODE EVERYONE</a> <a href='?src=[REF(src)];set_godmode_all=off'>UNGODMODE EVERYONE</a>"

		if(ARENA_UI_MATCH)
			dat += "<b>Match menu</b>"
			dat += "-----------------------------------------"
			dat += "<a href='?src=[REF(src)];change_page=arena'>Manage Arena</a>"
			//dat += "<a href='?src=[REF(src)];setup_match=1'>Setup Next Match</a>"
			dat += "-----------------------------------------"
			dat += "<a href='?src=[REF(src)];change_page=team'>Go to Teams</a>"
			dat += "<a href='?src=[REF(src)];setup_match=1'>Setup Next Match</a>"

			var/datum/event_team/team1 = GLOB.global_roster.team1
			var/datum/event_team/team2 = GLOB.global_roster.team2
			dat += ""

			if(team1)
				dat += "\tTeam 1 ([team1.rostered_id]): <a href='?src=[REF(src)];remove_team_slot=1'>Remove [team1]</a> <a href='?src=[REF(src)];spawn_team=[REF(team1)]'>Spawn Team (RED)</a>"
				dat += "\t\t<a href='?src=[REF(src)];set_freeze=[REF(team1)]'><b>[team1.frozen ? "Unfreeze" : "Freeze"]</span></b></a> <a href='?src=[REF(src)];set_godmode=[REF(team1)]'><b>[team1.godmode ? "Disable Godmode" : "Enable Godmode"]</span></b></a>"
				var/i = 0
				for(var/datum/contestant/iter_member in team1.members)
					i++
					var/mob/the_guy = iter_member.get_mob()
					dat += "\t\tMember #[i]: [iter_member] ([the_guy]) <a href='?src=[REF(src)];unteam_member=[REF(iter_member)];unteam_team_target=[REF(team1)]'>Remove Member</a>"
			else
				dat += "<a href='?src=[REF(src)];select_team_slot=1'>Select Team 1</a>"

			if(team1 && team2) // since it can be busy with both teams there
				dat += "--------"

			if(team2)
				dat += "\tTeam 2 ([team2.rostered_id]): <a href='?src=[REF(src)];remove_team_slot=2'>Remove [team2] <a href='?src=[REF(src)];spawn_team=[REF(team2)]'>Spawn Team (GREEN)</a>"
				dat += "\t\t<a href='?src=[REF(src)];set_freeze=[REF(team2)]'><b>[team2.frozen ? "Unfreeze" : "Freeze"]</span></b></a> <a href='?src=[REF(src)];set_godmode=[REF(team2)]'><b>[team2.godmode ? "Disable Godmode" : "Enable Godmode"]</span></b></a>"
				var/i = 0
				for(var/datum/contestant/iter_member in team2.members)
					i++
					var/mob/the_guy = iter_member.get_mob()
					dat += "\t\tMember #[i]: [iter_member] ([the_guy]) <a href='?src=[REF(src)];unteam_member=[REF(iter_member)];unteam_team_target=[REF(team2)]'>Remove Member</a>"
			else
				dat += "<a href='?src=[REF(src)];select_team_slot=2'>Select Team 2</a>"

			if(istype(team1) ||istype(team2))
				//dat += "<a href='?src=[REF(src)];set_freeze_all=on'><b>Freeze All</b></a><a href='?src=[REF(src)];set_freeze_all=off'><b>Unfreeze All</b></a>"
				//dat += "<a href='?src=[REF(src)];set_godmode_all=on'><b>Godmode All</b></a><a href='?src=[REF(src)];set_godmode_all=off'><b>Ungodmode All</b></a>"
				dat += "<a href='?src=[REF(src)];spawn_team=1'><b>Spawn Teams</b></a><a href='?src=[REF(src)];despawn_all=1'><b>Unspawn Everyone</b></a>"

			if(istype(team1) && istype(team2))
				dat += "<a href='?src=[REF(src)];start_match=1'><b>Start Match</b></a>"
				dat += "<a href='?src=[REF(src)];resolve_match=1'><b>Resolve Match</b></a>"


			var/list/waiting_teams = list()
			var/list/finished_teams = list()
			var/list/marked_teams = list()

			for(var/datum/event_team/iter_team in GLOB.global_roster.unrostered_teams)
				if(iter_team.finished_round)
					if(iter_team.flagged_for_elimination)
						marked_teams += iter_team
					else
						finished_teams += iter_team
				else
					waiting_teams += iter_team

			if(length(waiting_teams))
				dat += "<br><b>Waiting Teams:</b>"
				for(var/datum/event_team/iter_team in waiting_teams)
					dat += "\tTeam [iter_team.rostered_id]: <a href='?src=[REF(src)];change_page=team;[iter_team]'>[iter_team]</a>"

			if(length(finished_teams))
				dat += "<br><b>Proven Teams:</b>"
				for(var/datum/event_team/iter_team in finished_teams)
					dat += "\tTeam [iter_team.rostered_id]: <a href='?src=[REF(src)];change_page=team;[iter_team]'>[iter_team]</a>"

			if(length(marked_teams))
				dat += "<br><b>Marked Teams:</b>"
				for(var/datum/event_team/iter_team in marked_teams)
					dat += "\tTeam [iter_team.rostered_id]: <a href='?src=[REF(src)];change_page=team;[iter_team]'>[iter_team]</a> <a href='?src=[REF(src)];confirm_elim_team=[REF(iter_team)]'>Confirm Elimination</a> <a href='?src=[REF(src)];unmark_team=[REF(iter_team)]'>Unmark</a>"

		if(ARENA_UI_TEAMS)
			dat += "<b>Team menu</b>"
			dat += "-----------------------------------------"
			if(LAZYLEN(GLOB.global_roster.active_teams))
				dat += "<a href='?src=[REF(src)];clear_teams=1'>Clear existing teams</a><br>"

			for(var/datum/event_team/iter_team in GLOB.global_roster.active_teams)
				dat += "\tTeam [iter_team.rostered_id]:"
				dat += "\t\t<a href='?src=[REF(src)];query_add_member=[REF(iter_team)]'>Add Member!</a>"
				var/i = 0
				for(var/datum/contestant/iter_contestant in iter_team.members)
					i++
					var/mob/the_guy = iter_contestant.get_mob()
					dat += "\t\tMember #[i]: [iter_contestant] ([the_guy]) <a href='?src=[REF(src)];unteam_member=[REF(iter_contestant)];unteam_team_target=[REF(iter_team)]'>Remove Member</a>"

		if(ARENA_UI_INDIV)
			dat += "<b>Contestant menu</b>"
			dat += "-----------------------------------------"
			dat += "<a href='?src=[REF(src)];load_roster=1'>Load Roster</a>"
			dat += "<a href='?src=[REF(src)];add_specific_contestant=1'>Add Contestant</a>"
			dat += "<a href='?src=[REF(src)];reset_roster=1'><b>Reset Roster</b></a>"
			dat += "<b>Contestants:</b>"

			var/list/flagged_contestants = list()
			var/list/still_in = null
			if(GLOB.global_roster.active_contestants)
				still_in = GLOB.global_roster.active_contestants - GLOB.global_roster.losers

			for(var/datum/contestant/iter_contestant in still_in)
				if(iter_contestant.flagged_for_elimination)
					flagged_contestants += iter_contestant
					continue

				var/mob/the_guy = iter_contestant.get_mob()
				dat += "\t[iter_contestant.ckey] ([the_guy]) <a href='?src=[REF(src)];eliminate_contestant=[REF(iter_contestant)]'>Eliminate</a> <a href='?src=[REF(src)];delete_contestant=[REF(iter_contestant)]'>Delete</a>"

			if(length(flagged_contestants))
				dat += "<br><b>Contestants Flagged for Elimination:"
				for(var/datum/contestant/flagged_contestant in flagged_contestants)
					var/mob/the_guy = flagged_contestant.get_mob()
					dat += "\t[flagged_contestant.ckey] ([the_guy]) <a href='?src=[REF(src)];eliminate_contestant=[REF(flagged_contestant)]'>Confirm Elimination</a> <a href='?src=[REF(src)];unmark_contestant=[REF(flagged_contestant)]'>Unmark</a>"

			if(LAZYLEN(GLOB.global_roster.losers))
				dat += "<br><b><span class='danger'>Eliminated Contestants</span></b>:"
				for(var/datum/contestant/iter_loser in GLOB.global_roster.losers)
					var/mob/the_guy = iter_loser.get_mob()
					dat += "\t[iter_loser.ckey] ([the_guy]) (Eliminated) <a href='?src=[REF(src)];delete_contestant=[REF(iter_loser)]'>Delete</a>"

			if(LAZYLEN(GLOB.global_roster.ckeys_at_large))
				dat += "<br><b><span class='danger'>Ckeys at Large</span></b>:"
				for(var/iter_ckey in GLOB.global_roster.ckeys_at_large)
					dat += "\t[iter_ckey] <a href='?src=[REF(src)];remove_ckey_at_large=[iter_ckey]'>Delete</a>"

		if(ARENA_UI_ARENA)
			dat += "<b>Arena menu</b>"
			dat += "<a href='?src=[REF(src)];change_page=match'>\<Back to Match</a>"
			dat += "-----------------------------------------"
			dat += "Current arena: [current_arena_template]"
			dat += "<h2>Arena List:</h2>"
			for(var/A in arena_templates)
				dat += "<a href='?src=[REF(src)];change_arena=[url_encode(A)]'>[A]</a><br>"
			dat += "<hr>"
			dat += "<a href='?src=[REF(src)];upload=1'>Upload new arena</a><br>"
			dat += "<hr>"
			//Special actions
			dat += "<a href='?src=[REF(src)];special=reset'>Reset Arena.</a><br>"
			dat += "<a href='?src=[REF(src)];special=randomarena'>Load random arena.</a><br>"

	var/datum/browser/popup = new(user, "arena controller", "Arena Controller", 500, 600)
	popup.set_content(dat.Join("<br>"))
	popup.open()
	/*
	for(var/team in teams)
		dat += "<h2>[capitalize(team)] team:</h2>"
		dat += "<ul>"
		for(var/ckey in team_keys[team])
			var/player_status = "Not Present"
			var/mob/M = get_mob_by_key(ckey)
			if(M)
				//Should define waiting room upper/lower corner and check if they're there instead of generic live/dead check
				if(isobserver(M))
					player_status = "Ghosted"
				else
					player_status = M.stat == DEAD ? "Dead" : "Alive"
				dat += "<li>[ckey] - [player_status] - "
				dat += "<a href='?_src_=holder;[HrefToken(TRUE)];adminplayerobservefollow=[REF(M)]'>FLW</a>"
				dat += "<a href='?src=[REF(src)];member_action=remove;team=[team];ckey=[ckey]'>Remove</a>"
				//Add more per player features here
				dat += "</li>"
		dat += "</ul>"
		dat += "<div> Team Outfit : [outfits[team] ? outfits[team] : default_outfit]</div>"
		dat += "<a href='?src=[REF(src)];team_action=loadteam;team=[team]'>Load team</a>"
		dat += "<a href='?src=[REF(src)];team_action=addmember;team=[team]'>Add member</a>"
		dat += "<a href='?src=[REF(src)];team_action=outfit;team=[team]'>Change Outfit</a>"
		//Add more per team features here


	dat += "<a href='?src=[REF(src)];special=spawntrophy'>Spawn trophies for survivors.</a><br>"

	var/datum/browser/popup = new(user, "arena controller", "Arena Controller", 500, 600)
	popup.set_content(dat.Join())
	popup.open()
	*/

/// Arena spawnpoint
/obj/machinery/arena_spawn
	name = "Arena Spawnpoint"
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"
	resistance_flags = INDESTRUCTIBLE
	/// In case we have multiple arena controllers at once.
	var/arena_id = ARENA_DEFAULT_ID
	/// Team ID
	var/team = "default"
	/// only exist to cut down on glob.machines lookups, do not modify
	var/obj/machinery/computer/arena/_controller

/obj/machinery/arena_spawn/red
	name = "Red Team Spawnpoint"
	color = "red"
	team = ARENA_RED_TEAM

/obj/machinery/arena_spawn/green
	name = "Green Team Spawnpoint"
	color = "green"
	team = ARENA_GREEN_TEAM

/obj/machinery/arena_spawn/battle_royale
	name = "Battle Royale Spawnpoint"
	color = "green"
	team = ARENA_GREEN_TEAM

/obj/machinery/arena_spawn/proc/get_controller()
	if(_controller && !QDELETED(_controller) && _controller.arena_id == arena_id)
		return _controller
	for(var/obj/machinery/computer/arena/A in GLOB.machines)
		if(A.arena_id == arena_id)
			_controller = A
			return _controller

/obj/machinery/arena_spawn/attack_ghost(mob/user)
	var/obj/machinery/computer/arena/C = get_controller()
	if(!C) //Unlinked spawn
		return
	if(C.ready_to_spawn)
		var/list/allowed_keys = C.team_keys[team]
		if(!(user.ckey in allowed_keys))
			to_chat(user,span_warning("You're not on the team list."))
			return
		C.spawn_member(src,user.ckey,team)

//#undef ARENA_GREEN_TEAM
//#undef ARENA_RED_TEAM
#undef ARENA_DEFAULT_ID
#undef ARENA_CORNER_A
#undef ARENA_CORNER_B

/obj/item/paper/courtcase
	name = "paper- 'COURT CASE BRIEFING, PLEASE READ''"
	info = "<h1>GROUND RULES:<br>Red Team: Plantiff, Green Team: Defendent. Accused: Jorge Groen</h1><ol><li>Both sides will be given time to speak. The opposing side should be silent unless objecting against the other side.</li><li>Repeated objections of little relevance or dubious nature will be met with warnings from the judge.</li><li>If found in contempt of court, the offending person will eventually be turned into bread and eliminated from the tournament.</li><li>Contestants are encouraged to keep their statements in character. Repeated out of character remarks will result into being turned into bread.</li><li>Teams will be given 5 minutes to read over the relevant material below. Afterwards, each team will be given a cap of 5 minutes to present their opening statements, witness examination, and closing statements with brief pauses inbetween. The defense will start first and it will rotate to the plantiff.</li></ol><h1>Case Summary</h1><p><br><b>Accusation</b><br><br> Jorge Groen, hereby refered to as “the defendent”, stands accused of triple homicide of the 1st degree as written in the laws of Nanotrasen and employee policy. Per employee policy, the defendent is due a fair trial from a licensed Nanotrasen judge and a jury of their peers. Please note that due to limitations, all current jurors are plushies. <br><br><b>Background</b><br><br> The defendant is a Class A. CRD (Certified Research Director) with a long resume of various topics within the field of managing Nanotrasen ships in hazardous environments, managing advanced electrical grids, and operating life-form scanning devices. The defendent, on the day of the murder, was assigned to Class B, codenamed “Dleks”, while on low orbit nearby a lava planet. The defendent was one of 10 nanotrasen certified research and engineering specialists assigned with ensuring the integrity of the Class B ship. Upon being brought to the ship and given their daily assignments, the defendent was joined by various crewmates upon first being tasked with ensuring the integrity of the shields of the ship. The defendent was joined by three seperate figures upon making their way to their assigned duties including: <ol><li>Dr. Forrest Green</li><li>Dr. Katty Amarillo (Currently Deceased)</li><li>Chief Engineer Susan Smith (Currently Deceased)</li><li>Josef Blau (Missing)</li><li>###REDACTED###</li></ol><br><b>Witness</b><br><br>Dr. Forrest Green, hereby refered to as Forest per request of the witness, joins us today as one of the witnesses for said story and is the primary recollection of the events about to unfold, which took place outside of nanotrasen camera control. Forrest notes that, due to the nature of working with high voltage shields, they are required to wear full body suits that do not show their faces and they are unable to speak while wearing the suits. During their time with the defendent, they note that the defendent was the first to end the room along with Forrest, Dr. Katty Amarilla, and Josef Blau following behind last. Forrest also noted that only one individual appeared to be doing work for the time period that they were there, that being Susan Smith. After the affirmentioned work on the shield was done, Forrest stated that the ship lost power soon after the shields were brought up to defend the ship against asteroids in low orbit. Unable to see her contemporaries for very long, Forrest noted that she saw Chief Engineer Susan Smith and Dr. Katty Amarillo walk down the hallway on the starboard side of the ship with the defendent and notes that this was the last time that she saw Dr. Katty Amarillo before her body was discovered in cargo bay maintenance by ###REDACTED###. Forrest swiftly made their way to engineering while noting that Josef Blau went a different direction after all parties departed ways. After some time working on the ship’s wiring, Susan Smith was able to restore power to the ship to resume working on the shields.<br><br><b>Murder</b><br><br>During this time, Forrest was informed by ###REDACTED### that they should resume their duties on the other side of the ship. While moving through the Starboard side of the ship, Forrest noted an odd banging noise going through the ship and a “stillness in the air” from after returning from rewiring the ship. Forrest noted that she saw ###REDACTED### swiftly leave after said banging and she resumed her duties while noting that the defendent was strangely already back at configuring the ship’s shields at extreme speed. She noted that the distance that the defendent would not have been able to easily get from engineering all the way to the ships shields without some other means. It was at that moment that Forrest returned that she was informed by ###REDACTED### that a murder had taken place and Dr. Katty’s body was found on the southern part of the ship. Immediately a meeting was taken place per company policy where, upon starting the meeting, Susan Smith’s body was found to be discovered as well within the medical wing of the ship. <br>During saidDuring said meeting, all operations were stalled and the crew was brought to a pressurized room where they were able to speak freely to one another. Forrest noted that Josef Blau was the first to speak noting that they were unable to ascertain the whereabouts of the defendent during the time of the murder and accuses them of tampering with the ship’s airflow and ventilation systems to kill Dr. Katty in order to get ahead in their career. Additionally, Josef Blau refered to the defendent as “sus” [SIC] or also known as an improper spelling of suspicious on account of their lack of talking throughout the entire endavour. Per company policy, the defendent was scheduled by a popular vote to be thrown out of the ship until ###REDACTED### interfered with company policy and brought the ship to a halt due to the sensitive nature of the endavour. As such, the court case was organized and brought to order to give the defendent a fair trial. <br><br><b>Please make your case for your respective side.<br></b></p>"
