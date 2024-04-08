/mob/living/basic/cockroach/rockroach
	name = "rockroach"
	desc = "This cockroach has decided to cosplay as a turtle and is carrying a rock shell on it's back."
	icon = 'monkestation/code/modules/slimecore/icons/xenofauna.dmi'
	icon_state = "rockroach"
	health = 15
	maxHealth = 15

/mob/living/basic/cockroach/rockroach/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squashable, squash_chance = 15, squash_damage = 5)
	AddElement(/datum/element/death_drops, list(/obj/item/rockroach_shell))

/obj/item/rockroach_shell
	name = "rockroach shell"
	desc = "A rocky shell of some poor rockroach."
	icon = 'monkestation/code/modules/slimecore/icons/xenofauna.dmi'
	icon_state = "rockroach_shell"
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 2
	throw_range = 7

/mob/living/basic/cockroach/iceroach
	name = "iceroach"
	desc = "This cockroach has decided to cosplay as a turtle and is carrying some ice shards on it's back."
	icon = 'monkestation/code/modules/slimecore/icons/xenofauna.dmi'
	icon_state = "rockroach"
	health = 15
	maxHealth = 15

/mob/living/basic/cockroach/recursive
	name = "recursive roach"
	desc = "I swear I've seen this one before but I can't remember where."
	icon = 'monkestation/code/modules/slimecore/icons/xenofauna.dmi'
	icon_state = "rockroach"
	health = 15
	maxHealth = 15

/mob/living/basic/xenofauna
	desc = "Feed these to the slimes!"
	icon = 'monkestation/code/modules/slimecore/icons/xenofauna.dmi'
	ai_controller = /datum/ai_controller/basic_controller/cockroach
	health = 40
	maxHealth = 40

/mob/living/basic/xenofauna/diyaab
	name = "diyaab"
	icon_state = "diyaab"

/mob/living/basic/xenofauna/lavadog
	name = "lava dog"
	icon_state = "lavadog"

/mob/living/basic/xenofauna/dron
	name = "semi-organic bug"
	icon_state = "dron"

/mob/living/basic/xenofauna/greeblefly
	name = "greeblefly"
	icon_state = "greeblefly"

/mob/living/basic/xenofauna/possum
	name = "possum"
	icon_state = "possum"

/mob/living/basic/xenofauna/thoom
	name = "thoom"
	icon_state = "thoom"

/mob/living/basic/xenofauna/meatbeast
	name = "meat beast"
	icon_state = "meatbeast"

/mob/living/basic/xenofauna/thinbug
	name = "thin bug"
	icon_state = "thinbug"

/mob/living/basic/xenofauna/voxslug
	name = "strange slug"
	icon_state = "voxslug"
