//==================================//
// !           Cogscarab          ! //
//==================================//
/datum/clockcult/scripture/cogscarab
	name = "Вызвать Мехскарабея"
	desc = "Призовите панцирь Cogscarab, которым будут владеть павшие солдаты Рат'вара. Требуется 2 вызывающих. Длится дольше, чем больше живы cogscarabs. Требуется 20 живучести."
	tip = "Используйте мехскарабеев, чтобы укрепить Риби, в то время как человеческие слуги обращаются и саботируют команду."
	button_icon_state = "Cogscarab"
	power_cost = 500
	vitality_cost = 20
	invokation_time = 120
	invokation_text = list("Мои павшие братья,", "Пришло время подняться", "Защитить нашего господина", "Достичь величия!")
	category = SPELLTYPE_PRESERVATION
	cogs_required = 5
	invokers_required = 2

/datum/clockcult/scripture/cogscarab/begin_invoke(mob/living/M, obj/item/clockwork/clockwork_slab/slab, bypass_unlock_checks)
	invokation_time = 120 + (60 * GLOB.cogscarabs.len)
	if(!is_reebe(M.z))
		to_chat(M, span_warning("Это можно сделать только на Риби!"))
		return
	if(GLOB.cogscarabs.len > 8)
		to_chat(M, span_warning("Не могу призвать больше мехскарабеев."))
		return
	if(GLOB.gateway_opening)
		to_chat(M, span_warning("Слишком поздно, Рат'вар уже идёт!"))
		return
	. = ..()

/datum/clockcult/scripture/cogscarab/invoke_success()
	new /obj/effect/mob_spawn/drone/cogscarab(get_turf(invoker))
