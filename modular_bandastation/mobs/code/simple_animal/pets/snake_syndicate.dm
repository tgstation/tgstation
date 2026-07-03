//Уникальный питомец синдиката. Спрайты от Элл Гуда
/mob/living/basic/snake/syndicate
	name = "Синдизмей"
	desc = "Опасная змея выращенная в лаборатории для уничтожения неприятелей Синдиката."
	icon = 'modular_bandastation/mobs/icons/pets.dmi'
	icon_state = "snake_syndicate"
	icon_living = "snake_syndicate"
	icon_dead = "snake_syndicate_dead"
	icon_resting = "snake_syndicate_rest"
	held_state = "pai_snake"
	health = 100
	maxHealth = 100
	melee_damage_lower = 5
	melee_damage_upper = 25
	//var/obj/item/inventory_head // TODO Snake Fashion
	faction = list("neutral", "syndicate")
	gold_core_spawnable = NO_SPAWN
	///icon state of the collar we can wear
	var/collar_icon_state

/mob/living/basic/snake/syndicate/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wears_collar, collar_icon_state = collar_icon_state)

/mob/living/basic/snake/syndicate/verb/chasetail()
	set name = "Помахать хвостом"
	set desc = "Ваааай!"
	set category = "Animal"
	visible_message("[src] [pick("кружится", "махает хвостом")].", "[pick("Вы кружитесь.", "Вы махаете хвостом.")].")
	spin(20, 1)

/mob/living/basic/snake/syndicate/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(user.combat_mode)
		shh(-1, user)
	else
		shh(1, user)

/mob/living/basic/snake/syndicate/proc/shh(change, mob/M)
	if(!M || stat)
		return
	if(change > 0)
		new /obj/effect/temp_visual/heart(loc)
		manual_emote("радостно шипит!")
	else
		manual_emote("злобно шипит!")

// Змея офицера синдиката
/mob/living/basic/snake/syndicate/rouge
	name = "Руж"
	desc = "Уникальная трёхголовая змея Офицера Телекоммуникаций синдиката. Выращена в лаборатории. У каждой головы свой характер!"
	gender = FEMALE

/mob/living/basic/snake/syndicate/rouge/Initialize(mapload, special_reagent)
	. = ..()
	update_overlays()

/mob/living/basic/snake/syndicate/rouge/update_overlays()
	. = ..()

	var/mutable_appearance/acc = mutable_appearance(
		'modular_bandastation/mobs/icons/rouge_accessories.dmi',
		"beret_hos_black"
	)

	. += acc

// Для змеи необходимо провести полный рефактор шмоток, если хотим шапки

// // Item datums
// /datum/snake_fashion/head
// 	icon_file = 'modular_bandastation/mobs/icons/rouge_accessories.dmi'

// /datum/snake_fashion/head/beret_hos_black
// 	name = "Ля Руж"
// 	desc = "Mon Dieu! C'est un serpent à trois têtes!"
// 	speak = list("le shhh!")
// 	emote_see = list("трясётся в наигранном страхе.", "сдаётся.","устраивает тихую битву между своими головами.", "притворяется мёртвой.","ведёт себя так будто перед ней невидимая стенка.")

// // rouge items
// /obj/item/clothing/head/hos/beret
// 	snake_fashion = /datum/snake_fashion/head/beret_hos_black
