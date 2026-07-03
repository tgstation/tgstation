#define CLOSET_LOCK_PANEL_OPEN 0
#define CLOSET_LOCK_WIRES_DISCONNECTED 1
#define CLOSET_LOCK_HACKED 2

/obj/structure/closet
	var/picklocking_stage

/obj/structure/closet/examine(mob/user)
	. = ..()
	switch(picklocking_stage)
		if(CLOSET_LOCK_PANEL_OPEN)
			. += span_notice("Панель замка снята.")
		if(CLOSET_LOCK_WIRES_DISCONNECTED)
			. += span_notice("Панель замка снята, а провода торчат наружу.")
		if(CLOSET_LOCK_HACKED)
			. += span_notice("Замок полностью взломан.")

/obj/structure/closet/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(!secure)
		return
	if(istype(src, /obj/structure/closet/crate/secure/loot) && !user.combat_mode)
		to_chat(user, span_warning("Панель этого замка приржавела намертво!")) // отмена изичного открытия ящиков с лутом, которого после взлома там и так не будет
		balloon_alert(user, "не поддается!")
		return
	if(locked && picklocking_stage == null && !user.combat_mode)
		to_chat(user, span_notice("Вы начинаете откручивать панель замка [I.declent_ru(INSTRUMENTAL)]..."))
		balloon_alert(user, "снятие панели...")
		if(I.use_tool(src, user, 16 SECONDS, volume = 50))
			if(prob(95))
				broken = TRUE
				picklocking_stage = CLOSET_LOCK_PANEL_OPEN
				update_icon()
				to_chat(user, span_notice("Вы успешно открутили и сняли панель с замка!"))
				balloon_alert(user, "панель снята")
			else
				user.apply_damage(5, BRUTE, user.get_inactive_hand())
				user.emote("scream")
				to_chat(user, span_warning("Проклятье! [capitalize(I.declent_ru(NOMINATIVE))] сорвалась и повредила руку!"))
				balloon_alert(user, "неудача!")
		return TRUE

/obj/structure/closet/wirecutter_act(mob/living/user, obj/item/I)
	. = ..()
	if(locked && picklocking_stage == CLOSET_LOCK_PANEL_OPEN && !user.combat_mode)
		to_chat(user, span_notice("Вы начинаете перерезать провода [I.declent_ru(INSTRUMENTAL)]..."))
		balloon_alert(user, "подготовка проводки...")
		if(I.use_tool(src, user, 16 SECONDS, volume = 50))
			if(prob(80))
				to_chat(user, span_notice("Вы успешно подготовили проводку для взлома!"))
				balloon_alert(user, "проводка подготовлена")
				picklocking_stage = CLOSET_LOCK_WIRES_DISCONNECTED
			else
				to_chat(user, span_warning("Черт! Не тот провод!"))
				balloon_alert(user, "неудача!")
				do_sparks(5, TRUE, src)
				electrocute_mob(user, get_area(src), src, 0.5, TRUE)
		return TRUE

/obj/structure/closet/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	if(locked && picklocking_stage == CLOSET_LOCK_WIRES_DISCONNECTED && !user.combat_mode)
		to_chat(user, span_notice("Вы начинаете подключать [I.declent_ru(NOMINATIVE)] к проводам..."))
		balloon_alert(user, "взлом проводки...")
		if(I.use_tool(src, user, 16 SECONDS, volume = 50))
			if(prob(80))
				broken = FALSE
				picklocking_stage = CLOSET_LOCK_HACKED
				emag_act(user)
			else
				to_chat(user, span_warning("Черт! Не тот провод!"))
				balloon_alert(user, "неудача!")
				do_sparks(5, TRUE, src)
				electrocute_mob(user, get_area(src), src, 0.5, TRUE)
		return TRUE

#undef CLOSET_LOCK_PANEL_OPEN
#undef CLOSET_LOCK_WIRES_DISCONNECTED
#undef CLOSET_LOCK_HACKED
