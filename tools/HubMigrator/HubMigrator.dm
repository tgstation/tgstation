//Misc Medal hub IDs
#define MEDAL_METEOR 			"Your Life Before Your Eyes"
#define MEDAL_PULSE 			"Jackpot"
#define MEDAL_TIMEWASTE 		"Overextended The Joke"
#define MEDAL_RODSUPLEX 		"Feat of Strength"
#define MEDAL_CLOWNCARKING 		"Round and Full"
#define MEDAL_THANKSALOT 		"The Best Driver"
#define MEDAL_HELBITALJANKEN	"Hel-bent on Winning"
#define MEDAL_MATERIALCRAFT 	"Getting an Upgrade"


//Boss medals

// Medal hub IDs for boss medals (Pre-fixes)
#define BOSS_MEDAL_ANY		  "Boss Killer"
#define BOSS_MEDAL_MINER	  "Blood-drunk Miner Killer"
#define BOSS_MEDAL_BUBBLEGUM  "Bubblegum Killer"
#define BOSS_MEDAL_COLOSSUS	  "Colossus Killer"
#define BOSS_MEDAL_DRAKE	  "Drake Killer"
#define BOSS_MEDAL_HIEROPHANT "Hierophant Killer"
#define BOSS_MEDAL_LEGION	  "Legion Killer"
#define BOSS_MEDAL_TENDRIL	  "Tendril Exterminator"
#define BOSS_MEDAL_SWARMERS   "Swarmer Beacon Killer"

#define BOSS_MEDAL_MINER_CRUSHER	  	"Blood-drunk Miner Crusher"
#define BOSS_MEDAL_BUBBLEGUM_CRUSHER  	"Bubblegum Crusher"
#define BOSS_MEDAL_COLOSSUS_CRUSHER	  	"Colossus Crusher"
#define BOSS_MEDAL_DRAKE_CRUSHER	  	"Drake Crusher"
#define BOSS_MEDAL_HIEROPHANT_CRUSHER 	"Hierophant Crusher"
#define BOSS_MEDAL_LEGION_CRUSHER	 	"Legion Crusher"
#define BOSS_MEDAL_SWARMERS_CRUSHER		"Swarmer Beacon Crusher"

// Medal hub IDs for boss-kill scores
#define BOSS_SCORE 	         "Bosses Killed"
#define MINER_SCORE 		 "BDMs Killed"
#define BUBBLEGUM_SCORE 	 "Bubblegum Killed"
#define COLOSSUS_SCORE 	     "Colossus Killed"
#define DRAKE_SCORE 	     "Drakes Killed"
#define HIEROPHANT_SCORE 	 "Hierophants Killed"
#define LEGION_SCORE 	     "Legion Killed"
#define SWARMER_BEACON_SCORE "Swarmer Beacs Killed"
#define TENDRIL_CLEAR_SCORE	 "Tendrils Killed"



//Migration script generation
//Replace hub information and fire to generate hub_migration.sql script to use.
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

	var/ach = "achievements" //IMPORTANT : ADD PREFIX HERE IF YOU'RE USING PREFIXED SCHEMA

	var/list/giant_list_of_ckeys = params2list(world.GetScores(null,null,hub_address,hub_password))
	world << "starting migration script generation"
	var/outfile = file("hub_migration.sql")
	fdel(outfile)
	outfile << "BEGIN;"
	var/i = 1
	for(var/key in giant_list_of_ckeys)
		world << "Generating entries for [key] [i]/[giant_list_of_ckeys.len]"
		var/list/cheevos = params2list(world.GetMedal(null,key,hub_address,hub_password))
		//throw away old/invalid/unsupported ones
		cheevos = cheevos & valid_medals
		var/list/scores = params2list(world.GetScores(key,null,hub_address,hub_password))
		scores = scores & valid_scores
		for(var/score in scores)
			if(isnull(text2num(scores[score])))
				scores -= score
		var/keyv = ckey(key) //Checkinf if you don't have any manually entered drop tables; juniors on your hub is good idea.
		var/list/values = list()
		for(var/cheevo in cheevos)
			values += "('[keyv]','[cheevo]',1)"
		for(var/score in scores)
			values += "('[keyv]','[score]',[scores[score]])"
		if(values.len)
			var/list/keyline = list("INSERT INTO [ach](ckey,achievement_key,value) VALUES")
			keyline += values.Join(",")
			keyline += ";"
			outfile << keyline.Join()
		i++
	outfile << "END;"
