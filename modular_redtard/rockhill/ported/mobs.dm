/mob/living/simple_animal/hostile/retaliate
	parent_type = /mob/living/basic/rockhill

/mob/living/simple_animal/hostile/rogue
	parent_type = /mob/living/basic/rockhill

/mob/living/simple_animal/pet
	parent_type = /mob/living/basic/rockhill

/mob/living/carbon/spirit
	parent_type = /mob/living/basic/rockhill
	name = "Wanderer"
	icon = 'modular_redtard/rockhill/icons/roguetown/underworld/enigma_husks.dmi'
	icon_state = "hollow"
	health = 100
	maxHealth = 100
	rogue_mob_intents = list(/datum/intent/unarmed/help, /datum/intent/unarmed/punch)

/mob/living/simple_animal/butterfly
	parent_type = /mob/living/basic/rockhill
	name = "butterfly"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/mob/animal.dmi'
	icon_state = "butterfly"
	icon_living = "butterfly"
	icon_dead = "butterfly_dead"
	health = 2
	maxHealth = 2

/mob/living/simple_animal/chick
	parent_type = /mob/living/basic/rockhill
	name = "\improper chick"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/mob/animal.dmi'
	icon_state = "chick"
	icon_living = "chick"
	icon_dead = "chick_dead"
	health = 3
	maxHealth = 3
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown/wheat)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/fat = 1)

/mob/living/simple_animal/chicken
	parent_type = /mob/living/basic/rockhill
	name = "\improper chicken"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/mob/animal.dmi'
	icon_state = "chicken_brown"
	icon_living = "chicken_brown"
	icon_dead = "chicken_brown_dead"
	health = 15
	maxHealth = 15
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown/wheat, /obj/item/reagent_containers/food/snacks/grown/oat)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat = 1)

/mob/living/simple_animal/hostile/retaliate/bat
	name = "bat"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/mob/animal.dmi'
	icon_state = "bat"
	icon_living = "bat"
	icon_dead = "bat_dead"
	health = 50
	maxHealth = 50
	melee_damage_lower = 6
	melee_damage_upper = 5
	rogue_mob_intents = list(/datum/intent/bite)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 1)

/mob/living/simple_animal/hostile/retaliate/frog
	name = "frog"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/mob/animal.dmi'
	icon_state = "frog"
	icon_living = "frog"
	icon_dead = "frog_dead"
	health = 15
	maxHealth = 15
	melee_damage_lower = 5
	melee_damage_upper = 5

/mob/living/simple_animal/hostile/retaliate/goose
	name = "goose"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/mob/animal.dmi'
	icon_state = "goose"
	icon_living = "goose"
	icon_dead = "goose_dead"
	health = 25
	maxHealth = 25
	melee_damage_lower = 5
	melee_damage_upper = 5
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 2)

/mob/living/simple_animal/hostile/retaliate/rogue/beetle
	name = "giant woolly chafer beetle"
	desc = "A massive beetle covered in thick, woolly fur-like bristles. These gentle giants often travel up from the underdeep in search of food, particularly sweet mushrooms and fungi."
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/beetle.dmi'
	icon_state = "cuddlebug"
	icon_living = "cuddlebug"
	icon_dead = "dead"
	health = 300
	maxHealth = 300
	pixel_x = -8
	pixel_y = 0
	melee_damage_lower = 20
	melee_damage_upper = 35
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 14, ROGUE_STAT_CONSTITUTION = 15)
	rogue_mob_intents = list(/datum/intent/simple/headbutt)
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown/apple, /obj/item/reagent_containers/food/snacks/grown/berries)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak/beetle = 4, /obj/item/natural/hide = 3, /obj/item/natural/fur = 2, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 2, /obj/item/alch/viscera = 2, /obj/item/roguegem/chitin = 3)

/mob/living/simple_animal/hostile/retaliate/rogue/beetle/tame/saddled
	name = "giant woolly chafer beetle"
	desc = "A massive beetle covered in thick, woolly fur-like bristles. These gentle giants often travel up from the underdeep in search of food, particularly sweet mushrooms and fungi."
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/beetle.dmi'
	icon_state = "cuddlebug"
	icon_living = "cuddlebug"
	icon_dead = "dead"
	health = 300
	maxHealth = 300
	pixel_x = -8
	pixel_y = 0
	melee_damage_lower = 20
	melee_damage_upper = 35
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 14, ROGUE_STAT_CONSTITUTION = 15)
	rogue_mob_intents = list(/datum/intent/simple/headbutt)
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown/apple, /obj/item/reagent_containers/food/snacks/grown/berries)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak/beetle = 4, /obj/item/natural/hide = 3, /obj/item/natural/fur = 2, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 2, /obj/item/alch/viscera = 2, /obj/item/roguegem/chitin = 3)

/mob/living/simple_animal/hostile/retaliate/rogue/bigrat
	name = "rous"
	desc = "This is a big rat with beady red eyes, drawn to decay and filth."
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/bigrat.dmi'
	icon_state = "rat"
	icon_living = "rat"
	icon_dead = "rat1"
	health = 65
	maxHealth = 65
	pixel_x = -16
	pixel_y = -8
	melee_damage_lower = 17
	melee_damage_upper = 21
	rogue_defprob = 40
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 9, ROGUE_STAT_CONSTITUTION = 6)
	rogue_mob_intents = list(/datum/intent/simple/bite/bigrat)
	rogue_aggressive = 1
	rogue_retreat_health = 0.3
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks, /obj/item/natural/bone, /obj/item/natural/hide)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak/rat = 1, /obj/item/natural/hide = 1, /obj/item/natural/bone = 2, /obj/item/alch/sinew = 1, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 1, /obj/item/natural/head/rous = 1)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak/rat = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak/rat = 1, /obj/item/natural/hide = 1, /obj/item/natural/bone = 2, /obj/item/alch/sinew = 1, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 1, /obj/item/natural/fur/rat = 1, /obj/item/natural/head/rous = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/bull
	name = "cow"
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/cow.dmi'
	icon_state = "bull"
	icon_living = "bull"
	icon_dead = "bull_dead"
	health = 150
	maxHealth = 150
	melee_damage_lower = 25
	melee_damage_upper = 50
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 12, ROGUE_STAT_CONSTITUTION = 20, ROGUE_STAT_SPEED = 2)
	rogue_mob_intents = list(/datum/intent/simple/headbutt)
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown/wheat, /obj/item/reagent_containers/food/snacks/grown/oat)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 4, /obj/item/natural/hide = 1, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 3, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 2, /obj/item/alch/sinew = 2, /obj/item/natural/bone = 4, /obj/item/alch/viscera = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 6, /obj/item/natural/hide = 2, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 4, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2)

/mob/living/simple_animal/hostile/retaliate/rogue/chicken
	name = "\improper chicken"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/chicken.dmi'
	icon_state = "chicken_brown"
	icon_living = "chicken_brown"
	icon_dead = "chicken_brown_dead"
	health = 15
	maxHealth = 15
	melee_damage_lower = 1
	melee_damage_upper = 8
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 6, ROGUE_STAT_CONSTITUTION = 6, ROGUE_STAT_SPEED = 1)
	rogue_mob_intents = list(/datum/intent/simple/claw)
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown/berries/rogue, /obj/item/natural/worms, /obj/item/reagent_containers/food/snacks/grown/wheat, /obj/item/reagent_containers/food/snacks/grown/oat)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/fat = 1, /obj/item/reagent_containers/food/snacks/rogue/meat/poultry = 1, /obj/item/natural/feather = 1, /obj/item/natural/bone = 2, /obj/item/alch/sinew = 1, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 1)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/poultry = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/fat = 2, /obj/item/reagent_containers/food/snacks/rogue/meat/poultry = 2, /obj/item/natural/feather = 2, /obj/item/natural/bone = 2, /obj/item/alch/sinew = 1, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/cow
	name = "cow"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/cow.dmi'
	icon_state = "cow"
	icon_living = "cow"
	icon_dead = "cow_dead"
	health = 80
	maxHealth = 80
	melee_damage_lower = 10
	melee_damage_upper = 25
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 12, ROGUE_STAT_CONSTITUTION = 20, ROGUE_STAT_SPEED = 2)
	rogue_mob_intents = list(/datum/intent/simple/headbutt)
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown/wheat, /obj/item/reagent_containers/food/snacks/grown/oat)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 4, /obj/item/natural/hide = 1, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 3, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 2, /obj/item/alch/sinew = 2, /obj/item/natural/bone = 4, /obj/item/alch/viscera = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 6, /obj/item/natural/hide = 2, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 4, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2)

/mob/living/simple_animal/hostile/retaliate/rogue/cow/bullet
	name = "calf"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/cow.dmi'
	icon_state = "bullet"
	icon_living = "bullet"
	icon_dead = "bullet_dead"
	health = 20
	maxHealth = 20
	melee_damage_lower = 1
	melee_damage_upper = 6
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 5, ROGUE_STAT_CONSTITUTION = 5, ROGUE_STAT_SPEED = 5)
	rogue_mob_intents = list(/datum/intent/simple/headbutt)
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown/wheat, /obj/item/reagent_containers/food/snacks/grown/oat)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 4, /obj/item/natural/hide = 1, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 3, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 2, /obj/item/alch/sinew = 2, /obj/item/natural/bone = 4, /obj/item/alch/viscera = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 6, /obj/item/natural/hide = 2, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 4, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2)

/mob/living/simple_animal/hostile/retaliate/rogue/cow/cowlet
	name = "calf"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/cow.dmi'
	icon_state = "cowlet"
	icon_living = "cowlet"
	icon_dead = "cowlet_dead"
	health = 20
	maxHealth = 20
	melee_damage_lower = 1
	melee_damage_upper = 6
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 5, ROGUE_STAT_CONSTITUTION = 5, ROGUE_STAT_SPEED = 5)
	rogue_mob_intents = list(/datum/intent/simple/headbutt)
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown/wheat, /obj/item/reagent_containers/food/snacks/grown/oat)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 4, /obj/item/natural/hide = 1, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 3, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 2, /obj/item/alch/sinew = 2, /obj/item/natural/bone = 4, /obj/item/alch/viscera = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 6, /obj/item/natural/hide = 2, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 4, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2)

/mob/living/simple_animal/hostile/retaliate/rogue/direbear
	name = "direbear"
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/direbear.dmi'
	icon_state = "direbear"
	icon_living = "direbear"
	icon_dead = "direbear_dead"
	pixel_x = -16
	melee_damage_lower = 50
	melee_damage_upper = 60
	rogue_defprob = 40
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 13, ROGUE_STAT_CONSTITUTION = 12, ROGUE_STAT_SPEED = 9)
	rogue_mob_intents = list(/datum/intent/simple/bite/bear)
	rogue_aggressive = 1
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks, /obj/item/bodypart, /obj/item/organ, /obj/effect/decal/remains)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak/bear = 2, /obj/item/reagent_containers/food/snacks/fat = 1, /obj/item/natural/hide = 2, /obj/item/natural/fur/direbear = 1, /obj/item/alch/sinew = 2, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2, /obj/item/natural/bone = 4)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak/bear = 1, /obj/item/natural/hide = 1, /obj/item/natural/fur/direbear = 1, /obj/item/natural/bone = 3)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak/bear = 3, /obj/item/reagent_containers/food/snacks/fat = 2, /obj/item/natural/hide = 3, /obj/item/natural/fur/direbear = 2, /obj/item/alch/sinew = 2, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2, /obj/item/natural/bone = 4, /obj/item/natural/head/direbear = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/elemental/behemoth
	name = "earthen behemoth"
	icon = 'modular_redtard/rockhill/icons/mob/summonable/32x64.dmi'
	icon_state = "behemoth"
	icon_living = "behemoth"
	icon_dead = "vvd"
	health = 800
	maxHealth = 800
	melee_damage_lower = 55
	melee_damage_upper = 80
	rogue_defprob = 40
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 13, ROGUE_STAT_CONSTITUTION = 17, ROGUE_STAT_SPEED = 5)
	rogue_mob_intents = list(/datum/intent/simple/elementalt2_unarmed)
	rogue_aggressive = 1
	rogue_retreat_health = 0.3

/mob/living/simple_animal/hostile/retaliate/rogue/elemental/colossus
	name = "earthen colossus"
	icon = 'modular_redtard/rockhill/icons/mob/summonable/64x64.dmi'
	icon_state = "colossus"
	icon_living = "colossus"
	icon_dead = "vvd"
	health = 1500
	maxHealth = 1500
	pixel_x = -32
	melee_damage_lower = 40
	melee_damage_upper = 70
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 16, ROGUE_STAT_CONSTITUTION = 20, ROGUE_STAT_SPEED = 3)
	rogue_mob_intents = list(/datum/intent/simple/elementalt2_unarmed)
	rogue_aggressive = 1
	rogue_retreat_health = 0.3

/mob/living/simple_animal/hostile/retaliate/rogue/elemental/warden
	name = "earthen Warden"
	icon = 'modular_redtard/rockhill/icons/mob/summonable/32x32.dmi'
	icon_state = "warden"
	icon_living = "warden"
	icon_dead = "vvd"
	health = 340
	maxHealth = 340
	melee_damage_lower = 15
	melee_damage_upper = 17
	rogue_defprob = 30
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_CONSTITUTION = 15, ROGUE_STAT_SPEED = 6)
	rogue_mob_intents = list(/datum/intent/simple/elemental_unarmed)
	rogue_aggressive = 1
	rogue_retreat_health = 0.3

/mob/living/simple_animal/hostile/retaliate/rogue/fae/dryad
	name = "dryad"
	icon = 'modular_redtard/rockhill/icons/mob/summonable/32x64.dmi'
	icon_state = "dryad"
	icon_living = "dryad"
	icon_dead = "vvd"
	health = 650
	maxHealth = 650
	melee_damage_lower = 20
	melee_damage_upper = 30
	rogue_defprob = 40
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 14, ROGUE_STAT_CONSTITUTION = 18, ROGUE_STAT_SPEED = 4)
	rogue_mob_intents = list(/datum/intent/simple/elementalt2_unarmed)
	rogue_aggressive = 1
	rogue_retreat_health = 0.3

/mob/living/simple_animal/hostile/retaliate/rogue/fae/glimmerwing
	name = "glimmerwing"
	icon = 'modular_redtard/rockhill/icons/mob/summonable/32x32.dmi'
	icon_state = "glimmerwing"
	icon_living = "glimmerwing"
	icon_dead = "vvd"
	health = 270
	maxHealth = 270
	melee_damage_lower = 15
	melee_damage_upper = 17
	rogue_defprob = 40
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 9, ROGUE_STAT_CONSTITUTION = 7, ROGUE_STAT_SPEED = 15)
	rogue_mob_intents = list(/datum/intent/simple/bite)
	rogue_aggressive = 1
	rogue_retreat_health = 0.3

/mob/living/simple_animal/hostile/retaliate/rogue/fae/sprite
	name = "sprite"
	icon = 'modular_redtard/rockhill/icons/mob/summonable/32x32.dmi'
	icon_state = "sprite"
	icon_living = "sprite"
	icon_dead = "vvd"
	health = 50
	maxHealth = 50
	melee_damage_lower = 10
	melee_damage_upper = 20
	rogue_defprob = 40
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 2, ROGUE_STAT_CONSTITUTION = 6, ROGUE_STAT_SPEED = 17)
	rogue_mob_intents = list(/datum/intent/unarmed/claw)
	rogue_aggressive = 1
	rogue_retreat_health = 0.3

/mob/living/simple_animal/hostile/retaliate/rogue/goat
	name = "goat"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/gote.dmi'
	icon_state = "goat"
	icon_living = "goat"
	icon_dead = "goat_dead"
	health = 80
	maxHealth = 80
	melee_damage_lower = 10
	melee_damage_upper = 25
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 12, ROGUE_STAT_CONSTITUTION = 8)
	rogue_mob_intents = list(/datum/intent/simple/headbutt)
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown/wheat, /obj/item/reagent_containers/food/snacks/grown/oat, /obj/item/reagent_containers/food/snacks/grown/apple, /obj/item/reagent_containers/food/snacks/grown/berries/rogue)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 3, /obj/item/reagent_containers/food/snacks/fat = 2, /obj/item/natural/hide = 1, /obj/item/natural/fur/goat = 1, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 4, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 2, /obj/item/reagent_containers/food/snacks/fat = 1, /obj/item/alch/viscera = 1, /obj/item/alch/sinew = 2)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 4, /obj/item/reagent_containers/food/snacks/fat = 2, /obj/item/natural/hide = 2, /obj/item/natural/fur/goat = 1, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 4, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2, /obj/item/natural/head/goat = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/goat/goatlet
	name = "goatlet"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/gote.dmi'
	icon_state = "goatlet"
	icon_living = "goatlet"
	icon_dead = "goatlet_dead"
	health = 20
	maxHealth = 20
	melee_damage_lower = 1
	melee_damage_upper = 6
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 5, ROGUE_STAT_CONSTITUTION = 5, ROGUE_STAT_SPEED = 5)
	rogue_mob_intents = list(/datum/intent/simple/headbutt)
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown/wheat, /obj/item/reagent_containers/food/snacks/grown/oat, /obj/item/reagent_containers/food/snacks/grown/apple, /obj/item/reagent_containers/food/snacks/grown/berries/rogue)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 3, /obj/item/reagent_containers/food/snacks/fat = 2, /obj/item/natural/hide = 1, /obj/item/natural/fur/goat = 1, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 4, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 2, /obj/item/reagent_containers/food/snacks/fat = 1, /obj/item/alch/viscera = 1, /obj/item/alch/sinew = 2)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 4, /obj/item/reagent_containers/food/snacks/fat = 2, /obj/item/natural/hide = 2, /obj/item/natural/fur/goat = 1, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 4, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2, /obj/item/natural/head/goat = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/goat/goatletboy
	name = "goatlet"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/gote.dmi'
	icon_state = "goatletboy"
	icon_living = "goatletboy"
	icon_dead = "goatletboy_dead"
	health = 20
	maxHealth = 20
	melee_damage_lower = 1
	melee_damage_upper = 6
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 5, ROGUE_STAT_CONSTITUTION = 5, ROGUE_STAT_SPEED = 5)
	rogue_mob_intents = list(/datum/intent/simple/headbutt)
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown/wheat, /obj/item/reagent_containers/food/snacks/grown/oat, /obj/item/reagent_containers/food/snacks/grown/apple, /obj/item/reagent_containers/food/snacks/grown/berries/rogue)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 3, /obj/item/reagent_containers/food/snacks/fat = 2, /obj/item/natural/hide = 1, /obj/item/natural/fur/goat = 1, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 4, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 2, /obj/item/reagent_containers/food/snacks/fat = 1, /obj/item/alch/viscera = 1, /obj/item/alch/sinew = 2)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 4, /obj/item/reagent_containers/food/snacks/fat = 2, /obj/item/natural/hide = 2, /obj/item/natural/fur/goat = 1, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 4, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2, /obj/item/natural/head/goat = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/goatmale
	name = "goat"
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/gote.dmi'
	icon_state = "goatmale"
	icon_living = "goatmale"
	icon_dead = "goatmale_dead"
	health = 150
	maxHealth = 150
	melee_damage_lower = 25
	melee_damage_upper = 50
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 12, ROGUE_STAT_CONSTITUTION = 7, ROGUE_STAT_SPEED = 14)
	rogue_mob_intents = list(/datum/intent/simple/headbutt)
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown/wheat, /obj/item/reagent_containers/food/snacks/grown/oat, /obj/item/reagent_containers/food/snacks/grown/apple, /obj/item/reagent_containers/food/snacks/grown/berries/rogue)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 3, /obj/item/reagent_containers/food/snacks/fat = 2, /obj/item/natural/hide = 1, /obj/item/natural/fur/goat = 1, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 4, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 2, /obj/item/reagent_containers/food/snacks/fat = 1, /obj/item/alch/viscera = 1, /obj/item/alch/sinew = 2)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 4, /obj/item/reagent_containers/food/snacks/fat = 2, /obj/item/natural/hide = 2, /obj/item/natural/fur/goat = 1, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 4, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2, /obj/item/natural/head/goat = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/headless
	name = "headless"
	desc = "A horrible beast of gluttony. Its body is built like a barrel with a maw that opens only to darkness."
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/lamia.dmi'
	icon_state = "headless"
	icon_living = "headless"
	icon_dead = "headless_dead"
	health = 350
	maxHealth = 350
	melee_damage_lower = 25
	melee_damage_upper = 35
	rogue_defprob = 10
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 13, ROGUE_STAT_CONSTITUTION = 6)
	rogue_mob_intents = list(/datum/intent/simple/bite, /datum/intent/simple/claw)
	rogue_aggressive = 1
	rogue_retreat_health = 0.1
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 1, /obj/item/reagent_containers/food/snacks/fat = 2, /obj/item/alch/sinew = 2, /obj/item/alch/bone = 1)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 1, /obj/item/reagent_containers/food/snacks/fat = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 2, /obj/item/reagent_containers/food/snacks/fat = 2, /obj/item/alch/sinew = 2, /obj/item/alch/bone = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/horse/male/black/tame/saddled
	name = "horse"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/modular_helmsguard/icons/mob/horse.dmi'
	icon_state = "horseblack"
	icon_living = "horseblack"
	icon_dead = "horseblack_dead"
	health = 180
	maxHealth = 180
	pixel_x = -8
	melee_damage_lower = 10
	melee_damage_upper = 25
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 12, ROGUE_STAT_CONSTITUTION = 8, ROGUE_STAT_SPEED = 15)
	rogue_mob_intents = list(/datum/intent/simple/horse)
	rogue_aggressive = 1
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown/wheat, /obj/item/reagent_containers/food/snacks/grown/oat, /obj/item/reagent_containers/food/snacks/grown/apple)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 4, /obj/item/reagent_containers/food/snacks/fat = 2, /obj/item/natural/hide = 4, /obj/item/natural/bundle/bone/full = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/horse/male/brown/tame/saddled
	name = "horse"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/modular_helmsguard/icons/mob/horse.dmi'
	icon_state = "horsebrown"
	icon_living = "horsebrown"
	icon_dead = "horsebrown_dead"
	health = 180
	maxHealth = 180
	pixel_x = -8
	melee_damage_lower = 10
	melee_damage_upper = 25
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 12, ROGUE_STAT_CONSTITUTION = 8, ROGUE_STAT_SPEED = 15)
	rogue_mob_intents = list(/datum/intent/simple/horse)
	rogue_aggressive = 1
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown/wheat, /obj/item/reagent_containers/food/snacks/grown/oat, /obj/item/reagent_containers/food/snacks/grown/apple)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 4, /obj/item/reagent_containers/food/snacks/fat = 2, /obj/item/natural/hide = 4, /obj/item/natural/bundle/bone/full = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/horse/male/white/tame/saddled
	name = "horse"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/modular_helmsguard/icons/mob/horse.dmi'
	icon_state = "horsewhite"
	icon_living = "horsewhite"
	icon_dead = "horsewhite_dead"
	health = 180
	maxHealth = 180
	pixel_x = -8
	melee_damage_lower = 10
	melee_damage_upper = 25
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 12, ROGUE_STAT_CONSTITUTION = 8, ROGUE_STAT_SPEED = 15)
	rogue_mob_intents = list(/datum/intent/simple/horse)
	rogue_aggressive = 1
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown/wheat, /obj/item/reagent_containers/food/snacks/grown/oat, /obj/item/reagent_containers/food/snacks/grown/apple)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 4, /obj/item/reagent_containers/food/snacks/fat = 2, /obj/item/natural/hide = 4, /obj/item/natural/bundle/bone/full = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/infernal/fiend
	name = "fiend"
	icon = 'modular_redtard/rockhill/icons/mob/summonable/32x32.dmi'
	icon_state = "fiend"
	icon_living = "fiend"
	icon_dead = "vvd"
	health = 700
	maxHealth = 700
	melee_damage_lower = 20
	melee_damage_upper = 30
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 12, ROGUE_STAT_CONSTITUTION = 13, ROGUE_STAT_SPEED = 8)
	rogue_mob_intents = list(/datum/intent/simple/bite)
	rogue_aggressive = 1
	rogue_retreat_health = 0.3

/mob/living/simple_animal/hostile/retaliate/rogue/infernal/hellhound
	name = "hell hound"
	icon = 'modular_redtard/rockhill/icons/mob/summonable/32x32.dmi'
	icon_state = "hellhound"
	icon_living = "hellhound"
	icon_dead = "vvd"
	health = 270
	maxHealth = 270
	melee_damage_lower = 15
	melee_damage_upper = 17
	rogue_defprob = 40
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 9, ROGUE_STAT_CONSTITUTION = 7, ROGUE_STAT_SPEED = 13)
	rogue_mob_intents = list(/datum/intent/simple/bite)
	rogue_aggressive = 1
	rogue_retreat_health = 0.3

/mob/living/simple_animal/hostile/retaliate/rogue/infernal/imp
	name = "infernal imp"
	icon = 'modular_redtard/rockhill/icons/mob/summonable/32x32.dmi'
	icon_state = "imp"
	icon_living = "imp"
	icon_dead = "vvd"
	health = 70
	maxHealth = 70
	melee_damage_lower = 15
	melee_damage_upper = 17
	rogue_defprob = 40
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 6, ROGUE_STAT_CONSTITUTION = 7, ROGUE_STAT_SPEED = 12)
	rogue_mob_intents = list(/datum/intent/unarmed/claw)
	rogue_aggressive = 1
	rogue_retreat_health = 0.3

/mob/living/simple_animal/hostile/retaliate/rogue/infernal/watcher
	name = "infernal watcher"
	icon = 'modular_redtard/rockhill/icons/mob/summonable/32x32.dmi'
	icon_state = "watcher"
	icon_living = "watcher"
	icon_dead = "vvd"
	health = 600
	maxHealth = 600
	melee_damage_lower = 20
	melee_damage_upper = 30
	rogue_defprob = 35
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 12, ROGUE_STAT_CONSTITUTION = 13, ROGUE_STAT_SPEED = 8)
	rogue_mob_intents = list(/datum/intent/simple/bite)
	rogue_aggressive = 1
	rogue_retreat_health = 0.3

/mob/living/simple_animal/hostile/retaliate/rogue/mimic
	name = "chest"
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/mimic.dmi'
	icon_state = "mimicopen"
	icon_living = "mimicopen"
	icon_dead = "mimicdead"
	melee_damage_lower = 30
	melee_damage_upper = 40
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 15, ROGUE_STAT_CONSTITUTION = 15, ROGUE_STAT_SPEED = 5)
	rogue_mob_intents = list(/datum/intent/simple/bite)
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/rogue/meat, /obj/item/bodypart, /obj/item/organ)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 2, /obj/effect/spawner/lootdrop/valuable_jewelry_spawner = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/minotaur
	name = "Minotaur"
	icon = 'modular_redtard/rockhill/icons/modular_hearthstone/icons/mob/newminotaur.dmi'
	icon_state = "MinotaurMale"
	icon_living = "MinotaurMale"
	icon_dead = "MinotaurMale_dead"
	pixel_x = -16
	melee_damage_lower = 55
	melee_damage_upper = 80
	rogue_defprob = 40
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 16, ROGUE_STAT_CONSTITUTION = 19, ROGUE_STAT_SPEED = 5)
	rogue_mob_intents = list(/datum/intent/simple/minotaur_unarmed)
	rogue_aggressive = 1
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/rogue/meat)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 2, /obj/item/natural/hide = 2, /obj/item/natural/bundle/bone/full = 2, /obj/item/natural/head/minotaur = 1)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 1, /obj/item/natural/hide = 1, /obj/item/natural/bundle/bone/full = 2)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 4, /obj/item/natural/hide = 4, /obj/item/natural/bundle/bone/full = 2, /obj/item/natural/head/minotaur = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/minotaur/axe
	name = "Minotaur"
	icon = 'modular_redtard/rockhill/icons/modular_hearthstone/icons/mob/newminotaur.dmi'
	icon_state = "MinotaurMale_Axe"
	icon_living = "MinotaurMale_Axe"
	icon_dead = "MinotaurMale_dead"
	pixel_x = -16
	melee_damage_lower = 65
	melee_damage_upper = 85
	rogue_defprob = 40
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 16, ROGUE_STAT_CONSTITUTION = 19, ROGUE_STAT_SPEED = 5)
	rogue_mob_intents = list(/datum/intent/simple/minotaur_axe)
	rogue_aggressive = 1
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/rogue/meat)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 2, /obj/item/natural/hide = 2, /obj/item/natural/bundle/bone/full = 2, /obj/item/natural/head/minotaur = 1)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 1, /obj/item/natural/hide = 1, /obj/item/natural/bundle/bone/full = 2)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 4, /obj/item/natural/hide = 4, /obj/item/natural/bundle/bone/full = 2, /obj/item/natural/head/minotaur = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/minotaur/axe/female
	name = "Minotaur"
	icon = 'modular_redtard/rockhill/icons/modular_hearthstone/icons/mob/newminotaur.dmi'
	icon_state = "MinotaurFem_Axe"
	icon_living = "MinotaurFem_Axe"
	icon_dead = "MinotaurFem_dead"
	pixel_x = -16
	melee_damage_lower = 65
	melee_damage_upper = 85
	rogue_defprob = 40
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 16, ROGUE_STAT_CONSTITUTION = 19, ROGUE_STAT_SPEED = 5)
	rogue_mob_intents = list(/datum/intent/simple/minotaur_axe)
	rogue_aggressive = 1
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/rogue/meat)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 2, /obj/item/natural/hide = 2, /obj/item/natural/bundle/bone/full = 2, /obj/item/natural/head/minotaur = 1)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 1, /obj/item/natural/hide = 1, /obj/item/natural/bundle/bone/full = 2)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 4, /obj/item/natural/hide = 4, /obj/item/natural/bundle/bone/full = 2, /obj/item/natural/head/minotaur = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/mirespider
	name = "mire crawler"
	icon = 'modular_redtard/rockhill/icons/modular_hearthstone/icons/mob/mirespider_small.dmi'
	icon_state = "crawler"
	icon_living = "crawler"
	icon_dead = "crawler_dead"
	melee_damage_lower = 17
	melee_damage_upper = 26
	rogue_defprob = 40
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 7, ROGUE_STAT_CONSTITUTION = 7, ROGUE_STAT_SPEED = 13)
	rogue_mob_intents = list(/datum/intent/simple/bite/mirespider)
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/spider = 1, /obj/item/natural/hide = 1, /obj/item/natural/silk = 1, /obj/item/alch/viscera = 1, /obj/item/natural/head/mirespider = 1)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/spider = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/spider = 1, /obj/item/natural/hide = 1, /obj/item/natural/silk = 2, /obj/item/alch/viscera = 1, /obj/item/natural/head/mirespider = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/mirespider/angry
	name = "mire crawler"
	icon = 'modular_redtard/rockhill/icons/modular_hearthstone/icons/mob/mirespider_small.dmi'
	icon_state = "crawler"
	icon_living = "crawler"
	icon_dead = "crawler_dead"
	melee_damage_lower = 17
	melee_damage_upper = 26
	rogue_defprob = 40
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 7, ROGUE_STAT_CONSTITUTION = 7, ROGUE_STAT_SPEED = 13)
	rogue_mob_intents = list(/datum/intent/simple/bite/mirespider)
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/spider = 1, /obj/item/natural/hide = 1, /obj/item/natural/silk = 1, /obj/item/alch/viscera = 1, /obj/item/natural/head/mirespider = 1)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/spider = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/spider = 1, /obj/item/natural/hide = 1, /obj/item/natural/silk = 2, /obj/item/alch/viscera = 1, /obj/item/natural/head/mirespider = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/mole
	name = "mole"
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/mole.dmi'
	icon_state = "mole"
	icon_living = "mole"
	icon_dead = "mole_dead"
	melee_damage_lower = 19
	melee_damage_upper = 29
	rogue_defprob = 40
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 20, ROGUE_STAT_CONSTITUTION = 7, ROGUE_STAT_SPEED = 13)
	rogue_mob_intents = list(/datum/intent/simple/claw/mole)
	rogue_aggressive = 1
	rogue_retreat_health = 0.3
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/rogue/meat)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 3, /obj/item/natural/hide = 2, /obj/item/natural/fur = 1, /obj/item/natural/bone = 3, /obj/item/alch/sinew = 3, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 1, /obj/item/natural/head/mole = 1)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 2, /obj/item/alch/viscera = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 5, /obj/item/natural/hide = 3, /obj/item/natural/fur = 2, /obj/item/natural/bone = 3, /obj/item/alch/sinew = 3, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 1, /obj/item/natural/head/mole = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/mudcrab
	name = "mudcrab"
	desc = "A mudcrab."
	icon = 'modular_redtard/rockhill/icons/mob/animal.dmi'
	icon_state = "mudcrab"
	icon_living = "mudcrab"
	icon_dead = "mudcrab_dead"
	rogue_can_dodge = TRUE
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/crab = 2, /obj/item/alch/viscera = 2)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/crab = 1, /obj/item/alch/viscera = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/crab = 3, /obj/item/alch/viscera = 2)

/mob/living/simple_animal/hostile/retaliate/rogue/mudcrab/cabbit
	name = "cabbit"
	desc = "A cabbit, a particular favorite of local fauna; both as a pet and as a tasty meal."
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/cabbit.dmi'
	icon_state = "cabbit"
	icon_living = "cabbit"
	icon_dead = "cabbit_dead"
	rogue_can_dodge = TRUE
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/rabbit = 3, /obj/item/alch/sinew = 1, /obj/item/alch/bone = 1, /obj/item/natural/fur/rabbit = 1)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/rabbit = 2)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/rabbit = 4, /obj/item/alch/sinew = 1, /obj/item/alch/bone = 1, /obj/item/natural/fur/rabbit = 1, /obj/item/natural/rabbitsfoot = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/saiga
	name = "saiga doe"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/saiga.dmi'
	icon_state = "saiga"
	icon_living = "saiga"
	icon_dead = "saiga_dead"
	health = 156
	maxHealth = 156
	pixel_x = -8
	melee_damage_lower = 10
	melee_damage_upper = 25
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 12, ROGUE_STAT_CONSTITUTION = 8, ROGUE_STAT_SPEED = 15)
	rogue_mob_intents = list(/datum/intent/simple/headbutt/saiga)
	rogue_aggressive = 1
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown/wheat, /obj/item/reagent_containers/food/snacks/grown/oat, /obj/item/reagent_containers/food/snacks/grown/apple)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/saiga = 2, /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_ribs = 2, /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_loins = 2, /obj/item/reagent_containers/food/snacks/fat = 1, /obj/item/natural/hide = 2, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 3, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/saiga = 1, /obj/item/natural/bone = 4, /obj/item/alch/sinew = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_prime = 3, /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_ribs = 3, /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_loins = 3, /obj/item/reagent_containers/food/snacks/fat = 2, /obj/item/natural/hide = 4, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 3, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2, /obj/item/natural/head/saiga = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/saiga/saigaboy
	name = "saiga"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/saiga.dmi'
	icon_state = "saigaboy"
	icon_living = "saigaboy"
	icon_dead = "saigaboy_dead"
	health = 20
	maxHealth = 20
	pixel_x = -8
	melee_damage_lower = 1
	melee_damage_upper = 6
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 5, ROGUE_STAT_CONSTITUTION = 5, ROGUE_STAT_SPEED = 5)
	rogue_mob_intents = list(/datum/intent/simple/headbutt/saiga)
	rogue_aggressive = 1
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown/wheat, /obj/item/reagent_containers/food/snacks/grown/oat, /obj/item/reagent_containers/food/snacks/grown/apple)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 1, /obj/item/natural/bone = 3)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/saiga = 1, /obj/item/natural/bone = 4, /obj/item/alch/sinew = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_prime = 3, /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_ribs = 3, /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_loins = 3, /obj/item/reagent_containers/food/snacks/fat = 2, /obj/item/natural/hide = 4, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 3, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2, /obj/item/natural/head/saiga = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/saiga/saigabuck
	name = "saiga buck"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/saiga.dmi'
	icon_state = "buck"
	icon_living = "buck"
	icon_dead = "buck_dead"
	health = 400
	maxHealth = 400
	pixel_x = -8
	melee_damage_lower = 60
	melee_damage_upper = 90
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 12, ROGUE_STAT_CONSTITUTION = 15, ROGUE_STAT_SPEED = 18)
	rogue_mob_intents = list(/datum/intent/simple/headbutt/saiga)
	rogue_aggressive = 1
	rogue_retreat_health = 0.3
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown/wheat, /obj/item/reagent_containers/food/snacks/grown/oat, /obj/item/reagent_containers/food/snacks/grown/apple)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/saiga = 2, /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_ribs = 2, /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_loins = 2, /obj/item/reagent_containers/food/snacks/fat = 1, /obj/item/natural/hide = 2, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 3, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/saiga = 1, /obj/item/natural/bone = 4, /obj/item/alch/sinew = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_prime = 3, /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_ribs = 3, /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_loins = 3, /obj/item/reagent_containers/food/snacks/fat = 2, /obj/item/natural/hide = 4, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 3, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2, /obj/item/natural/head/saiga = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/saiga/saigabuck/tame
	name = "saiga buck"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/saiga.dmi'
	icon_state = "buck"
	icon_living = "buck"
	icon_dead = "buck_dead"
	health = 400
	maxHealth = 400
	pixel_x = -8
	melee_damage_lower = 60
	melee_damage_upper = 90
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 12, ROGUE_STAT_CONSTITUTION = 15, ROGUE_STAT_SPEED = 18)
	rogue_mob_intents = list(/datum/intent/simple/headbutt/saiga)
	rogue_aggressive = 1
	rogue_retreat_health = 0.3
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown/wheat, /obj/item/reagent_containers/food/snacks/grown/oat, /obj/item/reagent_containers/food/snacks/grown/apple)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/saiga = 2, /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_ribs = 2, /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_loins = 2, /obj/item/reagent_containers/food/snacks/fat = 1, /obj/item/natural/hide = 2, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 3, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/saiga = 1, /obj/item/natural/bone = 4, /obj/item/alch/sinew = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_prime = 3, /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_ribs = 3, /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_loins = 3, /obj/item/reagent_containers/food/snacks/fat = 2, /obj/item/natural/hide = 4, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 3, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2, /obj/item/natural/head/saiga = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/saiga/saigabuck/tame/saddled
	name = "saiga buck"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/saiga.dmi'
	icon_state = "buck"
	icon_living = "buck"
	icon_dead = "buck_dead"
	health = 400
	maxHealth = 400
	pixel_x = -8
	melee_damage_lower = 60
	melee_damage_upper = 90
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 12, ROGUE_STAT_CONSTITUTION = 15, ROGUE_STAT_SPEED = 18)
	rogue_mob_intents = list(/datum/intent/simple/headbutt/saiga)
	rogue_aggressive = 1
	rogue_retreat_health = 0.3
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown/wheat, /obj/item/reagent_containers/food/snacks/grown/oat, /obj/item/reagent_containers/food/snacks/grown/apple)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/saiga = 2, /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_ribs = 2, /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_loins = 2, /obj/item/reagent_containers/food/snacks/fat = 1, /obj/item/natural/hide = 2, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 3, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/saiga = 1, /obj/item/natural/bone = 4, /obj/item/alch/sinew = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_prime = 3, /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_ribs = 3, /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_loins = 3, /obj/item/reagent_containers/food/snacks/fat = 2, /obj/item/natural/hide = 4, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 3, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2, /obj/item/natural/head/saiga = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/saiga/saigakid
	name = "saiga calf"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/saiga.dmi'
	icon_state = "saigakid"
	icon_living = "saigakid"
	icon_dead = "saigakid_dead"
	health = 20
	maxHealth = 20
	pixel_x = -16
	melee_damage_lower = 1
	melee_damage_upper = 6
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 5, ROGUE_STAT_CONSTITUTION = 5, ROGUE_STAT_SPEED = 5)
	rogue_mob_intents = list(/datum/intent/simple/headbutt/saiga)
	rogue_aggressive = 1
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown/wheat, /obj/item/reagent_containers/food/snacks/grown/oat, /obj/item/reagent_containers/food/snacks/grown/apple)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 1, /obj/item/natural/bone = 3)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/saiga = 1, /obj/item/natural/bone = 4, /obj/item/alch/sinew = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_prime = 3, /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_ribs = 3, /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_loins = 3, /obj/item/reagent_containers/food/snacks/fat = 2, /obj/item/natural/hide = 4, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 3, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2, /obj/item/natural/head/saiga = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/saiga/undead
	name = "deadite saiga"
	desc = "A deadite saiga, its eyes glow with an eerie light."
	icon = 'modular_redtard/rockhill/icons/modular_hearthstone/icons/mob/saiga_undead.dmi'
	icon_state = "saiga"
	icon_living = "saiga"
	icon_dead = "saiga_dead"
	pixel_x = -8
	melee_damage_lower = 60
	melee_damage_upper = 90
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 12, ROGUE_STAT_CONSTITUTION = 8, ROGUE_STAT_SPEED = 15)
	rogue_mob_intents = list(/datum/intent/simple/headbutt/saiga)
	rogue_aggressive = 1
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown/wheat, /obj/item/reagent_containers/food/snacks/grown/oat, /obj/item/reagent_containers/food/snacks/grown/apple)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_z = 2, /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_ribs_z = 1, /obj/item/natural/bone = 6, /obj/item/alch/sinew = 1, /obj/item/alch/bone = 2, /obj/item/alch/viscera = 1)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_z = 1, /obj/item/natural/bone = 4, /obj/item/alch/sinew = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_z = 1, /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_ribs_z = 1, /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_loins_z = 2, /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_prime_z = 1, /obj/item/reagent_containers/food/snacks/fat = 1, /obj/item/natural/bone = 6, /obj/item/alch/sinew = 1, /obj/item/alch/bone = 2, /obj/item/alch/viscera = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/spider
	name = "beespider"
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/spider.dmi'
	icon_state = "honeys"
	icon_living = "honeys"
	icon_dead = "honeys-dead"
	melee_damage_lower = 17
	melee_damage_upper = 21
	rogue_defprob = 40
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 9, ROGUE_STAT_CONSTITUTION = 6)
	rogue_mob_intents = list(/datum/intent/simple/bite/honeyspider)
	rogue_aggressive = 1
	rogue_retreat_health = 0.3
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/rogue/meat, /obj/item/organ)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 1, /obj/item/natural/silk = 2, /obj/item/alch/viscera = 1, /obj/item/natural/head/honeyspider = 1)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 2)

/mob/living/simple_animal/hostile/retaliate/rogue/spider/mutated
	name = "skallax spider"
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/spider.dmi'
	icon_state = "skallax"
	icon_living = "skallax"
	icon_dead = "skallax-dead"
	health = 130
	maxHealth = 130
	melee_damage_lower = 17
	melee_damage_upper = 21
	rogue_defprob = 40
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 9, ROGUE_STAT_CONSTITUTION = 6)
	rogue_mob_intents = list(/datum/intent/simple/bite)
	rogue_aggressive = 1
	rogue_retreat_health = 0.3
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/rogue/meat, /obj/item/organ)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 2, /obj/item/natural/hide = 1)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 2)

/mob/living/simple_animal/hostile/retaliate/rogue/spider/rock
	name = "rockspider"
	desc = "These beasts, native to rockhill, are similar in behaviour and tenacity to the beespider, differing in their recessed heads and hairy brown bodies."
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/spider.dmi'
	icon_state = "spiderrock"
	icon_living = "spiderrock"
	icon_dead = "spiderrock-dead"
	melee_damage_lower = 17
	melee_damage_upper = 21
	rogue_defprob = 40
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 9, ROGUE_STAT_CONSTITUTION = 6)
	rogue_mob_intents = list(/datum/intent/simple/bite/honeyspider)
	rogue_aggressive = 1
	rogue_retreat_health = 0.3
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/rogue/meat, /obj/item/organ)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/spider = 1, /obj/item/natural/silk = 2, /obj/item/reagent_containers/food/snacks/rogue/honey/spider = 1, /obj/item/alch/viscera = 1)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/spider = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/spider = 2)

/mob/living/simple_animal/hostile/retaliate/rogue/swine
	name = "swine sow"
	desc = "A domesticated hog, won't be finding you any truffles."
	icon = 'modular_redtard/rockhill/icons/modular/Creechers/icons/piggie.dmi'
	icon_state = "piggie_f"
	icon_living = "piggie_f"
	icon_dead = "piggie_dead"
	health = 140
	maxHealth = 140
	melee_damage_lower = 15
	melee_damage_upper = 40
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 12, ROGUE_STAT_CONSTITUTION = 15, ROGUE_STAT_SPEED = 8)
	rogue_mob_intents = list(/datum/intent/simple/headbutt/saiga)
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown/oat, /obj/item/reagent_containers/food/snacks/grown/potato/rogue, /obj/item/reagent_containers/food/snacks/rogue/meat)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/fatty = 4, /obj/item/reagent_containers/food/snacks/rogue/meat/pork_belly = 1, /obj/item/reagent_containers/food/snacks/rogue/meat/ham/boar = 2, /obj/item/reagent_containers/food/snacks/fat = 2, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 3, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/fatty = 2, /obj/item/alch/sinew = 2, /obj/item/natural/bone = 4, /obj/item/alch/viscera = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/fatty = 6, /obj/item/reagent_containers/food/snacks/rogue/meat/pork_belly = 2, /obj/item/reagent_containers/food/snacks/rogue/meat/ham/boar = 2, /obj/item/reagent_containers/food/snacks/fat = 4, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 4, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2)

/mob/living/simple_animal/hostile/retaliate/rogue/swine/hog
	name = "swine hog"
	desc = "A domesticated hog, won't be finding you any truffles. This one can even be saddled."
	icon = 'modular_redtard/rockhill/icons/modular/Creechers/icons/piggie.dmi'
	icon_state = "piggie_m"
	icon_living = "piggie_m"
	icon_dead = "piggie_dead"
	health = 250
	maxHealth = 250
	melee_damage_lower = 35
	melee_damage_upper = 60
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 12, ROGUE_STAT_CONSTITUTION = 15, ROGUE_STAT_SPEED = 6)
	rogue_mob_intents = list(/datum/intent/simple/headbutt/saiga)
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown/oat, /obj/item/reagent_containers/food/snacks/grown/potato/rogue, /obj/item/reagent_containers/food/snacks/rogue/meat)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/fatty = 4, /obj/item/reagent_containers/food/snacks/rogue/meat/pork_belly = 1, /obj/item/reagent_containers/food/snacks/rogue/meat/ham/boar = 2, /obj/item/reagent_containers/food/snacks/fat = 2, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 3, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/fatty = 2, /obj/item/alch/sinew = 2, /obj/item/natural/bone = 4, /obj/item/alch/viscera = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/fatty = 6, /obj/item/reagent_containers/food/snacks/rogue/meat/pork_belly = 2, /obj/item/reagent_containers/food/snacks/rogue/meat/ham/boar = 2, /obj/item/reagent_containers/food/snacks/fat = 4, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 4, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2)

/mob/living/simple_animal/hostile/retaliate/rogue/swine/hog/piglet
	name = "piglet"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/modular/Creechers/icons/piggie.dmi'
	icon_state = "piggie_piglin"
	icon_living = "piggie_piglin"
	icon_dead = "piggie_piglin_dead"
	health = 20
	maxHealth = 20
	melee_damage_lower = 1
	melee_damage_upper = 6
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 5, ROGUE_STAT_CONSTITUTION = 5, ROGUE_STAT_SPEED = 2)
	rogue_mob_intents = list(/datum/intent/simple/headbutt)
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown/oat, /obj/item/reagent_containers/food/snacks/grown/potato/rogue, /obj/item/reagent_containers/food/snacks/rogue/meat)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/fatty = 4, /obj/item/reagent_containers/food/snacks/rogue/meat/pork_belly = 1, /obj/item/reagent_containers/food/snacks/rogue/meat/ham/boar = 2, /obj/item/reagent_containers/food/snacks/fat = 2, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 3, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/fatty = 2, /obj/item/alch/sinew = 2, /obj/item/natural/bone = 4, /obj/item/alch/viscera = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/fatty = 6, /obj/item/reagent_containers/food/snacks/rogue/meat/pork_belly = 2, /obj/item/reagent_containers/food/snacks/rogue/meat/ham/boar = 2, /obj/item/reagent_containers/food/snacks/fat = 4, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 4, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2)

/mob/living/simple_animal/hostile/retaliate/rogue/swine/piglet
	name = "piglet"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/modular/Creechers/icons/piggie.dmi'
	icon_state = "piggie_piglin"
	icon_living = "piggie_piglin"
	icon_dead = "piggie_piglin_dead"
	health = 20
	maxHealth = 20
	melee_damage_lower = 1
	melee_damage_upper = 6
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 5, ROGUE_STAT_CONSTITUTION = 5, ROGUE_STAT_SPEED = 2)
	rogue_mob_intents = list(/datum/intent/simple/headbutt)
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown/oat, /obj/item/reagent_containers/food/snacks/grown/potato/rogue, /obj/item/reagent_containers/food/snacks/rogue/meat)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/fatty = 4, /obj/item/reagent_containers/food/snacks/rogue/meat/pork_belly = 1, /obj/item/reagent_containers/food/snacks/rogue/meat/ham/boar = 2, /obj/item/reagent_containers/food/snacks/fat = 2, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 3, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/fatty = 2, /obj/item/alch/sinew = 2, /obj/item/natural/bone = 4, /obj/item/alch/viscera = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/fatty = 6, /obj/item/reagent_containers/food/snacks/rogue/meat/pork_belly = 2, /obj/item/reagent_containers/food/snacks/rogue/meat/ham/boar = 2, /obj/item/reagent_containers/food/snacks/fat = 4, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 4, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 2)

/mob/living/simple_animal/hostile/retaliate/rogue/troll
	name = "troll"
	desc = "Elven legends say these monsters were servants of Dendor tasked to guard his realm; nowadays they are sometimes found in the company of orcs. It's said that fire curbs their almost magical regeneration."
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/trolls/trolls.dmi'
	icon_state = "troll"
	icon_living = "troll"
	icon_dead = "troll_dead"
	pixel_x = -16
	melee_damage_lower = 40
	melee_damage_upper = 60
	rogue_defprob = 20
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 16, ROGUE_STAT_CONSTITUTION = 16, ROGUE_STAT_SPEED = 2)
	rogue_mob_intents = list(/datum/intent/unarmed/claw, /datum/intent/simple/bite)
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/rogue/meat, /obj/item/bodypart, /obj/item/organ)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak/troll = 3, /obj/item/natural/hide = 3, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 5, /obj/item/alch/horn = 2, /obj/item/alch/viscera = 3, /obj/item/natural/head/troll = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak/troll = 5, /obj/item/natural/hide = 5, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 7, /obj/item/alch/horn = 2, /obj/item/alch/viscera = 3, /obj/item/natural/head/troll = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/troll/axe
	name = "troll skull-splitter"
	desc = "This one seems smarter than the rest... And its axe could cut a man in two."
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/trolls/troll_axe.dmi'
	icon_state = "troll"
	icon_living = "troll"
	icon_dead = "troll_dead"
	pixel_x = -16
	melee_damage_lower = 55
	melee_damage_upper = 70
	rogue_defprob = 20
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 16, ROGUE_STAT_CONSTITUTION = 16, ROGUE_STAT_SPEED = 2)
	rogue_mob_intents = list(/datum/intent/simple/troll_axe)
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/rogue/meat, /obj/item/bodypart, /obj/item/organ)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak/troll = 3, /obj/item/natural/hide = 3, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 5, /obj/item/alch/horn = 2, /obj/item/alch/viscera = 3, /obj/item/natural/head/troll = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak/troll = 5, /obj/item/natural/hide = 5, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 7, /obj/item/alch/horn = 2, /obj/item/alch/viscera = 3, /obj/item/natural/head/troll/axe = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/troll/bog
	name = "bog troll"
	desc = "Elven legends say these monsters were servants of Dendor tasked to guard his realm; nowadays they are sometimes found in the company of orcs. It's said that fire curbs their almost magical regeneration."
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/trolls/trolls.dmi'
	icon_state = "troll"
	icon_living = "troll"
	icon_dead = "troll_dead"
	pixel_x = -16
	melee_damage_lower = 30
	melee_damage_upper = 50
	rogue_defprob = 30
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 16, ROGUE_STAT_CONSTITUTION = 16, ROGUE_STAT_SPEED = 3)
	rogue_mob_intents = list(/datum/intent/unarmed/claw, /datum/intent/simple/bite)
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/rogue/meat, /obj/item/bodypart, /obj/item/organ)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak/troll = 3, /obj/item/natural/hide = 3, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 5, /obj/item/alch/horn = 2, /obj/item/alch/viscera = 3, /obj/item/natural/head/troll = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak/troll = 5, /obj/item/natural/hide = 5, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 7, /obj/item/alch/horn = 2, /obj/item/alch/viscera = 3, /obj/item/natural/head/troll = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/troll/cave
	name = "cave troll"
	desc = "Dwarven tales of giants and trolls often contain these creatures, horrifying amalgamations of flesh and crystal who have long since abandoned Malum's ways."
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/trolls/troll_cave.dmi'
	icon_state = "troll"
	icon_living = "troll"
	icon_dead = "troll_dead"
	pixel_x = -16
	melee_damage_lower = 40
	melee_damage_upper = 60
	rogue_defprob = 15
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 16, ROGUE_STAT_CONSTITUTION = 16, ROGUE_STAT_SPEED = 2)
	rogue_mob_intents = list(/datum/intent/unarmed/claw, /datum/intent/simple/bite)
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/rogue/meat, /obj/item/bodypart, /obj/item/organ)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak/troll = 3, /obj/item/natural/hide = 3, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 5, /obj/item/alch/horn = 2, /obj/item/alch/viscera = 3, /obj/item/natural/head/troll = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak/troll = 5, /obj/item/natural/hide = 5, /obj/item/natural/bundle/bone/full = 1, /obj/item/alch/sinew = 7, /obj/item/alch/horn = 2, /obj/item/alch/viscera = 3, /obj/item/natural/head/troll = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/trufflepig
	name = "truffle pig"
	desc = "A hairy pig, bred for finding truffles in the bog."
	icon = 'modular_redtard/rockhill/icons/modular/Creechers/icons/piggie.dmi'
	icon_state = "piggie_m"
	icon_living = "piggie_m"
	icon_dead = "piggie_dead"
	health = 80
	maxHealth = 80
	melee_damage_lower = 8
	melee_damage_upper = 14
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 12, ROGUE_STAT_CONSTITUTION = 8, ROGUE_STAT_SPEED = 2)
	rogue_mob_intents = list(/datum/intent/simple/headbutt)
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/rogue/truffles)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/fatty = 2, /obj/item/reagent_containers/food/snacks/rogue/meat/pork_belly = 2, /obj/item/reagent_containers/food/snacks/fat = 2, /obj/item/natural/hide = 1)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/fatty = 1, /obj/item/reagent_containers/food/snacks/rogue/meat/pork_belly = 1, /obj/item/reagent_containers/food/snacks/fat = 1, /obj/item/natural/hide = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/fatty = 4, /obj/item/reagent_containers/food/snacks/rogue/meat/pork_belly = 3, /obj/item/reagent_containers/food/snacks/fat = 2, /obj/item/natural/hide = 2)

/mob/living/simple_animal/hostile/retaliate/rogue/wolf
	name = "volf"
	desc = "A snarling beast of mangy fur and yellowed teeth. Volves are known to attack hapless travelers in the deep forests when prey is scarce."
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/vol.dmi'
	icon_state = "vv"
	icon_living = "vv"
	icon_dead = "vvd"
	melee_damage_lower = 19
	melee_damage_upper = 29
	rogue_defprob = 40
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 7, ROGUE_STAT_CONSTITUTION = 7, ROGUE_STAT_SPEED = 12)
	rogue_mob_intents = list(/datum/intent/simple/bite/volf)
	rogue_aggressive = 1
	rogue_retreat_health = 0.3
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks, /obj/item/natural/bone, /obj/item/natural/hide)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak/wolf = 2, /obj/item/natural/hide = 2, /obj/item/alch/sinew = 2, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 1, /obj/item/natural/fur/wolf = 1, /obj/item/natural/bone = 3, /obj/item/natural/head/volf = 1)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak/wolf = 1, /obj/item/alch/viscera = 1, /obj/item/alch/sinew = 1, /obj/item/natural/bone = 2)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak/wolf = 2, /obj/item/natural/hide = 2, /obj/item/alch/sinew = 2, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 1, /obj/item/natural/fur/wolf = 2, /obj/item/natural/bone = 4, /obj/item/natural/head/volf = 1)

/mob/living/simple_animal/hostile/retaliate/rogue/wolf_undead
	name = "deadite volf"
	desc = "A volf that was claimed for undeath, defiantly snarling with a hunger for fresh meat."
	icon = 'modular_redtard/rockhill/icons/modular_hearthstone/icons/mob/wolf_undead.dmi'
	icon_state = "wolf"
	icon_living = "wolf"
	icon_dead = "wolf_dead"
	melee_damage_lower = 24
	melee_damage_upper = 34
	rogue_defprob = 40
	rogue_can_dodge = TRUE
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 7, ROGUE_STAT_CONSTITUTION = 7, ROGUE_STAT_SPEED = 12)
	rogue_mob_intents = list(/datum/intent/simple/bite/volf)
	rogue_aggressive = 1
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks/grown)
	rogue_butcher_results = list(/obj/item/natural/hide = 1, /obj/item/alch/sinew = 1, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 1, /obj/item/natural/bone = 3)
	rogue_botched_butcher_results = list(/obj/item/alch/viscera = 1, /obj/item/alch/sinew = 1, /obj/item/natural/bone = 2)
	rogue_perfect_butcher_results = list(/obj/item/natural/hide = 1, /obj/item/alch/sinew = 2, /obj/item/alch/bone = 1, /obj/item/alch/viscera = 1, /obj/item/natural/fur/wolf = 1, /obj/item/natural/bone = 4)

/mob/living/simple_animal/hostile/rogue/deepone
	name = "Deep One"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/fishman.dmi'
	icon_state = "deep1"
	icon_living = "deep1"
	icon_dead = "deep1_d"
	melee_damage_lower = 10
	melee_damage_upper = 25
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 13, ROGUE_STAT_CONSTITUTION = 11, ROGUE_STAT_SPEED = 9)
	rogue_mob_intents = list(/datum/intent/simple/claw/deepone_unarmed)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/crab = 5, /obj/item/alch/viscera = 2)

/mob/living/simple_animal/hostile/rogue/deepone/arm
	name = "Deep One"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/fishman.dmi'
	icon_state = "deep1_arm"
	icon_living = "deep1"
	icon_dead = "deep1_d"
	melee_damage_lower = 15
	melee_damage_upper = 30
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 13, ROGUE_STAT_CONSTITUTION = 11, ROGUE_STAT_SPEED = 9)
	rogue_mob_intents = list(/datum/intent/simple/claw/deepone_unarmed)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/crab = 5, /obj/item/alch/viscera = 2)

/mob/living/simple_animal/hostile/rogue/deepone/spit
	name = "Deep One"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/fishman.dmi'
	icon_state = "deep1_spit"
	icon_living = "deep1_spit"
	icon_dead = "deep1_d"
	melee_damage_lower = 10
	melee_damage_upper = 25
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 13, ROGUE_STAT_CONSTITUTION = 11, ROGUE_STAT_SPEED = 9)
	rogue_mob_intents = list(/datum/intent/simple/claw/deepone_unarmed)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/crab = 5, /obj/item/alch/viscera = 2)

/mob/living/simple_animal/hostile/rogue/deepone/wiz
	name = "Deep One Devout"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/fishman.dmi'
	icon_state = "deep1_wiz"
	icon_living = "deep1_wiz"
	icon_dead = "deep1_d"
	melee_damage_lower = 10
	melee_damage_upper = 25
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 13, ROGUE_STAT_CONSTITUTION = 11, ROGUE_STAT_SPEED = 9)
	rogue_mob_intents = list(/datum/intent/simple/claw/deepone_unarmed)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/crab = 5, /obj/item/alch/viscera = 2)

/mob/living/simple_animal/hostile/rogue/deepone/wiz/boss
	name = "Deep One Devout"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/fishman.dmi'
	icon_state = "deep1_wiz"
	icon_living = "deep1_wiz"
	icon_dead = "deep1_d"
	melee_damage_lower = 10
	melee_damage_upper = 25
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 13, ROGUE_STAT_CONSTITUTION = 11, ROGUE_STAT_SPEED = 9)
	rogue_mob_intents = list(/datum/intent/simple/claw/deepone_unarmed)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/crab = 5, /obj/item/alch/viscera = 2)

/mob/living/simple_animal/hostile/rogue/dreamfiend/ancient/unbound
	name = "ancient dream fiend"
	desc = "A truly horrifying creature. It makes you dizzy just looking at it."
	icon = 'modular_redtard/rockhill/icons/modular_hearthstone/icons/mob/abyssal_large.dmi'
	icon_state = "dreamfiend"
	icon_living = "dreamfiend"
	icon_dead = "dreamfiend"
	pixel_x = -16
	melee_damage_lower = 40
	melee_damage_upper = 120
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 20, ROGUE_STAT_PERCEPTION = 20, ROGUE_STAT_CONSTITUTION = 20)
	rogue_mob_intents = list(/datum/intent/simple/dreamfiend_ancient)

/mob/living/simple_animal/hostile/rogue/dreamfiend/unbound
	name = "minor dream fiend"
	icon = 'modular_redtard/rockhill/icons/modular_hearthstone/icons/mob/abyssal_small.dmi'
	icon_state = "dreamfiend"
	icon_living = "dreamfiend"
	icon_dead = "dreamfiend"
	melee_damage_lower = 25
	melee_damage_upper = 40
	rogue_mob_intents = list(/datum/intent/simple/bite)

/mob/living/simple_animal/hostile/rogue/haunt
	name = "haunt"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/wraith.dmi'
	icon_state = "haunt"
	icon_living = "haunt"
	icon_dead = null
	melee_damage_lower = 15
	melee_damage_upper = 25
	rogue_mob_stats = list(ROGUE_STAT_FORTUNE = 11)
	rogue_mob_intents = list(/datum/intent/simple/slash)
	rogue_food_types = list(/obj/item/reagent_containers/food/snacks, /obj/item/bodypart)

/mob/living/simple_animal/hostile/rogue/mirespider_lurker
	name = "mire lurker"
	icon = 'modular_redtard/rockhill/icons/modular_hearthstone/icons/mob/mirespider_big.dmi'
	icon_state = "lurker"
	icon_living = "lurker"
	icon_dead = "lurker_dead"
	pixel_x = -4
	melee_damage_lower = 35
	melee_damage_upper = 70
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 9, ROGUE_STAT_PERCEPTION = 15, ROGUE_STAT_CONSTITUTION = 9, ROGUE_STAT_SPEED = 14)
	rogue_mob_intents = list(/datum/intent/simple/bite/mirespider_lurker)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/spider = 4, /obj/item/natural/hide = 3, /obj/item/natural/silk = 3, /obj/item/alch/viscera = 4, /obj/item/natural/head/mirelurker = 1)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/spider = 2, /obj/item/natural/hide = 2, /obj/item/natural/silk = 1, /obj/item/alch/viscera = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/spider = 4, /obj/item/natural/hide = 4, /obj/item/natural/silk = 5, /obj/item/alch/viscera = 4, /obj/item/natural/head/mirelurker = 1)

/mob/living/simple_animal/hostile/rogue/mirespider_lurker/angry
	name = "mire lurker"
	icon = 'modular_redtard/rockhill/icons/modular_hearthstone/icons/mob/mirespider_big.dmi'
	icon_state = "lurker"
	icon_living = "lurker"
	icon_dead = "lurker_dead"
	pixel_x = -4
	melee_damage_lower = 35
	melee_damage_upper = 70
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 9, ROGUE_STAT_PERCEPTION = 15, ROGUE_STAT_CONSTITUTION = 9, ROGUE_STAT_SPEED = 14)
	rogue_mob_intents = list(/datum/intent/simple/bite/mirespider_lurker)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/spider = 4, /obj/item/natural/hide = 3, /obj/item/natural/silk = 3, /obj/item/alch/viscera = 4, /obj/item/natural/head/mirelurker = 1)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/spider = 2, /obj/item/natural/hide = 2, /obj/item/natural/silk = 1, /obj/item/alch/viscera = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/spider = 4, /obj/item/natural/hide = 4, /obj/item/natural/silk = 5, /obj/item/alch/viscera = 4, /obj/item/natural/head/mirelurker = 1)

/mob/living/simple_animal/hostile/rogue/mirespider_paralytic
	name = "aragn"
	icon = 'modular_redtard/rockhill/icons/modular_hearthstone/icons/mob/mirespider_small.dmi'
	icon_state = "aragn"
	icon_living = "aragn"
	icon_dead = "aragn_dead"
	melee_damage_lower = 21
	melee_damage_upper = 42
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 9, ROGUE_STAT_PERCEPTION = 7, ROGUE_STAT_CONSTITUTION = 9, ROGUE_STAT_SPEED = 12)
	rogue_mob_intents = list(/datum/intent/simple/bite/mirespider_paralytic)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/spider = 2, /obj/item/natural/hide = 1, /obj/item/natural/silk = 1, /obj/item/alch/viscera = 1, /obj/item/reagent_containers/spidervenom_inert = 1, /obj/item/natural/head/mirespider_paralytic = 1)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/spider = 1, /obj/item/natural/silk = 1, /obj/item/alch/viscera = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/spider = 2, /obj/item/natural/hide = 1, /obj/item/natural/silk = 1, /obj/item/alch/viscera = 1, /obj/item/reagent_containers/spidervenom_inert = 2, /obj/item/natural/head/mirespider_paralytic = 1)

/mob/living/simple_animal/hostile/rogue/mirespider_paralytic/angry
	name = "aragn"
	icon = 'modular_redtard/rockhill/icons/modular_hearthstone/icons/mob/mirespider_small.dmi'
	icon_state = "aragn"
	icon_living = "aragn"
	icon_dead = "aragn_dead"
	melee_damage_lower = 21
	melee_damage_upper = 42
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 9, ROGUE_STAT_PERCEPTION = 7, ROGUE_STAT_CONSTITUTION = 9, ROGUE_STAT_SPEED = 12)
	rogue_mob_intents = list(/datum/intent/simple/bite/mirespider_paralytic)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/spider = 2, /obj/item/natural/hide = 1, /obj/item/natural/silk = 1, /obj/item/alch/viscera = 1, /obj/item/reagent_containers/spidervenom_inert = 1, /obj/item/natural/head/mirespider_paralytic = 1)
	rogue_botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/spider = 1, /obj/item/natural/silk = 1, /obj/item/alch/viscera = 1)
	rogue_perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/spider = 2, /obj/item/natural/hide = 1, /obj/item/natural/silk = 1, /obj/item/alch/viscera = 1, /obj/item/reagent_containers/spidervenom_inert = 2, /obj/item/natural/head/mirespider_paralytic = 1)

/mob/living/simple_animal/hostile/rogue/skeleton/bow
	name = "Skeleton"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/modular_hearthstone/icons/mob/skeletons.dmi'
	icon_state = "skeleton_bow"
	icon_living = "skeleton_bow"
	icon_dead = ""
	melee_damage_lower = 10
	melee_damage_upper = 25
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 9, ROGUE_STAT_CONSTITUTION = 9, ROGUE_STAT_SPEED = 8)
	rogue_mob_intents = list(/datum/intent/simple/claw/skeleton)

/mob/living/simple_animal/hostile/rogue/skeleton/spear
	name = "Skeleton"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/modular_hearthstone/icons/mob/skeletons.dmi'
	icon_state = "skeleton_spear"
	icon_living = "skeleton_spear"
	icon_dead = ""
	melee_damage_lower = 10
	melee_damage_upper = 25
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 9, ROGUE_STAT_CONSTITUTION = 9, ROGUE_STAT_SPEED = 8)
	rogue_mob_intents = list(/datum/intent/simple/spear/skeleton)

/mob/living/simple_animal/pet/cat
	name = "cat"
	desc = "A nuisance and a valued, pest-killing companion. Also symbols of the benevolent side of Saint Pestra for their enmity with vermin."
	icon = 'modular_redtard/rockhill/icons/mob/pets.dmi'
	icon_state = "cat2"
	icon_living = "cat2"
	icon_dead = "cat2_dead"
	health = 20
	maxHealth = 20
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 3, ROGUE_STAT_CONSTITUTION = 3, ROGUE_STAT_SPEED = 3)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 1, /obj/item/organ/ears/cat = 1, /obj/item/organ/tail/cat = 1)

/mob/living/simple_animal/pet/cat/kitten
	name = "kitten"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/mob/pets.dmi'
	icon_state = "kitten"
	icon_living = "kitten"
	icon_dead = "kitten_dead"
	health = 20
	maxHealth = 20
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 3, ROGUE_STAT_CONSTITUTION = 3, ROGUE_STAT_SPEED = 3)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 1, /obj/item/organ/ears/cat = 1, /obj/item/organ/tail/cat = 1)

/mob/living/simple_animal/pet/cat/rogue/black
	name = "black cat"
	desc = "Possessed of lamplike eyes and a meow that sounds like the rattle of bones. Black cats are sacred to Necra, said to bring wandering spirits to the Carriageman."
	icon = 'modular_redtard/rockhill/icons/roguetown/topadd/takyon/Cat.dmi'
	icon_state = "cat"
	icon_living = "cat"
	icon_dead = "cat_dead"
	health = 20
	maxHealth = 20
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 3, ROGUE_STAT_CONSTITUTION = 3, ROGUE_STAT_SPEED = 3)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 1, /obj/item/organ/ears/cat = 1, /obj/item/organ/tail/cat = 1)

/mob/living/simple_animal/pet/cat/rogue/rat
	name = "Boris"
	desc = "Sated on lifetimes of the Keep's grain, there is simply no longer any point in slaying this beast. For it has already won."
	icon = 'modular_redtard/rockhill/icons/roguetown/mob/monster/bigrat.dmi'
	icon_state = "rat"
	icon_living = "rat"
	icon_dead = "rat1"
	health = 20
	maxHealth = 20
	rogue_mob_stats = list(ROGUE_STAT_STRENGTH = 3, ROGUE_STAT_CONSTITUTION = 3, ROGUE_STAT_SPEED = 3)
	rogue_butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 1, /obj/item/organ/ears/cat = 1, /obj/item/organ/tail/cat = 1)
