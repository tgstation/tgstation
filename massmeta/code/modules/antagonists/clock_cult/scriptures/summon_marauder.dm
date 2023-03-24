//==================================//
// !           Cogscarab          ! //
//==================================//
/datum/clockcult/scripture/marauder
	name = "Призвать Механического мародёра"
	desc = "Призывает механического мародёра, могущественного воина, способного отражать атаки дальнего боя. Требуется 3 заклинателя и 100 единиц живучести."
	tip = "Используйте механических мародеров в качестве могущественных солдат, которых можно отправить в бой, когда битва станет жесткой."
	button_icon_state = "Clockwork Marauder"
	power_cost = 2000
	vitality_cost = 100
	invokation_time = 300
	invokation_text = list("Через огонь и пламя...", "ничто не затмит Дви'гатель!")
	category = SPELLTYPE_PRESERVATION
	cogs_required = 6
	invokers_required = 3
	var/list/mob/dead/observer/candidates
	var/mob/dead/observer/selected

/datum/clockcult/scripture/marauder/invoke()
	candidates = poll_ghost_candidates("Хочешь стать механическим мародёром?", ROLE_SERVANT_OF_RATVAR, null, 100)
	if(LAZYLEN(candidates))
		selected = pick(candidates)
	if(!selected)
		to_chat(invoker, span_brass("<i>Никто особо и не хочет быть механическим мародёром!</i>"))
		invoke_fail()
		if(invokation_chant_timer)
			deltimer(invokation_chant_timer)
			invokation_chant_timer = null
		end_invoke()
		return
	..()

/datum/clockcult/scripture/marauder/invoke_success()
	var/mob/new_mob = new /mob/living/simple_animal/clockwork_marauder(get_turf(invoker))
	new_mob.key = selected.key
	selected = null
