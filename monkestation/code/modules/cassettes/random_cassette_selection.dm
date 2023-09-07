GLOBAL_LIST_INIT(approved_ids, json_decode(file2text("data/cassette_storage/ids.json")))

/obj/item/device/cassette_tape/random
	name = "Not Correctly Created Random Cassette"
	desc = "How did this happen?"
	random = TRUE
	tape = /datum/cassette/cassette_tape/random
