/mob/living/basic/ggg/glerm
	name = "\improper glerm"
	desc = "A little guy. Seems to be glerming."
	icon = 'monkestation/icons/mob/ggg/glerm.dmi'
	icon_state = "glerm"
	icon_living = "glerm"
	icon_dead = "glerm_dead"

	gender = NEUTER
	mob_biotypes = MOB_ORGANIC
	pass_flags = PASSTABLE|PASSGRILLE|PASSMOB
	mob_size = MOB_SIZE_SMALL
	held_w_class = WEIGHT_CLASS_TINY
	gold_core_spawnable = FRIENDLY_SPAWN
	sight = SEE_SELF|SEE_MOBS|SEE_OBJS|SEE_TURFS

	response_help_continuous = "nuzzles"
	response_help_simple = "nuzzle"
	response_disarm_continuous = "bonks"
	response_disarm_simple = "bonk"
	attack_verb_continuous = "chomps"
	attack_verb_simple = "chomp"
	attack_vis_effect = ATTACK_EFFECT_BITE

	maxHealth = 25
	health = 25

	speak_emote = list("glurps")
	death_message = "stops glerming for good."

	melee_damage_lower = 1
	melee_damage_upper = 1

	ai_controller = /datum/ai_controller/basic_controller/dog

/mob/living/basic/ggg/glerm/cool
	name = "\improper cool glerm"
	desc = "A cool little guy. Seems to be glerming harder than the rest."
	icon = 'monkestation/icons/mob/ggg/glerm.dmi'
	icon_state = "glerm_cool"
	icon_living = "glerm_cool"
	icon_dead = "glerm_cool_dead"
	gold_core_spawnable = NO_SPAWN
	//playsound(src, 'sound/vehicles/skateboard_roll.ogg', 50, TRUE)

/mob/living/basic/ggg/glerm/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/obj/item/choice_beacon/pet/donator/glerm
	name = "Glerm"
	default_name = "Bingus"
	company_source = "Glerm Industries LLC"
	company_message = "Be sure to feed your glerm."
	donator_pet = /mob/living/basic/ggg/glerm

/obj/item/choice_beacon/pet/donator/coolglerm
	name = "Cool Glerm"
	default_name = "Cool Bingus"
	company_source = "Glerm Industries LLC"
	company_message = "Be sure to feed your cool glerm premium glerm food."
	donator_pet = /mob/living/basic/ggg/glerm/cool

/datum/loadout_item/pocket_items/donator/glerm
	name = "Pet Delivery Beacon - Glerm"
	item_path = /obj/item/choice_beacon/pet/donator/glerm
	donator_only = FALSE
	requires_purchase = TRUE

/datum/loadout_item/pocket_items/donator/coolglerm
	name = "Pet Delivery Beacon - Cool Glerm"
	item_path = /obj/item/choice_beacon/pet/donator/coolglerm
	donator_only = TRUE
	requires_purchase = FALSE
