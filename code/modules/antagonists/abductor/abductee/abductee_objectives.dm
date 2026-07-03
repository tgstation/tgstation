/datum/objective/abductee
	completed = 1

/datum/objective/abductee/random

/datum/objective/abductee/random/New()
	explanation_text = pick(world.file2list("strings/abductee_objectives.txt"))

/datum/objective/abductee/steal
	explanation_text = "Украдите"

/datum/objective/abductee/steal/New()
	var/target = pick(list("всех животных", "все лампочки", "всех обезьян", "все фрукты", "все ботинки", "всё мыло", "всё оружие", "всю технику", "все органы"))
	explanation_text+=" [target]."

/datum/objective/abductee/paint
	explanation_text = "Эта станция ужасна. Вы должны разукрасить её"

/datum/objective/abductee/paint/New()
	var/color = pick(list("красным цветом", "голубым цветом", "зеленым цветом", "желтым цветом", "оранжевым цветом", "розовым цветом", "черным цветом", "разноцветным", "кровью"))
	explanation_text+= " [color]!"

/datum/objective/abductee/speech
	explanation_text = "Ваш мозг сломлен... Вы можете общаться только"

/datum/objective/abductee/speech/New()
	var/style = pick(list("пантомимой", "рифмами", "хайку", "длинными метафорами", "загадками", "буквальными значениями слов", "звуковыми эффектами", "военным жаргоном", "предложениями из трех слов"))
	explanation_text+= " [style]."

/datum/objective/abductee/capture
	explanation_text = "Захватите"

/datum/objective/abductee/capture/New()
	var/list/jobs = SSjob.joinable_occupations.Copy()
	for(var/datum/job/job as anything in jobs)
		if(job.current_positions < 1)
			jobs -= job
	if(length(jobs) > 0)
		var/datum/job/target = pick(jobs)
		explanation_text += " [target.title]."
	else
		explanation_text += " кого-нибудь."

/datum/objective/abductee/calling/New()
	var/mob/dead/D = pick(GLOB.dead_mob_list)
	if(D)
		explanation_text = "Вы знаете, что [D] погиб[genderize_ru(D.gender, "", "ла", "ло", "ли")]. Проведите спиритический сеанс, чтобы призвать [D.ru_p_them()] из мира духов."

/datum/objective/abductee/forbiddennumber

/datum/objective/abductee/forbiddennumber/New()
	var/number = rand(2,10)
	explanation_text = "Игнорируйте группы предметов из [number] штук, их не существует."
