/* THE GREAT BIG STATISTICS COLLECTION project
	The objective of all this shitcode is to collect important/interesting events in a round
	and write it to a really dumb text file, which will then be processed by an external server,
	whichi will generate a pretty, web-viewable version (if I get my shit together)
	by the public.

	Gamemode-specific stat collection is separated off into its own files because why not


	stat_collector is the nerve center, everything else is just there to store data until
	round end.
*/

// Important things to store stats on that aren't located here:
// ticker.mode, actual gamemode
// master_mode, i.e. secret, mixed

// To ensure that if output file syntax is changed, we will still be able to process
// new and old files
#define STAT_OUTPUT_VERSION "1.0"
#define STAT_OUTPUT_DIR "data/statfiles/"

/datum/stat_collector
	// UNUSED
	// var/enabled = 1
	var/human_death_stats = list()
	var/death_stats = list()
	var/explosion_stats = list()
	var/uplink_purchases = list()
	var/badass_bundles = list()
	// Blood spilled in c.liters
	var/blood_spilled = 0
	var/crates_ordered = 0
	var/artifacts_discovered = 0
	var/narsie_corpses_fed = 0
	var/escapees = 0
	var/crewscore = 0
	var/nuked = 0

	// Stat blobs
	var/datum/stat_blob/cult/cult = new
	var/datum/stat_blob/xeno/xeno = new

	var/gamemode = "UNSET"
	var/mixed_gamemodes = null
	var/round_start_time = null

/datum/stat/death_stat
	var/mob_typepath = "null"
	var/death_x = 0
	var/death_y = 0
	var/death_z = 0
	var/special_role = "null"
	var/key = "null"
	var/time_of_death = 0
	var/last_attacked_by = "null"
	var/realname = "null"

/datum/stat/uplink_purchase_stat
	var/itemtype = "null"
	var/bundle = "null"
	var/purchaser_key = "null"
	var/purchaser_name = "null"
	var/purchaser_is_traitor = 1

/datum/stat/uplink_badass_bundle_stat
	var/obj/contains = list()
	var/purchaser_key = "null"
	var/purchaser_name = "null"
	var/purchaser_is_traitor = 1

/datum/stat_collector/proc/uplink_purchase(var/datum/uplink_item/bundle, var/obj/resulting_item, var/mob/user )
	var/was_traitor = 1
	if(user.mind && user.mind.special_role != "traitor")
		was_traitor = 0

	if(istype(bundle, /datum/uplink_item/badass/bundle))
		var/datum/stat/uplink_badass_bundle_stat/BAD = new
		var/obj/item/weapon/storage/box/B = resulting_item
		for(var/obj/O in B.contents)
			BAD.contains += O.type
		BAD.purchaser_key = user.mind.key
		BAD.purchaser_name = user.mind.name
		BAD.purchaser_is_traitor = was_traitor
		badass_bundles += BAD
	else
		var/datum/stat/uplink_purchase_stat/UP = new
		if(istype(bundle, /datum/uplink_item/badass/random))
			UP.itemtype = resulting_item.type
		else
			UP.itemtype = bundle.item
		UP.bundle = bundle.type
		UP.purchaser_key = user.mind.key
		UP.purchaser_name = user.mind.name
		UP.purchaser_is_traitor = was_traitor
		uplink_purchases += UP

// /datum/stat_collector/proc/add_human_death(var/mob/living/carbon/human/M, var/datum/mind/B, timeofdeath)
// 	var/datum/stat/death_stat/d = new
// 	d.time_of_death = timeofdeath // We don't have a mob time of death yet since that's done after this proc call and I can't change that.
// 	d.last_attacked_by = M.LAssailant
// 	d.death_x = M.x
// 	d.death_y = M.y
// 	d.death_z = M.z
// 	d.mob_typepath = M.type
// 	if(B)
// 		d.special_role = B.special_role
// 		if(B.key)
// 			d.key = B.key
// 		if(B.name)
// 			d.realname = B.name
// 	stat_collection.human_death_stats += d

/datum/stat_collector/proc/add_death_stat(var/mob/M)
	//if(istype(M, /mob/living/carbon/human)) return 0
	if(ticker.current_state != 3) return 0 // We don't care about pre-round or post-round deaths. 3 is GAME_STATE_PLAYING which is undefined I guess
	var/datum/stat/death_stat/d = new
	d.time_of_death = M.timeofdeath
	d.last_attacked_by = M.LAssailant
	d.death_x = M.x
	d.death_y = M.y
	d.death_z = M.z
	d.mob_typepath = M.type
	d.realname = M.name
	if(M.mind)
		if(M.mind.special_role && M.mind.special_role != "") d.special_role = M.mind.special_role
		if(M.mind.key) d.key = M.mind.key
		if(M.mind.name) d.realname = M.mind.name
	stat_collection.death_stats += d

/datum/stat/explosion_stat
	var/epicenter_x = 0
	var/epicenter_y = 0
	var/epicenter_z = 0
	var/devastation_range = 0
	var/heavy_impact_range = 0
	var/light_impact_range = 0
	var/max_range = 0

/datum/stat_collector/proc/add_explosion_stat(turf/epicenter, const/dev_range, const/hi_range, const/li_range, mx_range)
	var/datum/stat/explosion_stat/e = new
	e.epicenter_x = epicenter.x
	e.epicenter_y = epicenter.y
	e.epicenter_z = epicenter.z
	e.devastation_range = dev_range
	e.heavy_impact_range = hi_range
	e.light_impact_range = li_range
	e.max_range = mx_range
	stat_collection.explosion_stats += e

/* Maybe not necessary, actually, since all survivors will be accessible on round end
/datum/stat/survivor
*/

/datum/stat_collector/proc/get_research_score()
	var/obj/machinery/r_n_d/server/server = null
	var/tech_level_total
	for(var/obj/machinery/r_n_d/server/serber in machines)
		if(serber.name == "Core R&D Server")
			server=serber
			break
	if(!server)
		return
	for(var/datum/tech/T in tech_list)
		if(T.goal_level==0) // Ignore illegal tech, etc
			continue
		var/datum/tech/KT  = locate(T.type, server.files.known_tech)
		tech_level_total += KT.level
	return tech_level_total

/datum/stat_collector/proc/antagCheck(statfile)
	for(var/datum/mind/Mind in ticker.minds)
		for(var/datum/objective/objective in Mind.objectives)
			if(objective.explanation_text == "Free Objective")
				statfile << "ANTAG_OBJ|[Mind.name]|[Mind.key]|[Mind.special_role]|FREE_OBJ"
			else if (objective.target)
				statfile << "ANTAG_OBJ|[Mind.name]|[Mind.key]|[Mind.special_role]|[objective.type]|[objective.target]|[objective.target.assigned_role]|[objective.target.name]|[objective.check_completion()]|[objective.explanation_text]"
			else
				statfile << "ANTAG_OBJ|[Mind.name]|[Mind.key]|[Mind.special_role]|[objective.type]|[objective.check_completion()]|[objective.explanation_text]"


// This guy writes the first line(s) of the stat file! Woo!
/datum/stat_collector/proc/Write_Header(statfile)
	statfile << "STATLOG_START|[STAT_OUTPUT_VERSION]|[map.nameLong]|[num2text(round_start_time, 30)]|[num2text(world.realtime, 30)]"
	statfile << "MASTERMODE|[master_mode]" // sekrit, or whatever else was decided as the 'actual' mode on round start.
	if(istype(ticker.mode, /datum/game_mode/mixed))
		var/datum/game_mode/mixed/mixy = ticker.mode
		var/T = "GAMEMODE"
		for(var/datum/game_mode/GM in mixy.modes)
			T += "|[GM.name]"
		statfile << T
	else statfile << "GAMEMODE|[ticker.mode.name]"

/datum/stat_collector/proc/Write_Footer(statfile)
	statfile << "WRITE_COMPLETE" // because I'd like to know if a write was interrupted and therefore invalid

/datum/stat_collector/proc/Process()
	var/filename_date = time2text(round_start_time, "YYYY.DD.MM")
	var/roundnum = 1
	// Iterate until we have an unused file.
	while(fexists(file(("[STAT_OUTPUT_DIR]statistics_[filename_date].[roundnum].txt"))))
		roundnum++
	var/statfile = file("[STAT_OUTPUT_DIR]statistics_[filename_date].[roundnum].txt")

	world << "Writing statistics to file"

	var/start_time = world.realtime
	Write_Header(statfile)
	statfile << "TECH_TOTAL|[get_research_score()]"
	statfile << "BLOOD_SPILLED|[blood_spilled]"
	statfile << "CRATES_ORDERED|[crates_ordered]"
	statfile << "ARTIFACTS_DISCOVERED|[artifacts_discovered]"
	statfile << "CREWSCORE|[crewscore]"
	statfile << "ESCAPEES|[escapees]"
	statfile << "NUKED|[nuked]"

	for(var/datum/stat/death_stat/D in death_stats)
		statfile << "MOB_DEATH|[D.mob_typepath]|[D.special_role]|[num2text(D.time_of_death, 30)]|[D.last_attacked_by]|[D.death_x]|[D.death_y]|[D.death_z]|[D.key]|[D.realname]"
	for(var/datum/stat/explosion_stat/E in explosion_stats)
		statfile << "EXPLOSION|[E.epicenter_x]|[E.epicenter_y]|[E.epicenter_z]|[E.devastation_range]|[E.heavy_impact_range]|[E.light_impact_range]|[E.max_range]"
	for(var/datum/stat/uplink_purchase_stat/U in uplink_purchases)
		statfile << "UPLINK_ITEM|[U.purchaser_key]|[U.purchaser_name]|[U.purchaser_is_traitor]|[U.bundle]|[U.itemtype]"
	for(var/datum/stat/uplink_badass_bundle_stat/B in badass_bundles)
		var/o 	= 		"BADASS_BUNDLE|[B.purchaser_key]|[B.purchaser_name]|[B.purchaser_is_traitor]"
		for(var/S in B.contains)
			o += "|[S]"
		statfile << "[o]"

	cult.doPostRoundChecks()
	cult.writeStats(statfile)

	xeno.doPostRoundChecks()
	xeno.writeStats(statfile)

	antagCheck(statfile)

	Write_Footer(statfile)
	world << "Statistics written to file in [(start_time - world.realtime)/10] seconds." // I think that's right?


// TODO write all living mobs to DB
