/datum/export/material
	cost = 5 // Cost per SHEET_MATERIAL_AMOUNT, which is 100cm3 as of May 2023.
	message = "cm3 of developer's tears. Please, report this on github"
	amount_report_multiplier = SHEET_MATERIAL_AMOUNT
	var/datum/material/material_id = null
	export_types = list(
		/obj/item/stack/sheet/mineral,
		/obj/item/stack/tile/mineral,
		/obj/item/stack/ore,
		/obj/item/coin
	)
// Yes, it's a base type containing export_types.
// But it has no material_id, so any applies_to check will return false, and these types reduce amount of copypasta a lot

/datum/export/material/get_amount(obj/O)
	if(!material_id)
		return 0
	if(!isitem(O))
		return 0

	var/obj/item/I = O
	var/list/mat_comp = I.get_material_composition(BREAKDOWN_FLAGS_EXPORT)
	var/datum/material/mat_ref = ispath(material_id) ? locate(material_id) in mat_comp : GET_MATERIAL_REF(material_id)
	if(isnull(mat_comp[mat_ref]))
		return 0

	var/amount = mat_comp[mat_ref]
	if(istype(I, /obj/item/stack/ore))
		amount *= 0.8 // Station's ore redemption equipment is really goddamn good.

	return round(amount / SHEET_MATERIAL_AMOUNT)

// Materials. Static materials exist as parent types, while materials subject to the stock market have a fluid cost as determined by material/market types
// If you're adding a new material to the stock market, make sure its export type is added here.

/datum/export/material/plasma
	cost = CARGO_CRATE_VALUE * 0.4
	k_elasticity = 0
	material_id = /datum/material/plasma
	message = "cm3 of plasma"

/datum/export/material/bananium
	cost = CARGO_CRATE_VALUE * 2
	material_id = /datum/material/bananium
	message = "cm3 of bananium"

/datum/export/material/diamond
	cost = CARGO_CRATE_VALUE
	material_id = /datum/material/adamantine
	message = "cm3 of adamantine"

/datum/export/material/mythril
	cost = CARGO_CRATE_VALUE * 3
	material_id = /datum/material/mythril
	message = "cm3 of mythril"

/datum/export/material/plastic
	cost = CARGO_CRATE_VALUE * 0.05
	message = "cm3 of plastic"
	material_id = /datum/material/plastic

/datum/export/material/runite
	cost = CARGO_CRATE_VALUE * 1.2
	message = "cm3 of runite"
	material_id = /datum/material/runite

/datum/export/material/hot_ice
	cost = CARGO_CRATE_VALUE * 0.8
	message = "cm3 of Hot Ice"
	material_id = /datum/material/hot_ice
	export_types = /obj/item/stack/sheet/hot_ice

/datum/export/material/metal_hydrogen
	cost = CARGO_CRATE_VALUE * 1.05
	message = "cm3 of metallic hydrogen"
	material_id = /datum/material/metalhydrogen
	export_types = /obj/item/stack/sheet/mineral/metal_hydrogen

/datum/export/material/market

/datum/export/material/market/diamond
	material_id = /datum/material/diamond
	message = "cm3 of diamonds"

/datum/export/material/market/uranium
	material_id = /datum/material/uranium
	message = "cm3 of uranium"

/datum/export/material/market/gold
	material_id = /datum/material/gold
	message = "cm3 of gold"

/datum/export/material/market/silver
	material_id = /datum/material/silver
	message = "cm3 of silver"

/datum/export/material/market/titanium
	material_id = /datum/material/titanium
	message = "cm3 of titanium"

/datum/export/material/market/bscrystal
	message = "of bluespace crystals"
	material_id = /datum/material/bluespace
	export_types = list(/obj/item/stack/sheet/bluespace_crystal, /obj/item/stack/ore) //For whatever reason, bluespace crystals are not a mineral

/datum/export/material/market/iron
	message = "cm3 of iron"
	material_id = /datum/material/iron
	export_types = list(
		/obj/item/stack/sheet/iron,
		/obj/item/stack/tile/iron,
		/obj/item/stack/rods,
		/obj/item/stack/ore,
		/obj/item/coin
	)

/datum/export/material/market/glass
	message = "cm3 of glass"
	material_id = /datum/material/glass
	export_types = list(
		/obj/item/stack/sheet/glass,
		/obj/item/stack/ore,
		/obj/item/shard
	)

/datum/export/material/market/get_cost(obj/O, apply_elastic = FALSE)
	var/obj/item/I = O
	var/amount = get_amount(I)
	if(!amount)
		return 0
	var/material_value = (SSstock_market.materials_prices[material_id]) * amount * MARKET_PROFIT_MODIFIER
	return round(material_value)

/datum/export/material/market/sell_object(obj/sold_item, datum/export_report/report, dry_run, apply_elastic)
	. = ..()
	var/amount = get_amount(sold_item)
	var/price = get_cost(sold_item)
	if(!amount)
		return
	if(!dry_run)
		SSstock_market.materials_quantity[material_id] += amount
		SSstock_market.materials_prices[material_id] -= round((price) * (amount / (amount + SSstock_market.materials_quantity[material_id])))
		//This formula should impact lower quantity materials greater, and higher quantity materials less. Still, it's  a bit rough. Tweaking may be needed.


// Stock blocks are a special type of export that can be used to sell a quantity of materials at a specific price on the market.
/datum/export/stock_block
	cost = 0
	message = "stock block"
	export_types = list(/obj/item/stock_block)

/datum/export/stock_block/get_cost(obj/O, apply_elastic = FALSE)
	var/obj/item/stock_block/block = O
	return block.export_value

/datum/export/stock_block/sell_object(obj/sold_item, datum/export_report/report, dry_run, apply_elastic)
	. = ..()
	if(dry_run)
		return
	var/obj/item/stock_block/sold_block = sold_item
	var/sale_value = sold_block.export_value
	SSstock_market.materials_quantity[sold_block.export_mat] += sold_block.quantity
	SSstock_market.materials_prices[sold_block.export_mat] -= round((sale_value) * (sold_block.quantity / (sold_block.quantity + SSstock_market.materials_quantity[sold_block.export_mat])))
	SSstock_market.materials_prices[sold_block.export_mat] = round(clamp(SSstock_market.materials_prices[sold_block.export_mat], initial(sold_block.export_mat.value_per_unit) * SHEET_MATERIAL_AMOUNT * 0.5 , initial(sold_block.export_mat.value_per_unit) * SHEET_MATERIAL_AMOUNT * 3))
