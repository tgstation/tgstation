#define LAVA_REMOVE_AMOUNT 50
#define GOLDBUSH_GROW_AMOUNT 30
#define STONE_DESTROY_AMOUNT 5

/obj/item/gaiasblessing
	name = "Gaia's Blessing"
	desc = "A staff of living towercap wood, infused with earthsblood. Some say it has a mind of its own, and that it will aid the wielder when fed."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "gaiablessing"
	container_type = OPENCONTAINER

/obj/item/gaiasblessing/Initialize()
	..()
	create_reagents(100)

/obj/item/gaiasblessing/afterattack(atom/O, mob/user, proximity)
	if(!proximity)
		return
	if(istype(O, /turf/open/lava))
		to_chat(user, "<span class='notice'>You point the staff toward)s the molten rock, and it starts to flow with earthsblood...</span>")
		if(!reagents.has_reagent("earthsblood",LAVA_REMOVE_AMOUNT))
			to_chat(user, "<span class='warning'>The staff needs more earthsblood to do this.</span>")
			return
		if(do_after(user, 100, target=O))
			blessLava(O, user)
			return
		to_chat(user, "<span class='warning'>You cut off the flow, interrupting the staff.</span>")
	if(istype(O, /turf/open/floor/grass))
		if(!reagents.has_reagent("earthsblood",GOLDBUSH_GROW_AMOUNT))
			to_chat(user, "<span class='warning'>The staff needs more earthsblood to do this.</span>")
			return
		if(/obj/item/gaiasblessing in O.contents)
			to_chat(user, "<span class='warning'>You cannot plant two saplings together.</span>")
			return
		to_chat(user, "<span class='notice'>You push the bottom of the staff into the grass, and it begins to grow vines into the dirt...</span>")
		if(do_after(user, 100, target=O))
			blessGrass(O, user)
			return
		to_chat(user, "<span class='warning'>You lift the staff away, and the vines twist back into the staff.</span>")
	if(istype(O, /turf/closed/mineral))
		if(!reagents.has_reagent("earthsblood",STONE_DESTROY_AMOUNT))
			to_chat(user, "<span class='warning'>The staff needs more earthsblood to do this.</span>")
			return
		to_chat(user, "<span class='notice'>You direct the staff towards the rock, and it grows a number of thick roots into it...</span>")
		if(do_after(user, 20, target=0))
			blessRock(O, user)
			return
		to_chat(user, "<span class='warning'>You turn away, and the roots recede into the staff.</span>")

/obj/item/gaiasblessing/proc/blessLava(turf/open/O, mob/user)
	if(!reagents.remove_reagent("earthsblood", LAVA_REMOVE_AMOUNT))
		to_chat(user, "<span class='warning'>The staff creaks as the earthsblood is reabsorbed.</span>")
		return
	to_chat(user, "<span class='notice'>The earthsblood pours into the lava, transforming it into water!</span>")
	new /turf/open/water(get_turf(O))

/obj/item/gaiasblessing/proc/blessGrass(turf/open/O, mob/user)
	if(!reagents.remove_reagent("earthsblood", GOLDBUSH_GROW_AMOUNT))
		to_chat(user, "<span class='warning'>The vines wilt and wither away.</span>")
		return
	to_chat(user, "<span class='notice'>The vines push into the ground, and sprout a golden sapling!</span>")
	new /obj/structure/flora/ausbushes/golden(get_turf(O))

/obj/item/gaiasblessing/proc/blessRock(turf/closed/mineral/O, mob/user)
	if(!reagents.remove_reagent("earthsblood", STONE_DESTROY_AMOUNT))
		to_chat(user, "<span class='warning'>The roots weaken, unable to dig into the rocky wall any further.</span>")
		return
	to_chat(user, "<span class='notice'>The roots shatter the stony wall, leaving freshly grown grass in their wake.</span>")
	O.gets_drilled()
	new /turf/open/floor/grass(get_turf(O))

/datum/crafting_recipe/gaias_blessing
	name = "Gaia's Blessing"
	result = /obj/item/gaiasblessing
	reqs = list(/obj/item/seeds/ambrosia/gaia = 3,
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

#undef LAVA_REMOVE_AMOUNT
#undef GOLDBUSH_GROW_AMOUNT
#undef STONE_DESTROY_AMOUNT