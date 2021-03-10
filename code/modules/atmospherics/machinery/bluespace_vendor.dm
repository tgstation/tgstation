/obj/machinery/bluespace_vendor
	icon = 'icons/obj/atmospherics/components/thermomachine.dmi'
	icon_state = "freezer"

	name = "Bluespace Gas Vendor"
	desc = "Sells gas tanks with custom mixes for all the family!"

	density = TRUE
	max_integrity = 300
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, RAD = 100, FIRE = 80, ACID = 30)
	layer = OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/thermomachine
	var/obj/machinery/atmospherics/components/unary/bluespace_sender/connected_machine
	var/empty_tanks = 10
	var/obj/item/tank/internal_tank
	var/selected_gas
	var/pumping = FALSE
	var/inserted_tank = FALSE
	var/gas_transfer_rate = 0
	var/tank_cost = 10
	var/gas_price = 0
	var/map_spawned = TRUE

/obj/machinery/bluespace_vendor/built
	map_spawned = FALSE

/obj/machinery/bluespace_vendor/Initialize()
	. = ..()
	AddComponent(/datum/component/payment, tank_cost, SSeconomy.get_dep_account(ACCOUNT_ENG), PAYMENT_ANGRY)

/obj/machinery/bluespace_vendor/LateInitialize()
	. = ..()
	if(!map_spawned)
		return
	for(var/obj/machinery/atmospherics/components/unary/bluespace_sender/sender in GLOB.machines)
		if(!sender)
			continue
		register_machine(sender)


/obj/machinery/bluespace_vendor/process()
	if(!selected_gas)
		return
	var/gas_path = gas_id2path(selected_gas)
	connected_machine.bluespace_network.pump_gas_to(internal_tank.air_contents, (gas_transfer_rate * 0.01) * 10 * ONE_ATMOSPHERE, gas_path)

/obj/machinery/bluespace_vendor/multitool_act(mob/living/user, obj/item/multitool/multitool)
	if(istype(multitool))
		if(istype(multitool.buffer, /obj/machinery/atmospherics/components/unary/bluespace_sender))
			if(connected_machine)
				to_chat(user, "<span class='notice'>Changing [src] bluespace network...</span>")
			if(!do_after(user, 0.2 SECONDS, src))
				return
			playsound(get_turf(user), 'sound/machines/click.ogg', 10, TRUE)
			register_machine(multitool.buffer)
			to_chat(user, "<span class='notice'>You link [src] to the console in [multitool]'s buffer.</span>")
			return TRUE

/obj/machinery/bluespace_vendor/proc/register_machine(var/machine)
	connected_machine = machine
	LAZYADD(connected_machine.vendors, src)
	RegisterSignal(connected_machine, COMSIG_PARENT_QDELETING, .proc/unregister_machine)

/obj/machinery/bluespace_vendor/proc/unregister_machine()
	UnregisterSignal(connected_machine, COMSIG_PARENT_QDELETING)
	LAZYREMOVE(connected_machine.vendors, src)
	connected_machine = null

/obj/machinery/bluespace_vendor/proc/check_price(mob/user)
	var/temp_price = 0
	for(var/gas_id in internal_tank.air_contents.gases)
		temp_price += internal_tank.air_contents.total_moles(gas_id) * connected_machine.base_prices[gas_id]
	gas_price = temp_price

	if(attempt_charge(src, user, gas_price) & COMPONENT_OBJ_CANCEL_CHARGE)
		var/datum/gas_mixture/remove = internal_tank.air_contents.remove(internal_tank.air_contents.total_moles())
		connected_machine.bluespace_network.merge(remove)
		return
	connected_machine.credits_gained += gas_price + tank_cost

	if(internal_tank && Adjacent(user)) //proper capitalysm take money before goods
		inserted_tank = FALSE
		user.put_in_hands(internal_tank)

/obj/machinery/bluespace_vendor/ui_interact(mob/user, datum/tgui/ui)
	if(!connected_machine)
		message_admins("NOT CONNECTED")
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
	data["gas_transfer_rate"] = gas_transfer_rate
	data["selected_gas"] = selected_gas
	data["tank_amount"] = empty_tanks
	data["inserted_tank"] = inserted_tank
	var/total_tank_pressure
	if(internal_tank)
		total_tank_pressure = internal_tank.air_contents.return_pressure()
	else
		total_tank_pressure = 0
	data["tank_full"] = total_tank_pressure
	return data

/obj/machinery/bluespace_vendor/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("start_pumping")
			pumping = TRUE
			selected_gas = params["gas_id"]
			. = TRUE
		if("stop_pumping")
			pumping = FALSE
			selected_gas = null
			. = TRUE
		if("pumping_rate")
			gas_transfer_rate = clamp(params["rate"], 0, 100)
			. = TRUE
		if("tank_prepare")
			inserted_tank = TRUE
			internal_tank = new(src)
			empty_tanks = max(empty_tanks - 1, 0)
			. = TRUE
		if("tank_expel")
			check_price(usr)
			. = TRUE
