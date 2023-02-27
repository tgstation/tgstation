/obj/machinery/computer/bank_machine
	circuit = /obj/item/circuitboard/computer/bank_machine

/obj/machinery/computer/bank_machine/Initialize(mapload)
	. = ..()
	//clear the account immediately
	synced_bank_account = null
	register_context()
	connect_to_shuttle(mapload, SSshuttle.get_containing_shuttle(src))

/obj/machinery/computer/bank_machine/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(istype(held_item, /obj/item/card/id))
		context[SCREENTIP_CONTEXT_LMB] = "Connect Account"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/computer/bank_machine/examine(mob/user)
	. = ..()
	if(synced_bank_account)
		. += span_notice("It is connected to [synced_bank_account.account_holder]'s account.")
	else
		. += span_notice("It is not connected to an account. Use an ID to connect it")

/obj/machinery/computer/bank_machine/multitool_act(mob/living/user, obj/item/multitool/tool)
	user.balloon_alert(user, "buffer saved in storage")
	tool.buffer = src
	return TRUE

/obj/machinery/computer/bank_machine/ui_data(mob/user)
	var/list/data = ..()

	if(synced_bank_account)
		data["station_name"] = synced_bank_account.account_holder

	return data

/obj/machinery/computer/bank_machine/attackby(obj/item/weapon, mob/user, params)
	if(isidcard(weapon))
		var/obj/item/card/id/id_weapon = weapon
		synced_bank_account = id_weapon.registered_account
		playsound(user, 'sound/machines/ding.ogg', 50, TRUE)
		balloon_alert_to_viewers(user, "account updated")

	if(!synced_bank_account && (istype(weapon, /obj/item/stack/spacecash) || istype(weapon, /obj/item/holochip)))
		return //don't let them continue the attack chain because they'll waste money on a machine with no account

	return ..()

/obj/machinery/computer/bank_machine/connect_to_shuttle(mapload, obj/docking_port/mobile/voidcrew/port, obj/docking_port/stationary/dock)
	. = ..()
	if(istype(port) && port.current_ship.ship_account)
		synced_bank_account = port.current_ship.ship_account

/**
 * CIRCUIT BOARD
 */
/obj/item/circuitboard/computer/bank_machine
	name = "Bank Machine"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/computer/bank_machine

/datum/design/board/bankmachine
	name = "Bank Machine Console Board"
	desc = "Allows for the construction of a Bank Machine circuit board to interact with your Ship's budget."
	id = "bankmachine"
	build_path = /obj/item/circuitboard/computer/bank_machine
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO
