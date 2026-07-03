/obj/effect/mob_spawn/ghost_role/human/virtual_domain
	outfit = /datum/outfit/virtual_pirate
	prompt_name = "a virtual domain debug entity"
	flavour_text = "Вам, наверное, не стоит этого видеть, обратитесь к администратору или программисту!"
	you_are_text = "Тебя не должно было здесь быть. Как ты вообще умудрился?"
	important_text = "Битраннинг - это преступление и ваша прямая угроза."
	temp_body = TRUE
	///Does this bit-entity get an antag datum with the goal of hunting bitrunners? TRUE by default
	var/antag = TRUE


/obj/effect/mob_spawn/ghost_role/human/virtual_domain/special(mob/living/spawned_mob, mob/mob_possessor, apply_prefs)
	var/datum/mind/ghost_mind = mob_possessor.mind
	if(ghost_mind) // Preserves any previous bodies before making the switch
		spawned_mob.AddComponent(/datum/component/temporary_body, ghost_mind, return_on_death = TRUE)

	..()

	if(antag)
		spawned_mob.mind.add_antag_datum(/datum/antagonist/domain_ghost_actor)
		spawned_mob.mind.set_assigned_role(SSjob.get_job_type(/datum/job/bitrunning_glitch))

/// Simulates a ghost role spawn without calling special(), ie a bitrunner spawn instead of a ghost.
/obj/effect/mob_spawn/ghost_role/human/virtual_domain/proc/artificial_spawn(mob/living/runner)
	SEND_SIGNAL(src, COMSIG_BITRUNNER_SPAWNED, runner)

//Beach Bums (Friendly)
/obj/effect/mob_spawn/ghost_role/human/virtual_domain/beach
	prompt_name = "a virtual beach bum"
	name = "virtual beach bum sleeper"
	you_are_text = "Ты, типа, полностью виртуальная имитация чувака, братан."
	flavour_text = "Привет. Ты приехал сюда, типа, на весенние каникулы, надеясь подцепить парочку классных электронных цыпочек, сечёшь?"
	important_text = "У вас не возникнет проблем с битраном: на самом деле, вы даже не осознаете, что находитесь в симуляции."
	outfit = /datum/outfit/beachbum
	spawner_job_path = /datum/job/beach_bum
	antag = FALSE
	allow_custom_character = GHOSTROLE_TAKE_PREFS_APPEARANCE

/obj/effect/mob_spawn/ghost_role/human/virtual_domain/beach/lifeguard
	name = "virtual lifeguard sleeper"
	you_are_text = "Вы - отважный виртуальный спасатель!"
	flavour_text = "От вас зависит, чтобы никто не зависал и не был съеден вредоносными программами и прочим."
	outfit = /datum/outfit/beachbum/lifeguard
	allow_custom_character = NONE

/obj/effect/mob_spawn/ghost_role/human/virtual_domain/beach/lifeguard/special(mob/living/carbon/human/lifeguard, mob/mob_possessor, apply_prefs)
	. = ..()
	lifeguard.gender = FEMALE
	lifeguard.update_body()

/obj/effect/mob_spawn/ghost_role/human/virtual_domain/beach/bartender
	name = "virtual bartender sleeper"
	you_are_text = "Вы - виртуальный пляжный бармен!"
	flavour_text = "Ваша задача - обеспечить поступление виртуально приготовленных напитков и помочь чувакам имитировать опьянение."
	outfit = /datum/outfit/spacebartender
	allow_custom_character = ALL

//Skeleton Pirates
/obj/effect/mob_spawn/ghost_role/human/virtual_domain/pirate
	name = "Virtual Pirate Remains"
	desc = "Какие-то неодушевленные кости. Кажется, что они могут ожить в любой момент!"
	density = FALSE
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	prompt_name = "a virtual skeleton pirate"
	you_are_text = "Ты - виртуальный пират. Яррр!"
	flavour_text = "Какая-то СУХОПУТНАЯ КРЫСА охотится за вашими сокровищами. Остановите их!"

/datum/outfit/virtual_pirate
	name = "Virtual Pirate"
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/pirate
	uniform = /obj/item/clothing/under/costume/pirate
	suit = /obj/item/clothing/suit/costume/pirate/armored
	glasses = /obj/item/clothing/glasses/eyepatch
	head = /obj/item/clothing/head/costume/pirate/bandana/armored
	shoes = /obj/item/clothing/shoes/pirate/armored

/obj/effect/mob_spawn/ghost_role/human/virtual_domain/pirate/special(mob/living/spawned_mob, mob/mob_possessor, apply_prefs)
	. = ..()
	spawned_mob.fully_replace_character_name(spawned_mob.real_name, "[pick(strings(PIRATE_NAMES_FILE, "generic_beginnings"))][pick(strings(PIRATE_NAMES_FILE, "generic_endings"))]")

//Syndicate
/obj/effect/mob_spawn/ghost_role/human/virtual_domain/syndie
	name = "Virtual Syndicate Sleeper"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	prompt_name = "a virtual syndicate operative"
	you_are_text = "Вы - виртуальный оперативник Синдиката."
	flavour_text = "Ревут сигналы тревоги! Нас берут на абордаж!"
	outfit = /datum/outfit/virtual_syndicate
	spawner_job_path = /datum/job/space_syndicate

/datum/outfit/virtual_syndicate
	name = "Virtual Syndie"
	id = /obj/item/card/id/advanced/chameleon
	id_trim = /datum/id_trim/chameleon/operative
	uniform = /obj/item/clothing/under/syndicate
	back = /obj/item/storage/backpack
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	shoes = /obj/item/clothing/shoes/combat
	implants = list(/obj/item/implant/weapons_auth)

/datum/outfit/virtual_syndicate/post_equip(mob/living/carbon/human/user, visuals_only)
	user.add_faction(ROLE_SYNDICATE)
