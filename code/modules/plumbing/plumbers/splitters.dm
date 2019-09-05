///it splits the reagents however you want. So you can "every 60 units, 45 goes left and 15 goes straight". The side direction is EAST, you can change this in the component
/obj/machinery/plumbing/splitter
	name = "Chemical Splitter"
	desc = "A chemical splitter for smart chemical factorization. Waits till a set of conditions is met and then stops all input and splits the buffer evenly or other in two ducts."
	icon_state = "splitter"
	buffer = 100
	///constantly switches between TRUE and FALSE. TRUE means the batch tick goes straight, FALSE means the next batch goes in the side duct.
	var/turn_straight = TRUE
	///how much we must transfer straight. note input can be as high as 10 reagents per process, usually
	var/transfer_straight = 5
	///how much we must transfer to the side
	var/transfer_side = 5
	//the maximum you can set the transfer to
	var/max_transfer = 9

/obj/machinery/plumbing/splitter/Initialize()
	. = ..()
	AddComponent(/datum/component/plumbing/splitter)

/obj/machinery/plumbing/splitter/wrench_act(mob/living/user, obj/item/I)
	default_unfasten_wrench(user, I)
	return TRUE

/obj/machinery/plumbing/splitter/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "chem_splitter", name, 700, 200, master_ui, state)
		ui.open()

/obj/machinery/plumbing/splitter/ui_data(mob/user)
	var/list/data = list()
	data["straight"] = transfer_straight
	data["side"] = transfer_side
	return data

/obj/machinery/plumbing/splitter/ui_act(action, params)
	if(..())
		return
	. = TRUE
	switch(action)
		if("set_amount")
			var/direction = params["target"]
			switch(direction)
				if("straight")
					transfer_straight = CLAMP(input("New target transfer:", name, transfer_straight) as num|null, 1 , max_transfer)
				if("side")
					transfer_side = CLAMP(input("New target transfer:", name, transfer_side) as num|null, 1 , max_transfer)
				else
					return FALSE