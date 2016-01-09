/mob/living/simple_animal/hostile/alien
	name = "alien hunter"
	desc = "Hiss!"
	icon = 'icons/mob/alien.dmi'
	icon_state = "alienh_s"
	icon_living = "alienh_s"
	icon_dead = "alienh_dead"
	icon_gib = "syndicate_gib"
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 0
	loot = list(/obj/effect/landmark/mobcorpse/alien/hunter)
	del_on_death = 1
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "slashes"
	speak_emote = list("hisses")
	a_intent = "harm"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	faction = list("alien")
	status_flags = CANPUSH
	minbodytemp = 0
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	unique_name = 1
	gold_core_spawnable = 0

/mob/living/simple_animal/hostile/alien/drone
	name = "alien drone"
	icon_state = "aliend_s"
	icon_living = "aliend_s"
	icon_dead = "aliend_dead"
	health = 60
	melee_damage_lower = 15
	melee_damage_upper = 15
	loot = list(/mob/living/carbon/alien/humanoid/drone)
	var/plant_cooldown = 30
	var/plants_off = 0

/mob/living/simple_animal/hostile/alien/drone/handle_automated_action()
	if(!..()) //AIStatus is off
		return
	plant_cooldown--
	if(AIStatus == AI_IDLE)
		if(!plants_off && prob(10) && plant_cooldown<=0)
			plant_cooldown = initial(plant_cooldown)
			SpreadPlants()

/mob/living/simple_animal/hostile/alien/sentinel
	name = "alien sentinel"
	icon_state = "aliens_s"
	icon_living = "aliens_s"
	icon_dead = "aliens_dead"
	health = 120
	melee_damage_lower = 15
	melee_damage_upper = 15
	loot = list(/mob/living/carbon/alien/humanoid/sentinel)
	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	projectiletype = /obj/item/projectile/neurotox
	projectilesound = 'sound/weapons/pierce.ogg'


/mob/living/simple_animal/hostile/alien/royal
	icon = 'icons/mob/alienqueen.dmi'
	pixel_x = -16
	layer = 6
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/slab/xeno = 20, /obj/item/stack/sheet/animalhide/xeno = 3)
	melee_damage_lower = 15
	melee_damage_upper = 15
	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	move_to_delay = 4
	mob_size = MOB_SIZE_LARGE
	projectiletype = /obj/item/projectile/neurotox
	loot = list()
	projectilesound = 'sound/weapons/pierce.ogg'
	status_flags = 0
	unique_name = 0
	ventcrawler = 0 //pull over that ass too fat
	pressure_resistance = 200 //Because big, stompy xenos should not be blown around like paper.

/mob/living/simple_animal/hostile/alien/royal/praetorian
	name = "alien praetorian"
	maxHealth = 250
	health = 250
	icon_state = "alienp"
	icon_living = "alienp"
	icon_dead = "alienp_dead"
	loot = list(/mob/living/carbon/alien/humanoid/royal/praetorian)

/mob/living/simple_animal/hostile/alien/royal/queen
	name = "alien queen"
	icon_state = "alienq"
	icon_living = "alienq"
	icon_dead = "alienq_dead"
	maxHealth = 400
	health = 400
	loot = list(/mob/living/carbon/alien/humanoid/royal/queen)

	var/sterile = 1
	var/plants_off = 0
	var/egg_cooldown = 30
	var/plant_cooldown = 30



/mob/living/simple_animal/hostile/alien/royal/queen/handle_automated_action()
	if(!..()) //AIStatus is off
		return
	egg_cooldown--
	plant_cooldown--
	if(AIStatus == AI_IDLE)
		if(!plants_off && prob(10) && plant_cooldown<=0)
			plant_cooldown = initial(plant_cooldown)
			SpreadPlants()
		if(!sterile && prob(10) && egg_cooldown<=0)
			egg_cooldown = initial(egg_cooldown)
			LayEggs()

/mob/living/simple_animal/hostile/alien/proc/SpreadPlants()
	if(!isturf(loc) || istype(loc, /turf/space))
		return
	if(locate(/obj/structure/alien/weeds/node) in get_turf(src))
		return
	visible_message("<span class='alertalien'>[src] has planted some alien weeds!</span>")
	new /obj/structure/alien/weeds/node(loc)

/mob/living/simple_animal/hostile/alien/proc/LayEggs()
	if(!isturf(loc) || istype(loc, /turf/space))
		return
	if(locate(/obj/structure/alien/egg) in get_turf(src))
		return
	visible_message("<span class='alertalien'>[src] has laid an egg!</span>")
	new /obj/structure/alien/egg(loc)

/obj/item/projectile/neurotox
	name = "neurotoxin"
	damage = 30
	icon_state = "toxin"

/mob/living/simple_animal/hostile/alien/death(gibbed)
	..(gibbed)
	visible_message("[src] lets out a waning guttural screech, green blood bubbling from its maw...")
	playsound(src, 'sound/voice/hiss6.ogg', 100, 1)

/mob/living/simple_animal/hostile/alien/handle_temperature_damage()
	if(bodytemperature < minbodytemp)
		adjustBruteLoss(2)
	else if(bodytemperature > maxbodytemp)
		adjustBruteLoss(20)
