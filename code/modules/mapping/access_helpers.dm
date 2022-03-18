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
			airlock.req_one_access = access_list
		else
			airlock.req_one_access_txt += ";[access_list.Join(";")]"
			airlock.req_one_access += access_list
	else
		log_mapping("[src] at [AREACOORD(src)] tried to set req_one_access, but req_access was already set!")

/obj/effect/mapping_helpers/airlock/access/all/payload(obj/machinery/door/airlock/airlock)
	if(airlock.req_one_access_txt == "0")
		if(airlock.req_access_txt == "0")
			airlock.req_access_txt = access_list.Join(";")
			airlock.req_access = access_list
		else
			airlock.req_access_txt += access_list.Join(";")
			airlock.req_access += access_list
	else
		log_mapping("[src] at [AREACOORD(src)] tried to set req_access, but req_one_access was already set!")

// -------------------- Req Any (Only requires ONE of the given accesses to open)
// -------------------- Common access helpers
/obj/effect/mapping_helpers/airlock/access/any/maintenance/Initialize()
    . = ..()
    access_list += ACCESS_MAINT_TUNNELS

// -------------------- Command access helpers
/obj/effect/mapping_helpers/airlock/access/any/command
	icon_state = "access_helper_com"

/obj/effect/mapping_helpers/airlock/access/any/command/general/Initialize()
    . = ..()
    access_list += ACCESS_HEADS

// -------------------- Engineering access helpers
/obj/effect/mapping_helpers/airlock/access/any/engineering
	icon_state = "access_helper_eng"

/obj/effect/mapping_helpers/airlock/access/any/engineering/general/Initialize()
    . = ..()
    access_list += ACCESS_MEDICAL

// -------------------- Medical access helpers
/obj/effect/mapping_helpers/airlock/access/any/medical
	icon_state = "access_helper_med"

/obj/effect/mapping_helpers/airlock/access/any/medical/general/Initialize()
    . = ..()
    access_list += ACCESS_MEDICAL

// -------------------- Science access helpers
/obj/effect/mapping_helpers/airlock/access/any/science
	icon_state = "access_helper_sci"

/obj/effect/mapping_helpers/airlock/access/any/science/general/Initialize()
    . = ..()
    access_list += ACCESS_RND

// -------------------- Security access helpers
/obj/effect/mapping_helpers/airlock/access/any/security
	icon_state = "access_helper_sec"

/obj/effect/mapping_helpers/airlock/access/any/security/general/Initialize()
    . = ..()
    access_list += ACCESS_SECURITY

/obj/effect/mapping_helpers/airlock/access/any/security/court/Initialize()
    . = ..()
    access_list += ACCESS_COURT

// -------------------- Service access helpers
/obj/effect/mapping_helpers/airlock/access/any/medical
	icon_state = "access_helper_serv"

/obj/effect/mapping_helpers/airlock/access/any/medical/general/Initialize()
    . = ..()
    access_list += ACCESS_SERVICE


// -------------------- Supply access helpers
/obj/effect/mapping_helpers/airlock/access/any/supply
	icon_state = "access_helper_sup"

/obj/effect/mapping_helpers/airlock/access/any/supply/general/Initialize()
    . = ..()
    access_list += ACCESS_CARGO


// -------------------- Req All (Requires ALL of the given accesses to open)
// -------------------- Common access helpers
/obj/effect/mapping_helpers/airlock/access/all/maintenance/Initialize()
    . = ..()
    access_list += ACCESS_MAINT_TUNNELS

// -------------------- Command access helpers
/obj/effect/mapping_helpers/airlock/access/all/command
	icon_state = "access_helper_com"

/obj/effect/mapping_helpers/airlock/access/all/command/general/Initialize()
    . = ..()
    access_list += ACCESS_HEADS

// -------------------- Engineering access helpers
/obj/effect/mapping_helpers/airlock/access/all/engineering
	icon_state = "access_helper_eng"

/obj/effect/mapping_helpers/airlock/access/all/general/engineering/Initialize()
    . = ..()
    access_list += ACCESS_MEDICAL

// -------------------- Medical access helpers
/obj/effect/mapping_helpers/airlock/access/all/medical
	icon_state = "access_helper_med"

/obj/effect/mapping_helpers/airlock/access/all/medical/general/Initialize()
    . = ..()
    access_list += ACCESS_MEDICAL

// -------------------- Science access helpers
/obj/effect/mapping_helpers/airlock/access/all/science
	icon_state = "access_helper_sci"

/obj/effect/mapping_helpers/airlock/access/all/science/general/Initialize()
    . = ..()
    access_list += ACCESS_RND

// -------------------- Security access helpers
/obj/effect/mapping_helpers/airlock/access/all/security
	icon_state = "access_helper_sec"

/obj/effect/mapping_helpers/airlock/access/all/security/general/Initialize()
    . = ..()
    access_list += ACCESS_SECURITY

// -------------------- Service access helpers
/obj/effect/mapping_helpers/airlock/access/all/medical
	icon_state = "access_helper_serv"

/obj/effect/mapping_helpers/airlock/access/all/medical/general/Initialize()
    . = ..()
    access_list += ACCESS_SERVICE


// -------------------- Supply access helpers
/obj/effect/mapping_helpers/airlock/access/all/supply
	icon_state = "access_helper_sup"

/obj/effect/mapping_helpers/airlock/access/all/supply/general/Initialize()
    . = ..()
    access_list += ACCESS_CARGO
