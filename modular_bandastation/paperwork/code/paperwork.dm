GLOBAL_LIST_INIT_TYPED(paper_replacements, /datum/paper_replacement, init_paper_replacements())

/proc/init_paper_replacements()
	var/list/paper_replacements = list()
	for(var/paper_replacement_type in subtypesof(/datum/paper_replacement))
		var/datum/paper_replacement/paper_replacement = new paper_replacement_type()
		paper_replacements[paper_replacement.key] = paper_replacement
	return paper_replacements

/proc/replace_text_keys(raw_text, mob/user)
	var/regex/key_regex = new(@"\[(\w+)\]","gm")

	var/result = raw_text
	while(key_regex.Find(result))
		var/matched_text = key_regex.match
		var/datum/paper_replacement/replacement = GLOB.paper_replacements[key_regex.group[1]]
		if(!replacement)
			continue

		var/replacement_text = replacement.get_replacement(user)
		result = splicetext(result, key_regex.index, key_regex.index + length(matched_text), replacement_text)

	return result


/datum/paper_replacement
	var/key = null
	var/name = "Undentified"

/datum/paper_replacement/proc/get_replacement(mob/user)
	CRASH("Paper replacement get_replacement not implemented.")

/datum/paper_replacement/name
	key = "name"
	name = "Имя"

/datum/paper_replacement/name/get_replacement(mob/user)
	return user.real_name || "неизвестный"

/datum/paper_replacement/age
	key = "age"
	name = "Возраст"

/datum/paper_replacement/age/get_replacement(mob/user)
	if(!ishuman(user))
		return "неизвестный"

	var/mob/living/carbon/human/human_user = user
	return isnull(human_user.age) ? "неизвестный" : human_user.age

/datum/paper_replacement/sign
	key = "sign"
	name = "Подпись"

/datum/paper_replacement/sign/get_replacement(mob/user)
	return "<font face=\"[SIGNATURE_FONT]\"><i>[user.real_name || "неизвестный"]</i></font>"

/datum/paper_replacement/time
	key = "time"
	name = "Текущее время"

/datum/paper_replacement/time/get_replacement(mob/user)
	return server_timestamp()

/datum/paper_replacement/date
	key = "date"
	name = "Текущая дата"

/datum/paper_replacement/date/get_replacement(mob/user)
	return "[time2text(world.timeofday, "DD/MM")]/[CURRENT_STATION_YEAR]"

/datum/paper_replacement/datetime
	key = "datetime"
	name = "Текущая дата и время"

/datum/paper_replacement/datetime/get_replacement(mob/user)
	return "[time2text(world.timeofday, "DD/MM")]/[CURRENT_STATION_YEAR] [server_timestamp()]"

/datum/paper_replacement/station_name
	key = "station_name"
	name = "Название станции"

/datum/paper_replacement/station_name/get_replacement(mob/user)
	return station_name()

/datum/paper_replacement/bank_id
	key = "bank_id"
	name = "Номер банковского счета"

/datum/paper_replacement/bank_id/get_replacement(mob/user)
	var/datum/memory/key/account/user_key = user?.mind?.memories?[/datum/memory/key/account]
	return isnull(user_key?.remembered_id) ? "отсутствует" : "[user_key.remembered_id]"

/datum/paper_replacement/job
	key = "job"
	name = "Должность"

/datum/paper_replacement/job/get_replacement(mob/user)
	if(!ishuman(user))
		return "отсутствует"

	var/mob/living/carbon/human/human_user = user
	var/job = human_user.get_assignment(if_no_id = null, if_no_job = null) || human_user?.mind?.assigned_role?.title

	return isnull(job) ? "отсутствует" : job_title_ru(job)

/datum/paper_replacement/department
	key = "department"
	name = "Отдел"

/datum/paper_replacement/department/get_replacement(mob/user)
	if(!ishuman(user))
		return "отсутствует"

	var/mob/living/carbon/human/human_user = user
	var/job = human_user.get_assignment(if_no_id = null, if_no_job = null) || human_user?.mind?.assigned_role?.title

	var/datum/job/user_job = SSjob.get_job(job)
	if(isnull(user_job))
		return "отсутствует"

	var/datum/job_department/department_type = user_job.department_for_prefs || user_job.departments_list?[1]
	return department_type::department_name || "отсутствует"

/datum/paper_replacement/species
	key = "species"
	name = "Раса"

/datum/paper_replacement/species/get_replacement(mob/user)
	if(!iscarbon(user))
		return "неизвестная"

	var/mob/living/carbon/carbon = user
	return isnull(carbon?.dna.species) ? "неизвестная" : carbon.dna.species.name

/datum/paper_replacement/gender
	key = "gender"
	name = "Пол"

/datum/paper_replacement/gender/get_replacement(mob/user)
	return istype(user) ? user.gender : "неизвестный"
