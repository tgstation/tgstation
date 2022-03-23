/obj/effect/mapping_helpers/airlock/access
	layer = DOOR_HELPER_LAYER
	icon_state = "access_helper"
	var/list/access_list = list()

// These are mutually exclusive; can't have req_any and req_all
/obj/effect/mapping_helpers/airlock/access/any/payload(obj/machinery/door/airlock/airlock)
	if(airlock.req_access_txt == "0")
		// Overwrite if there is no access set, otherwise add onto existing access
		if(airlock.req_one_access_txt == "0")
			airlock.req_one_access_txt = access_list.Join(";")
		else
			airlock.req_one_access_txt += ";[access_list.Join(";")]"
	else
		log_mapping("[src] at [AREACOORD(src)] tried to set req_one_access, but req_access was already set!")

/obj/effect/mapping_helpers/airlock/access/all/payload(obj/machinery/door/airlock/airlock)
	if(airlock.req_one_access_txt == "0")
		if(airlock.req_access_txt == "0")
			airlock.req_access_txt = access_list.Join(";")
		else
			airlock.req_access_txt += ";[access_list.Join(";")]"
	else
		log_mapping("[src] at [AREACOORD(src)] tried to set req_access, but req_one_access was already set!")

// -------------------- Req Any (Only requires ONE of the given accesses to open)
// -------------------- Command access helpers
/obj/effect/mapping_helpers/airlock/access/any/command
	icon_state = "access_helper_com"

/obj/effect/mapping_helpers/airlock/access/any/command/general/Initialize()
	. = ..()
	access_list += ACCESS_HEADS

/obj/effect/mapping_helpers/airlock/access/any/command/ai_upload/Initialize()
	. = ..()
	access_list += ACCESS_AI_UPLOAD

/obj/effect/mapping_helpers/airlock/access/any/command/teleporter/Initialize()
	. = ..()
	access_list += ACCESS_TELEPORTER

/obj/effect/mapping_helpers/airlock/access/any/command/eva/Initialize()
	. = ..()
	access_list += ACCESS_EVA

/obj/effect/mapping_helpers/airlock/access/any/command/gateway/Initialize()
	. = ..()
	access_list += ACCESS_GATEWAY

/obj/effect/mapping_helpers/airlock/access/any/command/hop/Initialize()
	. = ..()
	access_list += ACCESS_HOP

/obj/effect/mapping_helpers/airlock/access/any/command/captain/Initialize()
	. = ..()
	access_list += ACCESS_CAPTAIN

// -------------------- Engineering access helpers
/obj/effect/mapping_helpers/airlock/access/any/engineering
	icon_state = "access_helper_eng"

/obj/effect/mapping_helpers/airlock/access/any/engineering/general/Initialize()
	. = ..()
	access_list += ACCESS_ENGINE

/obj/effect/mapping_helpers/airlock/access/any/engineering/construction/Initialize()
	. = ..()
	access_list += ACCESS_CONSTRUCTION

/obj/effect/mapping_helpers/airlock/access/any/engineering/aux_base/Initialize()
	. = ..()
	access_list += ACCESS_AUX_BASE

/obj/effect/mapping_helpers/airlock/access/any/engineering/maintenance/Initialize()
	. = ..()
	access_list += ACCESS_MAINT_TUNNELS

/obj/effect/mapping_helpers/airlock/access/any/engineering/external/Initialize()
	. = ..()
	access_list += ACCESS_EXTERNAL_AIRLOCKS

/obj/effect/mapping_helpers/airlock/access/any/engineering/tech_storage/Initialize()
	. = ..()
	access_list += ACCESS_TECH_STORAGE

/obj/effect/mapping_helpers/airlock/access/any/engineering/atmos/Initialize()
	. = ..()
	access_list += ACCESS_ATMOSPHERICS

/obj/effect/mapping_helpers/airlock/access/any/engineering/tcoms/Initialize()
	. = ..()
	access_list += ACCESS_TCOMSAT

/obj/effect/mapping_helpers/airlock/access/any/engineering/ce/Initialize()
	. = ..()
	access_list += ACCESS_CE

// -------------------- Medical access helpers
/obj/effect/mapping_helpers/airlock/access/any/medical
	icon_state = "access_helper_med"

/obj/effect/mapping_helpers/airlock/access/any/medical/general/Initialize()
	. = ..()
	access_list += ACCESS_MEDICAL

/obj/effect/mapping_helpers/airlock/access/any/medical/morgue/Initialize()
	. = ..()
	access_list += ACCESS_MORGUE

/obj/effect/mapping_helpers/airlock/access/any/medical/chemistry/Initialize()
	. = ..()
	access_list += ACCESS_CHEMISTRY

/obj/effect/mapping_helpers/airlock/access/any/medical/virology/Initialize()
	. = ..()
	access_list += ACCESS_VIROLOGY

/obj/effect/mapping_helpers/airlock/access/any/medical/surgery/Initialize()
	. = ..()
	access_list += ACCESS_SURGERY

/obj/effect/mapping_helpers/airlock/access/any/medical/cmo/Initialize()
	. = ..()
	access_list += ACCESS_CMO

/obj/effect/mapping_helpers/airlock/access/any/medical/pharmacy/Initialize()
	. = ..()
	access_list += ACCESS_PHARMACY

/obj/effect/mapping_helpers/airlock/access/any/medical/psychology/Initialize()
	. = ..()
	access_list += ACCESS_PSYCHOLOGY

// -------------------- Science access helpers
/obj/effect/mapping_helpers/airlock/access/any/science
	icon_state = "access_helper_sci"

/obj/effect/mapping_helpers/airlock/access/any/science/general/Initialize()
	. = ..()
	access_list += ACCESS_RND

/obj/effect/mapping_helpers/airlock/access/any/science/research/Initialize()
	. = ..()
	access_list += ACCESS_RESEARCH

/obj/effect/mapping_helpers/airlock/access/any/science/ordnance/Initialize()
	. = ..()
	access_list += ACCESS_ORDNANCE

/obj/effect/mapping_helpers/airlock/access/any/science/ordnance_storage/Initialize()
	. = ..()
	access_list += ACCESS_ORDNANCE_STORAGE

/obj/effect/mapping_helpers/airlock/access/any/science/genetics/Initialize()
	. = ..()
	access_list += ACCESS_GENETICS

/obj/effect/mapping_helpers/airlock/access/any/science/robotics/Initialize()
	. = ..()
	access_list += ACCESS_ROBOTICS

/obj/effect/mapping_helpers/airlock/access/any/science/xenobio/Initialize()
	. = ..()
	access_list += ACCESS_XENOBIOLOGY

/obj/effect/mapping_helpers/airlock/access/any/science/minisat/Initialize()
	. = ..()
	access_list += ACCESS_MINISAT

/obj/effect/mapping_helpers/airlock/access/any/science/rd/Initialize()
	. = ..()
	access_list += ACCESS_RD

// -------------------- Security access helpers
/obj/effect/mapping_helpers/airlock/access/any/security
	icon_state = "access_helper_sec"

/obj/effect/mapping_helpers/airlock/access/any/security/general/Initialize()
	. = ..()
	access_list += ACCESS_SECURITY

/obj/effect/mapping_helpers/airlock/access/any/security/doors/Initialize()
	. = ..()
	access_list += ACCESS_SEC_DOORS

/obj/effect/mapping_helpers/airlock/access/any/security/brig/Initialize()
	. = ..()
	access_list += ACCESS_BRIG

/obj/effect/mapping_helpers/airlock/access/any/security/armory/Initialize()
	. = ..()
	access_list += ACCESS_ARMORY

/obj/effect/mapping_helpers/airlock/access/any/security/court/Initialize()
	. = ..()
	access_list += ACCESS_COURT

/obj/effect/mapping_helpers/airlock/access/any/security/hos/Initialize()
	. = ..()
	access_list += ACCESS_HOS

// -------------------- Service access helpers
/obj/effect/mapping_helpers/airlock/access/any/service
	icon_state = "access_helper_serv"

/obj/effect/mapping_helpers/airlock/access/any/service/general/Initialize()
	. = ..()
	access_list += ACCESS_SERVICE

/obj/effect/mapping_helpers/airlock/access/any/service/kitchen/Initialize()
	. = ..()
	access_list += ACCESS_KITCHEN

/obj/effect/mapping_helpers/airlock/access/any/service/bar/Initialize()
	. = ..()
	access_list += ACCESS_BAR

/obj/effect/mapping_helpers/airlock/access/any/service/hydroponics/Initialize()
	. = ..()
	access_list += ACCESS_HYDROPONICS

/obj/effect/mapping_helpers/airlock/access/any/service/janitor/Initialize()
	. = ..()
	access_list += ACCESS_JANITOR

/obj/effect/mapping_helpers/airlock/access/any/service/chapel_office/Initialize()
	. = ..()
	access_list += ACCESS_CHAPEL_OFFICE

/obj/effect/mapping_helpers/airlock/access/any/service/crematorium/Initialize()
	. = ..()
	access_list += ACCESS_CREMATORIUM

/obj/effect/mapping_helpers/airlock/access/any/service/crematorium/Initialize()
	. = ..()
	access_list += ACCESS_CREMATORIUM

/obj/effect/mapping_helpers/airlock/access/any/service/library/Initialize()
	. = ..()
	access_list += ACCESS_LIBRARY

/obj/effect/mapping_helpers/airlock/access/any/service/library/Initialize()
	. = ..()
	access_list += ACCESS_THEATRE

/obj/effect/mapping_helpers/airlock/access/any/service/lawyer/Initialize()
	. = ..()
	access_list += ACCESS_LAWYER

// -------------------- Supply access helpers
/obj/effect/mapping_helpers/airlock/access/any/supply
	icon_state = "access_helper_sup"

/obj/effect/mapping_helpers/airlock/access/any/supply/general/Initialize()
	. = ..()
	access_list += ACCESS_CARGO

/obj/effect/mapping_helpers/airlock/access/any/supply/mail_sorting/Initialize()
	. = ..()
	access_list += ACCESS_MAILSORTING

/obj/effect/mapping_helpers/airlock/access/any/supply/mining/Initialize()
	. = ..()
	access_list += ACCESS_MINING

/obj/effect/mapping_helpers/airlock/access/any/supply/mining_station/Initialize()
	. = ..()
	access_list += ACCESS_MINING_STATION

/obj/effect/mapping_helpers/airlock/access/any/supply/mineral_storage/Initialize()
	. = ..()
	access_list += ACCESS_MINERAL_STOREROOM

/obj/effect/mapping_helpers/airlock/access/any/supply/qm/Initialize()
	. = ..()
	access_list += ACCESS_QM

/obj/effect/mapping_helpers/airlock/access/any/supply/vault/Initialize()
	. = ..()
	access_list += ACCESS_VAULT

// -------------------- Req All (Requires ALL of the given accesses to open)
// -------------------- Command access helpers
/obj/effect/mapping_helpers/airlock/access/all/command
	icon_state = "access_helper_com"

/obj/effect/mapping_helpers/airlock/access/all/command/general/Initialize()
	. = ..()
	access_list += ACCESS_HEADS

/obj/effect/mapping_helpers/airlock/access/all/command/ai_upload/Initialize()
	. = ..()
	access_list += ACCESS_AI_UPLOAD

/obj/effect/mapping_helpers/airlock/access/all/command/teleporter/Initialize()
	. = ..()
	access_list += ACCESS_TELEPORTER

/obj/effect/mapping_helpers/airlock/access/all/command/eva/Initialize()
	. = ..()
	access_list += ACCESS_EVA

/obj/effect/mapping_helpers/airlock/access/all/command/gateway/Initialize()
	. = ..()
	access_list += ACCESS_GATEWAY

/obj/effect/mapping_helpers/airlock/access/all/command/hop/Initialize()
	. = ..()
	access_list += ACCESS_HOP

/obj/effect/mapping_helpers/airlock/access/all/command/captain/Initialize()
	. = ..()
	access_list += ACCESS_CAPTAIN

// -------------------- Engineering access helpers
/obj/effect/mapping_helpers/airlock/access/all/engineering
	icon_state = "access_helper_eng"

/obj/effect/mapping_helpers/airlock/access/all/engineering/general/Initialize()
	. = ..()
	access_list += ACCESS_ENGINE

/obj/effect/mapping_helpers/airlock/access/all/engineering/construction/Initialize()
	. = ..()
	access_list += ACCESS_CONSTRUCTION

/obj/effect/mapping_helpers/airlock/access/all/engineering/aux_base/Initialize()
	. = ..()
	access_list += ACCESS_AUX_BASE

/obj/effect/mapping_helpers/airlock/access/all/engineering/maintenance/Initialize()
	. = ..()
	access_list += ACCESS_MAINT_TUNNELS

/obj/effect/mapping_helpers/airlock/access/all/engineering/external/Initialize()
	. = ..()
	access_list += ACCESS_EXTERNAL_AIRLOCKS

/obj/effect/mapping_helpers/airlock/access/all/engineering/tech_storage/Initialize()
	. = ..()
	access_list += ACCESS_TECH_STORAGE

/obj/effect/mapping_helpers/airlock/access/all/engineering/atmos/Initialize()
	. = ..()
	access_list += ACCESS_ATMOSPHERICS

/obj/effect/mapping_helpers/airlock/access/all/engineering/tcoms/Initialize()
	. = ..()
	access_list += ACCESS_TCOMSAT

/obj/effect/mapping_helpers/airlock/access/all/engineering/ce/Initialize()
	. = ..()
	access_list += ACCESS_CE

// -------------------- Medical access helpers
/obj/effect/mapping_helpers/airlock/access/all/medical
	icon_state = "access_helper_med"

/obj/effect/mapping_helpers/airlock/access/all/medical/general/Initialize()
	. = ..()
	access_list += ACCESS_MEDICAL

/obj/effect/mapping_helpers/airlock/access/all/medical/morgue/Initialize()
	. = ..()
	access_list += ACCESS_MORGUE

/obj/effect/mapping_helpers/airlock/access/all/medical/chemistry/Initialize()
	. = ..()
	access_list += ACCESS_CHEMISTRY

/obj/effect/mapping_helpers/airlock/access/all/medical/virology/Initialize()
	. = ..()
	access_list += ACCESS_VIROLOGY

/obj/effect/mapping_helpers/airlock/access/all/medical/surgery/Initialize()
	. = ..()
	access_list += ACCESS_SURGERY

/obj/effect/mapping_helpers/airlock/access/all/medical/cmo/Initialize()
	. = ..()
	access_list += ACCESS_CMO

/obj/effect/mapping_helpers/airlock/access/all/medical/pharmacy/Initialize()
	. = ..()
	access_list += ACCESS_PHARMACY

/obj/effect/mapping_helpers/airlock/access/all/medical/psychology/Initialize()
	. = ..()
	access_list += ACCESS_PSYCHOLOGY

// -------------------- Science access helpers
/obj/effect/mapping_helpers/airlock/access/all/science
	icon_state = "access_helper_sci"

/obj/effect/mapping_helpers/airlock/access/all/science/general/Initialize()
	. = ..()
	access_list += ACCESS_RND

/obj/effect/mapping_helpers/airlock/access/all/science/research/Initialize()
	. = ..()
	access_list += ACCESS_RESEARCH

/obj/effect/mapping_helpers/airlock/access/all/science/ordnance/Initialize()
	. = ..()
	access_list += ACCESS_ORDNANCE

/obj/effect/mapping_helpers/airlock/access/all/science/ordnance_storage/Initialize()
	. = ..()
	access_list += ACCESS_ORDNANCE_STORAGE

/obj/effect/mapping_helpers/airlock/access/all/science/genetics/Initialize()
	. = ..()
	access_list += ACCESS_GENETICS

/obj/effect/mapping_helpers/airlock/access/all/science/robotics/Initialize()
	. = ..()
	access_list += ACCESS_ROBOTICS

/obj/effect/mapping_helpers/airlock/access/all/science/xenobio/Initialize()
	. = ..()
	access_list += ACCESS_XENOBIOLOGY

/obj/effect/mapping_helpers/airlock/access/all/science/minisat/Initialize()
	. = ..()
	access_list += ACCESS_MINISAT

/obj/effect/mapping_helpers/airlock/access/all/science/rd/Initialize()
	. = ..()
	access_list += ACCESS_RD

// -------------------- Security access helpers
/obj/effect/mapping_helpers/airlock/access/all/security
	icon_state = "access_helper_sec"

/obj/effect/mapping_helpers/airlock/access/all/security/general/Initialize()
	. = ..()
	access_list += ACCESS_SECURITY

/obj/effect/mapping_helpers/airlock/access/all/security/doors/Initialize()
	. = ..()
	access_list += ACCESS_SEC_DOORS

/obj/effect/mapping_helpers/airlock/access/all/security/brig/Initialize()
	. = ..()
	access_list += ACCESS_BRIG

/obj/effect/mapping_helpers/airlock/access/all/security/armory/Initialize()
	. = ..()
	access_list += ACCESS_ARMORY

/obj/effect/mapping_helpers/airlock/access/all/security/court/Initialize()
	. = ..()
	access_list += ACCESS_COURT

/obj/effect/mapping_helpers/airlock/access/all/security/hos/Initialize()
	. = ..()
	access_list += ACCESS_HOS

// -------------------- Service access helpers
/obj/effect/mapping_helpers/airlock/access/all/service
	icon_state = "access_helper_serv"

/obj/effect/mapping_helpers/airlock/access/all/service/general/Initialize()
	. = ..()
	access_list += ACCESS_SERVICE

/obj/effect/mapping_helpers/airlock/access/all/service/kitchen/Initialize()
	. = ..()
	access_list += ACCESS_KITCHEN

/obj/effect/mapping_helpers/airlock/access/all/service/bar/Initialize()
	. = ..()
	access_list += ACCESS_BAR

/obj/effect/mapping_helpers/airlock/access/all/service/hydroponics/Initialize()
	. = ..()
	access_list += ACCESS_HYDROPONICS

/obj/effect/mapping_helpers/airlock/access/all/service/janitor/Initialize()
	. = ..()
	access_list += ACCESS_JANITOR

/obj/effect/mapping_helpers/airlock/access/all/service/chapel_office/Initialize()
	. = ..()
	access_list += ACCESS_CHAPEL_OFFICE

/obj/effect/mapping_helpers/airlock/access/all/service/crematorium/Initialize()
	. = ..()
	access_list += ACCESS_CREMATORIUM

/obj/effect/mapping_helpers/airlock/access/all/service/crematorium/Initialize()
	. = ..()
	access_list += ACCESS_CREMATORIUM

/obj/effect/mapping_helpers/airlock/access/all/service/library/Initialize()
	. = ..()
	access_list += ACCESS_LIBRARY

/obj/effect/mapping_helpers/airlock/access/all/service/library/Initialize()
	. = ..()
	access_list += ACCESS_THEATRE

/obj/effect/mapping_helpers/airlock/access/all/service/lawyer/Initialize()
	. = ..()
	access_list += ACCESS_LAWYER

// -------------------- Supply access helpers
/obj/effect/mapping_helpers/airlock/access/all/supply
	icon_state = "access_helper_sup"

/obj/effect/mapping_helpers/airlock/access/all/supply/general/Initialize()
	. = ..()
	access_list += ACCESS_CARGO

/obj/effect/mapping_helpers/airlock/access/all/supply/mail_sorting/Initialize()
	. = ..()
	access_list += ACCESS_MAILSORTING

/obj/effect/mapping_helpers/airlock/access/all/supply/mining/Initialize()
	. = ..()
	access_list += ACCESS_MINING

/obj/effect/mapping_helpers/airlock/access/all/supply/mining_station/Initialize()
	. = ..()
	access_list += ACCESS_MINING_STATION

/obj/effect/mapping_helpers/airlock/access/all/supply/mineral_storage/Initialize()
	. = ..()
	access_list += ACCESS_MINERAL_STOREROOM

/obj/effect/mapping_helpers/airlock/access/all/supply/qm/Initialize()
	. = ..()
	access_list += ACCESS_QM

/obj/effect/mapping_helpers/airlock/access/all/supply/vault/Initialize()
	. = ..()
	access_list += ACCESS_VAULT
