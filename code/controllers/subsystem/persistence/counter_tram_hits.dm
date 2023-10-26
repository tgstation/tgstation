/// Location where we save the information about how many times the tram hit on previous round
#define TRAM_COUNT_FILEPATH "data/tram_hits_last_round.txt"

/datum/controller/subsystem/persistence/proc/load_tram_counter()
	if(!fexists(TRAM_COUNT_FILEPATH))
		return
	tram_hits_last_round = text2num(file2text(TRAM_COUNT_FILEPATH))

/datum/controller/subsystem/persistence/proc/save_tram_counter()
		rustg_file_write("[tram_hits_this_round]", TRAM_COUNT_FILEPATH)

#undef TRAM_COUNT_FILEPATH
