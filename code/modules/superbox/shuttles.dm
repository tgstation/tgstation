// Template definitions for our shuttles

/datum/map_template/shuttle/emergency/sb
	suffix = "sb"
	name = "Superbox emergency shuttle"
	credit_cost = 1200

/datum/map_template/shuttle/cargo/sb
	suffix = "sb"
	name = "cargo ferry (SB)"

/datum/map_template/shuttle/arrival/sb
	suffix = "sb"
	name = "arrival shuttle (SB)"

/datum/map_template/shuttle/mining/sb
	suffix = "sb"
	name = "mining shuttle (SB)"

/datum/map_template/shuttle/whiteship/sb
	suffix = "sb"
	name = "NT White Cruiser"

// Handling for making maint airlocks public access when something docks
/obj/machinery/door/airlock
	var/emergency_when_docked = FALSE

/obj/machinery/door/airlock/proc/emergency_dock(new_shuttledocked)
	if (!emergency_when_docked)
		return
	if (shuttledocked == new_shuttledocked)
		return
	if (emergency == new_shuttledocked)
		return
	emergency = new_shuttledocked
	update_icon()
	if (cyclelinkedairlock)
		cyclelinkedairlock.emergency = new_shuttledocked
		cyclelinkedairlock.update_icon()
