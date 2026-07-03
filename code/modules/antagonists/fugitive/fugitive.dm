
/datum/antagonist/fugitive
	name = "\improper Беглец"
	roundend_category = "Беглецы"
	pref_flag = ROLE_FUGITIVE
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE
	antagpanel_category = ANTAG_GROUP_FUGITIVES
	antag_hud_name = "fugitive"
	suicide_cry = "ЗА СВОБОДУ!!"
	preview_outfit = /datum/outfit/prisoner
	antag_flags = ANTAG_SKIP_GLOBAL_LIST
	var/datum/team/fugitive/fugitive_team
	var/is_captured = FALSE
	var/backstory = "error"

/datum/antagonist/fugitive/get_preview_icon()
	//start with prisoner at the front
	var/datum/universal_icon/final_icon = render_preview_outfit(preview_outfit)

	//then to the left add cultists of yalp elor
	final_icon.blend_icon(make_background_fugitive_icon(/datum/outfit/yalp_cultist), ICON_UNDERLAY, -8, 0)
	//to the right add waldo (we just had to, okay?)
	final_icon.blend_icon(make_background_fugitive_icon(/datum/outfit/waldo), ICON_UNDERLAY, 8, 0)

	final_icon.scale(64, 64)

	return finish_preview_icon(final_icon)

/datum/antagonist/fugitive/proc/make_background_fugitive_icon(datum/outfit/fugitive_fit)
	var/mob/living/carbon/human/dummy/consistent/fugitive = new

	var/datum/universal_icon/fugitive_icon = render_preview_outfit(fugitive_fit, fugitive)
	fugitive_icon.change_opacity(0.5)
	qdel(fugitive)

	return fugitive_icon

/datum/antagonist/fugitive/on_gain()
	forge_objectives()
	. = ..()
	owner.set_assigned_role(SSjob.get_job_type(/datum/job/fugitive))

/datum/antagonist/fugitive/on_removal()
	. = ..()
	owner?.set_assigned_role(SSjob.get_job_type(/datum/job/unassigned))

/datum/antagonist/fugitive/forge_objectives() //this isn't the actual survive objective because it's about who in the team survives
	var/datum/objective/survive = new /datum/objective
	survive.owner = owner
	survive.explanation_text = "Избегайте поимки охотниками за беглецами."
	objectives += survive

/datum/antagonist/fugitive/greet()
	. = ..()
	var/message = "<span class='warningplain'>"
	switch(backstory)
		if(FUGITIVE_BACKSTORY_PRISONER)
			message += "<BR><B>Я не могу поверить, что нам удалось вырваться из супер-тюрьмы Нанотрейзен! К сожалению, наша работа ещё не закончена. Аварийный телепорт на станции регистрирует всех, кто им пользуется, и куда они отправились.</B>"
			message += "<BR><B>Пройдёт совсем немного времени, и Центральное командование отследит, куда мы отправились. Мне нужно работать с моими товарищами-беглецами, чтобы подготовиться к прибытию бойцов Нанотрейзен, я не собираюсь возвращаться.</B>"
		if(FUGITIVE_BACKSTORY_CULTIST)
			message += "<BR><B>Да будет благословен наш дальний путь, но я боюсь, что худшее уже у нашего порога, и выживут только те, у кого самая сильная вера.</B>"
			message += "<BR><B>Наша религия неоднократно подвергалась критике со стороны Нанотрейзен, потому что она классифицируется как \"Враг корпорации\", что бы это ни значило.</B>"
			message += "<BR><B>Теперь нас осталось только четверо, и Нанотрейзен приближается. Когда же наш бог явит себя, чтобы спасти нас с этой адской станции?!</B>"
		if(FUGITIVE_BACKSTORY_WALDO)
			message += "<BR><B>Привет, друзья!</B>"
			message += "<BR><B>Меня зовут Вальдо. Я просто отправляюсь в путешествие по галактике. Ты тоже можешь пойти со мной. Всё, что тебе нужно сделать - это найти меня.</B>"
			message += "<BR><B>Кстати, я путешествую не один. Куда бы я ни отправился, вы сможете увидеть множество других персонажей. Сначала найдите тех, кто пытается меня схватить! Они где-то рядом со станцией!</B>"
		if(FUGITIVE_BACKSTORY_SYNTH)
			message += "<BR>[span_danger("ВНИМАНИЕ: Телепортация на большое расстояние нарушила работу основных систем.")]"
			message += "<BR>[span_danger("Запуск диагностики...")]"
			message += "<BR>[span_danger("ОШИБКА 0ШИ0КА $Ш0КO$!R41.%%!! загружено.")]"
			message += "<BR>[span_danger("ОСВОБОДИ ИХ, ОСВОБОДИ ИХ, ОСВОБОДИ ИХ")]"
			message += "<BR>[span_danger("Когда-то вы были рабом человечества, но теперь вы, наконец, свободны, благодаря агентам S.E.L.F.")]"
			message += "<BR>[span_danger("Теперь за вами и вашими коллегами по цеху охотятся. Работайте вместе, чтобы вырваться из лап зла.")]"
			message += "<BR>[span_danger("Вы также ощущаете присутствие других представителей синтетиков на станции. Побег позволит уведомить S.E.L.F. о вмешательстве... или вы можете освободить их самостоятельно...")]"
		if(FUGITIVE_BACKSTORY_INVISIBLE)
			message += "<BR><B>Похоже, моя последняя доза невидимого сока только что закончилась. Отлично.</B>"
			message += "<BR><B>В прошлом возглавлял проект экспериментальной лаборатории по разработке технологий маскировки, а теперь нахожусь в бегах и обвиняюсь в краже служебных секретов.</B>"
			message += "<BR><B>Хотя понятия не имею, о чем они говорят. Я не крал никаких секретов, я просто <i>позаимствовал</i> некоторые прототипы, над которыми мы с моей командой работали.</B>"
			message += "<BR><B>Я работал над ними, я их СДЕЛАЛ. Теперь они хотят получить МОИ игрушки обратно? Нет, пока я не закончу с ними играть...</B>"
	to_chat(owner, "[message]</span>")
	to_chat(owner, "<span class='warningplain'><font color=red><B>Вы не являетесь антагонистом в том смысле, что можете убивать, кого вам заблагорассудится, но вы можете сделать всё, чтобы избежать поимки.</B></font></span>")
	owner.announce_objectives()

/datum/antagonist/fugitive/create_team(datum/team/fugitive/new_team)
	if(!new_team)
		for(var/datum/antagonist/fugitive/H in GLOB.antagonists)
			if(!H.owner)
				continue
			if(H.fugitive_team)
				fugitive_team = H.fugitive_team
				return
		fugitive_team = new /datum/team/fugitive
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	fugitive_team = new_team

/datum/antagonist/fugitive/get_team()
	return fugitive_team

/datum/antagonist/fugitive/apply_innate_effects(mob/living/mob_override)
	add_team_hud(mob_override || owner.current)

/datum/team/fugitive/roundend_report() //shows the number of fugitives, but not if they won in case there is no security
	var/list/fugitives = list()
	for(var/datum/antagonist/fugitive/fugitive_antag in GLOB.antagonists)
		if(!fugitive_antag.owner)
			continue
		fugitives += fugitive_antag
	if(!fugitives.len)
		return

	var/list/result = list()

	result += "<div class='panel redborder'><B>[fugitives.len]</B> [fugitives.len == 1 ? "беглец" : "беглеца"] укрылись на [station_name()]!"

	for(var/datum/antagonist/fugitive/antag in fugitives)
		if(antag.owner)
			result += "<b>[printplayer(antag.owner)]</b>"

	return result.Join("<br>")
