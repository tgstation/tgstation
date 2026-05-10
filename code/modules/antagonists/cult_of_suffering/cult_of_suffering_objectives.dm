/datum/objective/berserk
	name = "berserk"
	explanation_text = "Убивайте всех, кто не под влиянием газа Адиум!"

	check_completion()
		// Минимальная реализация - всегда не завершено для временного антагониста
		return FALSE
