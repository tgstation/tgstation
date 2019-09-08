/obj/machinery/roulette
	name = "Roulette Table"
	desc = "A computerized roulette table."
	icon_state = "autolathe"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	var/bet_amount = 0
	var/house_balance = 3500 //placeholder
	var/account_balance = 100 //placeholder
	var/bet_type

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
	data["BetAmount"] = bet_amount
	data["BetType"] = bet_type
	data["HouseBalance"] = house_balance
	data["AccountBalance"] = account_balance

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
			anchored = anchored ? FALSE : TRUE
			. = TRUE
		if("ChangeBetAmount")
			bet_amount = CLAMP(text2num(params["amount"]), 10, 500)
			. = TRUE
		if("ChangeBetType")
			bet_type = params["type"]
			. = TRUE
	update_icon() // Not applicable to all objects.