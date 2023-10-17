/**
 * todo: make this a supply_pack/custom. Drop pog? ohoho yes. Would be VERY fun.
 */
/datum/supply_pack/market_materials
	name = "A Single Sheet of Bananium"
	desc = "Going market price for this kind of sheet, by Australicus Industrial Mining."
	cost = CARGO_CRATE_VALUE * 2
	// contains = list(/obj/item/stack/sheet/mineral/bananium)
	crate_name = "mineral stock sheet crate"
	group = "Canisters & Materials"
	/// What material we are trying to buy sheets of?
	var/datum/material/material
	/// How many sheets of the material we are trying to buy at once?
	var/amount

/datum/supply_pack/market_materials/get_cost()
	for(var/datum/material/mat as anything in SSstock_market.materials_prices)
		if(material == mat)
			return SSstock_market.materials_prices[mat] * amount

/datum/supply_pack/market_materials/fill(obj/structure/closet/crate/C)
	. = ..()
	new material.sheet_type(C, amount)

/datum/supply_pack/market_materials/iron
	name = "Iron Sheets"
	crate_name = "iron stock crate"
	material = /datum/material/iron
MARKET_QUANTITY_HELPERS(/datum/supply_pack/market_materials/iron)


/datum/supply_pack/market_materials/gold
	name = "Gold Sheets"
	crate_name = "gold stock crate"
	material = /datum/material/gold
MARKET_QUANTITY_HELPERS(/datum/supply_pack/market_materials/gold)
