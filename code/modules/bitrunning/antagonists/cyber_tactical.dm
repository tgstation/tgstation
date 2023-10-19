/datum/antagonist/bitrunning_glitch/cyber_tactical
	name = ROLE_CYBER_TACTICAL
	preview_outfit = /datum/outfit/cyber_police/tactical
	threat = 70

/datum/antagonist/bitrunning_glitch/cyber_tactical/on_gain()
	. = ..()

	if(!ishuman(owner.current))
		stack_trace("humans only for this position")
		return

	var/mob/living/carbon/human/player = owner.current

	player.dress_formal()
	player.equipOutfit(/datum/outfit/cyber_police/tactical)
	player.fully_replace_character_name(player.name, pick(GLOB.cyberauth_names))

/datum/outfit/cyber_police/tactical
	name = ROLE_CYBER_TACTICAL

	back = /obj/item/mod/control/pre_equipped/elite // TODO: make a new one
