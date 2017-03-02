

/*
Destructive Analyzer

It is used to destroy hand-held objects and advance technological research. Controls are in the linked R&D console.

Note: Must be placed within 3 tiles of the R&D Console
*/
/obj/machinery/r_n_d/destructive_analyzer
	name = "Destructive Analyzer"
	desc = "Learn science by destroying things!"
	icon_state = "d_analyzer"
	var/decon_mod = 0

/obj/machinery/r_n_d/destructive_analyzer/New()
	..()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/destructive_analyzer(null)
	B.apply_default_parts(src)

/obj/item/weapon/circuitboard/machine/destructive_analyzer
	name = "Destructive Analyzer (Machine Board)"
	build_path = /obj/machinery/r_n_d/destructive_analyzer
	origin_tech = "magnets=2;engineering=2;programming=2"
	req_components = list(
							/obj/item/weapon/stock_parts/scanning_module = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1)

/obj/machinery/r_n_d/destructive_analyzer/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/S in component_parts)
		T += S.rating
	decon_mod = T


/obj/machinery/r_n_d/destructive_analyzer/proc/ConvertReqString2List(list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list

/obj/machinery/r_n_d/destructive_analyzer/disconnect_console()
	linked_console.linked_destroy = null
	..()

/obj/machinery/r_n_d/destructive_analyzer/Insert_Item(obj/item/O, mob/user)
	if(user.a_intent != INTENT_HARM)
		. = 1
		if(!is_insertion_ready(user))
			return
		if(!O.origin_tech)
			user << "<span class='warning'>This doesn't seem to have a tech origin!</span>"
			return
		var/list/temp_tech = ConvertReqString2List(O.origin_tech)
		if (temp_tech.len == 0)
			user << "<span class='warning'>You cannot deconstruct this item!</span>"
			return
		if(!user.drop_item())
			user << "<span class='warning'>\The [O] is stuck to your hand, you cannot put it in the [src.name]!</span>"
			return
		busy = 1
		loaded_item = O
		O.forceMove(src)
		user << "<span class='notice'>You add the [O.name] to the [src.name]!</span>"
		flick("d_analyzer_la", src)
		spawn(10)
			icon_state = "d_analyzer_l"
			busy = 0
