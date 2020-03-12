/mob/living/simple_animal/hostile/regalrat
	name = "regal rat"
	desc = "An evolved rat, created through some strange science. It leads nearby rats with deadly efficiency to protect its kingdom. Not technically a king."
	icon_state = "regalrat"
	icon_living = "regalrat"
	icon_dead = "regalrat_dead"
	gender = NEUTER
	speak_chance = 0
	turns_per_move = 5
	maxHealth = 70
	health = 70
	see_in_dark = 5
	obj_damage = 10
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
	var/datum/action/cooldown/coffer
	var/datum/action/cooldown/riot
	///Number assigned to rats and mice, checked when determining infighting.
	var/faction_num = 0

/mob/living/simple_animal/hostile/regalrat/Initialize()
	. = ..()
	coffer = new /datum/action/cooldown/coffer
	riot = new /datum/action/cooldown/riot
	coffer.Grant(src)
	riot.Grant(src)
	faction_num = rand(1,999)

/mob/living/simple_animal/hostile/regalrat/handle_automated_action()
	if(prob(20))
		riot.Trigger()
	else if(prob(50))
		coffer.Trigger()
	. = ..()

/mob/living/simple_animal/hostile/regalrat/CanAttack(atom/the_target)
	if(istype(the_target, /mob/living/simple_animal/hostile/regalrat))
		return TRUE
	if(istype(the_target, /mob/living/simple_animal/hostile/rat))
		var/mob/living/simple_animal/hostile/rat/R = the_target
		if(R.faction_num == faction_num)
			return FALSE
		else
			return TRUE
	. = ..()

/**
  *This action creates trash, money, dirt, and cheese.
  */
/datum/action/cooldown/coffer
	name = "Fill Coffers"
	desc = "Your newly granted regality and poise let you scavenge for lost junk, but more importantly, cheese."
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	background_icon_state = "bg_clock"
	button_icon_state = "coffer"
	cooldown_time = 50

/datum/action/cooldown/coffer/Trigger()
	if(!..())
		return FALSE
	var/turf/T = get_turf(owner)
	var/loot = rand(1,100)
	var/static/trashpick = list(/obj/item/cigbutt,
			/obj/item/trash/cheesie,
			/obj/item/trash/candy,
			/obj/item/trash/chips,
			/obj/item/trash/pistachios,
			/obj/item/trash/plate,
			/obj/item/trash/popcorn,
			/obj/item/trash/raisins,
			/obj/item/trash/sosjerky,
			/obj/item/trash/syndi_cakes)
	switch(loot)
		if(1 to 5)
			to_chat(owner, "<span class='notice'>Score! You find some cheese!</span>")
			new /obj/item/reagent_containers/food/snacks/cheesewedge(T)
		if(6)
			to_chat(owner, "<span class='notice'>You find a... Hunh. This coin doesn't look right.</span>")
			var/rarecoin = rand(1,2)
			if (rarecoin == 1)
				new /obj/item/coin/twoheaded(T)
			else
				new /obj/item/coin/antagtoken(T)
		if(7 to 40)
			var/pickedtrash = pick(trashpick)
			to_chat(owner, "<span class='notice'>You just find more garbage and dirt. Lovely, but beneath you now.</span>")
			new /obj/effect/decal/cleanable/dirt(T)
			new pickedtrash(T)
		if(41 to 100)
			to_chat(owner, "<span class='notice'>Drat. Nothing.</span>")
			new /obj/effect/decal/cleanable/dirt(T)
	StartCooldown()

/**
  *This action checks all nearby mice, and converts them into hostile rats. If no mice are nearby, creates a new one.
  */

/datum/action/cooldown/riot
	name = "Raise Army"
	desc = "Raise an army out of the hordes of mice and pests crawling around the maintenance shafts."
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "riot"
	background_icon_state = "bg_clock"
	cooldown_time = 80
	///Checks to see if there are any nearby mice. Does not count Rats.
	var/something_from_nothing = FALSE

/datum/action/cooldown/riot/Trigger()
	if(!..())
		return FALSE
	for(var/mob/living/simple_animal/mouse/M in oview(owner, 5))
		var/mob/living/simple_animal/hostile/rat/R = new /mob/living/simple_animal/hostile/rat(get_turf(M))
		something_from_nothing = TRUE
		if(M.mind && M.stat == CONSCIOUS)
			M.mind.transfer_to(R)
		if(istype(owner,/mob/living/simple_animal/hostile/regalrat))
			var/mob/living/simple_animal/hostile/regalrat/giantrat = owner
			R.faction_num = giantrat.faction_num
		qdel(M)
	if(!something_from_nothing)
		new /mob/living/simple_animal/mouse(owner.loc)
		owner.visible_message("<span class='warning'>[owner] commands a mouse to its side!</span>")
	else
		owner.visible_message("<span class='warning'>[owner] commands its army to action, mutating them into rats!</span>")
	something_from_nothing = FALSE
	StartCooldown()

/mob/living/simple_animal/hostile/rat
	name = "rat"
	desc = "It's a nasty, ugly, evil, disease-ridden rodent with anger issues."
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	speak = list("Skree!","SKREEE!","Squeak?")
	speak_emote = list("squeaks")
	emote_hear = list("Hisses.")
	emote_see = list("runs in a circle.", "stands on its hind legs.")
	melee_damage_lower = 3
	melee_damage_upper = 5
	obj_damage = 5
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	maxHealth = 15
	health = 15
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/mouse = 1)
	density = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	faction = list("rat")
	var/faction_num

/mob/living/simple_animal/hostile/rat/CanAttack(atom/the_target)
	if(istype(the_target, /mob/living/simple_animal/hostile/regalrat))
		var/mob/living/simple_animal/hostile/regalrat/R = the_target
		if(R.faction_num == faction_num)
			return FALSE
		else
			return TRUE
	if(istype(the_target, /mob/living/simple_animal/hostile/rat))
		var/mob/living/simple_animal/hostile/rat/R = the_target
		if(R.faction_num == faction_num)
			return FALSE
		else
			return TRUE
	. = ..()
