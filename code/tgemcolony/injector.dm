/obj/item/handheldinjector
	name = "handheld injector"
	icon = 'icons/obj/mining.dmi'
	icon_state = "injector3"
	item_state = "jackhammer"
	desc = "For planting gems in the ground manually, Used for jumpstarting a Colony."
	usesound = 'sound/weapons/drill.ogg'
	hitsound = 'sound/weapons/drill.ogg'
	toolspeed = 1
	var/charges = 3

/obj/item/trash/handheldinjector
	name = "used handheld injector"
	icon = 'icons/obj/mining.dmi'
	icon_state = "injectorempty"
	item_state = "jackhammer"
	desc = "The tip is now dull, chipped, and there's no seed within."

/turf/closed/kindergartenrock
	name = "drained rock"
	icon = 'icons/turf/mining.dmi'
	icon_state = "rock_lowchance"
	canSmoothWith = null
	baseturfs = /turf/open/floor/plating/kindergarden
	opacity = 1
	density = TRUE

/turf/closed/kindergartenrock/attackby(obj/item/I, mob/user, params)
	if (!user.IsAdvancedToolUser())
		to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	if(I.tool_behaviour == TOOL_MINING)
		var/turf/T = user.loc
		if (!isturf(T))
			return

		to_chat(user, "<span class='notice'>You start picking...</span>")

		if(I.use_tool(src, user, 120, volume=50))
			if(ismineralturf(src))
				to_chat(user, "<span class='notice'>You finish cutting into the rock.</span>")
				playsound(src, 'sound/effects/break_stone.ogg', 50, 1)
				ScrapeAway(null, CHANGETURF_DEFER_CHANGE)
				SSblackbox.record_feedback("tally", "pick_used_mining", 1, I.type)
	else
		if(istype(I,/obj/item/handheldinjector))
			to_chat(user, "<span class='notice'>You can't inject in this lifeless soil.</span>")
		else
			return attack_hand(user)

/obj/kindergartengem
	density = TRUE
	name = "Kindergarten Deposit"
	icon = 'icons/turf/mining.dmi'
	icon_state = "rock_lowchance"
	desc = "It feels as if there's life growing inside this rock."
	opacity = 1
	var/list/potentialgems = list("Ruby") //rubies only spawn if there's no other gems to make.
	var/rubyremoved = FALSE
	var/bananium = 0
	var/bscrystal = 0
	var/diamond = 0
	var/gibtonite = 0
	var/gold = 0
	var/iron = 0
	var/plasma = 0
	var/silver = 0
	var/titanium = 0
	var/uranium = 0

/obj/kindergartengem/proc/pickgem()
	for(var/turf/A in range(3,src))
		if(istype(A, /turf/closed/mineral))
			var/turf/closed/mineral/M = A
			if(istype(M, /turf/closed/mineral/bananium))
				bananium = bananium+1
			if(istype(M, /turf/closed/mineral/bscrystal))
				bscrystal = bscrystal+1
			if(istype(M, /turf/closed/mineral/diamond))
				diamond = diamond+1
			if(istype(M, /turf/closed/mineral/gibtonite))
				gibtonite = gibtonite+1
			if(istype(M, /turf/closed/mineral/gold))
				gold = gold+1
			if(istype(M, /turf/closed/mineral/iron))
				iron = iron+1
			if(istype(M, /turf/closed/mineral/plasma))
				plasma = plasma+1
			if(istype(M, /turf/closed/mineral/silver))
				silver = silver+1
			if(istype(M, /turf/closed/mineral/titanium))
				titanium = titanium+1
			if(istype(M, /turf/closed/mineral/uranium))
				uranium = uranium+1

	//checking for potential gems.
	if(bscrystal >= 2)
		src.potentialgems.Add("Pearl")
		if(rubyremoved == FALSE)
			src.potentialgems.Remove("Ruby")
			rubyremoved = TRUE
	if(iron >= 3 && plasma >= 1)
		src.potentialgems.Add("Amethyst")
		if(rubyremoved == FALSE)
			src.potentialgems.Remove("Ruby")
			rubyremoved = TRUE
	if(titanium >= 1 && uranium >= 1)
		src.potentialgems.Add("Peridot")
		if(rubyremoved == FALSE)
			src.potentialgems.Remove("Ruby")
			rubyremoved = TRUE
	if(titanium >= 1 && diamond >= 1)
		src.potentialgems.Add("Agate")
		if(rubyremoved == FALSE)
			src.potentialgems.Remove("Ruby")
			rubyremoved = TRUE
	if(plasma >= 3 && uranium >= 1)
		src.potentialgems.Add("Jade")
		if(rubyremoved == FALSE)
			src.potentialgems.Remove("Ruby")
			rubyremoved = TRUE
	if(plasma >= 3 && diamond >= 1)
		src.potentialgems.Add("Rose Quartz")
		if(rubyremoved == FALSE)
			src.potentialgems.Remove("Ruby")
			rubyremoved = TRUE
	if(uranium >= 2 && titanium >= 2)
		src.potentialgems.Add("Bismuth")
		if(rubyremoved == FALSE)
			src.potentialgems.Remove("Ruby")
			rubyremoved = TRUE
	if(bscrystal >= 1 && diamond >= 2) //highly expensive due to it's OPness.
		src.potentialgems.Add("Sapphire")
		if(rubyremoved == FALSE)
			src.potentialgems.Remove("Ruby")
			rubyremoved = TRUE

	//choosing a gem spawner
	var/chosengem = pick(potentialgems)
	if(chosengem == "Ruby")
		new/obj/effect/mob_spawn/human/gem(get_turf(src))
	if(chosengem == "Pearl")
		new/obj/effect/mob_spawn/human/gem/pearl(get_turf(src))
	if(chosengem == "Agate")
		new/obj/effect/mob_spawn/human/gem/agate(get_turf(src))
	if(chosengem == "Jade")
		new/obj/effect/mob_spawn/human/gem/jade(get_turf(src))
	if(chosengem == "Rose Quartz")
		new/obj/effect/mob_spawn/human/gem/rosequartz(get_turf(src))
	if(chosengem == "Amethyst")
		new/obj/effect/mob_spawn/human/gem/amethyst(get_turf(src))
	if(chosengem == "Peridot")
		new/obj/effect/mob_spawn/human/gem/peridot(get_turf(src))
	if(chosengem == "Bismuth")
		new/obj/effect/mob_spawn/human/gem/bismuth(get_turf(src))
	if(chosengem == "Sapphire")
		new/obj/effect/mob_spawn/human/gem/sapphire(get_turf(src))

	//convert nearby materials
	for(var/turf/A in range(3,src))
		if(istype(A, /turf/closed/mineral))
			var/turf/closed/mineral/M = A
			new/turf/closed/kindergartenrock(locate(M.x,M.y,M.z))
	for(var/turf/A in range(4,src))
		if(istype(A, /turf/open/floor/plating/asteroid))
			var/turf/open/floor/plating/asteroid/M = A
			new/turf/open/floor/plating/kindergarden(locate(M.x,M.y,M.z))
	//kill all flora, farms, and human nests
	for(var/obj/A in range(4,src))
		if(istype(A, /obj/structure/flora) || istype(A, /obj/structure/lavaland/human_nest))
			A.visible_message("<span class='danger'>[A] withers away into dust!</span>")
			del(A)
		if(istype(A, /obj/machinery/hydroponics/soil))
			A.visible_message("<span class='danger'>[A] becomes drained!</span>")
			del(A)

	del(src)

/obj/kindergartengem/Initialize()
	. = ..()
	spawn(200)
	pickgem()