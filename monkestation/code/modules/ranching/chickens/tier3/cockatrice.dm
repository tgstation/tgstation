/mob/living/simple_animal/chicken/cockatrice
	icon_suffix = "cockatrice"

	breed_name_male = "Cockatrice"
	breed_name_female = "Cockatrice"

	ai_controller = /datum/ai_controller/chicken/hostile
	health = 150
	maxHealth = 150
	melee_damage = 10
	obj_damage = 10

	projectile_type = /obj/item/projectile/magic/venomous_spit
	shoot_prob = 10

	egg_type = /obj/item/food/egg/cockatrice

	book_desc = "Part lizard, part chicken, part bat. The Males of this species are capable of spitting a venom that will petrify you temporarily, and are very hostile."
/obj/item/food/egg/cockatrice
	name = "Petrifying Egg"
	icon_state = "cockatrice"

	layer_hen_type = /mob/living/simple_animal/chicken/cockatrice

/obj/item/food/egg/cockatrice/consumed_egg(datum/source, mob/living/eater, mob/living/feeder)
	. = ..()
	eater.apply_status_effect(PETRIFICATION_SPIT)

/datum/status_effect/ranching/cockatrice_eaten
	id= "cockatrice_egg"
	duration = 60 SECONDS
	var/obj/effect/proc_holder/spell/power = /obj/effect/proc_holder/spell/aimed/venomous_spit

/datum/status_effect/ranching/cockatrice_eaten/on_apply()
	power = new power()
	power.action_background_icon_state = "bg_tech_blue_on"
	power.panel = "Spell"
	owner.AddSpell(power)
	return ..()

/datum/status_effect/ranching/cockatrice_eaten/on_remove()
	owner.RemoveSpell(power)

/obj/effect/proc_holder/spell/aimed/venomous_spit
	name = "Venomous Spit"
	desc = "You Spit petrifying venom at your opponents."

	clothes_req = FALSE
	range = 20
	charge_max = 30 SECONDS
	action_icon_state = "charge"

	base_icon_state = "projectile"
	active_icon_state = "projectile"

	projectile_amount = 1
	projectile_type = /obj/item/projectile/magic/venomous_spit

/mob/living/simple_animal/chicken/cockatrice/Initialize(mapload)
	. = ..()
	if(gender == FEMALE)
		ai_controller.blackboard[BB_CHICKEN_AGGRESSIVE] = FALSE

/obj/item/ammo_casing/venomous_spit
	projectile_type = /obj/item/projectile/magic/venomous_spit

/obj/item/projectile/magic/venomous_spit
	name = "venomous spit"
	icon_state = "ion"
	damage = 5
	damage_type = BURN

/obj/item/projectile/magic/venomous_spit/on_hit(atom/target, blocked)
	if(iscarbon(target))
		var/mob/living/carbon/user = target
		user.petrify(10)
