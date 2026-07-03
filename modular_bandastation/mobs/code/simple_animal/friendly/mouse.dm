/mob/living/basic/mouse
	icon = 'modular_bandastation/mobs/icons/mouse.dmi' // Здесь есть недостающие стейты
	icon_resting = "mouse_gray_rest"
	attack_sound = 'modular_bandastation/mobs/sound/rat_squeak.ogg'
	death_sound = 'modular_bandastation/mobs/sound/rat_death.ogg'
	damaged_sounds = list('modular_bandastation/mobs/sound/rat_wound.ogg')
	blood_volume = BLOOD_VOLUME_SURVIVE
	butcher_results = list(/obj/item/food/meat/slab/mouse = 1)

/mob/living/basic/mouse/Initialize(mapload, tame = FALSE, new_body_color)
	. = ..()
	if(body_color == "wooly")
		name = /mob/living/basic/mouse/wooly::name
		desc = /mob/living/basic/mouse/wooly::desc
		icon = /mob/living/basic/mouse/wooly::icon
		held_lh = /mob/living/basic/mouse/wooly::held_lh
		held_rh = /mob/living/basic/mouse/wooly::held_rh
		head_icon = /mob/living/basic/mouse/wooly::head_icon
		minimum_survivable_temperature = /mob/living/basic/mouse/wooly::minimum_survivable_temperature
		maximum_survivable_temperature = /mob/living/basic/mouse/wooly::maximum_survivable_temperature
		maxHealth = /mob/living/basic/mouse/wooly::maxHealth
		health = /mob/living/basic/mouse/wooly::health

/mob/living/basic/mouse/splat()
	. = ..()
	if(prob(50))
		var/turf/location = get_turf(src)
		add_splatter_floor(location)
		// if(item)
		// 	item.add_mob_blood(src)
		// if(user)
		// 	user.add_mob_blood(src)

/mob/living/basic/mouse/death(gibbed)
	if(gibbed)
		make_remains()
	. = ..(gibbed)

/mob/living/basic/mouse/proc/make_remains()
	var/obj/effect/decal/remains = new /obj/effect/decal/remains/mouse(src.loc)
	remains.pixel_x = pixel_x
	remains.pixel_y = pixel_y

/mob/living/basic/mouse/wooly
	name = "пушистая мышь"
	desc = "С пушком. Такая способна пережить морозы."
	icon_state = "mouse_wooly"
	icon_living = "mouse_wooly"
	icon_dead = "mouse_wooly_dead"
	icon_resting = "mouse_wooly_sleep"
	body_color = "wooly"
	icon = 'modular_bandastation/mobs/icons/mouse.dmi'
	held_lh = 'modular_bandastation/mobs/icons/inhands/mobs_lefthand.dmi'
	held_rh = 'modular_bandastation/mobs/icons/inhands/mobs_righthand.dmi'
	head_icon = 'modular_bandastation/mobs/icons/inhead/head.dmi'

	minimum_survivable_temperature = NPC_DEFAULT_MIN_TEMP - 150
	maximum_survivable_temperature = NPC_DEFAULT_MAX_TEMP + 150
	maxHealth = 15
	health = 15

/mob/living/basic/mouse/clockwork
	name = "заводная мышь" // Чип
	desc = "Закатились шарики за ролики."
	icon = 'modular_bandastation/mobs/icons/mouse.dmi'
	icon_state = "mouse_clockwork"
	icon_living = "mouse_clockwork"
	icon_dead = "mouse_clockwork_dead"
	held_state = "mouse_clockwork"
	body_icon_state = null // чтобы не перекрасился
	gold_core_spawnable = NO_SPAWN
	butcher_results = list(/obj/item/stack/sheet/iron = 5)
	maxHealth = 20
	health = 20

/mob/living/basic/mouse/factory
	name = "мышь заводчанин"
	desc = "Вернулся с тяжелой мышиной смены на мышиной фабрике по производству мышиных вещей."
	icon = 'modular_bandastation/mobs/icons/mouse.dmi'
	icon_state = "mouse_zavod" // Спрайт авторства vitalya_kramsatel (discord)
	icon_living = "mouse_zavod"
	icon_dead = "mouse_zavod_dead"
	body_icon_state = null // чтобы не перекрасился
	butcher_results = list(/obj/item/food/meat/slab/mouse = 1, /obj/item/stack/sheet/iron = 2)
	minimum_survivable_temperature = NPC_DEFAULT_MIN_TEMP - 100
	maximum_survivable_temperature = NPC_DEFAULT_MAX_TEMP + 200
	maxHealth = 15
	health = 15

// =============================
// Для спавнов педальками

/mob/living/basic/mouse/representative
	name = "мышь представитель"
	desc = "Уважаемая мышь с крайне важным видом и очень важным делом."
	icon = 'modular_bandastation/mobs/icons/mouse.dmi'
	icon_state = "mouse_rep" // Спрайт авторства vitalya_kramsatel (discord)
	icon_living = "mouse_rep"
	icon_dead = "mouse_rep_dead"
	body_icon_state = null // чтобы не перекрасился
	minimum_survivable_temperature = NPC_DEFAULT_MIN_TEMP - 150 // Это всё-таки пушистый мышь
	maximum_survivable_temperature = NPC_DEFAULT_MAX_TEMP + 150
	maxHealth = 20
	health = 20
	// TODO: VERB сидения с спрайтами "mouse_rep_sit" и "mouse_rep_chair"

/mob/living/basic/mouse/jet
	name = "мышь-летяга"
	desc = "У неё есть летные права."
	speed = 0.8

/mob/living/basic/mouse/jet/Initialize(mapload, tame = FALSE, new_body_color)
	. = ..()
	icon_state = "[icon_state]_jet"
	icon_living = icon_state
	add_traits(list(TRAIT_SPACEWALK, TRAIT_SWIMMER, TRAIT_FENCE_CLIMBER), INNATE_TRAIT)
