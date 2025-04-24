/**
 * # Money Bot
 *
 * Immobile (but not dense) shell that can receive and dispense money.
 */
/obj/structure/money_bot
	name = "money bot"
	icon = 'icons/obj/science/circuits.dmi'
	icon_state = "setup_large"

	density = FALSE
	light_system = OVERLAY_LIGHT
	light_on = FALSE

	var/stored_money = 0
	var/locked = FALSE

/obj/structure/money_bot/atom_deconstruct(disassembled = TRUE)
	new /obj/item/holochip(drop_location(), stored_money)

/obj/structure/money_bot/proc/add_money(to_add)
	stored_money += to_add
	SEND_SIGNAL(src, COMSIG_MONEYBOT_ADD_MONEY, to_add)

/obj/structure/money_bot/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/money_bot(),
		new /obj/item/circuit_component/money_dispenser()
	), SHELL_CAPACITY_LARGE)

/obj/structure/money_bot/wrench_act(mob/living/user, obj/item/tool)
	if(locked)
		return
	set_anchored(!anchored)
	tool.play_tool_sound(src)
	balloon_alert(user, anchored ? "secured" : "unsecured")
	return TRUE


/obj/item/circuit_component/money_dispenser
	display_name = "Money Dispenser"
	desc = "Used to dispense money from the money bot. Money is taken from the internal storage of money."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// CD before next dispense
	COOLDOWN_DECLARE(dispense_cd)

	/// CD between allowing money to be dispensed
	var/dispense_cd_length = 0.5 SECONDS

	/// The maximum amount of chips to dispense in one tile
	var/max_chips = 50

	/// The amount of money to dispense
	var/datum/port/input/dispense_amount

	/// Outputs a signal when it fails to output any money.
	var/datum/port/output/on_fail

	var/obj/structure/money_bot/attached_bot

/obj/item/circuit_component/money_dispenser/populate_ports()
	dispense_amount = add_input_port("Amount", PORT_TYPE_NUMBER)
	on_fail = add_output_port("On Failed", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/money_dispenser/get_ui_notices()
	. = ..()
	. += create_ui_notice("Dispense Cooldown: [DisplayTimeText(dispense_cd_length)]", "orange", FA_ICON_STOPWATCH)
	. += create_ui_notice("Dispense Limit: [max_chips] Holochips (per tile)", "orange", FA_ICON_MONEY_BILL_TRANSFER)

/obj/item/circuit_component/money_dispenser/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/structure/money_bot))
		attached_bot = shell

/obj/item/circuit_component/money_dispenser/unregister_shell(atom/movable/shell)
	attached_bot = null
	return ..()

/obj/item/circuit_component/money_dispenser/pre_input_received(datum/port/input/port)
	dispense_amount.set_value(floor(dispense_amount.value))

/obj/item/circuit_component/money_dispenser/input_received(datum/port/input/port)

	if(!attached_bot)
		return

	if(!COOLDOWN_FINISHED(src, dispense_cd))
		on_fail.set_output(COMPONENT_SIGNAL)
		return

	var/to_dispense = clamp(dispense_amount.value, 0, attached_bot.stored_money)
	if(!to_dispense)
		on_fail.set_output(COMPONENT_SIGNAL)
		return

	COOLDOWN_START(src, dispense_cd, dispense_cd_length)
	var/atom/droploc = attached_bot.drop_location()
	var/num_on_tile = 0
	for(var/obj/item/holochip/chip in droploc)
		num_on_tile++
	// at this point, clearly no one's jumping for the cash. so let's stop dispensing
	if(num_on_tile > max_chips)
		on_fail.set_output(COMPONENT_SIGNAL)
		return

	attached_bot.add_money(-to_dispense)
	new /obj/item/holochip(droploc, to_dispense)

/obj/item/circuit_component/money_bot
	display_name = "Money Bot"
	var/obj/structure/money_bot/attached_bot
	desc = "Used to receive input signals when money is inserted into the money bot shell and also keep track of the total money in the shell."

	/// Total money in the shell
	var/datum/port/output/total_money
	/// Amount of the last money inputted into the shell
	var/datum/port/output/money_input
	/// Trigger for when money is inputted into the shell
	var/datum/port/output/money_trigger
	/// The person who input the money
	var/datum/port/output/entity

/obj/item/circuit_component/money_bot/populate_ports()
	total_money = add_output_port("Total Money", PORT_TYPE_NUMBER)
	money_input = add_output_port("Last Input Money", PORT_TYPE_NUMBER)
	entity = add_output_port("User", PORT_TYPE_USER)
	money_trigger = add_output_port("Money Input", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/money_bot/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/structure/money_bot))
		attached_bot = shell
		total_money.set_output(attached_bot.stored_money)
		RegisterSignal(shell, COMSIG_ATOM_ATTACKBY, PROC_REF(handle_money_insert))
		RegisterSignal(shell, COMSIG_MONEYBOT_ADD_MONEY, PROC_REF(handle_money_update))
		RegisterSignal(parent, COMSIG_CIRCUIT_SET_LOCKED, PROC_REF(on_set_locked))
		attached_bot.locked = parent.locked

/obj/item/circuit_component/money_bot/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, list(
		COMSIG_ATOM_ATTACKBY,
		COMSIG_MONEYBOT_ADD_MONEY,
	))
	total_money.set_output(null)
	if(attached_bot)
		attached_bot.locked = FALSE
		UnregisterSignal(parent, COMSIG_CIRCUIT_SET_LOCKED)
	attached_bot = null
	return ..()

/obj/item/circuit_component/money_bot/proc/handle_money_insert(atom/source, obj/item/item, mob/living/attacker)
	SIGNAL_HANDLER
	if(!attached_bot || !iscash(item))
		return

	var/amount_to_insert = item.get_item_credit_value()
	if(!amount_to_insert)
		balloon_alert(attacker, "this has no value!")
		return

	attached_bot.add_money(amount_to_insert)
	balloon_alert(attacker, "inserted [amount_to_insert] credits.")
	money_input.set_output(amount_to_insert)
	entity.set_output(attacker)
	money_trigger.set_output(COMPONENT_SIGNAL)
	qdel(item)

/obj/item/circuit_component/money_bot/proc/handle_money_update(atom/source)
	SIGNAL_HANDLER
	if(attached_bot)
		total_money.set_output(attached_bot.stored_money)

/**
 * Locks the attached bot when the circuit is locked.
 *
 * Arguments:
 * * new_value - A boolean that determines if the circuit is locked or not.
 **/
/obj/item/circuit_component/money_bot/proc/on_set_locked(datum/source, new_value)
	SIGNAL_HANDLER
	attached_bot.locked = new_value
