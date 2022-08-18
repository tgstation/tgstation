/mob/living/basic/bileworm
	name = "bileworm"
	desc = "Bileworms are dangerous detritivores that attack with the highly acidic bile they produce from consuming detritus."
	icon = 'icons/mob/simplemob/lavaland/bileworm.dmi'
	icon_state = "bileworm"
	icon_living = "bileworm"
	icon_dead = "bileworm_dead"
	mob_size = MOB_SIZE_LARGE
	mob_biotypes = MOB_BUG
	maxHealth = 150
	health = 150
	verb_say = "spittles"
	verb_ask = "spittles questioningly"
	verb_exclaim = "splutters and gurgles"
	verb_yell = "splutters and gurgles"
	butcher_results = list(/obj/item/food/meat/slab/bugmeat = 4)
	guaranteed_butcher_results = list(
		/obj/effect/gibspawner/generic = 1,
		/obj/item/stack/sheet/animalhide/bileworm = 1,
	)
	death_message = "seizes up and falls limp, slowly receeding into its burrow with a dying gurgle..."

	//it can't be dragged, just butcher it
	move_resist = INFINITY
	//doesn't melee, at all.
	//or move normally.

	combat_mode = TRUE
	faction = list("mining")

	ai_controller = /datum/ai_controller/basic_controller/bileworm

/mob/living/basic/bileworm/Initialize(mapload)
	. = ..()
	//traits and elements

	ADD_TRAIT(src, TRAIT_IMMOBILIZED, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_LAVA_IMMUNE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_ASHSTORM_IMMUNE, INNATE_TRAIT)
	AddElement(/datum/element/basic_body_temp_sensitive, max_body_temp = INFINITY)
	AddElement(/datum/element/crusher_loot, /obj/item/crusher_trophy/bileworm_spewlet, 15)
	AddElement(/datum/element/mob_killed_tally, "mobs_killed_mining")
	AddElement(/datum/element/content_barfer)

	//setup mob abilities

	var/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/bileworm/spew_bile = new(src)
	spew_bile.Grant(src)
	//well, one of them has to start on infinite cooldown
	spew_bile.StartCooldownSelf(INFINITY)
	var/datum/action/cooldown/mob_cooldown/resurface/resurface = new(src)
	resurface.Grant(src)
	var/datum/action/cooldown/mob_cooldown/devour/devour = new(src)
	devour.Grant(src)
	var/datum/action/adjust_vision/adjust_vision = new(src)
	adjust_vision.Grant(src)
	ai_controller.blackboard[BB_BILEWORM_SPEW_BILE] = spew_bile
	ai_controller.blackboard[BB_BILEWORM_RESURFACE] = resurface
	ai_controller.blackboard[BB_BILEWORM_DEVOUR] = devour
