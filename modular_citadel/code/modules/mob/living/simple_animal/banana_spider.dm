/obj/item/seeds/banana/Initialize()
    . = ..()
    mutatelist += /obj/item/seeds/banana/exotic_banana


/obj/item/seeds/banana/exotic_banana
	name = "pack of exotic banana seeds"
	desc = "They're seeds that grow into banana trees. However, those bananas might be alive."
	icon = 'modular_citadel/icons/mob/BananaSpider.dmi'
	icon_state = "seed_ExoticBanana"
	species = "banana"
	plantname = "Exotic Banana Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/banana/banana_spider_spawnable
	growing_icon = 'modular_citadel/icons/mob/BananaSpider.dmi'
	icon_dead = "banana-dead"
	mutatelist = list()
	genes = list(/datum/plant_gene/trait/slip)
	reagents_add = list("banana" = 0.1, "potassium" = 0.1, "vitamin" = 0.04, "nutriment" = 0.02)


/obj/item/reagent_containers/food/snacks/grown/banana/banana_spider_spawnable
	seed = /obj/item/seeds/banana/exotic_banana
	name = "banana spider"
	desc = "You do not know what it is, but you can bet the clown would love it."
	icon = 'modular_citadel/icons/mob/BananaSpider.dmi'
	icon_state = "banana"
	item_state = "banana"
	filling_color = "#FFFF00"
	list_reagents = list("nutriment" = 3, "vitamin" = 2)
	foodtype = GROSS | MEAT | RAW | FRUIT
	grind_results = list("blood" = 20, "liquidgibs" = 5)
	juice_results = list("banana" = 0)
	var/awakening = 0


/obj/item/reagent_containers/food/snacks/grown/banana/banana_spider_spawnable/attack_self(mob/user)
	if(awakening || isspaceturf(user.loc))
		return
	to_chat(user, "<span class='notice'>You decide to wake up the banana spider...</span>")
	awakening = 1

	spawn(30)
		if(!QDELETED(src))
			var/mob/living/simple_animal/banana_spider/S = new /mob/living/simple_animal/banana_spider(get_turf(src.loc))
			S.speed += round(10 / seed.potency)
			S.visible_message("<span class='notice'>The banana spider chitters as it stretches its legs.</span>")
			qdel(src)


/mob/living/simple_animal/banana_spider
	icon = 'modular_citadel/icons/mob/BananaSpider.dmi'
	name = "banana spider"
	desc = "What the fuck is this abomination?"
	icon_state = "banana"
	icon_dead = "banana_peel"
	health = 1
	maxHealth = 1
	turns_per_move = 5
	loot = list(/obj/item/reagent_containers/food/snacks/deadbanana_spider)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 270
	maxbodytemp = INFINITY
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	response_help  = "pokes"
	response_disarm = "shoos"
	response_harm   = "splats"
	speak_emote = list("chitters")
	mouse_opacity = 2
	density = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	gold_core_spawnable = FRIENDLY_SPAWN
	verb_say = "chitters"
	verb_ask = "chitters inquisitively"
	verb_exclaim = "chitters loudly"
	verb_yell = "chitters loudly"
	var/squish_chance = 50
	del_on_death = 1


/mob/living/simple_animal/banana_spider/Initialize()
	. = ..()
	var/area/A = get_area(src)
	if(A)
		notify_ghosts("A banana spider has been created in \the [A.name].", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE)
	GLOB.poi_list |= src


/mob/living/simple_animal/banana_spider/attack_ghost(mob/user)
	if(src.key)
		return
	if(CONFIG_GET(flag/use_age_restriction_for_jobs))
		if(!isnum(user.client.player_age))
			return
	if(!SSticker.mode)
		to_chat(user, "Can't become a banana spider before the game has started.")
		return
	var/be_spider = alert("Become a banana spider? (Warning, You can no longer be cloned!)",,"Yes","No")
	if(be_spider == "No" || QDELETED(src) || !isobserver(user))
		return
	src.sentience_act()
	src.key = user.key
	density = TRUE

/mob/living/simple_animal/banana_spider/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/slippery, 80)


/mob/living/simple_animal/banana_spider/Crossed(var/atom/movable/AM)
	. = ..()
	if(ismob(AM))
		if(isliving(AM))
			var/mob/living/A = AM
			if(A.mob_size > MOB_SIZE_SMALL && !(A.movement_type & FLYING))
				if(prob(squish_chance))
					A.visible_message("<span class='notice'>[A] squashed [src].</span>", "<span class='notice'>You squashed [src] under your weight as you fell.</span>")
					adjustBruteLoss(1)
				else
					visible_message("<span class='notice'>[src] avoids getting crushed.</span>")
	else
		if(isstructure(AM))
			if(prob(squish_chance))
				AM.visible_message("<span class='notice'>[src] was crushed under [AM]'s weight as they fell.</span>")
				adjustBruteLoss(1)
			else
				visible_message("<span class='notice'>[src] avoids getting crushed.</span>")

/mob/living/simple_animal/banana_spider/ex_act()
	return

/mob/living/simple_animal/banana_spider/start_pulling()
	return FALSE			//No.

/obj/item/reagent_containers/food/snacks/deadbanana_spider
	name = "dead banana spider"
	desc = "Thank god it's gone...but it does look slippery."
	icon = 'modular_citadel/icons/mob/BananaSpider.dmi'
	icon_state = "banana_peel"
	bitesize = 3
	eatverb = "devours"
	list_reagents = list("nutriment" = 3, "vitamin" = 2)
	foodtype = GROSS | MEAT | RAW
	grind_results = list("blood" = 20, "liquidgibs" = 5)
	juice_results = list("banana" = 0)


/obj/item/reagent_containers/food/snacks/deadbanana_spider/Initialize()
	. = ..()
	AddComponent(/datum/component/slippery, 80)
