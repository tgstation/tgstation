/obj/effect/mapping_helpers/airlock/access
	layer = DOOR_HELPER_LAYER
	icon_state = "access_helper"

// These are mutually exclusive; can't have req_any and req_all
/obj/effect/mapping_helpers/airlock/access/any/payload(obj/machinery/door/airlock/airlock)
	if(airlock.req_access_txt == "0")
		var/list/access_list = get_access()
		// Overwrite if there is no access set, otherwise add onto existing access
		if(airlock.req_one_access_txt == "0")
			airlock.req_one_access_txt = access_list.Join(";")
		else
			airlock.req_one_access_txt += ";[access_list.Join(";")]"
	else
		log_mapping("[src] at [AREACOORD(src)] tried to set req_one_access, but req_access was already set!")

/obj/effect/mapping_helpers/airlock/access/all/payload(obj/machinery/door/airlock/airlock)
	if(airlock.req_one_access_txt == "0")
		var/list/access_list = get_access()
		if(airlock.req_access_txt == "0")
			airlock.req_access_txt = access_list.Join(";")
		else
			airlock.req_access_txt += ";[access_list.Join(";")]"
	else
		log_mapping("[src] at [AREACOORD(src)] tried to set req_access, but req_one_access was already set!")

/obj/effect/mapping_helpers/airlock/access/proc/get_access()
	var/list/access = list()
	return access

// -------------------- Req Any (Only requires ONE of the given accesses to open)
// -------------------- Command access helpers
/obj/effect/mapping_helpers/airlock/access/any/command
	icon_state = "access_helper_com"

/obj/effect/mapping_helpers/airlock/access/any/command/general/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_HEADS
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/command/ai_upload/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_AI_UPLOAD
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/command/teleporter/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_TELEPORTER
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/command/eva/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_EVA
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/command/gateway/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_GATEWAY
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/command/hop/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_HOP
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/command/captain/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CAPTAIN
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/command/maintenance/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_HEADS, ACCESS_MAINT_TUNNELS)
	return access_list

// -------------------- Engineering access helpers
/obj/effect/mapping_helpers/airlock/access/any/engineering
	icon_state = "access_helper_eng"

/obj/effect/mapping_helpers/airlock/access/any/engineering/general/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_ENGINE
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/engineering/engine_equipment/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_ENGINE_EQUIP
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/engineering/construction/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CONSTRUCTION
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/engineering/aux_base/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_AUX_BASE
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/engineering/maintenance/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_MAINT_TUNNELS
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/engineering/maintenance/departmental/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_ENGINE, ACCESS_MAINT_TUNNELS)
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/engineering/external/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_EXTERNAL_AIRLOCKS
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/engineering/tech_storage/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_TECH_STORAGE
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/engineering/atmos/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_ATMOSPHERICS
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/engineering/tcoms/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_TCOMSAT
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/engineering/ce/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CE
	return access_list

// -------------------- Medical access helpers
/obj/effect/mapping_helpers/airlock/access/any/medical
	icon_state = "access_helper_med"

/obj/effect/mapping_helpers/airlock/access/any/medical/general/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_MEDICAL
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/medical/morgue/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_MORGUE
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/medical/chemistry/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CHEMISTRY
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/medical/virology/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_VIROLOGY
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/medical/surgery/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_SURGERY
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/medical/cmo/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CMO
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/medical/pharmacy/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_PHARMACY
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/medical/psychology/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_PSYCHOLOGY
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/medical/maintenance/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_MEDICAL, ACCESS_MAINT_TUNNELS)
	return access_list

// -------------------- Science access helpers
/obj/effect/mapping_helpers/airlock/access/any/science
	icon_state = "access_helper_sci"

/obj/effect/mapping_helpers/airlock/access/any/science/general/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_RND
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/science/research/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_RESEARCH
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/science/ordnance/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_ORDNANCE
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/science/ordnance_storage/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_ORDNANCE_STORAGE
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/science/genetics/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_GENETICS
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/science/robotics/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_ROBOTICS
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/science/xenobio/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_XENOBIOLOGY
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/science/minisat/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_MINISAT
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/science/rd/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_RD
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/science/maintenance/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_RND, ACCESS_MAINT_TUNNELS)
	return access_list

// -------------------- Security access helpers
/obj/effect/mapping_helpers/airlock/access/any/security
	icon_state = "access_helper_sec"

/obj/effect/mapping_helpers/airlock/access/any/security/general/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_SECURITY
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/security/entrance/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_BRIG_ENTRANCE
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/security/brig/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_BRIG
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/security/armory/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_ARMORY
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/security/detective/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_FORENSICS
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/security/court/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_COURT
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/security/hos/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_HOS
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/security/maintenance/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_SECURITY, ACCESS_MAINT_TUNNELS)
	return access_list

// -------------------- Service access helpers
/obj/effect/mapping_helpers/airlock/access/any/service
	icon_state = "access_helper_serv"

/obj/effect/mapping_helpers/airlock/access/any/service/general/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_SERVICE
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/service/kitchen/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_KITCHEN
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/service/bar/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_BAR
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/service/hydroponics/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_HYDROPONICS
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/service/janitor/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_JANITOR
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/service/chapel_office/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CHAPEL_OFFICE
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/service/crematorium/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CREMATORIUM
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/service/library/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_LIBRARY
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/service/theatre/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_THEATRE
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/service/lawyer/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_LAWYER
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/service/maintenance/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_SERVICE, ACCESS_MAINT_TUNNELS)
	return access_list

// -------------------- Supply access helpers
/obj/effect/mapping_helpers/airlock/access/any/supply
	icon_state = "access_helper_sup"

/obj/effect/mapping_helpers/airlock/access/any/supply/general/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CARGO
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/supply/mail_sorting/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_MAILSORTING
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/supply/mining/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_MINING
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/supply/mining_station/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_MINING_STATION
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/supply/mineral_storage/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_MINERAL_STOREROOM
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/supply/qm/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_QM
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/supply/vault/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_VAULT
	return access_list

/obj/effect/mapping_helpers/airlock/access/any/supply/maintenance/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_CARGO, ACCESS_MAINT_TUNNELS)
	return access_list

// -------------------- Req All (Requires ALL of the given accesses to open)
// -------------------- Command access helpers
/obj/effect/mapping_helpers/airlock/access/all/command
	icon_state = "access_helper_com"

/obj/effect/mapping_helpers/airlock/access/all/command/general/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_HEADS
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/command/ai_upload/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_AI_UPLOAD
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/command/teleporter/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_TELEPORTER
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/command/eva/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_EVA
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/command/gateway/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_GATEWAY
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/command/hop/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_HOP
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/command/captain/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CAPTAIN
	return access_list

// -------------------- Engineering access helpers
/obj/effect/mapping_helpers/airlock/access/all/engineering
	icon_state = "access_helper_eng"

/obj/effect/mapping_helpers/airlock/access/all/engineering/general/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_ENGINE
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/engineering/engine_equipment/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_ENGINE_EQUIP
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/engineering/construction/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CONSTRUCTION
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/engineering/aux_base/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_AUX_BASE
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/engineering/maintenance/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_MAINT_TUNNELS
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/engineering/external/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_EXTERNAL_AIRLOCKS
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/engineering/tech_storage/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_TECH_STORAGE
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/engineering/atmos/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_ATMOSPHERICS
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/engineering/tcoms/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_TCOMSAT
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/engineering/ce/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CE
	return access_list

// -------------------- Medical access helpers
/obj/effect/mapping_helpers/airlock/access/all/medical
	icon_state = "access_helper_med"

/obj/effect/mapping_helpers/airlock/access/all/medical/general/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_MEDICAL
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/medical/morgue/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_MORGUE
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/medical/chemistry/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CHEMISTRY
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/medical/virology/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_VIROLOGY
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/medical/surgery/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_SURGERY
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/medical/cmo/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CMO
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/medical/pharmacy/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_PHARMACY
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/medical/psychology/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_PSYCHOLOGY
	return access_list

// -------------------- Science access helpers
/obj/effect/mapping_helpers/airlock/access/all/science
	icon_state = "access_helper_sci"

/obj/effect/mapping_helpers/airlock/access/all/science/general/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_RND
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/science/research/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_RESEARCH
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/science/ordnance/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_ORDNANCE
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/science/ordnance_storage/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_ORDNANCE_STORAGE
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/science/genetics/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_GENETICS
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/science/robotics/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_ROBOTICS
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/science/xenobio/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_XENOBIOLOGY
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/science/minisat/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_MINISAT
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/science/rd/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_RD
	return access_list

// -------------------- Security access helpers
/obj/effect/mapping_helpers/airlock/access/all/security
	icon_state = "access_helper_sec"

/obj/effect/mapping_helpers/airlock/access/all/security/general/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_SECURITY
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/security/entrance/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_BRIG_ENTRANCE
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/security/brig/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_BRIG
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/security/armory/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_ARMORY
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/security/detective/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_FORENSICS
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/security/court/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_COURT
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/security/hos/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_HOS
	return access_list

// -------------------- Service access helpers
/obj/effect/mapping_helpers/airlock/access/all/service
	icon_state = "access_helper_serv"

/obj/effect/mapping_helpers/airlock/access/all/service/general/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_SERVICE
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/service/kitchen/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_KITCHEN
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/service/bar/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_BAR
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/service/hydroponics/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_HYDROPONICS
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/service/janitor/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_JANITOR
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/service/chapel_office/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CHAPEL_OFFICE
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/service/crematorium/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CREMATORIUM
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/service/library/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_LIBRARY
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/service/theatre/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_THEATRE
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/service/lawyer/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_LAWYER
	return access_list

// -------------------- Supply access helpers
/obj/effect/mapping_helpers/airlock/access/all/supply
	icon_state = "access_helper_sup"

/obj/effect/mapping_helpers/airlock/access/all/supply/general/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CARGO
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/supply/mail_sorting/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_MAILSORTING
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/supply/mining/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_MINING
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/supply/mining_station/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_MINING_STATION
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/supply/mineral_storage/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_MINERAL_STOREROOM
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/supply/qm/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_QM
	return access_list

/obj/effect/mapping_helpers/airlock/access/all/supply/vault/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_VAULT
	return access_list
