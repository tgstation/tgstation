//Black Box

/obj/machinery/smartfridge/black_box
	name = "black box"
	desc = "A completely indestructible chunk of crystal, rumoured to predate the start of this universe. It looks like you could store things inside it."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_on = "blackbox"
	icon_off = "blackbox"
	luminosity = 8
	max_n_of_items = 10
	pixel_y = -4
	use_power = 0
	var/duplicate = FALSE
	var/memory_saved = FALSE
	var/list/stored_items = list()

/obj/machinery/smartfridge/black_box/accept_check(obj/item/O)
	if(istype(O, /obj/item))
		return 1
	return 0

/obj/machinery/smartfridge/black_box/New()
	..()
	for(var/obj/machinery/smartfridge/black_box/B in machines)
		if(B != src)
			duplicate = 1
			qdel(src)
	ReadMemory()

/obj/machinery/smartfridge/black_box/process()
	..()
	if(ticker.current_state == GAME_STATE_FINISHED && !memory_saved)
		WriteMemory()

/obj/machinery/smartfridge/black_box/proc/WriteMemory()
	var/savefile/S = new /savefile("data/npc_saves/Blackbox.sav")
	stored_items = list()
	for(var/obj/I in component_parts)
		qdel(I)
	for(var/obj/O in contents)
		stored_items += O.type
	S["stored_items"]				<< stored_items
	memory_saved = TRUE

/obj/machinery/smartfridge/black_box/proc/ReadMemory()
	var/savefile/S = new /savefile("data/npc_saves/Blackbox.sav")
	S["stored_items"] 		>> stored_items

	if(isnull(stored_items))
		stored_items = list()

	for(var/item in stored_items)
		new item(src)


/obj/machinery/smartfridge/black_box/Destroy()
	if(duplicate)
		..()
	else
		return QDEL_HINT_LETMELIVE


//No taking it apart

/obj/machinery/smartfridge/black_box/default_deconstruction_screwdriver()
	return

/obj/machinery/smartfridge/black_box/exchange_parts()
	return


/obj/machinery/smartfridge/black_box/default_pry_open()
	return


/obj/machinery/smartfridge/black_box/default_unfasten_wrench()
	return

/obj/machinery/smartfridge/black_box/default_deconstruction_crowbar()
	return
