//a primmie version of the kitchenaid. not childed because we dont want to inherit the machine fx

/obj/machinery/chem_dispenser/spice_rack
	name = "spice rack"
	desc = "A shelf of jars and hanging herbs."
	icon = 'modular_doppler/hearthkin/primitive_cooking_additions/icons/cooking_structures.dmi'
	icon_state = "spice_rack"
	density = FALSE
	circuit = null
	recharge_amount = 0.1 KILO WATTS
	show_ph = FALSE
	base_reagent_purity = 0.25
	drag_slowdown = 2
	var/cell_we_spawn_with = /obj/item/stock_parts/power_store/cell/crap
	dispensable_reagents = list(
		/datum/reagent/water,
		/datum/reagent/consumable/nutriment/fat,
		/datum/reagent/consumable/nutriment/fat/oil,
		/datum/reagent/consumable/nutriment/fat/oil/olive,
		/datum/reagent/consumable/nutriment/fat/oil/corn,
		/datum/reagent/consumable/sugar,
		/datum/reagent/consumable/honey,
		/datum/reagent/consumable/caramel,
		/datum/reagent/consumable/soysauce,
		/datum/reagent/consumable/capsaicin,
		/datum/reagent/consumable/vinegar,
		/datum/reagent/consumable/worcestershire,
		/datum/reagent/consumable/salt,
		/datum/reagent/consumable/blackpepper,
		/datum/reagent/consumable/curry_powder,
		/datum/reagent/consumable/flour,
		/datum/reagent/consumable/rice_flour,
		/datum/reagent/consumable/korta_flour,
		/datum/reagent/consumable/cornmeal,
		/datum/reagent/consumable/corn_starch,
		/datum/reagent/consumable/rice,
		/datum/reagent/consumable/enzyme,
		/datum/reagent/consumable/eggyolk,
		/datum/reagent/consumable/eggwhite,
		/datum/reagent/consumable/korta_milk,
		/datum/reagent/consumable/korta_nectar,
		/datum/reagent/consumable/yoghurt,
		/datum/reagent/consumable/milk,
		/datum/reagent/consumable/cream,
		/datum/reagent/medicine/salglu_solution,
	)
	emagged_reagents = list(
	)

/obj/machinery/chem_dispenser/spice_rack/Initialize(mapload)
	. = ..()
	cell = new cell_we_spawn_with(src)
