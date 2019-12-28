// If you want to load a stage, put it here.
// You can make your own as such:

//datum/outfit/arena/***YOUR_CKEY***
//    name = "***PUT YOUR ACT'S NAME HERE***"
//    uniform = ***SELECT THE TYPE PATH OF THE UNIFORM YOU WANT TO USE***
//    suit = ***SELECT THE TYPE PATH OF THE SUIT YOU WANT TO USE***
// don't put any astrisks you dummy

// I'm kinda just using this a placeholder for all the components of a play.
// Obviously it could use it's own datum but this isn't going to be used for anything else.

/datum/outfit/stage
    name = "Stage default"
    uniform = /obj/item/clothing/under/color/random
    back = /obj/item/storage/backpack
    var/ckey = list("null")
    var/name_of_act
    var/stage = null
    var/time = 10 SECONDS
    var/items = list()
    var/act_completed = FALSE
    var/dead = 0 // How many deaths have occured
    var/override_presence = FALSE // If true, the person doesn't need to be present

    belt = /obj/item/pda/clown
    ears = /obj/item/radio/headset/headset_srv
    uniform = /obj/item/clothing/under/rank/civilian/clown
    shoes = /obj/item/clothing/shoes/clown_shoes
    mask = /obj/item/clothing/mask/gas/clown_hat
    l_pocket = /obj/item/bikehorn
    backpack_contents = list(
        /obj/item/stamp/clown = 1,
        /obj/item/reagent_containers/spray/waterflower = 1,
        /obj/item/reagent_containers/food/snacks/grown/banana = 1,
        /obj/item/instrument/bikehorn = 1,
        )
    
    implants = list(/obj/item/implant/sad_trombone)
    
    back = /obj/item/storage/backpack/clown

    box = /obj/item/storage/box/hug/survival

    chameleon_extras = /obj/item/stamp/clown

/datum/outfit/stage/citrus_test
    ckey = list("citrusgender")
    name_of_act = "citrusgender"
    time = 10 SECONDS
    items = list(
    /obj/effect/mine/explosive,
    /obj/effect/mine/sound/bwoink,
    /obj/effect/mine/sound/bwoink,
    /obj/effect/mine/sound/bwoink,
    /obj/effect/mine/sound/bwoink)
    shoes = /obj/item/clothing/shoes/clown_shoes/bruh

/datum/outfit/stage/fikou
    ckey = list("fikou")
    name_of_act = "fikou"
    items = list(
    /obj/item/gun/energy/meteorgun/clumsy,
    /obj/item/dnainjector/clumsymut)

/obj/item/gun/energy/meteorgun/clumsy
    clumsy_check = 1

/datum/outfit/stage/novaray
    ckey = list("novaray")
    name_of_act = "novarey"

/datum/outfit/stage/timonk
    ckey = list("timonk")
    name_of_act = "timonk"
    items = list(
    /obj/item/storage/toolbox/mechanical,
    /obj/item/clothing/suit/monkeysuit,
    /obj/item/clothing/mask/gas/monkeymask)

/datum/outfit/stage/fallingasteroids
    ckey = list("fallingasteroids")
    name_of_act = "fallingasteroids"
    items = list(
    /obj/structure/piano,
    /obj/item/wrench,
    /obj/item/instrument/saxophone,
    /obj/item/instrument/guitar)
    uniform = /obj/item/clothing/under/rank/centcom/commander
    suit = /obj/item/clothing/suit/space/hardsuit/deathsquad
    shoes = /obj/item/clothing/shoes/combat/swat
    gloves = /obj/item/clothing/gloves/combat
    mask = /obj/item/clothing/mask/gas/sechailer/swat
    glasses = /obj/item/clothing/glasses/hud/toggle/thermal
    back = /obj/item/storage/backpack/security
    l_pocket = /obj/item/melee/transforming/energy/sword/saber
    r_pocket = /obj/item/shield/energy
    suit_store = /obj/item/tank/internals/emergency_oxygen/double
    belt = /obj/item/gun/ballistic/revolver/mateba
    r_hand = /obj/item/gun/energy/pulse/loyalpin
    id = /obj/item/card/id/centcom
    ears = /obj/item/radio/headset/headset_cent/alt
    backpack_contents = list(/obj/item/storage/box=1,\
        /obj/item/ammo_box/a357=1,\
        /obj/item/storage/firstaid/regular=1,\
        /obj/item/storage/box/flashbangs=1,\
        /obj/item/flashlight=1,\
        /obj/item/grenade/c4/x4=1)

/datum/outfit/stage/qbmax
    ckey = list("qbmax")
    name_of_act = "qbmax"
    items = list(
    /obj/effect/mine/explosive,
    /obj/effect/mine/sound/bwoink,
    /obj/effect/mine/sound/bwoink,
    /mob/living/simple_animal/hostile/netherworld/migo,
    /obj/effect/mine/sound/bwoink)
    shoes = /obj/item/clothing/shoes/clown_shoes/bruh


/obj/item/clothing/shoes/clown_shoes/bruh
    desc = "bruh"

/obj/item/clothing/shoes/clown_shoes/bruh/Initialize()
    . = ..()
    AddComponent(/datum/component/squeak, list('sound/effects/bruh.ogg'=1,'sound/effects/bruh.ogg'=1), 50)
    var/obj/effect/A = new(get_turf(src))
    A.icon = 'icons/bruh.png'
    A.maptext_height = 200
    A.maptext_width = 100
    A.maptext = "<h1>I put meme entries into the talent show competition</h1>"
    A.SpinAnimation(10, 10)


/datum/outfit/stage/raveradbury
    ckey = list("raveradbury")
    name_of_act = "raveradbury"
    uniform = /obj/item/clothing/under/rank/civilian/mime/skirt
    accessory = /obj/item/clothing/accessory/maidapron
    mask = /obj/item/clothing/mask/gas/sexymime
    gloves = /obj/item/clothing/gloves/color/white
    head = /obj/item/clothing/head/wig/natural
    back = /obj/item/storage/backpack/satchel/leather
    items = list(
    /obj/machinery/deepfryer,
    /obj/machinery/photocopier,
    /obj/machinery/microwave,
    /obj/structure/table/reinforced,
    /obj/item/storage/box/rave)
    shoes = null

/obj/item/storage/box/rave
	name = "rave's box"
	illustration = "disk_kit"

/obj/item/storage/box/rave/PopulateContents()
    new /obj/item/kitchen/knife(src)
    new /obj/item/reagent_containers/food/condiment/flour(src)
    new /obj/item/reagent_containers/food/condiment/sugar(src)
    new /obj/item/reagent_containers/food/condiment/soymilk(src)
    new /obj/item/reagent_containers/glass/beaker(src)
