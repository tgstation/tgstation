
/datum/shipping
	var/name = "Shipping Datum"
	var/value = 500
	var/sell_type
	var/abstract = 0
	var/status = "="
	var/amount_sold_total = 0
	var/profit_made_total = 0
	var/amount_sold = 0
	var/profit_made = 0
	var/amount_on_market = 0
	var/allow_import = 1
	var/category = "blugh"

/datum/shipping/proc/add_value(var/V)
	var/original_value = value
	value += V
	if(value < 0)
		value = 1
	if(value > original_value)
		status = "+"
	else if(value < original_value)
		status = "-"
	else if(value == original_value)
		status = "="
	return

/datum/shipping/proc/lower_value(var/V)
	var/original_value = value
	value -= V
	if(value < 0)
		value = 1
	if(value > original_value)
		status = "+"
	else if(value < original_value)
		status = "-"
	else if(value == original_value)
		status = "="
	return

/datum/shipping/proc/set_value(var/V)
	var/original_value = value
	value = V
	if(value < 0)
		value = 1
	if(value > original_value)
		status = "+"
	else if(value < original_value)
		status = "-"
	else if(value == original_value)
		status = "="
	return


/datum/shipping/proc/ship_obj(var/atom/movable/AM)
	SSshuttle.points += value
	profit_made_total += value
	profit_made += value
	amount_sold++
	amount_sold_total++
	amount_on_market++
	if(prob(25))
		lower_value(rand(3, 1))

/datum/shipping/proc/buy_obj(var/amount_purchased, var/obj/machinery/shipping_pad/P)
	for(var/i in 1 to amount_purchased)
		if(amount_on_market == 0)
			break
		SSshuttle.points -= value
		amount_on_market--
		new sell_type(P.loc)
	playsound(P, 'sound/effects/import_sound.wav', 50, 0)

/datum/shipping/material
	abstract = 1
	amount_on_market = 100
	category = "Materials"

/datum/shipping/material/ship_obj(var/atom/movable/AM)
	if(istype(AM, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/S = AM
		SSshuttle.points += value * S.amount
		profit_made_total += value * S.amount
		profit_made += value * S.amount
		amount_sold += S.amount
		amount_sold_total += S.amount
		amount_on_market += S.amount
		if(prob(25))
			lower_value(rand(3, 1) * S.amount)
	return

/datum/shipping/material/buy_obj(var/amount_purchased, var/obj/machinery/shipping_pad/P)
	var/obj/item/stack/sheet/S = new sell_type(P.loc)
	for(var/i in 1 to amount_purchased)
		if(amount_on_market == 0)
			break
		SSshuttle.points -= value
		amount_on_market--
		S.amount++
	playsound(P, 'sound/effects/import_sound.wav', 50, 0)


/datum/shipping/raw
	abstract = 1
	amount_on_market = 100
	category = "Materials"