GLOBAL_LIST_INIT(raptor_colors, init_raptor_colors())

/proc/init_raptor_colors()
	var/list/colors = list()
	for (var/datum/raptor_color/color_type as anything in subtypesof(/datum/raptor_color))
		colors[color_type] = new color_type()
	return colors

/datum/raptor_color
	/// Color name used for raptor name and icon
	var/color = "error"
	/// RaptorDex description for the raptor
	var/description = "Report this!"
	/// Raptor's health
	var/health = 200
	/// Raptor's speed
	var/speed = 2
	// Minimal and maximal damage for the raptor
	var/melee_damage_lower = 10
	var/melee_damage_upper = 15
	/// Does this raptor redirect projectile hits onto its rider?
	var/redirect_shots = TRUE
	/// Rideable component type to assign to the raptor
	var/rideable_component = /datum/component/riding/creature/raptor
	/// Guaranteed cross-breeding colors, other parent color -> child color
	var/guaranteed_crossbreeds = list()
	/// Type of AI controller the raptor uses
	var/datum/ai_controller/ai_controller = /datum/ai_controller/basic_controller/raptor

/// Shared proc, only called once on raptor init for color-specific traits and properties
/datum/raptor_color/proc/setup_raptor(mob/living/basic/raptor/raptor)
	raptor.ai_controller = new ai_controller(raptor)

/datum/raptor_color/proc/setup_adult(mob/living/basic/raptor/raptor)
	// If we grow up while damaged, keep the damage percentage the same
	raptor.health *= health / raptor.maxHealth
	raptor.maxHealth = health
	raptor.speed = speed
	raptor.melee_damage_lower = melee_damage_lower
	raptor.melee_damage_upper = melee_damage_upper
	if (rideable_component)
		raptor.AddElement(/datum/element/ridable, rideable_component)
	setup_appearance(raptor)

/datum/raptor_color/proc/setup_young(mob/living/basic/raptor/raptor)
	raptor.health = health / 2
	raptor.maxHealth = health / 2
	raptor.speed = speed
	raptor.melee_damage_lower = floor(melee_damage_lower / 2)
	raptor.melee_damage_upper = floor(melee_damage_upper / 2)
	setup_appearance(raptor)

/datum/raptor_color/proc/setup_baby(mob/living/basic/raptor/raptor)
	raptor.health = health / 8
	raptor.maxHealth = health / 8
	raptor.speed = speed * 2.5
	raptor.melee_damage_lower = floor(melee_damage_lower / 3)
	raptor.melee_damage_upper = floor(melee_damage_upper / 3)
	setup_appearance(raptor)

/datum/raptor_color/proc/setup_appearance(mob/living/basic/raptor/raptor)
	raptor.name = "[color] [raptor.name]"
	raptor.icon_state = "[raptor.base_icon_state]_[color]"
	raptor.held_state = "[raptor.base_icon_state]_[color]"
	raptor.icon_living = "[raptor.base_icon_state]_[color]"
	raptor.icon_dead = "[raptor.base_icon_state]_[color]_dead"
	raptor.update_appearance()

/datum/raptor_color/red
	color = "red"
	description = "A resilient breed of raptors, battle-tested and bred for the purpose of humbling its foes in combat, \
		This breed demonstrates higher combat capabilities than its peers and oozes ruthless aggression."
	melee_damage_lower = 15
	melee_damage_upper = 20
	health = 300
	rideable_component = /datum/component/riding/creature/raptor/combat
	redirect_shots = FALSE
	guaranteed_crossbreeds = list(
		/datum/raptor_color/green = /datum/raptor_color/yellow,
		/datum/raptor_color/blue = /datum/raptor_color/purple,
	)
	// Doesn't care for your excuses for friendly fire
	ai_controller = /datum/ai_controller/basic_controller/raptor/aggressive

/datum/raptor_color/purple
	color = "purple"
	description = "A small, nimble breed, these raptors have been bred as travel companions rather than mounts, capable of storing the owner's possessions and helping them escape from danger unscathed."
	guaranteed_crossbreeds = list(
		/datum/raptor_color/green = /datum/raptor_color/white,
		/datum/raptor_color/yellow = /datum/raptor_color/blue,
	)

/*
/mob/living/basic/raptor/purple/Initialize(mapload)
	. = ..()
	create_storage(
		max_specific_storage = WEIGHT_CLASS_NORMAL,
		max_total_storage = 10,
		storage_type = /datum/storage/raptor_storage,
	)

/datum/storage/raptor_storage
	animated = FALSE
	insert_on_attack = FALSE // should flip when worn on the back

/datum/storage/raptor_storage/on_mousedropped_onto(datum/source, obj/item/dropping, mob/user)
	..()
	return NONE
*/

/datum/raptor_color/green
	color = "green"
	description = "A tough breed of raptor, made to withstand the harshest of punishment and to laugh in the face of pain, \
		this breed is able to withstand more punishment than its peers."
	health = 400
	// redirect_shots = FALSE // Need to figure out if I want this or not here
	guaranteed_crossbreeds = list(
		/datum/raptor_color/purple = /datum/raptor_color/white,
		/datum/raptor_color/red = /datum/raptor_color/yellow,
	)

/datum/raptor_color/green/setup_adult(mob/living/basic/raptor/raptor)
	. = ..()
	raptor.AddComponent(/datum/component/proficient_miner, 0.05, TRUE)

/datum/raptor_color/white
	color = "white"
	description = "A loving sort, it cares for it peers and rushes to their aid with reckless abandon. It is able to heal any raptors' ailments."
	guaranteed_crossbreeds = list(
		/datum/raptor_color/blue = /datum/raptor_color/green,
		/datum/raptor_color/yellow = /datum/raptor_color/red,
	)

/datum/raptor_color/white/setup_young(mob/living/basic/raptor/raptor)
	. = ..()
	raptor.AddComponent( \
		/datum/component/healing_touch, \
		heal_brute = melee_damage_upper * 0.75, \
		heal_burn = melee_damage_upper * 0.75, \
		heal_time = 0, \
		valid_targets_typecache = typecacheof(list(/mob/living/basic/raptor)), \
	)

/datum/raptor_color/white/setup_adult(mob/living/basic/raptor/raptor)
	. = ..()
	qdel(raptor.GetComponent(/datum/component/healing_touch))
	raptor.AddComponent( \
		/datum/component/healing_touch, \
		heal_brute = melee_damage_upper, \
		heal_burn = melee_damage_upper, \
		heal_time = 0, \
		valid_targets_typecache = typecacheof(list(/mob/living/basic/raptor)), \
	)

/datum/raptor_color/yellow
	color = "yellow"
	description = "This breed possesses greasy fast speed, DEMON speed, making light work of long pilgrimages. \
		It's said that a thunderclap could be heard when this breed reaches its maximum speed."
	speed = 1.5
	guaranteed_crossbreeds = list(
		/datum/raptor_color/purple = /datum/raptor_color/blue,
		/datum/raptor_color/white = /datum/raptor_color/red,
	)

/datum/raptor_color/blue
	color = "blue"
	description = "Covered in tough, lava-resistant feathers with thick insulated fur underneath, this breed is capable of marching through lava and fire alike."
	guaranteed_crossbreeds = list(
		/datum/raptor_color/red = /datum/raptor_color/purple,
		/datum/raptor_color/white = /datum/raptor_color/green,
	)

/datum/raptor_color/blue/setup_raptor(mob/living/basic/raptor/raptor)
	. = ..()
	raptor.add_traits(list(TRAIT_LAVA_IMMUNE, TRAIT_NOFIRE_SPREAD), INNATE_TRAIT)

/datum/raptor_color/black
	color = "black"
	description = "An ultra rare breed. Due to its sparse nature, not much is known about this sort. However it is said to possess many of its peers' abilities."
	health = 400
	speed = 1.5
	melee_damage_lower = 20
	melee_damage_upper = 25
	redirect_shots = FALSE
	rideable_component = /datum/component/riding/creature/raptor/combat
	ai_controller = /datum/ai_controller/basic_controller/raptor/aggressive

/datum/raptor_color/black/setup_raptor(mob/living/basic/raptor/raptor)
	. = ..()
	raptor.add_traits(list(TRAIT_LAVA_IMMUNE, TRAIT_NOFIRE_SPREAD), INNATE_TRAIT)

/datum/raptor_color/black/setup_adult(mob/living/basic/raptor/raptor)
	. = ..()
	raptor.AddComponent(/datum/component/proficient_miner, 0.1, TRUE) // Slightly worse than greens at this
