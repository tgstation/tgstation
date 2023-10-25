/datum/element/virtual_elite_mob

/datum/element/virtual_elite_mob/Attach(datum/target)
	. = ..()
	if(!ismegafauna(target))
		return

	var/mob/living/simple_animal/hostile/megafauna/boss = target

	var/new_max = FLOOR(ROUND_UP(boss.maxHealth * 0.5), 500)
	boss.maxHealth = new_max
	boss.health = new_max
	boss.true_spawn = FALSE

	if(istype(target, /mob/living/simple_animal/hostile/megafauna/legion)) // Sorry, legion has a weird loot system
		var/mob/living/simple_animal/hostile/megafauna/legion/skullguy = target
		skullguy.legion_loot = /obj/structure/closet/crate/secure/bitrunning/encrypted
		return

	boss.loot.Cut()
	boss.loot += /obj/structure/closet/crate/secure/bitrunning/encrypted
	boss.crusher_loot.Cut()
	boss.crusher_loot += /obj/structure/closet/crate/secure/bitrunning/encrypted
