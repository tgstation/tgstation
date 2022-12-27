
/obj/machinery/airalarm/server // No checks here.
	TLV = list(
		"pressure" = new/datum/tlv/no_checks,
		"temperature" = new/datum/tlv/no_checks,
		/datum/gas/oxygen = new/datum/tlv/no_checks,
		/datum/gas/nitrogen = new/datum/tlv/no_checks,
		/datum/gas/carbon_dioxide = new/datum/tlv/no_checks,
		/datum/gas/miasma = new/datum/tlv/no_checks,
		/datum/gas/plasma = new/datum/tlv/no_checks,
		/datum/gas/nitrous_oxide = new/datum/tlv/no_checks,
		/datum/gas/bz = new/datum/tlv/no_checks,
		/datum/gas/hypernoblium = new/datum/tlv/no_checks,
		/datum/gas/water_vapor = new/datum/tlv/no_checks,
		/datum/gas/tritium = new/datum/tlv/no_checks,
		/datum/gas/nitrium = new/datum/tlv/no_checks,
		/datum/gas/pluoxium = new/datum/tlv/no_checks,
		/datum/gas/freon = new/datum/tlv/no_checks,
		/datum/gas/hydrogen = new/datum/tlv/no_checks,
		/datum/gas/healium = new/datum/tlv/dangerous,
		/datum/gas/proto_nitrate = new/datum/tlv/dangerous,
		/datum/gas/zauker = new/datum/tlv/dangerous,
		/datum/gas/helium = new/datum/tlv/dangerous,
		/datum/gas/antinoblium = new/datum/tlv/dangerous,
		/datum/gas/halon = new/datum/tlv/dangerous,
	)

/obj/machinery/airalarm/kitchen_cold_room // Kitchen cold rooms start off at -14°C or 259.15K.
	TLV = list(
		"pressure" = new/datum/tlv(ONE_ATMOSPHERE * 0.8, ONE_ATMOSPHERE *  0.9, ONE_ATMOSPHERE * 1.1, ONE_ATMOSPHERE * 1.2), // kPa
		"temperature" = new/datum/tlv(COLD_ROOM_TEMP-40, COLD_ROOM_TEMP-20, COLD_ROOM_TEMP+20, COLD_ROOM_TEMP+40),
		/datum/gas/oxygen = new/datum/tlv(16, 19, 135, 140), // Partial pressure, kpa
		/datum/gas/nitrogen = new/datum/tlv(-1, -1, 1000, 1000),
		/datum/gas/carbon_dioxide = new/datum/tlv(-1, -1, 5, 10),
		/datum/gas/miasma = new/datum/tlv/(-1, -1, 2, 5),
		/datum/gas/plasma = new/datum/tlv/dangerous,
		/datum/gas/nitrous_oxide = new/datum/tlv/dangerous,
		/datum/gas/bz = new/datum/tlv/dangerous,
		/datum/gas/hypernoblium = new/datum/tlv(-1, -1, 1000, 1000), // Hyper-Noblium is inert and nontoxic
		/datum/gas/water_vapor = new/datum/tlv/dangerous,
		/datum/gas/tritium = new/datum/tlv/dangerous,
		/datum/gas/nitrium = new/datum/tlv/dangerous,
		/datum/gas/pluoxium = new/datum/tlv(-1, -1, 1000, 1000), // Unlike oxygen, pluoxium does not fuel plasma/tritium fires
		/datum/gas/freon = new/datum/tlv/dangerous,
		/datum/gas/hydrogen = new/datum/tlv/dangerous,
		/datum/gas/healium = new/datum/tlv/dangerous,
		/datum/gas/proto_nitrate = new/datum/tlv/dangerous,
		/datum/gas/zauker = new/datum/tlv/dangerous,
		/datum/gas/helium = new/datum/tlv/dangerous,
		/datum/gas/antinoblium = new/datum/tlv/dangerous,
		/datum/gas/halon = new/datum/tlv/dangerous,
	)

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

/datum/armor/machinery_airalarm
	energy = 100
	fire = 90
	acid = 30

/obj/machinery/airalarm/syndicate //general syndicate access
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/airalarm/away //general away mission access
	req_access = list(ACCESS_AWAY_GENERAL)
