/mob/living/silicon/ai/verb/ai_cryo()
	set name = "AI Unload"
	set desc = "Перемещает текущий ИИ на сервер хранения, освобождая место для другого."
	set category = "AI Commands"

	if(incapacitated)
		return

	if(tgui_alert(usr, "Вы точно хотите выгрузиться из ядра ИИ и покинуть раунд?.", "Выгрузиться на сервер хранения", list("Да", "Нет")) != "Да")
		return

	ghostize(FALSE)
	minor_announce("Станционный ИИ был отключён от внутренних систем и был перемещён на хранение. Производится подготовка для загрузки нового ИИ.", "Станционный ИИ")
	new /obj/structure/ai_core/latejoin_inactive(loc)
	if(mind?.assigned_role.title == JOB_AI)
		SSjob.free_job_position(JOB_AI)

	mind.special_roles = null
	qdel(src)
