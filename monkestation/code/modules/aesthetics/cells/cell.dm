/obj/item/stock_parts/cell
	icon = 'modular_skyrat/modules/aesthetics/cells/cell.dmi'
	/// The charge overlay icon file for the cell charge lights
	var/charging_icon = "cell_in"
	connector_type = null

/obj/item/stock_parts/cell/high
	charging_icon = "hcell_in"

/obj/item/stock_parts/cell/super
	charging_icon = "scell_in"

/obj/item/stock_parts/cell/hyper
	charging_icon = "hpcell_in"

/obj/item/stock_parts/cell/bluespace
	charging_icon = "bscell_in"

/obj/item/stock_parts/cell/infinite
	charging_icon = "icell_in"

/obj/item/stock_parts/cell/potato
	charging_icon = "potato_in"
	charge_light_type = "old"

/obj/item/stock_parts/cell/emproof/slime
	charging_icon = "slime_in"

/obj/item/stock_parts/cell/high/slime_hypercharged
	charging_icon = "slime_in"

/obj/item/stock_parts/cell/lead
	charging_icon = "lead_in"

/obj/item/stock_parts/cell/update_overlays()
	. = ..()
	if(grown_battery)
		. += mutable_appearance('icons/obj/power.dmi', "grown_wires")
	if((charge < 0.01) || !charge_light_type)
		return
	var/icon_link
	if(!grown_battery)
		icon_link = 'modular_skyrat/modules/aesthetics/cells/cell.dmi'
	else
		icon_link = 'icons/obj/power.dmi'
	. += mutable_appearance(icon_link, "cell-[charge_light_type]-o[(percent() >= 99.5) ? 2 : 1]")

/obj/machinery/cell_charger
	icon = 'modular_skyrat/modules/aesthetics/cells/cell.dmi'

/obj/machinery/cell_charger/update_overlays()
	. = ..()

	if(!charging)
		return

	if(!(machine_stat & (BROKEN|NOPOWER)))
		var/newlevel = round(charging.percent() * 4 / 100)
		. += "ccharger-o[newlevel]"
	if(!charging.charging_icon)
		. += image(charging.icon, charging.icon_state)
	else
		.+= image('modular_skyrat/modules/aesthetics/cells/cell.dmi', charging.charging_icon)\
