/obj/machinery/bitcoin_miner
	name = "SpaceCoin miner"
	desc = "This machine uses complex algorithms to mine SpaceCoin."
	circuit = /obj/item/circuitboard/machine/bitcoin_miner
	density = TRUE
	icon = 'icons/obj/economy.dmi'
	icon_state = "bit_miner"
	base_icon_state = "bit_miner_inactive"
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION
	light_power = 0.7
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	var/static/list/mod_insert = list(
		/obj/item/bitcoin/mod_amount,
		/obj/item/bitcoin/mod_perc
	)
	var/bitcoin_balance = 0
	var/min = 1
	var/max = 2
	var/got = 0
	var/perc = 3
	var/randommin = 0
	var/random1 = 0
	var/random2 = 0

/obj/machinery/bitcoin_miner/wrench_act(mob/living/user, obj/item/tool)
	if(default_unfasten_wrench(user, tool, time = 1.5 SECONDS))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/materials_market/screwdriver_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_screwdriver(user, base_icon_state, base_icon_state, tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/bitcoin_miner/update_icon_state()
	if(!powered() && icon_state == "bit_miner")
		icon_state = base_icon_state
		return ..()
	if(powered() && icon_state == "bit_miner_inactive")
		icon_state = "bit_miner"
		return ..()

/obj/machinery/bitcoin_miner/crowbar_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/bitcoin_miner/attackby(obj/item/O, mob/user, params)
	if(O == bitcoin/mod_amount)
		random1 = rand(1,3)
		random2 = rand(1,5)
		min = min + random1
		max = max + random2
		random1 = 0
		random2 = 0
		to_chat(user, span_notice("You have inserted a module into the miner."))
	else if(O == bitcoin/mod_perc)
		random1 = rand(1,2)
	return ..()

/obj/machinery/bitcoin_miner/examine(mob/user)
	. = ..()
	. += "The miner reports [bitcoin_balance] SpaceCoin are available."
	. += span_notice("The miner can get between [min] and [max] SpaceCoin.")
	. += span_notice("ALT-LMB to withdraw SpaceCoin.")
	. += span_notice("Current exchange rate: [SSbitcoin.get_price()] credits.")

/obj/machinery/bitcoin_miner/proc/mine()
	got = rand(min, max)
	bitcoin_balance = bitcoin_balance + got
	say("Mined [got] SpaceCoin!")
	playsound(src, 'sound/machines/sonar-ping.ogg', 25, FALSE)
	got = 0

/obj/machinery/bitcoin_miner/process(seconds_per_tick)
	if(SPT_PROB(perc, seconds_per_tick) && powered())
		mine()

/obj/machinery/bitcoin_miner/click_alt(mob/living/user)
	if(bitcoin_balance > 0)
		var/obj/item/holochip/holochip = new (user.drop_location(), bitcoin_balance * SSbitcoin.get_price())
		user.put_in_hands(holochip)
		to_chat(user, span_notice("You have withdrawn [bitcoin_balance] SpaceCoin at the current rate."))
		bitcoin_balance = 0
		playsound(src, 'sound/items/equip/sneakers_equip1.ogg', 50, FALSE)
		return CLICK_ACTION_SUCCESS
