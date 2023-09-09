//SKYRAT ADDITION BEGIN - AESTHETICS
#define AIRLOCK_LIGHT_POWER 0.5
#define AIRLOCK_LIGHT_RANGE 2
#define AIRLOCK_LIGHT_ENGINEERING "engineering"
#define AIRLOCK_POWERON_LIGHT_COLOR "#3aa7c2"
#define AIRLOCK_BOLTS_LIGHT_COLOR "#c22323"
#define AIRLOCK_ACCESS_LIGHT_COLOR "#57e69c"
#define AIRLOCK_EMERGENCY_LIGHT_COLOR "#d1d11d"
#define AIRLOCK_ENGINEERING_LIGHT_COLOR "#fd8719"
#define AIRLOCK_DENY_LIGHT_COLOR "#c22323"
//SKYRAT ADDITION END

#define AIRLOCK_CLOSED	1
#define AIRLOCK_CLOSING	2
#define AIRLOCK_OPEN	3
#define AIRLOCK_OPENING	4
#define AIRLOCK_DENY	5
#define AIRLOCK_EMAG	6

#define AIRLOCK_FRAME_CLOSED "closed"
#define AIRLOCK_FRAME_CLOSING "closing"
#define AIRLOCK_FRAME_OPEN "open"
#define AIRLOCK_FRAME_OPENING "opening"

/obj/machinery/door/airlock
	doorOpen = 'monkestation/code/modules/aesthetics/airlock/sound/open.ogg'
	doorClose = 'monkestation/code/modules/aesthetics/airlock/sound/close.ogg'
	boltUp = 'monkestation/code/modules/aesthetics/airlock/sound/bolts_up.ogg'
	boltDown = 'monkestation/code/modules/aesthetics/airlock/sound/bolts_down.ogg'
	//noPower = 'sound/machines/doorclick.ogg'
	var/forcedOpen = 'monkestation/code/modules/aesthetics/airlock/sound/open_force.ogg' //Come on guys, why aren't all the sound files like this.
	var/forcedClosed = 'monkestation/code/modules/aesthetics/airlock/sound/close_force.ogg'

	/// For those airlocks you might want to have varying "fillings" for, without having to
	/// have an icon file per door with a different filling.
	var/fill_state_suffix = null
	/// For the airlocks that use greyscale lights, set this to the color you want your lights to be.
	var/greyscale_lights_color = null
	/// For the airlocks that use a greyscale accent door color, set this color to the accent color you want it to be.
	var/greyscale_accent_color = null

	var/has_environment_lights = TRUE //Does this airlock emit a light?
	var/light_color_poweron = AIRLOCK_POWERON_LIGHT_COLOR
	var/light_color_bolts = AIRLOCK_BOLTS_LIGHT_COLOR
	var/light_color_access = AIRLOCK_ACCESS_LIGHT_COLOR
	var/light_color_emergency = AIRLOCK_EMERGENCY_LIGHT_COLOR
	var/light_color_engineering = AIRLOCK_ENGINEERING_LIGHT_COLOR
	var/light_color_deny = AIRLOCK_DENY_LIGHT_COLOR
	var/door_light_range = AIRLOCK_LIGHT_RANGE
	var/door_light_power = AIRLOCK_LIGHT_POWER
	///Is this door external? E.g. does it lead to space? Shuttle docking systems bolt doors with this flag.
	var/external = FALSE

/obj/machinery/door/airlock/external
	external = TRUE

/obj/machinery/door/airlock/shuttle
	external = TRUE

/obj/machinery/door/airlock/power_change()
	..()
	update_icon()

/obj/machinery/door/airlock/update_overlays()
	. = ..()
	var/pre_light_range = 0
	var/pre_light_power = 0
	var/pre_light_color = ""
	var/lights_overlay = ""

	var/frame_state
	var/light_state
	switch(airlock_state)
		if(AIRLOCK_CLOSED)
			frame_state = AIRLOCK_FRAME_CLOSED
			if(locked)
				light_state = AIRLOCK_LIGHT_BOLTS
				lights_overlay = "lights_bolts"
				pre_light_color = light_color_bolts
			else if(emergency)
				light_state = AIRLOCK_LIGHT_EMERGENCY
				lights_overlay = "lights_emergency"
				pre_light_color = light_color_emergency
			else
				lights_overlay = "lights_poweron"
				pre_light_color = light_color_poweron
		if(AIRLOCK_DENY)
			frame_state = AIRLOCK_FRAME_CLOSED
			light_state = AIRLOCK_LIGHT_DENIED
			lights_overlay = "lights_denied"
			pre_light_color = light_color_deny
		if(AIRLOCK_EMAG)
			frame_state = AIRLOCK_FRAME_CLOSED
		if(AIRLOCK_CLOSING)
			frame_state = AIRLOCK_FRAME_CLOSING
			light_state = AIRLOCK_LIGHT_CLOSING
			lights_overlay = "lights_closing"
			pre_light_color = light_color_access
		if(AIRLOCK_OPEN)
			frame_state = AIRLOCK_FRAME_OPEN
			if(locked)
				lights_overlay = "lights_bolts_open"
				pre_light_color = light_color_bolts
			else if(emergency)
				lights_overlay = "lights_emergency_open"
				pre_light_color = light_color_emergency
			else
				lights_overlay = "lights_poweron_open"
				pre_light_color = light_color_poweron
		if(AIRLOCK_OPENING)
			frame_state = AIRLOCK_FRAME_OPENING
			light_state = AIRLOCK_LIGHT_OPENING
			lights_overlay = "lights_opening"
			pre_light_color = light_color_access

	. += get_airlock_overlay(frame_state, icon, src, em_block = TRUE)
	if(airlock_material)
		. += get_airlock_overlay("[airlock_material]_[frame_state]", overlays_file, src, em_block = TRUE)
	else
		. += get_airlock_overlay("fill_[frame_state + fill_state_suffix]", icon, src, em_block = TRUE)

	if(greyscale_lights_color && !light_state)
		lights_overlay += "_greyscale"

	if(lights && hasPower())
		. += get_airlock_overlay("lights_[light_state]", overlays_file, src, em_block = FALSE)
		pre_light_range = door_light_range
		pre_light_power = door_light_power
		if(has_environment_lights)
			set_light(l_outer_range = pre_light_range, l_power = pre_light_power, l_color = pre_light_color, l_on = TRUE)
	else
		lights_overlay = ""
		set_light(l_on = FALSE)

	var/mutable_appearance/lights_appearance = mutable_appearance(overlays_file, lights_overlay, FLOAT_LAYER, src, ABOVE_LIGHTING_PLANE)

	if(greyscale_lights_color && !light_state)
		lights_appearance.color = greyscale_lights_color


	. += lights_appearance

	if(greyscale_accent_color)
		. += get_airlock_overlay("[frame_state]_accent", overlays_file, src, em_block = TRUE, state_color = greyscale_accent_color)

	if(panel_open)
		. += get_airlock_overlay("panel_[frame_state][security_level ? "_protected" : null]", overlays_file, src, em_block = TRUE)
	if(frame_state == AIRLOCK_FRAME_CLOSED && welded)
		. += get_airlock_overlay("welded", overlays_file, src, em_block = TRUE)

	if(airlock_state == AIRLOCK_EMAG)
		. += get_airlock_overlay("sparks", overlays_file, src, em_block = FALSE)

	if(hasPower())
		if(frame_state == AIRLOCK_FRAME_CLOSED)
			if(atom_integrity < integrity_failure * max_integrity)
				. += get_airlock_overlay("sparks_broken", overlays_file, src, em_block = FALSE)
			else if(atom_integrity < (0.75 * max_integrity))
				. += get_airlock_overlay("sparks_damaged", overlays_file, src, em_block = FALSE)
		else if(frame_state == AIRLOCK_FRAME_OPEN)
			if(atom_integrity < (0.75 * max_integrity))
				. += get_airlock_overlay("sparks_open", overlays_file, src, em_block = FALSE)

	if(note)
		. += get_airlock_overlay(get_note_state(frame_state), note_overlay_file, src, em_block = TRUE)

	if(frame_state == AIRLOCK_FRAME_CLOSED && seal)
		. += get_airlock_overlay("sealed", overlays_file, src, em_block = TRUE)

	if(hasPower() && unres_sides)
		for(var/heading in list(NORTH,SOUTH,EAST,WEST))
			if(!(unres_sides & heading))
				continue
			var/mutable_appearance/floorlight = mutable_appearance('icons/obj/doors/airlocks/station/overlays.dmi', "unres_[heading]", FLOAT_LAYER, src, ABOVE_LIGHTING_PLANE)
			switch (heading)
				if (NORTH)
					floorlight.pixel_x = 0
					floorlight.pixel_y = 32
				if (SOUTH)
					floorlight.pixel_x = 0
					floorlight.pixel_y = -32
				if (EAST)
					floorlight.pixel_x = 32
					floorlight.pixel_y = 0
				if (WEST)
					floorlight.pixel_x = -32
					floorlight.pixel_y = 0
			. += floorlight

//STATION AIRLOCKS
/obj/machinery/door/airlock
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/public.dmi'
	overlays_file = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/overlays.dmi'

/obj/machinery/door/airlock/command
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/command.dmi'

/obj/machinery/door/airlock/security
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/security.dmi'

/obj/machinery/door/airlock/security/old
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/security2.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_sec/old

/obj/machinery/door/airlock/security/old/glass
	opacity = FALSE
	glass = TRUE
	normal_integrity = 400

/obj/machinery/door/airlock/engineering
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/engineering.dmi'

/obj/machinery/door/airlock/medical
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/medical.dmi'

/obj/machinery/door/airlock/maintenance
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/maintenance.dmi'

/obj/machinery/door/airlock/maintenance/external
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/maintenanceexternal.dmi'

/obj/machinery/door/airlock/mining
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/mining.dmi'

/obj/machinery/door/airlock/atmos
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/atmos.dmi'

/obj/machinery/door/airlock/research
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/research.dmi'

/obj/machinery/door/airlock/freezer
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/freezer.dmi'

/obj/machinery/door/airlock/science
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/science.dmi'

/obj/machinery/door/airlock/virology
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/virology.dmi'

//STATION CUSTOM ARILOCKS
/obj/machinery/door/airlock/corporate
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/corporate.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_corporate
	normal_integrity = 450

/obj/machinery/door/airlock/corporate/glass
	opacity = FALSE
	glass = TRUE
	normal_integrity = 400

/obj/machinery/door/airlock/service
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/service.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_service

/obj/machinery/door/airlock/service/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/captain
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/cap.dmi'

/obj/machinery/door/airlock/hop
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/hop.dmi'

/obj/machinery/door/airlock/hos
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/hos.dmi'

/obj/machinery/door/airlock/hos/glass
	opacity = FALSE
	glass = TRUE
	normal_integrity = 400

/obj/machinery/door/airlock/ce
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/ce.dmi'

/obj/machinery/door/airlock/ce/glass
	opacity = FALSE
	glass = TRUE
	normal_integrity = 400

/obj/machinery/door/airlock/rd
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/rd.dmi'

/obj/machinery/door/airlock/rd/glass
	opacity = FALSE
	glass = TRUE
	normal_integrity = 400

/obj/machinery/door/airlock/qm
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/qm.dmi'

/obj/machinery/door/airlock/qm/glass
	opacity = FALSE
	glass = TRUE
	normal_integrity = 400

/obj/machinery/door/airlock/cmo
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/cmo.dmi'

/obj/machinery/door/airlock/cmo/glass
	opacity = FALSE
	glass = TRUE
	normal_integrity = 400

/obj/machinery/door/airlock/psych
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/psych.dmi'

/obj/machinery/door/airlock/asylum
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/asylum.dmi'

/obj/machinery/door/airlock/bathroom
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/bathroom.dmi'

//STATION MINERAL AIRLOCKS
/obj/machinery/door/airlock/gold
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/gold.dmi'

/obj/machinery/door/airlock/silver
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/silver.dmi'

/obj/machinery/door/airlock/diamond
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/diamond.dmi'

/obj/machinery/door/airlock/uranium
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/uranium.dmi'

/obj/machinery/door/airlock/plasma
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/plasma.dmi'

/obj/machinery/door/airlock/bananium
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/bananium.dmi'

/obj/machinery/door/airlock/sandstone
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/sandstone.dmi'

/obj/machinery/door/airlock/wood
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/wood.dmi'

//STATION 2 AIRLOCKS

/obj/machinery/door/airlock/public
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station2/glass.dmi'
	overlays_file = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station2/overlays.dmi'

//EXTERNAL AIRLOCKS
/obj/machinery/door/airlock/external
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/external/external.dmi'
	overlays_file = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/external/overlays.dmi'

//CENTCOM
/obj/machinery/door/airlock/centcom
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/centcom/centcom.dmi'
	overlays_file = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/centcom/overlays.dmi'

/obj/machinery/door/airlock/grunge
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/centcom/centcom.dmi'
	overlays_file = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/centcom/overlays.dmi'

//VAULT
/obj/machinery/door/airlock/vault
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/vault/vault.dmi'
	overlays_file = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/vault/overlays.dmi'

//HATCH
/obj/machinery/door/airlock/hatch
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/hatch/centcom.dmi'
	overlays_file = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/hatch/overlays.dmi'

/obj/machinery/door/airlock/maintenance_hatch
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/hatch/maintenance.dmi'
	overlays_file = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/hatch/overlays.dmi'

//HIGH SEC
/obj/machinery/door/airlock/highsecurity
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/highsec/highsec.dmi'
	overlays_file = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/highsec/overlays.dmi'

//ASSEMBLYS
/obj/structure/door_assembly/door_assembly_public
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station2/glass.dmi'
	overlays_file = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station2/overlays.dmi'

/obj/structure/door_assembly/door_assembly_com
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/command.dmi'

/obj/structure/door_assembly/door_assembly_sec
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/security.dmi'

/obj/structure/door_assembly/door_assembly_sec/old
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/security2.dmi'

/obj/structure/door_assembly/door_assembly_eng
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/engineering.dmi'

/obj/structure/door_assembly/door_assembly_min
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/mining.dmi'

/obj/structure/door_assembly/door_assembly_atmo
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/atmos.dmi'

/obj/structure/door_assembly/door_assembly_research
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/research.dmi'

/obj/structure/door_assembly/door_assembly_science
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/science.dmi'

/obj/structure/door_assembly/door_assembly_viro
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/virology.dmi'

/obj/structure/door_assembly/door_assembly_med
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/medical.dmi'

/obj/structure/door_assembly/door_assembly_mai
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/maintenance.dmi'

/obj/structure/door_assembly/door_assembly_extmai
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/maintenanceexternal.dmi'

/obj/structure/door_assembly/door_assembly_ext
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/external/external.dmi'
	overlays_file = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/external/overlays.dmi'

/obj/structure/door_assembly/door_assembly_fre
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/freezer.dmi'

/obj/structure/door_assembly/door_assembly_hatch
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/hatch/centcom.dmi'
	overlays_file = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/hatch/overlays.dmi'

/obj/structure/door_assembly/door_assembly_mhatch
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/hatch/maintenance.dmi'
	overlays_file = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/hatch/overlays.dmi'

/obj/structure/door_assembly/door_assembly_highsecurity
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/highsec/highsec.dmi'
	overlays_file = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/highsec/overlays.dmi'

/obj/structure/door_assembly/door_assembly_vault
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/vault/vault.dmi'
	overlays_file = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/vault/overlays.dmi'


/obj/structure/door_assembly/door_assembly_centcom
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/centcom/centcom.dmi'
	overlays_file = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/centcom/overlays.dmi'

/obj/structure/door_assembly/door_assembly_grunge
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/centcom/centcom.dmi'
	overlays_file = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/centcom/overlays.dmi'

/obj/structure/door_assembly/door_assembly_gold
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/gold.dmi'

/obj/structure/door_assembly/door_assembly_silver
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/silver.dmi'

/obj/structure/door_assembly/door_assembly_diamond
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/diamond.dmi'

/obj/structure/door_assembly/door_assembly_uranium
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/uranium.dmi'

/obj/structure/door_assembly/door_assembly_plasma
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/plasma.dmi'

/obj/structure/door_assembly/door_assembly_bananium
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/bananium.dmi'

/obj/structure/door_assembly/door_assembly_sandstone
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/sandstone.dmi'

/obj/structure/door_assembly/door_assembly_wood
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/wood.dmi'

/obj/structure/door_assembly/door_assembly_corporate
	name = "corporate airlock assembly"
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/corporate.dmi'
	glass_type = /obj/machinery/door/airlock/corporate/glass
	airlock_type = /obj/machinery/door/airlock/corporate

/obj/structure/door_assembly/door_assembly_service
	name = "service airlock assembly"
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/service.dmi'
	base_name = "service airlock"
	glass_type = /obj/machinery/door/airlock/service/glass
	airlock_type = /obj/machinery/door/airlock/service

/obj/structure/door_assembly/door_assembly_captain
	name = "captain airlock assembly"
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/cap.dmi'
	glass_type = /obj/machinery/door/airlock/command/glass
	airlock_type = /obj/machinery/door/airlock/captain

/obj/structure/door_assembly/door_assembly_hop
	name = "head of personnel airlock assembly"
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/hop.dmi'
	glass_type = /obj/machinery/door/airlock/command/glass
	airlock_type = /obj/machinery/door/airlock/hop

/obj/structure/door_assembly/hos
	name = "head of security airlock assembly"
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/hos.dmi'
	glass_type = /obj/machinery/door/airlock/hos/glass
	airlock_type = /obj/machinery/door/airlock/hos

/obj/structure/door_assembly/door_assembly_cmo
	name = "chief medical officer airlock assembly"
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/cmo.dmi'
	glass_type = /obj/machinery/door/airlock/cmo/glass
	airlock_type = /obj/machinery/door/airlock/cmo

/obj/structure/door_assembly/door_assembly_ce
	name = "chief engineer airlock assembly"
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/ce.dmi'
	glass_type = /obj/machinery/door/airlock/ce/glass
	airlock_type = /obj/machinery/door/airlock/ce

/obj/structure/door_assembly/door_assembly_rd
	name = "research director airlock assembly"
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/rd.dmi'
	glass_type = /obj/machinery/door/airlock/rd/glass
	airlock_type = /obj/machinery/door/airlock/rd

/obj/structure/door_assembly/door_assembly_qm
	name = "quartermaster airlock assembly"
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/qm.dmi'
	glass_type = /obj/machinery/door/airlock/qm/glass
	airlock_type = /obj/machinery/door/airlock/qm

/obj/structure/door_assembly/door_assembly_psych
	name = "psychologist airlock assembly"
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/psych.dmi'
	glass_type = /obj/machinery/door/airlock/medical/glass
	airlock_type = /obj/machinery/door/airlock/psych

/obj/structure/door_assembly/door_assembly_asylum
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/asylum.dmi'

/obj/structure/door_assembly/door_assembly_bathroom
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/bathroom.dmi'

/obj/machinery/door/airlock/hydroponics
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/botany.dmi'

/obj/structure/door_assembly/door_assembly_hydro
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/botany.dmi'

/obj/structure/door_assembly/
	icon = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/public.dmi'
	overlays_file = 'monkestation/code/modules/aesthetics/airlock/icons/airlocks/station/overlays.dmi'

//SKYRAT EDIT ADDITION BEGIN - AESTHETICS
#undef AIRLOCK_LIGHT_POWER
#undef AIRLOCK_LIGHT_RANGE
#undef AIRLOCK_LIGHT_ENGINEERING
#undef AIRLOCK_ENGINEERING_LIGHT_COLOR
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

#undef AIRLOCK_FRAME_CLOSED
#undef AIRLOCK_FRAME_CLOSING
#undef AIRLOCK_FRAME_OPEN
#undef AIRLOCK_FRAME_OPENING
