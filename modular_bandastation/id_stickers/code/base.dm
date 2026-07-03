/obj/item/id_sticker
	name = "ID sticker"
	desc = "Этим можно изменить внешний вид своей карты! Покажи службе безопасности какой ты стильный."
	icon = 'modular_bandastation/id_stickers/icons/id_stickers.dmi'
	icon_state = ""
	w_class = WEIGHT_CLASS_SMALL
	var/id_card_desc

/obj/item/id_sticker/colored
	name = "holographic ID sticker"
	desc = "Голографическая наклейка на карту. Вы можете выбрать цвет который она примет."
	icon_state = "colored"
	var/static/list/color_list = list(
		"Красный" = COLOR_RED_LIGHT,
		"Зелёный" = LIGHT_COLOR_GREEN,
		"Синий" = LIGHT_COLOR_BLUE,
		"Жёлтый" = COLOR_VIVID_YELLOW,
		"Оранжевый" = LIGHT_COLOR_ORANGE,
		"Фиолетовый" = LIGHT_COLOR_LAVENDER,
		"Голубой" = LIGHT_COLOR_LIGHT_CYAN,
		"Циановый" = LIGHT_COLOR_CYAN,
		"Аквамариновый" = LIGHT_COLOR_BLUEGREEN,
		"Розовый" = LIGHT_COLOR_PINK
	)
	greyscale_config = /datum/greyscale_config/id_sticker
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/id_sticker/colored/Initialize(mapload)
	. = ..()
	set_greyscale(color_list[pick(color_list)])

/obj/item/id_sticker/colored/attack_self(mob/living)
	var/choice = tgui_input_list(usr, "Какой цвет предпочитаете?", "Выбор цвета", list("Выбрать предустановленный", "Выбрать вручную"))
	if(!choice)
		return
	switch(choice)
		if("Выбрать предустановленный")
			choice = tgui_input_list(usr, "Выберите цвет", "Выбор цвета", color_list)
			var/color_to_set = color_list[choice]
			if(!color_to_set)
				return

			set_greyscale(color_to_set)

		if("Выбрать вручную")
			set_greyscale(input(usr, "Выберите цвет") as color)
