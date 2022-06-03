/obj/machinery/airalarm/cold_room

/obj/machinery/airalarm/cold_room/Initialize(mapload, ndir, nbuild)
	. = ..()
	alarm_thresholds = new /datum/alarm_threshold_collection/cold_room

/obj/machinery/airalarm/coldest

/obj/machinery/airalarm/coldest/Initialize(mapload, ndir, nbuild)
	. = ..()
	alarm_thresholds = new /datum/alarm_threshold_collection/coldest

/obj/machinery/airalarm/hottest

/obj/machinery/airalarm/hottest/Initialize(mapload, ndir, nbuild)
	. = ..()
	alarm_thresholds = new /datum/alarm_threshold_collection/hottest

/obj/machinery/airalarm/unlocked
	locked = FALSE

/obj/machinery/airalarm/engine
	name = "engine air alarm"
	locked = FALSE
	req_access = null
	req_one_access = list(ACCESS_ATMOSPHERICS, ACCESS_ENGINEERING)

/obj/machinery/airalarm/mixingchamber
	name = "chamber air alarm"
	locked = FALSE
	req_access = null
	req_one_access = list(ACCESS_ATMOSPHERICS, ACCESS_ORDNANCE)

/obj/machinery/airalarm/all_access
	name = "all-access air alarm"
	desc = "This particular atmos control unit appears to have no access restrictions."
	locked = FALSE
	req_access = null
	req_one_access = null

/obj/machinery/airalarm/syndicate //general syndicate access
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/airalarm/away //general away mission access
	req_access = list(ACCESS_AWAY_GENERAL)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/airalarm, 24)
