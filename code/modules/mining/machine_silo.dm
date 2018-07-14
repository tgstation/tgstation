GLOBAL_DATUM(ore_silo_default, /obj/machinery/ore_silo)
GLOBAL_LIST_EMPTY(silo_access_logs)

/obj/machinery/ore_silo
	name = "ore silo"
	desc = ""
	icon = 'icons/obj/mining.dmi'
	icon_state = "bin"
	density = TRUE

	var/list/lathes = list()
	var/list/orms = list()

/obj/machinery/ore_silo/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/material_container,
		list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TITANIUM, MAT_BLUESPACE),
		INFINITY,
		FALSE,
		list(/obj/item/stack))
	if (!GLOB.ore_silo_default && mapload && is_station_level(z))
		GLOB.ore_silo_default = src

/obj/machinery/ore_silo/Destroy()
	if (GLOB.ore_silo_default == src)
		GLOB.ore_silo_default = null

	for(var/O in orms)
		var/obj/machinery/mineral/ore_redemption/orm = O
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

/obj/machinery/ore_silo/proc/silo_log(obj/machinery/M, message, list/mats=null, multiplier=1)
	var/list/msg = list("([station_time_timestamp()]) <b>[M]</b> in [get_area(M)]<br>[message]<br>")
	var/sep = ""
	for(var/key in mats)
		var/val = mats[key] * multiplier
		msg += sep
		sep = ", "
		msg += "[val > 0 ? "+" : ""][val] [copytext(key, 2)]"

	var/list/logs = GLOB.silo_access_logs[REF(src)]
	if(!logs)
		GLOB.silo_access_logs[REF(src)] = logs = list()
	logs.Insert(1, msg.Join())
	updateUsrDialog()

	animate(src, icon_state = "bin_partial", time = 2)
	animate(icon_state = "bin_full", time = 1)
	animate(icon_state = "bin_partial", time = 2)
	animate(icon_state = "bin")

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
			ui += "<b>[mat.name]</b>: [mat.amount] units<br>"
			any = TRUE
	if(!any)
		ui += "Nothing!"

	ui += "</div><div class='statusDisplay'><h2>Connected Machines:</h2>"
	for(var/O in orms)
		ui += "<a href='?src=[REF(src)];remove_orm=[REF(O)]'>Remove</a> <b>\The [O]</b> in [get_area(O)]<br>"
	for(var/L in lathes)
		ui += "<a href='?src=[REF(src)];remove_lathe=[REF(L)]'>Remove</a> <b>\The [L]</b> in [get_area(L)]<br>"
	if(orms.len == 0 && lathes.len == 0)
		ui += "Nothing!"

	ui += "</div><div class='statusDisplay'><h2>Access Logs:</h2><ol>"
	any = FALSE
	for(var/M in GLOB.silo_access_logs[REF(src)])
		ui += "<li>[M]</li>"
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
		var/obj/machinery/mineral/ore_redemption/orm = locate(href_list["remove_orm"])
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

/obj/machinery/ore_silo/multitool_act(mob/living/user, obj/item/multitool/I)
	if (istype(I))
		to_chat(user, "<span class='notice'>You log [src] in the multitool's buffer.</span>")
		I.buffer = src
		return TRUE
