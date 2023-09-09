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
