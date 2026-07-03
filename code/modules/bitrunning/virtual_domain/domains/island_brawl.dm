/datum/lazy_template/virtual_domain/island_brawl
	name = "Островная потасовка"
	announce_to_ghosts = TRUE
	cost = BITRUNNER_COST_HIGH
	desc = "Мирный остров, спрятанный в Богом забытом месте.. Этот уровень будет автоматически завершен после того, как произойдет некоторое количесво смертей."
	difficulty = BITRUNNER_DIFFICULTY_HIGH
	forced_outfit = /datum/outfit/beachbum_combat
	help_text = "По всему острову могут быть назначены награды, но главная цель - выжить. Смерти на острове будут засчитаны в итоговый счет."
	key = "island_brawl"
	map_name = "island_brawl"
	reward_points = BITRUNNER_REWARD_HIGH
	secondary_loot = list(
		/obj/item/toy/beach_ball = 2,
		/obj/item/clothing/shoes/sandal = 1,
		/obj/item/clothing/glasses/sunglasses = 1,
		/obj/item/gun/energy/laser/chameleon/ballistic_only = 1,
		/obj/item/disk/bitrunning/item/mini_uzi = 1,
	)

/datum/lazy_template/virtual_domain/island_brawl/setup_domain(list/created_atoms)
	for(var/obj/effect/mob_spawn/ghost_role/human/virtual_domain/islander/spawner in created_atoms)
		custom_spawns += spawner

		RegisterSignal(spawner, COMSIG_QDELETING, PROC_REF(on_spawner_qdeleted))
		RegisterSignals(spawner, list(COMSIG_GHOSTROLE_SPAWNED, COMSIG_BITRUNNER_SPAWNED), PROC_REF(on_spawn))


/datum/lazy_template/virtual_domain/island_brawl/proc/on_spawner_qdeleted(obj/effect/mob_spawn/ghost_role/human/virtual_domain/islander/source)
	SIGNAL_HANDLER

	custom_spawns -= source
	UnregisterSignal(source, COMSIG_QDELETING)


/// Someone has spawned in, so we check for their death
/datum/lazy_template/virtual_domain/island_brawl/proc/on_spawn(datum/source, mob/living/spawned_mob)
	SIGNAL_HANDLER

	RegisterSignals(spawned_mob, list(COMSIG_LIVING_DEATH), PROC_REF(on_death))


/// Mob has died, so we add a point to the domain
/datum/lazy_template/virtual_domain/island_brawl/proc/on_death(datum/source, gibbed)
	SIGNAL_HANDLER

	add_points(1)


/obj/effect/mob_spawn/ghost_role/human/virtual_domain/islander
	name = "Islander"
	outfit = /datum/outfit/beachbum_combat
	prompt_name = "пляжный боевой бомж"
	you_are_text = "Вы - виртуальный островитянин."
	flavour_text = "Не позволяйте никому разрушить ваше идеальное место для отдыха. Договаривайтесь с другими... или нет!"
