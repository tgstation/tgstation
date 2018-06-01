GLOBAL_DATUM(ore_silo, /obj/machinery/ore_silo)
GLOBAL_LIST_EMPTY(silo_access_lathes)
GLOBAL_LIST_EMPTY(silo_access_log)

/obj/machinery/ore_silo
	name = "ore silo" // construct additional silos, commander
	desc = "Stores the station's ore. "
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "ore_silo"
	density = TRUE
	anchored = TRUE

/obj/machinery/ore_silo/Initialize()
	. = ..()
	AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TITANIUM, MAT_BLUESPACE),INFINITY, FALSE, list(/obj/item/stack))
	if(!GLOB.ore_silo)
		GLOB.ore_silo = src

/obj/machinery/ore_silo/Destroy()
	GET_COMPONENT(materials, /datum/component/material_container)
	materials.retrieve_all()
	if(GLOB.ore_silo == src)
		GLOB.ore_silo = null
	. = ..()

/obj/machinery/ore_silo/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/multitool))
		var/obj/item/multitool/M = I
		if(M.buffer)
			if(istype(M.buffer, /obj/machinery/rnd/production))
				to_chat(user, "You link [src] to [M.buffer], enabling ore access.")
				GLOB.silo_access_lathes[M.buffer] = TRUE
				M.buffer = null

/obj/machinery/ore_silo/ui_interact(mob/user)
	user.set_machine(src)
	var/datum/browser/popup = new(user, "ore_silo", name, 460, 550)
	popup.set_content(generate_ui())
	popup.open()
// <div><a href='?src=[REF(src)];show_logs=1'>Refresh</a></div>
/obj/machinery/ore_silo/proc/generate_ui()
	GET_COMPONENT(materials, /datum/component/material_container)
	var/ui_string = "<head><title>Ore Silo</title></head><body><h2>Stored Material:</h2><br>"
	for(var/M in materials.materials)
		var/datum/material/MAT = materials.materials[M]
		if(MAT.amount)
			ui_string += "<b>[MAT.name]</b>: [MAT.amount] units<br>"
	ui_string += "<h2>Connected Machines:</h2>
	for(var/L in GLOB.silo_access_lathes)
		if(GLOB.silo_access_lathes[L])
			ui_string += "<b>[L]</b> in <b>[get_area(L)]</b> (<a href='?src=[REF(src)];remove_link=[REF(L)]'>Remove Link</a>)"
	return ui_string
