///We take a constant input of reagents, and produce a pill once a set volume is reached
/obj/machinery/plumbing/pill_press
	name = "pill press"
	desc = "A press that presses pills."
	icon_state = "pill_press"
	///the minimum size a pill can be
	var/minimum_pill = 5
	///the maximum size a pill can be
	var/maximum_pill = 50
	///the size of the pill
	var/pill_size = 10
	///pill name
	var/pill_name = "factory pill"
	///the icon_state number for the pill.
	var/pill_number = RANDOM_PILL_STYLE
	///list of id's and icons for the pill selection of the ui
	var/list/pill_styles

	var/xen = 500
	var/yen = 500

/obj/machinery/plumbing/pill_press/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand)

	//expertly copypasted from chemmasters
	var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/simple/pills)
	pill_styles = list()
	for (var/x in 1 to PILL_STYLE_COUNT)
		var/list/SL = list()
		SL["id"] = x
		SL["htmltag"] = assets.icon_tag("pill[x]")
		pill_styles += list(SL)

/obj/machinery/plumbing/pill_press/wrench_act(mob/living/user, obj/item/I)
	default_unfasten_wrench(user, I)
	return TRUE

/obj/machinery/plumbing/pill_press/process()
	if(stat & NOPOWER)
		return
	if(reagents.total_volume >= pill_size)
		var/obj/item/reagent_containers/pill/P = new(drop_location())
		reagents.trans_to(P, pill_size)
		P.name = pill_name
		if(pill_number == RANDOM_PILL_STYLE)
			P.icon_state = "pill[rand(1,21)]"
		else 
			P.icon_state = "pill[pill_number]"
		if(P.icon_state == "pill4") //mirrored from chem masters
			P.desc = "A tablet or capsule, but not just any, a red one, one taken by the ones not scared of knowledge, freedom, uncertainty and the brutal truths of reality."

/obj/machinery/plumbing/pill_press/ui_base_html(html)
	var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/simple/pills)
	. = replacetext(html, "<!--customheadhtml-->", assets.css_tag())

/obj/machinery/plumbing/pill_press/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		var/datum/asset/assets = get_asset_datum(/datum/asset/spritesheet/simple/pills)
		assets.send(user)
		ui = new(user, src, ui_key, "chem_press", name, 410, 300, master_ui, state)
		ui.open()

/obj/machinery/plumbing/pill_press/ui_data(mob/user)
	var/list/data = list()
	data["pill_style"] = pill_number
	data["pill_size"] = pill_size
	data["pill_name"] = pill_name
	data["pill_styles"] = pill_styles
	return data

/obj/machinery/plumbing/pill_press/ui_act(action, params)
	if(..())
		return
	. = TRUE
	switch(action)
		if("change_pill_style")
			pill_number = CLAMP(text2num(params["id"]), 1 , PILL_STYLE_COUNT)
		if("change_pill_size")
			pill_size = round(CLAMP(input("New target volume", name, pill_size) as num|null, minimum_pill, maximum_pill))
		if("change_pill_name")
			var/new_name = stripped_input(usr, "Enter a pill name.", name, pill_name)
			if(findtext(new_name, "pill")) //names like pillatron and Pilliam are thus valid
				pill_name = new_name
			else 
				pill_name = new_name + " pill"
