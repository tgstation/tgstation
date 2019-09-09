#define ROULETTE_SINGLES_PAYOUT 35
#define ROULETTE_SIMPLE_PAYOUT 2

#define ROULETTE_BET_ODD "odd"
#define ROULETTE_BET_EVEN "even"
#define ROULETTE_BET_1TO18 "s1-18" //adds s to prevent text2num from working
#define ROULETTE_BET_19TO36 "s19-36" //adds s to prevent text2num from working
#define ROULETTE_BET_BLACK "black"
#define ROULETTE_BET_RED "red"

///Machine that lets you play roulette. Odds are pre-defined to be the same as European Roulette without the "En Prison" rule
/obj/machinery/roulette
	name = "Roulette Table"
	desc = "A computerized roulette table."
	icon_state = "autolathe"
	density = TRUE
	use_power = IDLE_POWER_USE
	anchored = FALSE
	idle_power_usage = 10
	active_power_usage = 100
	var/static/list/numbers = list("0" = "green", "1" = "red", "3" = "red", "5" = "red", "7" = "red", "9" = "red", "12" = "red", "14" = "red", "16" = "red",\
	"18" = "red", "19" = "red", "21" = "red", "23" = "red", "25" = "red", "27" = "red", "30" = "red", "32" = "red", "34" = "red", "36" = "red",\
	"2" = "black", "4" = "black", "6" = "black", "8" = "black", "10" = "black", "11" = "black", "13" = "black", "15" = "black", "17" = "black", "20" = "black",\
	"22" = "black", "24" = "black", "26" = "black", "28" = "black", "29" = "black", "31" = "black", "33" = "black", "35" = "black")

	var/chosen_bet_amount = 10
	var/house_balance = 3500 //placeholder
	var/account_balance = 100 //placeholder
	var/chosen_bet_type = 0
	var/obj/item/card/id/my_card
	var/playing = FALSE
	var/locked = FALSE
	var/list/coin_values = list(/obj/item/coin/diamond = 100, /obj/item/coin/gold = 25, /obj/item/coin/silver = 10, /obj/item/coin/iron = 1) //Make sure this is ordered from left to right.
	var/list/coins_to_dispense = list()
	var/datum/looping_sound/jackpot/jackpot_loop

/obj/machinery/roulette/Initialize()
	. = ..()
	jackpot_loop = new(list(src), FALSE)

/obj/machinery/roulette/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/simple/roulette)
		assets.send(user)
		
		ui = new(user, src, ui_key, "roulette", name, 455, 520, master_ui, state)
		ui.open()

/obj/machinery/roulette/ui_data(mob/user)
	var/list/data = list()
	data["IsAnchored"] = anchored
	data["BetAmount"] = chosen_bet_amount
	data["BetType"] = chosen_bet_type
	data["HouseBalance"] = my_card?.registered_account.account_balance
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/card/id/C = H.get_idcard(TRUE)
		if(C)
			data["AccountBalance"] = C.registered_account.account_balance
		else
			data["AccountBalance"] = 0
		data["CanUnbolt"] = (H.get_idcard() == my_card)

	var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/simple/roulette)
	data["black"] = assets.icon_tag("black")
	data["red"] = assets.icon_tag("red")
	data["even"] = assets.icon_tag("even")
	data["odd"] = assets.icon_tag("odd")
	data["1-18"] = assets.icon_tag("1-18")
	data["19-36"] = assets.icon_tag("19-36")
	data["0"] = assets.icon_tag("0")
	data["nano"] = assets.icon_tag("nano")
	return data

/obj/machinery/roulette/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("anchor")
			anchored = !anchored
			. = TRUE
		if("ChangeBetAmount")
			chosen_bet_amount = CLAMP(text2num(params["amount"]), 10, 500)
			. = TRUE
		if("ChangeBetAmountCustom")
			var/amount = input(usr, "Bet amount:") as num|null
			if(amount)
				chosen_bet_amount = CLAMP(amount, 10, 500)
		if("ChangeBetType")
			chosen_bet_type = params["type"]
			. = TRUE
	update_icon() // Not applicable to all objects.

/obj/machinery/roulette/ui_base_html(html)
	var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/simple/roulette)
	. = replacetext(html, "<!--customheadhtml-->", assets.css_tag())

///Handles setting ownership and the betting itself.
/obj/machinery/roulette/attackby(obj/item/W, mob/user, params)
	playsound(src, 'sound/machines/card_slide.ogg', 50, TRUE)
	if(istype(W, /obj/item/card/id))
		if(my_card)
			var/obj/item/card/id/player_card = W
			if(player_card.registered_account.account_balance <= chosen_bet_amount) //Does the player have enough funds
				audible_message("<span class='warning'>You do not have the funds to play! Lower your bet or get more money.</span>")
				playsound(src, 'sound/machines/buzz-two.ogg', 30, TRUE)
				return FALSE
			if(playing) //Prevents double playing
				return FALSE
			if(chosen_bet_amount && !isnull(chosen_bet_type))
				play(user, player_card, chosen_bet_type, chosen_bet_amount)
		else
			var/obj/item/card/id/new_card = W
			if(new_card.registered_account)
				var/msg = stripped_input(user, "Name of your roulette wheel:", "Roulette Naming", "Roulette Machine")
				if(!msg)
					return
				name = msg
				desc = "Owned by [new_card.registered_account.account_holder], draws directly into [user.p_their()] account."
				my_card = new_card
				to_chat(user, "You link the wheel to your account.")
				return

///Proc called when player is going to try and play
/obj/machinery/roulette/proc/play(mob/user, obj/item/card/id/player_id, bet_type, bet_amount)
	var/potential_payout = text2num(bet_type) ? bet_amount * ROULETTE_SINGLES_PAYOUT : bet_amount * ROULETTE_SIMPLE_PAYOUT
	if(!check_bartender_funds(potential_payout))
		return FALSE	 //bartender is too poor

	my_card.registered_account.transfer_money(player_id.registered_account, bet_amount)

	playing = TRUE

	var/rolled_number = rand(0, 36)

	playsound(src, 'sound/machines/chime.ogg', 50)
	playsound(src, 'sound/machines/roulettewheel.ogg', 50)
	addtimer(CALLBACK(src, .proc/finish_play, player_id, bet_type, bet_amount, potential_payout, rolled_number), 30)


///Ran after a while to check if the player won or not.
/obj/machinery/roulette/proc/finish_play(obj/item/card/id/player_id, bet_type, bet_amount, potential_payout, rolled_number)
	var/is_winner = check_win(bet_type, bet_amount, rolled_number) //Predetermine if we won
	var/color = numbers["[rolled_number]"] //Weird syntax, but dict uses strings.
	var/result = "[rolled_number] [color]" //e.g. 31 black

	audible_message("<span class='notice'>The result is: [result]</span>")

	playing = FALSE
	if(!is_winner)
		audible_message("<span class='warning'>You lost! Better luck next time</span>")
		playsound(src, 'sound/machines/synth_no.ogg', 50)
		return FALSE

	audible_message("<span class='notice'>You have won [potential_payout] credits! Congratulations!</span>")
	playsound(src, 'sound/machines/synth_yes.ogg', 50)

	dispense_prize(potential_payout)
		

///Fills a list of coins that should be dropped.
/obj/machinery/roulette/proc/dispense_prize(payout)

	if(payout >= 1000)
		jackpot_loop.start()

	var/remaining_payout = payout

	my_card.registered_account.adjust_money(-payout)

	for(var/coin_type in coin_values) //Loop through all coins from most valuable to least valuable. Try to give as much of that coin (the iterable) as possible until you can't anymore, then move to the next.
		var/value = coin_values[coin_type] //Change this to use initial value once we change to mat datum coins.
		var/coin_count = round(remaining_payout / value)

		if(!coin_count) //Cant make coins of this type, as we can't reach it's value.
			continue

		remaining_payout -= value * coin_count
		coins_to_dispense[coin_type] += coin_count

	drop_coin() //Start recursively dropping coins

///Recursive function that runs until it runs out of coins to drop.
/obj/machinery/roulette/proc/drop_coin()
	var/coin_to_drop

	for(var/i in coins_to_dispense) //Find which coin to drop
		if(coins_to_dispense[i] <= 0) //Less than 1? go to next potential coin.
			continue
		coin_to_drop = i
		break

	if(!coin_to_drop) //No more coins, stop recursion.
		jackpot_loop.stop()
		return FALSE

	coins_to_dispense[coin_to_drop] -= 1

	var/obj/item/cash = new coin_to_drop(loc)
	playsound(cash, pick(list('sound/machines/coindrop.ogg', 'sound/machines/coindrop2.ogg')), 40, TRUE)

	addtimer(CALLBACK(src, .proc/drop_coin), 3) //Recursion time

///Returns TRUE if the player bet correctly.
/obj/machinery/roulette/proc/check_win(bet_type, bet_amount, rolled_number)
	var/actual_bet_number = text2num(bet_type) //Only returns the numeric bet types, AKA singles.
	if(actual_bet_number) //This means we're playing singles
		return rolled_number == actual_bet_number

	switch(bet_type) //Otherwise, we are playing a "special" game, switch on all the cases so we can check.
		if(ROULETTE_BET_ODD)
			return ISODD(rolled_number)
		if(ROULETTE_BET_EVEN)
			return ISEVEN(rolled_number)
		if(ROULETTE_BET_1TO18)
			return (rolled_number >= 1 && rolled_number <= 18) //between 1 to 18
		if(ROULETTE_BET_19TO36)
			return rolled_number > 18 //between 19 to 36, no need to check bounds because we wont go higher anyways
		if(ROULETTE_BET_BLACK)
			return "black" == numbers["[rolled_number]"]//Check if our number is black in the numbers dict
		if(ROULETTE_BET_RED)
			return "red" == numbers["[rolled_number]"] //Check if our number is black in the numbers dict


///Returns TRUE if the owner has enough funds to payout
/obj/machinery/roulette/proc/check_bartender_funds(payout)
	if(my_card.registered_account.account_balance >= payout)
		return TRUE //We got the betting amount
	audible_message("<span class='warning'>The bank account of [my_card.registered_account.account_holder] does not have enough funds to pay out the potential prize, contact them to fill up their account or lower your bet!</span>")
	playsound(src, 'sound/machines/buzz-two.ogg', 30, TRUE)
	return FALSE


/obj/item/roulette_wheel_beacon
	name = "roulette wheel beacon"
	desc = "N.T. approved roulette wheel beacon, toss it down and you will have a complementary roulette wheel delivered to you."
	var/used

/obj/item/roulette_wheel_beacon/attack_self()
	if(used)
		return
	loc.visible_message("<span class='warning'>\The [src] begins to beep loudly!</span>")
	used = TRUE
	addtimer(CALLBACK(src, .proc/launch_payload), 40)

/obj/item/roulette_wheel_beacon/proc/launch_payload()	
	new /obj/effect/DPtarget(drop_location(), /obj/structure/closet/supplypod/centcompod, /obj/machinery/roulette)
