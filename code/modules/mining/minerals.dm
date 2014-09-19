var/list/name_to_mineral

proc/SetupMinerals()
	name_to_mineral = list()
	for(var/type in typesof(/mineral) - /mineral)
		var/mineral/new_mineral = new type
		if(!new_mineral.name)
			continue
		name_to_mineral[new_mineral.name] = new_mineral
	return 1

mineral
	///What am I called?
	var/name
	var/display_name
	///How much ore?
	var/result_amount
	///Does this type of deposit spread?
	var/spread = 1
	///Chance of spreading in any direction
	var/spread_chance

	///Path to the resultant ore.
	var/ore

	New()
		. = ..()
		if(!display_name)
			display_name = name

	proc/UpdateTurf(var/turf/unsimulated/mineral/T)
		T.UpdateMineral()

mineral/uranium
	name = "Uranium"
	result_amount = 5
	spread_chance = 10
	ore = /obj/item/weapon/ore/uranium

mineral/iron
	name = "Iron"
	result_amount = 5
	spread_chance = 25
	ore = /obj/item/weapon/ore/iron

mineral/diamond
	name = "Diamond"
	result_amount = 5
	spread_chance = 10
	ore = /obj/item/weapon/ore/diamond

mineral/gold
	name = "Gold"
	result_amount = 5
	spread_chance = 10
	ore = /obj/item/weapon/ore/gold

mineral/silver
	name = "Silver"
	result_amount = 5
	spread_chance = 10
	ore = /obj/item/weapon/ore/silver

mineral/plasma
	name = "Plasma"
	result_amount = 5
	spread_chance = 25
	ore = /obj/item/weapon/ore/plasma

mineral/clown
	display_name = "Bananium"
	name = "Clown"
	result_amount = 3
	spread = 0
	ore = /obj/item/weapon/ore/clown

mineral/phazon
	display_name = "Phazon"
	name = "Phazon"
	result_amount = 2 // 1
	spread = 0
	ore = /obj/item/weapon/ore/phazon

mineral/pharosium
	name = "Pharosium"
	result_amount = 5
	spread_chance = 5
	ore = /obj/item/weapon/ore/pharosium

mineral/char
	name = "Char"
	result_amount = 5
	spread_chance = 5
	ore = /obj/item/weapon/ore/char

mineral/claretine
	name = "Claretine"
	result_amount = 5
	spread_chance = 5
	ore = /obj/item/weapon/ore/claretine

mineral/bohrum
	name = "Bohrum"
	result_amount = 5
	spread_chance = 5
	ore = /obj/item/weapon/ore/bohrum

mineral/syreline
	name = "Syreline"
	result_amount = 5
	spread_chance = 5
	ore = /obj/item/weapon/ore/syreline

mineral/erebite
	name = "Erebite"
	result_amount = 5
	spread_chance = 5
	ore = /obj/item/weapon/ore/erebite

mineral/cytine
	name = "Cytine"
	result_amount = 5
	spread_chance = 5
	ore = /obj/item/weapon/ore/cytine

mineral/uqill
	name = "Uqill"
	result_amount = 5
	spread_chance = 5
	ore = /obj/item/weapon/ore/uqill

mineral/telecrystal
	name = "Telecrystal"
	result_amount = 5
	spread_chance = 5
	ore = /obj/item/weapon/ore/telecrystal

mineral/mauxite
	name = "Mauxite"
	result_amount = 5
	spread_chance = 5
	ore = /obj/item/weapon/ore/mauxite

mineral/cobryl
	name = "Cobryl"
	result_amount = 5
	spread_chance = 5
	ore = /obj/item/weapon/ore/cobryl

mineral/cerenkite
	name = "Cerenkite"
	result_amount = 5
	spread_chance = 5
	ore = /obj/item/weapon/ore/cerenkite

mineral/molitz
	name = "Molitz"
	result_amount = 5
	spread_chance = 5
	ore = /obj/item/weapon/ore/molitz

mineral/gibtonite
	display_name = "Gibtonite"
	name = "Gibtonite"
	result_amount = 1
	spread = 1
	ore = /obj/item/weapon/twohanded/required/gibtonite
	UpdateTurf(var/turf/T)
		if(!istype(T,/turf/unsimulated/mineral/gibtonite))
			T.ChangeTurf(/turf/unsimulated/mineral/gibtonite)
		else
			..()

mineral/cave
	display_name = "Cave"
	name = "Cave"
	result_amount = 1
	spread = 1
	ore = null
	UpdateTurf(var/turf/T)
		if(!istype(T,/turf/unsimulated/floor/asteroid/cave))
			T.ChangeTurf(/turf/unsimulated/floor/asteroid/cave)
		else
			..()