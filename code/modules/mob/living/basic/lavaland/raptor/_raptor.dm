GLOBAL_LIST_INIT(raptor_inherit_traits, list(
	BB_BASIC_DEPRESSED = "Depressed",
	BB_RAPTOR_MOTHERLY = "Motherly",
	BB_RAPTOR_PLAYFUL = "Playful",
	BB_RAPTOR_COWARD = "Coward",
))

GLOBAL_LIST_EMPTY(raptor_population)

/mob/living/basic/raptor
	name = "raptor"
	desc = "A trusty, powerful steed. Taming it might prove difficult..."
	icon = 'icons/mob/simple/lavaland/raptor_big.dmi'
	icon_state = "raptor_red"
	base_icon_state = "raptor"
	pixel_w = -12
	base_pixel_w = -12
	speed = 0.5
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	maxHealth = 200
	health = 200
	melee_damage_lower = 10
	melee_damage_upper = 15
	combat_mode = TRUE
	mob_size = MOB_SIZE_LARGE
	head_icon = 'icons/mob/clothing/back/pets_back.dmi'
	worn_slot_flags = ITEM_SLOT_BACK
	held_w_class = WEIGHT_CLASS_BULKY
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = BODYTEMP_COLD_ICEBOX_SAFE
	maximum_survivable_temperature = INFINITY
	attack_verb_continuous = "pecks"
	attack_verb_simple = "chomp"
	attack_sound = 'sound/items/weapons/punch1.ogg'
	faction = list(FACTION_RAPTOR, FACTION_NEUTRAL)
	speak_emote = list("screeches")
	butcher_results = list(
		/obj/item/food/meat/slab/chicken = 4,
		/obj/item/stack/sheet/bone = 2,
	)
	// AI controller is set by our color
	ai_controller = null
	/// Can this raptor breed?
	var/can_breed = TRUE
	/// Should we change offsets on direction change?
	var/change_offsets = TRUE
	/// Pet commands when we tame the raptor
	var/static/list/pet_commands = list(
		/datum/pet_command/breed,
		/datum/pet_command/idle,
		/datum/pet_command/move,
		/datum/pet_command/free,
		/datum/pet_command/attack,
		/datum/pet_command/follow,
		/datum/pet_command/fetch,
	)
	/// Can we wear a collar? If so, what is our icon state prefix for it?
	var/collar_state = "raptor"
	/// Raptor color datum assigned to this raptor, this is a singleton
	var/datum/raptor_color/raptor_color = null
	/// Are we an adult, youngling or baby?
	var/growth_stage = RAPTOR_ADULT
	/// Our current growth progress towards the next stage if we're a youngling or a baby
	var/growth_progress = 0
	/// Probability of getting progress in the baby phase each second
	var/growth_probability = 80
	/// Food types that we can consume
	var/static/list/food_types = list(
		/obj/item/stack/ore = 0,
		/obj/item/food/meat = 15,
		/obj/item/food/meat/slab = 25,
		/obj/item/food/meat/slab/spider = -15, // Toxic meats
		/obj/item/food/meat/slab/xeno = -15,
		/obj/item/food/meat/steak = 50,
		/obj/item/food/grown/ash_flora = 10,
		/obj/item/fish = 15,
		/obj/item/organ = 25,
	)
	/// Inheritance datum we store our genetic data in
	var/datum/raptor_inheritance/inherited_stats = null
	/// Current happiness value of the raptor
	var/happiness_percentage = 0

/mob/living/basic/raptor/Initialize(mapload, datum/raptor_color/color_type, datum/raptor_inheritance/passed_stats)
	. = ..()
	inherited_stats = passed_stats || new(src)
	// First thing as to go before tameable in change_growth_stage()
	AddElement(/datum/element/basic_eating, food_types = food_types)
	raptor_color = GLOB.raptor_colors[color_type || raptor_color || pick(GLOB.raptor_colors)]
	raptor_color.setup_raptor(src)

	if (growth_stage == RAPTOR_ADULT)
		raptor_color.setup_adult(src)
	else
		change_growth_stage(growth_stage, RAPTOR_ADULT)

	add_traits(list(TRAIT_ASHSTORM_IMMUNE, TRAIT_SNOWSTORM_IMMUNE, TRAIT_MINING_AOE_IMMUNE), INNATE_TRAIT)
	AddElement(\
		/datum/element/crusher_loot,\
		trophy_type = /obj/item/crusher_trophy/raptor_feather,\
		drop_mod = 100,\
		drop_immediately = FALSE,\
	)

	if (!mapload)
		GLOB.raptor_population += REF(src)

	AddComponent(/datum/component/obeys_commands, pet_commands, list(0, -base_pixel_w))
	AddElement(\
		/datum/element/change_force_on_death,\
		move_resist = MOVE_RESIST_DEFAULT,\
	)
	RegisterSignal(src, COMSIG_MOB_ATE, PROC_REF(on_eat))
	RegisterSignal(src, COMSIG_MOB_PRE_EAT, PROC_REF(on_pre_eat))

	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/ai_flee_while_injured, stop_fleeing_at = 0.5, start_fleeing_below = 0.2)

	if (can_breed)
		add_breeding_component()

	// Babies handle it in their change_growth_stage
	if (growth_stage != RAPTOR_BABY)
		update_blackboard()

	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_CLAW)
	RegisterSignal(src, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_dir_change))
	RegisterSignal(src, COMSIG_LIVING_SCOOPED_UP, PROC_REF(on_picked_up))
	adjust_offsets(dir)
	add_happiness_component()

/mob/living/basic/raptor/Destroy()
	raptor_color = null
	GLOB.raptor_population -= REF(src)
	return ..()

/mob/living/basic/raptor/death(gibbed)
	. = ..()
	GLOB.raptor_population -= REF(src)

/mob/living/basic/raptor/buckle_mob(mob/living/target, force = FALSE, check_loc = TRUE, buckle_mob_flags= NONE)
	if(!iscarbon(target))
		return
	return ..()

/mob/living/basic/raptor/proc/on_dir_change(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	adjust_offsets(new_dir)

/mob/living/basic/raptor/proc/adjust_offsets(direction)
	if (!change_offsets)
		return

	switch (direction)
		if (NORTH, SOUTH)
			add_offsets(RAPTOR_INNATE_SOURCE, w_add = 0, animate = FALSE)
		if (EAST, SOUTHEAST, NORTHEAST)
			add_offsets(RAPTOR_INNATE_SOURCE, w_add = -8, animate = FALSE)
		if (WEST, SOUTHWEST, NORTHWEST)
			add_offsets(RAPTOR_INNATE_SOURCE, w_add = 8, animate = FALSE)

/mob/living/basic/raptor/examine(mob/user)
	. = ..()
	if (stat == DEAD)
		return

	switch (health / maxHealth)
		if (0 to 0.2)
			. += span_italics(span_bolddanger("[p_They()] [p_are()] gruesomly wounded, barely staying up on [p_their()] feet!"))
		if (0.2 to 0.4)
			. += span_danger("[p_They()] [p_have()] heavy injuries and open wounds all around [p_their()] body!")
		if (0.4 to 0.6)
			. += span_warning("[p_They()] [p_are()] noticeably hurt, limping from [p_their()] cuts and bruises.")
		if (0.6 to 0.8)
			. += span_warning("[p_They()] [p_are()] visibly injured, a few bruises and cuts showing between [p_their()] feathers.")
		if (0.8 to 0.999)
			. += span_notice("[p_They()] [p_have()] a few minor bruises and scratches.")

/mob/living/basic/raptor/Life(seconds_per_tick, times_fired)
	. = ..()
	if (growth_stage != RAPTOR_BABY || HAS_TRAIT(src, TRAIT_STASIS) || stat == DEAD)
		return
	if (!SPT_PROB(growth_probability * (1 + happiness_percentage * RAPTOR_GROWTH_HAPPINESS_MULTIPLIER), seconds_per_tick))
		return
	growth_progress += rand(RAPTOR_BABY_GROWTH_LOWER, RAPTOR_BABY_GROWTH_UPPER)
	if (growth_progress >= RAPTOR_GROWTH_REQUIRED)
		change_growth_stage(RAPTOR_YOUNG)
		growth_progress = 0

/mob/living/basic/raptor/early_melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(!.)
		return FALSE
	if(!istype(target, /obj/structure/ore_container/food_trough/raptor_trough))
		return TRUE
	var/obj/ore_food = locate(/obj/item/stack/ore) in target
	if(isnull(ore_food))
		balloon_alert(src, "no food!")
	else
		UnarmedAttack(ore_food, TRUE, modifiers)
	return FALSE

/mob/living/basic/raptor/melee_attack(mob/living/target, list/modifiers, ignore_cooldown)
	if (!combat_mode && istype(target, /mob/living/basic/raptor))
		var/mob/living/basic/raptor/possible_baby = target
		if (possible_baby.growth_stage == RAPTOR_BABY)
			return target.attack_hand(src, list(LEFT_CLICK = TRUE))
	return ..()

/mob/living/basic/raptor/proc/add_breeding_component()
	var/static/list/partner_types = typecacheof(list(/mob/living/basic/raptor))
	var/static/list/baby_types = list(/obj/item/food/egg/raptor_egg = 1)
	AddComponent(\
		/datum/component/breed, \
		can_breed_with = partner_types, \
		baby_paths = baby_types, \
		breed_timer = 3 MINUTES, \
		post_birth = CALLBACK(src, PROC_REF(egg_inherit)), \
	)

/mob/living/basic/raptor/proc/add_happiness_component()
	var/static/list/percentage_callbacks = list(0, 15, 25, 35, 50, 75, 90, 100)
	// Higher happiness cap so it decays slower, about 15 minutes from full to zero
	AddComponent(\
		/datum/component/happiness, \
		maximum_happiness = 900, \
		on_petted_change = 50, \
		on_groom_change = 200, \
		on_eat_change = 150, \
		callback_percentages = percentage_callbacks,\
		happiness_callback = CALLBACK(src, PROC_REF(happiness_change)),\
	)

/mob/living/basic/raptor/proc/happiness_change(percent_value)
	var/attack_boost = round((percent_value - happiness_percentage) * RAPTOR_HAPPINESS_DAMAGE_BOOST, 1)
	melee_damage_lower += attack_boost
	melee_damage_upper += attack_boost
	happiness_percentage = percent_value

/mob/living/basic/raptor/projectile_hit(obj/projectile/hitting_projectile, def_zone, piercing_hit, blocked)
	// Most colors will redirect shots to their rider as to increase their own survivability, and only tank melee attacks
	if (raptor_color.redirect_shots && length(buckled_mobs))
		return buckled_mobs[1].projectile_hit(hitting_projectile, def_zone, piercing_hit, blocked)
	return ..()

/// Pass our genetic data to the egg
/mob/living/basic/raptor/proc/egg_inherit(obj/item/food/egg/raptor_egg/baby_egg, mob/living/basic/raptor/partner)
	var/datum/raptor_inheritance/child_genes = new()
	child_genes.set_parents(src, partner)
	baby_egg.inherited_stats = child_genes
	baby_egg.child_color = get_child_color(partner)
	// Halve our food modifiers every time we breed
	for (var/food_type in inherited_stats.foods_eaten)
		var/list/stat_mods = inherited_stats.foods_eaten[food_type]
		stat_mods["amount"] /= 2
		stat_mods["attack"] /= 2
		stat_mods["health"] /= 2
		stat_mods["speed"] /= 2
		stat_mods["ability"] /= 2
		stat_mods["growth"] /= 2
		var/list/trait_list = stat_mods["traits"]
		for (var/i in 1 to ceil(length(trait_list) / 2))
			trait_list -= pick(trait_list)

		var/list/color_chances = stat_mods["color_chances"]
		for (var/datum/raptor_color/color_type as anything in color_chances)
			color_chances[color_type] = floor(color_chances[color_type] / 2)
			if (!color_chances[color_type])
				color_chances -= color_type

/mob/living/basic/raptor/proc/get_child_color(mob/living/basic/raptor/partner)
	if (raptor_color == partner.raptor_color)
		return raptor_color.type

	if (raptor_color.guaranteed_crossbreeds[partner.raptor_color.type])
		return raptor_color.guaranteed_crossbreeds[partner.raptor_color.type]

	// This should be redundant as they should be mirroring eachother, but just in case
	if (partner.raptor_color.guaranteed_crossbreeds[raptor_color.type])
		return partner.raptor_color.guaranteed_crossbreeds[raptor_color.type]

	// We've got all the colors in our family tree and aren't rolling a guarantee, bingo
	if (length(inherited_stats.parent_colors | partner.inherited_stats.parent_colors | raptor_color.type | partner.raptor_color.type) == length(GLOB.raptor_colors))
		return /datum/raptor_color/black

	var/list/prob_list = list()
	for (var/datum/raptor_color/color_type as anything in GLOB.raptor_colors)
		prob_list[color_type] = color_type::spawn_chance

	var/amount_eaten = 0
	for (var/food_type in inherited_stats.foods_eaten)
		var/list/stat_mods = inherited_stats.foods_eaten[food_type]
		amount_eaten += stat_mods["amount"]

	for (var/food_type in inherited_stats.foods_eaten)
		var/list/stat_mods = inherited_stats.foods_eaten[food_type]
		var/list/color_chances = stat_mods["color_chances"]
		for (var/datum/raptor_color/color_type as anything in color_chances)
			prob_list[color_type] += floor(color_chances[color_type] * stat_mods["amount"])

	return pick_weight(prob_list)

/mob/living/basic/raptor/proc/on_picked_up(mob/living/basic/raptor/source, mob/living/user, obj/item/mob_holder/holder)
	SIGNAL_HANDLER
	// Our inventory code sucks so we have to do this
	holder.icon = 'icons/mob/simple/lavaland/raptor_baby.dmi'
	holder.icon_state = icon_state
	holder.alternate_worn_layer = HEAD_LAYER
	holder.pixel_w = 0
	holder.pixel_z = 0
	holder.base_pixel_w = 0
	holder.base_pixel_z = 0

/mob/living/basic/raptor/proc/on_pre_eat(datum/source, obj/item/potential_food, list/effect_mult)
	SIGNAL_HANDLER

	if (isorgan(potential_food))
		var/obj/item/organ/guts = potential_food
		if (!(guts.organ_flags & ORGAN_EDIBLE) || !(guts.organ_flags & ORGAN_ORGANIC))
			return COMSIG_MOB_CANCEL_EAT

	if (happiness_percentage)
		effect_mult += happiness_percentage * RAPTOR_GROWTH_HAPPINESS_MULTIPLIER

/mob/living/basic/raptor/proc/on_eat(datum/source, atom/food, mob/living/feeder)
	SIGNAL_HANDLER

	if (!istype(food, /obj/item/food))
		return

	var/obj/item/food/meal = food
	var/is_flora = istype(meal, /obj/item/food/grown/ash_flora)
	var/is_meat = (meal.foodtypes & (MEAT|GORE))
	// Babies cannot gain growth from eating meat, only plants, but they get some passively
	if ((!is_meat || growth_stage == RAPTOR_BABY) && !is_flora)
		return

	if (growth_stage == RAPTOR_ADULT)
		return

	// Better meals make your raptor grow faster
	var/growth_value = meal.crafting_complexity * RAPTOR_MEAL_COMPLEXITY_GROWTH_FACTOR + (is_flora ? RAPTOR_GROWTH_BASE_PLANT : RAPTOR_GROWTH_BASE_MEAT)
	growth_progress += growth_value * (1 + inherited_stats.growth_modifier) * (1 + happiness_percentage * RAPTOR_GROWTH_HAPPINESS_MULTIPLIER)
	if (growth_progress >= RAPTOR_GROWTH_REQUIRED)
		change_growth_stage(growth_stage == RAPTOR_BABY ? RAPTOR_YOUNG : RAPTOR_ADULT)
		growth_progress = 0

/// Changes the raptor to a new growth stage. Only should be done forwards, or on raptor init as the first thing before everything else
/// Sorry for the monolith, but splitting it up results in even worse looking code with a ton of duplicate calls and assignments
/// And making a *second* datum is just insanity
/mob/living/basic/raptor/proc/change_growth_stage(new_stage, prev_stage = growth_stage)
	if (new_stage == prev_stage)
		return FALSE

	if (SEND_SIGNAL(src, COMSIG_RAPTOR_GROWTH_STAGE_CHANGE, new_stage, prev_stage) & COMPONENT_CANCEL_RAPTOR_GROWTH)
		return FALSE

	growth_stage = new_stage

	// Visuals
	switch (new_stage)
		if (RAPTOR_BABY)
			name = "baby raptor"
			desc = "Will this grow into something useful?"
			icon = 'icons/mob/simple/lavaland/raptor_baby.dmi'
			base_icon_state = "baby"
			base_pixel_w = 0
			mob_size = MOB_SIZE_TINY
		if (RAPTOR_YOUNG)
			name = "raptor youngling"
			desc = "A young raptor that can grow into a robust, trusty steed. Rather naive at such an age, it shouldn't be too hard to tame."
			icon = 'icons/mob/simple/lavaland/raptor_big.dmi'
			base_icon_state = "young"
			base_pixel_w = initial(base_pixel_w)
			mob_size = MOB_SIZE_HUMAN
		if (RAPTOR_ADULT)
			name = "raptor"
			desc = initial(desc)
			icon = 'icons/mob/simple/lavaland/raptor_big.dmi'
			base_icon_state = "raptor"
			base_pixel_w = initial(base_pixel_w)
			mob_size = initial(mob_size)

	can_be_held = initial(density)
	density = initial(density)
	move_resist = initial(move_resist)
	can_breed = initial(can_breed)
	change_offsets = initial(change_offsets)

	if (new_stage == RAPTOR_ADULT)
		// Adults need to be tamed with skill rather than snacks
		qdel(GetComponent(/datum/component/tameable))
	else // Make us teeny-tiny
		can_be_held = TRUE
		density = FALSE
		can_breed = FALSE
		move_resist = MOVE_RESIST_DEFAULT
		change_offsets = FALSE

		if (prev_stage == RAPTOR_ADULT)
			AddComponent(/datum/component/tameable, food_types = food_types, tame_chance = 25, bonus_tame_chance = 15, unique = TRUE)

	if (change_offsets)
		adjust_offsets(dir)
	else
		remove_offsets(RAPTOR_INNATE_SOURCE, FALSE)

	if (can_breed)
		add_breeding_component()
	else
		qdel(GetComponent(/datum/component/breed))

	var/obj/item/mob_holder/holder = null
	if (istype(loc, /obj/item/mob_holder))
		holder = loc
		if (!can_be_held)
			holder.release()
			holder = null

	if (collar_state)
		RemoveElement(/datum/element/wears_collar, collar_icon = 'icons/mob/simple/lavaland/raptor_big.dmi', collar_icon_state = "[collar_state]_")

	if (new_stage == RAPTOR_BABY)
		collar_state = null
		var/list/friends = ai_controller?.blackboard[BB_FRIENDS_LIST]
		if (friends)
			friends = friends.Copy()
		QDEL_NULL(ai_controller)
		ai_controller = new /datum/ai_controller/basic_controller/baby_raptor(src)
		for (var/old_friend in friends)
			ai_controller.insert_blackboard_key_lazylist(BB_FRIENDS_LIST, old_friend)
		update_blackboard()
		held_w_class = WEIGHT_CLASS_SMALL
		worn_slot_flags = NONE
		holder?.update_weight_class(held_w_class)
	else
		collar_state = base_icon_state
		AddElement(/datum/element/wears_collar, collar_icon = 'icons/mob/simple/lavaland/raptor_big.dmi', collar_icon_state = "[collar_state]_")
		if (prev_stage == RAPTOR_BABY)
			var/list/friends = ai_controller?.blackboard[BB_FRIENDS_LIST]
			if (friends)
				friends = friends.Copy()
			QDEL_NULL(ai_controller)
			ai_controller = new raptor_color.ai_controller(src)
			for (var/old_friend in friends)
				ai_controller.insert_blackboard_key_lazylist(BB_FRIENDS_LIST, old_friend)
			update_blackboard()
		held_w_class = WEIGHT_CLASS_BULKY
		worn_slot_flags = ITEM_SLOT_BACK
		holder?.update_weight_class(held_w_class)

	// And finish the setup on our color's side
	switch (new_stage)
		if (RAPTOR_BABY)
			raptor_color.setup_baby(src)
		if (RAPTOR_YOUNG)
			raptor_color.setup_young(src)
		if (RAPTOR_ADULT)
			raptor_color.setup_adult(src)
	return TRUE

/mob/living/basic/raptor/proc/update_blackboard()
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

	var/static/list/preferred_foods = typecacheof(list(
		/obj/item/food/meat,
		/obj/item/food/grown/ash_flora,
	)) - typecacheof(list( // Don't seek out toxic foods
		/obj/item/food/meat/slab/spider,
		/obj/item/food/meat/slab/xeno,
	))

	ai_controller.set_blackboard_key(BB_BASIC_FOODS, preferred_foods)

	for(var/trait in GLOB.raptor_inherit_traits)
		var/should_inherit = (trait in inherited_stats.personality_traits)
		ai_controller?.set_blackboard_key(trait, should_inherit)

// Raptor types for mappers to use

/mob/living/basic/raptor/red
	icon_state = "raptor_red"
	raptor_color = /datum/raptor_color/red

/mob/living/basic/raptor/purple
	icon_state = "raptor_purple"
	raptor_color = /datum/raptor_color/purple

/mob/living/basic/raptor/green
	icon_state = "raptor_green"
	raptor_color = /datum/raptor_color/green

/mob/living/basic/raptor/white
	icon_state = "raptor_white"
	raptor_color = /datum/raptor_color/white

/mob/living/basic/raptor/black
	icon_state = "raptor_black"
	raptor_color = /datum/raptor_color/black

/mob/living/basic/raptor/yellow
	icon_state = "raptor_yellow"
	raptor_color = /datum/raptor_color/yellow

/mob/living/basic/raptor/blue
	icon_state = "raptor_blue"
	raptor_color = /datum/raptor_color/blue

/mob/living/basic/raptor/young
	growth_stage = RAPTOR_YOUNG

/mob/living/basic/raptor/young/red
	icon_state = "young_red"
	raptor_color = /datum/raptor_color/red

/mob/living/basic/raptor/young/purple
	icon_state = "young_purple"
	raptor_color = /datum/raptor_color/purple

/mob/living/basic/raptor/young/green
	icon_state = "young_green"
	raptor_color = /datum/raptor_color/green

/mob/living/basic/raptor/young/white
	icon_state = "young_white"
	raptor_color = /datum/raptor_color/white

/mob/living/basic/raptor/young/black
	icon_state = "young_black"
	raptor_color = /datum/raptor_color/black

/mob/living/basic/raptor/young/yellow
	icon_state = "young_yellow"
	raptor_color = /datum/raptor_color/yellow

/mob/living/basic/raptor/young/blue
	icon_state = "young_blue"
	raptor_color = /datum/raptor_color/blue

/mob/living/basic/raptor/baby
	icon = 'icons/mob/simple/lavaland/raptor_baby.dmi'
	growth_stage = RAPTOR_BABY

/mob/living/basic/raptor/baby/red
	icon_state = "baby_red"
	raptor_color = /datum/raptor_color/red

/mob/living/basic/raptor/baby/purple
	icon_state = "baby_purple"
	raptor_color = /datum/raptor_color/purple

/mob/living/basic/raptor/baby/green
	icon_state = "baby_green"
	raptor_color = /datum/raptor_color/green

/mob/living/basic/raptor/baby/white
	icon_state = "baby_white"
	raptor_color = /datum/raptor_color/white

/mob/living/basic/raptor/baby/black
	icon_state = "baby_black"
	raptor_color = /datum/raptor_color/black

/mob/living/basic/raptor/baby/yellow
	icon_state = "baby_yellow"
	raptor_color = /datum/raptor_color/yellow

/mob/living/basic/raptor/baby/blue
	icon_state = "baby_blue"
	raptor_color = /datum/raptor_color/blue
