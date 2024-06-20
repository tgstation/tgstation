/obj/projectile/energy/flora
	damage = 0
	damage_type = TOX
	armor_flag = ENERGY

/obj/projectile/energy/flora/on_hit(atom/target, blocked, pierce_hit)
	if(!isliving(target))
		return ..()

	var/mob/living/hit_plant = target
	if(!(hit_plant.mob_biotypes & MOB_PLANT))
		hit_plant.show_message(span_notice("The radiation beam dissipates harmlessly through your body."))
		return BULLET_ACT_BLOCK

	. = ..()
	if(. == BULLET_ACT_HIT && blocked < 100)
		on_hit_plant_effect(target)

	return .

/// Called when we hit a mob with plant biotype
/obj/projectile/energy/flora/proc/on_hit_plant_effect(mob/living/hit_plant)
	return

/obj/projectile/energy/flora/mut
	name = "alpha somatoray"
	icon_state = "energy"

/obj/projectile/energy/flora/mut/on_hit_plant_effect(mob/living/hit_plant)
	if(prob(85))
		hit_plant.adjustFireLoss(rand(5, 15))
		hit_plant.show_message(span_userdanger("The radiation beam singes you!"))
		return

	hit_plant.adjustToxLoss(rand(3, 6))
	hit_plant.Paralyze(10 SECONDS)
	hit_plant.visible_message(
		span_warning("[hit_plant] writhes in pain as [hit_plant.p_their()] vacuoles boil."),
		span_userdanger("You writhe in pain as your vacuoles boil!"),
		span_hear("You hear the crunching of leaves."),
	)
	if(iscarbon(hit_plant) && hit_plant.has_dna())
		var/mob/living/carbon/carbon_plant = hit_plant
		if(prob(80))
			carbon_plant.easy_random_mutate(NEGATIVE + MINOR_NEGATIVE)
		else
			carbon_plant.easy_random_mutate(POSITIVE)
		carbon_plant.random_mutate_unique_identity()
		carbon_plant.random_mutate_unique_features()
		carbon_plant.domutcheck()

/obj/projectile/energy/flora/yield
	name = "beta somatoray"
	icon_state = "energy2"

/obj/projectile/energy/flora/yield/on_hit_plant_effect(mob/living/hit_plant)
	hit_plant.set_nutrition(min(hit_plant.nutrition + 30, NUTRITION_LEVEL_FULL))

/obj/projectile/energy/flora/evolution
	name = "gamma somatoray"
	icon_state = "energy3"

/obj/projectile/energy/flora/evolution/on_hit_plant_effect(mob/living/hit_plant)
	hit_plant.show_message(span_notice("The radiation beam leaves you feeling disoriented!"))
	hit_plant.set_dizzy_if_lower(30 SECONDS)
	hit_plant.emote("flip")
	hit_plant.emote("spin")
