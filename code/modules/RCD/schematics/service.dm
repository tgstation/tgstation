//RSF schematics.
/datum/rcd_schematic/rsf
	energy_cost	= 1
	var/spawn_type
	category	= "Service"

/datum/rcd_schematic/rsf/New()
	if(!spawn_type)
		return 0
	var/atom/A = getFromPool(spawn_type)
	icon = A.icon
	icon_state = A.icon_state
	returnToPool(A)
	..()

/datum/rcd_schematic/rsf/attack(var/atom/A, var/mob/user)
	if(!is_type_in_list(A, list(/obj/structure/table, /turf/simulated/floor)))
		return 1

	to_chat(user, "Dispensing [lowertext(name)]")
	playsound(get_turf(user), 'sound/machines/click.ogg', 10, 1)
	new spawn_type(get_turf(A))

/datum/rcd_schematic/rsf/dosh
	name		= "Dosh"
	spawn_type	= /obj/item/weapon/spacecash/c10
	energy_cost	= 4

/datum/rcd_schematic/rsf/glass
	name		= "Glass"
	spawn_type	= /obj/item/weapon/reagent_containers/food/drinks/drinkingglass

/datum/rcd_schematic/rsf/flask
	name		= "Flask"
	spawn_type	= /obj/item/weapon/reagent_containers/food/drinks/flask/barflask

/datum/rcd_schematic/rsf/paper
	name		= "Paper"
	spawn_type	= /obj/item/weapon/paper

/datum/rcd_schematic/rsf/candle
	name		= "Candle"
	spawn_type	= /obj/item/candle

/datum/rcd_schematic/rsf/dice
	name		= "Dice"
	spawn_type	= /obj/item/weapon/storage/pill_bottle/dice

/datum/rcd_schematic/rsf/cards
	name		= "Deck of cards"
	spawn_type	= /obj/item/toy/cards

/datum/rcd_schematic/rsf/mug
	name		= "Mug"
	spawn_type	= /obj/item/weapon/reagent_containers/food/drinks/mug

/datum/rcd_schematic/rsf/zippo
	name		= "Zippo Lighter"
	spawn_type	= /obj/item/weapon/lighter/zippo
	energy_cost	= 2

/datum/rcd_schematic/rsf/pen
	name		= "Pen"
	spawn_type	= /obj/item/weapon/pen

/datum/rcd_schematic/rsf/cardboard
	name		= "Cardboard Sheet"
	spawn_type	= /obj/item/stack/sheet/cardboard

/datum/rcd_schematic/rsf/camera
	name		= "Camera"
	spawn_type	= /obj/item/device/camera
	energy_cost	= 4

/datum/rcd_schematic/rsf/film
	name		= "Film Cartridge"
	spawn_type	= /obj/item/device/camera_film
	energy_cost	= 2

/datum/rcd_schematic/rsf/cigar
	name		= "Cigar"
	spawn_type	= /obj/item/clothing/mask/cigarette/cigar

/datum/rcd_schematic/rsf/cigarettes
	name		= "Cigarette Packet"
	spawn_type	= /obj/item/weapon/storage/fancy/cigarettes
	energy_cost	= 3

/datum/rcd_schematic/rsf/fork
	name		= "Fork"
	spawn_type	= /obj/item/weapon/kitchen/utensil/fork
