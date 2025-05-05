//a megacell with infinite charge to function as a beer keg for synths

/obj/item/stock_parts/power_store/battery/infinite
	name = "unusually potent car battery"
	desc = "Analog technology has been known to display incredible longevity when the conditions are right. A century old \
	incandescent bulb, an unusually potent car battery, or particularly long lived old clothes dryer are certainly uncommon, but \
	not unheard of."
	icon = 'icons/obj/maintenance_loot.dmi'
	icon_state = "lead_battery"
	maxcharge = INFINITY
	custom_materials = list(/datum/material/glass=HALF_SHEET_MATERIAL_AMOUNT)
	chargerate = INFINITY
	ratingdesc = FALSE
	anchored = TRUE
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
