/datum/export/material
	cost = 5 // Cost per MINERAL_MATERIAL_AMOUNT, which is 2000cm3 as of April 2016.
	message = "cm3 of developer's tears. Please, report this on github"
	var/material_id = null
	export_types = list(
		/obj/item/stack/sheet/mineral, /obj/item/stack/tile/mineral,
		/obj/item/stack/ore, /obj/item/coin)
// Yes, it's a base type containing export_types.
// But it has no material_id, so any applies_to check will return false, and these types reduce amount of copypasta a lot

/datum/export/material/get_amount(obj/O)
	if(!material_id)
		return 0
	if(!isitem(O))
		return 0
	var/obj/item/I = O
	if(!(material_id in I.materials))
		return 0

	var/amount = I.materials[material_id]

	if(istype(I, /obj/item/stack))
		var/obj/item/stack/S = I
		amount *= S.amount
		if(istype(I, /obj/item/stack/ore))
			amount *= 0.8 // Station's ore redemption equipment is really goddamn good.

	return round(amount/MINERAL_MATERIAL_AMOUNT)

// Materials. Nothing but plasma is really worth selling. Better leave it all to RnD and sell some plasma instead.

/datum/export/material/bananium
	cost = 1000
	material_id = MAT_BANANIUM
	message = "cm3 of bananium"

/datum/export/material/diamond
	cost = 500
	material_id = MAT_DIAMOND
	message = "cm3 of diamonds"

/datum/export/material/plasma
	cost = 200
	k_elasticity = 0
	material_id = MAT_PLASMA
	message = "cm3 of plasma"

/datum/export/material/uranium
	cost = 100
	material_id = MAT_URANIUM
	message = "cm3 of uranium"

/datum/export/material/gold
	cost = 125
	material_id = MAT_GOLD
	message = "cm3 of gold"

/datum/export/material/silver
	cost = 50
	material_id = MAT_SILVER
	message = "cm3 of silver"

/datum/export/material/titanium
	cost = 125
	material_id = MAT_TITANIUM
	message = "cm3 of titanium"

/datum/export/material/plastitanium
	cost = 325 // plasma + titanium costs
	material_id = MAT_TITANIUM // code can only check for one material_id; plastitanium is half plasma, half titanium
	message = "cm3 of plastitanium"

/datum/export/material/metal
	cost = 5
	message = "cm3 of metal"
	material_id = MAT_METAL
	export_types = list(
		/obj/item/stack/sheet/metal, /obj/item/stack/tile/plasteel,
		/obj/item/stack/rods, /obj/item/stack/ore, /obj/item/coin)

/datum/export/material/glass
	cost = 5
	message = "cm3 of glass"
	material_id = MAT_GLASS
	export_types = list(/obj/item/stack/sheet/glass, /obj/item/stack/ore,
		/obj/item/shard)
