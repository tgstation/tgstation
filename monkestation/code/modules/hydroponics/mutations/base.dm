/datum/hydroponics/plant_mutation/death_weed
	mutates_from = list(/obj/item/seeds/cannabis)
	created_product = /obj/item/food/grown/cannabis/death
	created_seed = /obj/item/seeds/cannabis/death
	required_endurance = list(10, 30)
	required_potency = list(0, 30)

/datum/hydroponics/plant_mutation/life_weed
	mutates_from = list(/obj/item/seeds/cannabis)
	created_product = /obj/item/food/grown/cannabis/white
	created_seed = /obj/item/seeds/cannabis/white
	required_endurance = list(30, 50)
	required_potency = list(30, INFINITY)

/datum/hydroponics/plant_mutation/omega_weed
	mutates_from = list(/obj/item/seeds/cannabis)
	created_product = /obj/item/food/grown/cannabis/ultimate
	created_seed = /obj/item/seeds/cannabis/ultimate
	required_potency = list(420, INFINITY)

/datum/hydroponics/plant_mutation/rainbow_weed
	mutates_from = list(/obj/item/seeds/cannabis)
	created_product = /obj/item/food/grown/cannabis/rainbow
	created_seed = /obj/item/seeds/cannabis/rainbow
/datum/hydroponics/plant_mutation/ambrosia_deus
	mutates_from = list(/obj/item/seeds/ambrosia, /obj/item/seeds/ambrosia/gaia)
	created_product = /obj/item/food/grown/ambrosia/deus
	created_seed = /obj/item/seeds/ambrosia/deus
	required_endurance = list(40, 70)

/datum/hydroponics/plant_mutation/ambrosia_gaia
	mutates_from = list(/obj/item/seeds/ambrosia/deus)
	created_product = /obj/item/food/grown/ambrosia/gaia
	created_seed = /obj/item/seeds/ambrosia/gaia
	required_potency = list(0, 40)

/datum/hydroponics/plant_mutation/gold_apple
	mutates_from = list(/obj/item/seeds/apple)
	created_product = /obj/item/food/grown/apple/gold
	created_seed = /obj/item/seeds/apple/gold
	required_yield = list(10, 15)
	required_potency = list(70, INFINITY)

/datum/hydroponics/plant_mutation/mime_banana
	mutates_from = list(/obj/item/seeds/banana)
	created_product = /obj/item/food/grown/banana/mime
	created_seed = /obj/item/seeds/banana/mime
	required_lifespan = list(60, 80)
	required_potency = list(-INFINITY, 20)

/datum/hydroponics/plant_mutation/bluespace_banana
	mutates_from = list(/obj/item/seeds/banana)
	created_product = /obj/item/food/grown/banana/bluespace
	created_seed = /obj/item/seeds/banana/bluespace
	required_production = list(20, 60)
	required_potency = list(70, INFINITY)

/datum/hydroponics/plant_mutation/koi_beans
	mutates_from = list(/obj/item/seeds/soya)
	created_product = /obj/item/food/grown/koibeans
	created_seed = /obj/item/seeds/soya/koi
	required_potency = list(30, 50)

/datum/hydroponics/plant_mutation/glow_berry
	mutates_from = list(/obj/item/seeds/berry)
	created_product = /obj/item/food/grown/berries/glow
	created_seed = /obj/item/seeds/berry/glow
	required_lifespan = list(30, 50)

/datum/hydroponics/plant_mutation/poison_berry
	mutates_from = list(/obj/item/seeds/berry)
	created_product = /obj/item/food/grown/berries/poison
	created_seed = /obj/item/seeds/berry/poison
	required_endurance = list(10, 50)
	required_potency = list(50, 100)

/datum/hydroponics/plant_mutation/death_berry
	mutates_from = list(/obj/item/seeds/berry/poison)
	created_product = /obj/item/food/grown/berries/death
	created_seed = /obj/item/seeds/berry/death
	required_potency = list(120, INFINITY)

/datum/hydroponics/plant_mutation/blue_cherry
	mutates_from = list(/obj/item/seeds/cherry)
	created_product = /obj/item/food/grown/bluecherries
	created_seed = /obj/item/seeds/cherry/blue
	required_endurance = list(40, 80)

/datum/hydroponics/plant_mutation/cherry_bulb
	mutates_from = list(/obj/item/seeds/cherry)
	created_product = /obj/item/food/grown/cherrybulbs
	created_seed = /obj/item/seeds/cherry/bulb
	required_potency = list(70, 90)

/datum/hydroponics/plant_mutation/green_grape
	mutates_from = list(/obj/item/seeds/grape)
	created_product = /obj/item/food/grown/grapes/green
	created_seed = /obj/item/seeds/grape/green

/datum/hydroponics/plant_mutation/oat_wheat
	mutates_from = list(/obj/item/seeds/wheat)
	created_product = /obj/item/food/grown/oat
	created_seed = /obj/item/seeds/wheat/oat
	required_endurance = list(50, INFINITY)

/datum/hydroponics/plant_mutation/meat_wheat
	mutates_from = list(/obj/item/seeds/wheat)
	created_product = /obj/item/food/grown/meatwheat
	created_seed = /obj/item/seeds/wheat/meat
	required_lifespan = list(70, INFINITY)

/datum/hydroponics/plant_mutation/ghost_chili
	mutates_from = list(/obj/item/seeds/chili)
	created_product = /obj/item/food/grown/ghost_chili
	created_seed = /obj/item/seeds/chili/ghost
	required_potency = list(75, INFINITY)

/datum/hydroponics/plant_mutation/orange
	mutates_from = list(/obj/item/seeds/lime)
	created_product = /obj/item/food/grown/citrus/orange
	created_seed = /obj/item/seeds/orange

/datum/hydroponics/plant_mutation/dimension_orange
	mutates_from = list(/obj/item/seeds/orange)
	created_product = /obj/item/food/grown/citrus/orange_3d
	created_seed = /obj/item/seeds/orange_3d
	required_endurance = list(50, INFINITY)

/datum/hydroponics/plant_mutation/lime
	mutates_from = list(/obj/item/seeds/orange)
	created_product = /obj/item/food/grown/citrus/lime
	created_seed = /obj/item/seeds/lime

/datum/hydroponics/plant_mutation/fire_lemon
	mutates_from = list(/obj/item/seeds/lemon)
	created_product = /obj/item/food/grown/firelemon
	created_seed = /obj/item/seeds/firelemon
	required_endurance = list(-INFINITY, 15)

/datum/hydroponics/plant_mutation/vanilla_pod
	mutates_from = list(/obj/item/seeds/cocoapod)
	created_product = /obj/item/food/grown/vanillapod
	created_seed = /obj/item/seeds/cocoapod/vanillapod
	required_yield = list(9, 20)

/datum/hydroponics/plant_mutation/bungo_tree
	mutates_from = list(/obj/item/seeds/cocoapod)
	created_product = /obj/item/food/grown/bungofruit
	created_seed = /obj/item/seeds/cocoapod/bungotree
	required_endurance = list(60, INFINITY)

/datum/hydroponics/plant_mutation/snap_corn
	mutates_from = list(/obj/item/seeds/corn)
	created_product = /obj/item/grown/snapcorn
	created_seed = /obj/item/seeds/corn/snapcorn
	required_potency = list(80, INFINITY)

/datum/hydroponics/plant_mutation/durathread
	mutates_from = list(/obj/item/seeds/cotton)
	created_product = /obj/item/grown/cotton/durathread
	created_seed = /obj/item/seeds/cotton/durathread
	required_endurance = list(80, INFINITY)


/datum/hydroponics/plant_mutation/lily
	mutates_from = list(/obj/item/seeds/poppy)
	created_product = /obj/item/food/grown/poppy/lily
	created_seed = /obj/item/seeds/poppy/lily

/datum/hydroponics/plant_mutation/geranium
	mutates_from = list(/obj/item/seeds/poppy)
	created_product = /obj/item/food/grown/poppy/geranium
	created_seed = /obj/item/seeds/poppy/geranium

/datum/hydroponics/plant_mutation/fraxinella
	mutates_from = list(/obj/item/seeds/poppy/geranium)
	created_product = /obj/item/food/grown/poppy/geranium/fraxinella
	created_seed = /obj/item/seeds/poppy/geranium/fraxinella

/datum/hydroponics/plant_mutation/trumpet
	mutates_from = list(/obj/item/seeds/poppy/lily)
	created_product = /obj/item/food/grown/trumpet
	created_seed = /obj/item/seeds/poppy/lily/trumpet
	required_endurance = list(30, INFINITY)

/datum/hydroponics/plant_mutation/moon_flower
	mutates_from = list(/obj/item/seeds/sunflower)
	created_product = /obj/item/food/grown/moonflower
	created_seed = /obj/item/seeds/sunflower/moonflower
	required_endurance = list(30, 70)

/datum/hydroponics/plant_mutation/nova_flower
	mutates_from = list(/obj/item/seeds/sunflower)
	created_product = /obj/item/grown/novaflower
	created_seed = /obj/item/seeds/sunflower/novaflower
	required_potency = list(90, INFINITY)

/datum/hydroponics/plant_mutation/carpet
	mutates_from = list(/obj/item/seeds/grass)
	created_product = /obj/item/food/grown/grass/carpet
	created_seed = /obj/item/seeds/grass/carpet
	required_production = list(20, INFINITY)

/datum/hydroponics/plant_mutation/fairy
	mutates_from = list(/obj/item/seeds/grass)
	created_product = /obj/item/food/grown/grass/fairy
	created_seed = /obj/item/seeds/grass/fairy
	required_potency = list(45, INFINITY)

/datum/hydroponics/plant_mutation/korta_nut_sweet
	mutates_from = list(/obj/item/seeds/korta_nut)
	created_product = /obj/item/food/grown/korta_nut/sweet
	created_seed = /obj/item/seeds/korta_nut/sweet
	required_lifespan = list(30, INFINITY)
	required_potency = list(45, INFINITY)
	required_production = list(20, INFINITY)

/datum/hydroponics/plant_mutation/holy_melon
	mutates_from = list(/obj/item/seeds/watermelon)
	created_product = /obj/item/food/grown/holymelon
	created_seed = /obj/item/seeds/watermelon/holy
	required_lifespan = list(80, INFINITY)

/datum/hydroponics/plant_mutation/galaxy_thistle
	mutates_from = list(/obj/item/seeds/starthistle)
	created_product = /obj/item/food/grown/galaxythistle
	created_seed = /obj/item/seeds/galaxythistle

/datum/hydroponics/plant_mutation/corpse_flower
	mutates_from = list(/obj/item/seeds/starthistle)
	created_seed = /obj/item/seeds/starthistle/corpse_flower

/datum/hydroponics/plant_mutation/replica_pod
	mutates_from = list(/obj/item/seeds/cabbage)
	created_seed = /obj/item/seeds/replicapod
	required_endurance = list(70, INFINITY)
	required_lifespan = list(70, INFINITY)

/datum/hydroponics/plant_mutation/bamboo
	mutates_from = list(/obj/item/seeds/sugarcane)
	created_product = /obj/item/grown/log/bamboo
	created_seed = /obj/item/seeds/bamboo
	required_endurance = list(80, INFINITY)

/datum/hydroponics/plant_mutation/angel
	mutates_from = list(/obj/item/seeds/amanita)
	created_product = /obj/item/food/grown/mushroom/angel
	created_seed = /obj/item/seeds/angel
	required_yield = list(25, INFINITY)
	required_potency = list(-INFINITY, 10)

/datum/hydroponics/plant_mutation/walking_mushroom
	mutates_from = list(/obj/item/seeds/plump)
	created_seed = /obj/item/seeds/plump/walkingmushroom
	required_lifespan = list(40, INFINITY)

/datum/hydroponics/plant_mutation/jupiter_cup
	mutates_from = list(/obj/item/seeds/chanter)
	created_product = /obj/item/food/grown/mushroom/jupitercup
	created_seed = /obj/item/seeds/chanter/jupitercup
	required_endurance = list(50, INFINITY)
	required_potency = list(60, INFINITY)


/datum/hydroponics/plant_mutation/glow_cap
	mutates_from = list(/obj/item/seeds/glowshroom)
	created_product = /obj/item/food/grown/mushroom/glowshroom/glowcap
	created_seed = /obj/item/seeds/glowshroom/glowcap
	required_endurance = list(60, INFINITY)
	required_potency = list(80, INFINITY)

/datum/hydroponics/plant_mutation/shadow_shroom
	mutates_from = list(/obj/item/seeds/glowshroom)
	created_product = /obj/item/food/grown/mushroom/glowshroom/shadowshroom
	created_seed = /obj/item/seeds/glowshroom/shadowshroom
	required_production = list(45, INFINITY)
	required_endurance = list(-INFINITY, 30)

/datum/hydroponics/plant_mutation/death_nettle
	mutates_from = list(/obj/item/seeds/nettle)
	created_product = /obj/item/food/grown/nettle/death
	created_seed = /obj/item/seeds/nettle/death
	required_endurance = list(80, INFINITY)
	required_lifespan = list(40, 90)

/datum/hydroponics/plant_mutation/red_onion
	mutates_from = list(/obj/item/seeds/onion)
	created_product = /obj/item/food/grown/onion/red
	created_seed = /obj/item/seeds/onion/red
	required_potency = list(70, INFINITY)

/datum/hydroponics/plant_mutation/sweet_potato
	mutates_from = list(/obj/item/seeds/potato)
	created_product = /obj/item/food/grown/potato/sweet
	created_seed = /obj/item/seeds/potato/sweet
	required_potency = list(70, INFINITY)

/datum/hydroponics/plant_mutation/blumpkin
	mutates_from = list(/obj/item/seeds/pumpkin)
	created_product = /obj/item/food/grown/pumpkin/blumpkin
	created_seed = /obj/item/seeds/pumpkin/blumpkin
	required_endurance = list(-INFINITY, 30)
	required_lifespan = list(-INFINITY, 30)

/datum/hydroponics/plant_mutation/parsnip
	mutates_from = list(/obj/item/seeds/carrot)
	created_product = /obj/item/food/grown/parsnip
	created_seed = /obj/item/seeds/carrot/parsnip
	required_potency = list(60, INFINITY)

/datum/hydroponics/plant_mutation/redbeet
	mutates_from = list(/obj/item/seeds/whitebeet)
	created_product = /obj/item/food/grown/redbeet
	created_seed = /obj/item/seeds/redbeet
	required_potency = list(90, 120)

/datum/hydroponics/plant_mutation/astra_tea
	mutates_from = list(/obj/item/seeds/tea)
	created_product = /obj/item/food/grown/tea/astra
	created_seed = /obj/item/seeds/tea/astra
	required_yield = list(20, 40)
	required_potency = list(60, INFINITY)

/datum/hydroponics/plant_mutation/robusta_coffee
	mutates_from = list(/obj/item/seeds/coffee)
	created_product = /obj/item/food/grown/coffee/robusta
	created_seed = /obj/item/seeds/coffee/robusta
	required_potency = list(-INFINITY, 30)
	required_yield = list(20, INFINITY)

/datum/hydroponics/plant_mutation/space_tobacco
	mutates_from = list(/obj/item/seeds/tobacco)
	created_product = /obj/item/food/grown/tobacco/space
	created_seed = /obj/item/seeds/tobacco/space
	required_endurance = list(50, INFINITY)

/datum/hydroponics/plant_mutation/blue_tomato
	mutates_from = list(/obj/item/seeds/tomato)
	created_product = /obj/item/food/grown/tomato/blue
	created_seed = /obj/item/seeds/tomato/blue
	required_endurance = list(50, INFINITY)

/datum/hydroponics/plant_mutation/blood_tomato
	mutates_from = list(/obj/item/seeds/tomato)
	created_product = /obj/item/food/grown/tomato/blood
	created_seed = /obj/item/seeds/tomato/blood
	required_potency = list(60, INFINITY)

/datum/hydroponics/plant_mutation/killer_tomato
	mutates_from = list(/obj/item/seeds/tomato)
	created_product = /obj/item/food/grown/tomato/killer
	created_seed = /obj/item/seeds/tomato/killer
	required_lifespan = list(50, 90)

/datum/hydroponics/plant_mutation/bluespace_tomato
	mutates_from = list(/obj/item/seeds/tomato/blue)
	created_product = /obj/item/food/grown/tomato/blue/bluespace
	created_seed = /obj/item/seeds/tomato/blue/bluespace
	required_potency = list(120, INFINITY)

/datum/hydroponics/plant_mutation/steel_towercap
	mutates_from = list(/obj/item/seeds/tower)
	created_product = /obj/item/grown/log/steel
	created_seed = /obj/item/seeds/tower/steel
	required_endurance = list(80, INFINITY)

/datum/hydroponics/plant_mutation/greenbean_jump
	mutates_from = list(/obj/item/seeds/greenbean)
	created_product = /obj/item/food/grown/jumpingbeans
	created_seed = /obj/item/seeds/greenbean/jump
	required_potency = list(70, INFINITY)

/datum/hydroponics/plant_mutation/melon_barrel
	mutates_from = list(/obj/item/seeds/watermelon)
	created_product = /obj/item/food/grown/barrelmelon
	created_seed = /obj/item/seeds/watermelon/barrel
	required_endurance = list(60, INFINITY)
	required_lifespan = list(40, INFINITY)

/datum/hydroponics/plant_mutation/rose_carbon
	mutates_from = list(/obj/item/seeds/rose)
	created_product = /obj/item/food/grown/carbon_rose
	created_seed = /obj/item/seeds/carbon_rose
	required_lifespan = list(30, 50)

/datum/hydroponics/plant_mutation/peas_laughin
	mutates_from = list(/obj/item/seeds/peas)
	created_product = /obj/item/food/grown/laugh
	created_seed = /obj/item/seeds/peas/laugh
	required_endurance = list(-INFINITY, 25)
	required_potency = list(40, 50)

/datum/hydroponics/plant_mutation/peas_world
	mutates_from = list(/obj/item/seeds/peas/laugh)
	created_product = /obj/item/food/grown/peace
	created_seed = /obj/item/seeds/peas/laugh/peace
	required_production = list(100, INFINITY)
	required_yield = list(100, INFINITY)

/datum/hydroponics/plant_mutation/plumb
	mutates_from = list(/obj/item/seeds/plum)
	created_product = /obj/item/food/grown/plum/plumb
	created_seed = /obj/item/seeds/plum/plumb
	required_endurance = list(60, INFINITY)

/datum/hydroponics/plant_mutation/star_cactus
	mutates_from = list(/obj/item/seeds/lavaland/cactus)
	created_product = /obj/item/food/grown/star_cactus
	created_seed = /obj/item/seeds/star_cactus
	required_endurance = list(-INFINITY, 20)
	required_yield = list(-INFINITY, 20)

/datum/hydroponics/plant_mutation/kudzu_vines
	mutates_from = list(/obj/item/seeds/shrub)
	created_product = /obj/item/food/grown/kudzupod
	created_seed = /obj/item/seeds/kudzu
	required_production = list(90, 100)
	required_endurance = list(60, 70)
	required_yield = list(5, 10)
	required_lifespan = list(-INFINITY, 20)
