///chemical plumbing filter. If it's not filtered by left and right, it goes straight.
/obj/machinery/plumbing/filter
	name = "chemical filter"
	desc = "A chemical filter for filtering chemicals."
	icon_state = "filter"
	///whitelist of chems id's that go to the left side. Empty to disable port
	var/list/left = list()
	///whitelist of chem id's that go to the right side. Empty to disable port
	var/list/right = list()
	///whitelist of chems but their name instead of path
	var/list/english_left = list()
	///whitelist of chems but their name instead of path
	var/list/english_right = list()
	var/xen = 500
	var/yen = 500


/obj/machinery/plumbing/filter/Initialize()
	. = ..()
	AddComponent(/datum/component/plumbing/filter)

/obj/machinery/plumbing/filter/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "chemical_filter", name, xen, yen, master_ui, state)
		ui.open()

/obj/machinery/plumbing/filter/ui_data(mob/user)
	var/list/data = list()
	data["left"] = english_left
	data["right"] = english_right
	return data

/obj/machinery/plumbing/filter/ui_act(action, params)
	if(..())
		return
	. = TRUE
	switch(action)
		if("add")
			var/new_chem_name = ckey(input("Enter chemical to filter:", name) as text|null)
			if(GLOB.chemical_reagents_list.Find(new_chem_name))
				switch(params["which"])
					if("left")
						if(!english_left.Find(new_chem_name))
							english_left += new_chem_name
							left += GLOB.chemical_reagents_list[new_chem_name]
					if("right")
						if(!english_right.Find(new_chem_name))
							english_right += new_chem_name
							right += GLOB.chemical_reagents_list[new_chem_name]
			else
				to_chat(usr, "<span class='warning'>No such known reagent exists!</span>")

		if("remove")
			var/reagent = params["reagent"]
			switch(params["which"])
				if("left")
					if(english_left.Find(reagent))
						english_left -= reagent
						left -= GLOB.chemical_reagents_list[reagent]
				if("right")
					if(english_right.Find(reagent))
						english_right -= reagent
						right -= GLOB.chemical_reagents_list[reagent]

/obj/machinery/plumbing/filter/proc/get_chem_id(chem_name)
	for(var/A in GLOB.chemical_reagents_list)
		var/datum/reagent/R = A
		if(chem_name == ckey(R.name))
			return R.type
