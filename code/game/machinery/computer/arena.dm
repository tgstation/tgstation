#define ARENA_RED_TEAM "red"
#define ARENA_GREEN_TEAM "green"
#define ARENA_DEFAULT_ID "arena_default"

/obj/effect/landmark/arena
	name = "arena landmark"
	var/landmark_tag
	var/arena_id = ARENA_DEFAULT_ID

/obj/effect/landmark/arena/start
	name = "arena lower left corner"
	landmark_tag = "arena_start"

/obj/effect/landmark/arena/end
	name = "arena upper right corner"
	landmark_tag = "arena_end"

/obj/machinery/computer/arena
	name = "arena controller"
	var/arena_id = ARENA_DEFAULT_ID
	var/ready_to_spawn = FALSE //Enables/disables spawning
	var/list/arena_templates = list()
	var/current_arena_template = "None"
	var/empty_turf_type = /turf/open/indestructible //What turf arena resets to.
	var/list/teams = list(ARENA_RED_TEAM,ARENA_GREEN_TEAM)

	var/list/team_keys = list() // team_keys["red"] = list(ckey1,ckey2,ckey3)
	var/list/outfits = list() // outfits["red"] = outfit datum/outfit datum type
	var/default_outfit = /datum/outfit/job/assistant

	var/loading = FALSE

/obj/machinery/computer/arena/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	LoadDefaultArenas()

/obj/machinery/computer/arena/proc/LoadDefaultArenas()
	var/arena_dir = "[global.config.directory]/arenas/"
	var/list/default_arenas = flist(arena_dir)
	for(var/arena_file in default_arenas)
		var/simple_name = replacetext(replacetext(arena_file,arena_dir,""),".dmm","")
		add_new_arena_template(null,arena_dir + arena_file,simple_name)
	return

/obj/machinery/computer/arena/proc/get_landmark_turf(landmark_tag)
	for(var/obj/effect/landmark/arena/L in GLOB.landmarks_list)
		if(L.arena_id == arena_id && L.landmark_tag == landmark_tag && isturf(L.loc))
			return L.loc

/obj/machinery/computer/arena/proc/clear_arena()
	for(var/turf/T in block(get_landmark_turf("arena_start"),get_landmark_turf("arena_end")))
		T.empty(turf_type = /turf/open/indestructible)
	return

/obj/machinery/computer/arena/proc/load_arena(arena_template,mob/user)
	if(loading)
		return
	var/datum/map_template/M = arena_templates[arena_template]
	if(!M)
		to_chat(user,"<span class='warning'>No such arena</span>")
		return
	clear_arena() //Clear current arena
	loading = TRUE
	var/bd = M.load(get_landmark_turf("arena_start"))
	if(bd)
		current_arena_template = arena_template
		arena_afterload(arena_template)
	loading = FALSE

/obj/machinery/computer/arena/proc/arena_afterload(arena_filename)
	switch(arena_filename)
		if("example.dmm")
			to_chat(world,"EXAMPLE ARENA FIGHT STARTING NOW. OR WHATEVER")

/obj/machinery/computer/arena/proc/add_new_arena_template(user,fname,friendly_name)
	if(!fname)
		fname = input(user, "Upload dmm file to use as arena template","Upload Map Template") as null|file
	if(!fname)
		return
	if(!friendly_name)
		friendly_name = fname //Could ask the user for friendly name here

	var/datum/map_template/T = new(fname,friendly_name,TRUE)
	if(!T.cached_map || T.cached_map.check_for_errors())
		to_chat(user,"Map failed to parse check for errors.")
		return

	arena_templates[T.name] = T

/obj/machinery/computer/arena/proc/add_team_member(mob/user,team)
	var/list/keys = list()
	for(var/mob/M in GLOB.player_list)
		keys += M.client
	var/client/selection = input("Please, select a player!", "Team member", null, null) as null|anything in sortKey(keys)
	//Could be freeform if you want to add disconnected i guess
	if(!selection)
		return
	if(!team_keys[team])
		team_keys[team] = list(selection.ckey)
	else
		team_keys[team] |= selection.ckey
	to_chat(user,"[selection.ckey] added to [team] team.")

/obj/machinery/computer/arena/proc/remove_member(mob/user,ckey,team)
	team_keys[team] -= ckey
	to_chat(user,"[ckey] removed from [team] team.")

/obj/machinery/computer/arena/proc/spawn_member(obj/machinery/arena_spawn/spawnpoint,ckey,team)
	var/mob/oldbody = get_mob_by_key(ckey)
	if(!isobserver(oldbody))
		return
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(get_turf(spawnpoint))
	oldbody.client.prefs.copy_to(M)
	M.set_species(/datum/species/human) //Might set per team
	M.equipOutfit(outfits[team] ? outfits[team] : default_outfit)
	M.faction += team //In case anyone wants to add team based stuff to arenas
	M.key = ckey
	

/obj/machinery/computer/arena/proc/change_outfit(mob/user,team)
	outfits[team] = user.client.robust_dress_shop()

/obj/machinery/computer/arena/Topic(href, href_list)
	. = ..()
	var/mob/user = usr

	if(!user.client.holder) //These things are dangerous enough
		return

	if(href_list["upload"])
		add_new_arena_template(user)
	if(href_list["change_arena"])
		load_arena(href_list["change_arena"],user)
	if(href_list["toggle_spawn"])
		toggle_spawn(user)
	if(href_list["team_action"])
		var/team = href_list["team"]
		switch(href_list["team_action"])
			if("addmember")
				add_team_member(user,team)
			if("outfit")
				change_outfit(user,team)
	if(href_list["special"])
		switch(href_list["special"])
			if("reset")
				clear_arena()
			//Just example in case you want to add more
			if("rockfallseverybodydies")
				kill_everyone_in_arena()
			if("spawntrophy")
				trophy_for_last_man_standing()
	if(href_list["member_action"])
		var/ckey = href_list["ckey"]
		var/team = href_list["team"]
		switch(href_list["member_action"])
			if("remove")
				remove_member(user,ckey,team)
	updateUsrDialog()

/obj/machinery/computer/arena/proc/kill_everyone_in_arena()
	to_chat(world,"Rocks fall, everybody dies.")
	var/arena_turfs = block(get_landmark_turf("arena_start"),get_landmark_turf("arena_end"))
	for(var/mob/living/L in GLOB.mob_living_list)
		if(get_turf(L) in arena_turfs)
			L.death()

/obj/machinery/computer/arena/proc/toggle_spawn(mob/user)
	ready_to_spawn = !ready_to_spawn
	to_chat(user,"You [ready_to_spawn ? "enable" : "disable"] the spawners.")
	//Could use update_icon on spawnpoints to show they're on

/obj/machinery/computer/arena/proc/trophy_for_last_man_standing()
	var/arena_turfs = block(get_landmark_turf("arena_start"),get_landmark_turf("arena_end"))
	for(var/mob/living/L in GLOB.mob_living_list)
		if(L.stat != DEAD && (get_turf(L) in arena_turfs))
			var/obj/item/reagent_containers/food/drinks/trophy/gold_cup/G = new(get_turf(L))
			G.name = "[L.real_name]'s Trophy"

/obj/machinery/computer/arena/ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state)
	. = ..()
	var/list/dat = list()
	dat += "<div>Spawning is currently [ready_to_spawn ? "<span class='good'>enabled</span>" : "<span class='bad'>disabled</span>"] <a href='?src=[REF(src)];toggle_spawn=1'>Toggle</a></div>"
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
		dat += "<div> Team Outfit : [outfits[team]]</div>"
		dat += "<a href='?src=[REF(src)];team_action=addmember;team=[team]'>Add member</a>"
		dat += "<a href='?src=[REF(src)];team_action=outfit;team=[team]'>Change Outfit</a>"
		//Add more per team features here

	dat += "Current arena: [current_arena_template]"
	dat += "<h2>Arena List:</h2>"
	for(var/A in arena_templates)
		dat += "<a href='?src=[REF(src)];change_arena=[url_encode(A)]'>[A]</a><br>"
	dat += "<hr>"
	dat += "<a href='?src=[REF(src)];upload=1'>Upload new arena</a><br>"
	dat += "<hr>"
	//Special actions
	dat += "<a href='?src=[REF(src)];special=reset'>Reset Arena.</a><br>"
	dat += "<a href='?src=[REF(src)];special=rockfallseverybodydies'>Kill everyone in the arena.</a><br>"
	dat += "<a href='?src=[REF(src)];special=spawntrophy'>Spawn trophies for survivors.</a><br>"

	var/datum/browser/popup = new(user, "arena controller", "Arena Controller", 300, 300)
	popup.set_content(dat.Join())
	popup.open()

/obj/machinery/arena_spawn
	name = "Arena Spawnpoint"
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"
	resistance_flags = INDESTRUCTIBLE
	var/arena_id = ARENA_DEFAULT_ID //In case we have multiple arena controllers at once.
	var/team = "default"
	var/obj/machinery/computer/arena/_controller //only exist to cut down on glob.machines lookups

/obj/machinery/arena_spawn/red
	name = "Red Team Spawnpoint"
	team = ARENA_RED_TEAM

/obj/machinery/arena_spawn/green
	name = "Green Team Spawnpoint"
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
			to_chat(user,"<span class='warning'>You're not on the team list.</span>")
			return
		C.spawn_member(src,user.ckey,team)