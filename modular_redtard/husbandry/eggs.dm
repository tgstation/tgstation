/// Hens and eggs (Ratwood rogue/farm/chicken.dm Life(), friendly/farm_animals.dm chicken and chick, modular/Neu_Farming eggs.dm).
/// A nesting hen (the rogue chicken) lays out of her production - what she has eaten - once it is over 29, and only in a nest:
/// standing in one she lays (production -30); otherwise she walks to a nest in sight, or makes one of fibers or a stick under her
/// and goes looking for them. A fed hen (the friendly chicken) lays from a store of eggs every feeding adds to (TG's egg_layer).
/// While fewer than 50 hens live, an egg may be fertile (half a nesting hen's, a quarter of a fed one's): left on the ground it
/// hatches into a chick in about two minutes (TG's fertile_egg), rotting spoils it, and the chick grows into a hen.

/// Ratwood chicken Life(): lay in the nest she stands in, or find one, or make one.
/datum/component/rogue_livestock/proc/try_nest(mob/living/basic/rockhill/hen)
	if(production < ROGUE_EGG_PRODUCTION || !isturf(hen.loc) || hen.rogue_is_angry())
		return
	var/turf/here = hen.loc
	if(locate(/obj/structure/fluff/nest) in here)
		lay_egg(hen)
		return
	if(hen.ai_controller?.blackboard_key_exists(BB_ROGUE_NEST_TARGET))
		return
	var/list/nests = list()
	for(var/obj/structure/fluff/nest/nest in oview(ROGUE_NEST_SIGHT, hen))
		nests += nest
	if(length(nests))
		hen.rogue_seek(BB_ROGUE_NEST_TARGET, pick(nests), ROGUE_NEST_SEEK_TIME)
		return
	var/obj/item/stuff = locate(/obj/item/natural/fibers) in here
	if(!stuff)
		stuff = locate(/obj/item/grown/log/tree/stick) in here
	if(stuff)
		qdel(stuff)
		new /obj/structure/fluff/nest(here)
		hen.visible_message(span_notice("[hen] builds a nest."))
		return
	var/list/chaff = list()
	for(var/obj/item/natural/fibers/fibers in oview(ROGUE_NEST_SIGHT, hen))
		chaff += fibers
	if(!length(chaff))
		for(var/obj/item/grown/log/tree/stick/stick in oview(ROGUE_NEST_SIGHT, hen))
			chaff += stick
	if(length(chaff))
		hen.rogue_seek(BB_ROGUE_NEST_TARGET, pick(chaff), ROGUE_NEST_SEEK_TIME)

/datum/component/rogue_livestock/proc/lay_egg(mob/living/basic/rockhill/hen)
	hen.visible_message(span_alertalien("[hen] [pick(EGG_LAYING_MESSAGES)]"))
	production = max(production - ROGUE_EGG_PRODUCTION, 0)
	var/obj/item/egg = new hen.rogue_egg_type(hen.loc)
	egg.pixel_x = rand(-6, 6)
	egg.pixel_y = rand(-6, 6)
	if(hen.rogue_eggs_fertile && prob(ROGUE_EGG_FERTILE_CHANCE))
		rogue_fertilize_egg(egg)

/// TG's egg_layer laid an egg of a fed hen (Ratwood friendly chicken Life()).
/datum/component/rogue_livestock/proc/on_fed_egg_laid(obj/item/egg)
	var/mob/living/basic/rockhill/hen = parent
	if(hen.rogue_eggs_fertile && prob(ROGUE_FED_EGG_FERTILE_CHANCE))
		rogue_fertilize_egg(egg)

/// Living hens on the map (Ratwood chicken_count).
/proc/rogue_hen_count()
	. = 0
	for(var/mob/living/hen as anything in GLOB.rogue_hens)
		if(hen.stat != DEAD)
			.++

/// A fertile egg hatches into a chick while it lies on the ground (Ratwood egg process(): rand(1, 2) every 2 seconds to 100),
/// unless there are hens enough already.
/proc/rogue_fertilize_egg(obj/item/egg)
	if(rogue_hen_count() >= ROGUE_MAX_CHICKENS)
		return
	egg.AddComponent(/datum/component/fertile_egg, \
		embryo_type = /mob/living/simple_animal/chick, \
		minimum_growth_rate = 1, \
		maximum_growth_rate = 2, \
		total_growth_required = ROGUE_EGG_HATCH_GROWTH, \
		current_growth = 0, \
		location_allowlist = typecacheof(/turf), \
		spoilable = FALSE)

/// Ratwood egg become_rotten(): a rotten egg is not fertile any more.
/obj/item/reagent_containers/food/snacks/egg/become_rotten()
	. = ..()
	if(. && !QDELETED(src))
		qdel(GetComponent(/datum/component/fertile_egg))

/obj/item/reagent_containers/food/snacks/egg/Initialize(mapload)
	. = ..()
	if(!rogue_husbandry_enabled())
		return
	var/static/list/loc_connections = list(COMSIG_ATOM_ENTERED = PROC_REF(rogue_on_stepped))
	AddElement(/datum/element/connect_loc, loc_connections)

/// Ratwood egg Crossed(): someone who walks onto an egg lying on the ground crushes it.
/obj/item/reagent_containers/food/snacks/egg/proc/rogue_on_stepped(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	if(!isturf(loc) || !ishuman(arrived) || (arrived.movement_type & MOVETYPES_NOT_TOUCHING_GROUND))
		return
	rogue_crush(arrived)

/// The egg is crushed into a smudge on the floor.
/obj/item/reagent_containers/food/snacks/egg/proc/rogue_crush(mob/living/stepper)
	var/obj/effect/decal/cleanable/food/egg_smudge/smudge = new(loc)
	smudge.pixel_x = rand(-8, 8)
	smudge.pixel_y = rand(-8, 8)
	visible_message(span_warning("[stepper] crushes [src] underfoot."))
	qdel(src)

/// Ratwood chick: skittish, grows into a hen (chick Life(): rand(1, 2) a Life to 100).
/mob/living/simple_animal/chick
	ai_controller = /datum/ai_controller/basic_controller/simple/simple_skittish
	rogue_adult_type = /mob/living/simple_animal/hostile/retaliate/rogue/chicken
	rogue_growth_rate = ROGUE_CHICK_GROWTH

/// The rogue chicken nests (Ratwood rogue chicken Life()); the friendly one lays as it is fed.
/mob/living/simple_animal/hostile/retaliate/rogue/chicken
	rogue_lays_in_nest = TRUE
