/mob/living/basic/goat
	icon = 'modular_bandastation/mobs/icons/farm_animals.dmi'
	icon_resting = "goat"
	icon_gib = "gib"
	death_sound = 'modular_bandastation/mobs/sound/goat_death.ogg'

// ====================
// ======= Cow ========

/mob/living/basic/cow
	icon = 'modular_bandastation/mobs/icons/farm_animals.dmi'
	icon_state = "cow_black"
	icon_living = "cow_black"
	icon_dead = "cow_black_dead"
	icon_resting = "cow_black_rest"
	icon_gib = "gib"
	death_sound = 'modular_bandastation/mobs/sound/cow_death.ogg'
	damaged_sounds = list('modular_bandastation/mobs/sound/cow_damaged.ogg')
	var/list/possible_body_colors = list("brown", "black", "white")

/mob/living/basic/cow/Initialize(mapload)
	. = ..()
	if(!isnull(possible_body_colors))
		AddElement(/datum/element/animal_variety, "cow", pick(possible_body_colors), modify_pixels = FALSE)

/mob/living/basic/cow/black
	icon_state = "cow_black"
	icon_living = "cow_black"
	icon_dead = "cow_black_dead"
	icon_resting = "cow_black_rest"
	possible_body_colors = null

/mob/living/basic/cow/brown
	icon_state = "cow_brown"
	icon_living = "cow_brown"
	icon_dead = "cow_brown_dead"
	icon_resting = "cow_brown_rest"
	possible_body_colors = null

/mob/living/basic/cow/white
	icon_state = "cow_white"
	icon_living = "cow_white"
	icon_dead = "cow_white_dead"
	icon_resting = "cow_white_rest"
	possible_body_colors = null

// ====================
// ===== Chickens =====

/mob/living/basic/chicken
	icon = 'modular_bandastation/mobs/icons/farm_animals.dmi'
	icon_resting = "chicken_white_rest"
	icon_gib = "gib"
	death_sound = 'modular_bandastation/mobs/sound/chicken_death.ogg'
	damaged_sounds = list('modular_bandastation/mobs/sound/chicken_damaged1.ogg', 'modular_bandastation/mobs/sound/chicken_damaged2.ogg')

	// held_state Выбирается через инициализатор при розыгрыше раскраски
	can_be_held = TRUE
	held_w_class = WEIGHT_CLASS_SMALL
	held_lh = 'modular_bandastation/mobs/icons/inhands/mobs_lefthand.dmi'
	held_rh = 'modular_bandastation/mobs/icons/inhands/mobs_righthand.dmi'
	head_icon = 'modular_bandastation/mobs/icons/inhead/head.dmi'

/mob/living/basic/chicken/Initialize(mapload)
	. = ..()
	held_state = icon_state

/mob/living/basic/chick
	icon = 'modular_bandastation/mobs/icons/farm_animals.dmi'
	icon_resting = "chick_rest"
	death_sound = 'modular_bandastation/mobs/sound/mouse_squeak.ogg'
	held_state = "chick"
	can_be_held = TRUE
	held_w_class = WEIGHT_CLASS_TINY
	held_lh = 'modular_bandastation/mobs/icons/inhands/mobs_lefthand.dmi'
	held_rh = 'modular_bandastation/mobs/icons/inhands/mobs_righthand.dmi'
	head_icon = 'modular_bandastation/mobs/icons/inhead/head.dmi'

/mob/living/basic/chicken/cock
	name = "петух"
	desc = "Гордый и важный вид."
	gender = MALE
	icon = 'modular_bandastation/mobs/icons/farm_animals.dmi'
	icon_state = "cock"
	icon_living = "cock"
	icon_dead = "cock_dead"
	icon_resting = "cock_rest"
	icon_gib = "gib"
	butcher_results = list(/obj/item/food/meat/slab/chicken = 4)
	melee_damage_type = STAMINA
	melee_damage_lower = 2
	melee_damage_upper = 6
	attack_verb_continuous = "клюёт"
	attack_verb_simple = "клюёт"
	death_sound = 'modular_bandastation/mobs/sound/chicken_death.ogg'
	damaged_sounds = list('modular_bandastation/mobs/sound/chicken_damaged1.ogg', 'modular_bandastation/mobs/sound/chicken_damaged2.ogg')
	health = 50
	maxHealth = 50

	held_state = "cock"
	can_be_held = TRUE
	held_w_class = WEIGHT_CLASS_SMALL
	held_lh = 'modular_bandastation/mobs/icons/inhands/mobs_lefthand.dmi'
	held_rh = 'modular_bandastation/mobs/icons/inhands/mobs_righthand.dmi'
	head_icon = 'modular_bandastation/mobs/icons/inhead/head.dmi'

	can_egg_layer = FALSE // Мы не хотим чтобы петух высаживал яйца.
	ai_controller = /datum/ai_controller/basic_controller/chicken/cock

/mob/living/basic/chicken/cock/Initialize(mapload)
	. = ..()
	// Убираем "раскраску" курицы
	icon_state = initial(icon_state)
	icon_living = initial(icon_living)
	icon_dead = initial(icon_dead)
	held_state = icon_state

/mob/living/basic/chicken/cock/cool
	name = "крутух"
	desc = "Не грози южному курятнику, поклевывая зерно у себя в квартале."
	icon_state = "cock_cool"
	icon_living = "cock_cool"
	icon_dead = "cock_cool_dead"
	icon_resting = "cock_cool_rest"
	held_state = "cock_cool"
	health = 80
	maxHealth = 80

// ====================
// ======= Goose ======

/mob/living/basic/goose
	icon_resting = "goose_rest"
	melee_damage_type = STAMINA
	melee_damage_lower = 2
	melee_damage_upper = 8
	attack_verb_continuous = "щипает"
	attack_verb_simple = "щипает"
	death_sound = 'modular_bandastation/mobs/sound/duck_quak1.ogg'
	damaged_sounds = list('modular_bandastation/mobs/sound/duck_aggro1.ogg', 'modular_bandastation/mobs/sound/duck_aggro2.ogg')

/mob/living/basic/goose/gosling
	name = "гусенок"
	desc = "Симпатичный гусенок. Скоро он станей грозой всей станции."
	icon = 'modular_bandastation/mobs/icons/farm_animals.dmi'
	icon_state = "gosling"
	icon_living = "gosling"
	icon_dead = "gosling_dead"
	icon_resting = "gosling_rest"
	butcher_results = list(/obj/item/food/meat/slab/grassfed = 1)
	melee_damage_lower = 0
	melee_damage_upper = 2
	health = 15
	maxHealth = 15

/mob/living/basic/goose/turkey
	name = "индюшка"
	desc = "И не благодари."
	icon = 'modular_bandastation/mobs/icons/farm_animals.dmi'
	icon_state = "turkey"
	icon_living = "turkey"
	icon_dead = "turkey_dead"
	icon_resting = "turkey_rest"
	butcher_results = list(/obj/item/food/meat/slab/grassfed = 4)
