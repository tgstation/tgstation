/mob/living/basic/chicken/clown
	icon_suffix = "clown"

	breed_name_female = "Henk"
	breed_name_male = "Henkster"

	egg_type = /obj/item/food/egg/clown
	mutation_list = list(/datum/mutation/ranching/chicken/mime, /datum/mutation/ranching/chicken/clown_sad)
	minimum_living_happiness = -2000
	liked_foods = list(/obj/item/food/grown/banana  = 3)

	targeted_ability_planning_tree = /datum/ai_planning_subtree/targeted_mob_ability/min_range/chicken/clown

	targeted_ability = /datum/action/cooldown/mob_cooldown/chicken/honk

	book_desc = "Tries very hard to be funny and occasionally honks."
/obj/item/food/egg/clown
	name = "Clown Egg?"
	food_reagents = list(/datum/reagent/water = 50)
	icon_state = "clown"

	layer_hen_type = /mob/living/basic/chicken/clown

/obj/item/food/egg/clown/attack_self(mob/user)
	. = ..()
	to_chat(user, "Upon further inspection the [src.name] doesn't appear to be an egg at all instead it seems to be a water ballon?")
	var/obj/item/reagent_containers/water_balloon/clown_egg/replacer = new /obj/item/reagent_containers/water_balloon/clown_egg
	qdel(src)
	user.put_in_hands(replacer)

/obj/item/reagent_containers/water_balloon/clown_egg
	name = "Clown Egg?"
	list_reagents = list(/datum/reagent/water = 50)
	volume = 50
	icon_state = "egg"
	icon = 'monkestation/icons/obj/ranching/eggs.dmi'
	spillable = TRUE


// generic water balloon impact handler, need to move to new file if i make other water balloons
/obj/item/reagent_containers/water_balloon/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, force, gentle = FALSE, quickstart = TRUE)
	. = ..()
	visible_message("<span class='notice'>The [src.name] bursts upon impact with \the [target.name]!</span>")
	qdel(src)


/datum/action/cooldown/mob_cooldown/chicken/honk
	name = "Prank Target"
	desc = "Honk."
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "eye"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	cooldown_time = 30 SECONDS
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	shared_cooldown = NONE
	what_range = /datum/ai_behavior/targeted_mob_ability/min_range/chicken/melee

/datum/action/cooldown/mob_cooldown/chicken/honk/Activate(mob/living/target)
	target.slip(5 SECONDS, FALSE)
	StartCooldown()
	return TRUE
