// Ported from Citadel Station

/mob/living/simple_animal/banana_spider
	name = "banana spider"
	desc = "What the fuck is this abomination?"
	icon = 'modular_skyrat/master_files/icons/mob/newmobs.dmi'
	icon_state = "bananaspider"
	icon_dead = "bananaspider_peel"
	health = 1
	maxHealth = 1
	turns_per_move = 5			//this isn't player speed =|
	speed = 2				//this is player speed
	loot = list(/obj/item/reagent_containers/food/snacks/deadbanana_spider)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 270
	maxbodytemp = INFINITY
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	speak_emote = list("chitters")
	mouse_opacity = 2
	density = TRUE
	verb_say = "chitters"
	verb_ask = "chitters inquisitively"
	verb_exclaim = "chitters loudly"
	verb_yell = "chitters loudly"
	var/squish_chance = 50
	var/projectile_density = TRUE		//griffons get shot
	del_on_death = TRUE

/mob/living/simple_animal/banana_spider/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/slippery, 40)

/obj/item/reagent_containers/food/snacks/deadbanana_spider
	name = "dead banana spider"
	desc = "Thank god it's gone...but it does look slippery."
	icon = 'modular_skyrat/master_files/icons/mob/newmobs.dmi'
	icon_state = "bananaspider_peel"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 2)
	foodtype = GROSS | MEAT | RAW
	grind_results = list(/datum/reagent/blood = 20, /datum/reagent/liquidgibs = 5)
	juice_results = list(/datum/reagent/consumable/banana = 10)


/obj/item/reagent_containers/food/snacks/deadbanana_spider/Initialize()
	. = ..()
	AddComponent(/datum/component/slippery, 20)

/mob/living/simple_animal/hostile/giant_spider/badnana_spider
	name = "badnana spider"
	desc = "WHY WOULD GOD ALLOW THIS?!"
	icon = 'modular_skyrat/master_files/icons/mob/newmobs.dmi'
	icon_state = "badnanaspider" //created by Coldstorm on the Skyrat Discord
	icon_living = "badnanaspider"
	icon_dead = "badnanaspider_d"
	maxHealth = 40
	health = 40
	melee_damage_lower = 5
	melee_damage_upper = 5
	move_to_delay = 4
	speed = -0.5
	faction = list("spiders")

/mob/living/simple_animal/hostile/giant_spider/badnana_spider/AttackingTarget()
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		carbon_target.reagents.add_reagent(/datum/reagent/consumable/laughter, 10)

