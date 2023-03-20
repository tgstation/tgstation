/mob/living/simple_animal/chicken/clown
	icon_suffix = "clown"

	breed_name_female = "Henk"
	breed_name_male = "Henkster"

	egg_type = /obj/item/food/egg/clown
	mutation_list = list(/datum/mutation/ranching/chicken/mime, /datum/mutation/ranching/chicken/clown_sad)
	minimum_living_happiness = -2000

	cooldown_time = 30 SECONDS
	unique_ability = CHICKEN_HONK
	ability_prob = 25

	book_desc = "Tries very hard to be funny and occasionally honks."
/obj/item/food/egg/clown
	name = "Clown Egg?"
	food_reagents = list(/datum/reagent/water = 50)
	icon_state = "clown"

	layer_hen_type = /mob/living/simple_animal/chicken/clown

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
/obj/item/reagent_containers/water_balloon/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, quickstart)
	. = ..()
	visible_message("<span class='notice'>The [src.name] bursts upon impact with \the [target.name]!</span>")
	qdel(src)
