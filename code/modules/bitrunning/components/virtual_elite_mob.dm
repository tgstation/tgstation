/// Removes loot tables from megafauna and lowers their health.
/datum/element/virtual_elite_mob

/datum/element/virtual_elite_mob/Attach(datum/target)
	. = ..()
	if(!ismegafauna(target))
		return ELEMENT_INCOMPATIBLE

	var/mob/living/simple_animal/hostile/megafauna/boss = target

	var/new_max = clamp(boss.maxHealth * 0.5, 600, 1200)
	boss.maxHealth = new_max
	boss.health = new_max
	boss.true_spawn = FALSE
	boss.loot.Cut()
	boss.loot += /obj/structure/closet/crate/secure/bitrunning/encrypted
	boss.crusher_loot.Cut()
	boss.crusher_loot += /obj/structure/closet/crate/secure/bitrunning/encrypted
