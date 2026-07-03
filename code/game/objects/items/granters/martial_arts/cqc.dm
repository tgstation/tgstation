/obj/item/book/granter/martial/cqc
	martial = /datum/martial_art/cqc
	name = "old manual"
	martial_name = "основы CQC"
	desc = "Небольшое чёрное руководство. В ней представлены наглядные инструкции по тактическому рукопашному бою."
	greet = span_bolddanger("Вы освоили основы CQC.")
	icon_state = "cqcmanual"
	remarks = list(
		"Пинок... Бросок...",
		"Захват... Пинок...",
		"Наносите удары по животу, шее и спине, чтобы нанести критический урон...",
		"Бросок... Захват...",
		"Я, наверное, мог бы совместить это с какими-нибудь другими боевыми искусствами! ...Подождите, это же незаконно.",
		"Слова которые убивают...",
		"Последний, завершающий миг ваш...",
	)

/obj/item/book/granter/martial/cqc/on_reading_finished(mob/living/carbon/user)
	. = ..()
	if(uses <= 0)
		to_chat(user, span_warning("[capitalize(src.declent_ru(NOMINATIVE))] зловеще пищит..."))

/obj/item/book/granter/martial/cqc/recoil(mob/living/user)
	to_chat(user, span_warning("[capitalize(src.declent_ru(NOMINATIVE))] взрывается!"))
	playsound(src,'sound/effects/explosion/explosion1.ogg',40,TRUE)
	user.flash_act(1, 1)
	user.adjust_brute_loss(6)
	user.adjust_fire_loss(6)
	qdel(src)
