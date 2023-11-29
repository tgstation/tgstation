/datum/job/cargo_gorilla
	title = JOB_CARGO_GORILLA
	description = "Assist the supply department by moving freight and disposing of unwanted fruits."
	department_head = list(JOB_QUARTERMASTER)
	faction = FACTION_STATION
	total_positions = 0
	spawn_positions = 0
	supervisors = SUPERVISOR_QM
	spawn_type = /mob/living/basic/gorilla/cargorilla
	config_tag = "CARGO_GORILLA"
	random_spawns_possible = FALSE
	display_order = JOB_DISPLAY_ORDER_CARGO_GORILLA
	departments_list = list(/datum/job_department/cargo)
	mail_goodies = list(
		/obj/item/food/grown/banana = 1,
	)
	rpg_title = "Bananasmith"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_NEW_PLAYER_JOINABLE | JOB_EQUIP_RANK | JOB_CANNOT_OPEN_SLOTS | JOB_HIDE_WHEN_EMPTY | JOB_LATEJOIN_ONLY

/datum/job/cargo_gorilla/get_roundstart_spawn_point()
	if (length(GLOB.gorilla_start))
		return pick(GLOB.gorilla_start)
	return ..()

/datum/job/cargo_gorilla/get_spawn_mob(client/player_client, atom/spawn_point)
	if (!player_client)
		return
	var/mob/living/the_big_man = new spawn_type(get_turf(spawn_point))
	the_big_man.fully_replace_character_name(the_big_man.real_name, pick(GLOB.cargorilla_names))
	return the_big_man

/datum/job/cargo_gorilla/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	var/obj/item/card/id/advanced/cargo_gorilla/gorilla_id = new(spawned.loc)
	gorilla_id.registered_name = spawned.name
	gorilla_id.update_label()
	spawned.put_in_hands(gorilla_id, del_on_fail = TRUE)

	to_chat(spawned, span_boldnotice("You are Cargorilla, a pacifist friend of the station and carrier of freight."))
	to_chat(spawned, span_notice("You can pick up crates by clicking on them, and drop them by clicking on the ground."))
	spawned.mind.special_role = "Cargorilla"
