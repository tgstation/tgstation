#define AIRLOCK_LIGHT_POWER 1
#define AIRLOCK_LIGHT_RANGE 2
#define AIRLOCK_POWERON_LIGHT_COLOR "#3aa7c2"
#define AIRLOCK_BOLTS_LIGHT_COLOR "#c23b23"
#define AIRLOCK_ACCESS_LIGHT_COLOR "#57e69c"
#define AIRLOCK_EMERGENCY_LIGHT_COLOR "#d1d11d"
#define AIRLOCK_DENY_LIGHT_COLOR "#c23b23"
#define AIRLOCK_CLOSED	1
#define AIRLOCK_CLOSING	2
#define AIRLOCK_OPEN	3
#define AIRLOCK_OPENING	4
#define AIRLOCK_DENY	5
#define AIRLOCK_EMAG	6

/obj/machinery/door/airlock
	doorOpen = 'monkestation/sound/machines/airlock/open.ogg'
	doorClose = 'monkestation/sound/machines/airlock/close.ogg'
	doorDeni = 'sound/machines/deniedbeep.ogg'
	boltUp = 'monkestation/sound/machines/airlock/bolts_up.ogg'
	boltDown = 'monkestation/sound/machines/airlock/bolts_down.ogg'
	var/forcedOpen = 'sound/machines/airlockforced.ogg'
	var/forcedClosed = 'sound/machines/airlockforced.ogg'
	var/mutable_appearance/old_frame_overlay
	var/mutable_appearance/old_filling_overlay
	var/old_lights_overlay = ""
	var/mutable_appearance/old_panel_overlay
	var/mutable_appearance/old_weld_overlay
	var/mutable_appearance/old_damag_overlay
	var/mutable_appearance/old_sparks_overlay
	var/mutable_appearance/old_note_overlay

/obj/machinery/door/airlock/power_change()
	..()
	update_icon()

//STATION AIRLOCKS
/obj/machinery/door/airlock
	icon = 'monkestation/icons/obj/doors/airlocks/station/public.dmi'
	overlays_file = 'monkestation/icons/obj/doors/airlocks/station/overlays.dmi'
	note_overlay_file = 'monkestation/icons/obj/doors/airlocks/station/overlays.dmi'

/obj/machinery/door/airlock/command
	icon = 'monkestation/icons/obj/doors/airlocks/station/command.dmi'

/obj/machinery/door/airlock/security
	icon = 'monkestation/icons/obj/doors/airlocks/station/security.dmi'

/obj/machinery/door/airlock/engineering
	icon = 'monkestation/icons/obj/doors/airlocks/station/engineering.dmi'

/obj/machinery/door/airlock/medical
	icon = 'monkestation/icons/obj/doors/airlocks/station/medical.dmi'

/obj/machinery/door/airlock/maintenance
	icon = 'monkestation/icons/obj/doors/airlocks/station/maintenance.dmi'

/obj/machinery/door/airlock/maintenance/external
	icon = 'monkestation/icons/obj/doors/airlocks/station/maintenanceexternal.dmi'

/obj/machinery/door/airlock/mining
	icon = 'monkestation/icons/obj/doors/airlocks/station/mining.dmi'

/obj/machinery/door/airlock/atmos
	icon = 'monkestation/icons/obj/doors/airlocks/station/atmos.dmi'

/obj/machinery/door/airlock/research
	icon = 'monkestation/icons/obj/doors/airlocks/station/research.dmi'

/obj/machinery/door/airlock/freezer
	icon = 'monkestation/icons/obj/doors/airlocks/station/freezer.dmi'

/obj/machinery/door/airlock/science
	icon = 'monkestation/icons/obj/doors/airlocks/station/science.dmi'

/obj/machinery/door/airlock/virology
	icon = 'monkestation/icons/obj/doors/airlocks/station/virology.dmi'

//STATION MINERAL AIRLOCKS
/obj/machinery/door/airlock/gold
	icon = 'monkestation/icons/obj/doors/airlocks/station/gold.dmi'

/obj/machinery/door/airlock/silver
	icon = 'monkestation/icons/obj/doors/airlocks/station/silver.dmi'

/obj/machinery/door/airlock/diamond
	icon = 'monkestation/icons/obj/doors/airlocks/station/diamond.dmi'

/obj/machinery/door/airlock/uranium
	icon = 'monkestation/icons/obj/doors/airlocks/station/uranium.dmi'

/obj/machinery/door/airlock/plasma
	icon = 'monkestation/icons/obj/doors/airlocks/station/plasma.dmi'

/obj/machinery/door/airlock/bananium
	icon = 'monkestation/icons/obj/doors/airlocks/station/bananium.dmi'

/obj/machinery/door/airlock/sandstone
	icon = 'monkestation/icons/obj/doors/airlocks/station/sandstone.dmi'

/obj/machinery/door/airlock/wood
	icon = 'monkestation/icons/obj/doors/airlocks/station/wood.dmi'

//STATION 2 AIRLOCKS

/obj/machinery/door/airlock/public
	icon = 'monkestation/icons/obj/doors/airlocks/station2/glass.dmi'
	overlays_file = 'monkestation/icons/obj/doors/airlocks/station2/overlays.dmi'

//EXTERNAL AIRLOCKS
/obj/machinery/door/airlock/external
	icon = 'monkestation/icons/obj/doors/airlocks/external/external.dmi'
	overlays_file = 'monkestation/icons/obj/doors/airlocks/external/overlays.dmi'
	note_overlay_file = 'monkestation/icons/obj/doors/airlocks/external/overlays.dmi'

/obj/machinery/door/airlock/arrivals_external
	icon = 'monkestation/icons/obj/doors/airlocks/external/external.dmi'
	overlays_file = 'monkestation/icons/obj/doors/airlocks/external/overlays.dmi'
	note_overlay_file = 'monkestation/icons/obj/doors/airlocks/external/overlays.dmi'

//CENTCOMM
/obj/machinery/door/airlock/centcom
	icon = 'monkestation/icons/obj/doors/airlocks/centcom/centcom.dmi'
	overlays_file = 'monkestation/icons/obj/doors/airlocks/centcom/overlays.dmi'

/obj/machinery/door/airlock/grunge
	icon = 'monkestation/icons/obj/doors/airlocks/centcom/centcom.dmi'
	overlays_file = 'monkestation/icons/obj/doors/airlocks/centcom/overlays.dmi'

//VAULT
/obj/machinery/door/airlock/vault
	icon = 'monkestation/icons/obj/doors/airlocks/vault/vault.dmi'
	overlays_file = 'monkestation/icons/obj/doors/airlocks/vault/overlays.dmi'

//HATCH
/obj/machinery/door/airlock/hatch
	icon = 'monkestation/icons/obj/doors/airlocks/hatch/centcom.dmi'
	overlays_file = 'monkestation/icons/obj/doors/airlocks/hatch/overlays.dmi'
	note_overlay_file = 'monkestation/icons/obj/doors/airlocks/hatch/overlays.dmi'

/obj/machinery/door/airlock/maintenance_hatch
	icon = 'monkestation/icons/obj/doors/airlocks/hatch/maintenance.dmi'
	overlays_file = 'monkestation/icons/obj/doors/airlocks/hatch/overlays.dmi'
	note_overlay_file = 'monkestation/icons/obj/doors/airlocks/hatch/overlays.dmi'

//HIGH SEC
/obj/machinery/door/airlock/highsecurity
	icon = 'monkestation/icons/obj/doors/airlocks/highsec/highsec.dmi'
	overlays_file = 'monkestation/icons/obj/doors/airlocks/highsec/overlays.dmi'

//GLASS
/obj/machinery/door/airlock/glass_large
	icon = 'monkestation/icons/obj/doors/airlocks/glass_large/multi_tile.dmi'
	overlays_file = 'monkestation/icons/obj/doors/airlocks/glass_large/overlays.dmi'

//ASSEMBLYS
/obj/structure/door_assembly/door_assembly_public
	icon = 'monkestation/icons/obj/doors/airlocks/station2/glass.dmi'
	overlays_file = 'monkestation/icons/obj/doors/airlocks/station2/overlays.dmi'

/obj/structure/door_assembly/door_assembly_com
	icon = 'monkestation/icons/obj/doors/airlocks/station/command.dmi'

/obj/structure/door_assembly/door_assembly_sec
	icon = 'monkestation/icons/obj/doors/airlocks/station/security.dmi'

/obj/structure/door_assembly/door_assembly_eng
	icon = 'monkestation/icons/obj/doors/airlocks/station/engineering.dmi'

/obj/structure/door_assembly/door_assembly_min
	icon = 'monkestation/icons/obj/doors/airlocks/station/mining.dmi'

/obj/structure/door_assembly/door_assembly_atmo
	icon = 'monkestation/icons/obj/doors/airlocks/station/atmos.dmi'

/obj/structure/door_assembly/door_assembly_research
	icon = 'monkestation/icons/obj/doors/airlocks/station/research.dmi'

/obj/structure/door_assembly/door_assembly_science
	icon = 'monkestation/icons/obj/doors/airlocks/station/science.dmi'

/obj/structure/door_assembly/door_assembly_viro
	icon = 'monkestation/icons/obj/doors/airlocks/station/virology.dmi'

/obj/structure/door_assembly/door_assembly_med
	icon = 'monkestation/icons/obj/doors/airlocks/station/medical.dmi'

/obj/structure/door_assembly/door_assembly_mai
	icon = 'monkestation/icons/obj/doors/airlocks/station/maintenance.dmi'

/obj/structure/door_assembly/door_assembly_extmai
	icon = 'monkestation/icons/obj/doors/airlocks/station/maintenanceexternal.dmi'

/obj/structure/door_assembly/door_assembly_ext
	icon = 'monkestation/icons/obj/doors/airlocks/external/external.dmi'
	overlays_file = 'monkestation/icons/obj/doors/airlocks/external/overlays.dmi'

/obj/structure/door_assembly/door_assembly_fre
	icon = 'monkestation/icons/obj/doors/airlocks/station/freezer.dmi'

/obj/structure/door_assembly/door_assembly_hatch
	icon = 'monkestation/icons/obj/doors/airlocks/hatch/centcom.dmi'
	overlays_file = 'monkestation/icons/obj/doors/airlocks/hatch/overlays.dmi'

/obj/structure/door_assembly/door_assembly_mhatch
	icon = 'monkestation/icons/obj/doors/airlocks/hatch/maintenance.dmi'
	overlays_file = 'monkestation/icons/obj/doors/airlocks/hatch/overlays.dmi'

/obj/structure/door_assembly/door_assembly_highsecurity
	icon = 'monkestation/icons/obj/doors/airlocks/highsec/highsec.dmi'
	overlays_file = 'monkestation/icons/obj/doors/airlocks/highsec/overlays.dmi'

/obj/structure/door_assembly/door_assembly_vault
	icon = 'monkestation/icons/obj/doors/airlocks/vault/vault.dmi'
	overlays_file = 'monkestation/icons/obj/doors/airlocks/vault/overlays.dmi'


/obj/structure/door_assembly/door_assembly_centcom
	icon = 'monkestation/icons/obj/doors/airlocks/centcom/centcom.dmi'
	overlays_file = 'monkestation/icons/obj/doors/airlocks/centcom/overlays.dmi'

/obj/structure/door_assembly/door_assembly_grunge
	icon = 'monkestation/icons/obj/doors/airlocks/centcom/centcom.dmi'
	overlays_file = 'monkestation/icons/obj/doors/airlocks/centcom/overlays.dmi'

/obj/structure/door_assembly/door_assembly_gold
	icon = 'monkestation/icons/obj/doors/airlocks/station/gold.dmi'

/obj/structure/door_assembly/door_assembly_silver
	icon = 'monkestation/icons/obj/doors/airlocks/station/silver.dmi'

/obj/structure/door_assembly/door_assembly_diamond
	icon = 'monkestation/icons/obj/doors/airlocks/station/diamond.dmi'

/obj/structure/door_assembly/door_assembly_uranium
	icon = 'monkestation/icons/obj/doors/airlocks/station/uranium.dmi'

/obj/structure/door_assembly/door_assembly_plasma
	icon = 'monkestation/icons/obj/doors/airlocks/station/plasma.dmi'

/obj/structure/door_assembly/door_assembly_bananium
	icon = 'monkestation/icons/obj/doors/airlocks/station/bananium.dmi'

/obj/structure/door_assembly/door_assembly_sandstone
	icon = 'monkestation/icons/obj/doors/airlocks/station/sandstone.dmi'

/obj/structure/door_assembly/door_assembly_wood
	icon = 'monkestation/icons/obj/doors/airlocks/station/wood.dmi'

#undef AIRLOCK_LIGHT_POWER
#undef AIRLOCK_LIGHT_RANGE

#undef AIRLOCK_POWERON_LIGHT_COLOR
#undef AIRLOCK_BOLTS_LIGHT_COLOR
#undef AIRLOCK_ACCESS_LIGHT_COLOR
#undef AIRLOCK_EMERGENCY_LIGHT_COLOR
#undef AIRLOCK_DENY_LIGHT_COLOR

#undef AIRLOCK_CLOSED
#undef AIRLOCK_CLOSING
#undef AIRLOCK_OPEN
#undef AIRLOCK_OPENING
#undef AIRLOCK_DENY
#undef AIRLOCK_EMAG
