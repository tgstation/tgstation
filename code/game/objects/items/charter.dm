#define CAN_CHANGE_NAME (always_usable || ((world.time < CHALLENGE_TIME_LIMIT) && !used))

/obj/item/station_charter
	name = "station charter"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	desc = "An official document entrusting the governance of the \
		station and surrounding space to the Captain. "
	var/used = FALSE

	var/captain_name

	var/selected_prefix
	var/selected_name
	var/selected_suffix
	var/selected_number

	var/list/number_list = list()

	var/always_usable = FALSE

	var/mob/proposer
	var/proposed_custom_name

/obj/item/station_charter/New()
	. = ..()
	selected_prefix = pick(station_prefixes)
	selected_name = pick(station_names)
	selected_suffix = pick(station_suffixes)

	for(var/i in 1 to 99)
		number_list += "[i]"
	number_list += greek_letters
	number_list += roman_numerals
	number_list += numbers_as_words
	number_list += phonetic_alphabet

	selected_number = pick(number_list)


/obj/item/station_charter/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = hands_state)
	SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "station_charter", name, 975, 420, master_ui, state)
		ui.open()

/obj/item/station_charter/ui_data(mob/user)
	var/list/data = list()

	var/list/prefixes = list()
	for(var/i in station_prefixes)
		var/list/L = list("item" = i)
		if(i == selected_prefix)
			L["selected"] = TRUE
		prefixes += list(L)
	data["prefixes"] = prefixes

	var/list/names = list()
	for(var/i in station_names)
		var/list/L = list("item" = i)
		if(i == selected_name)
			L["selected"] = TRUE
		names += list(L)
	data["names"] = names

	var/list/suffixes = list()
	for(var/i in station_suffixes)
		var/list/L = list("item" = i)
		if(i == selected_suffix)
			L["selected"] = TRUE
		suffixes += list(L)
	data["suffixes"] = suffixes

	var/list/numbers = list()
	for(var/i in number_list)
		var/list/L = list("item" = i)
		if(L["item"] == selected_number)
			L["selected"] = TRUE
		numbers += list(L)
	data["numbers"] = numbers

	data["can_pick"] = CAN_CHANGE_NAME
	data["allow_custom"] = (!proposed_custom_name) && CAN_CHANGE_NAME

	data["potential_name"] = assemble_name()
	data["current_name"] = world.name

	if(!captain_name)
		for(var/i in mob_list)
			var/mob/M = i
			if(M.mind && M.mind.assigned_role == "Captain")
				captain_name = M.name
	if(!captain_name)
		data["captain_name"] = "Debug McDebugson"
	else
		data["captain_name"] = captain_name

	data["tabs"] = list("Prefix","Name","Suffix","Number")

	return data

/obj/item/station_charter/proc/assemble_name()
	var/list/L = list()
	var/list/potentials = list(selected_prefix, selected_name,
		selected_suffix, selected_number)

	for(var/i in potentials)
		if(i && i != "")
			L += i
	return jointext(L, " ")

/obj/item/station_charter/ui_act(action, params)
	if(..())
		return
	if(!CAN_CHANGE_NAME)
		return
	switch(action)
		if("select")
			var/selection_type = params["type"]
			var/item = params["item"]
			var/list/selected_list
			switch(selection_type)
				if("prefix")
					selected_list = station_prefixes
				if("name")
					selected_list = station_names
				if("suffix")
					selected_list = station_suffixes
				if("number")
					selected_list = number_list
			if(!selected_list)
				return
			if(!(item in selected_list))
				return
			switch(selection_type)
				if("prefix")
					selected_prefix = item
				if("name")
					selected_name = item
				if("suffix")
					selected_suffix = item
				if("number")
					selected_number = item
			. = TRUE
		if("rename")
			designate(usr, assemble_name())
			. = TRUE
		if("custom")
			if(proposed_custom_name) // only get one proposal
				return
			var/new_name = stripped_input(usr, message="What do you want \
				to name [station_name()]? This custom name will be have to \
				be explicitly approved by your employeers.",
				max_length=MAX_CHARTER_LEN)
			proposer = usr
			proposed_custom_name = new_name
			var/msg = "<span class='adminnotice'><b><font color=orange>CUSTOM STATION RENAME:</font></b>[key_name_admin(proposer)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[proposer]'>?</A>) proposes to rename the station to [proposed_custom_name] (<A HREF='?_src_=holder;BlueSpaceArtillery=\ref[proposer]'>BSA</A>) (<A HREF='?_src_=holder;approve_custom_name=\ref[src]'>APPROVE</A>)</span>"
			admins << msg


/obj/item/station_charter/proc/designate(mob/user, new_name, approved_by=null)
	world.name = new_name
	station_name = new_name
	minor_announce("[user.real_name] has designated your station \
		as [world.name].", "Captain's Charter", 0)
	log_game("[key_name(user)] designated the station [world.name]")
	if(approved_by)
		log_admin("[approved_by] approved [key_name(user)] rename of the \
			station as [new_name]")
	used = TRUE

/obj/item/station_charter/proc/admin_approval(approved_by)
	designate(proposer, proposed_custom_name, approved_by)

/obj/item/station_charter/admin
	name = "admin station charter"
	always_usable = TRUE
