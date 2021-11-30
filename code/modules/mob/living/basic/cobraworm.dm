/mob/living/basic/cobraworm
	name = "tiziran cobraworm"
	desc = "A wormlike creature from the Tiziran crudlands. It is commonly encounted near bone heaps, plastomiddens and compost basins. Its noxious spit is feared amongst Tirizan scourjocks."
	icon = 'icons/mob/cobraworm.dmi'
	icon_state = "cobraworm"
	base_icon_state = "cobraworm"
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	maxHealth = 80
	health = 80
	speed = 0
	ranged_ability = /obj/projectile/worm_spit
	melee_damage_lower = 3
	melee_damage_upper = 6
	obj_damage = 10

/mob/living/basic/cobraworm/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/particles/worm_enzymes
	icon = 'icons/effects/particles/worm_enzymes.dmi'
	icon_state = list("enzymes_1" = 2, "enzymes_2" = 2, "enzymes_3" = 2, "enzymes_4" = 1)
	width = 100
	height = 100
	count = 1000
	spawning = 2
	lifespan = 2 SECONDS
	fade = 1 SECONDS
	velocity = list(0, 0.6, 0)
	position = generator("circle", 0, 16, NORMAL_RAND)
	drift = generator("sphere", 0, 4, NORMAL_RAND)
	friction = 0.3
	gravity = list(0, -0.2)
	grow = 0

/obj/projectile/worm_spit
	name = "worm spit"
	icon_state = "worm"
	damage = 4
	damage_type = BURN
	flag = BIO

/obj/projectile/worm_spit/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/venomous, /datum/reagent/nightcrawler_enzymes, 3)
