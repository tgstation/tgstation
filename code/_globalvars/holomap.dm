/// A list of fire alarms on the station, separated by Z. Used cause there are a lot of fire alarms on any given station Z.
GLOBAL_LIST_EMPTY(station_fire_alarms)

GLOBAL_LIST_EMPTY(holomap_default_legend)

/// Used in generating area preview icons.
GLOBAL_LIST_INIT(holomap_color_to_name, list(
	HOLOMAP_AREACOLOR_COMMAND = "Command",
	HOLOMAP_AREACOLOR_SECURITY = "Security",
	HOLOMAP_AREACOLOR_MEDICAL = "Medical",
	HOLOMAP_AREACOLOR_SCIENCE = "Science",
	HOLOMAP_AREACOLOR_ENGINEERING = "Engineering",
	HOLOMAP_AREACOLOR_CARGO = "Cargo",
	HOLOMAP_AREACOLOR_HALLWAYS = "Hallways",
	HOLOMAP_AREACOLOR_MAINTENANCE = "Maintenance",
	HOLOMAP_AREACOLOR_ARRIVALS = "Arrivals",
	HOLOMAP_AREACOLOR_ESCAPE = "Departures",
	HOLOMAP_AREACOLOR_DORMS = "Recreation",
	HOLOMAP_AREACOLOR_SERVICE = "Service",
	HOLOMAP_AREACOLOR_HANGAR = "Hangar",
))
