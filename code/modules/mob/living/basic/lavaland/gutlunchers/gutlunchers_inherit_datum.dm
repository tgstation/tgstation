///stats we inherit from the parent
/datum/gutlunch_inherited_stats
	///attack we inherited
	var/attack
	///speed we inherited
	var/speed
	///health we inherited
	var/health

/datum/gutlunch_inherited_stats/New(mob/living/basic/parent)
	. = ..()
	attack = parent.melee_damage_lower
	speed = parent.speed
	health = parent.maxHealth
