/datum/antagonist/bitrunning_glitch/cyber_police
	name = ROLE_CYBER_POLICE

/datum/antagonist/bitrunning_glitch/cyber_police/on_gain()
	. = ..()

	if(!ishuman(owner.current))
		stack_trace("humans only for this position")
		return

	var/mob/living/carbon/human/player = owner.current

	player.equipOutfit(/datum/outfit/bitrunning_glitch/cyber_police)
	player.fully_replace_character_name(player.name, pick(GLOB.cyberauth_names))

	var/datum/martial_art/the_sleeping_carp/carp = new()
	carp.teach(player)

/datum/outfit/bitrunning_glitch/cyber_police
	name = ROLE_CYBER_POLICE
	glasses = /obj/item/clothing/glasses/sunglasses
	shoes = /obj/item/clothing/shoes/laceup
