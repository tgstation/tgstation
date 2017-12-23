#define JOB_MODIFICATION_MAP_NAME "SB Station"

MAP_REMOVE_JOB(curator)
MAP_REMOVE_JOB(virologist)
MAP_REMOVE_JOB(warden)

// With no curator, give the soapstone to the chaplain
/datum/outfit/job/chaplain/New()
	..()
	MAP_JOB_CHECK
	backpack_contents[/obj/item/soapstone] = 1

/datum/job/hydro/New()
	..()
	MAP_JOB_CHECK
	spawn_positions = 1

/datum/job/chemist/New()
	..()
	MAP_JOB_CHECK
	spawn_positions = 1

/datum/job/lawyer/New()
	..()
	MAP_JOB_CHECK
	spawn_positions = 1
