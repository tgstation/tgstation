GLOBAL_LIST_EMPTY(possibleMMItems)

/obj/structure/mysterymachine
	name = "Mysterious Generation Machine"
	desc = "Within this machine is the greatest power known to all of existence: unlimited creation! Whether built by an omnipotent god or an advanced omniscient intelligence created by an alien civilization, you do not know. What you do know however is that all you must do to receive whatever your heart desires is to type it in and- wait a second... What immature deviant replaced the keyboard with a lever?!?"
	icon_state = "mysterymachine"
	anchored = TRUE
	density = TRUE
	var/processing = FALSE
	var/item_input = ""
	var/inputSize = 32
	var/itemFound = FALSE
	var/itemText = ""
	var/lastText = ""
	var/firstText = ""

/obj/structure/mysterymachine/Initialize()
	. = ..()
	resistance_flags |= INDESTRUCTIBLE
	set_light(2, 2, "#FFFFFF")
	if(!GLOB.possibleMMItems.len)
		var/list/MMItems_types_list = subtypesof(/obj/item)
		for(var/V in MMItems_types_list)
			var/obj/item/I = V
			if(!initial(I.name) || !initial(I.icon_state) || (initial(I.item_flags) & ABSTRACT))
				MMItems_types_list -= V
			else
				if(lentext(initial(I.name)) > inputSize)
					inputSize = lentext(initial(I.name))
		GLOB.possibleMMItems = MMItems_types_list


/obj/structure/mysterymachine/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/wrench))
		to_chat(user, "<span class='notice'>The bolts are extremely tight. This could take awhile...</span>")
		default_unfasten_wrench(user, I, 300)
		return
	return ..()

/obj/structure/mysterymachine/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.always_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mysterymachine", name, 800, 200, master_ui, state)
		ui.open()

/obj/structure/mysterymachine/ui_data(mob/user)
	var/list/data = list()
	data["itemInput"] = item_input
	data["processing"] = processing
	data["itemFound"] = itemFound
	data["itemText"] = itemText
	data["firstText"] = firstText
	data["lastText"] = lastText
	return data

/obj/structure/mysterymachine/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("pullLever")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				add_fingerprint(C)
			processing = TRUE
			item_input = random_string(inputSize, GLOB.alphabet)
			SStgui.update_uis(src)
			var/list/validItems = get_valid_items()
			if(validItems.len)
				itemFound = TRUE
				var/obj/item/chosenItem = pick(validItems)
				itemText = sanitizeName(initial(chosenItem.name))
				var/textLoc = findtext(item_input, itemText)
				firstText = copytext(item_input, 1, textLoc)
				lastText = copytext(item_input, textLoc+lentext(itemText), 0)
				playsound(loc, 'sound/machines/chime.ogg', 50, 1, extrarange = -3, falloff = 10)
				say("Input of '[initial(chosenItem.name)]' detected. Item created!")
				new chosenItem(get_turf(usr))
			else
				itemFound = FALSE
				playsound(loc, 'sound/machines/deniedbeep.ogg', 50, 1, extrarange = -3, falloff = 10)
				say("No valid input detected!")
			processing = FALSE
			SStgui.update_uis(src)
			. = TRUE
	update_icon()

/obj/structure/mysterymachine/proc/get_valid_items()
	var/valid_items_to_return = new /list(0)
	for(var/V in GLOB.possibleMMItems)
		var/obj/item/I = V
		var/sanitizedItemName = sanitizeName(initial(I.name))
		if(findtext(item_input, sanitizedItemName))
			valid_items_to_return += V
	return valid_items_to_return

/obj/structure/mysterymachine/proc/sanitizeName(var/givenString)
	var/static/regex/nonalphabet= new(@"[^a-zA-Z0-9]", "g")
	return lowertext(replacetext(initial(givenString), nonalphabet, ""))