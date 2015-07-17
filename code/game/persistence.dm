/datum/persistence/
	var/last_singulo_release 	= 0
	var/record_singulo_release 	= 0
	var/savefile/S

/datum/persistence/New()
	S = new /savefile("data/persistence.sav")
	S.cd = "/"

	load_persistence()

/datum/persistence/proc/load_persistence()
	S["Last_Singulo_Release"]		>> last_singulo_release
	S["Record_Singulo_Release"]		>> record_singulo_release

/datum/persistence/proc/save_persistence()
	S["Last_Singulo_Release"]		<< ++last_singulo_release
	S["Record_Singulo_Release"]		<< max(record_singulo_release,last_singulo_release)