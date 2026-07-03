/mob/living/basic/pig
	icon = 'modular_bandastation/mobs/icons/pigs.dmi'
	icon_state = "pig"
	icon_living = "pig"
	icon_dead = "pig_dead"
	icon_resting = "pig_rest"
	icon_gib = "gib"
	attack_verb_continuous = "лягает"
	attack_verb_simple = "лягает"
	death_sound = 'modular_bandastation/mobs/sound/pig_death.ogg'

	// Переменные для перекрашивания
	/// Будем пытаться перекрасить при инициализации?
	var/need_recolor = TRUE
	/// Определение icon_state
	var/body_icon_state  = "pig"
	/// Черный, маринадный, дефолтный.
	var/body_color
	/// Шанс покрасить в другой цвет
	var/color_chance = 5
	/// Какой цвет перекраски возможен. null - дефолт
	var/list/possible_body_colors = list("black")

/mob/living/basic/pig/Initialize(mapload)
	. = ..()
	try_recolor()

/mob/living/basic/pig/proc/try_recolor()
	if(!need_recolor)
		return
	if(isnull(body_icon_state) || isnull(possible_body_colors) || !length(possible_body_colors))
		WARNING("У [src] не определены переменные для перекраски")
		return
	if(!prob(color_chance))
		return
	var/picked_color = pick(possible_body_colors)
	if(!isnull(body_icon_state))
		AddElement(/datum/element/animal_variety, "[body_icon_state]", "[picked_color]", modify_pixels = FALSE)

/mob/living/basic/pig/baby
	name = "поросенок"
	desc = "Маленький и смышленный, его ждет вкусное будущее!"
	icon_state = "pig_baby"
	icon_living = "pig_baby"
	icon_dead = "pig_baby_dead"
	icon_resting = "pig_baby_rest"
	body_icon_state = "pig_baby"

	health = 20
	maxHealth = 20
	melee_damage_lower = 1
	melee_damage_upper = 2
	obj_damage = 2
	butcher_results = list(/obj/item/food/meat/slab/pig = 2)

	ai_controller = /datum/ai_controller/basic_controller/pig

/mob/living/basic/pig/baby/teen
	name = "подсвинок"
	desc = "Задорная хрюшка, готовая к приключениям на кухне!"
	icon_state = "pig_teen"
	icon_living = "pig_teen"
	icon_dead = "pig_teen_dead"
	icon_resting = "pig_teen_rest"
	body_icon_state = "pig_teen"

	health = 20
	maxHealth = 20
	melee_damage_lower = 1
	melee_damage_upper = 3
	obj_damage = 3
	butcher_results = list(/obj/item/food/meat/slab/pig = 5)

/mob/living/basic/pig/baby/young
	name = "свинка"
	desc = "Молодая и пухленькая, полна сил и хрюканья."
	icon_state = "pig_young"
	icon_living = "pig_young"
	icon_dead = "pig_young_dead"
	icon_resting = "pig_young_rest"
	body_icon_state = "pig_young"

	health = 50
	maxHealth = 50
	melee_damage_lower = 2
	melee_damage_upper = 5
	obj_damage = 6
	butcher_results = list(/obj/item/food/meat/slab/pig = 10)

/mob/living/basic/pig
	name = "свинья"
	desc = "Классическая хрюшка, что-то среднее между кормушкой и копилкой."
	icon_state = "pig"
	icon_living = "pig"
	icon_dead = "pig_dead"
	icon_resting = "pig_rest"
	body_icon_state = "pig"

	health = 80
	maxHealth = 80
	speed = 2
	melee_damage_lower = 2
	melee_damage_upper = 8
	obj_damage = 10
	butcher_results = list(/obj/item/food/meat/slab/pig = 12)
	ai_controller = /datum/ai_controller/basic_controller/pig/big

/mob/living/basic/pig/adult
	name = "свин"
	desc = "Здоровенный упитанный порось, внушает уважение своим видом."
	icon_state = "pig_adult"
	icon_living = "pig_adult"
	icon_dead = "pig_adult_dead"
	icon_resting = "pig_adult_rest"
	body_icon_state = "pig_adult"
	health = 100
	maxHealth = 100
	speed = 2
	butcher_results = list(/obj/item/food/meat/slab/pig = 16)
	melee_damage_lower = 3
	melee_damage_upper = 10
	obj_damage = 13

/mob/living/basic/pig/old
	name = "хряк"
	desc = "Старый и опытный порось, накопивший огромное достоинство."
	icon_state = "pig_old"
	icon_living = "pig_old"
	icon_dead = "pig_old_dead"
	icon_resting = "pig_old_rest"
	body_icon_state = "pig_old"
	health = 150
	maxHealth = 150
	speed = 3
	melee_damage_lower = 4
	melee_damage_upper = 12
	obj_damage = 15
	butcher_results = list(/obj/item/food/meat/slab/pig = 22)

/mob/living/basic/pig/old/ancient
	name = "прахряк"
	desc = "Легенда свинарника, древний хрюкун, переживший больше обедов, чем можно сосчитать."
	icon_state = "pig_ancient"
	icon_living = "pig_ancient"
	icon_dead = "pig_ancient_dead"
	icon_resting = "pig_ancient_rest"
	body_icon_state = "pig_ancient"
	health = 200
	maxHealth = 200
	melee_damage_lower = 5
	melee_damage_upper = 15
	obj_damage = 20
	butcher_results = list(/obj/item/food/meat/slab/pig = 30)
