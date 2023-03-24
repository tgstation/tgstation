/datum/objective/clockcult
	name = "служить Рат'вару"
	explanation_text = "Защитите Небесные врата, чтобы Рат'вар мог просветить этот мир!"

/datum/objective/clockcult/check_completion()
	return GLOB.ratvar_risen
