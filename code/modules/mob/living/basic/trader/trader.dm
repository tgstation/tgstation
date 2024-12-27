/mob/living/basic/trader
	name = "Trader"
	desc = "Come buy some!"
	unique_name = FALSE
	icon = 'icons/mob/simple/simple_human.dmi'
	maxHealth = 200
	health = 200
	melee_damage_lower = 10
	melee_damage_upper = 10
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	attack_sound = 'sound/items/weapons/punch1.ogg'
	basic_mob_flags = DEL_ON_DEATH
	unsuitable_atmos_damage = 2.5
	combat_mode = FALSE
	move_resist = MOVE_FORCE_STRONG
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_HUMANOID
	speed = 0

	ai_controller = /datum/ai_controller/basic_controller/trader

	///Sound used when item sold/bought
	var/sell_sound = 'sound/effects/cashregister.ogg'
	///The currency name
	var/currency_name = "credits"
	///The spawner we use to create our look
	var/spawner_path = /obj/effect/mob_spawn/corpse/human/generic_assistant
	///Our species to create our look
	var/species_path = /datum/species/human
	///The loot we drop when we die
	var/loot = list(/obj/effect/mob_spawn/corpse/human/generic_assistant)
	///Casing used to shoot during retaliation
	var/ranged_attack_casing = /obj/item/ammo_casing/shotgun/buckshot
	///Sound to make while doing a retalitory attack
	var/ranged_attack_sound = 'sound/items/weapons/gun/pistol/shot.ogg'
	///Weapon path, for visuals
	var/held_weapon_visual = /obj/item/gun/ballistic/shotgun

	///Type path for the trader datum to use for retrieving the traders wares, speech, etc
	var/trader_data_path = /datum/trader_data


/mob/living/basic/trader/Initialize(mapload)
	. = ..()
	apply_dynamic_human_appearance(src, species_path = species_path, mob_spawn_path = spawner_path, r_hand = held_weapon_visual)

	var/datum/trader_data/trader_data = new trader_data_path
	AddComponent(/datum/component/trader, trader_data = trader_data)
	AddComponent(/datum/component/ranged_attacks, casing_type = ranged_attack_casing, projectile_sound = ranged_attack_sound, cooldown_time = 3 SECONDS)
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/ai_swap_combat_mode, BB_BASIC_MOB_CURRENT_TARGET, string_list(trader_data.say_phrases[TRADER_BATTLE_START_PHRASE]), string_list(trader_data.say_phrases[TRADER_BATTLE_END_PHRASE]))
	if(LAZYLEN(loot))
		loot = string_list(loot)
		AddElement(/datum/element/death_drops, loot)

	var/datum/action/setup_shop/setup_shop = new (src, trader_data.shop_spot_type, trader_data.sign_type, trader_data.sell_sound, trader_data.say_phrases[TRADER_SHOP_OPENING_PHRASE])
	setup_shop.Grant(src)
	ai_controller.set_blackboard_key(BB_SETUP_SHOP, setup_shop)

/mob/living/basic/trader/mrbones
	name = "Mr. Bones"
	desc = "A skeleton merchant, he seems very humerus."
	speak_emote = list("rattles")
	speech_span = SPAN_SANS
	mob_biotypes = MOB_UNDEAD|MOB_HUMANOID
	icon_state = "mrbones"
	gender = MALE

	ai_controller = /datum/ai_controller/basic_controller/trader/jumpscare

	sell_sound = 'sound/mobs/non-humanoids/hiss/hiss2.ogg'
	species_path = /datum/species/skeleton
	spawner_path = /obj/effect/mob_spawn/corpse/human/skeleton/mrbones
	loot = list(/obj/effect/decal/remains/human)
	ranged_attack_casing = /obj/item/ammo_casing/energy/bolt/halloween
	held_weapon_visual = /obj/item/gun/ballistic/revolver

	trader_data_path = /datum/trader_data/mr_bones
