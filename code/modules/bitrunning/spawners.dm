/obj/effect/mob_spawn/ghost_role/human/virtual_domain
	outfit = /datum/outfit/pirate
	prompt_name = "a virtual domain debug entity"
	flavour_text = "You probably shouldn't be seeing this, contact a coder!"
	you_are_text = "You are NOT supposed to be here. How did you let this happen?"
	important_text = "You must eliminate any bitrunners from the domain."
	temp_body = TRUE

/obj/effect/mob_spawn/ghost_role/human/virtual_domain/Initialize(mapload)
	. = ..()
	notify_ghosts("The [name] has been created. The virtual world calls for aid!", src, "Virtual Insanity!")

/obj/effect/mob_spawn/ghost_role/human/virtual_domain/special(mob/living/spawned_mob, mob/mob_possessor)
	var/datum/mind/ghost_mind = mob_possessor.mind
	if(ghost_mind?.current) // Preserves any previous bodies before making the switch
		spawned_mob.AddComponent(/datum/component/temporary_body, ghost_mind, ghost_mind.current, TRUE)

	..()

	spawned_mob.mind.add_antag_datum(/datum/antagonist/domain_ghost_actor)

/obj/effect/mob_spawn/ghost_role/human/virtual_domain/pirate
	name = "Virtual Pirate Remains"
	desc = "Some inanimate bones. They feel like they could spring to life at any moment!"
	density = FALSE
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	prompt_name = "a virtual skeleton pirate"
	you_are_text = "You are a virtual pirate. Yarrr!"
	flavour_text = "You have awoken, without instruction. There's a LANDLUBBER after yer booty. Stop them!"

/obj/effect/mob_spawn/ghost_role/human/virtual_domain/pirate/special(mob/living/spawned_mob, mob/mob_possessor)
	. = ..()
	spawned_mob.fully_replace_character_name(spawned_mob.real_name, "[pick(strings(PIRATE_NAMES_FILE, "generic_beginnings"))][pick(strings(PIRATE_NAMES_FILE, "generic_endings"))]")

/obj/effect/mob_spawn/ghost_role/human/virtual_domain/syndie
	name = "Virtual Syndicate Sleeper"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	prompt_name = "a virtual syndicate operative"
	you_are_text = "You are a virtual syndicate operative."
	flavour_text = "You have awoken, without instruction. Alarms blare! We are being boarded!"
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

/datum/outfit/virtual_syndicate/post_equip(mob/living/carbon/human/user, visualsOnly)
	user.faction |= ROLE_SYNDICATE
