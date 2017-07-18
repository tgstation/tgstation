#define MEDAL_PREFIX "Seer"
#define PHASE_VOID "void" //The Seer hasn't been aggroed.
#define PHASE_ALPHA "alpha" //The first phase; the Seer swaps between megafauna types, using different abilities for each.
#define FORM_TIME_ALPHA 7 //The amount of ticks the Seer will spend in a form in Alpha phase
#define PHASE_MU "mu" //The second phase; the Seer swaps rapidly between mob types, using different abilities for each.
#define FORM_TIME_MU 5 //The amount of ticks the Seer will spend in a form in Alpha phase
#define PHASE_OMEGA "omega" //The final phase; the Seer stands in the center of the room unleashing a torrent of curses until defeated.
#define FORM_ACCURSED "mass of curses"
#define FORM_DRAGON "dragon"
#define FORM_BUBBLEGUM "bubblegum"
#define FORM_COLOSSUS "colossus"
#define FORM_HIEROPHANT "hierophant"

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
	speak_emote = list("sibilates")
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
	var/form = FORM_ACCURSED
	var/transition = FALSE //If we're transitioning between phases
	var/list/forms = list(, \
	FORM_DRAGON = list("x" = -16, "y" = 0, "icon" = 'icons/mob/lavaland/64x64megafauna.dmi', "state" = "dragon"), \
	FORM_BUBBLEGUM = list("x" = -32, "y" = 0, "icon" = 'icons/mob/lavaland/96x96megafauna.dmi', "state" = "bubblegum"), \
	FORM_COLOSSUS = list("x" = -32, "y" = 0, "icon" = 'icons/mob/lavaland/96x96megafauna.dmi', "state" = "eva"), \
	FORM_HIEROPHANT = list("x" = 0, "y" = 0, "icon" = 'icons/mob/lavaland/hierophant_new.dmi', "state" = "hierophant"), \
	) //A list of all the possible forms, with pixel offsets, icons, and states
	var/list/forms_this_cycle //Forms done during this "transition" cycle; we go through each form once before we reset
	var/has_used_ability = FALSE //If the Seer has used its form's "special ability" yet
	var/charging = FALSE //Used to track the Howling Charge ability
	var/time_in_form = 0 //How many ticks the Seer has spent in this form
	var/turf/original_location

/mob/living/simple_animal/hostile/megafauna/seer/Initialize()
	. = ..()
	original_location = get_turf(src)
	if(prob(1))
		name = pick("big angry curse ball", "It's A Bunch Of Ghosts Guys")

/mob/living/simple_animal/hostile/megafauna/seer/Destroy()
	new/obj/effect/seer_death(get_turf(src))
	return ..()

/mob/living/simple_animal/hostile/megafauna/seer/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(GLOB.necropolis_gate)
		GLOB.necropolis_gate.toggle_the_gate(null, TRUE) //a good try.
	return ..()

/mob/living/simple_animal/hostile/megafauna/seer/Move()
	if(!canmove)
		return
	. = ..()



//Seer death "cinematic."
/obj/effect/temp_visual/seer_death
	name = "\improper Seer"
	desc = "A witness to the end of its days."
	icon_state = "seer_frenzy"
	icon = 'icons/mob/lavaland/64x64megafauna.dmi'
	pixel_x = -16
	pixel_y = -16
	layer = LARGE_MOB_LAYER
	duration = 65
	density = TRUE
	anchored = TRUE
	light_range = 3
	mouse_opacity = 0

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
	sleep(35)
	playsound(src, 'sound/creatures/seer_scream.ogg', 100, FALSE)
	animate(src, pixel_y = -9, alpha = 25, time = 30)

#undef PHASE_VOID
#undef PHASE_ALPHA
#undef PHASE_MU
#undef PHASE_OMEGA
#undef FORM_ACCURSED
#undef FORM_DRAGON
#undef FORM_BUBBLEGUM
#undef FORM_COLOSSUS
#undef FORM_HIEROPHANT
#undef MEDAL_PREFIX
