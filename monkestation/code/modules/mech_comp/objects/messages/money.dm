/obj/item/mcobject/messaging/payment
	name = "payment component"

	icon_state = "comp_money"
	base_icon_state = "comp_money"

	///The default price of the component
	var/price = 100
	///the sent code
	var/code = null
	///total amount collected so far
	var/collected = 0

	///the string displayed after the payment threshold has been reached
	var/output_string = ""

/obj/item/mcobject/messaging/payment/update_desc(updates)
	. = ..()
	. += "Known for eating your change."
	. += "Collected Money: [collected] credits"
	. += "Current Price: [price] credits"

/obj/item/mcobject/messaging/payment/Initialize(mapload)
	. = ..()
	MC_ADD_INPUT("eject money", empty)
	MC_ADD_CONFIG("Set Price", set_price)
	MC_ADD_CONFIG("Set Code", set_code)
	MC_ADD_CONFIG("Set Output String", set_string)
	MC_ADD_CONFIG("Eject Money", check_eject)

/obj/item/mcobject/messaging/payment/proc/empty(datum/mcmessage/input)
	if(!anchored || !input)
		return
	if(input.cmd != code)
		return
	eject_money()

/obj/item/mcobject/messaging/payment/proc/set_code(mob/user, obj/item/tool)
	if(!code_check(user))
		return
	var/new_code = tgui_input_text(user, "Please enter a new code", "Payment Component")
	if(!new_code)
		return
	code = new_code
	say("SUCCESS:Code set to [code]")
	return TRUE

/obj/item/mcobject/messaging/payment/proc/code_check(mob/user)
	if(code)
		var/code_check = tgui_input_text(user, "Please enter current code", "Payment Component")
		if(!code_check || code_check != code)
			say("ERROR:Incorrect code given.")
			return
	return TRUE

/obj/item/mcobject/messaging/payment/proc/set_price(mob/user, obj/item/tool)
	if(!code_check(user))
		return
	var/new_price = tgui_input_number(user, "Set new price", "Payment Component", min_value = 0)
	if(!new_price)
		return
	price = new_price
	say("SUCCESS:Price has been set to [price]")
	return TRUE

/obj/item/mcobject/messaging/payment/proc/set_string(mob/user, obj/item/tool)
	if(!code_check(user))
		return
	var/new_string = tgui_input_text(user, "Set a thank you string", "Payment Component", output_string)
	if(!new_string)
		return
	output_string = new_string
	say("SUCCESS:Thank you message has been set to: [new_string]")
	return TRUE

/obj/item/mcobject/messaging/payment/proc/check_eject(mob/user, obj/item/tool)
	if(!code_check(user))
		return
	eject_money()

/obj/item/mcobject/messaging/payment/proc/eject_money()
	if(collected)
		var/obj/item/stack/spacecash/c1/money = new(src.loc)
		money.amount = collected
		collected = 0
		update_appearance()
	return

/obj/item/mcobject/messaging/payment/attacked_by(obj/item/attacking_item, mob/living/user)
	. = ..()
	if(attacking_item in subtypesof(/obj/item/stack/spacecash))
		var/obj/item/stack/spacecash/attacked_stack = attacking_item
		var/total_value = attacked_stack.get_item_credit_value()
		var/individual_value = attacked_stack.value
		if(total_value >= price)
			var/amount_to_reduce = ROUND_UP(price / individual_value)
			var/actual_input = amount_to_reduce * attacked_stack.value
			if(amount_to_reduce == attacked_stack.amount)
				qdel(attacked_stack)
			else
				attacked_stack.amount -= amount_to_reduce
			collected += actual_input
			say("[output_string]")
		else
			collected += total_value
			qdel(attacked_stack)

	else if (istype(attacking_item, /obj/item/holochip))
		var/obj/item/holochip/attacked_chip = attacking_item
		if(attacked_chip.credits >= price)
			collected += price
			attacked_chip.credits -= price
			say("[output_string]")
		else
			collected += attacked_chip.credits
			qdel(attacked_chip)
