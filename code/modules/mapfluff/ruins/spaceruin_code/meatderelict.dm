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
	default_raw_text = "<i>The research was going smooth... but the experiment did not go as planned. He convulsed and screamed as he slowly mutated into... that thing. It started to spread everywhere, outside the lab too. There is no way we can cover up that we are not a teleport research outpost, so I locked down the lab, but they already know. They sent a squad to rescue us, but...</i>"

/obj/item/paper/crumpled/fluff/meatderelict/shieldgens
	name = "shield gate marketing sketch"
	default_raw_text = "The <b>QR-109 Shield Gate</b> is a robust hardlight machine capable of producing a strong shield to bar entry. With control panel integration, it can be enabled or disabled from anywhere, such as ship's Bridge, <b>Engineering Bay</b>, or wherever else! <i>The rest is faded...</i>"

/obj/item/paper/crumpled/fluff/meatderelict
	name = "engineer note"
	default_raw_text = "I've overclocked the power generators to add that needed juice to the experiment, though they're a bit unstable."

/obj/item/paper/crumpled/fluff/meatderelict/fridge
	name = "engineer complaint"
	default_raw_text = "Whoever keeps stealing my fucking ice cream from my fridge, I swear I will actually fuck you up. It is not cheap to get this delicious ice cream here, nor is it for you. <b>And don't touch my snacks in the drawer!</b>"

/obj/machinery/computer/terminal/meatderelict
	upperinfo = "COPYRIGHT 2500 NANOSOFT-TM - DO NOT REDISTRIBUTE - Now with audio!" //not that old
	content = list(
		"Experimental Test Satellite 37B<br/>Nanotrasen™️ approved deep space experimentation lab<br/><br/>Entry 1:<br/><br/>Subject - \[Species 501-C-12\]<br/>Date - \[REDACTED\]<br/>We have acquired a biological sample of unknown origins \[Species 501-C-12\] from an NT outpost on the far reaches. Initial experiments have determined the sample to be a creature never previously recorded. It weighs approximately 7 grams and seems to be docile. Initial examinations determine that it is an extremely fast replicating organism which can alter its physiology to take multiple differing shapes. \[Recording Terminated\]<br/>- Dr. Phil Cornelius",
		"Entry 2:<br/><br/>Subject - \[Species 501-C-12\]<br/>Date - \[REDACTED\]<br/>The creature responds to electrical stimuli. It has failed to respond to Light, Heat, Cold, Oxygen, Plasma, CO2, Nitrogen. It, within moments, seemed to have generated muscle tissue within its otherwise shapeless form and moved away from the source of electricity. Feeding the creature has been a simple matter, it consumed just about any form of protein. It appears to rapidly digest and convert forms of protein into more of itself. Any undigestible products are simply left alone. Will continue to monitor creature and provide reports to Nanotrasen Central Command. \[Recording Terminated\]<br/>- Dr. Phil Cornelius",
		"Entry 3:<br/><br/>Subject - \[Species 501-C-12\]<br/>Date - \[REDACTED\]<br/>Any attempts at contacting Nanotrasen has failed. I've never seen anything like it. I... I don't think I'm going to survive much longer, I can hear it pushing on my room door. If anyone reads this, let my family know that I- \[Loud crash\]<br/>GET BACK \[Gunshots\]<br/>AHHHHHHHHHHHH \[Recording Terminated\]<br/>- Dr. Phil Cornelius"
	)

/obj/machinery/door/puzzle/meatderelict
	name = "lockdown door"
	desc = "A beaten door, still sturdy. Impervious to conventional methods of destruction, must be a way to open it nearby."
	icon = 'icons/obj/doors/puzzledoor/danger.dmi'
	puzzle_id = "md_prevault"

/mob/living/basic/meteor_heart/opens_puzzle_door
	///the puzzle id we send on death
	var/id
	///queue size, must match
	var/queue_size = 2

/mob/living/basic/meteor_heart/opens_puzzle_door/Initialize(mapload)
	. = ..()
	new /obj/effect/puzzle_death_signal_holder(loc, src, id, queue_size)

/obj/effect/puzzle_death_signal_holder // ok apparently registering signals on qdeling stuff is not very functional
	///delay
	var/delay = 2.5 SECONDS
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/puzzle_death_signal_holder/Initialize(mapload, mob/listened, id, queue_size = 2)
	. = ..()
	if(isnull(id))
		return INITIALIZE_HINT_QDEL
	RegisterSignal(listened, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	SSqueuelinks.add_to_queue(src, id, queue_size)

/obj/effect/puzzle_death_signal_holder/proc/on_death(datum/source)
	SIGNAL_HANDLER
	addtimer(CALLBACK(src, PROC_REF(send_sig)), delay)

/obj/effect/puzzle_death_signal_holder/proc/send_sig()
	SEND_SIGNAL(src, COMSIG_PUZZLE_COMPLETED)
	qdel(src)

/obj/machinery/puzzle/button/meatderelict
	name = "lockdown panel"
	desc = "A panel that controls the lockdown of this outpost."
	id = "md_prevault"

/obj/machinery/puzzle/button/meatderelict/on_puzzle_complete()
	. = ..()
	playsound(src, 'sound/effects/alert.ogg', 100, TRUE)
	visible_message(span_warning("[src] lets out an alarm as the lockdown is lifted!"))

/obj/structure/puzzle_blockade/meat
	name = "mass of meat and teeth"
	desc = "A horrible mass of meat and teeth. Can it see you? You hope not. Virtually indestructible, must be a way around."
	icon = 'icons/obj/structures.dmi'
	icon_state = "meatblockade"
	opacity = TRUE

/obj/structure/puzzle_blockade/meat/try_signal(datum/source)
	Shake(duration = 0.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(open_up)), 0.5 SECONDS)

/obj/structure/puzzle_blockade/meat/proc/open_up()
	new /obj/effect/gibspawner/generic(drop_location())
	qdel(src)

/obj/lightning_thrower
	name = "overcharged SMES"
	desc = "An overclocked SMES, bursting with power."
	anchored = TRUE
	density = TRUE
	icon = 'icons/obj/machines/engine/other.dmi'
	icon_state = "smes"
	/// do we currently want to shock diagonal tiles? if not, we shock cardinals
	var/throw_diagonals = FALSE
	/// flags we apply to the shock
	var/shock_flags = SHOCK_KNOCKDOWN | SHOCK_NOGLOVES
	/// damage of the shock
	var/shock_damage = 20
	/// list of turfs that are currently shocked so we can unregister the signal
	var/list/signal_turfs = list()
	/// how long do we shock
	var/shock_duration = 0.5 SECONDS

/obj/lightning_thrower/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSprocessing, src)

/obj/lightning_thrower/Destroy()
	. = ..()
	signal_turfs = null
	STOP_PROCESSING(SSprocessing, src)

/obj/lightning_thrower/process(seconds_per_tick)
	var/list/dirs = throw_diagonals ? GLOB.diagonals : GLOB.cardinals
	throw_diagonals = !throw_diagonals
	playsound(src, 'sound/effects/magic/lightningbolt.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, ignore_walls = FALSE)
	for(var/direction in dirs)
		var/victim_turf = get_step(src, direction)
		if(isclosedturf(victim_turf))
			continue
		Beam(victim_turf, icon_state="lightning[rand(1,12)]", time = shock_duration)
		RegisterSignal(victim_turf, COMSIG_ATOM_ENTERED, PROC_REF(shock_victim)) //we cant move anyway
		signal_turfs += victim_turf
		for(var/mob/living/victim in victim_turf)
			shock_victim(null, victim)
	addtimer(CALLBACK(src, PROC_REF(clear_signals)), shock_duration)

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
