#define SERPENT_ENRAGED (health < maxHealth*0.5)

/mob/living/simple_animal/hostile/megafauna/serpent
	name = "sea serpent"
	desc = "A rather decieving name as it doesn't look much like a serpent."
	health = 2500
	maxHealth = 2500
	attack_verb_continuous = "chomps"
	attack_verb_simple = "chomp"
	attack_sound = 'sound/effects/magic/demon_attack1.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	icon = 'icons/mob/simple/lavaland/sea_serpent.dmi'
	icon_state = "dragon"
	icon_living = "dragon"
	icon_dead = "dragon_dead"
	health_doll_icon = "dragon"
	friendly_verb_continuous = "stares down"
	friendly_verb_simple = "stare down"
	speak_emote = list("roars")
	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	speed = 5
	move_to_delay = 3
	ranged = TRUE
	pixel_x = -16
	base_pixel_x = -16
	crusher_loot = list(/obj/structure/closet/crate/necropolis/dragon/crusher)
	loot = list(/obj/structure/closet/crate/necropolis/dragon)
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/bone = 30)
	guaranteed_butcher_results = list(/obj/item/stack/sheet/animalhide/ashdrake = 10)
	initial_language_holder = /datum/language_holder/lizard/hear_common
	var/player_cooldown = 0
	gps_name = "Electric Signal"
	death_message = "collapses into a pile of bones, its flesh sloughing away."
	death_sound = 'sound/effects/magic/demon_dies.ogg'
	footstep_type = FOOTSTEP_MOB_HEAVY
	var/datum/action/cooldown/mob_cooldown/thunderstorm/thunderstorm
	var/datum/action/cooldown/mob_cooldown/dash/dash
	var/datum/action/cooldown/mob_cooldown/fire_breath/ice/electric/serpent/breath = BB_WHELP_STRAIGHTLINE_FIRE
	var/datum/action/cooldown/mob_cooldown/fire_breath/ice/eruption/electric/serpent/eruption = BB_WHELP_WIDESPREAD_FIRE

/mob/living/simple_animal/hostile/megafauna/serpent/Initialize(mapload)
	. = ..()
	thunderstorm = new(src)
	dash = new(src)
	breath = new(src)
	eruption = new(src)
	thunderstorm.Grant(src)
	dash.Grant(src)
	breath.Grant(src)
	eruption.Grant(src)
	AddElement(/datum/element/change_force_on_death, move_force = MOVE_FORCE_DEFAULT)
	add_traits(list(TRAIT_NODROWN, TRAIT_SWIMMER), INNATE_TRAIT)

/mob/living/simple_animal/hostile/megafauna/serpent/Destroy()
	thunderstorm = null
	breath = null
	eruption = null
	return ..()

/mob/living/simple_animal/hostile/megafauna/serpent/OpenFire()
	if(client)
		return

	if(prob(12))
		dash.Trigger(target = target)
		return

	if(prob(30))
		breath.Trigger(target = target)
		return

	if(prob(18))
		eruption.Trigger(target = target)
		return

	if(prob(18))
		thunderstorm.Trigger(target = target)
		return

/mob/living/simple_animal/hostile/megafauna/serpent/ex_act(severity, target)
	if(severity <= EXPLODE_LIGHT)
		return FALSE
	return ..()

/datum/action/cooldown/mob_cooldown/thunderstorm
	name = "Thunderstorm"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Allows you to thunderstorm around yourself."
	cooldown_time = 4 SECONDS

/datum/action/cooldown/mob_cooldown/thunderstorm/Activate(atom/target_atom)
	disable_cooldown_actions()
	storm(target_atom)
	StartCooldown()
	enable_cooldown_actions()
	return TRUE

/datum/action/cooldown/mob_cooldown/thunderstorm/proc/storm(atom/target)
	if(!target)
		return
	target.visible_message(span_boldwarning("The sky lights up with a storm!"))
	var/turf/targetturf = get_turf(target)
	for(var/turf/turf as anything in RANGE_TURFS(9,targetturf))
		if(prob(12))
			new /obj/effect/temp_visual/lightning_strike(turf)

/datum/action/cooldown/mob_cooldown/fire_breath/ice/electric/serpent
	cooldown_time = 6 SECONDS
	click_to_activate = FALSE
	fire_range = 10
	forecast_delay = 0
	fire_delay = 1.5 DECISECONDS

/datum/action/cooldown/mob_cooldown/fire_breath/ice/eruption/electric/serpent
	forecast_delay = 0
	fire_delay = 1.8 DECISECONDS
