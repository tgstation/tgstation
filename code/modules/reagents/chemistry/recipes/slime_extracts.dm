
/datum/chemical_reaction/slime
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME
	required_other = TRUE
	var/deletes_extract = TRUE

/datum/chemical_reaction/slime/pre_reaction_other_checks(datum/reagents/holder)
	var/obj/item/slime_extract/extract = holder.my_atom
	if(!istype(extract))
		return FALSE

	return extract.extract_uses > 0

/datum/chemical_reaction/slime/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	use_slime_core(holder)

/datum/chemical_reaction/slime/proc/use_slime_core(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, "type")
	if(deletes_extract)
		delete_extract(holder)

/datum/chemical_reaction/slime/proc/delete_extract(datum/reagents/holder)
	var/obj/item/slime_extract/M = holder.my_atom
	if(M.extract_uses <= 0 && !results.len) //if the slime doesn't output chemicals
		qdel(M)

//Grey
/datum/chemical_reaction/slime/slimespawn
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/grey

/datum/chemical_reaction/slime/slimespawn/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/mob/living/basic/slime/spawning_slime = new(get_turf(holder.my_atom), /datum/slime_type/grey)
	spawning_slime.visible_message(span_danger("Infused with plasma, the core begins to quiver and grow, and a new baby slime emerges from it!"))
	..()

/datum/chemical_reaction/slime/slimeinaprov
	results = list(/datum/reagent/medicine/epinephrine = 3)
	required_reagents = list(/datum/reagent/water = 5)
	required_container = /obj/item/slime_extract/grey

/datum/chemical_reaction/slime/slimemonkey
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/grey

/datum/chemical_reaction/slime/slimemonkey/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	for(var/i in 1 to 3)
		new /obj/item/food/monkeycube(get_turf(holder.my_atom))
	..()

//Green
/datum/chemical_reaction/slime/slimemutate
	results = list(/datum/reagent/mutationtoxin/jelly = 1)
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/green

/datum/chemical_reaction/slime/slimehuman
	results = list(/datum/reagent/mutationtoxin = 1)
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/green

/datum/chemical_reaction/slime/slimelizard
	results = list(/datum/reagent/mutationtoxin/lizard = 1)
	required_reagents = list(/datum/reagent/uranium/radium = 1)
	required_container = /obj/item/slime_extract/green

//Metal
/datum/chemical_reaction/slime/slimemetal
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/metal

/datum/chemical_reaction/slime/slimemetal/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/turf/location = get_turf(holder.my_atom)
	new /obj/item/stack/sheet/plasteel(location, 5)
	new /obj/item/stack/sheet/iron(location, 15)
	..()

/datum/chemical_reaction/slime/slimeglass
	required_reagents = list(/datum/reagent/water = 1)
	required_container = /obj/item/slime_extract/metal

/datum/chemical_reaction/slime/slimeglass/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/turf/location = get_turf(holder.my_atom)
	new /obj/item/stack/sheet/rglass(location, 5)
	new /obj/item/stack/sheet/glass(location, 15)
	..()

//Gold
/datum/chemical_reaction/slime/slimemobspawn
	required_reagents = list(/datum/reagent/toxin/plasma = 15)
	required_container = /obj/item/slime_extract/gold
	deletes_extract = FALSE //we do delete, but we don't do so instantly
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME | REACTION_TAG_DANGEROUS

/datum/chemical_reaction/slime/slimemobspawn/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	summon_mobs(holder, T)
	var/obj/item/slime_extract/M = holder.my_atom
	deltimer(M.qdel_timer)
	..()
	M.qdel_timer = addtimer(CALLBACK(src, PROC_REF(delete_extract), holder), 55, TIMER_STOPPABLE)

/datum/chemical_reaction/slime/slimemobspawn/proc/summon_mobs(datum/reagents/holder, turf/T)
	T.visible_message(span_danger("The slime extract begins to vibrate violently!"))
	addtimer(CALLBACK(src, PROC_REF(chemical_mob_spawn), holder, 4, "Gold Slime", HOSTILE_SPAWN), 5 SECONDS)

/datum/chemical_reaction/slime/slimemobspawn/lesser
	required_reagents = list(/datum/reagent/blood = 1)

/datum/chemical_reaction/slime/slimemobspawn/lesser/summon_mobs(datum/reagents/holder, turf/T)
	T.visible_message(span_danger("The slime extract begins to vibrate violently!"))
	addtimer(CALLBACK(src, PROC_REF(chemical_mob_spawn), holder, 3, "Lesser Gold Slime", HOSTILE_SPAWN, FACTION_NEUTRAL), 5 SECONDS)

/datum/chemical_reaction/slime/slimemobspawn/friendly
	required_reagents = list(/datum/reagent/water = 1)

/datum/chemical_reaction/slime/slimemobspawn/friendly/summon_mobs(datum/reagents/holder, turf/T)
	T.visible_message(span_danger("The slime extract begins to vibrate adorably!"))
	addtimer(CALLBACK(src, PROC_REF(chemical_mob_spawn), holder, 1, "Friendly Gold Slime", FRIENDLY_SPAWN, FACTION_NEUTRAL), 5 SECONDS)

/datum/chemical_reaction/slime/slimemobspawn/spider
	required_reagents = list(/datum/reagent/spider_extract = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME | REACTION_TAG_DANGEROUS

/datum/chemical_reaction/slime/slimemobspawn/spider/summon_mobs(datum/reagents/holder, turf/T)
	T.visible_message(span_danger("The slime extract begins to vibrate crikey-ingly!"))
	addtimer(CALLBACK(src, PROC_REF(chemical_mob_spawn), holder, 3, "Traitor Spider Slime", /mob/living/basic/spider/giant/midwife, FACTION_NEUTRAL, FALSE), 5 SECONDS)


//Silver
/datum/chemical_reaction/slime/slimebork
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/silver

/datum/chemical_reaction/slime/slimebork/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	//BORK BORK BORK
	var/turf/T = get_turf(holder.my_atom)

	playsound(T, 'sound/effects/phasein.ogg', 100, TRUE)

	for(var/mob/living/carbon/C in viewers(T, null))
		C.flash_act()

	for(var/i in 1 to 4 + rand(1,2))
		var/chosen = getbork()
		var/obj/item/food_item = new chosen(T)
		ADD_TRAIT(food_item, TRAIT_FOOD_SILVER, INNATE_TRAIT)
		if(prob(5))//Fry it!
			food_item.AddElement(/datum/element/fried_item, rand(15, 60) SECONDS)
		if(prob(5))//Grill it!
			food_item.AddElement(/datum/element/grilled_item, rand(30 SECONDS, 100 SECONDS))
		if(prob(50))
			for(var/j in 1 to rand(1, 3))
				step(food_item, pick(NORTH,SOUTH,EAST,WEST))
	..()

/datum/chemical_reaction/slime/slimebork/proc/getbork()
	return get_random_food()

/datum/chemical_reaction/slime/slimebork/drinks
	required_reagents = list(/datum/reagent/water = 1)

/datum/chemical_reaction/slime/slimebork/drinks/getbork()
	return get_random_drink()

//Blue
/datum/chemical_reaction/slime/slimefrost
	results = list(/datum/reagent/consumable/frostoil = 10)
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/blue

/datum/chemical_reaction/slime/slimestabilizer
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/blue

/datum/chemical_reaction/slime/slimestabilizer/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	new /obj/item/slimepotion/slime/stabilizer(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime/slimefoam
	required_reagents = list(/datum/reagent/water = 5)
	required_container = /obj/item/slime_extract/blue

/datum/chemical_reaction/slime/slimefoam/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	holder.create_foam(/datum/effect_system/fluid_spread/foam, 80, span_danger("[src] spews out foam!"), log = TRUE)

//Dark Blue
/datum/chemical_reaction/slime/slimefreeze
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/darkblue
	deletes_extract = FALSE

/datum/chemical_reaction/slime/slimefreeze/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message(span_danger("The slime extract starts to feel extremely cold!"))
	addtimer(CALLBACK(src, PROC_REF(freeze), holder), 5 SECONDS)
	var/obj/item/slime_extract/M = holder.my_atom
	deltimer(M.qdel_timer)
	..()
	M.qdel_timer = addtimer(CALLBACK(src, PROC_REF(delete_extract), holder), 55, TIMER_STOPPABLE)

/datum/chemical_reaction/slime/slimefreeze/proc/freeze(datum/reagents/holder)
	if(holder?.my_atom)
		var/turf/open/T = get_turf(holder.my_atom)
		if(istype(T))
			var/datum/gas/gastype = /datum/gas/nitrogen
			T.atmos_spawn_air("[initial(gastype.id)]=50;[TURF_TEMPERATURE(2.7)]")

/datum/chemical_reaction/slime/slimefireproof
	required_reagents = list(/datum/reagent/water = 1)
	required_container = /obj/item/slime_extract/darkblue

/datum/chemical_reaction/slime/slimefireproof/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	new /obj/item/slimepotion/fireproof(get_turf(holder.my_atom))
	..()

//Orange
/datum/chemical_reaction/slime/slimecasp
	results = list(/datum/reagent/consumable/capsaicin = 10)
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/orange

/datum/chemical_reaction/slime/slimefire
	required_reagents = list(/datum/reagent/toxin/plasma = 15)
	required_container = /obj/item/slime_extract/orange
	deletes_extract = FALSE

/datum/chemical_reaction/slime/slimefire/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message(span_danger("The slime extract begins to vibrate adorably!"))
	addtimer(CALLBACK(src, PROC_REF(slime_burn), holder), 5 SECONDS)
	var/obj/item/slime_extract/M = holder.my_atom
	deltimer(M.qdel_timer)
	..()
	M.qdel_timer = addtimer(CALLBACK(src, PROC_REF(delete_extract), holder), 55, TIMER_STOPPABLE)

/datum/chemical_reaction/slime/slimefire/proc/slime_burn(datum/reagents/holder)
	if(holder?.my_atom)
		var/turf/open/T = get_turf(holder.my_atom)
		if(istype(T))
			T.atmos_spawn_air("[GAS_PLASMA]=50;[TURF_TEMPERATURE(1000)]")


/datum/chemical_reaction/slime/slimesmoke
	results = list(/datum/reagent/phosphorus = 10, /datum/reagent/potassium = 10, /datum/reagent/consumable/sugar = 10)
	required_reagents = list(/datum/reagent/water = 5)
	required_container = /obj/item/slime_extract/orange

//Yellow
/datum/chemical_reaction/slime/slimeoverload
	required_reagents = list(/datum/reagent/blood = 15)
	required_container = /obj/item/slime_extract/yellow
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME | REACTION_TAG_DANGEROUS

/datum/chemical_reaction/slime/slimeoverload/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	empulse(get_turf(holder.my_atom), 3, 5)
	..()

/datum/chemical_reaction/slime/slimecell
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/yellow

/datum/chemical_reaction/slime/slimecell/on_reaction(datum/reagents/holder, created_volume)
	new /obj/item/stock_parts/power_store/cell/emproof/slime(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime/slimeglow
	required_reagents = list(/datum/reagent/water = 1)
	required_container = /obj/item/slime_extract/yellow

/datum/chemical_reaction/slime/slimeglow/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message(span_danger("The slime begins to emit a soft light. Squeezing it will cause it to grow brightly."))
	new /obj/item/flashlight/slime(T)
	..()

//Purple
/datum/chemical_reaction/slime/slimepsteroid
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/purple

/datum/chemical_reaction/slime/slimepsteroid/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	new /obj/item/slimepotion/slime/steroid(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime/slimeregen
	results = list(/datum/reagent/medicine/regen_jelly = 5)
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/purple

//Dark Purple
/datum/chemical_reaction/slime/slimeplasma
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/darkpurple

/datum/chemical_reaction/slime/slimeplasma/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	new /obj/item/stack/sheet/mineral/plasma(get_turf(holder.my_atom), 3)
	..()

//Red
/datum/chemical_reaction/slime/slimemutator
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/red

/datum/chemical_reaction/slime/slimemutator/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	new /obj/item/slimepotion/slime/mutator(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime/slimebloodlust
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/red
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME | REACTION_TAG_DANGEROUS

/datum/chemical_reaction/slime/slimebloodlust/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	for(var/mob/living/basic/slime/slime in viewers(get_turf(holder.my_atom), null))
		if(slime.hunger_disabled) //Undoes docility, but doesn't make rabid.
			slime.visible_message(span_danger("[slime] forgets its training, becoming wild once again!"))
			slime.set_default_behaviour()
			slime.update_name()
			continue
		slime.set_enraged_behaviour()
		slime.visible_message(span_danger("The [slime] is driven into a frenzy!"))
	..()

/datum/chemical_reaction/slime/slimespeed
	required_reagents = list(/datum/reagent/water = 1)
	required_container = /obj/item/slime_extract/red

/datum/chemical_reaction/slime/slimespeed/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	new /obj/item/slimepotion/speed(get_turf(holder.my_atom))
	..()

//Pink
/datum/chemical_reaction/slime/docility
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/pink

/datum/chemical_reaction/slime/docility/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	new /obj/item/slimepotion/slime/docility(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime/gender
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/pink

/datum/chemical_reaction/slime/gender/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	new /obj/item/slimepotion/genderchange(get_turf(holder.my_atom))
	..()

//Black
/datum/chemical_reaction/slime/slimemutate2
	results = list(/datum/reagent/aslimetoxin = 1)
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/black

//Oil
/datum/chemical_reaction/slime/slimeexplosion
	required_reagents = list(/datum/reagent/toxin/plasma = 15)
	required_container = /obj/item/slime_extract/oil
	deletes_extract = FALSE
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME | REACTION_TAG_DANGEROUS

/datum/chemical_reaction/slime/slimeexplosion/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	var/lastkey = holder.my_atom.fingerprintslast
	var/touch_msg = "N/A"
	if(lastkey)
		var/mob/toucher = get_mob_by_key(lastkey)
		touch_msg = "[ADMIN_LOOKUPFLW(toucher)]."
		toucher.log_message("was the last to touch the slime which has exploded at [AREACOORD(T)].", LOG_GAME, log_globally = FALSE)
	message_admins("Slime Explosion reaction started at [ADMIN_VERBOSEJMP(T)]. Last Fingerprint: [touch_msg]")
	log_game("Slime Explosion reaction started at [AREACOORD(T)]. Last Fingerprint: [lastkey ? lastkey : "N/A"].")
	T.visible_message(span_danger("The slime extract begins to vibrate violently !"))
	addtimer(CALLBACK(src, PROC_REF(boom), holder), 5 SECONDS)
	var/obj/item/slime_extract/M = holder.my_atom
	deltimer(M.qdel_timer)
	..()
	M.qdel_timer = addtimer(CALLBACK(src, PROC_REF(delete_extract), holder), 55, TIMER_STOPPABLE)

/datum/chemical_reaction/slime/slimeexplosion/proc/boom(datum/reagents/holder)
	if(holder?.my_atom)
		explosion(holder.my_atom, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 4, explosion_cause = src)


/datum/chemical_reaction/slime/slimeoil
	results = list(/datum/reagent/consumable/nutriment/fat/oil = 10)
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/oil

//Light Pink
/datum/chemical_reaction/slime/slimepotion2
	required_container = /obj/item/slime_extract/lightpink
	required_reagents = list(/datum/reagent/toxin/plasma = 1)

/datum/chemical_reaction/slime/slimepotion2/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	new /obj/item/slimepotion/slime/sentience(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime/renaming
	required_container = /obj/item/slime_extract/lightpink
	required_reagents = list(/datum/reagent/water = 1)

/datum/chemical_reaction/slime/renaming/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	new /obj/item/slimepotion/slime/renaming(holder.my_atom.drop_location())
	..()


//Adamantine
/datum/chemical_reaction/slime/adamantine
	required_reagents = list(/datum/reagent/toxin/plasma = 15)
	required_container = /obj/item/slime_extract/adamantine

/datum/chemical_reaction/slime/adamantine/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	new /obj/item/stack/sheet/mineral/adamantine(get_turf(holder.my_atom))
	..()

//Bluespace
/datum/chemical_reaction/slime/slimefloor2
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/bluespace

/datum/chemical_reaction/slime/slimefloor2/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	new /obj/item/stack/tile/bluespace(get_turf(holder.my_atom), 25)
	..()


/datum/chemical_reaction/slime/slimecrystal
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/bluespace

/datum/chemical_reaction/slime/slimecrystal/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/obj/item/stack/ore/bluespace_crystal/BC = new (get_turf(holder.my_atom))
	BC.visible_message(span_notice("The [BC.name] appears out of thin air!"))
	..()

/datum/chemical_reaction/slime/slimeradio
	required_reagents = list(/datum/reagent/water = 1)
	required_container = /obj/item/slime_extract/bluespace

/datum/chemical_reaction/slime/slimeradio/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	new /obj/item/slimepotion/slime/slimeradio(get_turf(holder.my_atom))
	..()

//Cerulean
/datum/chemical_reaction/slime/slimepsteroid2
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/cerulean

/datum/chemical_reaction/slime/slimepsteroid2/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	new /obj/item/slimepotion/enhancer(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime/slime_territory
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/cerulean

/datum/chemical_reaction/slime/slime_territory/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	new /obj/item/blueprints/slime(get_turf(holder.my_atom))
	..()

//Sepia
/datum/chemical_reaction/slime/slimestop
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/sepia

/datum/chemical_reaction/slime/slimestop/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	addtimer(CALLBACK(src, PROC_REF(slime_stop), holder), 5 SECONDS)

/datum/chemical_reaction/slime/slimestop/proc/slime_stop(datum/reagents/holder)
	var/obj/item/slime_extract/sepia/extract = holder.my_atom
	var/turf/T = get_turf(holder.my_atom)
	new /obj/effect/timestop(T, null, null, null)
	if(istype(extract))
		if(extract.extract_uses > 0)
			var/mob/lastheld = get_mob_by_key(holder.my_atom.fingerprintslast)
			if(lastheld && !lastheld.equip_to_slot_if_possible(extract, ITEM_SLOT_HANDS, disable_warning = TRUE))
				extract.forceMove(get_turf(lastheld))
	use_slime_core(holder)

/datum/chemical_reaction/slime/slimecamera
	required_reagents = list(/datum/reagent/water = 1)
	required_container = /obj/item/slime_extract/sepia

/datum/chemical_reaction/slime/slimecamera/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	new /obj/item/camera(get_turf(holder.my_atom))
	new /obj/item/camera_film(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime/slimefloor
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/sepia

/datum/chemical_reaction/slime/slimefloor/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	new /obj/item/stack/tile/sepia(get_turf(holder.my_atom), 25)
	..()

//Pyrite
/datum/chemical_reaction/slime/slimepaint
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/pyrite

/datum/chemical_reaction/slime/slimepaint/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/chosen = pick(subtypesof(/obj/item/paint))
	new chosen(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime/slimecrayon
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/pyrite

/datum/chemical_reaction/slime/slimecrayon/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/chosen = pick(difflist(subtypesof(/obj/item/toy/crayon),typesof(/obj/item/toy/crayon/spraycan)))
	new chosen(get_turf(holder.my_atom))
	..()

//Rainbow :o)
/datum/chemical_reaction/slime/slime_rng
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/rainbow

/datum/chemical_reaction/slime/slime_rng/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	if(created_volume >= 5)
		var/obj/item/grenade/clusterbuster/slime/S = new (get_turf(holder.my_atom))
		S.visible_message(span_danger("Infused with plasma, the core begins to expand uncontrollably!"))
		S.icon_state = "[S.base_state]_active"
		S.active = TRUE
		addtimer(CALLBACK(S, TYPE_PROC_REF(/obj/item/grenade, detonate)), rand(1.5 SECONDS, 6 SECONDS))
	else
		var/mob/living/basic/slime/random/random_slime = new (get_turf(holder.my_atom))
		random_slime.visible_message(span_danger("Infused with plasma, the core begins to quiver and grow, and a new baby slime emerges from it!"))
	..()

/datum/chemical_reaction/slime/slimebomb
	required_reagents = list(/datum/reagent/toxin/slimejelly = 1)
	required_container = /obj/item/slime_extract/rainbow

/datum/chemical_reaction/slime/slimebomb/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	var/obj/item/grenade/clusterbuster/slime/volatile/S = new (T)
	S.visible_message(span_danger("Infused with slime jelly, the core begins to expand uncontrollably!"))
	S.icon_state = "[S.base_state]_active"
	S.active = TRUE
	addtimer(CALLBACK(S, TYPE_PROC_REF(/obj/item/grenade, detonate)), rand(1.5 SECONDS, 6 SECONDS))
	var/lastkey = holder.my_atom.fingerprintslast
	var/touch_msg = "N/A"
	if(lastkey)
		var/mob/toucher = get_mob_by_key(lastkey)
		touch_msg = "[ADMIN_LOOKUPFLW(toucher)]."
		toucher.log_message("was last to touch a Brorble Brorble that has been primed at [AREACOORD(T)].", LOG_GAME, log_globally = FALSE)
	message_admins("Brorble Brorble primed at [ADMIN_VERBOSEJMP(T)]. Last Fingerprint: [touch_msg]")
	log_game("Brorble Brorble primed at [AREACOORD(T)]. Last Fingerprint: [lastkey ? lastkey : "N/A"].")
	..()

/datum/chemical_reaction/slime/slime_transfer
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/rainbow

/datum/chemical_reaction/slime/slime_transfer/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	new /obj/item/slimepotion/transference(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime/flight_potion
	required_reagents = list(/datum/reagent/water/holywater = 5, /datum/reagent/uranium = 5)
	required_container = /obj/item/slime_extract/rainbow

/datum/chemical_reaction/slime/flight_potion/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	new /obj/item/reagent_containers/cup/bottle/potion/flight(get_turf(holder.my_atom))
	..()
