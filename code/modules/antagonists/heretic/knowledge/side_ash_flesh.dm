// Sidepaths for knowledge between Ash and Flesh.
/datum/heretic_knowledge/ashen_eyes
	name = "Ashen Eyes"
	desc = "Allows you to craft thermal vision amulet by transmutating eyes with a glass shard."
	gain_text = "Piercing eyes guided them through the mundane. Their watch was eternal."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/ashen_shift,
		/datum/heretic_knowledge/flesh_ghoul,
	)
	required_atoms = list(
		/obj/item/organ/eyes = 1,
		/obj/item/shard = 1,
	)
	result_atoms = list(/obj/item/clothing/neck/eldritch_amulet)
	cost = 1

/datum/heretic_knowledge/curse/paralysis
	name = "Curse of Paralysis"
	gain_text = "Corrupt their flesh, make them bleed."
	desc = "Curse someone for 5 minutes of inability to walk. \
		Requires a hatchet, a pool of blood, a leg, a hatchet and an item that the victim touched with their bare hands."
	next_knowledge = list(
		/datum/heretic_knowledge/mad_mask,
		/datum/heretic_knowledge/summon/raw_prophet,
	)
	required_atoms = list(
		/obj/item/bodypart/l_leg = 1,
		/obj/item/bodypart/r_leg = 1,
		/obj/item/hatchet = 1,
	)
	duration = 5 MINUTES
	cost = 1

/datum/heretic_knowledge/summon/ashy
	name = "Ashen Ritual"
	desc = "You can now summon an Ash Man by transmutating a pile of ash, a head and a book."
	gain_text = "I combined my principle of hunger with my desire for destruction. And the Nightwatcher knew my name."
	next_knowledge = list(
		/datum/heretic_knowledge/summon/stalker,
		/datum/heretic_knowledge/spell/flame_birth,
	)
	required_atoms = list(
		/obj/effect/decal/cleanable/ash = 1,
		/obj/item/bodypart/head = 1,
		/obj/item/book = 1,
		)
	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/ash_spirit
	cost = 1
