/mob/living/simple_animal/chicken/cotton_candy
	icon_suffix = "cotton_candy"

	breed_name = "Cotton Candy"
	egg_type = /obj/item/food/egg/cotton_candy
	mutation_list = list(/datum/mutation/ranching/chicken/dreamsicle)

	unique_ability = CHICKEN_SUGAR_RUSH
	cooldown_time = 40 SECONDS
	ability_prob = 5

	book_desc = "Incredibly fluffy, aswell as hyper. Watch out they will sometimes enter a Sugar Rush which will cause them to bounce around and make other chickens unhappy."
/obj/item/food/egg/cotton_candy
	name = "Sugary Egg"
	icon_state = "cotton_candy"

	layer_hen_type = /mob/living/simple_animal/chicken/cotton_candy

/obj/item/food/egg/cotton_candy/consumed_egg(datum/source, mob/living/eater, mob/living/feeder)
	eater.apply_status_effect(SUGAR_RUSH)


/datum/status_effect/ranching/hen_rush
	id = "hen_rush"
	duration = 30 SECONDS
	tick_interval = 1 SECONDS

/datum/status_effect/ranching/hen_rush/on_apply()
	owner.AddComponent(/datum/component/after_image)
	owner.add_movespeed_modifier("sugar_rush", update=TRUE, priority=100, multiplicative_slowdown=-0.75, blacklisted_movetypes=(FLYING|FLOATING))
	return ..()

/datum/status_effect/ranching/hen_rush/tick()
	var/move_dir = pick(GLOB.alldirs)
	owner.Move(get_step(owner, move_dir), move_dir)
	owner.Move(get_step(owner, move_dir), move_dir)
	owner.Move(get_step(owner, move_dir), move_dir)

/datum/status_effect/ranching/hen_rush/on_remove()
	var/datum/component/after_image = owner.GetComponent(/datum/component/after_image)
	after_image?.RemoveComponent()
	owner.remove_movespeed_modifier("sugar_rush")

/datum/status_effect/ranching/sugar_rush
	id = "sugar_rush"
	duration = 30 SECONDS
	tick_interval = 1 SECONDS

/datum/status_effect/ranching/sugar_rush/on_apply()
	owner.AddComponent(/datum/component/after_image, 2)
	owner.add_movespeed_modifier("sugar_rush", update=TRUE, priority=100, multiplicative_slowdown=-0.75, blacklisted_movetypes=(FLYING|FLOATING))
	return ..()

/datum/status_effect/ranching/sugar_rush/tick()
	var/datum/reagents/owners_reagents = owner.reagents
	if(owners_reagents)
		owners_reagents.add_reagent(/datum/reagent/consumable/sugar, 2)

/datum/status_effect/ranching/sugar_rush/on_remove()
	var/datum/component/after_image = owner.GetComponent(/datum/component/after_image)
	after_image?.RemoveComponent()
	owner.remove_movespeed_modifier("sugar_rush")
