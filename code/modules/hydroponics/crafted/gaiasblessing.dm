/obj/item/gaiasblessing
	name = "Gaia's Blessing"
	desc = "A staff of towercap wood, infused with earthsblood. Rumors say it is blessed by a botanical goddess."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "gaiablessing"

/obj/item/gaiasblessing/afterattack(atom/O, mob/user, proximity)
	if(!proximity)
		return
	if(istype(O, /turf/open/lava))
		to_chat(user, "<span class='notice'>You begin chanting a soft prayer to Gaia.</span>")
		if(do_after(user, 100, target=O))
			new /turf/open/water(get_turf(O))
			to_chat(user, "<span class='notice'>You finish the prayer, and slam the staff into the lava. Water spreads as the staff burns away!</span>")
			qdel(src)
			return
		to_chat(user, "<span class='warning'>You stop chanting.</span>")
	if(istype(O, /turf/open/floor/grass))
		to_chat(user, "<span class='notice'>You start to plant the staff in the grass, praying to Gaia</span>")
		if(do_after(user, 100, target=O))
			new /obj/structure/flora/ausbushes/golden(get_turf(O))
			to_chat(user, "<span class='notice'>You finish the prayer and the staff twists with new life!</span>")
			qdel(src)
			return

/datum/crafting_recipe/gaias_blessing
	name = "Gaia's Blessing"
	result = /obj/item/gaiasblessing
	reqs = list(/datum/reagent/medicine/earthsblood = 50,
				/obj/item/seeds/ambrosia/deus = 3,
				/obj/item/stack/sheet/mineral/wood = 10)
	time = 20
	category = CAT_PRIMAL


/obj/structure/flora/ausbushes/golden
	name = "enchanted sapling"
	desc = "A blessed tree, looking as if it grew from a staff. The air smells sweet and natural near it."
	icon_state = "goldenbush"

/obj/structure/flora/ausbushes/golden/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/flora/ausbushes/golden/Destroy()
	STOP_PROCESSING(SSobj, src)
	..()

/obj/structure/flora/ausbushes/golden/process()
	var/turf/open/T = get_turf(src)
	var/datum/gas_mixture/G = T.return_air()
	G.assert_gases(/datum/gas/plasma, /datum/gas/oxygen, /datum/gas/nitrogen)
	if(G.gases[/datum/gas/plasma])
		var/plas_amt = min(5,G.gases[/datum/gas/plasma][MOLES]) //Absorb some plasma
		G.gases[/datum/gas/plasma][MOLES] -= plas_amt

	if(G.return_pressure() > ONE_ATMOSPHERE)
		if(G.gases[/datum/gas/oxygen][MOLES] / O2STANDARD < G.gases[/datum/gas/nitrogen][MOLES] / N2STANDARD)
			G.gases[/datum/gas/nitrogen][MOLES] -= 2
		else
			G.remove(2) //Slowly try to make it normal pressure, at least.
	else
		G.gases[/datum/gas/oxygen][MOLES] += 1 //Produce oxygen!
	T.air_update_turf(TRUE)
