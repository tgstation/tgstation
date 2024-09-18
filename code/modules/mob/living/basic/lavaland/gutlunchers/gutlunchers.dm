#define MAX_ATTACK_DIFFERENCE 3
#define MAX_LOWER_ATTACK 15
#define MINIMUM_POSSIBLE_SPEED 1
#define MAX_POSSIBLE_HEALTH 100

/mob/living/basic/mining/gutlunch
	name = "gutlunch"
	desc = "A scavenger that eats raw ores, often found alongside ash walkers. Produces a thick, nutritious milk."
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "gutlunch"
	combat_mode = FALSE
	icon_living = "gutlunch"
	icon_dead = "gutlunch"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	basic_mob_flags = DEL_ON_DEATH
	speak_emote = list("warbles", "quavers")
	faction = list(FACTION_ASHWALKER)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "squishes"
	response_harm_simple = "squish"
	friendly_verb_continuous = "pinches"
	friendly_verb_simple = "pinch"
	gold_core_spawnable = FRIENDLY_SPAWN
	death_message = "is pulped into bugmash."
	greyscale_config = /datum/greyscale_config/gutlunch
	///possible colors we can have
	var/list/possible_colors = list(COLOR_WHITE)
	///can we breed?
	var/can_breed = TRUE

/mob/living/basic/mining/gutlunch/Initialize(mapload)
	. = ..()
	GLOB.gutlunch_count++
	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(pre_attack))
	if(greyscale_config)
		set_greyscale(colors = list(pick(possible_colors)))
	AddElement(/datum/element/ai_retaliate)
	if(!can_breed)
		return
	AddComponent(\
		/datum/component/breed,\
		can_breed_with = typecacheof(list(/mob/living/basic/mining/gutlunch)),\
		baby_path = /mob/living/basic/mining/gutlunch/grub,\
		post_birth = CALLBACK(src, PROC_REF(after_birth)),\
		breed_timer = 3 MINUTES,\
	)

/mob/living/basic/mining/gutlunch/Destroy()
	GLOB.gutlunch_count--
	return ..()

/mob/living/basic/mining/gutlunch/proc/pre_attack(mob/living/puncher, atom/target)
	SIGNAL_HANDLER

	if(!istype(target, /obj/structure/ore_container/food_trough/gutlunch_trough))
		return

	var/obj/ore_food = locate(/obj/item/stack/ore) in target

	if(isnull(ore_food))
		balloon_alert(src, "no food!")
	else
		melee_attack(ore_food)
	return COMPONENT_HOSTILE_NO_ATTACK

/mob/living/basic/mining/gutlunch/proc/after_birth(mob/living/basic/mining/gutlunch/grub/baby, mob/living/partner)
	var/our_color = LAZYACCESS(atom_colours, FIXED_COLOUR_PRIORITY) || COLOR_GRAY
	var/partner_color = LAZYACCESS(partner.atom_colours, FIXED_COLOUR_PRIORITY) || COLOR_GRAY
	baby.add_atom_colour(BlendRGB(our_color, partner_color, 1), FIXED_COLOUR_PRIORITY)
	var/atom/male_parent = (gender == MALE) ? src : partner
	baby.inherited_stats = new(male_parent)

/mob/living/basic/mining/gutlunch/proc/roll_stats(input_attack, input_speed, input_health)
	melee_damage_lower = rand(input_attack, min(MAX_LOWER_ATTACK, input_attack + MAX_ATTACK_DIFFERENCE))
	melee_damage_upper = melee_damage_lower + MAX_ATTACK_DIFFERENCE
	speed = rand(MINIMUM_POSSIBLE_SPEED, input_speed)
	maxHealth = rand(input_health, MAX_POSSIBLE_HEALTH)
	health = maxHealth

/mob/living/basic/mining/gutlunch/milk
	name = "gubbuck"
	gender = FEMALE
	possible_colors = list("#E39FBB","#817178","#9d667d")
	ai_controller = /datum/ai_controller/basic_controller/gutlunch/gutlunch_milk
	///overlay we display when our udder is full!
	var/mutable_appearance/full_udder

/mob/living/basic/mining/gutlunch/milk/Initialize(mapload)
	. = ..()
	var/datum/callback/milking_callback = CALLBACK(src, TYPE_PROC_REF(/atom/movable, update_overlays))
	AddComponent(\
		/datum/component/udder,\
		udder_type = /obj/item/udder/gutlunch,\
		on_milk_callback = milking_callback,\
		on_generate_callback = milking_callback,\
	)
	full_udder = mutable_appearance(icon, "gl_full")
	full_udder.color = LAZYACCESS(atom_colours, FIXED_COLOUR_PRIORITY) || COLOR_GRAY

/mob/living/basic/mining/gutlunch/warrior
	name = "gunther"
	gender = MALE
	melee_damage_lower = 8
	melee_damage_upper = 13
	speed = 5
	maxHealth = 70
	health = 70
	ai_controller = /datum/ai_controller/basic_controller/gutlunch/gutlunch_warrior
	possible_colors = list("#6d77ff","#8578e4","#97b6f6")
	//pet commands when we tame the gutluncher
	var/static/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/point_targeting/attack,
		/datum/pet_command/point_targeting/breed/gutlunch,
		/datum/pet_command/follow,
		/datum/pet_command/point_targeting/fetch,
		/datum/pet_command/mine_walls,
	)

/mob/living/basic/mining/gutlunch/warrior/Initialize(mapload)
	. = ..()
	roll_stats(melee_damage_lower, speed, maxHealth)
	AddComponent(/datum/component/obeys_commands, pet_commands)
	AddElement(/datum/element/wall_tearer, allow_reinforced = FALSE)

/mob/living/basic/mining/gutlunch/milk/update_overlays(new_udder_volume, max_udder_volume)
	. = ..()
	if(new_udder_volume != max_udder_volume)
		return
	. += full_udder

/mob/living/basic/mining/gutlunch/grub
	name = "grublunch"
	possible_colors = list("#cc9797", "#b74c4c")
	can_breed = FALSE
	gender = NEUTER
	ai_controller = /datum/ai_controller/basic_controller/gutlunch/gutlunch_baby
	current_size = 0.6
	///list of stats we inherited
	var/datum/gutlunch_inherited_stats/inherited_stats

/mob/living/basic/mining/gutlunch/grub/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/growth_and_differentiation,\
		growth_time = 3 MINUTES,\
		growth_probability = 100,\
		lower_growth_value = 0.5,\
		upper_growth_value = 1,\
		signals_to_kill_on = list(COMSIG_MOB_CLIENT_LOGIN),\
		optional_checks = CALLBACK(src, PROC_REF(ready_to_grow)),\
		optional_grow_behavior = CALLBACK(src, PROC_REF(determine_growth_path)),\
	)

/mob/living/basic/mining/gutlunch/grub/proc/ready_to_grow()
	return (stat == CONSCIOUS)

/mob/living/basic/mining/gutlunch/grub/proc/determine_growth_path()
	var/final_type = prob(50) ? /mob/living/basic/mining/gutlunch/warrior : /mob/living/basic/mining/gutlunch/milk
	var/mob/living/basic/mining/gutlunch/grown_mob = new final_type(get_turf(src))
	if(grown_mob.gender == MALE && inherited_stats)
		grown_mob.roll_stats(inherited_stats.attack, inherited_stats.speed, inherited_stats.health)
	qdel(src)

#undef MAX_ATTACK_DIFFERENCE
#undef MAX_LOWER_ATTACK
#undef MINIMUM_POSSIBLE_SPEED
#undef MAX_POSSIBLE_HEALTH
