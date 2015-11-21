/datum/smelting_recipe
	var/name= ""
	var/list/ingredients[0]
	var/yieldtype = null

// Note: Returns -1 if not enough ore!
/datum/smelting_recipe/proc/checkIngredients(var/obj/machinery/mineral/processing_unit/P)
	for(var/ore_id in P.ore.storage)
		var/min_ore_required = ingredients[ore_id]

		if(P.ore.getAmount(ore_id) < min_ore_required)
			return 0

	. = 1

// RECIPES BEEP BOOP
/datum/smelting_recipe/glass
	name = "Glass"
	ingredients=list(
		MAT_GLASS = 1
	)
	yieldtype = /obj/item/stack/sheet/glass/glass


/datum/smelting_recipe/rglass
	name = "Reinforced Glass"
	ingredients=list(
		MAT_GLASS = 1,
		MAT_IRON = 1
	)
	yieldtype = /obj/item/stack/sheet/glass/rglass

/datum/smelting_recipe/gold
	name = "Gold"
	ingredients=list(
		MAT_GOLD = 1
	)
	yieldtype = /obj/item/stack/sheet/mineral/gold

/datum/smelting_recipe/silver
	name = "Silver"
	ingredients=list(
		MAT_SILVER = 1
	)
	yieldtype = /obj/item/stack/sheet/mineral/silver

/datum/smelting_recipe/diamond
	name = "Diamond"
	ingredients=list(
		MAT_DIAMOND = 1
	)
	yieldtype = /obj/item/stack/sheet/mineral/diamond

/datum/smelting_recipe/plasma
	name = "Plasma"
	ingredients=list(
		MAT_PLASMA = 1
	)
	yieldtype = /obj/item/stack/sheet/mineral/plasma

/datum/smelting_recipe/uranium
	name = "Uranium"
	ingredients=list(
		MAT_URANIUM = 1
	)
	yieldtype = /obj/item/stack/sheet/mineral/uranium

/datum/smelting_recipe/metal
	name = "Metal"
	ingredients=list(
		MAT_IRON = 1
	)
	yieldtype = /obj/item/stack/sheet/metal

/datum/smelting_recipe/plasteel
	name = "Plasteel"
	ingredients=list(
		MAT_IRON = 1,
		MAT_PLASMA = 1
	)
	yieldtype = /obj/item/stack/sheet/plasteel

/datum/smelting_recipe/clown
	name = "Bananium"
	ingredients=list(
		MAT_CLOWN = 1
	)
	yieldtype = /obj/item/stack/sheet/mineral/clown

/datum/smelting_recipe/plasma_glass
	name = "Plasma Glass"
	ingredients=list(
		MAT_PLASMA = 1,
		MAT_GLASS = 1
	)
	yieldtype = /obj/item/stack/sheet/glass/plasmaglass

/datum/smelting_recipe/plasma_rglass
	name="Reinforced Plasma Glass"
	ingredients=list(
		MAT_PLASMA = 1,
		MAT_GLASS = 1,
		MAT_IRON = 1
	)
	yieldtype=/obj/item/stack/sheet/glass/plasmarglass

/datum/smelting_recipe/phazon
	name = "phazon"
	ingredients=list(
		MAT_PHAZON = 1
	)
	yieldtype = /obj/item/stack/sheet/mineral/phazon

/datum/smelting_recipe/plastic
	name = "Plastic"
	ingredients=list(
		MAT_PLASTIC = 1
	)
	yieldtype = /obj/item/stack/sheet/mineral/plastic

/datum/smelting_recipe/cardboard
	name = "Cardboard"
	ingredients=list(
		MAT_CARDBOARD = 1
	)
	yieldtype = /obj/item/stack/sheet/cardboard

/*
/datum/smelting_recipe/pharosium
	name="pharosium"
	ingredients=list(
		"pharosium"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/pharosium

/datum/smelting_recipe/char
	name="char"
	ingredients=list(
		"char"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/char

/datum/smelting_recipe/claretine
	name="claretine"
	ingredients=list(
		"claretine"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/claretine

/datum/smelting_recipe/bohrum
	name="bohrum"
	ingredients=list(
		"bohrum"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/bohrum

/datum/smelting_recipe/syreline
	name="syreline"
	ingredients=list(
		"syreline"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/syreline

/datum/smelting_recipe/erebite
	name="erebite"
	ingredients=list(
		"erebite"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/erebite

/datum/smelting_recipe/cytine
	name="cytine"
	ingredients=list(
		"cytine"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/cytine

/datum/smelting_recipe/telecrystal
	name="telecrystal"
	ingredients=list(
		"telecrystal"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/telecrystal

/datum/smelting_recipe/mauxite
	name="mauxite"
	ingredients=list(
		"mauxite"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/mauxite

/datum/smelting_recipe/cobryl
	name="cobryl"
	ingredients=list(
		"cobryl"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/cobryl

/datum/smelting_recipe/cerenkite
	name="cerenkite"
	ingredients=list(
		"cerenkite"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/cerenkite

/datum/smelting_recipe/molitz
	name="molitz"
	ingredients=list(
		"molitz"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/molitz

/datum/smelting_recipe/uqill
	name="uqill"
	ingredients=list(
		"uqill"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/uqill
*/
