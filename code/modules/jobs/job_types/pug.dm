/datum/job/pug
	title = JOB_PUG
	description = "Köpek olarak hiç bir sorumluluğunun olmamasinin keyfini yaşa."
	faction = FACTION_STATION
	total_positions = 5
	spawn_positions = 5
	supervisors = "your canine desires." //vicirdek
	selection_color = "#dddddd"
	spawn_type = /mob/living/simple_animal/pet/dog/pug

	departments_list = list(
		/datum/job_department/service,
		)
	random_spawns_possible = FALSE
	job_flags = JOB_NEW_PLAYER_JOINABLE
	rpg_title = "Aç Alfa Gri Kurt"

/datum/job/pug/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	spawned.apply_pref_name(/datum/preference/name/pug, player_client)
