/mob/living/basic/ggg/susflash
	name = "suspicious flash"
	desc = "A powerful and versatile flashbulb device, with applications ranging from disorienting attackers to acting as visual receptors in robot production. This one has legs for some reason..."
	icon = 'monkestation/icons/mob/ggg/susflash.dmi'
	icon_state = "flash_living"
	icon_living = "flash_living"
	icon_dead = "flash_dead"
	gender = NEUTER
	//istate = ISTATE_HARM|ISTATE_BLOCKING
	mob_biotypes = MOB_ROBOTIC
	density = FALSE
	pass_flags = PASSTABLE|PASSGRILLE|PASSMOB
	mob_size = MOB_SIZE_TINY
	held_w_class = WEIGHT_CLASS_TINY
	gold_core_spawnable = NO_SPAWN
	can_be_held = FALSE //Will be changed when I make a sprite
	// attacked_sound = ""
	// death_sound = ""

	response_help_continuous = "nuzzles"
	response_help_simple = "nuzzle"
	response_disarm_continuous = "bonks"
	response_disarm_simple = "bonk"

	maxHealth = 25
	health = 25
	melee_damage_lower = 1
	melee_damage_upper = 1
	// speed = 3
	attack_verb_continuous = "spooks"
	attack_verb_simple = "spook"
	attack_vis_effect = ATTACK_EFFECT_SLASH

	speak_emote = list("muffles")
	death_message = "'s head falls off."
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0

	lighting_cutoff_red = 15
	lighting_cutoff_green = 10
	lighting_cutoff_blue = 25

	ai_controller = /datum/ai_controller/basic_controller/mouse

/mob/living/basic/ggg/susflash/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/obj/item/choice_beacon/pet/donator/susflash
	name = "Ordinary Flash Bulb"
	default_name = "suspicious flash"
	company_source = "Saturnian United Systems"
	company_message = "Here is your completely ordinary flash bulb."
	donator_pet = 	/mob/living/basic/ggg/susflash

/datum/loadout_item/pocket_items/donator/susflash
	name = "Pet Delivery Beacon - Ordinary Flash Bulb"
	item_path = /obj/item/choice_beacon/pet/donator/susflash
	donator_only = TRUE
	requires_purchase = FALSE
