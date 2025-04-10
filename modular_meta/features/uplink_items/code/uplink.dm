////Байндлы в /bindle/...
///Вещи для нюкеров

//Мехи нюкеров
/datum/uplink_item/mech/justice
	name = "Justice Exosuit"
	desc = "Black and red syndicate mech designed for execution orders. \
		For safety reasons, the syndicate advises against standing too close."
	item = /obj/vehicle/sealed/mecha/justice/loaded
	cost = 60

///Вещи для определённых ролей трейторов
//РНД
/datum/uplink_item/device_tools/ultdoorjack
	name = "Syndicate Ultimate authentication override card"
	desc = "Pinnacle of syndicate technical revolution. \
			A ultimate doorjack..? \
			Did the Cybersun scientists spent their research grant money on this? \
			Atleast it's better than the regular one having six charges, although has a longer cooldown."
	progression_minimum = 10 MINUTES
	item = /obj/item/card/emag/doorjack/ultjacker
	cost = 6
	surplus = 20
