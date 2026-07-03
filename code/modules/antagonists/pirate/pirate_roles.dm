
//space pirates from the pirate event.

/obj/effect/mob_spawn/ghost_role/human/pirate
	name = "space pirate sleeper"
	desc = "A cryo sleeper smelling faintly of rum."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	prompt_name = "a space pirate"
	outfit = /datum/outfit/pirate/space
	anchored = TRUE
	density = FALSE
	show_flavor = FALSE //Flavour only exists for spawners menu
	you_are_text = "Вы — космический пират"
	flavour_text = "От станции поступил отказ в оплате за вашу защиту. Защитите корабль, похитьте кредиты со станции и совершите набег на неё для ещё большей добычи."
	spawner_job_path = /datum/job/space_pirate
	allow_custom_character = GHOSTROLE_TAKE_PREFS_APPEARANCE
	///Rank of the pirate on the ship, it's used in generating pirate names!
	var/rank = "Дезертир"
	///Path of the structure we spawn after creating a pirate.
	var/fluff_spawn = /obj/structure/showcase/machinery/oldpod/used

	//obviously, these pirate name vars are only used if you don't override `generate_pirate_name()`
	///json key to pirate names, the first part ("Comet" in "Cometfish")
	var/name_beginnings = "generic_beginnings"
	///json key to pirate names, the last part ("fish" in "Cometfish")
	var/name_endings = "generic_endings"

/obj/effect/mob_spawn/ghost_role/human/pirate/special(mob/living/spawned_mob, mob/mob_possessor, apply_prefs)
	. = ..()
	spawned_mob.fully_replace_character_name(spawned_mob.real_name, generate_pirate_name(spawned_mob.gender))
	spawned_mob.mind.add_antag_datum(/datum/antagonist/pirate)

/obj/effect/mob_spawn/ghost_role/human/pirate/proc/generate_pirate_name(spawn_gender)
	var/beggings = strings(PIRATE_NAMES_FILE, name_beginnings)
	var/endings = strings(PIRATE_NAMES_FILE, name_endings)
	return "[rank ? rank + " " : ""][pick(beggings)][pick(endings)]"

/obj/effect/mob_spawn/ghost_role/human/pirate/create(mob/mob_possessor, newname, apply_prefs)
	if(fluff_spawn)
		new fluff_spawn(drop_location())
	return ..()

/obj/effect/mob_spawn/ghost_role/human/pirate/captain
	rank = "Лидер ренегатов"
	outfit = /datum/outfit/pirate/space/captain

/obj/effect/mob_spawn/ghost_role/human/pirate/gunner
	rank = "Отступник"

/obj/effect/mob_spawn/ghost_role/human/pirate/skeleton
	name = "pirate remains"
	desc = "Some inanimate bones. They feel like they could spring to life at any moment!"
	density = FALSE
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	prompt_name = "пират-скелет"
	mob_species = /datum/species/skeleton
	outfit = /datum/outfit/pirate
	rank = "Боцман"
	fluff_spawn = null
	allow_custom_character = NONE

/obj/effect/mob_spawn/ghost_role/human/pirate/skeleton/captain
	rank = "Капитан"
	outfit = /datum/outfit/pirate/captain/skeleton

/obj/effect/mob_spawn/ghost_role/human/pirate/skeleton/gunner
	rank = "Канонир"

/obj/effect/mob_spawn/ghost_role/human/pirate/silverscale
	name = "elegant sleeper"
	desc = "Cozy. You get the feeling you aren't supposed to be here, though..."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	prompt_name = "серебрянная чешуя"
	mob_species = /datum/species/lizard/silverscale
	outfit = /datum/outfit/pirate/silverscale
	rank = "Знатного рода"
	allow_custom_character = NONE

/obj/effect/mob_spawn/ghost_role/human/pirate/silverscale/generate_pirate_name(spawn_gender)
	var/first_name
	switch(spawn_gender)
		if(MALE)
			first_name = pick(GLOB.lizard_names_male)
		if(FEMALE)
			first_name = pick(GLOB.lizard_names_female)
		else
			first_name = pick(GLOB.lizard_names_male + GLOB.lizard_names_female)

	return "[rank] [first_name]-Серебрянная чешуя"

/obj/effect/mob_spawn/ghost_role/human/pirate/silverscale/captain
	rank = "Старая гвардия"
	outfit = /datum/outfit/pirate/silverscale/captain

/obj/effect/mob_spawn/ghost_role/human/pirate/silverscale/gunner
	rank = "Первого класса"

/obj/effect/mob_spawn/ghost_role/human/pirate/interdyne
	name = "\improper Interdyne sleeper"
	desc = "A surprisingly clean cryogenic sleeper. You can see your reflection on the sides!"
	density = FALSE
	you_are_text = "Вы — бывший фармацевт Интердайн, а теперь космический пират."
	flavour_text = "Станция отказалась финансировать ваши исследования, так что вы \"убедите\" их пожертвовать свои средства на ваше благородное дело."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	prompt_name = "бывший сотрудник Интердайн"
	outfit = /datum/outfit/pirate/interdyne
	rank = "Фармацевт"

/obj/effect/mob_spawn/ghost_role/human/pirate/interdyne/generate_pirate_name(spawn_gender)
	var/first_name
	switch(spawn_gender)
		if(MALE)
			first_name = pick(GLOB.first_names_male)
		if(FEMALE)
			first_name = pick(GLOB.first_names_female)
		else
			first_name = pick(GLOB.first_names)

	return "[rank] [first_name]"

/obj/effect/mob_spawn/ghost_role/human/pirate/interdyne/senior
	rank = "Директор-фармацевт"
	outfit = /datum/outfit/pirate/interdyne/captain

/obj/effect/mob_spawn/ghost_role/human/pirate/interdyne/junior
	rank = "Фармацевт"

/obj/effect/mob_spawn/ghost_role/human/pirate/grey
	name = "\improper Assistant sleeper"
	desc = "A very dirty cryogenic sleeper. You're not sure if it even works."
	density = FALSE
	you_are_text = "Раньше вы были ассистентом Нанотрейзен, пока один неудачный бунт не изменил всё. Теперь вы странствуете по космосу и грабите любой шаттл, который попадётся на пути!"
	flavour_text = "Нет ничего такого, во что нельзя было бы хорошенько треснуть тулбоксом, чтобы пролить кровь... или, в нашем случае, добыть деньги. Бери всё что захочешь!"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	prompt_name = "ассистент, вышедший из-под контроля"
	outfit = /datum/outfit/pirate/grey
	rank = "Тайдер"

/obj/effect/mob_spawn/ghost_role/human/pirate/grey/shitter
	rank = "Тайд-мастер"

/obj/effect/mob_spawn/ghost_role/human/pirate/irs
	name = "\improper Space IRS sleeper"
	desc = "A surprisingly clean cryogenic sleeper. You can see your reflection on the sides!"
	density = FALSE
	you_are_text = "Вы — агент космической налоговой службы."
	flavour_text = "Даже в бескрайних просторах расширяющейся вселенной никто не скроется от налоговика! Будь вы просто образцовой пиратской бандой или настоящим агентом местного правительства — вы выжмете из станции все до последнего кредита! Мирными средствами или не очень..."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	prompt_name = "Агент космической налоговой службы"
	outfit = /datum/outfit/pirate/irs
	fluff_spawn = null // dirs are fucked and I don't have the energy to deal with it
	rank = "Агент"

/obj/effect/mob_spawn/ghost_role/human/pirate/irs/generate_pirate_name(spawn_gender)
	var/first_name
	switch(spawn_gender)
		if(MALE)
			first_name = pick(GLOB.first_names_male)
		if(FEMALE)
			first_name = pick(GLOB.first_names_female)
		else
			first_name = pick(GLOB.first_names)

	return "[rank] [first_name]"


/obj/effect/mob_spawn/ghost_role/human/pirate/irs/auditor
	rank = "Главный аудитор"
	outfit = /datum/outfit/pirate/irs/auditor

/obj/effect/mob_spawn/ghost_role/human/pirate/lustrous
	name = "lustrous crystal"
	desc = "A crystal housing a mutated Ethereal, it emanates a foreboding glow."
	density = FALSE
	you_are_text = "Когда-то вы были гордым Эфириалом, но теперь от вас осталась лишь жажда драгоценного блюспейс-кристалла."
	flavour_text = "Станция отказала вам в блюспейс-кристаллах — сладкой амброзии пятого измерения. Нанесите удар!"
	icon = 'icons/mob/effects/ethereal_crystal.dmi'
	icon_state = "ethereal_crystal"
	fluff_spawn = null
	prompt_name = "пещерный обитатель"
	mob_species = /datum/species/ethereal/lustrous
	outfit = /datum/outfit/pirate/lustrous
	rank = "Сверкающий"
	allow_custom_character = NONE

/obj/effect/mob_spawn/ghost_role/human/pirate/lustrous/captain
	rank = "Сияющий"
	outfit = /datum/outfit/pirate/lustrous/captain

/obj/effect/mob_spawn/ghost_role/human/pirate/lustrous/gunner
	rank = "Мерцающий"

/obj/effect/mob_spawn/ghost_role/human/pirate/medieval
	name = "\improper Improvised sleeper"
	desc = "A body bag poked with holes, currently being used as a sleeping bag. Someone seems to be sleeping inside of it."
	density = FALSE
	you_are_text = "Раньше вы были никем, пока вам не вручили меч и возможность подняться по рангу. Если приложите усилия, вас ждёт успех!"
	flavour_text = "Грабить кретинов, занимаясь кровавым спортом и насилием? Беспроигрышный вариант. Держитесь вместе и разграбьте всё до нитки!"
	icon = 'icons/obj/medical/bodybag.dmi'
	icon_state = "bodybag"
	fluff_spawn = null
	prompt_name = "средневековый завоеватель"
	outfit = /datum/outfit/pirate/medieval
	rank = "Пехотинец"

/obj/effect/mob_spawn/ghost_role/human/pirate/medieval/special(mob/living/carbon/spawned_mob, mob/mob_possessor, apply_prefs)
	. = ..()
	if(rank == "Пехотинец")
		spawned_mob.add_traits(list(TRAIT_NOGUNS, TRAIT_TOSS_GUN_HARD), INNATE_TRAIT)
		spawned_mob.AddComponent(/datum/component/unbreakable)
		var/datum/action/cooldown/mob_cooldown/dash/dodge = new(spawned_mob)
		dodge.Grant(spawned_mob)

/obj/effect/mob_spawn/ghost_role/human/pirate/medieval/warlord
	rank = "Полководец"
	outfit = /datum/outfit/pirate/medieval/warlord

/obj/effect/mob_spawn/ghost_role/human/pirate/medieval/warlord/special(mob/living/carbon/spawned_mob, mob/mob_possessor, apply_prefs)
	. = ..()
	spawned_mob.dna.add_mutation(/datum/mutation/hulk/superhuman, MUTATION_SOURCE_GHOST_ROLE)
	spawned_mob.dna.add_mutation(/datum/mutation/gigantism, MUTATION_SOURCE_GHOST_ROLE)
