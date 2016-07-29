// Because why bloat the main file when I can do this?
/datum/stat_blob/

/datum/stat_blob/proc/doPostRoundChecks()

/datum/stat_blob/proc/writeStats(file)

/datum/stat_blob/cult
	var/runes_written = 0
	var/runes_fumbled = 0
	var/runes_nulled = 0
	var/tomes_created = 0
	var/converted = 0
	var/narsie_summoned = 0
	var/narsie_corpses_fed = 0
	var/surviving_cultists = 0
	var/deconverted = 0

/datum/stat_blob/cult/doPostRoundChecks()
	for(var/datum/mind/M in ticker.minds)
		if(M.active && istype(M.current, /mob/living/carbon) && M.special_role == "Cultist")
			surviving_cultists++

/datum/stat_blob/cult/writeStats(file)
	file << "CULTSTATS|[runes_written]|[runes_fumbled]|[runes_nulled]|[converted]|[tomes_created]|[narsie_summoned]|[narsie_corpses_fed]|[surviving_cultists]|[deconverted]"

/datum/stat_blob/xeno/
	var/eggs_laid = 0
	var/faces_hugged = 0 //this actually should only count people impregnated, I just like the name
	var/proper_head_protection = 0 //whenever a facehugger fails to impregnate someone

/datum/stat_blob/xeno/writeStats(file)
	file << "XENOSTATS|[eggs_laid]|[faces_hugged]|[proper_head_protection]"
