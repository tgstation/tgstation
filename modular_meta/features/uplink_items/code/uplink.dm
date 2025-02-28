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
	desc = "This is greater version of a doorjack. \
			Have 6 charges, and have longer reload time. \
			Thanks to the scientists from the syndicate for creating \
			experimental version for the elite gorlex fighters and scientists of the enemy station."
	progression_minimum = 10 MINUTES
	item = /obj/item/card/emag/doorjack/ultjacker
	cost = 10
	surplus = 20
