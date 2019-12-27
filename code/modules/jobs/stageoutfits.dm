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
    var/ckey = null
    var/stage = null
    var/time = 120 SECONDS
    var/items = list()
    var/act_completed = FALSE
    var/dead = 0 // How many deaths have occured

/datum/outfit/stage/citrus_test
    ckey = "citrusgender"
    items = list(
    /obj/item/reagent_containers/food/snacks/donkpocket, 
    /obj/item/reagent_containers/food/snacks/donkpocket, 
    /obj/item/reagent_containers/food/snacks/donkpocket,
    /obj/item/reagent_containers/food/snacks/donkpocket,
    /obj/item/reagent_containers/food/snacks/donkpocket)

/datum/outfit/stage/fikou
    ckey = "fikou"
    items = list(
    /obj/item/gun/energy/meteorgun/clumsy,
    /obj/item/dnainjector/clumsymut)

/obj/item/gun/energy/meteorgun/clumsy
    clumsy_check = 1



