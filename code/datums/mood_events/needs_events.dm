//nutrition
/datum/mood_event/fat
	description = "<B>Я ожирел...</B>" //muh fatshaming
	mood_change = -6

/datum/mood_event/too_wellfed
	description = "Кажется, я переел."
	mood_change = 0

/datum/mood_event/wellfed
	description = "Ух, как наелся!"
	mood_change = 8

/datum/mood_event/fed
	description = "Я недавно поел."
	mood_change = 5

/datum/mood_event/hungry
	description = "Я немного проголодался."
	mood_change = -3

/datum/mood_event/hungry_very
	description = "Я голодаю!"
	mood_change = -6

/datum/mood_event/starving
	description = "Я умираю с голода!"
	mood_change = -10

//charge
/datum/mood_event/supercharged
	description = "Я не могу сдерживать всю эту энергию внутри, мне нужно срочно высвободить её!"
	mood_change = -10

/datum/mood_event/overcharged
	description = "Я немного переполнен энергией, мне бы следовало немного её освободить."
	mood_change = -4

/datum/mood_event/charged
	description = "Я чувствую энергию в своих венах!"
	mood_change = 6

/datum/mood_event/lowpower
	description = "Моя энергия на исходе, мне бы подзарядиться."
	mood_change = -6

/datum/mood_event/decharged
	description = "Мне крайне необходимо зарядиться!"
	mood_change = -10

//Disgust
/datum/mood_event/gross
	description = "Я видел что-то противное."
	mood_change = -4

/datum/mood_event/verygross
	description = "Кажется, меня сейчас стошнит..."
	mood_change = -6

/datum/mood_event/disgusted
	description = "О боже, это отвратительно..."
	mood_change = -8

/datum/mood_event/disgust/bad_smell
	description = "Я чувствую ужасный запах разложения в этой комнате."
	mood_change = -6

/datum/mood_event/disgust/nauseating_stench
	description = "Вонь от гниющих трупов невыносима!"
	mood_change = -12

/datum/mood_event/disgust/dirty_food
	description = "Это было не слишком гигиенично есть..."
	mood_change = -6
	timeout = 4 MINUTES

/datum/mood_event/disgust/dirty_food/add_effects(...)
	if(HAS_PERSONALITY(owner, /datum/personality/ascetic))
		mood_change *= 0.25
		description = "Еда была грязной, но съедобной."
	if(HAS_PERSONALITY(owner, /datum/personality/gourmand))
		mood_change *= 1.5
		description = "Это еда была грязной. Её что, готовили в мусорном баке?!"

//Generic needs events
/datum/mood_event/shower
	description = "Я недавно принял приятный душ."
	mood_change = 4
	timeout = 5 MINUTES

/datum/mood_event/shower/add_effects(shower_reagent)
	if(istype(shower_reagent, /datum/reagent/blood))
		if(HAS_TRAIT(owner, TRAIT_MORBID) || HAS_TRAIT(owner, TRAIT_EVIL) || (owner.mob_biotypes & MOB_UNDEAD))
			description = "Ощущение прекрасного кровавого душа было великолепным."
			mood_change = 6 // you sicko
		else
			description = "Недавно я принял ужасный душ, из которого лилась кровь!"
			mood_change = -4
			timeout = 3 MINUTES
	else if(istype(shower_reagent, /datum/reagent/water))
		if(HAS_TRAIT(owner, TRAIT_WATER_HATER) && !HAS_TRAIT(owner, TRAIT_WATER_ADAPTATION))
			description = "Ненавижу быть мокрым!"
			mood_change = -2
			timeout = 3 MINUTES
		else
			return // just normal clean shower
	else // it's dirty ass water
		description = "Недавно я принял грязный душ!"
		mood_change = -3
		timeout = 3 MINUTES

/datum/mood_event/hot_spring
	description = "Это так расслабляет - купаться в горячей воде..."
	mood_change = 5

/datum/mood_event/hot_spring_hater
	description = "Нет, нет, нет, я не хочу принимать ванну!"
	mood_change = -2

/datum/mood_event/hot_spring_left
	description = "Было приятно помыться в тёплой воде."
	mood_change = 4
	timeout = 4 MINUTES

/datum/mood_event/hot_spring_hater_left
	description = "Я ненавижу ванны! Ненавижу, как холодно становится, когда выходишь из ванны!"
	mood_change = -3
	timeout = 2 MINUTES

/datum/mood_event/fresh_laundry
	description = "Ах, ничего не сравнится с ощущением свежевыстиранного комбинезона."
	mood_change = 2
	timeout = 10 MINUTES

/datum/mood_event/surrounded_by_silicon
	description = "Я окружен совершенными формами жизни!!"
	mood_change = 8

/datum/mood_event/around_many_silicon
	description = "Так много синтетиков вокруг меня!"
	mood_change = 4

/datum/mood_event/around_silicon
	description = "Эти синтетики абсолютно совершенны."
	mood_change = 2

/datum/mood_event/around_organic
	description = "Органики вокруг меня напоминают о слабости плоти."
	mood_change = -2

/datum/mood_event/around_many_organic
	description = "Так много отвратительных органиков!"
	mood_change = -4

/datum/mood_event/surrounded_by_organic
	description = "Я окружен отвратительными органиками!!"
	mood_change = -8

/datum/mood_event/completely_robotic
	description = "Я отбросил свою слабую плоть, моя форма совершенна!"
	mood_change = 8

/datum/mood_event/very_robotic
	description = "Я больше робот, чем органик!"
	mood_change = 4

/datum/mood_event/balanced_robotic
	description = "Часть машина, часть органик."
	mood_change = 0

/datum/mood_event/very_organic
	description = "Я ненавижу эту слабую и немощную плоть!"
	mood_change = -4

/datum/mood_event/completely_organic
	description = "Я полностью органик, это ужасно!!"
	mood_change = -8
