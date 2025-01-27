// Chem dispenser with awful max capacity and recharge, but it makes important cooking reagents

/obj/machinery/chem_dispenser/kitchenaid_stand
	name = "'KitchenMage' culinary acquisition helper"
	desc = "Promoted by the top celebrity chefs across the coalition, used by not one of them. \
		A towering machine capable of synthesizing common kitchen ingredients at extremely poor quality \
		for practically free. 'KitchenMage', every kitchen could use a wizard."
	icon = 'modular_doppler/colony_fabricator/icons/kitchen_dispenser.dmi'
	icon_state = "dispenser"
	base_icon_state = "dispenser"
	anchored = FALSE
	circuit = null
	recharge_amount = 0.1 KILO WATTS // Rolls "worst recharge rate ever"
	show_ph = FALSE
	base_reagent_purity = 0.25 // Simply awful
	drag_slowdown = 2
	dispensable_reagents = list(
		/datum/reagent/water,
		// Nutriment
		/datum/reagent/consumable/nutriment/vitamin,
		/datum/reagent/consumable/nutriment/protein,
		/datum/reagent/consumable/nutriment/peptides,
		// Frying
		/datum/reagent/consumable/nutriment/fat,
		/datum/reagent/consumable/nutriment/fat/oil,
		/datum/reagent/consumable/nutriment/fat/oil/olive,
		/datum/reagent/consumable/nutriment/fat/oil/corn,
		// High Fructose Corn Syrup (Yum!)
		/datum/reagent/consumable/sugar,
		/datum/reagent/consumable/corn_syrup,
		/datum/reagent/consumable/honey,
		/datum/reagent/consumable/astrotame,
		/datum/reagent/consumable/caramel,
		// I'm gonna sauce ye
		/datum/reagent/consumable/soysauce,
		/datum/reagent/consumable/ketchup,
		/datum/reagent/consumable/capsaicin,
		/datum/reagent/consumable/mayonnaise,
		/datum/reagent/consumable/bbqsauce,
		/datum/reagent/consumable/vinegar,
		/datum/reagent/consumable/worcestershire,
		// Seasonings
		/datum/reagent/consumable/salt,
		/datum/reagent/consumable/blackpepper,
		/datum/reagent/consumable/red_bay,
		/datum/reagent/consumable/curry_powder,
		// Flour (and rice)
		/datum/reagent/consumable/flour,
		/datum/reagent/consumable/rice_flour,
		/datum/reagent/consumable/korta_flour,
		/datum/reagent/consumable/cornmeal,
		/datum/reagent/consumable/corn_starch,
		/datum/reagent/consumable/rice,
		// Other Stuff
		/datum/reagent/consumable/enzyme,
		/datum/reagent/consumable/eggyolk,
		/datum/reagent/consumable/eggwhite,
		/datum/reagent/consumable/char,
		/datum/reagent/consumable/korta_milk,
		/datum/reagent/consumable/korta_nectar,
		/datum/reagent/consumable/peanut_butter,
		/datum/reagent/consumable/cherryjelly,
		/datum/reagent/consumable/yoghurt,
		/datum/reagent/consumable/dashi_concentrate,
		/datum/reagent/consumable/grounding_solution,
		/datum/reagent/consumable/milk,
		/datum/reagent/consumable/soymilk,
		/datum/reagent/consumable/cream,
		/datum/reagent/medicine/salglu_solution, // You cook with this just believe me here
	)
	// There is a news post I saw long ago, about how a food stall in china was strangely popular with locals
	// It was suspiciously popular, even. Like the entire town was addicted to the food form this one stand
	// Turns out, there is a reason for this
	// They literally were addicted
	// To the opium that was being dumped in the food to make customers come back for more
	emagged_reagents = list(
		/datum/reagent/drug/blastoff,
		/datum/reagent/drug/happiness,
		/datum/reagent/drug/kronkaine,
		/datum/reagent/drug/saturnx,
		/datum/reagent/drug/mushroomhallucinogen,
		/datum/reagent/drug/nicotine,
	)
	/// Since we don't have a board to take from, we use this to give the dispenser a cell on spawning
	var/cell_we_spawn_with = /obj/item/stock_parts/power_store/cell/crap

/obj/machinery/chem_dispenser/kitchenaid_stand/Initialize(mapload)
	. = ..()
	cell = new cell_we_spawn_with(src)
	particles = new /particles/smoke/burning
	particles.position = list(6, 20, 0)
	particles.lifespan = 1 SECONDS

/obj/machinery/chem_dispenser/kitchenaid_stand/Destroy()
	QDEL_NULL(particles)
	return ..()

/obj/machinery/chem_dispenser/kitchenaid_stand/examine(mob/user)
	. = ..()
	// If you're cold she's cold. Emag the kitchen dispenser.
	. += span_warning("HEALTH AND SAFETY NOTICE :: KEEP AWAY FROM CRYPTOGRAPHIC SEQUENCING DEVICES")

/obj/machinery/chem_dispenser/kitchenaid_stand/work_animation()
	. = ..()
	playsound(src, 'sound/machines/mining/refinery.ogg', 50, TRUE)

/obj/machinery/chem_dispenser/kitchenaid_stand/display_beaker()
	var/mutable_appearance/overlayed_beaker = beaker_overlay || mutable_appearance(icon, "disp_beaker")
	return overlayed_beaker
