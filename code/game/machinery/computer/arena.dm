/obj/effect/landmark/arena
	name = "arena landmark"
	var/landmark_tag

/obj/effect/landmark/arena/start
	name = "arena lower left corner"
	landmark_tag = "arena_start"

/obj/effect/landmark/arena/end
	name = "arena upper right corner"
	landmark_tag = "arena_end"

/obj/machinery/computer/arena
	name = "arena controller"
	var/list/arena_templates = list()
	var/current_arena_template = "None"
	var/empty_turf_type = /turf/open/indestructible

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
		if(L.landmark_tag == landmark_tag && isturf(L.loc))
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

/obj/machinery/computer/arena/Topic(href, href_list)
	. = ..()
	var/user = usr

	if(!user.client.holder) //These things are dangerous enough
		return

	if(href_list["upload"])
		add_new_arena_template(user)
	if(href_list["change_arena"])
		load_arena(href_list["change_arena"],user)
	if(href_list["special"])
		switch(href_list["special"])
			if("reset")
				clear_arena()
			//Just example in case you want to add more
			if("rockfallseverybodydies")
				kill_everyone_in_arena()
			if("spawntrophy")
				trophy_for_last_man_standing()
	updateUsrDialog()

/obj/machinery/computer/arena/proc/kill_everyone_in_arena()
	to_chat(world,"Rocks fall, everybody dies.")
	var/arena_turfs = block(get_landmark_turf("arena_start"),get_landmark_turf("arena_end"))
	for(var/mob/living/L in GLOB.mob_living_list)
		if(get_turf(L) in arena_turfs)
			L.death()

/obj/machinery/computer/arena/proc/trophy_for_last_man_standing()
	var/arena_turfs = block(get_landmark_turf("arena_start"),get_landmark_turf("arena_end"))
	for(var/mob/living/L in GLOB.mob_living_list)
		if(L.stat != DEAD && (get_turf(L) in arena_turfs))
			var/obj/item/reagent_containers/food/drinks/trophy/gold_cup/G = new(get_turf(L))
			G.name = "[L.real_name]'s Trophy"

/obj/machinery/computer/arena/ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state)
	. = ..()
	var/list/dat = list()
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