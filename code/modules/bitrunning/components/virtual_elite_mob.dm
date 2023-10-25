/datum/element/virtual_elite_mob

/datum/element/virtual_elite_mob/Initialize()
	if(!isliving(parent))
		return ELEMENT_INCOMPATIBLE

/datum/element/virtual_elite_mob/Attach(datum/target)
	var/mob/living/simple_animal/hostile/megafauna/boss = parent

	boss.health = ROUND_UP(boss.heath * 0.5)
	boss.maxHealth = ROUND_UP(boss.maxHealth * 0.5)
	boss.true_spawn = FALSE

	if(istype(parent, /mob/living/simple_animal/hostile/megafauna/legion)) // Sorry, legion has a weird loot system
		var/mob/living/simple_animal/hostile/megafauna/legion/skullguy = parent
		skullguy.legion_loot = /obj/structure/closet/crate/secure/bitrunning/encrypted
		return

	boss.loot.Cut()
	boss.loot += /obj/structure/closet/crate/secure/bitrunning/encrypted
	boss.crusher_loot.Cut()
	boss.crusher_loot += /obj/structure/closet/crate/secure/bitrunning/encrypted
