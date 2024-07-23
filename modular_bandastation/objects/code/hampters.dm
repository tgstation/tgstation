/obj/item/toy/plush/hampter
	name = "хамптер"
	desc = "Просто плюшевый хамптер. Самый обычный."
	icon = 'modular_bandastation/objects/icons/hampter.dmi'
	icon_state = "hampter"
	lefthand_file = 'modular_bandastation/objects/icons/inhands/hampter_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/inhands/hampter_righthand.dmi'
	inhand_icon_state = "hampter"
	worn_icon = 'modular_bandastation/objects/icons/inhead/head.dmi'
	worn_icon_state = "hampter"
	slot_flags = ITEM_SLOT_HEAD
	w_class = WEIGHT_CLASS_TINY
	COOLDOWN_DECLARE(squeeze_cooldown)

/obj/item/toy/plush/hampter/attack_self(mob/living/carbon/human/user)
	if(!COOLDOWN_FINISHED(src, squeeze_cooldown))
		return
	COOLDOWN_START(src, squeeze_cooldown, 2 SECONDS)
	. = ..()
	if(user.combat_mode == TRUE)
		new /obj/effect/decal/cleanable/blood(get_turf(user))
		user.visible_message(span_warning("[user] раздавил хамптера своей рукой!"), span_warning("Вы с особой жестокостью давите хамптера в своей руке, оставляя от него лишь лужу крови!"))
		qdel(src)

/obj/item/toy/plush/hampter/assistant
	name = "хамптер ассистент"
	desc = "Плюшевый хамптер ассистент. Зачем ему изольки?"
	icon_state = "hampter_ass"
	inhand_icon_state = "hampter_ass"
	worn_icon_state = "hampter_ass"

/obj/item/toy/plush/hampter/security
	name = "хамптер офицер"
	desc = "Плюшевый хамптер офицер службы безопасности. У него станбатон!"
	icon_state = "hampter_sec"
	inhand_icon_state = "hampter_sec"
	worn_icon_state = "hampter_sec"

/obj/item/toy/plush/hampter/medical
	name = "хамптер врач"
	desc = "Плюшевый хамптер врач. Тащите дефибриллятор!"
	icon_state = "hampter_med"
	inhand_icon_state = "hampter_med"
	worn_icon_state = "hampter_med"

/obj/item/toy/plush/hampter/janitor
	name = "хамптер уборщик"
	desc = "Плюшевый хамптер уборщик. Переключись на шаг."
	icon_state = "hampter_jan"
	inhand_icon_state = "hampter_jan"
	worn_icon_state = "hampter_jan"

/obj/item/toy/plush/hampter/old_captain
	name = "хамптер старый капитан"
	desc = "ПЛюшевый хамптер капитан в старой униформе. Это какой год?"
	icon_state = "hampter_old-cap"
	inhand_icon_state = "hampter_old-cap"
	worn_icon_state = "hampter_old-cap"

/obj/item/toy/plush/hampter/captain
	name = "хамптер капитан"
	desc = "Плюшевый хамптер капитан. Где его запасная карта?"
	icon_state = "hampter_cap"
	inhand_icon_state = "hampter_cap"
	worn_icon_state = "hampter_cap"

/obj/item/toy/plush/hampter/syndicate
	name = "хамптер Синдиката"
	desc = "Плюшевый хамптер агент Синдиката. Ваши активы пострадают."
	icon_state = "hampter_sdy"
	inhand_icon_state = "hampter_sdy"
	worn_icon_state = "hampter_sdy"

/obj/item/toy/plush/hampter/deadsquad
	name = "хамптер Дедсквада"
	desc = "Плюшевый хамптер Отряда Смерти. Все контракты расторгнуты."
	icon_state = "hampter_ded"
	inhand_icon_state = "hampter_ded"
	worn_icon_state = "hampter_ded"

/obj/item/toy/plush/hampter/ert
	name = "хамптер ОБР"
	desc = "Плюшевый хамптер ОБР. Доложите о ситуации на станции."
	icon_state = "hampter_ert"
	inhand_icon_state = "hampter_ert"
	worn_icon_state = "hampter_ert"
