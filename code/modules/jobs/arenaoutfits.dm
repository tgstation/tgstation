// If you want to load a toolbox outfit, put it here. Please don't change anything more than the uniform and suit.
// You can make your own as such:

//datum/outfit/arena/***WHATEVER_YOUR_TEAM_NAME_IS***
//    title = "Arena team: ***PUT YOUR TEAM NAME HERE***"
//    uniform = ***SELECT THE TYPE PATH OF THE UNIFORM YOU WANT TO USE***
//    suit = ***SELECT THE TYPE PATH OF THE SUIT YOU WANT TO USE***
// PLEASE NOTE THAT ANY ARMOR WHICH GIVES PROTECTION FROM HITS/ETC WILL NOT BE ALLOWED. PLEASE PICK ONLY COSMETIC ARMORS/UNIFORMS
// also don't put any astrisks you dummy

/datum/outfit/arena
    name = "Arena default"
    uniform = /obj/item/clothing/under/color/random
    suit = /obj/item/clothing/suit/hooded/ian_costume

datum/outfit/arena/topdown_sprites
    name = "Arena team: We Miss Topdown Sprites"
    uniform = /obj/item/clothing/under/color/grey/glorf

datum/outfit/arena/terry_gang     //(include underscores)
    name = "Arena team: TERRY GANG"
    uniform = /obj/item/clothing/under/color/grey
    suit = /obj/item/clothing/suit/monkeysuit
    mask = /obj/item/clothing/mask/gas/monkeymask

datum/outfit/arena/fusionfloodfriends
    name = "Arena team: Fusion Flood Friends"
    uniform = /obj/item/clothing/under/rank/engineering/atmospheric_technician
    suit = /obj/item/clothing/suit/radiation/noslow
    head = /obj/item/clothing/head/radiation
    shoes = /obj/item/clothing/shoes/workboots
    gloves = /obj/item/clothing/gloves/justyellowgloves