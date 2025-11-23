/mob/living/basic/stoat
	name = "stoat"
	desc = "A natural born vermin exterminator... a janitor's best friend."
	icon_state = "stoat"
	icon_living = "stoat"
	icon_dead = "stoat_dead"
	base_icon_state = "stoat"
	icon = 'icons/mob/simple/pets.dmi'
	butcher_results = list(/obj/item/food/meat/slab = 1)
	mob_biotypes = MOB_ORGANIC
	mob_size = MOB_SIZE_SMALL
	pass_flags = PASSTABLE | PASSMOB
	density = FALSE
	health = 40
	maxHealth = 40
	melee_damage_lower = 6
	melee_damage_upper = 9
	response_help_continuous = "pets"
	response_help_simple = "pet"
	verb_say = "chips"
	verb_ask = "chips curiously"
	can_be_held = TRUE
	verb_exclaim = "chips loudly"
	verb_yell = "chips loudly"
	faction = list(FACTION_NEUTRAL)
	ai_controller = /datum/ai_controller/basic_controller/stoat
	///some commands we obey
	var/static/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/move,
		/datum/pet_command/free,
		/datum/pet_command/attack,
		/datum/pet_command/follow,
		/datum/pet_command/fetch,
	)
	//can this mob breed?
	var/can_breed = TRUE

/mob/living/basic/stoat/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	AddElement(/datum/element/tiny_mob_hunter)
	var/static/list/eatable_food = list(
		/obj/item/food/deadmouse,
		/obj/item/food/egg,
	)
	AddComponent(/datum/component/tameable, food_types = eatable_food, tame_chance = 70, bonus_tame_chance = 0)
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, typecacheof(eatable_food))
	AddElement(/datum/element/wears_collar)
	AddComponent(/datum/component/obeys_commands, pet_commands)
	if(can_breed)
		add_breeding_component()

	var/static/list/display_emote = list(
		BB_EMOTE_SAY = list("Chirp chirp chirp!"),
		BB_EMOTE_SEE = list("sweeps its tail!", "jumps around!", "licks its fur!"),
		BB_SPEAK_CHANCE = 2,
		BB_EMOTE_SOUND = list('sound/mobs/non-humanoids/stoat/stoat_sounds.ogg'),
	)
	ai_controller.set_blackboard_key(BB_BASIC_MOB_SPEAK_LINES, display_emote)

/mob/living/basic/stoat/proc/add_breeding_component()
	var/static/list/partner_paths = typecacheof(list(/mob/living/basic/stoat))
	var/static/list/baby_paths = list(
		/mob/living/basic/stoat/kit = 100 // Placeholder until we get proper baby stoats
	)
	AddComponent(\
	/datum/component/breed,\
	can_breed_with = typecacheof(list(/mob/living/basic/stoat)),\
	baby_paths = baby_paths,\
	)

/mob/living/basic/stoat/kit
	name = "\improper stoat kit"
	real_name = "stoat"
	desc = "They're a stoat kit!"
	icon_state = "kit_stoat"
	icon_living = "kit_stoat"
	icon_dead = "kit_stoat_dead"
	density = FALSE
	pass_flags = PASSMOB
	ai_controller = /datum/ai_controller/basic_controller/stoat/kit
	mob_size = MOB_SIZE_SMALL
	can_breed = FALSE
