//==================================//
// !       Abscond       ! //
//==================================//

/datum/clockcult/scripture/abscond
	name = "Бегство"
	desc = "Телепорт на Риби. Если тащить кого-то, то он отправится тоже."
	tip = "Телепорт на Риби. Если тащить кого-то, то он отправится тоже."
	button_icon_state = "Abscond"
	power_cost = 5
	invokation_time = 25
	invokation_text = list("Когда мы прощаемся и возвращаемся к звездам...", "мы найдем дорогу домой.")
	category = SPELLTYPE_SERVITUDE
	var/client_color

/datum/clockcult/scripture/abscond/recital()
	client_color = invoker.client.color
	animate(invoker.client, color = "#AF0AAF", time = invokation_time)
	. = ..()

/datum/clockcult/scripture/abscond/invoke_success()
	var/turf/T = get_turf(pick(GLOB.servant_spawns))
	if(!T)
		to_chat(invoker, span_warning("Error, no valid teleport locations found!"))
	try_warp_servant(invoker, T, TRUE)
	var/prev_alpha = invoker.alpha
	invoker.alpha = 0
	animate(invoker, alpha=prev_alpha, time=10)
	if(invoker.client)
		animate(invoker.client, color = client_color, time = 25)

/datum/clockcult/scripture/abscond/invoke_fail()
	if(invoker?.client)
		animate(invoker.client, color = client_color, time = 10)
