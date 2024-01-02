/datum/wires/microwave
	holder_type = /obj/machinery/microwave
	proper_name = "Microwave"

/datum/wires/microwave/New(atom/holder)
	wires = list(
		WIRE_ACTIVATE,
		WIRE_MODE_SELECT
	)
	..()

/datum/wires/microwave/interactable(mob/user)
	if(!..())
		return FALSE
	. = FALSE
	var/obj/machinery/microwave/mw = holder
	if(mw.panel_open)
		. = TRUE

/datum/wires/microwave/on_pulse(wire)
	var/obj/machinery/microwave/mw = holder
	switch(wire)
		if(WIRE_ACTIVATE)
			mw.cook()
		if(WIRE_MODE_SELECT)
			if(mw.vampire_charging_capable)
				mw.vampire_charging_enabled = !mw.vampire_charging_enabled

/datum/wires/microwave/on_cut(wire, mend, source)
	var/obj/machinery/microwave/mw = holder
	switch(wire)
		if(WIRE_ACTIVATE)
			mw.wire_disabled = !mend
		if(WIRE_MODE_SELECT)
			mw.wire_mode_swap = !mend
