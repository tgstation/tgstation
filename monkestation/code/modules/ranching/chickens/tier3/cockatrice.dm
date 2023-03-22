/mob/living/simple_animal/chicken/cockatrice
	icon_suffix = "cockatrice"

	breed_name_male = "Cockatrice"
	breed_name_female = "Cockatrice"

	ai_controller = /datum/ai_controller/chicken/hostile
	health = 150
	maxHealth = 150
	harm_intent_damage = 10
	obj_damage = 10

	projectile_type = /obj/projectile/magic/venomous_spit
	shoot_prob = 10

	egg_type = /obj/item/food/egg/cockatrice

	book_desc = "Part lizard, part chicken, part bat. The Males of this species are capable of spitting a venom that will petrify you temporarily, and are very hostile."
/obj/item/food/egg/cockatrice
	name = "Petrifying Egg"
	icon_state = "cockatrice"

	layer_hen_type = /mob/living/simple_animal/chicken/cockatrice

/mob/living/simple_animal/chicken/cockatrice/Initialize(mapload)
	. = ..()
	if(gender == FEMALE)
		ai_controller.blackboard[BB_CHICKEN_AGGRESSIVE] = FALSE

/obj/item/ammo_casing/venomous_spit
	projectile_type = /obj/projectile/magic/venomous_spit

/obj/projectile/magic/venomous_spit
	name = "venomous spit"
	icon_state = "ion"
	damage = 5
	damage_type = BURN

/obj/projectile/magic/venomous_spit/on_hit(atom/target, blocked)
	if(iscarbon(target))
		var/mob/living/carbon/user = target
		user.petrify(10)
