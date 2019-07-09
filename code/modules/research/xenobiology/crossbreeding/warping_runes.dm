///////////////////////////////////////////////
//////////////////SLIME RUNES//////////////////
///////////////////////////////////////////////

/obj/effect/slimerune/grey
	name = "grey rune"
	desc = "The center has an outline of a slime extract in it."

/obj/effect/slimerune/grey/examine(mob/user)
	..()
	var/obj/item/slimecross/warping/grey/ex = extract
	to_chat(user, "<span class='notice'>It has absorbed [ex.num_absorbed] extract[(ex.num_absorbed != 1) ? "s":""].</span>")
	to_chat(user, "<span class='notice'>At 8 extracts, it can be manually fed an extract to produce a slime of that color.</span>")

/obj/effect/slimerune/grey/process()
	var/obj/item/slimecross/warping/grey/ex = extract
	if(ex.num_absorbed >= 8)
		return
	if(locate(/obj/item/slime_extract) in get_turf(loc))
		var/eaten = 0
		for(var/obj/item/slime_extract/x in get_turf(src))
			if(ex.num_absorbed >= 8)
				break
			qdel(x)
			ex.num_absorbed++
			eaten += 1
		visible_message("<span class='notice'>[src] glows, and the extract[eaten != 1 ? "s":""] on it fade[eaten != 1 ? "":"s"] away.</span>")
		if(ex.num_absorbed >= 8)
			visible_message("<span class='notice'>[src] has finished its bluespace calibration, and can now produce a slime.</span>")

/obj/effect/slimerune/grey/attackby(obj/item/slime_extract/O, mob/user)
	var/obj/item/slimecross/warping/grey/ex = extract
	if(!istype(O))
		return
	if(ex.num_absorbed < 8)
		to_chat(user, "<span class='warning'>[src] isn't calibrated with enough slime extracts to produce a slime.</span>")
		return
	ex.num_absorbed = 0
	user.visible_message("<span class='warning'>[user] places a slime extract onto [src], and a slime grows from it!</span>", "<span class='notice'>You place [O] onto [src], and a slime grows from it!</span>")
	var/mob/living/simple_animal/slime/S = new(loc)
	S.set_colour(O.slimecolor)
	qdel(O)
	return

/obj/effect/slimerune/orange
	name = "orange rune"
	desc = "It's hot to the touch..."
	var/obj/structure/bonfire/prelit/slime/fire

/obj/effect/slimerune/orange/on_place()
	fire = new(loc)

/obj/effect/slimerune/orange/on_remove()
	qdel(fire)

/obj/structure/bonfire/prelit/slime
	name = "magical flame"
	desc = "It floats above the rune with constrained purpose."

/obj/structure/bonfire/prelit/slime/CheckOxygen()
	return TRUE

/obj/structure/bonfire/prelit/slime/extinguish()
	return

/obj/effect/slimerune/purple
	name = "purple rune"
	desc = "It longs for cloth to weave and plastics to catalyze."

/obj/effect/slimerune/purple/process()
	for(var/obj/item/stack/sheet/cloth/C in get_turf(loc))
		if(C.use(20))
			var/obj/item/stack/medical/bruise_pack/B = new(loc)
			visible_message("<span class='notice'>[src] weaves [C] into [B].")
			break

	for(var/obj/item/stack/sheet/plastic/P in get_turf(loc))
		if(P.use(20))
			var/obj/item/stack/medical/ointment/O = new(loc)
			visible_message("<span class='notice'>[src] melts down [P], creating [O].")
			break

/obj/effect/slimerune/blue
	name = "blue rune"
	desc = "It constantly mists water from its intricate design."

/obj/effect/slimerune/blue/ComponentInitialize()
	AddComponent(/datum/component/slippery, 80)

/obj/effect/slimerune/blue/process()
	var/obj/effect/particle_effect/water/W = new /obj/effect/particle_effect/water(get_turf(src))
	var/datum/reagents/R = new/datum/reagents(10)
	W.reagents = R
	R.my_atom = W
	R.add_reagent(/datum/reagent/water, 10)
	for(var/atom/A in get_turf(loc))
		W.Bump(A)

/obj/effect/slimerune/metal
	name = "metal rune"
	desc = "The air above it feels solid to the touch."
	density = TRUE
	pickuptime = 100 //10 seconds.

/obj/effect/slimerune/yellow
	name = "yellow rune"
	desc = "The air around it feels negatively charged."

/obj/effect/slimerune/yellow/process()
	var/total = 0
	for(var/atom/movable/A in get_turf(loc))
		var/obj/item/stock_parts/cell/C = A.get_cell()
		if(C && C.charge > 0)
			var/amount = min(C.charge, 1000)
			total += amount
			C.use(amount)
	for(var/obj/machinery/power/apc/A in get_area(loc))
		var/obj/item/stock_parts/cell/C = A.get_cell()
		C.give(total)

/obj/effect/slimerune/darkpurple
	name = "dark purple rune"
	desc = "Plasma mist seeps from the edges of the rune, pooling in the center."
	var/time_to_produce = 2
	var/production = 0

/obj/effect/slimerune/darkpurple/process() //Will likely slow this down.
	if(production < time_to_produce)
		production++
		return
	production = 0
	var/obj/item/plasmacrystal/crystal = locate(/obj/item/plasmacrystal) in get_turf(loc)
	if(!istype(crystal))
		crystal = new(loc)
	crystal.reagents.add_reagent(/datum/reagent/toxin/plasma,5)
	crystal.update_icon()

/obj/item/plasmacrystal
	name = "plasma crystal"
	desc = "A fragile shard of crystallized plasma. Useless to fabricators, but it would probably fit in a grinder rather easily."
	icon = 'icons/obj/shards.dmi' //Temp icons
	icon_state = "plasmasmall"
	grind_results = list(/datum/reagent/toxin/plasma=0)

/obj/item/plasmacrystal/Initialize(mapload)
	. = ..()
	create_reagents(100)

/obj/item/plasmacrystal/update_icon() //Temp icons
	if(reagents.total_volume >= 100)
		icon_state = "plasmalarge"
	else if(reagents.total_volume >= 50)
		icon_state = "plasmamedium"
	else
		icon_state = "plasmasmall"

/obj/effect/slimerune/darkblue
	name = "dark blue rune"
	desc = "The air doesn't feel colder around it, but it sends a chill through you nonetheless."

/obj/effect/slimerune/darkblue/process()
	for(var/mob/living/L in get_turf(loc))
		L.adjust_bodytemperature(-20)

/obj/effect/slimerune/darkblue/Crossed(atom/movable/AM)
	. = ..()
	var/mob/living/L = AM
	if(!istype(L))
		return
	L.adjust_bodytemperature(-70) //Crossing it is much stronger of an effect.

/obj/effect/slimerune/silver
	name = "silver rune"
	desc = "Sate its hunger, so that you might sate yours."

/obj/effect/slimerune/silver/process()
	var/obj/item/reagent_containers/food/snacks/snack = locate(/obj/item/reagent_containers/food/snacks) in get_turf(loc)
	if(snack)
		var/datum/reagent/N = snack.reagents.has_reagent(/datum/reagent/consumable/nutriment)
		var/obj/item/slimecross/warping/silver/ex = extract
		qdel(snack)
		ex.nutrition += N.volume * 2

/obj/effect/slimerune/silver/Crossed(atom/movable/AM)
	. = ..()
	var/mob/living/carbon/human/H = AM
	if(!istype(H))
		return
	if(!HAS_TRAIT(H, TRAIT_NOHUNGER))
		var/difference = NUTRITION_LEVEL_FULL - H.nutrition
		if(difference > 0)
			var/obj/item/slimecross/warping/silver/ex = extract
			var/nutrition = min(ex.nutrition, difference)
			H.adjust_nutrition(nutrition)
			ex.nutrition -= nutrition

/obj/effect/slimerune/bluespace
	name = "bluespace rune"
	desc = "A rectangular hole is at the center, covered with blue cloth."
	var/obj/item/storage/backpack/satchel/warping/satchel

/obj/effect/slimerune/bluespace/on_place()
	. = ..()
	satchel = new(loc, get_turf(loc))

/obj/effect/slimerune/bluespace/process()
	if(!istype(satchel))
		extract.forceMove(loc)
		on_remove()
		qdel(src)

/obj/effect/slimerune/bluespace/on_remove()
	if(satchel)
		qdel(satchel)

/obj/item/storage/backpack/satchel/warping
	name = "wormhole satchel"
	desc = "You can make out a strange runic pattern on the interior."
	component_type = /datum/component/storage/concrete/tilebound

/obj/item/storage/backpack/satchel/warping/Initialize(mapload, turf/tileloc)
	. = ..()
	var/datum/component/storage/concrete/tilebound/STR = GetComponent(/datum/component/storage/concrete/tilebound)
	STR.base_tile = tileloc

/obj/effect/slimerune/sepia
	name = "sepia rune"
	desc = "You can feel it slow your breathing and your pulse."

/obj/effect/slimerune/sepia/on_place()
	return //Stops it from processing.

/obj/effect/slimerune/sepia/Crossed(atom/movable/AM)
	if(isliving(AM))
		var/mob/living/L = AM
		L.apply_status_effect(STATUS_EFFECT_STASIS, null, TRUE)
		RegisterSignal(L, COMSIG_LIVING_RESIST, .proc/resist_stasis)

/obj/effect/slimerune/sepia/Uncrossed(atom/movable/AM)
	if(isliving(AM))
		var/mob/living/L = AM
		L.remove_status_effect(STATUS_EFFECT_STASIS)
		UnregisterSignal(L, COMSIG_LIVING_RESIST)

/obj/effect/slimerune/sepia/Destroy() //On Destroy rather than on_remove to ensure you absolutely cannot circumvent it and maintain infinite stasis.
	for(var/mob/living/L in get_turf(src))
		L.remove_status_effect(STATUS_EFFECT_STASIS)
		UnregisterSignal(L, COMSIG_LIVING_RESIST)
	return ..()

/obj/effect/slimerune/sepia/proc/resist_stasis(mob/living/M)
	attack_hand(M)

/obj/effect/slimerune/cerulean
	name = "cerulean rune"
	desc = "It shimmers from certain angles, like an empty mirror..."
	var/atom/movable/lastcrossed

/obj/effect/slimerune/cerulean/on_place()
	return //Stops it from processing.

/obj/effect/slimerune/cerulean/Crossed(atom/movable/AM)
	if(isliving(AM))
		vis_contents -= lastcrossed
		lastcrossed = AM
		vis_contents += lastcrossed

/obj/effect/slimerune/pyrite
	name = "pyrite rune"
	desc = "It glitters, reflecting a rainbow of colors."

/obj/effect/slimerune/pyrite/on_place()
	return //Stops it from processing.

/obj/effect/slimerune/pyrite/Crossed(atom/movable/AM)
	AM.add_atom_colour(rgb(rand(0,255),rand(0,255),rand(0,255)), WASHABLE_COLOUR_PRIORITY)

/obj/effect/slimerune/red
	name = "red rune"
	desc = "Just looking at it makes you want to ball your fists."

/obj/effect/slimerune/red/on_place()
	return //Stops it from processing.

/obj/effect/slimerune/red/Crossed(atom/movable/AM)
	if(ishuman(AM))
		var/mob/living/carbon/human/C = AM
		RegisterSignal(C, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, .proc/bonus_damage)

/obj/effect/slimerune/red/Uncrossed(atom/movable/AM)
	if(ishuman(AM))
		var/mob/living/carbon/human/C = AM
		UnregisterSignal(C, COMSIG_HUMAN_MELEE_UNARMED_ATTACK)

/obj/effect/slimerune/red/proc/bonus_damage(mob/living/user, atom/A)
	if(!isliving(A))
		return
	var/mob/living/L = A
	L.visible_message("<span class='danger'>[src] glows brightly below [user]...</span>", "<span class='userdanger'>[src] glows, empowering [user]'s attack!</span>")
	L.adjustBruteLoss(10) //Turns the average punch into the equivalent of a toolbox, but only as long as you're on the tile.

/obj/effect/slimerune/green
	name = "green rune"
	desc = "Strange, alien markings line the interior. It searches for plasma."

/obj/effect/slimerune/green/process()
	for(var/obj/item/stack/sheet/mineral/plasma/P in get_turf(loc))
		if(P.use(2))
			new /obj/item/stack/sheet/resin(loc)
