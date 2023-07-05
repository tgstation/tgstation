// This whole file is just a container for the spiderling subtypes that actually differentiate into different giant spiders. None of them are particularly special as of now.

/// Will differentiate into the base giant spider (known colloquially as the "guard" spider).
/mob/living/basic/spiderling/guard
	grow_as = /mob/living/basic/giant_spider/guard
	name = "guard spiderling"
	desc = "Furry and brown, it looks defenseless. This one has sparkling red eyes."
	menu_description = "Furry and brown, specializing in defense of the hive and other spides."

	/// Will differentiate into the "ambush" giant spider.
/mob/living/basic/spiderling/ambush
	grow_as = /mob/living/basic/giant_spider/ambush
	name = "ambush spiderling"
	desc = "Furry and white, it looks defenseless. This one has sparkling pink eyes."
	icon_state = "ambush_spiderling"
	icon_dead = "ambush_spiderling_dead"
	menu_description = "Slow spider variant specializing in stalking and ambushing prey, above avarage health and damage with a strong grip."

/// Will differentiate into the "scout" giant spider.
/mob/living/basic/spiderling/scout
	grow_as = /mob/living/basic/giant_spider/scout
	name = "scout spiderling"
	desc = "Furry and black, it looks defenseless. This one has sparkling purple eyes."
	icon_state = "scout_spiderling"
	icon_dead = "scout_spiderling_dead"
	menu_description = "Fast spider variant specializing in scouting and alerting of prey ,with the ability to travel in vents."


/// Will differentiate into the "hunter" giant spider.
/mob/living/basic/spiderling/hunter
	grow_as = /mob/living/basic/giant_spider/hunter
	name = "hunter spiderling"
	desc = "Furry and black, it looks defenseless. This one has sparkling purple eyes."
	icon_state = "hunter_spiderling"
	icon_dead = "hunter_spiderling_dead"
	menu_description = "Fast spider variant specializing in catching running prey and toxin injection, but has less health and damage."

/// Will differentiate into the "nurse" giant spider.
/mob/living/basic/spiderling/nurse
	grow_as = /mob/living/basic/giant_spider/nurse
	name = "nurse spiderling"
	desc = "Furry and black, it looks defenseless. This one has sparkling green eyes."
	icon_state = "nurse_spiderling"
	icon_dead = "nurse_spiderling_dead"
	menu_description = "Support spider variant specializing in healing their brethren and placing webbings very swiftly, but has very low amount of health and deals low damage."

	/// Will differentiate into the "tangle" giant spider.
/mob/living/basic/spiderling/tangle
	grow_as = /mob/living/basic/giant_spider/tangle
	name = "tangle spiderling"
	desc = "Furry and brown, it looks defenseless. This one has dim brown eyes."
	icon_state = "tangle_spiderling"
	icon_dead = "tangle_spiderling_dead"
	menu_description = "Support spider variant specializing in contruction to protect their brethren, but has very low amount of health and deals low damage."

/// Will differentiate into the "midwife" giant spider.
/mob/living/basic/spiderling/midwife
	grow_as = /mob/living/basic/giant_spider/midwife
	name = "broodmother spiderling"
	desc = "Furry and black, it looks defenseless. This one has scintillating green eyes. Might also be hiding a real knife somewhere."
	icon_state = "midwife_spiderling"
	icon_dead = "midwife_spiderling_dead"
	menu_description = "Royal spider variant specializing in reproduction and leadership, but has very low amount of health and deals low damage."
	gold_core_spawnable = NO_SPAWN

/// Will differentiate into the "viper" giant spider.
/mob/living/basic/spiderling/viper
	grow_as = /mob/living/basic/giant_spider/viper
	name = "viper_spiderling"
	desc = "Furry and black, it looks defenseless. This one has sparkling purple eyes."
	icon_state = "viper_spiderling"
	icon_dead = "viper_spiderling_dead"
	menu_description = "Extremly Fast spider variant specializing in catching running prey and lethal toxin injection, but has less health and damage."
	gold_core_spawnable = NO_SPAWN

/// Will differentiate into the "tarantula" giant spider.
/mob/living/basic/spiderling/tarantula
	grow_as = /mob/living/basic/giant_spider/tarantula
	name = "tarantula_spiderling"
	desc = "Furry and black, it looks defenseless. This one has abyssal red eyes."
	icon_state = "tarantula_spiderling"
	icon_dead = "tarantula_spiderling_dead"
	menu_description = "Tank spider variant with an enormous amount of health and damage, but is very slow when not on webbing. It also has a charge ability to close distance with a target after a small windup."
	gold_core_spawnable = NO_SPAWN

/// Will differentiate into the "hunter" giant spider.
/mob/living/basic/spiderling/hunter/flesh
	grow_as = /mob/living/basic/giant_spider/hunter/flesh
	name = "hunter spiderling"
	desc = "Furry and black, it looks defenseless. This one has sparkling purple eyes."
	icon_state = "flesh_spiderling"
	icon_dead = "flesh_spiderling_dead"
	menu_description = "Self-sufficient spider variant capable of healing themselves and producing webbbing fast."
	gold_core_spawnable = NO_SPAWN
