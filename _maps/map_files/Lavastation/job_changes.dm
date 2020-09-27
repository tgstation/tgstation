
//please god give everyone mining access i'm begging you.

#define JOB_MODIFICATION_MAP_NAME "Lavastation"

/datum/job/New()
	..()
	MAP_JOB_CHECK
	minimal_access = list(ACCESS_CARGO, ACCESS_QM, ACCESS_MINING, ACCESS_MINING_STATION)

/datum/outfit/job/New()
	..()
	MAP_JOB_CHECK
	box = /obj/item/storage/box/survival/radio