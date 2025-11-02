
/obj/structure/ore_vent/boss
	name = "menacing ore vent"
	desc = "An ore vent, brimming with underground ore. This one has an evil aura about it. Better be careful."
	unique_vent = TRUE
	spawn_drone_on_tap = FALSE
	boulder_size = BOULDER_SIZE_LARGE
	mineral_breakdown = list( // All the riches of the world, eeny meeny boulder room.
		/datum/material/iron = 1,
		/datum/material/glass = 1,
		/datum/material/plasma = 1,
		/datum/material/titanium = 1,
		/datum/material/silver = 1,
		/datum/material/gold = 1,
		/datum/material/diamond = 1,
		/datum/material/uranium = 1,
		/datum/material/bluespace = 1,
		/datum/material/plastic = 1,
	)
	defending_mobs = list(
		/mob/living/simple_animal/hostile/megafauna/bubblegum,
		/mob/living/simple_animal/hostile/megafauna/dragon,
		/mob/living/simple_animal/hostile/megafauna/colossus,
	)
	excavation_warning = "Something big is nearby. Are you ABSOLUTELY ready to excavate this ore vent? A NODE drone will be deployed after threat is neutralized."
	///What boss do we want to spawn?
	var/summoned_boss = null

/obj/structure/ore_vent/boss/Initialize(mapload)
	. = ..()
	summoned_boss = pick(defending_mobs)

/obj/structure/ore_vent/boss/examine(mob/user)
	. = ..()
	var/boss_string = ""
	switch(summoned_boss)
		if(/mob/living/simple_animal/hostile/megafauna/bubblegum)
			boss_string = "A giant fleshbound beast"
		if(/mob/living/simple_animal/hostile/megafauna/dragon)
			boss_string = "Sharp teeth and scales"
		if(/mob/living/simple_animal/hostile/megafauna/colossus)
			boss_string = "A giant, armored behemoth"
		if(/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner)
			boss_string = "A bloody drillmark"
		if(/mob/living/simple_animal/hostile/megafauna/wendigo/noportal)
			boss_string = "A chilling skull"
	. += span_notice("[boss_string] is etched onto the side of the vent.")

/obj/structure/ore_vent/boss/start_wave_defense()
	if(!COOLDOWN_FINISHED(src, wave_cooldown))
		return
	// Completely override the normal wave defense, and just spawn the boss.
	var/mob/living/simple_animal/hostile/megafauna/boss = new summoned_boss(loc)
	RegisterSignal(boss, COMSIG_VENT_WAVE_CONCLUDED, PROC_REF(handle_wave_conclusion))
	SSblackbox.record_feedback("tally", "ore_vent_mobs_spawned", 1, summoned_boss)
	boss.say(boss.summon_line, language = /datum/language/common, forced = "summon line") //Pull their specific summon line to say. Default is meme text so make sure that they have theirs set already.

/obj/structure/ore_vent/boss/handle_wave_conclusion()
	node = new /mob/living/basic/node_drone(loc) //We're spawning the vent after the boss dies, so the player can just focus on the boss.
	SSblackbox.record_feedback("tally", "ore_vent_mobs_killed", 1, summoned_boss)
	COOLDOWN_RESET(src, wave_cooldown)
	return ..()

/obj/structure/ore_vent/boss/icebox
	icon_state = "ore_vent_ice"
	icon_state_tapped = "ore_vent_ice_active"
	defending_mobs = list(
		/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner,
		/mob/living/simple_animal/hostile/megafauna/wendigo/noportal,
		/mob/living/simple_animal/hostile/megafauna/colossus,
	)
