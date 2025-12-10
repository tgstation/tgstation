/datum/export/material
	abstract_type = /datum/export/material
	cost = 5 // Cost per SHEET_MATERIAL_AMOUNT, which is 100cm3 as of May 2023.
	k_hit_percentile = 0.2 / MAX_STACK_SIZE //Meaning selling 1 full stack of materials will decrease subsequent sales by 20%
	k_recovery_time = 8 MINUTES
	message = "cm3 of developer's tears. Please, report this on github"
	amount_report_multiplier = SHEET_MATERIAL_AMOUNT
	export_types = list(
		/obj/item/stack/sheet/mineral,
		/obj/item/stack/tile/mineral,
		/obj/item/stack/ore,
		/obj/item/coin
	)
	///Material id we are trying to
	var/datum/material/material_id = null
// Yes, it's a base type containing export_types.
// But it has no material_id, so any applies_to check will return false, and these types reduce amount of copypasta a lot

/datum/export/material/New()
	var/temp_exports = export_types
	export_types = null
	. = ..()
	export_types = init_export_types(temp_exports)

/**
 * Inits an list of exports for this type. For performance this usually returns a static list
 *
 * Arguments
 * * export_data - exports whos type cache we are trying to create
*/
/datum/export/material/proc/init_export_types(export_data)
	PROTECTED_PROC(TRUE)

	var/static/list/shared_exports = null
	if(isnull(shared_exports))
		shared_exports = typecacheof(export_data, only_root_path = !include_subtypes)

	return shared_exports

/datum/export/material/get_amount(obj/O)
	if(!isitem(O))
		return 0

	var/obj/item/I = O
	var/list/mat_comp = I.get_material_composition()
	var/datum/material/mat_ref = ispath(material_id) ? locate(material_id) in mat_comp : GET_MATERIAL_REF(material_id)
	var/amount = mat_comp[mat_ref]
	if(!amount)
		return 0

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

/datum/export/material/adamantine
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

/datum/export/material/hot_ice/init_export_types(export_data)
	return typecacheof(export_data, only_root_path = !include_subtypes)

/datum/export/material/metal_hydrogen
	cost = CARGO_CRATE_VALUE * 1.05
	message = "cm3 of metallic hydrogen"
	material_id = /datum/material/metalhydrogen
	export_types = /obj/item/stack/sheet/mineral/metal_hydrogen

/datum/export/material/metal_hydrogen/init_export_types(export_data)
	return typecacheof(export_data, only_root_path = !include_subtypes)

/datum/export/material/market
	abstract_type = /datum/export/material/market
	cost = 1

/datum/export/material/market/get_base_cost(obj/exported_obj)
	return ..() * SSstock_market.materials_prices[material_id]

/**
 * Returns number of sheets in this item
 *
 * Arguments
 * * obj/sold_item - the item whos sheets we are computing
*/
/datum/export/material/market/proc/get_sheets(obj/sold_item)
	PROTECTED_PROC(TRUE)

	return get_amount(sold_item)

/datum/export/material/market/sell_object(obj/sold_item, datum/export_report/report, dry_run, apply_elastic)
	. = ..()
	var/sheets = get_sheets(sold_item)
	if(!sheets)
		return

	//This formula should impact lower quantity materials greater, and higher quantity materials less. Still, it's  a bit rough. Tweaking may be needed.
	if(!dry_run)
		//decrease the market price
		SSstock_market.adjust_material_price(material_id, -SSstock_market.materials_prices[material_id] * (sheets / (sheets + SSstock_market.materials_quantity[material_id])))
		//increase the stock
		SSstock_market.adjust_material_quantity(material_id, sheets)

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
	export_types = list(
		/obj/item/stack/sheet/bluespace_crystal,
		/obj/item/stack/ore/bluespace_crystal,
	)

/datum/export/material/market/bscrystal/init_export_types(export_data)
	return typecacheof(export_data, only_root_path = !include_subtypes)

/datum/export/material/market/iron
	message = "cm3 of iron"
	material_id = /datum/material/iron
	export_types = list(
		/obj/item/stack/sheet/iron,
		/obj/item/stack/tile/iron,
		/obj/item/stack/rods,
		/obj/item/stack/ore,
		/obj/item/coin,
	)

/datum/export/material/market/iron/init_export_types(export_data)
	return typecacheof(export_data, only_root_path = !include_subtypes)

/datum/export/material/market/glass
	message = "cm3 of glass"
	material_id = /datum/material/glass
	export_types = list(
		/obj/item/stack/sheet/glass,
		/obj/item/stack/ore,
		/obj/item/shard,
	)

/datum/export/material/market/glass/init_export_types(export_data)
	return typecacheof(export_data, only_root_path = !include_subtypes)

/datum/export/material/market/stock_block
	amount_report_multiplier = 1
	k_hit_percentile = 0.2 //20% hit per block stock which is synomonous to an full stack of sheets
	message = ""
	unit_name = "stock block"
	export_types = list(/obj/item/stock_block)

/datum/export/material/market/stock_block/init_export_types(export_data)
	return typecacheof(export_data, only_root_path = !include_subtypes)

/datum/export/material/market/stock_block/get_amount(obj/item/stock_block/block)
	return 1 //sold as 1 stock block but we adjust the markets via get_sheets()

/datum/export/material/market/stock_block/get_sheets(obj/item/stock_block/block)
	return block.custom_materials[block.custom_materials[1]] / SHEET_MATERIAL_AMOUNT

/datum/export/material/market/stock_block/get_base_cost(obj/item/stock_block/block)

	return (block.fluid ? SSstock_market.materials_prices[block.custom_materials[1].type] : block.export_value) * get_sheets(block)

/datum/export/material/market/stock_block/sell_object(obj/item/stock_block/block, datum/export_report/report, dry_run, apply_elastic)
	material_id = block.custom_materials[1].type

	return ..()
