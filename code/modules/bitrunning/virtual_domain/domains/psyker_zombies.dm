/datum/lazy_template/virtual_domain/psyker_zombies
	name = "Зараженный домен"
	cost = BITRUNNER_COST_MEDIUM
	desc = "Еще один заброшенный уголок виртуального мира. Этот мир был заброшен из-за зомби-вируса. \
		Внимание - виртуальный домен не поддерживает визуальное отображение и использует эхолокацию."
	difficulty = BITRUNNER_DIFFICULTY_MEDIUM
	completion_loot = list(/obj/item/radio/headset/psyker = 1) //Looks cool, might make your local burdened chaplain happy.
	forced_outfit = /datum/outfit/echolocator
	help_text = "Этот некогда любимый виртуальный домен был поврежден вирусом, в результате чего он стал нестабильным, полным дыр и ЗОМБИ! \
		Поблизости где-то должен быть Загадочный ящик, который поможет вам вооружиться. Вооружитесь и закончите начатое киберполицией!"
	key = "psyker_zombies"
	map_name = "psyker_zombies"
	reward_points = BITRUNNER_REWARD_HIGH
