/mob/living/basic/mouse/rat/maddie
	name = "maddie"
	desc = "what do you mean they made her real"
	gold_core_spawnable = FRIENDLY_SPAWN
	melee_damage_lower = 1
	melee_damage_upper = 2
	obj_damage = 2
	maxHealth = 200
	health = 300
	icon = 'troutstation/icons/mob/simple/animal.dmi'
	body_color = "maddie"
	squeaks = list('troutstation/sound/items/toy_squeak/mrdSqueak.ogg' = 1)
	squeak_volume = 35
	gender = FEMALE

	ai_controller = /datum/ai_controller/basic_controller/mouse

/datum/emote/mouse/squeak/maddie
	mob_type_allowed_typecache = /mob/living/basic/mouse/rat/maddie
	key = "msqueak"
	key_third_person = "msqueaks"
	message = "squeaks!"
	sound = 'troutstation/sound/items/toy_squeak/mrdSqueak.ogg'
