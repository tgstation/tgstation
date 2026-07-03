//The hunters!!
/datum/antagonist/fugitive_hunter
	name = "Охотник за беглецами"
	roundend_category = "Беглецы"
	silent = TRUE //greet called by the spawn
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE
	antagpanel_category = ANTAG_GROUP_HUNTERS
	antag_hud_name = "fugitive_hunter"
	suicide_cry = "ЗА ЧЕСТЬ!!"
	antag_flags = ANTAG_SKIP_GLOBAL_LIST
	var/datum/team/fugitive_hunters/hunter_team
	var/backstory = "error"

/datum/antagonist/fugitive_hunter/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/fugitive_hunter/forge_objectives() //this isn't an actual objective because it's about round end rosters
	var/datum/objective/capture = new /datum/objective
	capture.owner = owner
	capture.explanation_text = "Захватите беглецов на станции и поместите их в блюспейс устройство захвата на вашем корабле."
	objectives += capture

/datum/antagonist/fugitive_hunter/greet()
	switch(backstory)
		if(HUNTER_PACK_COPS)
			to_chat(owner, span_bolddanger("Правосудие прибыло. Я являюсь членом Космопола!"))
			to_chat(owner, "<B>Преступники должны находиться на станции. У нас установлены специальные импланты ИЛС для их распознавания.</B>")
			to_chat(owner, "<B>Так как мы практически потеряли контроль над этими проклятыми беззаконными мегакорпорациями, остаётся загадкой, будет ли сотрудничать с нами их служба безопасности.</B>")
		if(HUNTER_PACK_RUSSIAN)
			to_chat(owner, span_danger("Ай бля. Я космический русский контрабандист! Мы были в полёте, когда наш груз телепортировали с нашего корабля!"))
			to_chat(owner, span_danger("Нас окликнул мужчина в зелёной форме, пообещавший вернуть наши товары целыми и невредимыми в обмен на услугу:"))
			to_chat(owner, span_danger("на местной станции скрываются беглецы, которых этот человек хочет поймать; живыми или мёртвыми."))
			to_chat(owner, span_danger("Без нашего груза нам не удастся свести концы с концами, поэтому мы вынуждены подчиниться его требованиям и захватить беглецов."))
		if(HUNTER_PACK_BOUNTY)
			to_chat(owner, span_danger("Время приступить к делу. Я охотник за головами! Скоро мы прибудем к укрытию нашей цели."))
			to_chat(owner, span_danger("Разведданные сообщили, что наша цель находится на исследовательской станции. Необычное место для преступника, чтобы залечь на дно."))
			to_chat(owner, span_danger("Наш клиент пообещал нам большие деньги, и мы намерены оправдать ожидания клиента и доставить цель. Надеюсь, эта работа окажется простой и хорошо оплачиваемой..."))
		if(HUNTER_PACK_PSYKER)
			to_chat(owner, span_danger("ДОБРЫЙ ВЕЧЕР, МЫ ПСАЙКЕРЫ ОХОТН... НЕТ, ПСАЙКЕРЫ ШИКАРИ!"))
			to_chat(owner, span_danger("Один мозгляк связался с нами через голографический коммуникатор с предложением, от которого мы не смогли отказаться. Мы похищаем для них кое-кого, а взамен получаем ПОЖИЗНЕННЫЙ ЗАПАС ГОРА."))
			to_chat(owner, span_danger("Запасы гора у нас стали истощаться последнее время - как же мы могли отказать? Пьянка ДОЛЖНА продолжаться!"))
		if(HUNTER_PACK_MI13)
			to_chat(owner, span_danger("Агенты, мы засекли разыскиваемого беглеца в зоне, контролируемой Нанотрейзен."))
			to_chat(owner, span_danger("Ваша задача проста. Проникните на объект и захватите цель - живой или мёртвой."))
			to_chat(owner, span_danger("Это миссия скрытного проникновения на вражескую территорию. Будьте осторожны и постарайтесь избежать обнаружения, если возможно."))

	to_chat(owner, span_bolddanger("Вы не являетесь антагонистом в том смысле, что можете убивать, кого вам заблагорассудится, но вы можете сделать всё, чтобы обеспечить поимку беглецов, даже если для этого придётся пройти через всю станцию."))
	owner.announce_objectives()

/datum/antagonist/fugitive_hunter/create_team(datum/team/fugitive_hunters/new_team)
	if(!new_team)
		for(var/datum/antagonist/fugitive_hunter/H in GLOB.antagonists)
			if(!H.owner)
				continue
			if(H.hunter_team)
				hunter_team = H.hunter_team
				return
		hunter_team = new /datum/team/fugitive_hunters
		hunter_team.backstory = backstory
		hunter_team.update_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	hunter_team = new_team

/datum/antagonist/fugitive_hunter/get_team()
	return hunter_team

/datum/antagonist/fugitive_hunter/apply_innate_effects(mob/living/mob_override)
	add_team_hud(mob_override || owner.current)
	if(backstory == HUNTER_PACK_RUSSIAN)
		var/mob/living/owner_mob = mob_override || owner.current
		owner_mob.grant_language(/datum/language/spinwarder, source = LANGUAGE_BOUNTYHUNTER)
		owner_mob.set_active_language(/datum/language/spinwarder)

/datum/antagonist/fugitive_hunter/remove_innate_effects(mob/living/mob_override)
	var/mob/living/owner_mob = mob_override || owner.current
	owner_mob.remove_language(/datum/language/spinwarder, source = LANGUAGE_BOUNTYHUNTER)

/datum/team/fugitive_hunters
	var/backstory = "error"

/datum/team/fugitive_hunters/proc/update_objectives(initial = FALSE)
	objectives = list()
	var/datum/objective/O = new()
	O.team = src
	objectives += O

/datum/team/fugitive_hunters/proc/assemble_fugitive_results()
	var/list/fugitives_counted = list()
	var/list/fugitives_dead = list()
	var/list/fugitives_captured = list()
	for(var/datum/antagonist/fugitive/A in GLOB.antagonists)
		if(!A.owner)
			stack_trace("Antagonist datum without owner in GLOB.antagonists: [A]")
			continue
		fugitives_counted += A
		if(A.owner.current.stat == DEAD)
			fugitives_dead += A
		if(A.is_captured)
			fugitives_captured += A
	. = list(fugitives_counted, fugitives_dead, fugitives_captured) //okay, check out how cool this is.

/datum/team/fugitive_hunters/proc/all_hunters_dead()
	var/dead_boys = 0
	for(var/I in members)
		var/datum/mind/hunter_mind = I
		if(!(ishuman(hunter_mind.current) || (hunter_mind.current.stat == DEAD)))
			dead_boys++
	return dead_boys >= members.len

/datum/team/fugitive_hunters/proc/get_result()
	var/list/fugitive_results = assemble_fugitive_results()
	var/list/fugitives_counted = fugitive_results[1]
	var/list/fugitives_dead = fugitive_results[2]
	var/list/fugitives_captured = fugitive_results[3]
	var/hunters_dead = all_hunters_dead()
	//this gets a little confusing so follow the comments if it helps
	if(!fugitives_counted.len)
		return
	if(fugitives_captured.len)//any captured
		if(fugitives_captured.len == fugitives_counted.len)//if the hunters captured all the fugitives, there's a couple special wins
			if(!fugitives_dead)//specifically all of the fugitives alive
				return FUGITIVE_RESULT_BADASS_HUNTER
			else if(hunters_dead)//specifically all of the hunters died (while capturing all the fugitives)
				return FUGITIVE_RESULT_POSTMORTEM_HUNTER
			else//no special conditional wins, so just the normal major victory
				return FUGITIVE_RESULT_MAJOR_HUNTER
		else if(!hunters_dead)//so some amount captured, and the hunters survived.
			return FUGITIVE_RESULT_HUNTER_VICTORY
		else//so some amount captured, but NO survivors.
			return FUGITIVE_RESULT_MINOR_HUNTER
	else//from here on out, hunters lost because they did not capture any fugitive dead or alive. there are different levels of getting beat though:
		if(!fugitives_dead)//all fugitives survived
			return FUGITIVE_RESULT_MAJOR_FUGITIVE
		else if(fugitives_dead < fugitives_counted)//at least ANY fugitive lived
			return FUGITIVE_RESULT_FUGITIVE_VICTORY
		else if(!hunters_dead)//all fugitives died, but none were taken in by the hunters. minor win
			return FUGITIVE_RESULT_MINOR_FUGITIVE
		else//all fugitives died, all hunters died, nobody brought back. seems weird to not give fugitives a victory if they managed to kill the hunters but literally no progress to either goal should lead to a nobody wins situation
			return FUGITIVE_RESULT_STALEMATE

/datum/team/fugitive_hunters/roundend_report() //shows the number of fugitives, but not if they won in case there is no security
	if(!members.len)
		return

	var/list/result = list()

	result += "<div class='panel redborder'>...и <B>[members.len]</B> [backstory] пытался выследить их!"

	for(var/datum/mind/M in members)
		result += "<b>[printplayer(M)]</b>"

	switch(get_result())
		if(FUGITIVE_RESULT_BADASS_HUNTER)//use defines
			result += "<span class='greentext big'>Безупречная победа [capitalize(backstory)]!</span>"
			result += "<B>[capitalize(backstory)] захватили всех беглецов живыми!</B>"
		if(FUGITIVE_RESULT_POSTMORTEM_HUNTER)
			result += "<span class='greentext big'>Посмертная победа [capitalize(backstory)]!</span>"
			result += "<B>[capitalize(backstory)] удалось поймать каждого беглеца, но все они погибли! Ужас!</B>"
		if(FUGITIVE_RESULT_MAJOR_HUNTER)
			result += "<span class='greentext big'>Разгромная победа [capitalize(backstory)]</span>"
			result += "<B>[capitalize(backstory)] удалось поймать каждого беглеца, живого или мёртвого.</B>"
		if(FUGITIVE_RESULT_HUNTER_VICTORY)
			result += "<span class='greentext big'>Победа [capitalize(backstory)]</span>"
			result += "<B>[capitalize(backstory)] удалось поймать беглеца, живого или мёртвого.</B>"
		if(FUGITIVE_RESULT_MINOR_HUNTER)
			result += "<span class='greentext big'>Незначительная победа [capitalize(backstory)]</span>"
			result += "<B>Все [capitalize(backstory)] погибли, но им удалось поймать беглеца, живого или мёртвого.</B>"
		if(FUGITIVE_RESULT_STALEMATE)
			result += "<span class='neutraltext big'>Кровавый тупик</span>"
			result += "<B>Все погибли, и никого из беглецов не удалось вернуть.</B>"
		if(FUGITIVE_RESULT_MINOR_FUGITIVE)
			result += "<span class='redtext big'>Незначительная победа беглецов</span>"
			result += "<B>Все беглецы погибли, но ни один из них не был возвращён!</B>"
		if(FUGITIVE_RESULT_FUGITIVE_VICTORY)
			result += "<span class='redtext big'>Победа беглецов</span>"
			result += "<B>Беглец выжил, и ни одно тело не было забрано [capitalize(backstory)].</B>"
		if(FUGITIVE_RESULT_MAJOR_FUGITIVE)
			result += "<span class='redtext big'>Разгромная победа беглецов</span>"
			result += "<B>Все беглецы выжили и избежали поимки!</B>"
		else //get_result returned null- either bugged or no fugitives showed
			result += "<span class='neutraltext big'>Телефонный розыгрыш!</span>"
			result += "<B>[capitalize(backstory)] были вызваны, но беглецов не было...?</B>"

	result += "</div>"

	return result.Join("<br>")
