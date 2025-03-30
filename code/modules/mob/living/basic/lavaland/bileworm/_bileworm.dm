/mob/living/basic/mining/bileworm
	name = "bileworm"
	desc = "Bileworms are dangerous detritivores that attack with the highly acidic bile they produce from consuming detritus."
	icon = 'icons/mob/simple/lavaland/bileworm.dmi'
	icon_state = "bileworm"
	icon_living = "bileworm"
	icon_dead = "bileworm_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BUG|MOB_MINING
	maxHealth = 100
	health = 100
	verb_say = "spittles"
	verb_ask = "spittles questioningly"
	verb_exclaim = "splutters and gurgles"
	verb_yell = "splutters and gurgles"
	crusher_loot = /obj/item/crusher_trophy/bileworm_spewlet
	crusher_drop_chance = 15
	butcher_results = list(/obj/item/food/meat/slab/bugmeat = 4)
	guaranteed_butcher_results = list(
		/obj/effect/gibspawner/generic = 1,
		/obj/item/stack/sheet/animalhide/bileworm = 1,
		/obj/item/stack/ore/gold = 2,
	)
	death_message = "seizes up and falls limp, slowly receeding into its burrow with a dying gurgle..."
	throw_blocked_message = "is absorbed by the spongy hide of"

	//it can't be dragged, just butcher it
	move_resist = INFINITY
	//doesn't melee, at all.
	//or move normally.

	ai_controller = /datum/ai_controller/basic_controller/bileworm

	///which action this mob will be given, subtypes have different attacks
	var/attack_action_path = /datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/bileworm
	///which, if at all, mob this evolves into at the 30 min mark
	var/evolve_path = /mob/living/basic/mining/bileworm/vileworm

/mob/living/basic/mining/bileworm/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, INNATE_TRAIT)

	if(ispath(evolve_path))
		AddComponent(/datum/component/evolutionary_leap, 30 MINUTES, evolve_path)
	AddElement(/datum/element/content_barfer)

	//setup mob abilities

	//well, one of them has to start on infinite cooldown
	var/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/bileworm/spew_bile = new(src)
	spew_bile.Grant(src)
	spew_bile.StartCooldownSelf(INFINITY)
	ai_controller?.set_blackboard_key(BB_BILEWORM_SPEW_BILE, spew_bile)

	var/static/list/other_innate_actions = list(
		/datum/action/adjust_vision/bileworm = null,
		/datum/action/cooldown/mob_cooldown/devour = BB_BILEWORM_DEVOUR,
		/datum/action/cooldown/mob_cooldown/resurface = BB_BILEWORM_RESURFACE,
	)
	grant_actions_by_list(other_innate_actions)
