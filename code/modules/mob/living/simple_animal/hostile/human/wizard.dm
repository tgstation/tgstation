/mob/living/simple_animal/hostile/humanoid/wizard
	name = "wizard"
	desc = "An elite troop of the Wizard Federation, trained in casting fireball and teleport."
	icon_state = "wizard"
	icon_living = "wizard"
	icon_dead = null //The corpse disappears!
	speak_chance = 2

	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "punches"

	corpse = null
	items_to_drop = list()

	ranged = 1
	ranged_message = null
	ranged_cooldown_cap = 5
	retreat_distance = 6
	minimum_distance = 6
	projectiletype = /obj/item/projectile/simple_fireball
	gender = MALE

	faction = "wizard"

/mob/living/simple_animal/hostile/humanoid/wizard/New()
	..()

	name = "[pick(wizard_first)] [pick(wizard_second)]"
	speak = list("Your souls shall suffer!", "No mortals shall be spared.", "My magic will tear you apart!", "Prepare to face the almighty [name]!")

/mob/living/simple_animal/hostile/humanoid/wizard/Die()
	src.say("SCYAR NILA [pick("AI UPLOAD", "SECURE ARMORY", "BAR", "PRIMARY TOOL STORAGE", "INCINERATOR", "CHAPEL", "FORE STARBOARD MAINTENANCE", "WIZARD FEDERATION")]")
	var/obj/effect/effect/smoke/S = new /obj/effect/effect/smoke(get_turf(src))
	S.time_to_live = 20 //2 seconds instead of full 10

	..()
	return qdel(src)

/mob/living/simple_animal/hostile/humanoid/wizard/OpenFire()
	src.say("ONI[pick(" ","`")]SOMA")
	..()
