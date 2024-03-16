GLOBAL_LIST_INIT(approved_ids, initialize_approved_ids())

/proc/unique_random_tapes(amt = 1)
	. = list()
	if(!length(GLOB.approved_ids))
		GLOB.approved_ids = initialize_approved_ids()
		if(!length(GLOB.approved_ids))
			return
	var/list/ids_to_choose = GLOB.approved_ids.Copy()
	amt = min(amt, length(ids_to_choose))
	for(var/i in 1 to amt)
		. += pick_n_take(ids_to_choose)

/proc/initialize_approved_ids()
	var/ids_exist = file("data/cassette_storage/ids.json")
	if(!fexists(ids_exist))
		return list()
	return json_decode(file2text(ids_exist))

/obj/item/device/cassette_tape/random
	name = "Not Correctly Created Random Cassette"
	desc = "How did this happen?"
	random = TRUE
	id = "not_randomized"
