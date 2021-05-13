GLOBAL_LIST_INIT(weighted_rare_ore_types, list(
	/obj/item/stack/ore/uranium = 5,
	/obj/item/stack/ore/diamond = 5,
	/obj/item/stack/ore/titanium = 10,
	/obj/item/stack/ore/bluespace_crystal = 5
	))

#define MAX_ORE_AMOUNT 750

/obj/structure/ore_vein
	name = "ore vein"
	icon = 'icons/obj/lavaland/terrain.dmi'
	icon_state = "ore_vein"
	anchored = TRUE

	var/ore_type
	var/ore_amount_current
	var/ore_amount_max
	var/current_extraction = 0
	///Have we been discovered with a mining scanner?
	var/discovered = FALSE
	///How many points we grant to whoever discovers us
	var/point_value = 100
	///what's our real name that will show upon discovery? null to do nothing
	var/true_name
	///the message given when you discover this geyser.
	var/discovery_message = null

/obj/structure/ore_vein/iron
	ore_type = /obj/item/stack/ore/iron
	true_name = "iron ore vein"

/obj/structure/ore_vein/plasma
	ore_type = /obj/item/stack/ore/plasma
	true_name = "plasma ore vein"

/obj/structure/ore_vein/gold
	ore_type = /obj/item/stack/ore/gold
	true_name = "gold ore vein"

/obj/structure/ore_vein/silver
	ore_type = /obj/item/stack/ore/silver
	true_name = "silver ore vein"

/obj/structure/ore_vein/Initialize()
	. = ..()
	if(!ore_type)
		ore_type = pickweight(GLOB.weighted_rare_ore_types)
	if(!ore_amount_max || !ore_amount_current)
		ore_amount_max = ore_amount_current = rand(250, MAX_ORE_AMOUNT)
	if(!true_name)
		var/obj/item/stack/ore/random_ore = ore_type
		true_name = initial(random_ore.name) + " vein"

/obj/structure/ore_vein/attackby(obj/item/item, mob/user)
	if(istype(item, /obj/item/drill_package) && discovered)
		if(locate(/obj/machinery/drill) in loc)
			return
		new/obj/machinery/drill(loc)

	if(!istype(item, /obj/item/mining_scanner) && !istype(item, /obj/item/t_scanner/adv_mining_scanner))
		return

	if(discovered)
		to_chat(user, "<span class='warning'>This ore vein has already been discovered!</span>")
		return

	to_chat(user, "<span class='notice'>You discovered the ore vein and mark it on the GPS system!</span>")
	if(discovery_message)
		to_chat(user, discovery_message)

	name = true_name

	discovered = TRUE

	AddComponent(/datum/component/gps, true_name)

	add_points(user)

/obj/structure/ore_vein/proc/add_points(mob/user)
	if(isliving(user))
		var/mob/living/living = user

		var/obj/item/card/id/card = living.get_idcard()
		if(card)
			to_chat(user, "<span class='notice'>[point_value] mining points have been paid out!</span>")
			card.mining_points += point_value

/obj/structure/ore_vein/proc/reduce_ore_amount(amount)
	ore_amount_current -= amount
	if(ore_amount_current <= 0)
		consume_vein()

/obj/structure/ore_vein/proc/consume_vein()
	qdel(src)
