///Datum that handles
/datum/achievement_data
	///Ckey of this achievement data's owner
	var/key
	///Up to date list of all achievements and their info.
	var/data = list()
	///Original status of achievement.
	var/original_cached_data = list()
	///Have we done our set-up yet?
	var/initialized = FALSE

/datum/achievement_data/New(key)
	src.key = key
	if(SSachievements.initialized && !initialized)
		InitializeData()

/datum/achievement_data/proc/InitializeData()
	initialized = TRUE
	load_all_achievements() //So we know which achievements we have unlocked so far.

///Saves any out-of-date achievements to db.
/datum/achievement_data/proc/save()
	for(var/T in data)
		var/datum/award/A = SSachievements.awards[T]
		if(data[T] != original_cached_data[T])//If our data from before is not the same as now, save it to db.
			A.save(key,data[T])

/datum/achievement_data/proc/load_all_achievements()
	set waitfor = FALSE
	
	var/list/kv = list()
	var/datum/DBQuery/Query = SSdbcore.NewQuery("SELECT achievement_key,value FROM [format_table_name("achievements")] WHERE ckey = '[sanitizeSQL(key)]'")
	if(!Query.Execute())
		qdel(Query)
		return
	while(Query.NextRow())
		var/key = Query.item[1]
		var/value = text2num(Query.item[2])
		kv[key] = value
	qdel(Query)

	for(var/T in subtypesof(/datum/award))
		var/datum/award/A = SSachievements.awards[T]
		if(!A || !A.name) //Skip abstract achievements types
			continue
		if(!data[T])
			data[T] = A.parse_value(kv[A.hub_id])
			original_cached_data[T] = data[T]

///Updates local cache with db data for the given achievement type if it wasn't loaded yet.
/datum/achievement_data/proc/get_data(achievement_type)
	var/datum/award/A = SSachievements.awards[achievement_type]
	if(!A.name)
		return FALSE
	if(!data[achievement_type])
		data[achievement_type] = A.load(key)
		original_cached_data[achievement_type] = data[achievement_type]

///Unlocks an achievement of a specific type.
/datum/achievement_data/proc/unlock(achievement_type, mob/user)
	var/datum/award/A = SSachievements.awards[achievement_type]
	get_data(achievement_type) //Get the current status first if necessary
	if(istype(A, /datum/award/achievement))
		data[achievement_type] = TRUE
		A.on_unlock(user) //Only on default achievement, as scores keep going up.
	else if(istype(A, /datum/award/score))
		data[achievement_type] += 1

///Getter for the status/score of an achievement
/datum/achievement_data/proc/get_achievement_status(achievement_type)
	return data[achievement_type]

///Resets an achievement to default values.
/datum/achievement_data/proc/reset(achievement_type)
	var/datum/award/A = SSachievements.awards[achievement_type]
	get_data(achievement_type)
	if(istype(A, /datum/award/achievement))
		data[achievement_type] = FALSE
	else if(istype(A, /datum/award/score))
		data[achievement_type] = 0

/datum/achievement_data/ui_base_html(html)
	var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/simple/achievements)
	. = replacetext(html, "<!--customheadhtml-->", assets.css_tag())

/datum/achievement_data/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.always_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/simple/achievements)
		assets.send(user)
		ui = new(user, src, ui_key, "achievements", "Achievements Menu", 800, 1000, master_ui, state)
		ui.open()

/datum/achievement_data/ui_data(mob/user)
	var/ret_data = list() // screw standards (qustinnus you must rename src.data ok)
	ret_data["categories"] = list("Bosses", "Misc" , "Scores")
	ret_data["achievements"] = list()

	var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/simple/achievements)
	//This should be split into static data later
	for(var/achievement_type in SSachievements.awards)
		if(!SSachievements.awards[achievement_type].name) //No name? we a subtype.
			continue
		if(isnull(data[achievement_type])) //We're still loading
			continue
		var/list/this = list(
			"name" = SSachievements.awards[achievement_type].name,
			"desc" = SSachievements.awards[achievement_type].desc,
			"category" = SSachievements.awards[achievement_type].category,
			"icon_class" = assets.icon_class_name(SSachievements.awards[achievement_type].icon),
			"value" = data[achievement_type],
			"score" = ispath(achievement_type,/datum/award/score)
			)
		ret_data["achievements"] += list(this)

	return ret_data

/datum/achievement_data/ui_static_data(mob/user)
	. = ..()
	.["highscore"] = list()
	for(var/score in SSachievements.scores)
		var/datum/award/score/S = SSachievements.scores[score]
		if(!S.name || !S.track_high_scores || !S.high_scores.len)
			continue
		.["highscore"] += list(list("name" = S.name,"scores" = S.high_scores))

/client/verb/checkachievements()
	set category = "OOC"
	set name = "Check achievements"
	set desc = "See all of your achievements!"

	player_details.achievements.ui_interact(usr)


#ifdef TESTING

//Migration script generation
//Replace hub information and fire to generate data/hub_migration.sql script to use.
//TODO put this in seperate project
/mob/verb/generate_migration_script()
	set name = "Generate Hub Migration Script"

	var/hub_address = "REPLACEME"
	var/hub_password = "REPLACEME"
	
	var/list/valid_medals = list(
						MEDAL_METEOR,
						MEDAL_PULSE,
						MEDAL_TIMEWASTE,
						MEDAL_RODSUPLEX,
						MEDAL_CLOWNCARKING,
						MEDAL_THANKSALOT,
						MEDAL_HELBITALJANKEN,
						MEDAL_MATERIALCRAFT,
						BOSS_MEDAL_ANY,
						BOSS_MEDAL_MINER,
						BOSS_MEDAL_BUBBLEGUM,
						BOSS_MEDAL_COLOSSUS,
						BOSS_MEDAL_DRAKE,
						BOSS_MEDAL_HIEROPHANT,
						BOSS_MEDAL_LEGION,
						BOSS_MEDAL_TENDRIL,
						BOSS_MEDAL_SWARMERS,
						BOSS_MEDAL_MINER_CRUSHER,
						BOSS_MEDAL_BUBBLEGUM_CRUSHER,
						BOSS_MEDAL_COLOSSUS_CRUSHER,
						BOSS_MEDAL_DRAKE_CRUSHER,
						BOSS_MEDAL_HIEROPHANT_CRUSHER,
						BOSS_MEDAL_LEGION_CRUSHER,
						BOSS_MEDAL_SWARMERS_CRUSHER)
						
	var/list/valid_scores = list(
						BOSS_SCORE,
						MINER_SCORE,
						BUBBLEGUM_SCORE,
						COLOSSUS_SCORE,
						DRAKE_SCORE,
						HIEROPHANT_SCORE,
						LEGION_SCORE,
						SWARMER_BEACON_SCORE,
						TENDRIL_CLEAR_SCORE)

	var/ach = format_table_name("achievements")

	var/list/giant_list_of_ckeys = params2list(world.GetScores(null,null,hub_address,hub_password))
	to_chat(usr,"starting migration script generation")
	var/outfile = file("data/hub_migration.sql")
	fdel(outfile)
	WRITE_FILE(outfile,"BEGIN;")
	for(var/key in giant_list_of_ckeys)
		to_chat(usr,"Generating entries for [key]")
		var/list/cheevos = params2list(world.GetMedal(null,key,hub_address,hub_password))
		//throw away old/invalid/unsupported ones
		cheevos = cheevos & valid_medals
		var/list/scores = params2list(world.GetScores(key,null,hub_address,hub_password))
		scores = scores & valid_scores
		for(var/score in scores)
			if(isnull(text2num(scores[score])))
				scores -= score
		var/keyv = sanitizeSQL(key)
		var/list/values = list()
		for(var/cheevo in cheevos)
			values += "([keyv],[cheevo],1)"
		for(var/score in scores)
			values += "('[keyv]','[score]',[scores[score]])"
		if(values.len)
			var/list/keyline = list("INSERT INTO [ach](ckey,achievement_key,value) VALUES")
			keyline += values.Join(",")
			keyline += ";"
			WRITE_FILE(outfile,keyline.Join())
	WRITE_FILE(outfile,"END;")

#endif
