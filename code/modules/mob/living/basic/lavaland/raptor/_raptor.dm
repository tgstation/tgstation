GLOBAL_LIST_INIT(raptor_growth_paths, list(
	/mob/living/basic/raptor/baby_raptor/red = list(RAPTOR_PURPLE, RAPTOR_WHITE),
	/mob/living/basic/raptor/baby_raptor/white = list(RAPTOR_GREEN, RAPTOR_PURPLE),
	/mob/living/basic/raptor/baby_raptor/purple = list(RAPTOR_GREEN, RAPTOR_WHITE),
	/mob/living/basic/raptor/baby_raptor/yellow = list(RAPTOR_GREEN, RAPTOR_RED),
	/mob/living/basic/raptor/baby_raptor/green = list(RAPTOR_RED, RAPTOR_YELLOW),
	/mob/living/basic/raptor/baby_raptor/blue = list(RAPTOR_RED, RAPTOR_PURPLE)
))

GLOBAL_LIST_INIT(raptor_inherit_traits, list(
	BB_BASIC_DEPRESSED = "Depressed",
	BB_RAPTOR_MOTHERLY = "Motherly",
	BB_RAPTOR_PLAYFUL = "Playful",
	BB_RAPTOR_COWARD = "Coward",
	BB_RAPTOR_TROUBLE_MAKER = "Trouble Maker",
))

GLOBAL_LIST_EMPTY(raptor_population)

#define HAPPINESS_BOOST_DAMPENER 0.3

/mob/living/basic/raptor
	name = "raptor"
	desc = "A trusty, powerful steed. Taming it might prove difficult..."
	icon = 'icons/mob/simple/lavaland/raptor_big.dmi'
	speed = 2
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	maxHealth = 270
	health = 270
	melee_damage_lower = 10
	melee_damage_upper = 15
	combat_mode = TRUE
	mob_size = MOB_SIZE_LARGE
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = BODYTEMP_COLD_ICEBOX_SAFE
	maximum_survivable_temperature = INFINITY
	attack_verb_continuous = "pecks"
	attack_verb_simple = "chomps"
	attack_sound = 'sound/items/weapons/punch1.ogg'
	faction = list(FACTION_RAPTOR, FACTION_NEUTRAL)
	speak_emote = list("screeches")
	ai_controller = /datum/ai_controller/basic_controller/raptor
	///can this mob breed
	var/can_breed = TRUE
	///should we change offsets on direction change?
	var/change_offsets = TRUE
	///can we ride this mob
	var/ridable_component = /datum/component/riding/creature/raptor
	//pet commands when we tame the raptor
	var/static/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/point_targeting/attack,
		/datum/pet_command/follow,
		/datum/pet_command/point_targeting/fetch,
	)
	///things we inherited from our parent
	var/datum/raptor_inheritance/inherited_stats
	///our color
	var/raptor_color
	///the description that appears in the dex
	var/dex_description
	///path of our child
	var/child_path


/mob/living/basic/raptor/Initialize(mapload)
	. = ..()
	if(SSmapping.is_planetary())
		change_offsets = FALSE
		icon = 'icons/mob/simple/lavaland/raptor_icebox.dmi'

	add_traits(list(TRAIT_LAVA_IMMUNE, TRAIT_ASHSTORM_IMMUNE, TRAIT_SNOWSTORM_IMMUNE), INNATE_TRAIT)

	if(!mapload)
		GLOB.raptor_population += REF(src)
	AddComponent(/datum/component/obeys_commands, pet_commands)

	AddElement(\
		/datum/element/change_force_on_death,\
		move_resist = MOVE_RESIST_DEFAULT,\
	)

	var/static/list/display_emote = list(
		BB_EMOTE_SAY = list("Chirp chirp chirp!", "Kweh!", "Bwark!"),
		BB_EMOTE_SEE = list("shakes its feathers!", "stretches!", "flaps its wings!", "pecks at the ground!"),
		BB_EMOTE_SOUND = list(
			'sound/mobs/non-humanoids/raptor/raptor_1.ogg',
			'sound/mobs/non-humanoids/raptor/raptor_2.ogg',
			'sound/mobs/non-humanoids/raptor/raptor_3.ogg',
			'sound/mobs/non-humanoids/raptor/raptor_4.ogg',
			'sound/mobs/non-humanoids/raptor/raptor_5.ogg',
		),
		BB_SPEAK_CHANCE = 2,
	)

	ai_controller.set_blackboard_key(BB_BASIC_MOB_SPEAK_LINES, display_emote)
	inherited_stats = new
	inherit_properties()
	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(pre_attack))
	var/static/list/my_food = list(/obj/item/stack/ore)
	AddElement(/datum/element/basic_eating, food_types = my_food)
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/ai_flee_while_injured, stop_fleeing_at = 0.5, start_fleeing_below = 0.2)

	if(ridable_component)
		AddElement(/datum/element/ridable, ridable_component)

	if(can_breed)
		AddComponent(\
			/datum/component/breed,\
			can_breed_with = typecacheof(list(/mob/living/basic/raptor)),\
			baby_path = /obj/item/food/egg/raptor_egg,\
			post_birth = CALLBACK(src, PROC_REF(egg_inherit)),\
			breed_timer = 3 MINUTES,\
		)
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_CLAW)
	RegisterSignal(src, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_dir_change))
	adjust_offsets(dir)
	add_happiness_component()


/mob/living/basic/raptor/buckle_mob(mob/living/target, force = FALSE, check_loc = TRUE, buckle_mob_flags= NONE)
	if(!iscarbon(target))
		return
	return ..()

/mob/living/basic/raptor/proc/add_happiness_component()
	var/static/list/percentage_callbacks = list(0, 15, 25, 35, 50, 75, 90, 100)
	AddComponent(\
		/datum/component/happiness,\
		on_petted_change = 100,\
		on_groom_change = 100,\
		on_eat_change = 400,\
		callback_percentages = percentage_callbacks,\
		happiness_callback = CALLBACK(src, PROC_REF(happiness_change)),\
	)

/mob/living/basic/raptor/proc/on_dir_change(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	adjust_offsets(new_dir)

/mob/living/basic/raptor/proc/adjust_offsets(direction)
	if(!change_offsets)
		return
	pixel_x = (direction & EAST) ? -20 : 0
	pixel_y = (direction & NORTH) ? -5 : 0


/mob/living/basic/raptor/proc/pre_attack(mob/living/puncher, atom/target)
	SIGNAL_HANDLER

	if(!istype(target, /obj/structure/ore_container/food_trough/raptor_trough))
		return

	var/obj/ore_food = locate(/obj/item/stack/ore) in target

	if(isnull(ore_food))
		balloon_alert(src, "no food!")
	else
		INVOKE_ASYNC(src, PROC_REF(melee_attack), ore_food)
	return COMPONENT_HOSTILE_NO_ATTACK

/mob/living/basic/raptor/melee_attack(mob/living/target, list/modifiers, ignore_cooldown)
	if(!combat_mode && istype(target, /mob/living/basic/raptor/baby_raptor))
		target.attack_hand(src, list(LEFT_CLICK = TRUE))
		return
	return ..()

/mob/living/basic/raptor/death(gibbed)
	. = ..()
	GLOB.raptor_population -= REF(src)

/mob/living/basic/raptor/proc/happiness_change(percent_value)
	var/attack_boost = round(initial(melee_damage_lower) * percent_value * HAPPINESS_BOOST_DAMPENER, 1)
	melee_damage_lower = initial(melee_damage_lower) + attack_boost
	melee_damage_upper = melee_damage_lower + 5


///pass down our inheritance to the egg
/mob/living/basic/raptor/proc/egg_inherit(obj/item/food/egg/raptor_egg/baby_egg, mob/living/basic/raptor/partner)
	var/datum/raptor_inheritance/inherit = new
	inherit.set_parents(inherited_stats, partner.inherited_stats)
	baby_egg.inherited_stats = inherit
	baby_egg.determine_growth_path(src, partner)

/mob/living/basic/raptor/proc/inherit_properties()
	if(isnull(inherited_stats))
		return
	for(var/trait in GLOB.raptor_inherit_traits) // done this way to allow overriding of traits when assigned new inherit datum
		var/should_inherit = (trait in inherited_stats.inherit_traits)
		ai_controller?.set_blackboard_key(trait, should_inherit)
	melee_damage_lower += inherited_stats.attack_modifier
	melee_damage_upper += melee_damage_lower + 5
	maxHealth += inherited_stats.health_modifier
	heal_overall_damage(maxHealth)

/mob/living/basic/raptor/Destroy()
	QDEL_NULL(inherited_stats)
	return ..()

/mob/living/basic/raptor/red
	name = "red raptor"
	icon_state = "raptor_red"
	icon_living = "raptor_red"
	icon_dead = "raptor_red_dead"
	melee_damage_lower = 15
	melee_damage_upper = 20
	raptor_color = RAPTOR_RED
	dex_description = "A resilient breed of raptors, battle-tested and bred for the purpose of humbling its foes in combat, \
		This breed demonstrates higher combat capabilities than its peers and oozes ruthless aggression."
	child_path = /mob/living/basic/raptor/baby_raptor/red

/mob/living/basic/raptor/purple
	name = "purple raptor"
	icon_state = "raptor_purple"
	icon_living = "raptor_purple"
	icon_dead = "raptor_purple_dead"
	raptor_color = RAPTOR_PURPLE
	dex_description = "A dependable mount, bred for the purpose of long distance pilgrimages. This breed is also able to store its rider's possessions."
	child_path = /mob/living/basic/raptor/baby_raptor/purple

/mob/living/basic/raptor/purple/Initialize(mapload)
	. = ..()
	create_storage(
		max_specific_storage = WEIGHT_CLASS_NORMAL,
		max_total_storage = 10,
		storage_type = /datum/storage/raptor_storage,
	)

/mob/living/basic/raptor/green
	name = "green raptor"
	icon_state = "raptor_green"
	icon_living = "raptor_green"
	icon_dead = "raptor_green_dead"
	maxHealth = 400
	health = 400
	raptor_color = RAPTOR_GREEN
	dex_description = "A tough breed of raptor, made to withstand the harshest of punishment and to laugh in the face of pain, \
		this breed is able to withstand more punishment than its peers."
	child_path = /mob/living/basic/raptor/baby_raptor/green

/mob/living/basic/raptor/green/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/proficient_miner)

/mob/living/basic/raptor/white
	name = "white raptor"
	icon_state = "raptor_white"
	icon_living = "raptor_white"
	icon_dead = "raptor_white_dead"
	raptor_color = RAPTOR_WHITE
	dex_description = "A loving sort, it cares for it peers and rushes to their aid with reckless abandon. It is able to heal any raptors' ailments."
	child_path = /mob/living/basic/raptor/baby_raptor/white

/mob/living/basic/raptor/white/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/healing_touch,\
		heal_brute = melee_damage_upper,\
		heal_burn = melee_damage_upper,\
		heal_time = 0,\
		valid_targets_typecache = typecacheof(list(/mob/living/basic/raptor)),\
	)

/mob/living/basic/raptor/black
	name = "black raptor"
	icon_state = "raptor_black"
	icon_living = "raptor_black"
	icon_dead = "raptor_black_dead"
	maxHealth = 400
	health = 400
	speed = 1
	ridable_component = /datum/component/riding/creature/raptor/fast
	melee_damage_lower = 20
	melee_damage_upper = 25
	raptor_color = RAPTOR_BLACK
	dex_description = "An ultra rare breed. Due to its sparse nature, not much is known about this sort. However it is said to possess many of its peers' abilities."
	child_path = /mob/living/basic/raptor/baby_raptor/black

/mob/living/basic/raptor/yellow
	name = "yellow raptor"
	icon_state = "raptor_yellow"
	icon_living = "raptor_yellow"
	icon_dead = "raptor_yellow_dead"
	ridable_component = /datum/component/riding/creature/raptor/fast
	speed = 1
	raptor_color = RAPTOR_YELLOW
	dex_description = "This breed possesses greasy fast speed, DEMON speed, making light work of long pilgrimages. It's said that a thunderclap could be heard when this breed reaches its maximum speed."
	child_path = /mob/living/basic/raptor/baby_raptor/yellow

/mob/living/basic/raptor/blue
	name = "blue raptor"
	icon_state = "raptor_blue"
	icon_living = "raptor_blue"
	icon_dead = "raptor_blue_dead"
	raptor_color = RAPTOR_BLUE
	dex_description = "Known to produce nutritous and equally delicious milk, which is also said to possess healing properties."
	child_path = /mob/living/basic/raptor/baby_raptor/blue

/mob/living/basic/raptor/blue/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/udder,\
		udder_type = /obj/item/udder/raptor,\
	)

/datum/storage/raptor_storage
	animated = FALSE
	insert_on_attack = FALSE

/datum/storage/raptor_storage/on_mousedropped_onto(datum/source, obj/item/dropping, mob/user)
	..()
	return NONE

#undef HAPPINESS_BOOST_DAMPENER
