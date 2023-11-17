
/////////////
//OCEAN BAR//
/////////////

/obj/item/stack/tile/fake_seafloor
	name = "fake ocean floor tiles"
	singular_name = "fake ocean floor tile"
	icon = 'monkestation/icons/obj/tiles.dmi'
	icon_state = "tile_seafloor"
	inhand_icon_state = "tile-space"
	turf_type = /turf/open/floor/fake_seafloor
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/tile/fake_seafloor

/turf/open/floor/fake_seafloor
	name = "synthetic ocean floor"
	icon = 'monkestation/icons/turf/seafloor.dmi'
	icon_state = "seafloor"
	base_icon_state = "seafloor"

/////////////////
//BEACHSIDE BAR//
/////////////////

/obj/item/paper/fluff/beachside_bar
	name = "lighting system ad"
	default_raw_text = {"With the new Nanotrasen(tm) Magilight System(tm) you too can have perfect lighting at all times of orbit!"}

/obj/item/stack/tile/fakesand
	name = "fake sand tiles"
	singular_name = "fake sand tile"
	icon = 'monkestation/icons/obj/tiles.dmi'
	icon_state = "tile_sand"
	inhand_icon_state = "tile-space"
	turf_type = /turf/open/floor/fakesand
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/tile/fakesand

/turf/open/floor/fakesand
	name = "synthetic beach"
	desc = "Plastic."
	icon = 'icons/misc/beach.dmi'
	icon_state = "sand"
	base_icon_state = "sand"

	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	floor_tile = /obj/item/stack/tile/fake_seafloor

/turf/open/floor/fake_seafloor/medium
	icon_state = "seafloor_med"
	base_icon_state = "seafloor_med"

/turf/open/floor/fake_seafloor/heavy
	icon_state = "seafloor_heavy"
	base_icon_state = "seafloor_heavy"

/turf/open/floor/fake_seafloor/ironsand
	icon = 'icons/turf/floors.dmi'
	icon_state = "ironsand1"
	base_icon_state = "ironsand"

/turf/open/floor/fake_seafloor/spawning/Initialize(mapload)
	. = ..()
	if(prob(10))
		var/to_spawn = pick(list(/obj/structure/flora/ocean/glowweed,
					/obj/structure/flora/ocean/longseaweed,
					/obj/structure/flora/ocean/seaweed,
					/obj/structure/flora/ocean/coral,
					/obj/structure/flora/rock/style_random))
		new to_spawn(src)

/turf/closed/mineral/random/fake_ocean
	baseturfs = /turf/open/floor/fake_seafloor
	turf_type = /turf/open/floor/fake_seafloor
	color = "#58606b"

////////////
//CULT BAR//
////////////

/obj/effect/rune/beer
	name = "rune of booze"
	desc = "An odd collection of symbols drawn in what seems to be ethanol, it seems it has spots for 25 people. Curious."
	cultist_name = "the ancient nar'sie alcoholism rune"
	cultist_desc = "allows anyone to prepare greater amounts of ethanol magic and condense it into a puddle \
					Due to you being a cultist you give twice the summoning power normally required to invoke this"
	invocation = "Let the world tremble as beer consumes it!"
	req_cultists = 25 // you need a full 5x5 tile space of people for this
	can_be_scribed = FALSE

	// icon handling
	icon = 'icons/effects/96x96.dmi'
	color = RUNE_COLOR_BURNTORANGE
	icon_state = "rune_large"
	pixel_x = -32 //So the big ol' 96x96 sprite shows up right
	pixel_y = -32

	/// non-cultists can also use this rune :)
	cult_override = TRUE
	/// Did we already summon a beer storm?
	var/used = FALSE
	/// Reagent that is produced once the rune is invoked.
	var/flood_reagent = /datum/reagent/consumable/ethanol/beer
	/// Round event control we might as well keep track of instead of locating every time
	var/datum/round_event_control/scrubber_overflow/every_vent/overflow_control

/obj/effect/rune/beer/Destroy(force)
	if(!force)
		return QDEL_HINT_LETMELIVE
	if(src == GLOB.narsie_breaching_rune)
		GLOB.narsie_breaching_rune = TRUE //we still want to summon even if destroyed
	return ..()

/obj/effect/rune/beer/Initialize(mapload)
	. = ..()
	overflow_control = locate(/datum/round_event_control/scrubber_overflow/every_vent) in SSevents.control

/obj/effect/rune/beer/conceal() //you cant hide from destiny (stops cultists from fucking with it)
	return

/obj/effect/rune/beer/invoke(list/invokers)
	if(used)
		return
	var/mob/living/user = invokers[1]
	if(locate(/obj/narsie) in SSpoints_of_interest.narsies) // you cant summon booze if the god is already on this plane of existance
		for(var/invoker in invokers)
			to_chat(invoker, span_warning("Nar'Sie is already on this plane, you lost your opportunity to summon beer with her!"))
		log_game("Beer rune activated by [user] at [COORD(src)] failed - Nar'sie is summoned.")
	used = TRUE
	if(GLOB.clock_ark) // Rat'var is against alcoholism
		if(!GLOB.narsie_breaching_rune)
			GLOB.narsie_breaching_rune = src
		for(var/invoker in invokers)
			to_chat(invoker, span_bigbrass("A horrible light is preventing Nar'sie from summoning beer to this realm! \
											It looks like you will have to destroy whatever is causing this before Nar'sie may summon beer."))
		return
	..()
	sound_to_playing_players('sound/effects/dimensional_rend.ogg')
	sleep(4 SECONDS)
	if(src)
		color = RUNE_COLOR_RED
	RegisterSignal(overflow_control, COMSIG_CREATED_ROUND_EVENT, PROC_REF(on_created_round_event))
	overflow_control.runEvent()

/obj/effect/rune/beer/proc/on_created_round_event(datum/round_event_control/source_event_control, datum/round_event/scrubber_overflow/every_vent/created_event)
	SIGNAL_HANDLER
	UnregisterSignal(overflow_control, COMSIG_CREATED_ROUND_EVENT)
	created_event.forced_reagent_type = flood_reagent
