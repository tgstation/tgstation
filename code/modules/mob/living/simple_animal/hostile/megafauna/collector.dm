#define MEDAL_PREFIX "Collector"

/mob/living/simple_animal/hostile/megafauna/collector
	name = "The Collector"
	desc = "A thrumming mass of rapacious curses."
	icon_state = "collector"
	icon_living = "collector"
	icon = 'icons/mob/lavaland/128x128megafauna.dmi'
	pixel_x = -48
	pixel_y = -32
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
	score_type = COLLECTOR_SCORE
	var/turf/original_location

/mob/living/simple_animal/hostile/megafauna/collector/Initialize()
	. = ..()
	original_location = get_turf(src)
	if(prob(1))
		name = pick("big angry curse ball", "\improper It's A Bunch Of Ghosts Guys")
		desc = "You get the feeling someone couldn't decide on a name for this."

/mob/living/simple_animal/hostile/megafauna/collector/Destroy()
	new/obj/effect/temp_visual/collector_death(get_turf(src))
	return ..()

/mob/living/simple_animal/hostile/megafauna/collector/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(GLOB.necropolis_gate)
		GLOB.necropolis_gate.toggle_the_gate(null, TRUE) //a good try.
	return ..()

/mob/living/simple_animal/hostile/megafauna/collector/Move()
	if(!canmove)
		return
	. = ..()
	playsound(src, 'sound/creatures/collector_step.ogg', 50, FALSE)



//Collector death "cinematic."
/obj/effect/temp_visual/collector_death
	name = "The Collector"
	desc = "A mass of curses, losing form."
	icon_state = "collector"
	icon = 'icons/mob/lavaland/128x128megafauna.dmi'
	pixel_x = -48
	pixel_y = -32
	layer = LARGE_MOB_LAYER
	duration = 40
	density = TRUE
	light_range = 3

/obj/effect/temp_visual/collector_death/Initialize()
	. = ..()
	death_animation()

/obj/effect/temp_visual/collector_death/Destroy()
	playsound(src, 'sound/creatures/collector_death.ogg', 100, FALSE)
	new/obj/item/weapon/staff/storm(get_turf(src))
	return ..()

/obj/effect/temp_visual/collector_death/proc/death_animation()
	visible_message("<span class='big revenboldnotice'>[src] writhes and howls with unearthly agony!</span>")
	for(var/mob/M in GLOB.player_list)
		if(M.z == z)
			M.playsound_local(M, 'sound/creatures/collector_deathblow.ogg', 100, FALSE)

#undef MEDAL_PREFIX
