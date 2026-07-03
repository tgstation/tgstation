/datum/objective/revenant

/datum/objective/revenant/New()
	target_amount = rand(350, 600)
	explanation_text = "Поглотите [target_amount] очков эссенции с гуманоидов."
	return ..()

/datum/objective/revenant/check_completion()
	if(!isrevenant(owner.current))
		return FALSE
	var/mob/living/basic/revenant/owner_mob = owner.current
	if(QDELETED(owner_mob) || owner_mob.stat == DEAD)
		return FALSE
	var/essence_stolen = owner_mob.essence_accumulated
	return essence_stolen >= target_amount

/datum/objective/revenant_fluff

/datum/objective/revenant_fluff/New()
	var/list/explanation_texts = list(
		"Помогайте существующим угрозам и усугубляйте их в критические моменты.",
		"Вызывайте как можно больше хаоса и гнева, избегая смерти.",
		"Повреждайте и приводите в негодность как можно больше оборудования станции.",
		"Выводите из строя и вызывайте сбои в работе как можно большего числа машин.",
		"Убедитесь, что любое святое оружие стало непригодным для использования.",
		"Прислушивайтесь к просьбам мёртвых и выполняйте их, если это не слишком неудобно или не ведёт к самоуничтожению.",
		"Выдавайте себя за Бога или добивайтесь поклонения себе как Божеству.",
		"Доставляйте капитану как можно больше страданий.",
		"Доставляйте клоуну как можно больше страданий.",
		"Доставляйте экипажу как можно больше страданий.",
		"По возможности предотвращайте использование энергетического оружия.",
	)
	if(SSjob.assigned_captain)
		explanation_texts += "Make the captain as miserable as possible."
	var/datum/job/clown/clown_job = SSjob.get_job(JOB_CLOWN)
	if(clown_job.current_positions)
		explanation_texts += "Make the clown as miserable as possible."
	explanation_text = pick(explanation_texts)
	return ..()

/datum/objective/revenant_fluff/check_completion()
	return TRUE
