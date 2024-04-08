/obj/machinery/slime_market_pad
	name = "intergalactic market pad"
	desc = "A tall device with a hole for inserting slime extracts. IMPs are widely used for trading small items on large distances all over the galaxy."
	icon = 'monkestation/code/modules/slimecore/icons/machinery.dmi'
	icon_state = "market_pad"
	base_icon_state = "market_pad"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 2000
	circuit = /obj/item/circuitboard/machine/slime_market_pad
	var/obj/machinery/computer/slime_market/console

/obj/machinery/slime_market_pad/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		user.visible_message(span_notice("\The [user] [panel_open ? "opens" : "closes"] the hatch on \the [src]."), span_notice("You [panel_open ? "open" : "close"] the hatch on \the [src]."))
		update_appearance()
		return TRUE

	if(default_unfasten_wrench(user, I))
		return TRUE

	if(default_deconstruction_crowbar(I))
		return TRUE

	. = ..()

/obj/machinery/slime_market_pad/examine(mob/user)
	. = ..()
	if(!panel_open)
		. += span_notice("The panel is <i>screwed</i> in.")

/obj/machinery/slime_market_pad/update_overlays()
	. = ..()
	if(panel_open)
		. += "market_pad-panel"

/obj/machinery/slime_market_pad/Initialize(mapload)
	. = ..()
	link_console()

/obj/machinery/slime_market_pad/AltClick(mob/user)
	. = ..()
	link_console()

/obj/machinery/slime_market_pad/proc/link_console()
	if(console)
		return

	for(var/direction in GLOB.cardinals)
		console = locate(/obj/machinery/computer/slime_market, get_step(src, direction))
		if(console)
			console.link_market_pad()
			break

/obj/machinery/slime_market_pad/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(!console)
		to_chat(user, span_warning("[src] does not have a console linked to it!"))
		return

	if(istype(I, /obj/item/slime_extract))
		var/obj/item/slime_extract/extract = I
		if(extract.tier == 0)
			to_chat(user, span_warning("[src] doesn't seem to accept this extract!"))
			return
		flick("[base_icon_state]_vend", src)
		sell_extract(extract)
		return

	else if(istype(I, /obj/item/storage/bag/xeno))
		if(tgui_alert(user, "Are you sure you want to sell all extracts from [I]?", "<3?", list("Yes", "No")) != "Yes")
			return

		flick("[base_icon_state]_vend", src)
		for(var/obj/item/slime_extract/extract in I)
			if(extract.tier == 0)
				continue
			sell_extract(extract)
		return

/obj/machinery/slime_market_pad/proc/sell_extract(obj/item/slime_extract/extract)
	SSresearch.xenobio_points += round(SSresearch.slime_core_prices[extract.type])

	var/price_mod = rand(SLIME_SELL_MODIFIER_MIN * 10000, SLIME_SELL_MODIFIER_MAX * 10000) / 10000
	var/price_limiter = 1 - ((SSresearch.default_core_prices[extract.tier] * SLIME_SELL_MINIMUM_MODIFIER) / SSresearch.slime_core_prices[extract.type])
	SSresearch.slime_core_prices[extract.type] = (1 + price_mod * price_limiter) * SSresearch.slime_core_prices[extract.type]

	for(var/core_type in SSresearch.slime_core_prices)
		if(core_type == extract.type)
			continue

		var/obj/item/slime_extract/core = core_type
		price_mod = rand(SLIME_SELL_OTHER_MODIFIER_MIN * 100000, SLIME_SELL_OTHER_MODIFIER_MAX * 100000) / 100000
		price_limiter = 1 - (SSresearch.slime_core_prices[core_type] / (SSresearch.default_core_prices[initial(core.tier)] * SLIME_SELL_MAXIMUM_MODIFIER))

		SSresearch.slime_core_prices[core_type] = (1 + price_mod * price_limiter) * SSresearch.slime_core_prices[core_type]
	qdel(extract)

/obj/machinery/slime_market_pad/attackby_secondary(obj/item/weapon, mob/user, params)
	if(!console)
		to_chat(user, span_warning("[src] does not have a console linked to it!"))
		return

	if(!console.request_pad)
		to_chat(user, span_warning("[console] does not have a request_pad linked to it!"))
		return

	if(!length(console.request_pad.current_requests))
		to_chat(user, span_warning("There are no current extract requests!"))
		return

	if(istype(weapon, /obj/item/slime_extract))
		var/list/radial_choices = list()
		var/list/choice_to_request = list()
		var/obj/item/slime_extract/extract = weapon
		for(var/datum/extract_request_data/current as anything in console.request_pad.current_requests)
			if((current.extract_path != extract.type) || current.ready_for_pickup)
				continue
			radial_choices |= current.radial_data
			choice_to_request |= list(current.request_name = current)

		if(!length(radial_choices))
			say("There are no current extract requests that need this extract!")
			return

		var/choice = show_radial_menu(user, src, radial_choices, require_near = TRUE, tooltips = TRUE)
		if(!choice_to_request[choice])
			return

		var/datum/extract_request_data/chosen = choice_to_request[choice]
		chosen.add_extract()

		flick("[base_icon_state]_vend", src)
		qdel(extract)

		return
