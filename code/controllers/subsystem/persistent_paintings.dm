SUBSYSTEM_DEF(persistent_paintings)
	name = "Persistent Paintings"
	init_order = INIT_ORDER_PERSISTENT_PAINTINGS
	flags = SS_NO_FIRE

	/// A list of painting frames that this controls
	var/list/obj/structure/sign/painting/painting_frames = list()

	/// A map of identifiers (such as library) to paintings from paintings.json
	var/list/paintings = list()

/datum/controller/subsystem/persistent_paintings/Initialize(start_timeofday)
	var/json_file = file("data/paintings.json")
	if(fexists(json_file))
		paintings = json_decode(file2text(json_file))

	for(var/obj/structure/sign/painting/painting_frame as anything in painting_frames)
		painting_frame.load_persistent()

	return ..()

/// Saves all persistent paintings
/datum/controller/subsystem/persistent_paintings/proc/save_paintings()
	for(var/obj/structure/sign/painting/painting_frame as anything in painting_frames)
		painting_frame.save_persistent()

	var/json_file = file("data/paintings.json")
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(paintings))
