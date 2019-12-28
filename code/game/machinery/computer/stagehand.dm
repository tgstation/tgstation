//Stage that has templates, can pull them and pull players in a timely fashion, ends in 2 minutes.
//todo: Automate the process, make it possible for people to check in early
// Would be nice to have a ready up button and a list with all people who are signed up with a checklist to show that they're ready

#define STAGE_DEFAULT_ID "stage_default"
#define STAGE_CORNER_A "cornerA"
#define STAGE_CORNER_B "cornerB"
#define STAGE_ITEM_1 "item 1"
#define STAGE_ITEM_2 "item 2"
#define STAGE_ITEM_3 "item 3"
#define STAGE_ITEM_4 "item 4"
#define STAGE_ITEM_5 "item 5"

GLOBAL_LIST_EMPTY(stageborder_list) //list of all stage borders, need this so we can change the ckey 

/obj/effect/landmark/stage
	name = "stage landmark"
	var/landmark_tag
	var/stage_id = STAGE_DEFAULT_ID

/obj/effect/landmark/stage/start
	name = "stage corner A"
	landmark_tag = STAGE_CORNER_A

/obj/effect/landmark/stage/end
	name = "stage item 1"
	landmark_tag = STAGE_CORNER_B

/obj/effect/landmark/stage/item1
	name = "stage item 1"
	landmark_tag = STAGE_ITEM_1

/obj/effect/landmark/stage/item2
	name = "stage item 2"
	landmark_tag = STAGE_ITEM_2

/obj/effect/landmark/stage/item3
	name = "stage item 3"
	landmark_tag = STAGE_ITEM_3

/obj/effect/landmark/stage/item4
	name = "stage item 4"
	landmark_tag = STAGE_ITEM_4

/obj/effect/landmark/stage/item5
	name = "stage item 5"
	landmark_tag = STAGE_ITEM_5

/obj/machinery/computer/stage
	name = "stage controller"
	/// Stage ID
	var/stage_id = STAGE_DEFAULT_ID
	/// Enables/disables spawning
	var/ready_to_spawn = FALSE
	/// Assoc list of map templates indexed by user friendly names
	var/static/list/stage_templates = list()
	/// Were the config directory stages loaded
	var/static/default_stage_loaded = FALSE
	/// Name of currently loaded template
	var/current_stage_template = "None"
	/// List of ckeys to be spawned
	var/list/actors = list()
	/// List of outfit datums/types indexed by team id, can be empty
	var/outfits = null
	/// Default outfit if outfits is empty
	var/default_outfit = /datum/outfit/job/clown
	/// Is the stage template loading in
	var/loading = FALSE

	//How long between acts unless changed
	var/start_delay = 120 SECONDS
	//Value for the countdown
	var/start_time
	///Landmarks for items
	var/list/item_landmarks = list()
	var/landmarks_loaded = FALSE
	var/list/all_stage_acts = list()
	var/override_automate = TRUE
	var/announcement_made = FALSE
	var/waiting_for_actor = FALSE
	var/test
	var/datum/outfit/stage/current_act //The current act on stage
	var/list/countdowns = list()

/obj/machinery/computer/stage/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	LoadDefaultStages()
	GenerateActs()


/**
  * Loads the stages from config directory.
  * THESE ARE FULLY CACHED FOR QUICK SWITCHING SO KEEP TRACK OF THE AMOUNT
  */
/obj/machinery/computer/stage/proc/LoadDefaultStages()
	if(default_stage_loaded)
		return
	var/stage_dir = "[global.config.directory]/arenas/"
	var/list/stage_list = flist(stage_dir)
	for(var/stage_file in stage_list)
		var/simple_name = replacetext(replacetext(stage_file,stage_dir,""),".dmm","")
		add_new_stage_template(null,stage_dir + stage_file,simple_name)

/obj/machinery/computer/stage/proc/GenerateActs()
	for(var/O in subtypesof(/datum/outfit/stage))
		var/datum/outfit/stage/stage_outfit = O
		all_stage_acts[initial(stage_outfit.name_of_act)] += new O()

/obj/machinery/computer/stage/proc/LoadItemLandmarks()
	if(!landmarks_loaded)
		item_landmarks += get_landmark_turf(STAGE_ITEM_1)
		item_landmarks += get_landmark_turf(STAGE_ITEM_2)
		item_landmarks += get_landmark_turf(STAGE_ITEM_3)
		item_landmarks += get_landmark_turf(STAGE_ITEM_4)
		item_landmarks += get_landmark_turf(STAGE_ITEM_5)
		landmarks_loaded = TRUE

/obj/machinery/computer/stage/proc/get_landmark_turf(landmark_tag)
	for(var/obj/effect/landmark/stage/L in GLOB.landmarks_list)
		if(L.stage_id == stage_id && L.landmark_tag == landmark_tag && isturf(L.loc))
			return L.loc

/obj/machinery/computer/stage/proc/get_load_point()
	var/turf/A = get_landmark_turf(STAGE_CORNER_A)
	var/turf/B = get_landmark_turf(STAGE_CORNER_B)
	return locate(min(A.x,B.x),min(A.y,B.y),A.z)

/obj/machinery/computer/stage/proc/get_stage_turfs()
	var/lp = get_load_point()
	var/turf/A = get_landmark_turf(STAGE_CORNER_A)
	var/turf/B = get_landmark_turf(STAGE_CORNER_B)
	var/turf/hp = locate(max(A.x,B.x),max(A.y,B.y),A.z)
	return block(lp,hp)

/obj/machinery/computer/stage/proc/clear_stage()
	for(var/turf/T in get_stage_turfs())
		T.empty(turf_type = /turf/open/floor/wood)
	current_stage_template = "None"

/obj/machinery/computer/stage/proc/load_stage(stage_template,mob/user)
	if(loading)
		return
	var/datum/map_template/M = stage_templates[stage_template]
	if(!M)
		to_chat(user,"<span class='warning'>No such stage</span>")
		return
	clear_stage() //Clear current stage
	var/turf/A = get_landmark_turf(STAGE_CORNER_A)
	var/turf/B = get_landmark_turf(STAGE_CORNER_B)
	var/wh = abs(A.x - B.x) + 1
	var/hz = abs(A.y - B.y) + 1
	if(M.width > wh || M.height > hz)
		to_chat(user,"<span class='warning'>Stage template is too big for the current stage!</span>")
		return
	loading = TRUE
	var/bd = M.load(get_load_point())
	if(bd)
		current_stage_template = stage_template
	loading = FALSE

	message_admins("[key_name_admin(user)] loaded [stage_template] event stage for [stage_id] stage.")
	log_admin("[key_name(user)] loaded [stage_template] event stage for [stage_id] stage.")

/obj/machinery/computer/stage/proc/add_new_stage_template(user,fname,friendly_name)
	if(!fname)
		fname = input(user, "Upload dmm file to use as stage template","Upload Map Template") as null|file
	if(!fname)
		return
	if(!friendly_name)
		friendly_name = "[fname]" //Could ask the user for friendly name here

	var/datum/map_template/T = new(fname,friendly_name,TRUE)
	if(!T.cached_map || T.cached_map.check_for_errors())
		to_chat(user,"Map failed to parse check for errors.")
		return

	stage_templates[T.name] = T
	message_admins("[key_name_admin(user)] uploaded new event stage: [friendly_name].")
	log_admin("[key_name(user)] uploaded new event stage: [friendly_name].")

/obj/machinery/computer/stage/proc/spawn_items(mob/user, list/item_setup)
	LoadItemLandmarks()
	if(!item_setup)
		item_setup = list()
		var/selection = input("Click the player's item list", "Actor's item lists", null, null) as null|anything in all_stage_acts
		if(!selection)
			return
		var/datum/outfit/stage/outfit_selection = all_stage_acts[selection]
		item_setup |= outfit_selection.items
	var/instance = 1
	for(var/item in item_setup)
		var/atom/movable/O = item
		var/turf/T = item_landmarks[instance]
		new O(T)
		instance++



/obj/machinery/computer/stage/proc/load_actors(user)
	var/rawactors = stripped_multiline_input(user,"Enter actors for the current stage (ckeys separated by newline)")
	for(var/i in splittext(rawactors,"\n"))
		var/key = ckey(i)
		if(!i)
			continue
		add_actor(user,key)

/obj/machinery/computer/stage/proc/add_actor(mob/user,key)
	if(!key)
		var/list/keys = list()
		for(var/mob/M in GLOB.player_list)
			keys += M.client
		var/client/selection = input("Please, select a player!", "Actors", null, null) as null|anything in sortKey(keys)
		//Could be freeform if you want to add disconnected i guess
		if(!selection)
			return
		key = selection.ckey
	actors.Add(key)
	to_chat(user,"[key] added to actors list.")

/obj/machinery/computer/stage/proc/remove_member(mob/user,ckey)
	actors.Remove(ckey)
	to_chat(user,"[ckey] removed from actors list")

/obj/machinery/computer/stage/proc/spawn_actor(obj/machinery/stage_spawn/spawnpoint, ckey)
	var/mob/oldbody = get_mob_by_key(ckey)
	if(!oldbody)
		return
	if(!oldbody.client)
		return
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(get_turf(spawnpoint))
	oldbody.client.prefs.copy_to(M)
	var/datum/species/S = oldbody.client.prefs.pref_species
	if(S.id == "plasmaman")
		var/datum/outfit/plasmaman/P = new
		if(outfits)
			var/datum/outfit/stage/A = outfits
			P.suit = initial(A.suit)
		P.l_hand = /obj/item/storage/toolbox
		M.equipOutfit(P)
	else
		M.equipOutfit(outfits ? outfits : default_outfit)
	M.equipOutfit(outfits ? outfits : default_outfit)
	M.key = ckey
	RegisterSignal(M, COMSIG_MOB_SAY, .proc/handle_speech)
	qdel(oldbody)
	return M.client

/obj/machinery/computer/stage/proc/handle_speech(mob/living/carbon/user, list/speech_args)
	speech_args[SPEECH_SPANS] |= list(SPAN_COMMAND)

/obj/machinery/computer/stage/proc/spawn_actors(mob/user)
	var/actor_spawn = get_spawn()
	var/list/actors_in_act = list()
	for(var/key in actors)
		actors_in_act.Add(spawn_actor(actor_spawn, key))
	to_chat(user,"Actors have been spawned.")
	if(actors_in_act.len)
		test = actors_in_act[1]
		return actors_in_act[1]


/obj/machinery/computer/stage/proc/change_outfit(mob/user)
	outfits = user.client.robust_dress_shop()

/obj/machinery/computer/stage/proc/toggle_spawn(mob/user)
	ready_to_spawn = !ready_to_spawn
	to_chat(user,"You [ready_to_spawn ? "enable" : "disable"] the stage spawn.")
	log_admin("[key_name(user)] toggled the spawn for the stage.")
	// Could use update_icon on spawnpoints here to show they're on
	if(ready_to_spawn)
		for(var/mob/M in all_actors())
			to_chat(M,"<span class='userdanger'>You're ready to perform!</span>")

/obj/machinery/computer/stage/proc/all_actors()
	. = list()
	for(var/key in actors)
		var/mob/M = get_mob_by_key(key)
		if(M)
			. += M

obj/machinery/computer/stage/proc/get_spawn()
	for(var/obj/machinery/stage_spawn/A in GLOB.machines)
		if(A.stage_id == stage_id)
			return A

obj/machinery/computer/stage/proc/toggle_automate_acts(user, var/change_override = TRUE)
	if(change_override)
		override_automate = !override_automate
		updateUsrDialog()
	if(waiting_for_actor)
		to_chat(user,"<span class='notice'>Please wait for the actor to show and for the 60 seconds to end. Once the 60 seconds are up and you have overriden the automation, you will be prompted to end the act. If you have spawned them in, click to continue the act after the seconds.</span>")
		return
	if(!announcement_made)
		priority_announce("The 2019 Winter Ball Talent Show is starting! Please make your way down to the 1st floor to the stage.", null, 'sound/ai/commandreport.ogg')
		announcement_made = TRUE
	for(var/ckey in all_stage_acts)
		current_act = all_stage_acts[ckey]
		if(override_automate)
			return
		if(current_act.act_completed)
			continue
		if(current_act.stage)
			log_world("loading [current_act.stage]")
			load_stage(current_act.stage, user)
		spawn_items(user, current_act.items)
		outfits = current_act // should change the outfit (and it does!)
		for(var/actor in current_act.ckey)
			var/i
			log_world("spawning [current_act.ckey[i]]")
			add_actor(user, actor)
			i++
		change_stage_border(current_act.ckey) // might want to let the person walk on stage.
		if(!spawn_actors(user) && !current_act.override_presence) // Person didn't spawn or isn't here
			priority_announce("[capitalize(current_act.ckey[1])] has not shown up! They have 60 seconds to appear or else they will be disqualified.")
			waiting_for_actor = TRUE
			sleep(60 SECONDS)
			if(!spawn_actors(user) && !override_automate)
				priority_announce("[capitalize(current_act.ckey[1])] has not shown up! They are disqualified.")
				Reset_Stage(user, ckey, current_act)
				waiting_for_actor = FALSE
				continue
		waiting_for_actor = FALSE
		if(override_automate)
			var/selection = input(user, "Do you wish to continue the current play? (Note if you choose NO, it will not be counted as completed and will continue when you turn on reautomation)", "Decision") as null|anything in list("Yes", "No")
			if(selection == "No")
				Reset_Stage(user, completed = FALSE)
				return
		priority_announce("Please put your hands together for [capitalize(current_act.ckey[1])]!!")
		if(current_act.time)
			start_delay = current_act.time
		var/timetext = DisplayTimeText(start_delay)
		for(var/mob/M in all_actors())
			to_chat(M,"<span class='userdanger'>You have [timetext]!</span>")
			RegisterSignal(M, COMSIG_MOB_DEATH, .proc/on_death) // Need to listen to see if the person died.
		to_chat(user,"<span class='notice'>The act has started! [timetext] remains.</span>")
		start_time = world.time + start_delay
		var/obj/machinery/stage_spawn/actor_spawn = get_spawn()
		var/obj/effect/countdown/stage/A = new(actor_spawn)
		A.start()
		countdowns += A
		sleep(start_delay)
		var/datum/outfit/stage/original_play = all_stage_acts[ckey] // probably a better way to do this, but we need the orginal play datum
		var/list/ckey_list = original_play.ckey
		if(original_play.act_completed) // if this happened, we've run through the list again and this proc can end
			return
		Reset_Stage(user, ckey, current_act)

/obj/machinery/computer/stage/proc/Reset_Stage(user, ckey, var/datum/outfit/stage/current_act, var/completed = TRUE)
	for(var/mob/M in all_actors())
		UnregisterSignal(M, COMSIG_MOB_SAY)
	if(countdowns)
		QDEL_LIST(countdowns)
	for(var/CK in actors)
		remove_member(user, CK)
	updateUsrDialog()
	clear_stage()
	start_delay = 120 SECONDS
	if(completed)
		current_act.act_completed = TRUE
	if(!waiting_for_actor)
		priority_announce("Thank you to [capitalize(current_act.ckey[1])] for their performance!", title ="", sound ='sound/misc/applause.ogg')

/obj/machinery/computer/stage/proc/on_death()
	var/datum/outfit/stage/original_play = all_stage_acts[current_act.ckey[1]] // finds the play
	original_play.dead = original_play.dead + 1 //tallies a death to the play
	var/list/actors_in_act = original_play.ckey
	if(original_play.dead < actors_in_act.len) //might have plays with more than 2 actors
		return
	original_play.act_completed = TRUE // completes that play
	sleep(5 SECONDS) // let the death SINK IN
	all_stage_acts[current_act.ckey[1]] = original_play // reassigns the play to the datum on the list, to show that it has ended with death(s)
	var/mob/user = usr
	Reset_Stage(user, current_act.ckey, current_act)
	toggle_automate_acts(user, FALSE) // run through the list again without changing the override

/obj/machinery/computer/stage/proc/change_stage_border(ckey) // changes the ckey of the border so that the person on stage can walk around
	for(var/obj/effect/path_blocker/stage/border in GLOB.stageborder_list)
		border.ckeys = ckey

/obj/machinery/computer/stage/Topic(href, href_list)
	if(..())
		return
	var/mob/user = usr

	if(!user.client.holder) // Should it require specific perm ?
		return
	if(href_list["spawn_items"])
		spawn_items(user)
	if(href_list["toggle_automate_acts"])
		toggle_automate_acts(user)
	if(href_list["upload"])
		add_new_stage_template(user)
	if(href_list["change_stage"])
		load_stage(href_list["change_stage"],user)
	if(href_list["toggle_spawn"])
		toggle_spawn(user)

	if(href_list["actors_action"])
		switch(href_list["actors_action"])
			if("addmember")
				add_actor(user)
			if("loadactors")
				load_actors(user)
			if("outfit")
				change_outfit(user)
			if("spawnactors")
				spawn_actors(user)

	if(href_list["special"])
		switch(href_list["special"])
			if("reset")
				clear_stage()
			//Just example in case you want to add more
	if(href_list["member_action"])
		var/ckey = href_list["ckey"]
		switch(href_list["member_action"])
			if("remove")
				remove_member(user,ckey)
	updateUsrDialog()


/obj/machinery/computer/stage/ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state)
	. = ..()
	var/list/dat = list()
	dat += "<div>Spawning is currently [ready_to_spawn ? "<span class='good'>enabled</span>" : "<span class='bad'>disabled</span>"] <a href='?src=[REF(src)];toggle_spawn=1'>Toggle</a></div>"
	for(var/ckey in actors)
		dat += "<h2>Actors:</h2>"
		dat += "<ul>"
		var/player_status = "Not Present"
		var/mob/M = get_mob_by_key(ckey)
		if(M)
			if(isobserver(M))
				player_status = "Ghosted"
			else
				player_status = M.stat == DEAD ? "Dead" : "Alive"
			dat += "<li>[ckey] - [player_status] - "
			dat += "<a href='?_src_=holder;[HrefToken(TRUE)];adminplayerobservefollow=[REF(M)]'>FLW</a>"
			dat += "<a href='?src=[REF(src)];member_action=remove;ckey=[ckey]'>Remove</a>"
			//Add more per player features here
			dat += "</li>"
	dat += "</ul>"
	dat += "<div> Team Outfit : [outfits ? outfits : default_outfit]</div>"
	dat += "<a href='?src=[REF(src)];actors_action=loadactors'>Load actors</a>"
	dat += "<a href='?src=[REF(src)];actors_action=addmember'>Add member</a>"
	dat += "<a href='?src=[REF(src)];actors_action=outfit'>Change Outfit</a>"
	dat += "<a href='?src=[REF(src)];actors_action=spawnactors'>Spawn Actors</a>"

	dat += "Current stage: [current_stage_template]"
	dat += "<h2>Stage List:</h2>"
	for(var/A in stage_templates)
		dat += "<a href='?src=[REF(src)];change_stage=[url_encode(A)]'>[A]</a><br>"
	dat += "<hr>"
	dat += "<a href='?src=[REF(src)];spawn_items=1'>Spawn Items</a>"
	dat += "<div> <b>Automation Overide</b> is currently [override_automate ? "<span class='bad'>enabled</span>" : "<span class='good'>disabled</span>"] <a href='?src=[REF(src)];toggle_automate_acts=1'>Toggle Act Automation</a>"
	dat += "<a href='?src=[REF(src)];upload=1'>Upload new stage</a><br>"
	dat += "<hr>"
	//Special actions
	dat += "<a href='?src=[REF(src)];special=reset'>Reset Stage.</a><br>"

	var/datum/browser/popup = new(user, "stage controller", "Stage Controller", 500, 600)
	popup.set_content(dat.Join())
	popup.open()

/obj/machinery/computer/stage_signup

// Stage spawnpoint
/obj/machinery/stage_spawn
	name = "Stage Spawnpoint"
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"
	resistance_flags = INDESTRUCTIBLE
	/// In case we have multiple stage controllers at once.
	var/stage_id = STAGE_DEFAULT_ID
	/// only exist to cut down on glob.machines lookups, do not modify
	var/obj/machinery/computer/stage/_controller

/obj/machinery/stage_spawn/proc/get_controller()
	if(_controller && !QDELETED(_controller) && _controller.stage_id == stage_id)
		return _controller
	for(var/obj/machinery/computer/stage/A in GLOB.machines)
		if(A.stage_id == stage_id)
			_controller = A
			return _controller

/obj/machinery/stage_spawn/attack_ghost(mob/user)
	var/obj/machinery/computer/stage/C = get_controller()
	if(!C) //Unlinked spawn
		return
	if(C.ready_to_spawn)
		var/list/allowed_keys = C.actors
		if(!(user.ckey in allowed_keys))
			to_chat(user,"<span class='warning'>You're not set to perform currently.</span>")
			return
		C.spawn_actor(src,user.ckey)

/obj/effect/path_blocker/stage
	name = "Stage Barrier"
	desc = "Do they just let anyone up here?"
	var/ckeys = list() //who is on stage currently?

/obj/effect/path_blocker/stage/Initialize()
	. = ..()
	GLOB.stageborder_list += src

/obj/effect/path_blocker/stage/Destroy()
	GLOB.stageborder_list -= src
	return ..()
	

/obj/effect/path_blocker/stage/CanPass(atom/movable/mover, turf/target)
	if(mover.client_mobs_in_contents)
		var/mob/M = mover
		if(!(M.ckey in ckeys))
			return reverse
		return !reverse
	return reverse

#undef STAGE_DEFAULT_ID
#undef STAGE_CORNER_A
#undef STAGE_CORNER_B
#undef STAGE_ITEM_1
#undef STAGE_ITEM_2
#undef STAGE_ITEM_3
#undef STAGE_ITEM_4
#undef STAGE_ITEM_5