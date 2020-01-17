/mob/living/simple_animal/hostile/regalrat
	name = "Regal Rat"
	desc = "An evolved rat, created through some strange science. It leads nearby rats with deadly efficiency to protect its kingdom."
	icon_state = "regalrat"
	icon_living = "regalrat"
	icon_dead = "regalrat_dead"
	gender = NEUTER
	speak_chance = 0
	turns_per_move = 5
	maxHealth = 70
	health = 70
	see_in_dark = 5
	butcher_results = list(/obj/item/clothing/head/crown = 1,)
	response_help_continuous = "glares at"
	response_help_simple = "glare at"
	response_disarm_continuous = "skoffs at"
	response_disarm_simple = "skoff at"
	response_harm_continuous = "slashes"
	response_harm_simple = "slash"
	melee_damage_lower = 13
	melee_damage_upper = 15
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/weapons/punch1.ogg'
	ventcrawler = VENTCRAWLER_ALWAYS
	faction = list("rat")
	var/datum/action/innate/regalrat/coffer

/mob/living/simple_animal/hostile/regalrat/Initialize()
	. = ..()
	coffer = new
	coffer.Grant(src)

/datum/action/innate/regalrat
	background_icon_state = "bg_default"

/datum/action/innate/regalrat/coffer
	name = "Fill Coffers"
	desc = "Your newly granted regality and poise let you scavenge for lost junk, but more importantly, cheese."

/datum/action/innate/regalrat/coffer/Activate()
	var/mob/living/simple_animal/hostile/regalrat/R = owner
	var/turf/T = get_turf(R)
	var/loot = rand(1,100) //100 different crates with varying chances of spawning
	switch(loot)
		if(1 to 5)
			to_chat(R, "<span class='notice'>Score! You find some cheese!</span>")
			new /obj/item/reagent_containers/food/snacks/cheesewedge(T)
		if(6 to 20)
			to_chat(R, "<span class='notice'>You find some leftover coins. More for the royal treasury!</span>")
			new /obj/item/coin/silver(T)
			new /obj/item/coin/iron(T)
		if(21)
			to_chat(R, "<span class='notice'>You find a... Hunh. This coin doesn't look right.</span>")
			var/rarecoin = rand(1,2)
			if (rarecoin == 1)
				new /obj/item/coin/twoheaded(T)
			else
				new /obj/item/coin/antagtoken(T)
		if(22 to 40)
			to_chat(R, "<span class='notice'>You just find more garbage and dirt. Lovely, but beneath you now.</span>")
			new /obj/effect/decal/cleanable/dirt(T)
			new /obj/item/trash/can/food/beans(T)
		if(41 to 100)
			to_chat(R, "<span class='notice'>Drat. Nothing.</span>")
