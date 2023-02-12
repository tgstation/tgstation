/**
 * # Spider Hunter
 * A subtype of the giant spider which is faster, has toxin injection, but less health and damage.
 * This spider is only slightly slower than a human.
 */
/mob/living/basic/giant_spider/hunter
	name = "hunter spider"
	desc = "Furry and black, it makes you shudder to look at it. This one has sparkling purple eyes."
	icon_state = "hunter"
	icon_living = "hunter"
	icon_dead = "hunter_dead"
	maxHealth = 50
	health = 50
	melee_damage_lower = 15
	melee_damage_upper = 20
	poison_per_bite = 5
	speed = 3
	player_speed_modifier = -3.1
	menu_description = "Fast spider variant specializing in catching running prey and toxin injection, but has less health and damage."

/**
 * # Spider Nurse
 *
 * A subtype of the giant spider which specializes in support skills.
 * Nurses can place down webbing in a quarter of the time that other species can and can wrap other spiders' wounds, healing them.
 * Note that it cannot heal itself.
 */
/mob/living/basic/giant_spider/nurse
	name = "nurse spider"
	desc = "Furry and black, it makes you shudder to look at it. This one has brilliant green eyes."
	icon_state = "nurse"
	icon_living = "nurse"
	icon_dead = "nurse_dead"
	gender = FEMALE
	butcher_results = list(/obj/item/food/meat/slab/spider = 2, /obj/item/food/spiderleg = 8, /obj/item/food/spidereggs = 4)
	maxHealth = 40
	health = 40
	melee_damage_lower = 5
	melee_damage_upper = 10
	web_speed = 0.25
	web_type = /datum/action/cooldown/lay_web/sealer
	menu_description = "Support spider variant specializing in healing their brethren and placing webbings very swiftly, but has very low amount of health and deals low damage."
	///The health HUD applied to the mob.
	var/health_hud = DATA_HUD_MEDICAL_ADVANCED

/mob/living/basic/giant_spider/nurse/Initialize(mapload)
	. = ..()
	var/datum/atom_hud/datahud = GLOB.huds[health_hud]
	datahud.show_to(src)

	AddComponent(/datum/component/healing_touch,\
		interaction_key = DOAFTER_SOURCE_SPIDER,\
		valid_targets_typecache = typecacheof(list(/mob/living/basic/giant_spider)),\
		action_text = "%SOURCE% begins wrapping the wounds of %TARGET%.",\
		complete_text = "%SOURCE% wraps the wounds of %TARGET%.",\
	)

/**
 * # Tarantula
 *
 * A subtype of the giant spider which specializes in pure strength and staying power.
 * Is slowed down when not on webbing, but can lunge to throw off attackers and possibly to stun them.
 */
/mob/living/basic/giant_spider/tarantula
	name = "tarantula"
	desc = "Furry and black, it makes you shudder to look at it. This one has abyssal red eyes."
	icon_state = "tarantula"
	icon_living = "tarantula"
	icon_dead = "tarantula_dead"
	maxHealth = 300 // woah nelly
	health = 300
	melee_damage_lower = 35
	melee_damage_upper = 40
	obj_damage = 100
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	speed = 6
	player_speed_modifier = -5.5 // Doesn't seem that slow but it gets a debuff off web
	mob_size = MOB_SIZE_LARGE
	gold_core_spawnable = NO_SPAWN
	menu_description = "Tank spider variant with an enormous amount of health and damage, but is very slow when not on webbing. It also has a charge ability to close distance with a target after a small windup."
	/// Charging ability
	var/datum/action/cooldown/mob_cooldown/charge/basic_charge/charge

/mob/living/basic/giant_spider/tarantula/Initialize(mapload)
	. = ..()
	charge = new /datum/action/cooldown/mob_cooldown/charge/basic_charge()
	charge.Grant(src)

	AddElement(/datum/element/web_walker, /datum/movespeed_modifier/tarantula_web)

/mob/living/basic/giant_spider/tarantula/Destroy()
	QDEL_NULL(charge)
	return ..()

/// Lunge if you click something at range
/mob/living/basic/giant_spider/tarantula/ranged_secondary_attack(atom/atom_target, modifiers)
	charge.Trigger(target = atom_target)

/**
 * # Spider Viper
 *
 * A subtype of the giant spider which specializes in speed and poison.
 * Injects a deadlier toxin than other spiders, moves extremely fast, but has a limited amount of health.
 */
/mob/living/basic/giant_spider/viper
	name = "viper spider"
	desc = "Furry and black, it makes you shudder to look at it. This one has effervescent purple eyes."
	icon_state = "viper"
	icon_living = "viper"
	icon_dead = "viper_dead"
	maxHealth = 40
	health = 40
	melee_damage_lower = 5
	melee_damage_upper = 5
	poison_per_bite = 5
	poison_type = /datum/reagent/toxin/viperspider
	speed = 2
	player_speed_modifier = -2.5
	gold_core_spawnable = NO_SPAWN
	menu_description = "Assassin spider variant with an unmatched speed and very deadly poison, but has very low amount of health and damage."

/**
 * # Spider Broodmother
 *
 * A subtype of the giant spider which is the crux of a spider horde, and the way which it grows.
 * Has very little offensive capabilities but can lay eggs at any time to create more basic spiders.
 * After consuming human bodies can lay specialised eggs including more broodmothers.
 * They are also capable of sending messages to all living spiders and setting directives for their children.
 */
/mob/living/basic/giant_spider/midwife
	name = "broodmother spider"
	desc = "Furry and black, it makes you shudder to look at it. This one has scintillating green eyes. Might also be hiding a real knife somewhere."
	gender = FEMALE
	icon_state = "midwife"
	icon_living = "midwife"
	icon_dead = "midwife_dead"
	maxHealth = 60
	health = 60
	melee_damage_lower = 10
	melee_damage_upper = 15
	gold_core_spawnable = NO_SPAWN
	web_speed = 0.5
	web_type = /datum/action/cooldown/lay_web/sealer
	menu_description = "Royal spider variant specializing in reproduction and leadership, but has very low amount of health and deals low damage."

/mob/living/basic/giant_spider/midwife/Initialize(mapload)
	. = ..()
	var/datum/action/cooldown/wrap/wrapping = new(src)
	wrapping.Grant(src)

	var/datum/action/lay_eggs/make_eggs = new(src)
	make_eggs.Grant(src)

	var/datum/action/lay_eggs/enriched/make_better_eggs = new(src)
	make_better_eggs.Grant(src)

	var/datum/action/set_spider_directive/give_orders = new(src)
	give_orders.Grant(src)

	var/datum/action/command_spiders/not_hivemind_talk = new(src)
	not_hivemind_talk.Grant(src)

/**
 * # Giant Ice Spider
 *
 * A subtype of the giant spider which is immune to temperature damage, unlike its normal counterpart.
 * Currently unused in the game unless spawned by admins.
 */
/mob/living/basic/giant_spider/ice
	name = "giant ice spider"
	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500
	color = rgb(114,228,250)
	gold_core_spawnable = NO_SPAWN
	menu_description = "Versatile ice spider variant for frontline combat with high health and damage. Immune to temperature damage."

/**
 * # Ice Nurse Spider
 *
 * A temperature-proof nurse spider. Also unused.
 */
/mob/living/basic/giant_spider/nurse/ice
	name = "giant ice spider"
	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500
	poison_type = /datum/reagent/consumable/frostoil
	color = rgb(114,228,250)
	menu_description = "Support ice spider variant specializing in healing their brethren and placing webbings very swiftly, but has very low amount of health and deals low damage. Immune to temperature damage."

/**
 * # Ice Hunter Spider
 *
 * A temperature-proof hunter with chilling venom. Also unused.
 */
/mob/living/basic/giant_spider/hunter/ice
	name = "giant ice spider"
	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500
	poison_type = /datum/reagent/consumable/frostoil
	color = rgb(114,228,250)
	gold_core_spawnable = NO_SPAWN
	menu_description = "Fast ice spider variant specializing in catching running prey and frost oil injection, but has less health and damage. Immune to temperature damage."

/**
 * # Scrawny Hunter Spider
 *
 * A hunter spider that trades damage for health, unable to smash enviroments.
 * Used as a minor threat in abandoned places, such as areas in maintenance or a ruin.
 */
/mob/living/basic/giant_spider/hunter/scrawny
	name = "scrawny spider"
	environment_smash = ENVIRONMENT_SMASH_NONE
	health = 60
	maxHealth = 60
	melee_damage_lower = 5
	melee_damage_upper = 10
	desc = "Furry and black, it makes you shudder to look at it. This one has sparkling purple eyes, and looks abnormally thin and frail."
	menu_description = "Fast spider variant specializing in catching running prey and toxin injection, but has less damage than a normal hunter spider at the cost of a little more health."

/**
 * # Scrawny Tarantula
 *
 * A weaker version of the Tarantula, unable to smash enviroments.
 * Used as a moderately strong but slow threat in abandoned places, such as areas in maintenance or a ruin.
 */
/mob/living/basic/giant_spider/tarantula/scrawny
	name = "scrawny tarantula"
	environment_smash = ENVIRONMENT_SMASH_NONE
	health = 150
	maxHealth = 150
	melee_damage_lower = 20
	melee_damage_upper = 25
	desc = "Furry and black, it makes you shudder to look at it. This one has abyssal red eyes, and looks abnormally thin and frail."
	menu_description = "A weaker variant of the tarantula with reduced amount of health and damage, very slow when not on webbing. It also has a charge ability to close distance with a target after a small windup."

/**
 * # Scrawny Nurse Spider
 *
 * A weaker version of the nurse spider with reduced health, unable to smash enviroments.
 * Mainly used as a weak threat in abandoned places, such as areas in maintenance or a ruin.
 * In the future we should give this AI so that it actually heals its teammates.
 */
/mob/living/basic/giant_spider/nurse/scrawny
	name = "scrawny nurse spider"
	environment_smash = ENVIRONMENT_SMASH_NONE
	health = 30
	maxHealth = 30
	desc = "Furry and black, it makes you shudder to look at it. This one has brilliant green eyes, and looks abnormally thin and frail."
	menu_description = "Weaker version of the nurse spider, specializing in healing their brethren and placing webbings very swiftly, but has very low amount of health and deals low damage."

/**
 * # Flesh Spider
 *
 * A subtype of giant spider which only occurs from changelings.
 * Has the base stats of a hunter, but they can heal themselves and spin webs faster.
 * They also occasionally leave puddles of blood when they walk around. Flavorful!
 */
/mob/living/basic/giant_spider/hunter/flesh
	desc = "A odd fleshy creature in the shape of a spider.  Its eyes are pitch black and soulless."
	icon_state = "flesh_spider"
	icon_living = "flesh_spider"
	icon_dead = "flesh_spider_dead"
	web_speed = 0.7
	menu_description = "Self-sufficient spider variant capable of healing themselves and producing webbbing fast, but has less health and damage."

/mob/living/basic/giant_spider/hunter/flesh/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/blood_walk, \
		blood_type = /obj/effect/decal/cleanable/blood/bubblegum, \
		blood_spawn_chance = 5)
	// It might be easier and more fitting to just replace this with Regenerator
	AddComponent(/datum/component/healing_touch,\
		heal_brute = maxHealth * 0.5,\
		heal_burn = maxHealth * 0.5,\
		self_targetting = HEALING_TOUCH_SELF_ONLY,\
		interaction_key = DOAFTER_SOURCE_SPIDER,\
		valid_targets_typecache = typecacheof(list(/mob/living/basic/giant_spider/hunter/flesh)),\
		extra_checks = CALLBACK(src, PROC_REF(can_mend)),\
		action_text = "%SOURCE% begins mending themselves...",\
		complete_text = "%SOURCE%'s wounds mend together.",\
	)

/// Prevent you from healing other flesh spiders, or healing when on fire
/mob/living/basic/giant_spider/hunter/flesh/proc/can_mend(mob/living/source, mob/living/target)
	if (on_fire)
		balloon_alert(src, "on fire!")
		return FALSE
	return TRUE

/**
 * # Viper Spider (Wizard)
 *
 * A spider form for wizards. Has the viper spider's extreme speed and strong venom, with additional health and vent crawling abilities.
 */
/mob/living/basic/giant_spider/viper/wizard
	maxHealth = 80
	health = 80
	menu_description = "Stronger assassin spider variant with an unmatched speed, high amount of health and very deadly poison, but deals very low amount of damage. It also has ability to ventcrawl."
	apply_spider_antag = FALSE

/mob/living/basic/giant_spider/viper/wizard/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/**
 * # Sergeant Araneus
 *
 * This friendly arachnid hangs out in the HoS office on some space stations. Better trained than an average officer and does not attack except in self-defence.
 */
/mob/living/basic/giant_spider/sgt_araneus
	name = "Sergeant Araneus"
	real_name = "Sergeant Araneus"
	desc = "A fierce companion of the Head of Security, this spider has been carefully trained by Nanotrasen specialists. Its beady, staring eyes send shivers down your spine."
	faction = list("spiders")
	maxHealth = 250
	health = 250
	melee_damage_lower = 15
	melee_damage_upper = 20
	ai_controller = /datum/ai_controller/basic_controller/giant_spider/retaliate
	apply_spider_antag = FALSE

/mob/living/basic/giant_spider/sgt_araneus/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pet_bonus, "chitters proudly!")
	AddElement(/datum/element/ai_retaliate)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
