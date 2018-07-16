GLOBAL_DATUM(ore_silo_default, /obj/machinery/ore_silo)
GLOBAL_LIST_EMPTY(silo_access_logs)

/obj/machinery/ore_silo
	name = "ore silo"
	desc = "An all-in-one bluespace storage and transmission system for the station's mineral distribution needs."
	icon = 'icons/obj/mining.dmi'
	icon_state = "bin"
	density = TRUE

	var/list/lathes = list()
	var/list/orms = list()
	var/list/holds = list()

/obj/machinery/ore_silo/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/material_container,
		list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TITANIUM, MAT_BLUESPACE),
		INFINITY,
		FALSE,
		list(/obj/item/stack),
		null,
		null,
		TRUE)
	if (!GLOB.ore_silo_default && mapload && is_station_level(z))
		GLOB.ore_silo_default = src

/obj/machinery/ore_silo/Destroy()
	if (GLOB.ore_silo_default == src)
		GLOB.ore_silo_default = null

	for(var/O in orms)
		var/obj/machinery/mineral/orm = O
		if (orm.silo == src)
			orm.silo = null

	for(var/L in lathes)
		var/obj/machinery/rnd/production/lathe = L
		if (lathe.silo == src)
			lathe.silo = null
			lathe.materials = null

	GET_COMPONENT(materials, /datum/component/material_container)
	materials.retrieve_all()

	return ..()

/obj/machinery/ore_silo/proc/remote_attackby(obj/machinery/M, mob/user, obj/item/stack/I)
	GET_COMPONENT(materials, /datum/component/material_container)
	// stolen from /datum/component/material_container/proc/OnAttackBy
	if(user.a_intent != INTENT_HELP)
		return
	if(I.item_flags & ABSTRACT)
		return
	if(!istype(I) || (I.flags_1 & HOLOGRAM_1) || (I.item_flags & NO_MAT_REDEMPTION))
		to_chat(user, "<span class='warning'>[M] won't accept [I]!</span>")
		return
	var/item_mats = I.materials & materials.materials
	if(!length(item_mats))
		to_chat(user, "<span class='warning'>[I] does not contain sufficient materials to be accepted by [M].</span>")
		return
	// assumes unlimited space...
	var/amount = I.amount
	materials.user_insert(I, user)
	silo_log(M, "deposited", amount, "sheets", item_mats)
	return TRUE

/obj/machinery/ore_silo/attackby(obj/item/W, mob/user, params)
	if (istype(W, /obj/item/stack))
		return remote_attackby(src, user, W)
	return ..()

/obj/machinery/ore_silo/ui_interact(mob/user)
	user.set_machine(src)
	var/datum/browser/popup = new(user, "ore_silo", null, 560, 550)
	popup.set_content(generate_ui())
	popup.open()

/obj/machinery/ore_silo/proc/generate_ui()
	GET_COMPONENT(materials, /datum/component/material_container)
	var/list/ui = list("<head><title>Ore Silo</title></head><body><div class='statusDisplay'><h2>Stored Material:</h2>")
	var/any = FALSE
	for(var/M in materials.materials)
		var/datum/material/mat = materials.materials[M]
		if (mat.amount)
			ui += "<b>[mat.name]</b>: [round(mat.amount) / MINERAL_MATERIAL_AMOUNT] sheets<br>"
			any = TRUE
	if(!any)
		ui += "Nothing!"

	ui += "</div><div class='statusDisplay'><h2>Connected Machines:</h2>"
	for(var/orm in orms)
		var/obj/machinery/mineral/O = orm
		var/hold_key = "[get_area(O)]/orm"
		var/msg = holds[hold_key] ? "Allow" : "Hold"
		ui += "<a href='?src=[REF(src)];remove_orm=[REF(O)]'>Remove</a><a href='?src=[REF(src)];hold[!holds[hold_key]]=[url_encode(hold_key)]'>[msg]</a> <b>[O.name]</b> in [get_area_name(O, TRUE)]<br>"
	for(var/lathe in lathes)
		var/obj/machinery/rnd/production/L = lathe
		var/hold_key = "[get_area(L)]/lathe"
		var/msg = holds[hold_key] ? "Allow" : "Hold"
		ui += "<a href='?src=[REF(src)];remove_lathe=[REF(L)]'>Remove</a><a href='?src=[REF(src)];hold[!holds[hold_key]]=[url_encode(hold_key)]'>[msg]</a> <b>[L.name]</b> in [get_area_name(L, TRUE)]<br>"
	if(orms.len == 0 && lathes.len == 0)
		ui += "Nothing!"

	ui += "</div><div class='statusDisplay'><h2>Access Logs:</h2><ol>"
	any = FALSE
	for(var/M in GLOB.silo_access_logs[REF(src)])
		var/datum/ore_silo_log/entry = M
		ui += "<li>[entry.formatted]</li>"
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

	if(href_list["remove_orm"])
		var/obj/machinery/mineral/orm = locate(href_list["remove_orm"])
		if (istype(orm))
			orms -= orm
			if (orm.silo == src)
				orm.silo = null
			updateUsrDialog()
			return TRUE
	else if(href_list["remove_lathe"])
		var/obj/machinery/rnd/production/lathe = locate(href_list["remove_lathe"])
		if (istype(lathe))
			lathes -= lathe
			if (lathe.silo == src)
				lathe.silo = null
				lathe.materials = null
			updateUsrDialog()
			return TRUE
	else if(href_list["hold1"])
		holds[href_list["hold1"]] = TRUE
		updateUsrDialog()
		return TRUE
	else if(href_list["hold0"])
		holds -= href_list["hold0"]
		updateUsrDialog()
		return TRUE

/obj/machinery/ore_silo/multitool_act(mob/living/user, obj/item/multitool/I)
	if (istype(I))
		to_chat(user, "<span class='notice'>You log [src] in the multitool's buffer.</span>")
		I.buffer = src
		return TRUE

/obj/machinery/ore_silo/proc/on_hold(obj/machinery/M)
	var/category = "lathe"
	if(istype(M, /obj/machinery/mineral))
		category = "orm"
	return holds["[get_area(M)]/[category]"]

/obj/machinery/ore_silo/proc/silo_log(obj/machinery/M, action, amount, noun, list/mats)
	if (!length(mats))
		return
	var/datum/ore_silo_log/entry = new(M, action, amount, noun, mats)

	var/list/logs = GLOB.silo_access_logs[REF(src)]
	if(!LAZYLEN(logs))
		GLOB.silo_access_logs[REF(src)] = logs = list(entry)
	else if(!logs[1].merge(entry))
		logs.Insert(1, entry)

	updateUsrDialog()
	animate(src, icon_state = "bin_partial", time = 2)
	animate(icon_state = "bin_full", time = 1)
	animate(icon_state = "bin_partial", time = 2)
	animate(icon_state = "bin")

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
	for(var/each in materials)
		materials[each] *= abs(_amount)
	format()

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

	var/list/msg = list("([timestamp]) <b>[machine_name]</b> in [area_name]<br>[action] [abs(amount)]x [noun]<br>")
	var/sep = ""
	for(var/key in materials)
		var/val = round(materials[key]) / MINERAL_MATERIAL_AMOUNT
		msg += sep
		sep = ", "
		msg += "[amount < 0 ? "-" : "+"][val] [copytext(key, 2)]"
	formatted = msg.Join()
