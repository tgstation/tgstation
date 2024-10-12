/obj/item/melee/baton
	/// For use with jousting. For each usable jousting tile, increase the stamina damage of the jousting hit by this much.
	var/stamina_damage_per_jousting_tile = 2

/obj/item/melee/baton/Initialize(mapload)
	. = ..()

	add_jousting_component()

/// Component adder proc for custom behavior, without needing to add more vars.
/obj/item/melee/baton/proc/add_jousting_component()
	AddComponent(/datum/component/jousting, damage_boost_per_tile = 0, knockdown_chance_per_tile = 6)

/// For jousting. Called when a joust is considered successfully done.
/obj/item/melee/baton/proc/on_successful_joust(mob/living/target, mob/user, usable_charge)
	target.apply_damage(stamina_damage_per_jousting_tile * usable_charge, STAMINA)
