/**
 * # Giant Spider
 *
 * A mob which can be created by dynamic event, botany, or xenobiology.
 * The basic type is the guard, which is slow but sturdy and outputs good damage.
 * All spiders can produce webbing.
 */
/mob/living/basic/giant_spider
	name = "giant spider"
	desc = "Furry and black, it makes you shudder to look at it. This one has deep red eyes."
	icon = 'icons/mob/simple/arachnoid.dmi'
	icon_state = "guard"
	icon_living = "guard"
	icon_dead = "guard_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BUG
	speak_emote = list("chitters")
	butcher_results = list(/obj/item/food/meat/slab/spider = 2, /obj/item/food/spiderleg = 8)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	initial_language_holder = /datum/language_holder/spider
	speed = 5
	maxHealth = 125
	health = 125
	damage_coeff = list(BRUTE = 1, BURN = 1.25, TOX = 1, CLONE = 1, STAMINA = 1, OXY = 1)
	basic_mob_flags = FLAMMABLE_MOB
	status_flags = NONE
	unsuitable_cold_damage = 4
	unsuitable_heat_damage = 4
	obj_damage = 30
	melee_damage_lower = 20
	melee_damage_upper = 25
	combat_mode = TRUE
	faction = list(FACTION_SPIDER)
	pass_flags = PASSTABLE
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	unique_name = TRUE
	gold_core_spawnable = HOSTILE_SPAWN
	// VERY red, to fit the eyes
	lighting_cutoff_red = 22
	lighting_cutoff_green = 5
	lighting_cutoff_blue = 5
	ai_controller = /datum/ai_controller/basic_controller/giant_spider
	/// Speed modifier to apply if controlled by a human player
	var/player_speed_modifier = -4
	/// What reagent the mob injects targets with
	var/poison_type = /datum/reagent/toxin/hunterspider
	/// How much of a reagent the mob injects on attack
	var/poison_per_bite = 0
	/// Multiplier to apply to web laying speed. Fractional numbers make it faster, because it's a multiplier.
	var/web_speed = 1
	/// Type of webbing ability to learn.
	var/web_type = /datum/action/cooldown/lay_web
	/// The message that the mother spider left for this spider when the egg was layed.
	var/directive = ""
	/// Short description of what this mob is capable of, for radial menu uses
	var/menu_description = "Tanky and strong for the defense of the nest and other spiders."
	/// If true then you shouldn't be told that you're a spider antagonist as soon as you are placed into this mob
	var/apply_spider_antag = TRUE

/mob/living/basic/giant_spider/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_WEB_SURFER, INNATE_TRAIT)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)
	AddElement(/datum/element/nerfed_pulling, GLOB.typecache_general_bad_things_to_easily_move)
	AddElement(/datum/element/prevent_attacking_of_types, GLOB.typecache_general_bad_hostile_attack_targets, "this tastes awful!")
	AddElement(/datum/element/cliff_walking)

	if(poison_per_bite)
		AddElement(/datum/element/venomous, poison_type, poison_per_bite)

	var/datum/action/cooldown/lay_web/webbing = new web_type(src)
	webbing.webbing_time *= web_speed
	webbing.Grant(src)
	ai_controller.set_blackboard_key(BB_SPIDER_WEB_ACTION, webbing)

/mob/living/basic/giant_spider/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	GLOB.spidermobs[src] = TRUE
	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/player_spider_modifier, multiplicative_slowdown = player_speed_modifier)
	if (apply_spider_antag)
		var/datum/antagonist/spider/spider_antag = new(directive)
		mind.add_antag_datum(spider_antag)

/mob/living/basic/giant_spider/Logout()
	. = ..()
	remove_movespeed_modifier(/datum/movespeed_modifier/player_spider_modifier)

/mob/living/basic/giant_spider/Destroy()
	GLOB.spidermobs -= src
	return ..()

/mob/living/basic/giant_spider/mob_negates_gravity()
	if(locate(/obj/structure/spider/stickyweb) in loc)
		return TRUE
	return ..()

/mob/living/basic/giant_spider/expose_reagents(list/reagents, datum/reagents/source, methods=TOUCH, volume_modifier=1, show_message=TRUE)
	. = ..()
	for(var/datum/reagent/toxin/pestkiller/current_reagent in reagents)
		apply_damage(50 * volume_modifier, STAMINA, BODY_ZONE_CHEST)
