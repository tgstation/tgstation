/*******************************\
|   SLOT MACHINES               |
|   Original code by Glloyd     |
|   Tgstation port by Miauw     |
|   Tgui spin by stylemistake   |
\*******************************/

#define SPIN_PRICE 5
#define WINNING_NOTHING 0
#define WINNING_FREESPIN 1
#define WINNING_SMALL 2
#define WINNING_BIG 3
#define WINNING_JACKPOT 4
#define PRIZE_SMALL 400
#define PRIZE_BIG 1000
#define PRIZE_JACKPOT 10000
#define SPIN_TIME 4 SECONDS
#define REEL_DEACTIVATE_DELAY 0.4 SECONDS
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
	var/money = 3000 // How much money it has CONSUMED
	var/plays = 0
	var/working = FALSE
	var/winning = WINNING_NOTHING
	var/balance = 0 // How much money is in the machine, ready to be CONSUMED.
	var/jackpots = 0
	var/paymode = HOLOCHIP // toggles between HOLOCHIP/COIN, defined above
	var/cointype = /obj/item/coin/iron //default cointype

	/// Typepaths representing the symbols shown on this machine's reels.
	/// Override this list in subtypes to make themed slot machines.
	var/list/symbol_paths = list(
		/obj/item/food/grown/bluecherries,
		/obj/item/food/grown/cherries,
		/obj/item/grenade/flashbang,
		/obj/item/rupee,
		/obj/item/food/grown/chili,
		/obj/item/food/grown/icepepper,
		/obj/item/stack/spacecash/c20,
	)

	/// Used to determine the 1st name of the slot machine [adjective] [noun]
	var/list/slot_adjectives = list(
		"Atomic", "Blazing", "Bonus", "Cosmic", "Diamond",
		"Double", "Golden", "Grand", "Greedy", "Honking",
		"Jumbo", "Lucky", "Mega", "Platinum", "Robust",
		"Royal", "Spess", "Super", "Triple", "Turbo",
		"Wild"
	)

	/// Used to determine the 2nd name of the slot machine [adjective] [noun]
	var/slot_nouns = list(
		"Bankroll", "Bonanza", "Bounty", "Cashout", "Cherries",
		"Fortune", "Jackpot", "Luck", "Moolah", "Payday",
		"Reels", "Riches", "Sevens", "Spinner", "Spins",
		"Strike", "Treasure", "Windfall"
	)

	/// The symbol typepath that pays out the jackpot when it lines up five wide
	/// on the middle row. MUST also be present in symbol_paths.
	var/jackpot_path = /obj/item/coin/gold

	/// The symbol typepath that arms a flashbang when it lines up five wide on the
	/// middle row. MUST also be present in symbol_paths. Set to null to disable.
	var/bomb_path = /obj/item/grenade/flashbang

	/// Hex colour string used to theme the tgui banner, spin button, and reel
	/// highlight. Null leaves the stock rainbow gradient in place.
	/// Department subtypes feed this from the RADIO_COLOR_* defines so they stay
	/// in lockstep with radio/chat colouring.
	var/theme_color = null

	/// Cached list of symbol data (id/name/icon/icon_state) sent to the UI.
	/// Built once from symbol_paths in Initialize() via build_symbol_data().
	var/list/symbol_data

	var/static/list/coinvalues
	var/list/reels = list(
		list("", "", ""),
		list("", "", ""),
		list("", "", ""),
		list("", "", ""),
		list("", "", ""),
	)
	var/static/list/ray_filter = list(type = "rays", y = 16, size = 40, density = 4, color = COLOR_RED_LIGHT, factor = 15, flags = FILTER_OVERLAY)

/obj/machinery/computer/slot_machine/Initialize(mapload)
	. = ..()
	jackpots = rand(1, 4) //false hope
	plays = rand(75, 200)

	// Sanity: warn if a subtype misconfigures its special symbols
	if(jackpot_path && !(jackpot_path in symbol_paths))
		stack_trace("[type] has jackpot_path [jackpot_path] not present in symbol_paths!")
	if(bomb_path && !(bomb_path in symbol_paths))
		stack_trace("[type] has bomb_path [bomb_path] not present in symbol_paths!")

	// Build the UI-friendly symbol data from our typepaths
	build_symbol_data()

	// Populate the reels
	randomize_reels()

	if (isnull(coinvalues))
		coinvalues = list()

		for(cointype in typesof(/obj/item/coin))
			var/obj/item/coin/C = new cointype
			coinvalues["[cointype]"] = C.get_item_credit_value()
			qdel(C) //Sigh

/// Builds symbol_data from symbol_paths. Each entry contains the stringified
/// typepath (as a unique id) plus the name/icon/icon_state pulled via the :: operator.
/obj/machinery/computer/slot_machine/proc/build_symbol_data()
	symbol_data = list()
	for(var/obj/symbol as anything in symbol_paths)
		symbol_data += list(list(
			"id" = "[symbol]",
			"name" = symbol::name,
			"icon" = symbol::icon,
			"icon_state" = symbol::icon_state,
		))

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
				if(!user.transfer_item_to_turf(inserted_coin, drop_location(), silent = FALSE))
					return ITEM_INTERACT_BLOCKING
				inserted_coin.throw_at(user, 3, 10)
				if(prob(10))
					balance = max(balance - SPIN_PRICE, 0)
				to_chat(user, span_warning("[src] spits your coin back out!"))
				return ITEM_INTERACT_BLOCKING
			else
				if(!user.temporarilyRemoveItemFromInventory(inserted_coin))
					return ITEM_INTERACT_BLOCKING
				balloon_alert(user, "coin inserted")
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
			balloon_alert(user, "[inserted_chip.credits] [MONEY_NAME_AUTOPURAL(inserted_chip.credits)] inserted")
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
	var/datum/effect_system/basic/spark_spread/spark_system = new(src.loc, 4, 0)
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
	data["symbols"] = symbol_data
	data["theme_color"] = theme_color
	data["cost"] = SPIN_PRICE
	data["jackpot"] = PRIZE_JACKPOT
	return data

/obj/machinery/computer/slot_machine/ui_data(mob/user)
	var/list/data = list()
	var/list/_reels = list()
	for(var/reel in reels)
		_reels += list(list(
			"symbols" = reel,
		))
	data["reels"] = _reels
	data["balance"] = balance
	data["working"] = working
	data["winning"] = winning
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

	if(!use_energy(active_power_usage, force = FALSE))
		say("Not enough energy!")
		return

	var/the_name
	if(user)
		the_name = user.real_name
		visible_message(span_notice("[user] pulls the lever and the slot machine starts spinning!"))
		if(isliving(user))
			var/mob/living/living_user = user
			living_user.add_mood_event("slots_spin", /datum/mood_event/slots)
	else
		the_name = "Exaybachay"

	balance -= SPIN_PRICE
	money += SPIN_PRICE
	plays += 1
	working = TRUE

	update_appearance()

	// Play the lever pull sound and a reel spin sound after a short delay
	playsound(src, 'sound/machines/lever/lever_start.ogg', 50)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), src, 'sound/machines/roulette/roulettewheel.ogg', 20), 0.3 SECONDS)

	// Randomize reels to get the new final state.
	randomize_reels()

	// Now wait for a pre-determined delay to set machine to a non-spinning state.
	// On the UI side, result is pre-determined: after the delay below,
	// animation stops at the newly calculated state of the reels.
	addtimer(CALLBACK(src, PROC_REF(finish_spinning), user, the_name), SPIN_TIME)

/obj/machinery/computer/slot_machine/proc/finish_spinning(mob/user, the_name)
	working = FALSE
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

/// Randomize the states of all reels. Each slot stores a stringified symbol typepath.
/obj/machinery/computer/slot_machine/proc/randomize_reels()
	for(var/list/reel in reels)
		reel[1] = "[pick(symbol_paths)]"
		reel[2] = "[pick(symbol_paths)]"
		reel[3] = "[pick(symbol_paths)]"

/// Checks if any prizes have been won, and pays them out
/obj/machinery/computer/slot_machine/proc/give_prizes(usrname, mob/user)
	var/linelength = get_lines()
	var/did_player_win = TRUE

	if(bomb_path && check_jackpot(bomb_path))
		var/obj/item/grenade/flashbang/bang = new(get_turf(src))
		bang.arm_grenade(null, 1 SECONDS)

	else if(check_jackpot(jackpot_path))
		winning = WINNING_JACKPOT
		var/prize = money + PRIZE_JACKPOT
		visible_message("<b>[src]</b> says, 'JACKPOT! You win [prize] [MONEY_NAME]!'")
		priority_announce("Congratulations to [user ? user.real_name : usrname] for winning the jackpot at the slot machine in [get_area(src)]!")
		if(isliving(user) && (user in viewers(src)))
			var/mob/living/living_user = user
			living_user.add_mood_event("slots", /datum/mood_event/slots/win/jackpot)
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
		winning = WINNING_BIG
		visible_message("<b>[src]</b> says, 'Big Winner! You win a thousand [MONEY_NAME]!'")
		give_money(PRIZE_BIG)
		if(isliving(user) && (user in viewers(src)))
			var/mob/living/living_user = user
			living_user.add_mood_event("slots", /datum/mood_event/slots/win/big)

	else if(linelength == 4)
		winning = WINNING_SMALL
		visible_message("<b>[src]</b> says, 'Winner! You win four hundred [MONEY_NAME]!'")
		give_money(PRIZE_SMALL)
		if(isliving(user) && (user in viewers(src)))
			var/mob/living/living_user = user
			living_user.add_mood_event("slots", /datum/mood_event/slots/win)

	else if(linelength == 3)
		winning = WINNING_FREESPIN
		to_chat(user, span_notice("You win three free games!"))
		balance += SPIN_PRICE * 4
		money = max(money - SPIN_PRICE * 4, money)

	else
		winning = WINNING_NOTHING
		balloon_alert(user, "no luck!")
		did_player_win = FALSE
		if(isliving(user) && (user in viewers(src)))
			var/mob/living/living_user = user
			living_user.add_mood_event("slots", /datum/mood_event/slots/loss)

	playsound(src, 'sound/machines/lever/lever_stop.ogg', 50)

	SStgui.update_uis(src)
	addtimer(CALLBACK(src, PROC_REF(clear_winning)), 3 SECONDS)

	if(did_player_win)
		add_filter("jackpot_rays", 3, ray_filter)
		animate(get_filter("jackpot_rays"), offset = 10, time = 3 SECONDS, loop = -1)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum, remove_filter), "jackpot_rays"), 3 SECONDS)
		playsound(src, 'sound/machines/roulette/roulettejackpot.ogg', 50, TRUE)

/obj/machinery/computer/slot_machine/proc/clear_winning()
	winning = WINNING_NOTHING

/// Checks for a jackpot (5 matching symbols in the middle row) for the given symbol typepath
/obj/machinery/computer/slot_machine/proc/check_jackpot(symbol_path)
	var/symbol_id = "[symbol_path]"
	for(var/list/reel in reels)
		if(reel[2] != symbol_id)
			return FALSE
	return TRUE

/// Finds the largest number of consecutive matching symbols in any row.
/// Returns 0 if no run of 3 or more is found.
/// Rewritten from the old findtext() approach since arbitrary typepath strings
/// can be prefixes of each other and would silently produce false positives.
/obj/machinery/computer/slot_machine/proc/get_lines()
	var/amountthesame = 0

	for(var/row in 1 to 3)
		var/current_symbol = null
		var/current_run = 0

		for(var/list/reel in reels)
			var/symbol = reel[row]
			if(symbol == current_symbol)
				current_run++
			else
				current_symbol = symbol
				current_run = 1
			if(current_run >= 3)
				amountthesame = max(amountthesame, current_run)

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

// ==========================================================================
// Department-themed slot machine variants
//
// Each subtype only needs to override symbol_paths / jackpot_path / bomb_path /
// theme_color. Odds and payouts are identical to the base machine — this is
// purely cosmetic flavour.
//
// theme_color is fed straight from the RADIO_COLOR_* defines so these machines
// stay visually consistent with the rest of the department UI colouring without
// duplicating hex strings.
//
// NOTE: Some of the typepaths below are best-guesses based on common TG items.
// If any fail to compile, swap them out — the UI doesn't care what the path IS,
// only that it has a usable icon/icon_state.
// ==========================================================================

/obj/machinery/computer/slot_machine/command
	name = "command slot machine"
	desc = "Gambling for the antisocial head of staff. The house always wins. You are the house."
	theme_color = RADIO_COLOR_COMMAND
	symbol_paths = list(
		/obj/item/disk/nuclear,
		/obj/item/megaphone,
		/obj/item/hand_tele,
		/obj/item/clothing/head/hats/caphat,
		/obj/item/card/id/advanced/gold,
		/obj/item/melee/baton/telescopic,
		/obj/item/grenade/flashbang,
	)
	jackpot_path = /obj/item/disk/nuclear
	bomb_path = /obj/item/grenade/flashbang

/obj/machinery/computer/slot_machine/security
	name = "security slot machine"
	desc = "Gambling for the antisocial officer. Losing is a crime. Winning is also a crime."
	theme_color = RADIO_COLOR_SECURITY
	symbol_paths = list(
		/obj/item/food/donut/plain,
		/obj/item/restraints/handcuffs,
		/obj/item/melee/baton/security,
		/obj/item/assembly/flash/handheld,
		/obj/item/clothing/head/helmet/sec,
		/obj/item/clothing/glasses/hud/security,
		/obj/item/grenade/flashbang,
	)
	jackpot_path = /obj/item/food/donut/plain
	bomb_path = /obj/item/grenade/flashbang

/obj/machinery/computer/slot_machine/medical
	name = "medical slot machine"
	desc = "Gambling for the antisocial doctor. Side effects may include crippling debt."
	theme_color = RADIO_COLOR_MEDICAL
	symbol_paths = list(
		/obj/item/storage/medkit/regular,
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/syringe,
		/obj/item/scalpel,
		/obj/item/hemostat,
		/obj/item/stack/medical/wrap/gauze,
		/obj/item/grenade/flashbang,
	)
	jackpot_path = /obj/item/storage/medkit/regular
	bomb_path = /obj/item/grenade/flashbang

/obj/machinery/computer/slot_machine/engineering
	name = "engineering slot machine"
	desc = "Gambling for the antisocial engineer. Warranty void if delaminated."
	theme_color = RADIO_COLOR_ENGINEERING
	symbol_paths = list(
		/obj/item/storage/toolbox/mechanical,
		/obj/item/construction/rcd,
		/obj/item/clothing/gloves/color/yellow,
		/obj/item/wrench,
		/obj/item/weldingtool,
		/obj/item/multitool,
		/obj/item/grenade/flashbang,
	)
	jackpot_path = /obj/item/storage/toolbox/mechanical
	bomb_path = /obj/item/grenade/flashbang

/obj/machinery/computer/slot_machine/service
	name = "service slot machine"
	desc = "Gambling for the antisocial bartender. Tips are not included. Tips are never included."
	theme_color = RADIO_COLOR_SERVICE
	symbol_paths = list(
		/obj/item/reagent_containers/cup/glass/drinkingglass,
		/obj/item/reagent_containers/cup/glass/bottle/whiskey,
		/obj/item/reagent_containers/cup/glass/bottle/beer,
		/obj/item/mop,
		/obj/item/food/grown/banana,
		/obj/item/bikehorn,
		/obj/item/grenade/flashbang,
	)
	jackpot_path = /obj/item/reagent_containers/cup/glass/drinkingglass
	bomb_path = /obj/item/grenade/flashbang

/obj/machinery/computer/slot_machine/research
	name = "research slot machine"
	desc = "Gambling for the antisocial scientist. Statistically speaking, you will lose."
	theme_color = RADIO_COLOR_SCIENCE
	symbol_paths = list(
		/obj/item/slime_extract/grey,
		/obj/item/clothing/glasses/science,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/stock_parts/capacitor,
		/obj/item/analyzer,
		/obj/item/disk/tech_disk,
		/obj/item/grenade/flashbang,
	)
	jackpot_path = /obj/item/slime_extract/grey
	bomb_path = /obj/item/grenade/flashbang

/obj/machinery/computer/slot_machine/syndicate
	name = "syndicate slot machine"
	desc = "Gambling for the antisocial operative. The house always wins. The house is Nanotrasen. Destroy the house."
	theme_color = RADIO_COLOR_SYNDICATE
	symbol_paths = list(
		/obj/item/card/emag,
		/obj/item/melee/energy/sword,
		/obj/item/storage/toolbox/syndicate,
		/obj/item/clothing/mask/gas/syndicate,
		/obj/item/soap/syndie,
		/obj/item/toy/plush/nukeplushie,
		/obj/item/grenade/c4,
	)
	jackpot_path = /obj/item/card/emag
	bomb_path = /obj/item/grenade/c4

#undef SPIN_PRICE
#undef WINNING_NOTHING
#undef WINNING_FREESPIN
#undef WINNING_SMALL
#undef WINNING_BIG
#undef WINNING_JACKPOT
#undef PRIZE_SMALL
#undef PRIZE_BIG
#undef PRIZE_JACKPOT
#undef SPIN_TIME
#undef REEL_DEACTIVATE_DELAY
#undef HOLOCHIP
#undef COIN
