/*
** Holomap vars and procs on /area
*/

/area
	/// Color of this area on holomaps.
	var/holomap_color = null
	/// Whether the turfs in the area should be drawn onto the "base" holomap.
	var/holomap_should_draw = TRUE

/area/shuttle
	holomap_should_draw = FALSE

/area/ruin
	holomap_should_draw = FALSE

// Command //
/area/station/command
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/station/ai_monitored
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

// Security //
/area/station/security
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/station/ai_monitored/security
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/station/maintenance/department/security
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

// Science //
/area/station/science
	holomap_color = HOLOMAP_AREACOLOR_SCIENCE

/area/station/maintenance/department/science
	holomap_color = HOLOMAP_AREACOLOR_SCIENCE

// Medical //
/area/station/medical
	holomap_color = HOLOMAP_AREACOLOR_MEDICAL

/area/station/maintenance/department/medical
	holomap_color = HOLOMAP_AREACOLOR_MEDICAL

// Engineering //
/area/station/engineering
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/station/maintenance/department/engine
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/station/maintenance/solars
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

// Service //
/area/station/service
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/maintenance/department/crew_quarters
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/maintenance/department/chapel
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

// Cargo //
/area/station/cargo
	holomap_color = HOLOMAP_AREACOLOR_CARGO

/area/station/maintenance/department/cargo
	holomap_color = HOLOMAP_AREACOLOR_CARGO

/area/station/command/heads_quarters/qm
	holomap_color = HOLOMAP_AREACOLOR_CARGO

/area/station/maintenance/disposal
	holomap_color = HOLOMAP_AREACOLOR_CARGO

// Maints //
/area/station/maintenance
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/library/abandoned
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/station/service/abandoned_gambling_den
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/station/medical/abandoned
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/station/science/research/abandoned
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/station/commons/vacant_room/office
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/station/service/hydroponics/garden/abandoned
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

// Dorms //
/area/station/commons
	holomap_color = HOLOMAP_AREACOLOR_DORMS

/area/station/maintenance/department/crew_quarters
	holomap_color = HOLOMAP_AREACOLOR_DORMS

/area/station/holodeck
	holomap_color = HOLOMAP_AREACOLOR_DORMS


/area/station/hallway
	holomap_color = HOLOMAP_AREACOLOR_HALLWAYS
