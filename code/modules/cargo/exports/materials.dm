/datum/export/material
	cost = 5 // Cost per MINERAL_MATERIAL_AMOUNT, which is 2000cm3 as of April 2016.
	message = "cm3 of developer's tears. Please, report this on github"
	var/material_id = null
	export_types = list(
		/obj/item/stack/sheet/mineral, /obj/item/stack/tile/mineral,
		/obj/item/weapon/ore, /obj/item/weapon/coin)
// Yes, it's a base type containing export_types.
// But it has no material_id, so any applies_to check will return false, and these types reduce amount of copypasta a lot

/datum/export/material/get_amount(obj/O)
	if(!material_id)
		return 0
	if(!istype(O, /obj/item))
		return 0
	var/obj/item/I = O
	if(!(material_id in I.materials))
		return 0

	var/amount = I.materials[material_id]

	if(istype(I, /obj/item/stack))
		var/obj/item/stack/S = I
		amount *= S.amount
	else if(istype(I, /obj/item/weapon/ore))
		amount *= 0.8 // Station's ore redemption equipment is really goddamn good.

	return round(amount)

/datum/export/material/get_cost(obj/O)
	return round(..() / MINERAL_MATERIAL_AMOUNT)

// Materials. Nothing but plasma is really worth selling. Better leave it all to RnD and sell some plasma instead.

// Bananium. Exporting it makes the clown cry. Priceless.
/datum/export/material/bananium
	cost = 5000
	material_id = MAT_BANANIUM
	message = "cm3 of bananium"

// Diamonds. Rare and expensive.
/datum/export/material/diamond
	cost = 2500
	material_id = MAT_DIAMOND
	message = "cm3 of diamonds"

// Plasma. The oil of 26 century. The reason why you are here.
/datum/export/material/plasma
	cost = 500
	material_id = MAT_PLASMA
	message = "cm3 of plasma"

/datum/export/material/plasma/get_cost(obj/O, contr = 0, emag = 0)
	. = ..()
	if(emag) // Syndicate pays you more for the plasma.
		. = round(. * 1.5)

// Uranium. Still useful for both power generation and nuclear annihilation.
/datum/export/material/uranium
	cost = 400
	material_id = MAT_URANIUM
	message = "cm3 of uranium"

// Gold. Used in electronics and corrosion-resistant plating.
/datum/export/material/gold
	cost = 250
	material_id = MAT_GOLD
	message = "cm3 of gold"

// Silver.
/datum/export/material/silver
	cost = 100
	material_id = MAT_SILVER
	message = "cm3 of silver"

// Titanium.
/datum/export/material/titanium
	cost = 250
	material_id = MAT_TITANIUM
	message = "cm3 of titanium"

// Metal. Common building material.
/datum/export/material/metal
	message = "cm3 of metal"
	material_id = MAT_METAL
	export_types = list(
		/obj/item/stack/sheet/metal, /obj/item/stack/tile/plasteel,
		/obj/item/stack/rods, /obj/item/weapon/ore, /obj/item/weapon/coin)

// Glass. Common building material.
/datum/export/material/glass
	message = "cm3 of glass"
	material_id = MAT_GLASS
	export_types = list(/obj/item/stack/sheet/glass, /obj/item/weapon/ore,
		/obj/item/weapon/shard)