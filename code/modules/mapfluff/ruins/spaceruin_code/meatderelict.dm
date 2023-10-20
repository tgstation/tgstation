/obj/item/keycard/meatderelict/director
	name = "directors keycard"
	desc = "A fancy keycard. Likely unlocks the directors office. The name tag is all smudged."
	color = "#990000"
	puzzle_id = "md_director"

/obj/item/keycard/meatderelict/engpost
	name = "post keycard"
	desc = "A fancy keycard. Has the engineering insignia on it."
	color = "#f0da12"
	puzzle_id = "md_engpost"

/obj/item/keycard/meatderelict/armory
	name = "armory keycard"
	desc = "A red keycard. Has a really cool image of a gun on it. Fancy."
	color = "#FF7276"
	puzzle_id = "md_armory"

/obj/item/paper/crumpled/bloody/fluff/meatderelict/directoroffice
	name = "directors note"
	default_raw_text = "<i>The research was going smooth... but the experiment did not go as planned. He convulsed and screamed as he slowly mutated into.. that thing. It started to spread everywhere, outside the lab too. There is no way we can cover up that we are not a teleport research outpost, so I locked down the lab, but they already know. They sent a squad to rescue us, but...</i>"

/obj/item/paper/crumpled/fluff/meatderelict/shieldgens
	name = "shield gate marketing sketch"
	default_raw_text = "The <b>QR-109 Shield Gate</b> is a robust hardlight machine capable of producing a strong shield to bar entry. With integration, it can be controlled from anywhere, like your ships bridge, <b>Engineering</b>, or anywhere else, from a control panel! <i>The rest is faded..</i>"

/obj/item/paper/crumpled/fluff/meatderelict
	name = "engineer note"
	default_raw_text = "Ive overclocked the power generators to add that needed juice to the experiment, though theyre a bit unstable."

/obj/item/paper/crumpled/fluff/meatderelict/fridge
	name = "engineer complaint"
	default_raw_text = "Whoever keeps stealing my fucking icecream from my fridge, I swear I will actually fuck you up. It is not cheap to get this delicious icecream here, nor is it for you. <b>And dont touch my snacks in the drawer!</b>"

/obj/machinery/computer/terminal/meatderelict
	content = list("todo \
	todo.")

/obj/machinery/door/puzzle/meatderelict
	name = "lockdown door"
	desc = "A beaten door, still sturdy. Impervious to conventional methods of destruction, must be a way to open it nearby."
	base_icon_state = "danger"
	icon_state = "danger_closed"
	puzzle_id = "md_prevault"

/mob/living/basic/meteor_heart/opens_puzzle_door
	var/id

/mob/living/basic/meteor_heart/opens_puzzle_door/death(gibbed)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(send_signal)), 2.5 SECONDS)

/mob/living/basic/meteor_heart/opens_puzzle_door/proc/send_signal()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_PUZZLE_COMPLETED, id)

/obj/machinery/puzzle_button/meatderelict
	name = "lockdown panel"
	desc = "A panel that controls the lockdown of this outpost."
	id = "md_prevault"

/obj/machinery/puzzle_button/meatderelict/open_doors()
	..()
	playsound(src, 'sound/effects/alert.ogg', 100, TRUE)
	visible_message(span_warning("[src] lets out an alarm as the lockdown is lifted!"))

/obj/structure/puzzle_blockade/meat
	name = "mass of meat and teeth"
	desc = "A horrible mass of meat and teeth. Can it see you? You hope not. Virtually indestructible, must be a way around."
	icon = 'icons/obj/structures.dmi'
	icon_state = "meatblockade"
	opacity = TRUE

/obj/structure/puzzle_blockade/meat/try_signal(datum/source, try_id)
	SIGNAL_HANDLER
	if(try_id != id)
		return
	Shake(duration = 0.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(open_up)), 0.5 SECONDS)

/obj/structure/puzzle_blockade/meat/proc/open_up()
	new /obj/effect/gibspawner/generic(drop_location())
	qdel(src)

/obj/lightning_thrower
	name = "overcharged SMES"
	desc = "An overclocked SMES, bursting with power. <b>Entering something being shocked is as bad idea.</b>"
	anchored = TRUE
	density = TRUE
	icon = 'icons/obj/machines/engine/other.dmi'
	icon_state = "smes"
	//not for mappers go away
	var/static/list/throw_directions_cardinal = list(NORTH,WEST,EAST,SOUTH)
	var/static/list/throw_directions_diagonal = list(NORTHWEST,NORTHEAST,SOUTHWEST,SOUTHEAST)
	//use these
	var/throw_diagonals = FALSE
	var/shock_flags = SHOCK_KNOCKDOWN | SHOCK_NOGLOVES
	var/shock_damage = 20
	var/list/signal_turfs = list()

/obj/lightning_thrower/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSprocessing, src) 

/obj/lightning_thrower/Destroy()
	. = ..()
	signal_turfs = null

/obj/lightning_thrower/process(seconds_per_tick)
	var/list/dirs = throw_diagonals ? throw_directions_diagonal : throw_directions_cardinal
	throw_diagonals = !throw_diagonals
	playsound(src, 'sound/magic/lightningbolt.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, ignore_walls = FALSE)
	for(var/direction in dirs)
		var/victim_turf = get_step(src, direction)
		if(isclosedturf(victim_turf))
			continue
		Beam(victim_turf, icon_state="lightning[rand(1,12)]", time = 0.5 SECONDS)
		RegisterSignal(victim_turf, COMSIG_ATOM_ENTERED, PROC_REF(shock_victim)) //we cant move anyway
		signal_turfs += victim_turf
		for(var/mob/living/victim in victim_turf)
			shock_victim(null, victim)
	addtimer(CALLBACK(src, PROC_REF(clear_signals)), 0.5 SECONDS)

/obj/lightning_thrower/proc/clear_signals(datum/source)
	SIGNAL_HANDLER
	for(var/turf in signal_turfs)
		UnregisterSignal(turf, COMSIG_ATOM_ENTERED)
		signal_turfs -= turf

/obj/lightning_thrower/proc/shock_victim(datum/source, mob/living/victim)
	SIGNAL_HANDLER
	if(!istype(victim))
		return
	victim.electrocute_act(shock_damage, src, flags = shock_flags)
