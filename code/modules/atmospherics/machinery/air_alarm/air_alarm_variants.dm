
/obj/machinery/airalarm/server

/obj/machinery/airalarm/server/Initialize(mapload)
	. = ..()
	tlv_collection["temperature"] = new /datum/tlv/no_checks
	tlv_collection["pressure"] = new /datum/tlv/no_checks

/obj/machinery/airalarm/kitchen_cold_room

/obj/machinery/airalarm/kitchen_cold_room/Initialize(mapload)
	. = ..()
	tlv_collection["temperature"] = new /datum/tlv/cold_room_temperature
	tlv_collection["pressure"] = new /datum/tlv/cold_room_pressure

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
