/obj/structure/closet
	/// If TRUE, the closet will anchored by default, if it spawns on the station's z-level.
	var/roundstart_anchor = TRUE

/obj/structure/closet/Initialize(mapload)
	. = ..()
	if(mapload && can_roundstart_anchor())
		set_anchored(TRUE)

/obj/structure/closet/proc/can_roundstart_anchor()
	if(!roundstart_anchor || !anchorable || !is_station_level(loc?.z))
		return FALSE
	var/area/current_area = get_area(src)
	if(!current_area?.anchor_roundstart_lockers)
		return FALSE
	return TRUE

/obj/structure/closet/crate
	roundstart_anchor = FALSE

/obj/structure/closet/supplypod
	roundstart_anchor = FALSE
