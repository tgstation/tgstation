/// This is the bitcoin miner!
/// My code isn't going to be good. This is my first time!
/// I will be editing the galactic materials market file

/obj/machinery/bitcoin_miner
	name = "bitcoin miner"
	desc = "This machine mines bitcoins! To the moon!"
	circuit = /obj/item/circuitboard/machine/bitcoin_miner
	//req_access = list(ACCESS_CARGO) do i need to have this?
	density = TRUE
	icon = 'icons/obj/economy.dmi'
	icon_state = "bit_miner"
	base_icon_state = "bit_miner_inactive"
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION
	light_power = 0.7
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	var/static/list/money_insert = list(
		/obj/item/holochip
	)
	var/static/list/min_insert = list(
		/obj/item/organ/liver,
		/obj/item/papercutter,
		/obj/item/clothing/head/utility/bomb_hood,
		/obj/item/clothing/suit/utility/bomb_suit,
		/obj/item/clothing/gloves/color/fyellow,
		/obj/item/trash/can,
		/obj/item/food/deadmouse,
		/obj/item/kitchen/rollingpin,
		/obj/item/gun/energy/laser/practice,
		/obj/item/phone,
		///obj/item/book/manual/wiki/securityspacelaw, it errors out for some reason
		/obj/item/dice/d8
	)
	var/static/list/max_insert = list(
		/obj/item/clothing/head/bio_hood,
		/obj/item/toner/large,
		/obj/item/flashlight/flare,
		/obj/item/wallframe/camera,
		/obj/item/clothing/mask/breath,
		/obj/item/pen/fourcolor,
		/obj/item/clothing/suit/hazardvest,
		/obj/item/storage/briefcase/secure,
		/obj/item/gavelhammer,
		/obj/item/clothing/neck/tie/black
	)
	var/upgrade_state = 1
	var/bitcoin_balance = 0
	var/min = 1
	var/max = 2
	var/got = 0
	var/perc = 20

/obj/machinery/bitcoin_miner/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(default_unfasten_wrench(user, tool, time = 1.5 SECONDS) == SUCCESSFUL_UNFASTEN)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/materials_market/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
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
	. = ..()
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/bitcoin_miner/attackby(obj/item/O, mob/user, params)
	if(is_type_in_list(O, money_insert))
		var/value = O.get_item_credit_value()

		if(!value)
			say("Cannot insert nil credits.")
			playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, FALSE)
			return TRUE

		to_chat(user, span_notice("You have inserted [value] credits into the machine. It seems it mines better now."))
		playsound(src, 'sound/machines/synth/synth_yes.ogg', 50, FALSE)
		perc = perc + value/100
		qdel(O)

		return ..()

	else if(is_type_in_list(O, min_insert))
		to_chat(user, span_notice("You have inserted [O.name] into the machine"))
		playsound(src, 'sound/machines/compiler/compiler-stage2.ogg', 50, FALSE)
		qdel(O)
		min = min + 1

		return ..()

	else if(is_type_in_list(O, max_insert))
		to_chat(user, span_notice("You have inserted [O.name] into the machine"))
		playsound(src, 'sound/machines/compiler/compiler-stage2.ogg', 50, FALSE)
		qdel(O)
		max = max + 1

	return ..()

/obj/machinery/bitcoin_miner/examine(mob/user)
	. = ..()
	. += "The miner reports [bitcoin_balance] bitcoins are available."
	. += span_notice("The miner can get between [min] and [max] bitcoin.")
	. += span_notice("ALT-LMB to withdraw bitcoins.")
	. += span_notice("Current price: [SSbitcoin.get_price()] credits.")

/obj/machinery/bitcoin_miner/proc/mine()
	got = rand(min, max)
	bitcoin_balance = bitcoin_balance + got
	say("Mined [got] bitcoins!")
	playsound(src, 'sound/machines/sonar-ping.ogg', 25, FALSE)
	got = 0

/obj/machinery/bitcoin_miner/process(seconds_per_tick)
	if(SPT_PROB(10, seconds_per_tick) && powered())
		mine()

/obj/machinery/bitcoin_miner/click_alt(mob/living/user)
	if(bitcoin_balance > 0)
		var/obj/item/holochip/holochip = new (user.drop_location(), bitcoin_balance * SSbitcoin.get_price())
		user.put_in_hands(holochip)
		bitcoin_balance = 0
		playsound(src, 'sound/items/equip/sneakers-equip1.ogg', 50, FALSE)
		return CLICK_ACTION_SUCCESS
