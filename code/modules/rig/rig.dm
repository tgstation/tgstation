//epic rig
/obj/item/rig
	name = "Base RIG"
	desc = "You should not see this, yell at a coder!"
	icon = 'icons/obj/rig.dmi'
	icon_state = "rig_shell"

/obj/item/rig/themed
	///How the RIG and things connected to it look
	var/theme = "engi"

/obj/item/rig/themed/control
	name = "RIG control module"
	desc = "A special powered suit that protects against various environments. Wear it on your back, deploy it and turn it on to use its' power."
	icon_state = "engi-module"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	req_access = list()
	slowdown = 1
	theme = "engi"
	///If the suit is deployed and turned on
	var/active = FALSE
	///If the suit wire/module hatch is open
	var/open = FALSE
	///If the suit is ID locked
	var/locked = FALSE
	///If the suit is malfunctioning
	var/malfunctioning = FALSE
	///If the suit has EMP protection
	var/emp_protection = FALSE
	///How long the RIG is electrified for
	var/seconds_electrified = MACHINE_NOT_ELECTRIFIED
	///If the suit interface is broken
	var/interface_break = FALSE
	///How much part complexity can this RIG carry
	var/complexity_max = 15

/obj/item/rig/control/Initialize()
	..()
	icon_state = "[theme]-module"
	wires = new /datum/wires/rig(src)

/obj/item/rig/control/Destroy()
	..()
	QDEL_NULL(wires)

/obj/item/rig/themed/control/process()
	if(seconds_electrified > MACHINE_NOT_ELECTRIFIED)
		seconds_electrified--

