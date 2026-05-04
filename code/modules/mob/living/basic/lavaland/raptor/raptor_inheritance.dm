/datum/raptor_inheritance
	/// Inherited parent personality traits
	var/list/personality_traits = list()
	/// Flat damage modifier
	var/attack_modifier = 0
	/// Flat health modifier
	var/health_modifier = 0
	/// Speed modifier, not randomized by default
	var/speed_modifier = 0
	/// Primary ability stat modifier, not randomized by default
	/// Multiplier equates to 1 + this
	var/ability_modifier = 0
	/// Growth rate modifier, not randomized by default
	/// Multiplier equates to 1 + this
	var/growth_modifier = 0
	/// Foods eaten that can affect our child's stats -> stats they modify
	var/list/foods_eaten = list()
	/// List of all colors in our family tree
	var/list/parent_colors = list()

// Owner being set will randomize the stats as it means we're spawned not via an egg
// otherwise wait for set_parents call to inherit genetics
/datum/raptor_inheritance/New(mob/living/basic/raptor/owner)
	. = ..()
	if (!owner)
		return

	attack_modifier = rand(RAPTOR_INHERIT_MIN_ATTACK * 0.5, RAPTOR_INHERIT_MAX_ATTACK * 0.5)
	health_modifier = rand(RAPTOR_INHERIT_MIN_HEALTH * 0.5, RAPTOR_INHERIT_MAX_HEALTH * 0.5)
	var/list/traits_to_pick = GLOB.raptor_inherit_traits.Copy()
	for(var/i in 1 to rand(1, RAPTOR_TRAIT_INHERIT_AMOUNT))
		personality_traits += pick_n_take(traits_to_pick)

/datum/raptor_inheritance/proc/set_parents(mob/living/basic/raptor/mother, mob/living/basic/raptor/father)
	var/datum/raptor_inheritance/mom_stats = mother.inherited_stats
	var/datum/raptor_inheritance/dad_stats = father.inherited_stats

	parent_colors = mom_stats.parent_colors | dad_stats.parent_colors | mother.raptor_color.type | father.raptor_color.type

	var/list/traits_to_pick = list()
	// + so shared traits have double the weight
	for (var/raptor_trait in mom_stats.personality_traits + dad_stats.personality_traits)
		if (!traits_to_pick[raptor_trait])
			traits_to_pick[raptor_trait] = 0
		traits_to_pick[raptor_trait] += 1

	var/attack_mod = 0
	var/health_mod = 0
	var/speed_mod = 0
	var/ability_mod = 0
	var/growth_mod = 0
	var/amount_eaten = 0

	for (var/food_type in foods_eaten)
		var/list/stat_mods = foods_eaten[food_type]
		amount_eaten += stat_mods["amount"]

	for (var/food_type in foods_eaten)
		var/list/stat_mods = foods_eaten[food_type]
		// First multiply stats themselves, then multiply to get a proportion of this food from amount_eaten
		var/amount = stat_mods["amount"] ** 2
		// Eating other foods reduces the effects of a specific one
		attack_mod += stat_mods["attack"] / amount_eaten * amount
		health_mod += stat_mods["health"] / amount_eaten * amount
		speed_mod += stat_mods["speed"] / amount_eaten * amount
		ability_mod += stat_mods["ability"] / amount_eaten * amount
		growth_mod += stat_mods["growth"] / amount_eaten * amount
		var/list/trait_list = stat_mods["traits"]
		for (var/raptor_trait in trait_list)
			if (!traits_to_pick[raptor_trait])
				traits_to_pick[raptor_trait] = 0
			traits_to_pick[raptor_trait] += trait_list[raptor_trait] * stat_mods["amount"]

	// If we don't clamp these, RNG and drift can get wildly out of control and result in polar values
	// and this way we at most get twice the minimum/maximum value, so at least half the rand spread is within the clamp values
	attack_mod = clamp(attack_mod, RAPTOR_INHERIT_MIN_ATTACK, RAPTOR_INHERIT_MAX_ATTACK)
	health_mod = clamp(health_mod, RAPTOR_INHERIT_MIN_HEALTH, RAPTOR_INHERIT_MAX_HEALTH)
	speed_mod = clamp(speed_mod, RAPTOR_INHERIT_MIN_SPEED, RAPTOR_INHERIT_MAX_SPEED)
	ability_mod = clamp(ability_mod, RAPTOR_INHERIT_MIN_MODIFIER, RAPTOR_INHERIT_MAX_MODIFIER)
	growth_mod = clamp(growth_mod, RAPTOR_INHERIT_MIN_MODIFIER, RAPTOR_INHERIT_MAX_MODIFIER)

	attack_modifier = rand((min(mom_stats.attack_modifier, dad_stats.attack_modifier) + min(0, attack_mod)) + RAPTOR_GENETIC_DRIFT * RAPTOR_INHERIT_MIN_ATTACK, (max(mom_stats.attack_modifier, dad_stats.attack_modifier) + max(0, attack_mod)) + RAPTOR_GENETIC_DRIFT * RAPTOR_INHERIT_MAX_ATTACK)
	health_modifier = rand((min(mom_stats.health_modifier, dad_stats.health_modifier) + min(0, health_mod)) + RAPTOR_GENETIC_DRIFT * RAPTOR_INHERIT_MIN_HEALTH, (max(mom_stats.health_modifier, dad_stats.health_modifier) + max(0, health_mod)) + RAPTOR_GENETIC_DRIFT * RAPTOR_INHERIT_MAX_HEALTH)
	speed_modifier = rand((min(mom_stats.speed_modifier, dad_stats.speed_modifier) + min(0, speed_mod)) + RAPTOR_GENETIC_DRIFT * RAPTOR_INHERIT_MIN_SPEED, (max(mom_stats.speed_modifier, dad_stats.speed_modifier) + max(0, speed_mod)) + RAPTOR_GENETIC_DRIFT * RAPTOR_INHERIT_MAX_SPEED)
	ability_modifier = rand((min(mom_stats.ability_modifier, dad_stats.ability_modifier) + min(0, ability_mod)) + RAPTOR_GENETIC_DRIFT * RAPTOR_INHERIT_MIN_MODIFIER, (max(mom_stats.ability_modifier, dad_stats.ability_modifier) + max(0, ability_mod)) + RAPTOR_GENETIC_DRIFT * RAPTOR_INHERIT_MAX_MODIFIER)
	growth_modifier = rand((min(mom_stats.growth_modifier, dad_stats.growth_modifier) + min(0, growth_mod)) + RAPTOR_GENETIC_DRIFT * RAPTOR_INHERIT_MIN_MODIFIER, (max(mom_stats.growth_modifier, dad_stats.growth_modifier) + max(0, growth_mod)) + RAPTOR_GENETIC_DRIFT * RAPTOR_INHERIT_MAX_MODIFIER)

	for(var/i in 1 to min(length(traits_to_pick), RAPTOR_TRAIT_INHERIT_AMOUNT))
		var/chosen_trait = pick_weight(traits_to_pick)
		traits_to_pick -= chosen_trait
		personality_traits += chosen_trait

	attack_modifier = clamp(attack_modifier, RAPTOR_INHERIT_MIN_ATTACK, RAPTOR_INHERIT_MAX_ATTACK)
	health_modifier = clamp(health_modifier, RAPTOR_INHERIT_MIN_HEALTH, RAPTOR_INHERIT_MAX_HEALTH)
	speed_modifier = clamp(speed_modifier, RAPTOR_INHERIT_MIN_SPEED, RAPTOR_INHERIT_MAX_SPEED)
	ability_modifier = clamp(ability_modifier, RAPTOR_INHERIT_MIN_MODIFIER, RAPTOR_INHERIT_MAX_MODIFIER)
	growth_modifier = clamp(growth_modifier, RAPTOR_INHERIT_MIN_MODIFIER, RAPTOR_INHERIT_MAX_MODIFIER)
