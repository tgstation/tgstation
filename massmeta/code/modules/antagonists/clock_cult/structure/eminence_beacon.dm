/obj/structure/destructible/clockwork/eminence_beacon
	name = "шпиль Преосвященства"
	desc = "Древний латунный шпиль, в котором заключен дух могущественного существа, созданного Рат'варом для надзора за своими верными слугами."
	icon_state = "tinkerers_daemon"
	resistance_flags = INDESTRUCTIBLE
	var/used = FALSE
	var/vote_active = FALSE
	var/vote_timer

/obj/structure/destructible/clockwork/eminence_beacon/attack_hand(mob/user)
	. = ..()
	if(!is_servant_of_ratvar(user))
		return
	if(vote_active)
		deltimer(vote_timer)
		vote_timer = null
		vote_active = FALSE
		hierophant_message("[user] отменяет голосование Преосвященства.")
		return
	if(used)
		to_chat(user, span_brass("Преосвященство уже здесь."))
		return
	var/option = tgui_alert(user,"Кто должен стать Преосвященством?",,list("Я","Призрак", "Отмена"))
	if(option == "Отмена")
		return
	else if(option == "Я")
		hierophant_message("[user] хочет выбрать себя Преосвященством. Взаимодействовуйте с [src] для отмены.", span="<span=large_brass>")
		vote_timer = addtimer(CALLBACK(src, PROC_REF(vote_succeed), user), 600, TIMER_STOPPABLE)
	else if(option == "Призрак")
		hierophant_message("[user] хочет призрак в качестве Преосвященства. Взаимодействовуйте с [src] для отмены.")
		vote_timer = addtimer(CALLBACK(src, PROC_REF(vote_succeed)), 600, TIMER_STOPPABLE)
	vote_active = TRUE

/obj/structure/destructible/clockwork/eminence_beacon/proc/vote_succeed(mob/eminence)
	vote_active = FALSE
	used = TRUE
	if(!eminence)
		var/list/mob/dead/observer/candidates = poll_ghost_candidates("Хотите стать Преосвященством?", ROLE_SERVANT_OF_RATVAR, null, 100, POLL_IGNORE_PYROSLIME)
		if(LAZYLEN(candidates))
			eminence = pick(candidates)
	if(!(eminence?.client))
		hierophant_message("Преосвященство слишком занята делами, попробуйте позже.")
		used = FALSE
		return
	var/mob/new_mob = new /mob/living/simple_animal/eminence(get_turf(src))
	new_mob.key = eminence.key
	hierophant_message("Встречайте её Преосвященство!")
