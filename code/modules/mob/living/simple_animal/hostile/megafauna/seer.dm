#define MEDAL_PREFIX "Seer"
#define PHASE_NULL "null" //The Seer's melee phase. It actively pursues its target.
#define PHASE_VOID "void" //The Seer's ranged phase. It stands in the center of the arena, flooding the room with projectiles.
#define PHASE_DARK "dark" //The Seer's "last stand" phase. It warps wildly around the arena in a frenzy.

/mob/living/simple_animal/hostile/megafauna/seer
	name = "\improper Seer"
	desc = "A witness to the end."
	icon_state = "seer"
	icon_living = "seer"
	icon = 'icons/mob/lavaland/64x64megafauna.dmi'
	pixel_x = -16
	pixel_y = -16
	health = 2500
	maxHealth = 2500
	attacktext = "lashes out at"
	attack_sound = 'sound/magic/clockwork/narsie_attack.ogg'
	speak_emote = list("heralds")
	armour_penetration = 100
	melee_damage_lower = 15
	melee_damage_upper = 15
	speed = 1
	move_to_delay = 10
	ranged = TRUE
	del_on_death = TRUE
	wander = FALSE
	idle_vision_range = 7
	vision_range = 7
	aggro_vision_range = 15
	medal_type = MEDAL_PREFIX
	score_type = SEER_SCORE
	var/phase = PHASE_VOID
	var/transitioning = FALSE //If we're moving between phases
	var/turf/original_location

/mob/living/simple_animal/hostile/megafauna/seer/Initialize()
	. = ..()
	original_location = get_turf(src)
	if(prob(1))
		name = pick("big angry curse ball", "\improper It's A Bunch Of Ghosts Guys")
		desc = "You get the feeling someone couldn't decide on a name for this."

/mob/living/simple_animal/hostile/megafauna/seer/Destroy()
	new/obj/effect/temp_visual/seer_death(get_turf(src))
	return ..()

/mob/living/simple_animal/hostile/megafauna/seer/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(GLOB.necropolis_gate)
		GLOB.necropolis_gate.toggle_the_gate(null, TRUE) //a good try.
	return ..()

/mob/living/simple_animal/hostile/megafauna/seer/Move()
	if(!canmove)
		return
	. = ..()
	if(phase == PHASE_NULL)
		playsound(src, 'sound/creatures/seer_step.ogg', 50, FALSE)

/mob/living/simple_animal/hostile/megafauna/seer/proc/swap_phases(to_phase)
	set waitfor = FALSE
	if(!to_phase)
		return
	phase = to_phase
	if(phase == PHASE_VOID)
		icon_state = "seer"
		playsound(src, 'sound/creatures/seer_teleport.ogg', 75, FALSE)
		visible_message("<span class='revennotice italics'>[src] vanishes, a violet mist drifting to the [dir2text(get_dir(src, original_location))]!</span>")
		forceMove(original_location)
		canmove = FALSE
		visible_message("<span class='revennotice italics'>[src] appears above [original_location]!</span>")
		playsound(src, 'sound/creatures/seer_teleport.ogg', 75, FALSE)
	else if(phase == PHASE_DARK)
		transitioning = TRUE
		playsound(src, 'sound/creatures/seer_teleport.ogg', 75, FALSE)
		forceMove(original_location)
		canmove = FALSE
		sleep(20)
		transitioning = FALSE
		icon_state = "seer_frenzy"
		visible_message("<span class='revenboldnotice big'>[src] goes into a frenzy!</span>")
		playsound(src, 'sound/creatures/seer_deathblow.ogg', 100, TRUE, frequency = 1.1)
	else //Defaults to PHASE_NULL
		icon_state = "seer"
		visible_message("<span class='revennotice italics'>[src] lumbers forward!</span>")
		canmove = TRUE
		playsound(src, 'sound/creatures/seer_scream.ogg', 75, FALSE)



//Seer death "cinematic."
/obj/effect/temp_visual/seer_death
	name = "\improper Seer"
	desc = "A witness to the end of its days."
	icon_state = "seer_frenzy"
	icon = 'icons/mob/lavaland/64x64megafauna.dmi'
	pixel_x = -16
	pixel_y = -16
	layer = LARGE_MOB_LAYER
	duration = 40
	density = TRUE
	light_range = 3

/obj/effect/temp_visual/seer_death/Initialize()
	. = ..()
	death_animation()

/obj/effect/temp_visual/seer_death/Destroy()
	playsound(src, 'sound/creatures/seer_death.ogg', 100, FALSE)
	new/obj/item/weapon/staff/storm(get_turf(src))
	return ..()

/obj/effect/temp_visual/seer_death/proc/death_animation()
	visible_message("<span class='big revenboldnotice'>[src] writhes and howls with unearthly agony!</span>")
	for(var/mob/M in GLOB.player_list)
		if(M.z == z)
			M.playsound_local(M, 'sound/creatures/seer_deathblow.ogg', 100, FALSE)

#undef PHASE_DARK
#undef PHASE_VOID
#undef PHASE_NULL
#undef MEDAL_PREFIX
