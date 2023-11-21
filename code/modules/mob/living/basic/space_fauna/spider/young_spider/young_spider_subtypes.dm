// This whole file is just a container for the young spider subtypes that actually differentiate into different giant spiders. None of them are particularly special as of now.

/// Will differentiate into the base giant spider (known colloquially as the "guard" spider).
/mob/living/basic/spider/growing/young/guard
	grow_as = /mob/living/basic/spider/giant/guard
	name = "young guard spider"
	desc = "Furry and brown, it looks defenseless. This one has sparkling red eyes."
	maxHealth = 70
	health = 70
	melee_damage_lower = 10
	melee_damage_upper = 15
	speed = 0.7

/// Will differentiate into the "ambush" giant spider.
/mob/living/basic/spider/growing/young/ambush
	grow_as = /mob/living/basic/spider/giant/ambush
	name = "young ambush spider"
	desc = "Furry and white, it looks defenseless. This one has sparkling pink eyes."
	icon = 'icons/mob/simple/arachnoid.dmi'
	icon_state = "young_ambush"
	icon_dead = "young_ambush_dead"
	maxHealth = 55
	health = 55
	melee_damage_lower = 12
	melee_damage_upper = 18
	speed = 1

/mob/living/basic/spider/growing/young/ambush/Initialize(mapload)
	. = ..()
	var/datum/action/cooldown/mob_cooldown/sneak/spider/sneak_web = new(src)
	sneak_web.Grant(src)

/// Will differentiate into the "scout" giant spider.
/mob/living/basic/spider/growing/young/scout
	grow_as = /mob/living/basic/spider/giant/scout
	name = "young scout spider"
	desc = "Furry and black, it looks defenseless. This one has sparkling blue eyes."
	icon = 'icons/mob/simple/arachnoid.dmi'
	icon_state = "young_scout"
	icon_dead = "young_scout_dead"
	maxHealth = 35
	health = 35
	melee_damage_lower = 2
	melee_damage_upper = 4
	speed = 0.5
	poison_per_bite = 4
	poison_type = /datum/reagent/peaceborg/confuse
	sight = SEE_SELF|SEE_MOBS

/mob/living/basic/spider/growing/young/scout/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/// Will differentiate into the "hunter" giant spider.
/mob/living/basic/spider/growing/young/hunter
	grow_as = /mob/living/basic/spider/giant/hunter
	name = "young hunter spider"
	desc = "Furry and black, it looks defenseless. This one has sparkling purple eyes."
	icon = 'icons/mob/simple/arachnoid.dmi'
	icon_state = "young_hunter"
	icon_dead = "young_hunter_dead"
	maxHealth = 45
	health = 45
	melee_damage_lower = 8
	melee_damage_upper = 12
	speed = 0.5
	poison_per_bite = 2

/// Will differentiate into the "nurse" giant spider.
/mob/living/basic/spider/growing/young/nurse
	grow_as = /mob/living/basic/spider/giant/nurse
	name = "young nurse spider"
	desc = "Furry and black, it looks defenseless. This one has sparkling green eyes."
	icon = 'icons/mob/simple/arachnoid.dmi'
	icon_state = "young_nurse"
	icon_dead = "young_nurse_dead"
	maxHealth = 25
	health = 25
	melee_damage_lower = 2
	melee_damage_upper = 4
	speed = 0.7
	web_speed = 0.5
	web_type = /datum/action/cooldown/mob_cooldown/lay_web/sealer
	///The health HUD applied to the mob.
	var/health_hud = DATA_HUD_MEDICAL_ADVANCED

/mob/living/basic/spider/growing/young/nurse/Initialize(mapload)
	. = ..()
	var/datum/atom_hud/datahud = GLOB.huds[health_hud]
	datahud.show_to(src)

	AddComponent(/datum/component/healing_touch,\
		heal_brute = 15,\
		heal_burn = 15,\
		interaction_key = DOAFTER_SOURCE_SPIDER,\
		valid_targets_typecache = typecacheof(list(/mob/living/basic/spider/giant)),\
		action_text = "%SOURCE% begins wrapping the wounds of %TARGET%.",\
		complete_text = "%SOURCE% wraps the wounds of %TARGET%.",\
	)

/// Will differentiate into the "tangle" giant spider.
/mob/living/basic/spider/growing/young/tangle
	grow_as = /mob/living/basic/spider/giant/tangle
	name = "young tangle spider"
	desc = "Furry and brown, it looks defenseless. This one has dim brown eyes."
	icon = 'icons/mob/simple/arachnoid.dmi'
	icon_state = "young_tangle"
	icon_dead = "young_tangle_dead"
	maxHealth = 30
	health = 30
	melee_damage_lower = 1
	melee_damage_upper = 1
	speed = 0.7
	web_speed = 0.25
	web_type = /datum/action/cooldown/mob_cooldown/lay_web/sealer
	poison_per_bite = 2
	poison_type = /datum/reagent/toxin/acid

/mob/living/basic/spider/growing/young/tangle/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/healing_touch,\
		heal_brute = 10,\
		heal_burn = 10,\
		heal_time = 3 SECONDS,\
		self_targetting = HEALING_TOUCH_SELF_ONLY,\
		interaction_key = DOAFTER_SOURCE_SPIDER,\
		valid_targets_typecache = typecacheof(list(/mob/living/basic/spider/growing/young/tangle, /mob/living/basic/spider/giant/tangle)),\
		extra_checks = CALLBACK(src, PROC_REF(can_mend)),\
		action_text = "%SOURCE% begins mending themselves...",\
		complete_text = "%SOURCE%'s wounds mend together.",\
	)

/// Prevent you from healing other tangle spiders, or healing when on fire
/mob/living/basic/spider/growing/young/tangle/proc/can_mend(mob/living/source, mob/living/target)
	if (on_fire)
		balloon_alert(src, "on fire!")
		return FALSE
	return TRUE

/// Will differentiate into the "midwife" giant spider.
/mob/living/basic/spider/growing/young/midwife
	grow_as = /mob/living/basic/spider/giant/midwife
	name = "young broodmother spider"
	desc = "Furry and black, it looks defenseless. This one has scintillating green eyes. Might also be hiding a real knife somewhere."
	icon = 'icons/mob/simple/arachnoid.dmi'
	icon_state = "young_midwife"
	icon_dead = "young_midwife_dead"
	maxHealth = 100
	health = 100
	melee_damage_lower = 5
	melee_damage_upper = 10
	speed = 0.7
	web_speed = 0.5
	web_type = /datum/action/cooldown/mob_cooldown/lay_web/sealer

/// Will differentiate into the "viper" giant spider.
/mob/living/basic/spider/growing/young/viper
	grow_as = /mob/living/basic/spider/giant/viper
	name = "young viper spider"
	desc = "Furry and black, it looks defenseless. This one has sparkling magenta eyes."
	icon = 'icons/mob/simple/arachnoid.dmi'
	icon_state = "young_viper"
	icon_dead = "young_viper_dead"
	maxHealth = 30
	health = 30
	melee_damage_lower = 5
	melee_damage_upper = 5
	speed = 0.2
	poison_type = /datum/reagent/toxin/viperspider
	poison_per_bite = 2

/// Will differentiate into the "tarantula" giant spider.
/mob/living/basic/spider/growing/young/tarantula
	grow_as = /mob/living/basic/spider/giant/tarantula
	name = "young tarantula spider"
	desc = "Furry and black, it looks defenseless. This one has abyssal red eyes."
	icon = 'icons/mob/simple/arachnoid.dmi'
	icon_state = "young_tarantula"
	icon_dead = "young_tarantula_dead"
	maxHealth = 150
	health = 150
	melee_damage_lower = 20
	melee_damage_upper = 25
	speed = 1
	obj_damage = 40
