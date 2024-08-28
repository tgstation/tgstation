/datum/lazy_template/virtual_domain/janitor_work_test
	name = "Janitorial Work: Test"
	desc = "Cremwmeber causing janitorial issues? Teach them how to clean up."
	help_text = "Test domain for janitorial work."
	key = "janitor_work_test"
	map_name = "janitor_work_test"
	bitrunning_network = BITRUNNER_DOMAIN_SECURITY
	forced_outfit = /datum/outfit/job/janitor/prisoner

/datum/lazy_template/virtual_domain/janitor_work_test/setup_domain(list/created_atoms)
	for(var/obj/effect/landmark/bitrunning/bitrunner_spawn/spawner in created_atoms)
		custom_spawns += spawner

/datum/outfit/job/janitor/prisoner
	name = "Janitor (Prisoner)"
	uniform = /obj/item/clothing/under/rank/prisoner
	head = /obj/item/clothing/head/soft/purple
	belt = /obj/item/storage/belt/janitor
	ears = null
	shoes = /obj/item/clothing/shoes/galoshes
	skillchips = null
	backpack_contents = null
