#define JOB_MODIFICATION_MAP_NAME "Delta Station"

/datum/outfit/job/New()
	..()
	MAP_JOB_CHECK

/datum/job/assistant/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 300
    spawn_positions = 300
    supervisors = "<span class='danger'>the Gods</span>"

MAP_REMOVE_JOB(captain) //job_types/captain.dm
MAP_REMOVE_JOB(hop) //job_types/cargo_service.dm
MAP_REMOVE_JOB(janitor)
MAP_REMOVE_JOB(hydro)
MAP_REMOVE_JOB(qm)
MAP_REMOVE_JOB(mining)
MAP_REMOVE_JOB(cargo_tech)
MAP_REMOVE_JOB(bartender)
MAP_REMOVE_JOB(cook)
MAP_REMOVE_JOB(clown) //job_types/civilian.dm
MAP_REMOVE_JOB(mime)
MAP_REMOVE_JOB(curator)
MAP_REMOVE_JOB(lawyer)
MAP_REMOVE_JOB(chaplain) //job_types/civilian_chaplain.dm
MAP_REMOVE_JOB(chief_engineer) //job_types/engineering.dm
MAP_REMOVE_JOB(engineer)
MAP_REMOVE_JOB(atmos)
MAP_REMOVE_JOB(cmo) //job_types/medical.dm
MAP_REMOVE_JOB(doctor)
MAP_REMOVE_JOB(chemist)
MAP_REMOVE_JOB(geneticist)
MAP_REMOVE_JOB(virologist)
MAP_REMOVE_JOB(rd) //job_types/science.dm
MAP_REMOVE_JOB(scientist)
MAP_REMOVE_JOB(roboticist)
MAP_REMOVE_JOB(hos) //job_types/security.dm
MAP_REMOVE_JOB(warden)
MAP_REMOVE_JOB(detective)
MAP_REMOVE_JOB(officer)
MAP_REMOVE_JOB(ai) //job_types/silicon.dm
MAP_REMOVE_JOB(cyborg)
