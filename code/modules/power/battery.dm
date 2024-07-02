/obj/item/stock_parts/power_store/battery
	name = "megacell"
	desc = "A series of rechargeable electrochemical cells wired together to hold significantly more power than a standard power cell."
	icon = 'icons/obj/machines/cell_charger.dmi'
	icon_state = "cellbig"
	cell_size_prefix = "cellbig"
	inhand_icon_state = "cell"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	force = 10
	throwforce = 5
	throw_speed = 2
	throw_range = 2
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*12, /datum/material/glass=SMALL_MATERIAL_AMOUNT*2)
	grind_results = list(/datum/reagent/lithium = 60, /datum/reagent/iron = 10, /datum/reagent/silicon = 10)
	rating_base = STANDARD_BATTERY_CHARGE
	maxcharge = STANDARD_BATTERY_CHARGE
	chargerate = STANDARD_BATTERY_RATE

/obj/item/stock_parts/power_store/battery/empty
	empty = TRUE

/obj/item/stock_parts/power_store/battery/upgraded
	name = "upgraded megacell"
	desc = "A battery with a slightly higher capacity than normal!"
	maxcharge = STANDARD_BATTERY_CHARGE * 2.5
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT*2.5)
	chargerate = STANDARD_BATTERY_RATE * 0.5

/obj/item/stock_parts/power_store/battery/high
	name = "high-capacity megacell"
	icon_state = "hcellbig"
	maxcharge = STANDARD_BATTERY_CHARGE * 10
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT * 3)
	chargerate = STANDARD_BATTERY_RATE * 0.75

/obj/item/stock_parts/power_store/battery/high/empty
	empty = TRUE

/obj/item/stock_parts/power_store/battery/super
	name = "super-capacity megacell"
	icon_state = "scellbig"
	maxcharge = STANDARD_BATTERY_CHARGE * 20
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT * 4)
	chargerate = STANDARD_BATTERY_RATE

/obj/item/stock_parts/power_store/battery/super/empty
	empty = TRUE

/obj/item/stock_parts/power_store/battery/hyper
	name = "hyper-capacity megacell"
	icon_state = "hpcellbig"
	maxcharge = STANDARD_BATTERY_CHARGE * 30
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT * 5)
	chargerate = STANDARD_BATTERY_RATE * 1.5

/obj/item/stock_parts/power_store/battery/hyper/empty
	empty = TRUE

/obj/item/stock_parts/power_store/battery/bluespace
	name = "bluespace megacell"
	desc = "A rechargeable transdimensional megacell."
	icon_state = "bscellbig"
	maxcharge = STANDARD_BATTERY_CHARGE * 40
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT*6)
	chargerate = STANDARD_BATTERY_RATE * 2

/obj/item/stock_parts/power_store/battery/bluespace/empty
	empty = TRUE

/obj/item/stock_parts/power_store/battery/crap
	name = "\improper Nanotrasen brand rechargeable AA megacell"
	desc = "You can't top the plasma top." //TOTALLY TRADEMARK INFRINGEMENT
	maxcharge = STANDARD_BATTERY_CHARGE * 0.5
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT*1)

/obj/item/stock_parts/power_store/battery/crap/empty
	empty = TRUE
