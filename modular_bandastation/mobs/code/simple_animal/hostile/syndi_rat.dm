/mob/living/basic/mouse/rat/syndirat
	name = "Синдикрыс"
	desc = "На службе синдиката"
	icon = 'modular_bandastation/mobs/icons/mouse.dmi'
	icon_state = "syndirat"
	icon_living = "syndirat"
	icon_dead = "syndirat_dead"
	icon_resting = "syndirat_sleep"
	body_color = ""
	body_icon_state = null
	possible_body_colors = null
	health = 50
	maxHealth = 50

	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	unsuitable_atmos_damage = 0

	melee_damage_lower = 5
	melee_damage_upper = 15

	ai_controller = /datum/ai_controller/basic_controller/mouse/rat/syndi

/mob/living/basic/mouse/rat/syndirat/jet
	desc = "Нарушитель безполетных зон."
	icon_state = "syndirat_jet"
	icon_living = "syndirat_jet"
	speed = 0.8

/mob/living/basic/mouse/rat/syndirat/jet/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_SPACEWALK, TRAIT_SWIMMER, TRAIT_FENCE_CLIMBER), INNATE_TRAIT)
