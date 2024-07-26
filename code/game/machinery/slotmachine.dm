/*******************************\
|   Slot Machines |
|   Original code by Glloyd |
|   Tgstation port by Miauw |
\*******************************/

#define SPIN_PRICE 5
#define SMALL_PRIZE 400
#define BIG_PRIZE 1000
#define JACKPOT 10000
#define SPIN_TIME 65 //As always, deciseconds.
#define REEL_DEACTIVATE_DELAY 7
#define JACKPOT_SEVENS FA_ICON_7
#define HOLOCHIP 1
#define COIN 2

/obj/machinery/computer/slot_machine
	name = "slot machine"
	desc = "Gambling for the antisocial."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "slots"
	icon_keyboard = null
	icon_screen = "slots_screen"
	density = TRUE
	circuit = /obj/item/circuitboard/computer/slot_machine
	light_color = LIGHT_COLOR_BROWN
	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON // don't need to be literate to play slots
	var/money = 3000 //How much money it has CONSUMED
	var/plays = 0
	var/working = FALSE
	var/balance = 0 //How much money is in the machine, ready to be CONSUMED.
	var/jackpots = 0
	var/paymode = HOLOCHIP //toggles between HOLOCHIP/COIN, defined above
	var/cointype = /obj/item/coin/iron //default cointype
	/// Icons that can be displayed by the slot machine.
	var/static/list/icons = list(
		FA_ICON_LEMON = list("value" = 2, "colour" = "yellow"),
		FA_ICON_STAR = list("value" = 2, "colour" = "yellow"),
		FA_ICON_BOMB = list("value" = 2, "colour" = "red"),
		FA_ICON_BIOHAZARD = list("value" = 2, "colour" = "green"),
		FA_ICON_APPLE_WHOLE = list("value" = 2, "colour" = "red"),
		FA_ICON_7 = list("value" = 1, "colour" = "yellow"),
		FA_ICON_DOLLAR_SIGN = list("value" = 2, "colour" = "green"),
	)

	var/static/list/coinvalues
	var/list/reels = list(list("", "", "") = 0, list("", "", "") = 0, list("", "", "") = 0, list("", "", "") = 0, list("", "", "") = 0)
	var/static/list/ray_filter = list(type = "rays", y = 16, size = 40, density = 4, color = COLOR_RED_LIGHT, factor = 15, flags = FILTER_OVERLAY)

/obj/machinery/computer/slot_machine/Initialize(mapload)
	. = ..()
	jackpots = rand(1, 4) //false hope
	plays = rand(75, 200)

	toggle_reel_spin_sync(1) //The reels won't spin unless we activate them

	var/list/reel = reels[1]
	for(var/i in 1 to reel.len) //Populate the reels.
		randomize_reels()

	toggle_reel_spin_sync(0)

	if (isnull(coinvalues))
		coinvalues = list()

		for(cointype in typesof(/obj/item/coin))
			var/obj/item/coin/C = new cointype
			coinvalues["[cointype]"] = C.get_item_credit_value()
			qdel(C) //Sigh

/obj/machinery/computer/slot_machine/on_deconstruction(disassembled)
	if(balance)
		give_payout(balance)

/obj/machinery/computer/slot_machine/process(seconds_per_tick)
	. = ..() //Sanity checks.
	if(!.)
		return .

	money += round(seconds_per_tick / 2) //SPESSH MAJICKS

/obj/machinery/computer/slot_machine/update_icon_state()
	if(machine_stat & BROKEN)
		icon_state = "slots_broken"
	else
		icon_state = "slots"
	return ..()

/obj/machinery/computer/slot_machine/update_overlays()
	if(working)
		icon_screen = "slots_screen_working"
	else
		icon_screen = "slots_screen"
	return ..()


/obj/machinery/computer/slot_machine/item_interaction(mob/living/user, obj/item/inserted, list/modifiers)
	if(istype(inserted, /obj/item/coin))
		var/obj/item/coin/inserted_coin = inserted
		if(paymode == COIN)
			if(prob(2))
				if(!user.transferItemToLoc(inserted_coin, drop_location(), silent = FALSE))
					return ITEM_INTERACT_BLOCKING
				inserted_coin.throw_at(user, 3, 10)
				if(prob(10))
					balance = max(balance - SPIN_PRICE, 0)
				to_chat(user, span_warning("[src] spits your coin back out!"))
				return ITEM_INTERACT_BLOCKING
			else
				if(!user.temporarilyRemoveItemFromInventory(inserted_coin))
					return ITEM_INTERACT_BLOCKING
				balloon_alert(user, "coin insterted")
				balance += inserted_coin.value
				qdel(inserted_coin)
				return ITEM_INTERACT_SUCCESS
		else
			balloon_alert(user, "holochips only!")
		return ITEM_INTERACT_BLOCKING

	if(istype(inserted, /obj/item/holochip))
		if(paymode == HOLOCHIP)
			var/obj/item/holochip/inserted_chip = inserted
			if(!user.temporarilyRemoveItemFromInventory(inserted_chip))
				return ITEM_INTERACT_BLOCKING
			balloon_alert(user, "[inserted_chip.credits] credit[inserted_chip.credits == 1 ? "" : "s"] inserted")
			balance += inserted_chip.credits
			qdel(inserted_chip)
			return ITEM_INTERACT_SUCCESS
		else
			balloon_alert(user, "coins only!")
		return ITEM_INTERACT_BLOCKING

	return NONE

/obj/machinery/computer/slot_machine/multitool_act(mob/living/user, obj/item/tool)
	if(balance > 0)
		visible_message("<b>[src]</b> says, 'ERROR! Please empty the machine balance before altering paymode'") //Prevents converting coins into holocredits and vice versa
		return ITEM_INTERACT_BLOCKING

	if(paymode == HOLOCHIP)
		paymode = COIN
		balloon_alert(user, "now using coins")
	else
		paymode = HOLOCHIP
		balloon_alert(user, "now using holochips")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/computer/slot_machine/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(4, 0, src.loc)
	spark_system.start()
	playsound(src, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	balloon_alert(user, "machine rigged")
	return TRUE

/obj/machinery/computer/slot_machine/ui_interact(mob/living/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SlotMachine", name)
		ui.open()

/obj/machinery/computer/slot_machine/ui_static_data(mob/user)
	var/list/data = list()
	data["icons"] = list()
	for(var/icon_name in icons)
		var/list/icon = icons[icon_name]
		icon += list("icon" = icon_name)
		data["icons"] += list(icon)
	data["cost"] = SPIN_PRICE
	data["jackpot"] = JACKPOT

	return data

/obj/machinery/computer/slot_machine/ui_data(mob/user)
	var/list/data = list()
	var/list/reel_states = list()
	for(var/reel_state in reels)
		reel_states += list(reel_state)
	data["state"] = reel_states
	data["balance"] = balance
	data["working"] = working
	data["money"] = money
	data["plays"] = plays
	data["jackpots"] = jackpots
	data["paymode"] = paymode
	return data


/obj/machinery/computer/slot_machine/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("spin")
			spin(ui.user)
			return TRUE
		if("payout")
			if(balance > 0)
				give_payout(balance)
				balance = 0
				return TRUE

/obj/machinery/computer/slot_machine/emp_act(severity)
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN) || . & EMP_PROTECT_SELF)
		return
	if(prob(15 * severity))
		return
	if(prob(1)) // :^)
		obj_flags |= EMAGGED
	var/severity_ascending = 4 - severity
	money = max(rand(money - (200 * severity_ascending), money + (200 * severity_ascending)), 0)
	balance = max(rand(balance - (50 * severity_ascending), balance + (50 * severity_ascending)), 0)
	money -= max(0, give_payout(min(rand(-50, 100 * severity_ascending)), money)) //This starts at -50 because it shouldn't always dispense coins yo
	spin()

/obj/machinery/computer/slot_machine/proc/spin(mob/user)
	if(!can_spin(user))
		return

	var/the_name
	if(user)
		the_name = user.real_name
		visible_message(span_notice("[user] pulls the lever and the slot machine starts spinning!"))
	else
		the_name = "Exaybachay"

	balance -= SPIN_PRICE
	money += SPIN_PRICE
	plays += 1
	working = TRUE

	toggle_reel_spin(1)
	update_appearance()
	var/spin_loop = addtimer(CALLBACK(src, PROC_REF(do_spin)), 2, TIMER_LOOP|TIMER_STOPPABLE)

	addtimer(CALLBACK(src, PROC_REF(finish_spinning), spin_loop, user, the_name), SPIN_TIME - (REEL_DEACTIVATE_DELAY * reels.len))
	//WARNING: no sanity checking for user since it's not needed and would complicate things (machine should still spin even if user is gone), be wary of this if you're changing this code.

/obj/machinery/computer/slot_machine/proc/do_spin()
	if(!use_energy(active_power_usage, force = FALSE))
		say("Not enough energy!")
		return
	randomize_reels()

/obj/machinery/computer/slot_machine/proc/finish_spinning(spin_loop, mob/user, the_name)
	toggle_reel_spin(0, REEL_DEACTIVATE_DELAY)
	working = FALSE
	deltimer(spin_loop)
	give_prizes(the_name, user)
	update_appearance()

/// Check if the machine can be spun
/obj/machinery/computer/slot_machine/proc/can_spin(mob/user)
	if(machine_stat & NOPOWER)
		balloon_alert(user, "no power!")
		return FALSE
	if(machine_stat & BROKEN)
		balloon_alert(user, "machine broken!")
		return FALSE
	if(working)
		balloon_alert(user, "already spinning!")
		return FALSE
	if(balance < SPIN_PRICE)
		balloon_alert(user, "insufficient balance!")
		return FALSE
	return TRUE

/// Sets the spinning states of all reels to value, with a delay between them
/obj/machinery/computer/slot_machine/proc/toggle_reel_spin(value, delay = 0) //value is 1 or 0 aka on or off
	for(var/list/reel in reels)
		if(!value)
			playsound(src, 'sound/machines/ding_short.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		reels[reel] = value
		if(delay)
			sleep(delay)

/// Same as toggle_reel_spin, but without the delay and runs synchronously
/obj/machinery/computer/slot_machine/proc/toggle_reel_spin_sync(value)
	for(var/list/reel in reels)
		reels[reel] = value

/// Randomize the states of all reels
/obj/machinery/computer/slot_machine/proc/randomize_reels()

	for(var/reel in reels)
		if(reels[reel])
			reel[3] = reel[2]
			reel[2] = reel[1]
			var/chosen = pick(icons)
			reel[1] = icons[chosen] + list("icon_name" = chosen)

/// Checks if any prizes have been won, and pays them out
/obj/machinery/computer/slot_machine/proc/give_prizes(usrname, mob/user)
	var/linelength = get_lines()
	var/did_player_win = TRUE

	if(check_jackpot(FA_ICON_BOMB))
		var/obj/item/grenade/flashbang/bang = new(get_turf(src))
		bang.arm_grenade(null, 1 SECONDS)

	else if(check_jackpot(JACKPOT_SEVENS))
		var/prize = money + JACKPOT
		visible_message("<b>[src]</b> says, 'JACKPOT! You win [prize] credits!'")
		priority_announce("Congratulations to [user ? user.real_name : usrname] for winning the jackpot at the slot machine in [get_area(src)]!")
		jackpots += 1
		money = 0
		if(paymode == HOLOCHIP)
			new /obj/item/holochip(loc, prize)
		else
			for(var/i in 1 to 5)
				cointype = pick(subtypesof(/obj/item/coin))
				var/obj/item/coin/payout_coin = new cointype(loc)
				random_step(payout_coin, 2, 50)
				playsound(src, pick(list('sound/machines/coindrop.ogg', 'sound/machines/coindrop2.ogg')), 50, TRUE)
				sleep(REEL_DEACTIVATE_DELAY)

	else if(linelength == 5)
		visible_message("<b>[src]</b> says, 'Big Winner! You win a thousand credits!'")
		give_money(BIG_PRIZE)

	else if(linelength == 4)
		visible_message("<b>[src]</b> says, 'Winner! You win four hundred credits!'")
		give_money(SMALL_PRIZE)

	else if(linelength == 3)
		to_chat(user, span_notice("You win three free games!"))
		balance += SPIN_PRICE * 4
		money = max(money - SPIN_PRICE * 4, money)

	else
		balloon_alert(user, "no luck!")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50)
		did_player_win = FALSE

	if(did_player_win)
		add_filter("jackpot_rays", 3, ray_filter)
		animate(get_filter("jackpot_rays"), offset = 10, time = 3 SECONDS, loop = -1)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum, remove_filter), "jackpot_rays"), 3 SECONDS)
		playsound(src, 'sound/machines/roulettejackpot.ogg', 50, TRUE)

/// Checks for a jackpot (5 matching icons in the middle row) with the given icon name
/obj/machinery/computer/slot_machine/proc/check_jackpot(name)
	return reels[1][2]["icon_name"] + reels[2][2]["icon_name"] + reels[3][2]["icon_name"] + reels[4][2]["icon_name"] + reels[5][2]["icon_name"] == "[name][name][name][name][name]"

/// Finds the largest number of consecutive matching icons in a row
/obj/machinery/computer/slot_machine/proc/get_lines()
	var/amountthesame

	for(var/i in 1 to 3)
		var/inputtext = reels[1][i]["icon_name"] + reels[2][i]["icon_name"] + reels[3][i]["icon_name"] + reels[4][i]["icon_name"] + reels[5][i]["icon_name"]
		for(var/icon in icons)
			var/j = 3 //The lowest value we have to check for.
			var/symboltext = icon + icon + icon
			while(j <= 5)
				if(findtext(inputtext, symboltext))
					amountthesame = max(j, amountthesame)
				j++
				symboltext += icon

			if(amountthesame)
				break

	return amountthesame

/// Give the specified amount of money. If the amount is greater than the amount of prize money available, add the difference as balance
/obj/machinery/computer/slot_machine/proc/give_money(amount)
	var/amount_to_give = min(amount, money)
	var/surplus = amount - give_payout(amount_to_give)
	money -= amount_to_give
	balance += surplus

/// Pay out the specified amount in either coins or holochips
/obj/machinery/computer/slot_machine/proc/give_payout(amount)
	if(paymode == HOLOCHIP)
		cointype = /obj/item/holochip
	else
		cointype = obj_flags & EMAGGED ? /obj/item/coin/iron : /obj/item/coin/silver

	if(!(obj_flags & EMAGGED))
		amount = dispense(amount, cointype, null, 0)

	else
		var/mob/living/target = locate() in range(2, src)

		amount = dispense(amount, cointype, target, 1)

	return amount

/// Dispense the given amount. If machine is set to use coins, will use the specified coin type.
/// If throwit and target are set, will launch the payment at the target
/obj/machinery/computer/slot_machine/proc/dispense(amount = 0, cointype = /obj/item/coin/silver, throwit = FALSE, mob/living/target)
	if(paymode == HOLOCHIP)
		var/obj/item/holochip/chip = new /obj/item/holochip(loc,amount)

		if(throwit && target)
			chip.throw_at(target, 3, 10)
	else
		var/value = coinvalues["[cointype]"]
		if(value <= 0)
			CRASH("Coin value of zero, refusing to payout in dispenser")
		while(amount >= value)
			var/obj/item/coin/thrown_coin = new cointype(loc) //DOUBLE THE PAIN
			amount -= value
			if(throwit && target)
				thrown_coin.throw_at(target, 3, 10)
			else
				random_step(thrown_coin, 2, 40)

	playsound(src, pick(list('sound/machines/coindrop.ogg', 'sound/machines/coindrop2.ogg')), 50, TRUE)
	return amount

#undef BIG_PRIZE
#undef COIN
#undef HOLOCHIP
#undef JACKPOT
#undef REEL_DEACTIVATE_DELAY
#undef JACKPOT_SEVENS
#undef SMALL_PRIZE
#undef SPIN_PRICE
#undef SPIN_TIME
