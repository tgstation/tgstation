GLOBAL_DATUM(ore_silo_default, /obj/machinery/ore_silo)
GLOBAL_LIST_EMPTY(silo_access_logs)

/obj/machinery/ore_silo
	name = "ore silo"
	desc = "An all-in-one bluespace storage and transmission system for the station's mineral distribution needs."
	icon = 'icons/obj/machines/ore_silo.dmi'
	icon_state = "silo"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/ore_silo

	/// The machine UI's page of logs showing ore history.
	var/log_page = 1
	/// List of all connected components that are on hold from accessing materials.
	var/list/holds = list()
	/// List of all components that are sharing ores with this silo.
	var/list/datum/component/remote_materials/ore_connected_machines = list()
	/// Material Container
	var/datum/component/material_container/materials

/obj/machinery/ore_silo/Initialize(mapload)
	. = ..()
	var/static/list/materials_list = list(
		/datum/material/iron,
		/datum/material/glass,
		/datum/material/silver,
		/datum/material/gold,
		/datum/material/diamond,
		/datum/material/plasma,
		/datum/material/uranium,
		/datum/material/bananium,
		/datum/material/titanium,
		/datum/material/bluespace,
		/datum/material/plastic,
		)
	materials = AddComponent( \
		/datum/component/material_container, \
		materials_list, \
		INFINITY, \
		MATCONTAINER_NO_INSERT, \
		allowed_items = /obj/item/stack \
	)
	if (!GLOB.ore_silo_default && mapload && is_station_level(z))
		GLOB.ore_silo_default = src

/obj/machinery/ore_silo/Destroy()
	if (GLOB.ore_silo_default == src)
		GLOB.ore_silo_default = null

	for(var/datum/component/remote_materials/mats as anything in ore_connected_machines)
		mats.disconnect_from(src)

	ore_connected_machines = null
	materials = null

	return ..()

/obj/machinery/ore_silo/proc/remote_attackby(obj/machinery/M, mob/living/user, obj/item/stack/I, breakdown_flags=NONE)
	if(user.combat_mode)
		return
	if(I.item_flags & ABSTRACT)
		return
	if(!istype(I) || (I.flags_1 & HOLOGRAM_1) || (I.item_flags & NO_MAT_REDEMPTION))
		to_chat(user, span_warning("[M] won't accept [I]!"))
		return
	var/item_mats = materials.get_item_material_amount(I, breakdown_flags)
	if(!item_mats)
		to_chat(user, span_warning("[I] does not contain sufficient materials to be accepted by [M]."))
		return
	// assumes unlimited space...
	var/amount = I.amount
	materials.user_insert(I, user, breakdown_flags)
	var/list/matlist = I.get_material_composition(breakdown_flags)
	silo_log(M, "deposited", amount, I.name, matlist)
	return TRUE

/obj/machinery/ore_silo/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, W))
		updateUsrDialog()
		return
	if(default_deconstruction_crowbar(W))
		return

	if(!powered())
		return ..()

	if (isstack(W))
		return remote_attackby(src, user, W)

	return ..()

/obj/machinery/ore_silo/ui_interact(mob/user)
	user.set_machine(src)
	var/datum/browser/popup = new(user, "ore_silo", null, 600, 550)
	popup.set_content(generate_ui())
	popup.open()

/obj/machinery/ore_silo/proc/generate_ui()
	var/list/ui = list("<head><title>Ore Silo</title></head><body><div class='statusDisplay'><h2>Stored Material:</h2>")
	var/any = FALSE
	for(var/M in materials.materials)
		var/datum/material/mat = M
		var/amount = materials.materials[M]
		var/sheets = round(amount) / SHEET_MATERIAL_AMOUNT
		var/ref = REF(M)
		if (sheets)
			if (sheets >= 1)
				ui += "<a href='?src=[REF(src)];ejectsheet=[ref];eject_amt=1'>Eject</a>"
			else
				ui += "<span class='linkOff'>Eject</span>"
			if (sheets >= 20)
				ui += "<a href='?src=[REF(src)];ejectsheet=[ref];eject_amt=20'>20x</a>"
			else
				ui += "<span class='linkOff'>20x</span>"
			ui += "<b>[mat.name]</b>: [sheets] sheets<br>"
			any = TRUE
	if(!any)
		ui += "Nothing!"

	ui += "</div><div class='statusDisplay'><h2>Connected Machines:</h2>"
	for(var/datum/component/remote_materials/mats as anything in ore_connected_machines)
		var/atom/parent = mats.parent
		ui += "<a href='?src=[REF(src)];remove=[REF(mats)]'>Remove</a>"
		ui += "<a href='?src=[REF(src)];hold=[REF(mats)]'>[holds[mats] ? "Allow" : "Hold"]</a>"
		ui += " <b>[parent.name]</b> in [get_area_name(parent, TRUE)]<br>"
	if(!ore_connected_machines.len)
		ui += "Nothing!"

	ui += "</div><div class='statusDisplay'><h2>Access Logs:</h2>"
	var/list/logs = GLOB.silo_access_logs[REF(src)]
	var/len = LAZYLEN(logs)
	var/num_pages = 1 + round((len - 1) / 30)
	var/page = clamp(log_page, 1, num_pages)
	if(num_pages > 1)
		for(var/i in 1 to num_pages)
			if(i == page)
				ui += "<span class='linkOff'>[i]</span>"
			else
				ui += "<a href='?src=[REF(src)];page=[i]'>[i]</a>"

	ui += "<ol>"
	any = FALSE
	for(var/i in (page - 1) * 30 + 1 to min(page * 30, len))
		var/datum/ore_silo_log/entry = logs[i]
		ui += "<li value=[len + 1 - i]>[entry.formatted]</li>"
		any = TRUE
	if (!any)
		ui += "<li>Nothing!</li>"

	ui += "</ol></div>"
	return ui.Join()

/obj/machinery/ore_silo/Topic(href, href_list)
	if(..())
		return
	add_fingerprint(usr)
	usr.set_machine(src)

	if(href_list["remove"])
		var/datum/component/remote_materials/mats = locate(href_list["remove"]) in ore_connected_machines
		if (mats)
			mats.disconnect_from(src)
			updateUsrDialog()
			return TRUE
	else if(href_list["hold"])
		var/datum/component/remote_materials/mats = locate(href_list["hold"]) in ore_connected_machines
		mats.toggle_holding()
		updateUsrDialog()
		return TRUE
	else if(href_list["ejectsheet"])
		var/datum/material/eject_sheet = locate(href_list["ejectsheet"])
		var/count = materials.retrieve_sheets(text2num(href_list["eject_amt"]), eject_sheet, drop_location())
		var/list/matlist = list()
		matlist[eject_sheet] = SHEET_MATERIAL_AMOUNT * count
		silo_log(src, "ejected", -count, "sheets", matlist)
		return TRUE
	else if(href_list["page"])
		log_page = text2num(href_list["page"]) || 1
		updateUsrDialog()
		return TRUE

/obj/machinery/ore_silo/multitool_act(mob/living/user, obj/item/multitool/I)
	. = ..()
	if (istype(I))
		to_chat(user, span_notice("You log [src] in the multitool's buffer."))
		I.set_buffer(src)
		return TRUE

/**
 * Creates a log entry for depositing/withdrawing from the silo both ingame and in text based log
 *
 * Arguments:
 * - [M][/obj/machinery]: The machine performing the action.
 * - action: Text that visually describes the action (smelted/deposited/resupplied...)
 * - amount: The amount of sheets/objects deposited/withdrawn by this action. Positive for depositing, negative for withdrawing.
 * - noun: Name of the object the action was performed with (sheet, units, ore...)
 * - [mats][list]: Assoc list in format (material datum = amount of raw materials). Wants the actual amount of raw (iron, glass...) materials involved in this action. If you have 10 metal sheets each worth 100 iron you would pass a list with the iron material datum = 1000
 */
/obj/machinery/ore_silo/proc/silo_log(obj/machinery/M, action, amount, noun, list/mats)
	if (!length(mats))
		return
	var/datum/ore_silo_log/entry = new(M, action, amount, noun, mats)
	var/list/datum/ore_silo_log/logs = GLOB.silo_access_logs[REF(src)]
	if(!LAZYLEN(logs))
		GLOB.silo_access_logs[REF(src)] = logs = list(entry)
	else if(!logs[1].merge(entry))
		logs.Insert(1, entry)

	updateUsrDialog()
	flick("silo_active", src)

/obj/machinery/ore_silo/examine(mob/user)
	. = ..()
	. += span_notice("[src] can be linked to techfabs, circuit printers and protolathes with a multitool.")

/datum/ore_silo_log
	var/name  // for VV
	var/formatted  // for display

	var/timestamp
	var/machine_name
	var/area_name
	var/action
	var/noun
	var/amount
	var/list/materials

/datum/ore_silo_log/New(obj/machinery/M, _action, _amount, _noun, list/mats=list())
	timestamp = station_time_timestamp()
	machine_name = M.name
	area_name = get_area_name(M, TRUE)
	action = _action
	amount = _amount
	noun = _noun
	materials = mats.Copy()
	format()
	var/list/data = list(
		"machine_name" = machine_name,
		"area_name" = AREACOORD(M),
		"action" = action,
		"amount" = abs(amount),
		"noun" = noun,
		"raw_materials" = get_raw_materials(""),
		"direction" = amount < 0 ? "withdrawn" : "deposited",
	)
	logger.Log(
		LOG_CATEGORY_SILO,
		"[machine_name] in \[[AREACOORD(M)]\] [action] [abs(amount)]x [noun] | [get_raw_materials("")]",
		data,
	)

/datum/ore_silo_log/proc/merge(datum/ore_silo_log/other)
	if (other == src || action != other.action || noun != other.noun)
		return FALSE
	if (machine_name != other.machine_name || area_name != other.area_name)
		return FALSE

	timestamp = other.timestamp
	amount += other.amount
	for(var/each in other.materials)
		materials[each] += other.materials[each]
	format()
	return TRUE

/datum/ore_silo_log/proc/format()
	name = "[machine_name]: [action] [amount]x [noun]"
	formatted = "([timestamp]) <b>[machine_name]</b> in [area_name]<br>[action] [abs(amount)]x [noun]<br> [get_raw_materials("")]"

/datum/ore_silo_log/proc/get_raw_materials(separator)
	var/list/msg = list()
	for(var/key in materials)
		var/datum/material/M = key
		var/val = round(materials[key])
		msg += separator
		separator = ", "
		msg += "[amount < 0 ? "-" : "+"][val] [M.name]"
	return msg.Join()
