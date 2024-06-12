/obj/item/wallframe/bluespace_vendor_mount
	name = "bluespace vendor wall mount"
	desc = "Used for placing bluespace vendors."
	icon = 'icons/obj/machines/atmospherics/bluespace_gas_selling.dmi'
	icon_state = "bluespace_vendor_open"
	result_path = /obj/machinery/bluespace_vendor/built
	pixel_shift = 30

///Defines for the mode of the vendor
#define BS_MODE_OFF 1
#define BS_MODE_IDLE 2
#define BS_MODE_PUMPING 3
#define BS_MODE_OPEN 4

/obj/machinery/bluespace_vendor
	icon = 'icons/obj/machines/atmospherics/bluespace_gas_selling.dmi'
	icon_state = "bluespace_vendor_off"
	base_icon_state = "bluespace_vendor"
	name = "Bluespace Gas Vendor"
	desc = "Sells gas tanks with custom mixes for all the family!"

	max_integrity = 300
	armor_type = /datum/armor/machinery_bluespace_vendor
	layer = OBJ_LAYER

	///The bluespace sender that this vendor is connected to
	var/obj/machinery/atmospherics/components/unary/bluespace_sender/connected_machine
	///Amount of usable tanks inside the machine
	var/empty_tanks = 10
	///Reference to the current in use tank to be filled
	var/obj/item/tank/internals/generic/internal_tank
	///Path of the gas selected from the UI to be pumped inside the tanks
	var/selected_gas
	///Is the vendor trying to move gases from the network to the tanks?
	var/pumping = FALSE
	///Has the user prepared a tank to be filled with gases?
	var/inserted_tank = FALSE
	///Amount of the tank already filled with gas (from 0 to 100)
	var/tank_filling_amount = 0
	///Base price of the tank
	var/tank_cost = 10
	///Stores the current price of the gases inside the tank
	var/gas_price = 0
	///Helper for mappers, will automatically connect to the sender (ensure to only place one sender per map)
	var/map_spawned = TRUE
	///Current operating mode of the vendor
	var/mode = BS_MODE_OFF

//The one that the players make
/obj/machinery/bluespace_vendor/built
	map_spawned = FALSE
	mode = BS_MODE_OPEN

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/bluespace_vendor, 30)

/datum/armor/machinery_bluespace_vendor
	energy = 100
	fire = 80
	acid = 30

/obj/machinery/bluespace_vendor/New(loc, ndir, nbuild)
	. = ..()

	if(nbuild)
		set_panel_open(TRUE)

	update_appearance()

/obj/machinery/bluespace_vendor/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/payment, tank_cost, SSeconomy.get_dep_account(ACCOUNT_ENG), PAYMENT_ANGRY)
	find_and_hang_on_wall( FALSE)

/obj/machinery/bluespace_vendor/post_machine_initialize()
	. = ..()
	if(!map_spawned)
		return
	for(var/obj/machinery/atmospherics/components/unary/bluespace_sender/sender as anything in GLOB.bluespace_senders)
		register_machine(sender)

/obj/machinery/bluespace_vendor/Destroy()
	unregister_machine()
	return ..()

/obj/machinery/bluespace_vendor/update_icon_state()
	switch(mode)
		if(BS_MODE_OFF)
			icon_state = "[base_icon_state]_off"
		if(BS_MODE_IDLE)
			icon_state = "[base_icon_state]_idle"
		if(BS_MODE_PUMPING)
			icon_state = "[base_icon_state]_pumping"
		if(BS_MODE_OPEN)
			icon_state = "[base_icon_state]_open"
	return ..()

/obj/machinery/bluespace_vendor/Exited(atom/movable/gone, direction)
	if(gone == internal_tank)
		internal_tank = null
	return ..()

/obj/machinery/bluespace_vendor/process()
	if(mode == BS_MODE_OPEN)
		return
	if(!selected_gas)
		return
	var/gas_path = gas_id2path(selected_gas)

	if(!connected_machine.bluespace_network.gases[gas_path])
		pumping = FALSE
		selected_gas = null
		mode = BS_MODE_IDLE
		update_appearance()
		return

	connected_machine.bluespace_network.pump_gas_to(internal_tank.return_air(), (tank_filling_amount * 0.01) * 10 * ONE_ATMOSPHERE, gas_path)

/obj/machinery/bluespace_vendor/multitool_act(mob/living/user, obj/item/multitool/multitool)
	if(!istype(multitool))
		return
	if(!istype(multitool.buffer, /obj/machinery/atmospherics/components/unary/bluespace_sender))
		to_chat(user, span_notice("Wrong machine type in [multitool] buffer..."))
		return
	if(connected_machine)
		to_chat(user, span_notice("Changing [src] bluespace network..."))
	if(!do_after(user, 0.2 SECONDS, src))
		return
	playsound(get_turf(user), 'sound/machines/click.ogg', 10, TRUE)
	register_machine(multitool.buffer)
	to_chat(user, span_notice("You link [src] to the console in [multitool]'s buffer."))
	return TRUE

/obj/machinery/bluespace_vendor/attackby(obj/item/item, mob/living/user)
	if(!pumping && default_deconstruction_screwdriver(user, "[base_icon_state]_open", "[base_icon_state]_off", item))
		check_mode()
		return
	if(default_deconstruction_crowbar(item, FALSE, custom_deconstruct = TRUE))
		new/obj/item/wallframe/bluespace_vendor_mount(user.loc)
		qdel(src)
		return

	if(istype(item, /obj/item/stack/sheet/iron))
		var/obj/item/stack/sheet/iron/iron = item
		if (iron.use(1))
			empty_tanks++
			return TRUE
	return ..()

/obj/machinery/bluespace_vendor/examine(mob/user)
	. = ..()
	if(empty_tanks > 1)
		. += span_notice("There are currently [empty_tanks] empty tanks available, more can be made by inserting iron sheets in the machine.")
	else if(empty_tanks == 1)
		. += span_notice("There is only one empty tank available, please refill the machine by using iron sheets.")
	else
		. += span_notice("There is no available tank, please refill the machine by using iron sheets.")

///Check what is the current operating mode
/obj/machinery/bluespace_vendor/proc/check_mode()
	if(panel_open)
		mode = BS_MODE_OPEN
	else if(connected_machine)
		mode = BS_MODE_IDLE
	else
		mode = BS_MODE_OFF
	update_appearance()

///Register the sender as the connected_machine
/obj/machinery/bluespace_vendor/proc/register_machine(machine)
	connected_machine = machine
	LAZYADD(connected_machine.vendors, src)
	RegisterSignal(connected_machine, COMSIG_QDELETING, PROC_REF(unregister_machine))
	mode = BS_MODE_IDLE
	update_appearance()

///Unregister the connected_machine (either when qdel this or the sender)
/obj/machinery/bluespace_vendor/proc/unregister_machine()
	SIGNAL_HANDLER
	if(connected_machine)
		UnregisterSignal(connected_machine, COMSIG_QDELETING)
		LAZYREMOVE(connected_machine.vendors, src)
		connected_machine = null
	mode = BS_MODE_OFF
	update_appearance()

///Check the price of the current tank, if the user doesn't have the money the gas will be merged back into the network
/obj/machinery/bluespace_vendor/proc/check_price(mob/user)
	var/temp_price = 0
	var/datum/gas_mixture/working_mix = internal_tank.return_air()
	var/list/gases = working_mix.gases
	for(var/gas_id in gases)
		temp_price += gases[gas_id][MOLES] * connected_machine.base_prices[gas_id]
	gas_price = temp_price

	if(attempt_charge(src, user, gas_price) & COMPONENT_OBJ_CANCEL_CHARGE)
		var/datum/gas_mixture/remove = working_mix.remove_ratio(1)
		connected_machine.bluespace_network.merge(remove)
		return
	connected_machine.credits_gained += gas_price + tank_cost

	if(internal_tank && Adjacent(user)) //proper capitalysm take money before goods
		inserted_tank = FALSE
		user.put_in_hands(internal_tank)

/obj/machinery/bluespace_vendor/ui_interact(mob/user, datum/tgui/ui)
	if(!connected_machine || mode == BS_MODE_OPEN)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BluespaceVendor", name)
		ui.open()

/obj/machinery/bluespace_vendor/ui_data(mob/user)
	var/list/data = list()
	var/list/bluespace_gasdata = list()
	if(connected_machine.bluespace_network.total_moles())
		for(var/gas_id in connected_machine.bluespace_network.gases)
			bluespace_gasdata.Add(list(list(
			"name" = connected_machine.bluespace_network.gases[gas_id][GAS_META][META_GAS_NAME],
			"id" = connected_machine.bluespace_network.gases[gas_id][GAS_META][META_GAS_ID],
			"amount" = round(connected_machine.bluespace_network.gases[gas_id][MOLES], 0.01),
			"price" = connected_machine.base_prices[gas_id],
			)))
	else
		for(var/gas_id in connected_machine.bluespace_network.gases)
			bluespace_gasdata.Add(list(list(
				"name" = connected_machine.bluespace_network.gases[gas_id][GAS_META][META_GAS_NAME],
				"id" = "",
				"amount" = 0,
				"price" = 0,
				)))
	data["bluespace_network_gases"] = bluespace_gasdata
	data["pumping"] = pumping
	data["tank_filling_amount"] = tank_filling_amount
	data["selected_gas"] = selected_gas
	data["tank_amount"] = empty_tanks
	data["inserted_tank"] = inserted_tank
	var/total_tank_pressure
	if(internal_tank)
		var/datum/gas_mixture/working_mix = internal_tank.return_air()
		total_tank_pressure = working_mix.return_pressure()
	else
		total_tank_pressure = 0
	data["tank_full"] = total_tank_pressure
	return data

/obj/machinery/bluespace_vendor/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(mode == BS_MODE_OPEN)
		return

	switch(action)
		if("start_pumping")
			if(inserted_tank && !pumping)
				pumping = TRUE
				selected_gas = params["gas_id"]
				mode = BS_MODE_PUMPING
				update_appearance()
			. = TRUE
		if("stop_pumping")
			if(inserted_tank && pumping)
				pumping = FALSE
				selected_gas = null
				mode = BS_MODE_IDLE
				update_appearance()
			. = TRUE
		if("pumping_rate")
			tank_filling_amount = clamp(params["rate"], 0, 100)
			. = TRUE
		if("tank_prepare")
			if(empty_tanks && !inserted_tank)
				inserted_tank = TRUE
				internal_tank = new(src)
				empty_tanks = max(empty_tanks - 1, 0)
			. = TRUE
		if("tank_expel")
			if(inserted_tank && !pumping)
				check_price(usr)
			. = TRUE

#undef BS_MODE_OFF
#undef BS_MODE_IDLE
#undef BS_MODE_PUMPING
#undef BS_MODE_OPEN
