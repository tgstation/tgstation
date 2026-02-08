#define MAX_TRANSFER 9

///it splits the reagents however you want. So you can "every 60 units, 45 goes left and 15 goes straight". The side direction is EAST, you can change this in the component
/obj/machinery/plumbing/splitter
	name = "chemical splitter"
	desc = "A chemical splitter for smart chemical factorization. Waits till a set of conditions is met and then stops all input and splits the buffer evenly or other in two ducts."
	icon_state = "splitter_tri"
	buffer = 100
	density = FALSE

	///how much we must transfer straight(SOUTH)
	var/transfer_straight = 5
	///how much we must transfer to the left(EAST)
	var/transfer_left = 5
	///how much we must transfer to the right(WEST)
	var/transfer_right = 5

/obj/machinery/plumbing/splitter/Initialize(mapload, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/multidirectional/splitter, layer)

/obj/machinery/plumbing/splitter/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemSplitter", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/plumbing/splitter/ui_static_data(mob/user)
	return list(
		max_transfer = MAX_TRANSFER
	)

/obj/machinery/plumbing/splitter/ui_data(mob/user)
	return list(
		straight = transfer_straight,
		left = transfer_left,
		right = transfer_right,
	)

/obj/machinery/plumbing/splitter/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("set_amount")
			var/value = text2num(params["amount"])
			if(!value)
				return FALSE
			value = clamp(value, 1, MAX_TRANSFER)

			switch(params["target"])
				if("straight")
					transfer_straight = value
					return TRUE

				if("left")
					transfer_left = value
					return TRUE

				if("right")
					transfer_right = value
					return TRUE

#undef MAX_TRANSFER
