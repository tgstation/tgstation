/mob/living/basic/migo
	name = "mi-go"
	desc = "A pinkish, fungoid crustacean-like creature with clawed appendages and a head covered with waving antennae."
	icon_state = "mi-go"
	icon_living = "mi-go"
	icon_dead = "mi-go-dead"
	health = 80
	maxHealth = 80
	obj_damage = 50
	melee_damage_lower = 25
	melee_damage_upper = 50
	speed = 1
	attack_verb_continuous = "lacerates"
	attack_verb_simple = "lacerate"
	melee_attack_cooldown = 1 SECONDS
	gold_core_spawnable = HOSTILE_SPAWN
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	faction = list(FACTION_NETHER)
	speak_emote = list("screams", "clicks", "chitters", "barks", "moans", "growls", "meows", "reverberates", "roars", "squeaks", "rattles", "exclaims", "yells", "remarks", "mumbles", "jabbers", "stutters", "seethes")
	death_message = "wails as its form turns into a pulpy mush."
	death_sound = 'sound/mobs/non-humanoids/hiss/hiss6.ogg'
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	// Real blue, trying to go for the migo's look
	lighting_cutoff_red = 15
	lighting_cutoff_green = 15
	lighting_cutoff_blue = 50

	ai_controller = /datum/ai_controller/basic_controller/simple_hostile_obstacles
	var/static/list/migo_sounds
	/// Odds migo will dodge
	var/dodge_prob = 10

/mob/living/basic/migo/Initialize(mapload)
	. = ..()
	//hahahaha fuck you code divers
	// whoever you are FUCK you and I hate you.
	// in memory of the 200 something sound path list that was here

	if(!istype(src, /mob/living/basic/migo/hatsune) && prob(0.1)) // chance on-load mi-gos will spawn with a miku wig on (shiny variant)
		new /mob/living/basic/migo/hatsune(get_turf(loc), mapload)
		return INITIALIZE_HINT_QDEL

	AddElement(/datum/element/swabable, CELL_LINE_TABLE_NETHER, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 0)
	AddComponent(/datum/component/health_scaling_effects, min_health_slowdown = -1.5, additional_status_callback = CALLBACK(src, PROC_REF(update_dodge_chance)))

/// Makes the migo more likely to dodge around the more damaged it is
/mob/living/basic/migo/proc/update_dodge_chance(health_ratio)
	dodge_prob = LERP(50, 10, health_ratio)

/mob/living/basic/migo/proc/make_migo_sound()
	playsound(src, pick(SSsounds.all_sounds), 50, TRUE)

/mob/living/basic/migo/send_speech(message_raw, message_range, obj/source, bubble_type, list/spans, datum/language/message_language, list/message_mods, forced, tts_message, list/tts_filter)
	. = ..()
	if(stat != CONSCIOUS)
		return
	make_migo_sound()

/mob/living/basic/migo/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	..()
	if(stat)
		return
	if(SPT_PROB(5, seconds_per_tick))
		make_migo_sound()

/mob/living/basic/migo/Move(atom/newloc, dir, step_x, step_y)
	if(!ckey && prob(dodge_prob) && moving_diagonally == 0 && isturf(loc) && isturf(newloc))
		return dodge(newloc, dir)
	else
		return ..()

/mob/living/basic/migo/proc/dodge(moving_to, move_direction)
	//Assuming we move towards the target we want to swerve toward them to get closer
	var/cdir = turn(move_direction, 45)
	var/ccdir = turn(move_direction, -45)
	. = Move(get_step(loc,pick(cdir, ccdir)))
	if(!.)//Can't dodge there so we just carry on
		. = Move(moving_to, move_direction)

/// The special hatsune miku themed mi-go.
/mob/living/basic/migo/hatsune
	name = "hatsune mi-go"
	desc = parent_type::desc + " This one is wearing a bright blue wig."
	icon_state = "mi-go-h"
	icon_living = "mi-go-h"

	gender = FEMALE
	gold_core_spawnable = FRIENDLY_SPAWN
	faction = list(FACTION_NEUTRAL)

/mob/living/basic/migo/hatsune/make_migo_sound()
	playsound(src, 'sound/mobs/non-humanoids/tourist/tourist_talk_japanese1.ogg', 50, TRUE)

/mob/living/basic/migo/hatsune/Initialize(mapload)
	. = ..()
	var/static/list/death_loot = list(/obj/item/instrument/piano_synth)
	AddElement(/datum/element/death_drops, death_loot)
