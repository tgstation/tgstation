//SKYRAT ADDITION BEGIN - AESTHETICS
#define AIRLOCK_LIGHT_POWER 1
#define AIRLOCK_LIGHT_RANGE 2
#define AIRLOCK_POWERON_LIGHT_COLOR "#3aa7c2"
#define AIRLOCK_BOLTS_LIGHT_COLOR "#c23b23"
#define AIRLOCK_ACCESS_LIGHT_COLOR "#57e69c"
#define AIRLOCK_EMERGENCY_LIGHT_COLOR "#d1d11d"
#define AIRLOCK_DENY_LIGHT_COLOR "#c23b23"
//SKYRAT ADDITION END
#define AIRLOCK_CLOSED	1
#define AIRLOCK_CLOSING	2
#define AIRLOCK_OPEN	3
#define AIRLOCK_OPENING	4
#define AIRLOCK_DENY	5
#define AIRLOCK_EMAG	6

/obj/machinery/door/airlock
	var/obj/effect/overlay/vis_airlock/vis_overlay1
	var/obj/effect/overlay/vis_airlock/vis_overlay2
	doorOpen = 'modular_skyrat/modules/aesthetics/airlock/sound/open.ogg'
	doorClose = 'modular_skyrat/modules/aesthetics/airlock/sound/close.ogg'
	doorDeni = 'modular_skyrat/modules/aesthetics/airlock/sound/access_denied.ogg'
	boltUp = 'modular_skyrat/modules/aesthetics/airlock/sound/bolts_up.ogg'
	boltDown = 'modular_skyrat/modules/aesthetics/airlock/sound/bolts_down.ogg'
	//noPower = 'sound/machines/doorclick.ogg'
	var/forcedOpen = 'modular_skyrat/modules/aesthetics/airlock/sound/open_force.ogg' //Come on guys, why aren't all the sound files like this.
	var/forcedClosed = 'modular_skyrat/modules/aesthetics/airlock/sound/close_force.ogg'

/obj/machinery/door/airlock/Initialize()
	//overlay2
	vis_overlay1 = new()
	vis_overlay1.icon = overlays_file
	//overlay1
	vis_overlay2 = new()
	vis_overlay2.icon = overlays_file
	vis_overlay2.layer = layer
	vis_overlay2.plane = 1
	vis_contents += vis_overlay1
	vis_contents += vis_overlay2
	set_airlock_overlays()
	. = ..()

/obj/effect/overlay/vis_airlock
	layer = EMISSIVE_LAYER
	plane = EMISSIVE_PLANE
	vis_flags = VIS_INHERIT_ID

/obj/machinery/door/airlock/Destroy()
	. = ..()
	vis_contents -= vis_overlay1
	vis_contents -= vis_overlay2
	QDEL_NULL(vis_overlay1)
	QDEL_NULL(vis_overlay2)

/obj/machinery/door/airlock/power_change()
	..()
	update_icon()

/obj/machinery/door/airlock/proc/set_airlock_overlays(state)
	var/mutable_appearance/frame_overlay
	var/mutable_appearance/filling_overlay
	var/lights_overlay = ""
	var/mutable_appearance/panel_overlay
	var/mutable_appearance/weld_overlay
	var/mutable_appearance/damag_overlay
	var/mutable_appearance/sparks_overlay
	var/mutable_appearance/note_overlay
	var/mutable_appearance/seal_overlay

	var/notetype = note_type()
	var/pre_light_range = 0
	var/pre_light_power = 0
	var/pre_light_color = ""

	switch(state)
		if(AIRLOCK_CLOSED)
			frame_overlay = get_airlock_overlay("closed", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closed", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closed", icon)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_closed_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_closed", overlays_file)
			if(welded)
				weld_overlay = get_airlock_overlay("welded", overlays_file)
			if(seal)
				seal_overlay = get_airlock_overlay("sealed", overlays_file)
			if(obj_integrity < integrity_failure * max_integrity)
				damag_overlay = get_airlock_overlay("sparks_broken", overlays_file)
			else if(obj_integrity < (0.75 * max_integrity))
				damag_overlay = get_airlock_overlay("sparks_damaged", overlays_file)
			if(lights && hasPower())
				pre_light_range = AIRLOCK_LIGHT_RANGE
				pre_light_power = AIRLOCK_LIGHT_POWER
				if(locked)
					lights_overlay = "lights_bolts"
					pre_light_color = AIRLOCK_BOLTS_LIGHT_COLOR
				else if(emergency)
					lights_overlay = "lights_emergency"
					pre_light_color = AIRLOCK_EMERGENCY_LIGHT_COLOR
				else
					lights_overlay = "lights_poweron"
					pre_light_color = AIRLOCK_POWERON_LIGHT_COLOR
			if(note)
				note_overlay = get_airlock_overlay(notetype, note_overlay_file)

		if(AIRLOCK_DENY)
			if(!hasPower())
				return
			frame_overlay = get_airlock_overlay("closed", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closed", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closed", icon)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_closed_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_closed", overlays_file)
			if(obj_integrity < integrity_failure * max_integrity)
				damag_overlay = get_airlock_overlay("sparks_broken", overlays_file)
			else if(obj_integrity < (0.75 * max_integrity))
				damag_overlay = get_airlock_overlay("sparks_damaged", overlays_file)
			if(welded)
				weld_overlay = get_airlock_overlay("welded", overlays_file)
			if(seal)
				seal_overlay = get_airlock_overlay("sealed", overlays_file)
			if(lights && hasPower())
				pre_light_range = AIRLOCK_LIGHT_RANGE
				pre_light_power = AIRLOCK_LIGHT_POWER
				lights_overlay = "lights_denied"
				pre_light_color = AIRLOCK_DENY_LIGHT_COLOR
			if(note)
				note_overlay = get_airlock_overlay(notetype, note_overlay_file)

		if(AIRLOCK_EMAG)
			frame_overlay = get_airlock_overlay("closed", icon)
			sparks_overlay = get_airlock_overlay("sparks", overlays_file)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closed", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closed", icon)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_closed_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_closed", overlays_file)
			if(obj_integrity < integrity_failure * max_integrity)
				damag_overlay = get_airlock_overlay("sparks_broken", overlays_file)
			else if(obj_integrity < (0.75 * max_integrity))
				damag_overlay = get_airlock_overlay("sparks_damaged", overlays_file)
			if(welded)
				weld_overlay = get_airlock_overlay("welded", overlays_file)
			if(seal)
				seal_overlay = get_airlock_overlay("sealed", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay(notetype, note_overlay_file)

		if(AIRLOCK_OPEN)
			frame_overlay = get_airlock_overlay("open", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_open", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_open", icon)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_open_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_open", overlays_file)
			if(obj_integrity < (0.75 * max_integrity))
				damag_overlay = get_airlock_overlay("sparks_open", overlays_file)
			if(lights && hasPower())
				pre_light_range = AIRLOCK_LIGHT_RANGE
				pre_light_power = AIRLOCK_LIGHT_POWER
				if(locked)
					lights_overlay = "lights_bolts_open"
					pre_light_color = AIRLOCK_BOLTS_LIGHT_COLOR
				else if(emergency)
					lights_overlay = "lights_emergency_open"
					pre_light_color = AIRLOCK_EMERGENCY_LIGHT_COLOR
				else
					lights_overlay = "lights_poweron_open"
					pre_light_color = AIRLOCK_POWERON_LIGHT_COLOR
			if(note)
				note_overlay = get_airlock_overlay("[notetype]_open", note_overlay_file)

		if(AIRLOCK_CLOSING)
			frame_overlay = get_airlock_overlay("closing", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closing", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closing", icon)
			if(lights && hasPower())
				pre_light_range = AIRLOCK_LIGHT_RANGE
				pre_light_power = AIRLOCK_LIGHT_POWER
				//lights_overlay = get_airlock_overlay("lights_opening", overlays_file)
				lights_overlay = "lights_closing"
				pre_light_color = AIRLOCK_ACCESS_LIGHT_COLOR
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_closing_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_closing", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay("[notetype]_closing", note_overlay_file)

		if(AIRLOCK_OPENING)
			frame_overlay = get_airlock_overlay("opening", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_opening", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_opening", icon)
			if(lights && hasPower())
				pre_light_range = AIRLOCK_LIGHT_RANGE
				pre_light_power = AIRLOCK_LIGHT_POWER
				//lights_overlay = get_airlock_overlay("lights_opening", overlays_file)
				lights_overlay = "lights_opening"
				pre_light_color = AIRLOCK_ACCESS_LIGHT_COLOR
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_opening_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_opening", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay("[notetype]_opening", note_overlay_file)

	cut_overlays()
	set_light(pre_light_range, pre_light_power, pre_light_color)
	add_overlay(frame_overlay)
	add_overlay(filling_overlay)
	add_overlay(panel_overlay)
	add_overlay(weld_overlay)
	add_overlay(damag_overlay)
	add_overlay(note_overlay)
	add_overlay(seal_overlay)
	add_overlay(sparks_overlay)
	update_vis_overlays(lights_overlay)
	check_unres()


/obj/machinery/door/airlock/proc/update_vis_overlays(overlay_state)
	vis_overlay1.icon_state = overlay_state
	vis_overlay2.icon_state = overlay_state


//STATION AIRLOCKS
/obj/machinery/door/airlock
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/public.dmi'
	overlays_file = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/overlays.dmi'
	note_overlay_file = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/overlays.dmi'

/obj/machinery/door/airlock/command
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/command.dmi'

/obj/machinery/door/airlock/security
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/security.dmi'

/obj/machinery/door/airlock/engineering
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/engineering.dmi'

/obj/machinery/door/airlock/medical
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/medical.dmi'

/obj/machinery/door/airlock/maintenance
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/maintenance.dmi'

/obj/machinery/door/airlock/maintenance/external
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/maintenanceexternal.dmi'

/obj/machinery/door/airlock/mining
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/mining.dmi'

/obj/machinery/door/airlock/atmos
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/atmos.dmi'

/obj/machinery/door/airlock/research
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/research.dmi'

/obj/machinery/door/airlock/freezer
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/freezer.dmi'

/obj/machinery/door/airlock/science
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/science.dmi'

/obj/machinery/door/airlock/virology
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/virology.dmi'

//STATION MINERAL AIRLOCKS
/obj/machinery/door/airlock/gold
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/gold.dmi'

/obj/machinery/door/airlock/silver
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/silver.dmi'

/obj/machinery/door/airlock/diamond
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/diamond.dmi'

/obj/machinery/door/airlock/uranium
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/uranium.dmi'

/obj/machinery/door/airlock/plasma
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/plasma.dmi'

/obj/machinery/door/airlock/bananium
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/bananium.dmi'

/obj/machinery/door/airlock/sandstone
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/sandstone.dmi'

/obj/machinery/door/airlock/wood
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/wood.dmi'

//STATION 2 AIRLOCKS

/obj/machinery/door/airlock/public
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station2/glass.dmi'
	overlays_file = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station2/overlays.dmi'

//EXTERNAL AIRLOCKS
/obj/machinery/door/airlock/external
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/external/external.dmi'
	overlays_file = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/external/overlays.dmi'
	note_overlay_file = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/external/overlays.dmi'

//CENTCOMM
/obj/machinery/door/airlock/centcom
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/centcom/centcom.dmi'
	overlays_file = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/centcom/overlays.dmi'

/obj/machinery/door/airlock/grunge
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/centcom/centcom.dmi'
	overlays_file = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/centcom/overlays.dmi'

//VAULT
/obj/machinery/door/airlock/vault
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/vault/vault.dmi'
	overlays_file = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/vault/overlays.dmi'

//HATCH
/obj/machinery/door/airlock/hatch
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/hatch/centcom.dmi'
	overlays_file = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/hatch/overlays.dmi'
	note_overlay_file = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/hatch/overlays.dmi'

/obj/machinery/door/airlock/maintenance_hatch
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/hatch/maintenance.dmi'
	overlays_file = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/hatch/overlays.dmi'
	note_overlay_file = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/hatch/overlays.dmi'

//HIGH SEC
/obj/machinery/door/airlock/highsecurity
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/highsec/highsec.dmi'
	overlays_file = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/highsec/overlays.dmi'

//GLASS
/obj/machinery/door/airlock/glass_large
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/multi_tile/multi_tile.dmi'
	overlays_file = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/multi_tile/overlays.dmi'

//ASSEMBLYS
/obj/structure/door_assembly/door_assembly_public
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station2/glass.dmi'
	overlays_file = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station2/overlays.dmi'

/obj/structure/door_assembly/door_assembly_com
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/command.dmi'

/obj/structure/door_assembly/door_assembly_sec
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/security.dmi'

/obj/structure/door_assembly/door_assembly_eng
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/engineering.dmi'

/obj/structure/door_assembly/door_assembly_min
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/mining.dmi'

/obj/structure/door_assembly/door_assembly_atmo
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/atmos.dmi'

/obj/structure/door_assembly/door_assembly_research
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/research.dmi'

/obj/structure/door_assembly/door_assembly_science
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/science.dmi'

/obj/structure/door_assembly/door_assembly_viro
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/virology.dmi'

/obj/structure/door_assembly/door_assembly_med
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/medical.dmi'

/obj/structure/door_assembly/door_assembly_mai
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/maintenance.dmi'

/obj/structure/door_assembly/door_assembly_extmai
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/maintenanceexternal.dmi'

/obj/structure/door_assembly/door_assembly_ext
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/external/external.dmi'
	overlays_file = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/external/overlays.dmi'

/obj/structure/door_assembly/door_assembly_fre
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/freezer.dmi'

/obj/structure/door_assembly/door_assembly_hatch
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/hatch/centcom.dmi'
	overlays_file = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/hatch/overlays.dmi'

/obj/structure/door_assembly/door_assembly_mhatch
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/hatch/maintenance.dmi'
	overlays_file = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/hatch/overlays.dmi'

/obj/structure/door_assembly/door_assembly_highsecurity
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/highsec/highsec.dmi'
	overlays_file = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/highsec/overlays.dmi'

/obj/structure/door_assembly/door_assembly_vault
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/vault/vault.dmi'
	overlays_file = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/vault/overlays.dmi'


/obj/structure/door_assembly/door_assembly_centcom
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/centcom/centcom.dmi'
	overlays_file = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/centcom/overlays.dmi'

/obj/structure/door_assembly/door_assembly_grunge
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/centcom/centcom.dmi'
	overlays_file = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/centcom/overlays.dmi'

/obj/structure/door_assembly/door_assembly_gold
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/gold.dmi'

/obj/structure/door_assembly/door_assembly_silver
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/silver.dmi'

/obj/structure/door_assembly/door_assembly_diamond
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/diamond.dmi'

/obj/structure/door_assembly/door_assembly_uranium
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/uranium.dmi'

/obj/structure/door_assembly/door_assembly_plasma
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/plasma.dmi'

/obj/structure/door_assembly/door_assembly_bananium
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/bananium.dmi'

/obj/structure/door_assembly/door_assembly_sandstone
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/sandstone.dmi'

/obj/structure/door_assembly/door_assembly_wood
	icon = 'modular_skyrat/modules/aesthetics/airlock/icons/airlocks/station/wood.dmi'

//SKYRAT EDIT ADDITION BEGIN - AESTHETICS
#undef AIRLOCK_LIGHT_POWER
#undef AIRLOCK_LIGHT_RANGE

#undef AIRLOCK_POWERON_LIGHT_COLOR
#undef AIRLOCK_BOLTS_LIGHT_COLOR
#undef AIRLOCK_ACCESS_LIGHT_COLOR
#undef AIRLOCK_EMERGENCY_LIGHT_COLOR
#undef AIRLOCK_DENY_LIGHT_COLOR
//SKYRAT EDIT END

#undef AIRLOCK_CLOSED
#undef AIRLOCK_CLOSING
#undef AIRLOCK_OPEN
#undef AIRLOCK_OPENING
#undef AIRLOCK_DENY
#undef AIRLOCK_EMAG
