// Корги потому что у корги есть код с шапками ОФФов...
/mob/living/basic/pet/dog/corgi/security
	name = "Мухтар"
	real_name = "Мухтар"
	desc = "Верный служебный пес. Он гордо несёт бремя хорошего мальчика."
	icon = 'modular_bandastation/mobs/icons/pets.dmi'
	icon_state = "german_shep"
	icon_living = "german_shep"
	icon_resting = "german_shep_rest"
	icon_dead = "german_shep_dead"
	held_state = "bullterrier"
	health = 100
	maxHealth = 100
	melee_damage_type = STAMINA
	melee_damage_lower = 10
	melee_damage_upper = 25
	butcher_results = list(/obj/item/food/meat/slab/corgi/dog/security = 3)
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/basic/pet/dog/corgi/security/grom
	name = "Майор Гром"
	real_name = "Майор Гром"
	desc = "Талантливый и своенравный пес, который действует по своим правилам, по своему общается с «правильными» людьми, ищет справедливость и не останавливается ни перед чем."
	icon_state = "ranger"
	icon_living = "ranger"
	icon_resting = "ranger_rest"
	icon_dead = "ranger_dead"

/mob/living/basic/pet/dog/corgi/security/warden
	name = "Джульбарс"
	real_name = "Джульбарс"
	desc = "Мудрый служебный пес, названный в честь единственной собаки удостоившийся боевой награды за великолепных нюх и разминирование множество станций."
	icon_state = "german_shep2"
	icon_living = "german_shep2"
	icon_resting = "german_shep2_rest"
	icon_dead = "german_shep2_dead"

/mob/living/basic/pet/dog/corgi/security/detective
	name = "Гав-Гавыч"
	desc = "Старый служебный пёс. Он давно потерял нюх, однако детектив по-прежнему содержит и заботится о нём."
	icon_state = "blackdog"
	icon_living = "blackdog"
	icon_dead = "blackdog_dead"
	icon_resting = "blackdog_rest"
