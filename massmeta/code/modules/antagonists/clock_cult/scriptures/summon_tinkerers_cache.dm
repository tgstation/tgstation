//==================================//
// !      Tinkerer's Cache     ! //
//==================================//
/datum/clockcult/scripture/create_structure/tinkerers_cache
	name = "Тайник механика"
	desc = "Создает тайник механика, мощную кузницу, способную создавать элитное снаряжение."
	tip = "Используйте тайник для создания более мощного снаряжения, правда с долгой перезарядкой."
	button_icon_state = "Tinkerer's Cache"
	power_cost = 700
	invokation_time = 50
	invokation_text = list("Направь мою руку, и мы создадим величие.")
	summoned_structure = /obj/structure/destructible/clockwork/gear_base/tinkerers_cache
	cogs_required = 4
	category = SPELLTYPE_STRUCTURES

//===============
//Tinkerer's Cache Structure
//===============

/obj/structure/destructible/clockwork/gear_base/tinkerers_cache
	name = "тайник механика"
	desc = "Бронзовый унитаз, заполненный деталями."
	clockwork_desc = "Бронзовый унитаз, заполненный деталями. Может быть использован для создания мощных предметов Ратвара."
	default_icon_state = "tinkerers_cache"
	anchored = TRUE
	break_message = span_warning("Тайник мастера тает в груду латуни.")
	var/cooldowntime = 0

/obj/structure/destructible/clockwork/gear_base/tinkerers_cache/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!is_servant_of_ratvar(user))
		to_chat(user, span_warning("Пытаюсь засунуть руку в [src], но чуть не обжигаю её!"))
		return
	if(!anchored)
		to_chat(user, span_brass("Стоит прикрутить [src] для начала."))
		return
	if(cooldowntime > world.time)
		to_chat(user, span_brass("[src] всё ещё нагревается, будет готов через [DisplayTimeText(cooldowntime - world.time)]."))
		return
	var/choice = tgui_alert(user,"Начинаю соединять компоненты внутри тайника.",, list("Роба божества","Плащ-покров","Призрачные очки"))
	var/list/pickedtype = list()
	switch(choice)
		if("Роба божества")
			pickedtype += /obj/item/clothing/suit/clockwork/speed
		if("Плащ-покров")
			pickedtype += /obj/item/clothing/suit/clockwork/cloak
		if("Призрачные очки")
			pickedtype += /obj/item/clothing/glasses/clockwork/wraith_spectacles
	if(src && !QDELETED(src) && anchored && pickedtype && Adjacent(user) && !user.incapacitated() && is_servant_of_ratvar(user) && cooldowntime <= world.time)
		cooldowntime = world.time + 2400
		for(var/N in pickedtype)
			new N(get_turf(src))
			to_chat(user, span_brass("Создаю [choice], практически идеальный образец, [src] начинает остывать."))

