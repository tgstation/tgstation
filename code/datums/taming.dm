///////////////USELESS SNOWFLAKE PAGE DECORATION LOOK AT ME IM SO SPECIAL kill me///////////////
//This datum handles taming mobs, saddling mobs, and riding mobanimal.
//It is accessed by simple animals only, specifically those who (can_tame)
///////////////USELESS SNOWFLAKE PAGE DECORATION LOOK AT ME IM SO SPECIAL kill me///////////////
/datum/taming

	var/taming_progress = 0
	var/required_progress = 100
	var/tame = 0
	var/mob/living/carbon/human/lastfeeder = null
	var/mob/living/carbon/human/owner = null
	var/feed_verb = null



/datum/taming/proc/feed_alone(mob/living/simple_animal/animal, obj/item/weapon/reagent_containers/food/snacks/F)
	if(is_type_in_typecache(F, animal.wanted_objects) && animal.can_tame)
		animal.visible_message("<span class='notice'>[animal] munches up [F].</span>")
		qdel(F)
		taming_progress += 10 //you have to throw food for them first instead of trying to feed them.
	..()

/datum/taming/proc/feed(mob/user, mob/living/simple_animal/animal, obj/item/weapon/reagent_containers/food/snacks/F)
	if(animal.stat == CONSCIOUS && is_type_in_typecache(F, animal.wanted_objects))
		if(!taming_progress)
			user.visible_message("[animal] growls angrily.")
		else
			if(taming_progress < 25)
				feed_verb = "reluctantly"
			if(taming_progress > 50)
				feed_verb = "quickly"
			if(taming_progress > 75)
				feed_verb = "eagerly"
			if(taming_progress >= 100)
				feed_verb = "happily"
				tame()
			user.visible_message("[animal] eats the [F] [feed_verb]")
			qdel(F)
			taming_progress += 15
			lastfeeder = user
			animal.faction = list("neutral")
			addtimer(src, "revert_to_wild", 700)

/datum/taming/proc/revert_to_wild(mob/living/simple_animal/animal)
	if(!tame)
		animal.faction = list("mining")
		taming_progress = 0

/datum/taming/proc/tame(mob/living/simple_animal/animal)
	if(taming_progress >= required_progress && !tame)
		tame = 1
		owner = lastfeeder
		animal.faction = list("neutral")


/datum/taming/proc/apply_saddle(mob/living/simple_animal/animal, obj/item/O)
	if(animal.stat == CONSCIOUS && istype(O, /obj/item/weapon/saddle) && tame)
		animal.add_overlay("[animal.name]_saddled")
		animal.can_buckle = 1
		animal.buckle_lying = 0 //Override for resting buckles
		animal.regenerate_icons()
		qdel(O)
