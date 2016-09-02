// GENERIC //

/datum/chemical_reaction/slime
	required_other = 1
	var/slimecore = null

/datum/chemical_reaction/slime/special_reqs(datum/reagents/holder)
	..()
	if(slime_check() && slimecore && istype(holder.my_atom, slimecore))
		return 1

/datum/chemical_reaction/slime/proc/slime_check(datum/reagents/holder)
	if(istype(holder.my_atom, slimecore))
		var/obj/item/slime_extract/M = holder.my_atom
		if(M.Uses > 0) // added a limit to slime cores -- Muskets requested this
			return 1

/datum/chemical_reaction/slime/proc/slime_success(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/slime_extract/M = holder.my_atom
	var/list/seen = viewers(4, get_turf(M))
	M.Uses--
	if(M.Uses <= 0) // give the notification that the slime core is dead
		for(var/mob/mob in seen)
			mob << "<span class='notice'>\icon[M] \The [M]'s power is consumed in the reaction.</span>"
			M.name = "used slime extract"
			M.desc = "This extract has been used up."

// GREY SLIME //

// Plasma //
/datum/chemical_reaction/slime/greyplasma
	required_reagents = list("plasma" = 1)
	slimecore = /obj/item/slime_extract/grey

/datum/chemical_reaction/slime/greyplasma/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		new /mob/living/simple_animal/slime(location, "grey")
		consume_reagents(holder)
		slime_success(holder)
	location.visible_message("<span class='danger'>Infused with plasma, the \
			core begins to quiver and grow, and soon [multiplier > 1 ? "mew baby slimes emerge":"a new baby slime emerges"] from it!</span>")
	simple_feedback(holder)
	return 1

// Water //
/datum/chemical_reaction/slime/greywater
	results = list("epinephrine" = 3)
	required_reagents = list("water" = 5)
	slimecore = /obj/item/slime_extract/grey

/datum/chemical_reaction/slime/greywater/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		slime_success(holder)
		simple_react(holder)
	simple_feedback(holder)
	return 1

// Blood //
/datum/chemical_reaction/slime/greyblood
	required_reagents = list("blood" = 1)
	slimecore = /obj/item/slime_extract/grey

/datum/chemical_reaction/slime/greyblood/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0
	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		new /obj/item/weapon/reagent_containers/food/snacks/monkeycube(location)
		new /obj/item/weapon/reagent_containers/food/snacks/monkeycube(location)
		new /obj/item/weapon/reagent_containers/food/snacks/monkeycube(location)
		consume_reagents(holder)
		slime_success(holder)
	simple_feedback(holder)
	return 1

// GREEN //

// Plasma //
/datum/chemical_reaction/slime/greenplasma
	results = list("mutationtoxin" = 1)
	required_reagents = list("plasma" = 1)
	slimecore = /obj/item/slime_extract/green

/datum/chemical_reaction/slime/greenplasma/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		slime_success(holder)
		simple_react(holder)
	simple_feedback(holder)
	return 1

// Radium //
/datum/chemical_reaction/slime/greenradium
	results = list("unstablemutationtoxin" = 1)
	required_reagents = list("radium" = 1)
	slimecore = /obj/item/slime_extract/green

/datum/chemical_reaction/slime/greenradium/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		slime_success(holder)
		simple_react(holder)
	simple_feedback(holdermix_message = "<span class='info'>The mixture rapidly expands and contracts, its appearance shifting into a sickening green.</span>")
	return 1

// METAL //

// Plasma //
/datum/chemical_reaction/slime/metalplasma
	required_reagents = list("plasma" = 1)
	slimecore = /obj/item/slime_extract/metal

/datum/chemical_reaction/slime/metalplasma/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0
	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		new /obj/item/stack/sheet/plasteel (location, 5)
		new /obj/item/stack/sheet/metal (location, 15)
		consume_reagents(holder)
		slime_success(holder)
	simple_feedback(holder)
	return 1

// Water //
/datum/chemical_reaction/slime/metalwater
	required_reagents = list("water" = 1)
	slimecore = /obj/item/slime_extract/metal

/datum/chemical_reaction/slime/metalwater/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0
	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		new /obj/item/stack/sheet/rglass (location, 5)
		new /obj/item/stack/sheet/glass (location, 15)
		consume_reagents(holder)
		slime_success(holder)
	simple_feedback(holder)
	return 1

// GOLD //

// Plasma //
/datum/chemical_reaction/slime/goldplasma
	required_reagents = list("plasma" = 1)
	slimecore = /obj/item/slime_extract/gold

/datum/chemical_reaction/slime/goldplasma/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0
	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		addtimer(src, "chemical_mob_spawn", 50, FALSE, holder, 5, "Gold Slime")
		consume_reagents(holder)
		slime_success(holder)
	location.visible_message("<span class='danger'>The slime extract begins to vibrate violently !</span>")
	simple_feedback(holder)
	return 1

// Blood //
/datum/chemical_reaction/slime/goldblood
	required_reagents = list("blood" = 1)
	slimecore = /obj/item/slime_extract/gold

/datum/chemical_reaction/slime/goldplasma/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0
	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		addtimer(src, "chemical_mob_spawn", 50, FALSE, holder, 3, "Lesser Gold Slime", "neutral")
		consume_reagents(holder)
		slime_success(holder)
	location.visible_message("<span class='danger'>The slime extract begins to vibrate violently !</span>")
	simple_feedback(holder)
	return 1

// Water //
/datum/chemical_reaction/slime/goldwater
	required_reagents = list("water" = 1)
	slimecore = /obj/item/slime_extract/gold

/datum/chemical_reaction/slime/goldwater/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0
	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		addtimer(src, "chemical_mob_spawn", 50, FALSE, holder, 1, "Friendly Gold Slime", "neutral")
		consume_reagents(holder)
		slime_success(holder)
	location.visible_message("<span class='danger'>The slime extract begins to vibrate adorably !</span>")
	simple_feedback(holder)
	return 1

// SILVER //

// Plasma //
/datum/chemical_reaction/slime/silverplasma
	required_reagents = list("plasma" = 1)
	slimecore = /obj/item/slime_extract/silver

/datum/chemical_reaction/slime/silverplasma/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/list/blocked = list(/obj/item/weapon/reagent_containers/food/snacks,
		/obj/item/weapon/reagent_containers/food/snacks/store/bread,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/store/cake,
		/obj/item/weapon/reagent_containers/food/snacks/cakeslice,
		/obj/item/weapon/reagent_containers/food/snacks/store,
		/obj/item/weapon/reagent_containers/food/snacks/pie,
		/obj/item/weapon/reagent_containers/food/snacks/kebab,
		/obj/item/weapon/reagent_containers/food/snacks/pizza,
		/obj/item/weapon/reagent_containers/food/snacks/pizzaslice,
		/obj/item/weapon/reagent_containers/food/snacks/salad,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/slab,
		/obj/item/weapon/reagent_containers/food/snacks/soup,
		/obj/item/weapon/reagent_containers/food/snacks/grown,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom,
		)
	blocked |= typesof(/obj/item/weapon/reagent_containers/food/snacks/customizable)

	var/list/borks = typesof(/obj/item/weapon/reagent_containers/food/snacks) - blocked

	playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/living/carbon/C in viewers(get_turf(holder.my_atom), null))
		C.flash_eyes()

	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= i <= multiplier && slime_check(holder), i++)
		for(var/j = 1, j <= rand(5,7), j++)
			var/chosen = pick(borks)
			var/obj/B = new chosen
			if(B)
				B.loc = location
				if(prob(50))
					for(var/k = 1, k <= rand(1, 3), k++)
						step(B, pick(NORTH,SOUTH,EAST,WEST))
		consume_reagents(holder)
		slime_success(holder)
	simple_feedback(holder)
	return 1

// Water //
/datum/chemical_reaction/slime/silverwater
	required_reagents = list("water" = 1)
	slimecore = /obj/item/slime_extract/silver

/datum/chemical_reaction/slime/silverwater/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/list/borks = subtypesof(/obj/item/weapon/reagent_containers/food/drinks)

	playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/living/carbon/C in viewers(get_turf(holder.my_atom), null))
		C.flash_eyes()

	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= i <= multiplier && slime_check(holder), i++)
		for(var/j = 1, j <= rand(5,7), j++)
			var/chosen = pick(borks)
			var/obj/B = new chosen
			if(B)
				B.loc = location
				if(prob(50))
					for(var/k = 1, k <= rand(1, 3), k++)
						step(B, pick(NORTH,SOUTH,EAST,WEST))
		consume_reagents(holder)
		slime_success(holder)
	simple_feedback(holder)
	return 1

// BLUE //

// Plasma //
/datum/chemical_reaction/slime/blueplasma
	results = list("frostoil" = 10)
	required_reagents = list("plasma" = 1)
	slimecore = /obj/item/slime_extract/blue

/datum/chemical_reaction/slime/blueplasma/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		slime_success(holder)
		simple_react(holder)
	simple_feedback(holder)
	return 1

// Blood //
/datum/chemical_reaction/slime/blueblood
	required_reagents = list("blood" = 1)
	slimecore = /obj/item/slime_extract/blue

/datum/chemical_reaction/slime/blueblood/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		new /obj/item/slimepotion/stabilizer(location)
		consume_reagents(holder)
		slime_success(holder)
	simple_feedback(holder)
	return 1

// DARKBLUE //


// Plasma //
/datum/chemical_reaction/slime/darkblueplasma
	required_reagents = list("plasma" = 1)
	slimecore = /obj/item/slime_extract/darkblue

/datum/chemical_reaction/slime/darkblueplasma/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		addtimer(src, "freeze", 50, FALSE, holder)
		consume_reagents(holder)
		slime_success(holder)
	location.visible_message("<span class='danger'>The slime extract begins to vibrate adorably!</span>")
	simple_feedback(holder)
	return 1

/datum/chemical_reaction/slime/darkblueplasma/proc/freeze(datum/reagents/holder)
	if(holder && holder.my_atom)
		var/turf/location = get_turf(holder.my_atom)
		playsound(location, 'sound/effects/phasein.ogg', 100, 1)
		for(var/mob/living/M in range(location, 7))
			M.bodytemperature -= 240
			M << "<span class='notice'>You feel a chill!</span>"

// Water //
/datum/chemical_reaction/slime/darkbluewater
	required_reagents = list("water" = 1)
	slimecore = /obj/item/slime_extract/darkblue

/datum/chemical_reaction/slime/darkbluewater/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		new /obj/item/slimepotion/fireproof(location)
		consume_reagents(holder)
		slime_success(holder)
	simple_feedback(holder)
	return 1

// ORANGE //

// Plasma //
/datum/chemical_reaction/slime/orangeplasma
	required_reagents = list("plasma" = 1)
	slimecore = /obj/item/slime_extract/orange

/datum/chemical_reaction/slime/orangeplasma/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		addtimer(src, "burn", 50, FALSE, holder)
		consume_reagents(holder)
		slime_success(holder)
	location.visible_message("<span class='danger'>The slime extract begins to vibrate adorably!</span>")
	simple_feedback(holder)
	return 1

/datum/chemical_reaction/slime/orangeplasma/proc/burn(datum/reagents/holder)
	if(holder && holder.my_atom)
		var/turf/location = get_turf(holder.my_atom)
		for(var/atom/A in range(location, 5))
			A.fire_act()
		var/turf/open/T = location
		if(istype(T))
			T.atmos_spawn_air("plasma=50;TEMP=1000")

// Blood //
/datum/chemical_reaction/slime/orangeblood
	results = list("capsaicin" = 10)
	required_reagents = list("blood" = 1)
	slimecore = /obj/item/slime_extract/orange

/datum/chemical_reaction/slime/orangeblood/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		slime_success(holder)
		simple_react(holder)
	simple_feedback(holder)
	return 1

// YELLOW //

// Plasma //
/datum/chemical_reaction/slime/yellowplasma
	required_reagents = list("plasma" = 1)
	slimecore = /obj/item/slime_extract/yellow

/datum/chemical_reaction/slime/yellowplasma/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		slime_success(holder)
		consume_reagents(holder)
		new /obj/item/weapon/stock_parts/cell/high/slime(location)
	simple_feedback(holder)
	return 1

// Blood //
/datum/chemical_reaction/slime/yellowblood
	required_reagents = list("blood" = 1)
	slimecore = /obj/item/slime_extract/yellow

/datum/chemical_reaction/slime/yellowblood/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		slime_success(holder)
		consume_reagents(holder)
		empulse(location, 3, 7)
	simple_feedback(holder)
	return 1

// Water //
/datum/chemical_reaction/slime/yellowwater
	required_reagents = list("water" = 1)
	slimecore = /obj/item/slime_extract/yellow

/datum/chemical_reaction/slime/yellowwater/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		slime_success(holder)
		consume_reagents(holder)
		new /obj/item/device/flashlight/slime(location)
	simple_feedback(holder)
	location.visible_message("<span class='danger'>The slime begins to emit a soft light. Squeezing it will cause it to grow brightly.</span>")
	return 1

// PURPLE //

// Plasma //
/datum/chemical_reaction/slime/purpleplasma
	required_reagents = list("plasma" = 1)
	slimecore = /obj/item/slime_extract/purple

/datum/chemical_reaction/slime/purpleplasma/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		slime_success(holder)
		consume_reagents(holder)
		new /obj/item/slimepotion/steroid(location)
	simple_feedback(holder)
	return 1

// Sugar //
/datum/chemical_reaction/slime/purplesugar
	results = list("slimejelly" = 10)
	required_reagents = list("sugar" = 1)
	slimecore = /obj/item/slime_extract/purple

/datum/chemical_reaction/slime/purplesugar/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		slime_success(holder)
		simple_react(holder)
	simple_feedback(holder)
	return 1

// DARKPURPLE //

// Plasma //
/datum/chemical_reaction/slime/darkpurpleplasma
	required_reagents = list("plasma" = 1)
	slimecore = /obj/item/slime_extract/darkpurple

/datum/chemical_reaction/slime/darkpurpleplasma/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		slime_success(holder)
		consume_reagents(holder)
		new /obj/item/stack/sheet/mineral/plasma(location, 3)
	simple_feedback(holder)
	return 1

// RED //

// Plasma //
/datum/chemical_reaction/slime/redplasma
	required_reagents = list("plasma" = 1)
	slimecore = /obj/item/slime_extract/red

/datum/chemical_reaction/slime/redplasma/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		slime_success(holder)
		consume_reagents(holder)
		new /obj/item/slimepotion/mutator(location)
	simple_feedback(holder)
	return 1

// Blood //
/datum/chemical_reaction/slime/redblood
	required_reagents = list("blood" = 1)
	slimecore = /obj/item/slime_extract/red

/datum/chemical_reaction/slime/redblood/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		slime_success(holder)
		consume_reagents(holder)
		for(var/mob/living/simple_animal/slime/slime in viewers(location, null))
			slime.rabid = 1
			slime.visible_message("<span class='danger'>The [slime] is driven into a frenzy!</span>")
	simple_feedback(holder)
	return 1

// Water //
/datum/chemical_reaction/slime/redwater
	required_reagents = list("water" = 1)
	slimecore = /obj/item/slime_extract/red

/datum/chemical_reaction/slime/redwater/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		slime_success(holder)
		consume_reagents(holder)
		new /obj/item/slimepotion/speed(location)
	simple_feedback(holder)
	return 1

// PINK //

// Plasma //
/datum/chemical_reaction/slime/pinkplasma
	required_reagents = list("plasma" = 1)
	slimecore = /obj/item/slime_extract/pink

/datum/chemical_reaction/slime/pinkplasma/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		slime_success(holder)
		consume_reagents(holder)
		new /obj/item/slimepotion/docility(location)
	simple_feedback(holder)
	return 1

/datum/chemical_reaction/slime/pinkblood
	required_reagents = list("blood" = 1)
	required_container = /obj/item/slime_extract/pink

/datum/chemical_reaction/slime/pinkblood/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		slime_success(holder)
		consume_reagents(holder)
		new /obj/item/slimepotion/genderchange(location)
	simple_feedback(holder)
	return 1

// BLACK //

// Plasma //
/datum/chemical_reaction/slime/blackplasma
	results = list("amutationtoxin" = 1)
	required_reagents = list("plasma" = 1)
	slimecore = /obj/item/slime_extract/black

/datum/chemical_reaction/slime/blackplasma/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		slime_success(holder)
		simple_react(holder)
	simple_feedback(holder)
	return 1

// OIL //

// Plasma //
/datum/chemical_reaction/slime/oilplasma
	required_reagents = list("plasma" = 1)
	slimecore = /obj/item/slime_extract/oil

/datum/chemical_reaction/slime/oilplasma/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/turf/location = get_turf(holder.my_atom)

	var/lastkey = holder.my_atom.fingerprintslast
	var/touch_msg = "N/A"
	if(lastkey)
		var/mob/toucher = get_mob_by_key(lastkey)
		touch_msg = "[key_name_admin(lastkey)]<A HREF='?_src_=holder;adminmoreinfo=\ref[toucher]'>?</A>(<A HREF='?_src_=holder;adminplayerobservefollow=\ref[toucher]'>FLW</A>)."
	message_admins("Slime Explosion reaction started at <a href='?_src_=holder;adminplayerobservecoodjump=1;X=[location.x];Y=[location.y];Z=[location.z]'>[location.loc.name] (JMP)</a>. Last Fingerprint: [touch_msg]")
	log_game("Slime Explosion reaction started at [location.loc.name] ([location.x],[location.y],[location.z]). Last Fingerprint: [lastkey ? lastkey : "N/A"].")


	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		addtimer(src, "boom", 50, FALSE, holder)
		consume_reagents(holder)
		slime_success(holder)
	location.visible_message("<span class='danger'>The slime extract begins to vibrate violently !</span>")
	simple_feedback(holder)
	return 1

/datum/chemical_reaction/slime/oilplasma/proc/boom(datum/reagents/holder)
	if(holder && holder.my_atom)
		explosion(get_turf(holder.my_atom), 1 ,3, 6)

// LIGHTPINK //

// Plasma //
/datum/chemical_reaction/slime/pinkplasma
	slimecore = /obj/item/slime_extract/lightpink
	required_reagents = list("plasma" = 1)

/datum/chemical_reaction/slime/pinkplasma/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		slime_success(holder)
		consume_reagents(holder)
		new /obj/item/slimepotion/sentience(location)
	simple_feedback(holder)
	return 1

// ADAMANTINE //

// Plasma //
/datum/chemical_reaction/slime/adamantineplasma
	required_reagents = list("plasma" = 1)
	slimecore = /obj/item/slime_extract/adamantine

/datum/chemical_reaction/slime/adamantineplasma/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		slime_success(holder)
		consume_reagents(holder)
		var/obj/effect/golemrune/Z = new /obj/effect/golemrune
		Z.loc = location
		notify_ghosts("Golem rune created in [get_area(Z)].", 'sound/effects/ghost2.ogg', source = Z)
	simple_feedback(holder)
	return 1

// BLUESPACE //

// Plasma //
/datum/chemical_reaction/slime/bluespaceplasma
	required_reagents = list("plasma" = 1)
	slimecore = /obj/item/slime_extract/bluespace

/datum/chemical_reaction/slime/bluespaceplasma/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		slime_success(holder)
		consume_reagents(holder)
		var/obj/item/weapon/ore/bluespace_crystal/BC = new /obj/item/weapon/ore/bluespace_crystal(location)
		location.visible_message("<span class='notice'>The [BC.name] appears out of thin air!</span>")
	simple_feedback(holder)
	return 1

// Blood //
/datum/chemical_reaction/slime/bluespaceblood
	required_reagents = list("blood" = 1)
	slimecore = /obj/item/slime_extract/bluespace

/datum/chemical_reaction/slime/bluespaceblood/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		slime_success(holder)
		consume_reagents(holder)
		new /obj/item/stack/tile/bluespace(location, amount = 25)
	simple_feedback(holder)
	return 1

// CERULEAN //

// Plasma //
/datum/chemical_reaction/slime/ceruleanplasma
	required_reagents = list("plasma" = 1)
	slimecore = /obj/item/slime_extract/cerulean

/datum/chemical_reaction/slime/ceruleanplasma/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		slime_success(holder)
		consume_reagents(holder)
		new /obj/item/slimepotion/enhancer(location)
	simple_feedback(holder)
	return 1

// Blood //
/datum/chemical_reaction/slime/ceruleanblood
	required_reagents = list("blood" = 1)
	slimecore = /obj/item/slime_extract/cerulean

/datum/chemical_reaction/slime/ceruleanblood/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		slime_success(holder)
		consume_reagents(holder)
		new /obj/item/areaeditor/blueprints/slime(location)
	simple_feedback(holder)
	return 1

// SEPIA //

// Plasma //
/datum/chemical_reaction/slime/sepiaplasma
	required_reagents = list("plasma" = 1)
	slimecore = /obj/item/slime_extract/sepia

/datum/chemical_reaction/slime/sepiaplasma/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0
	var/mob/mob = get_mob_by_key(holder.my_atom.fingerprintslast)
	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		slime_success(holder)
		consume_reagents(holder)
		var/obj/effect/timestop/T = new /obj/effect/timestop(location)
		T.immune += mob
		T.timestop()
	simple_feedback(holder)
	return 1

// Water //
/datum/chemical_reaction/slime/sepiawater
	required_reagents = list("water" = 1)
	slimecore = /obj/item/slime_extract/sepia

/datum/chemical_reaction/slime/sepiawater/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		slime_success(holder)
		consume_reagents(holder)
		new /obj/item/device/camera(location)
		new /obj/item/device/camera_film(location)
	simple_feedback(holder)
	return 1

// Blood //
/datum/chemical_reaction/slime/sepiablood
	required_reagents = list("blood" = 1)
	slimecore = /obj/item/slime_extract/sepia

/datum/chemical_reaction/slime/sepiablood/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		slime_success(holder)
		consume_reagents(holder)
		new /obj/item/stack/tile/sepia(location, amount = 25)
	simple_feedback(holder)
	return 1

// PYRITE //

// Plasma //
/datum/chemical_reaction/slime/pyriteplasma
	required_reagents = list("plasma" = 1)
	slimecore = /obj/item/slime_extract/pyrite

/datum/chemical_reaction/slime/pyriteplasma/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/list/paints = subtypesof(/obj/item/weapon/paint)
	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		slime_success(holder)
		consume_reagents(holder)
		var/chosen = pick(paints)
		new chosen(location)
	simple_feedback(holder)
	return 1

// RAINBOW //

// Plasma //
/datum/chemical_reaction/slime/rainbowplasma
	required_reagents = list("plasma" = 1)
	slimecore = /obj/item/slime_extract/rainbow

/datum/chemical_reaction/slime/rainbowplasma/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		new /mob/living/simple_animal/slime/random(location)
		consume_reagents(holder)
		slime_success(holder)
	location.visible_message("<span class='danger'>Infused with plasma, the \
			core begins to quiver and grow, and soon [multiplier > 1 ? "mew baby slimes emerge":"a new baby slime emerges"] from it!</span>")
	simple_feedback(holder)
	return 1

// Blood //
/datum/chemical_reaction/slime/rainbowblood
	required_reagents = list("blood" = 1)
	slimecore = /obj/item/slime_extract/rainbow

/datum/chemical_reaction/slime/rainbowblood/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(holder, FALSE)
	if(!multiplier)
		return 0

	var/turf/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		consume_reagents(holder)
		slime_success(holder)
		new /obj/item/slimepotion/transference(location)
	simple_feedback(holder)
	return 1



