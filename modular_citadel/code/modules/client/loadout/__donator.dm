//This is the file that handles donator loadout items.

/datum/gear/pingcoderfailsafe
	name = "IF YOU SEE THIS, PING A CODER RIGHT NOW!"
	category = SLOT_IN_BACKPACK
	path = /obj/item/bikehorn/golden
	ckeywhitelist = list("This entry should never appear with this variable set.") //If it does, then that means somebody fucked up the whitelist system pretty hard

/datum/gear/donortestingbikehorn
	name = "Donor item testing bikehorn"
	category = SLOT_IN_BACKPACK
	path = /obj/item/bikehorn
	geargroupID = "DONORTEST"

/datum/gear/kevhorn
	name = "Airhorn"
	category = SLOT_IN_BACKPACK
	path = /obj/item/bikehorn/airhorn
	ckeywhitelist = list("kevinz000")

/datum/gear/cebusoap
	name = "Cebutris' soap"
	category = SLOT_IN_BACKPACK
	path = /obj/item/custom/ceb_soap
	ckeywhitelist = list("cebutris")

/datum/gear/kiaracloak
	name = "Kiara's cloak"
	category = SLOT_NECK
	path = /obj/item/clothing/neck/cloak/inferno
	ckeywhitelist = list("inferno707")

/datum/gear/kiaracollar
	name = "Kiara's collar"
	category = SLOT_NECK
	path = /obj/item/clothing/neck/petcollar/inferno
	ckeywhitelist = list("inferno707")

/datum/gear/kiaramedal
	name = "Insignia of Steele"
	category = SLOT_IN_BACKPACK
	path = /obj/item/clothing/accessory/medal/steele
	ckeywhitelist = list("inferno707")

/datum/gear/hheart
	name = "The Hollow Heart"
	category = SLOT_WEAR_MASK
	path = /obj/item/clothing/mask/hheart
	ckeywhitelist = list("inferno707")

/datum/gear/engravedzippo
	name = "Engraved zippo"
	category = SLOT_HANDS
	path = /obj/item/lighter/gold
	ckeywhitelist = list("dirtyoldharry")

/datum/gear/geisha
	name = "Geisha suit"
	category = SLOT_W_UNIFORM
	path = /obj/item/clothing/under/geisha
	ckeywhitelist = list("atiefling")

/datum/gear/specialscarf
	name = "Special scarf"
	category = SLOT_NECK
	path = /obj/item/clothing/neck/scarf/zomb
	ckeywhitelist = list("zombierobin")

/datum/gear/redmadcoat
	name = "The Mad's labcoat"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/toggle/labcoat/mad/red
	ckeywhitelist = list("zombierobin")

/datum/gear/santahat
	name = "Santa hat"
	category = SLOT_HEAD
	path = /obj/item/clothing/head/santa/fluff
	ckeywhitelist = list("illotafv")

/datum/gear/reindeerhat
	name = "Reindeer hat"
	category = SLOT_HEAD
	path = /obj/item/clothing/head/hardhat/reindeer/fluff
	ckeywhitelist = list("illotafv")

/datum/gear/treeplushie
	name = "Christmas tree plushie"
	category = SLOT_IN_BACKPACK
	path = /obj/item/toy/plush/tree
	ckeywhitelist = list("illotafv")

/datum/gear/santaoutfit
	name = "Santa costume"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/space/santa/fluff
	ckeywhitelist = list("illotafv")

/datum/gear/treecloak
	name = "Christmas tree cloak"
	category = SLOT_NECK
	path = /obj/item/clothing/neck/cloak/festive
	ckeywhitelist = list("illotafv")

/datum/gear/carrotplush
	name = "Carrot plushie"
	category = SLOT_IN_BACKPACK
	path = /obj/item/toy/plush/carrot
	ckeywhitelist = list("improvedname")

/datum/gear/carrotcloak
	name = "Carrot cloak"
	category = SLOT_NECK
	path = /obj/item/clothing/neck/cloak/carrot
	ckeywhitelist = list("improvedname")

/datum/gear/albortorosamask
	name = "Alborto Rosa mask"
	category = SLOT_WEAR_MASK
	path = /obj/item/clothing/mask/luchador/zigfie
	ckeywhitelist = list("zigfie")

/datum/gear/mankini
	name = "Mankini"
	category = SLOT_W_UNIFORM
	path = /obj/item/clothing/under/mankini
	ckeywhitelist = list("zigfie")

/datum/gear/pinkshoes
	name = "Pink shoes"
	category = SLOT_SHOES
	path = /obj/item/clothing/shoes/sneakers/pink
	ckeywhitelist = list("zigfie")

/datum/gear/reecesgreatcoat
	name = "Reece's Great Coat"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/trenchcoat/green
	ckeywhitelist = list("geemiesif")

/datum/gear/russianflask
	name = "Russian flask"
	category = SLOT_IN_BACKPACK
	path = /obj/item/reagent_containers/food/drinks/flask/russian
	cost = 2
	ckeywhitelist = list("slomka")

/datum/gear/stalkermask
	name = "S.T.A.L.K.E.R. mask"
	category = SLOT_WEAR_MASK
	path = /obj/item/clothing/mask/gas/stalker
	ckeywhitelist = list("slomka")

/datum/gear/stripedcollar
	name = "Striped collar"
	category = SLOT_NECK
	path = /obj/item/clothing/neck/petcollar/stripe
	ckeywhitelist = list("jademanique")

/datum/gear/performersoutfit
	name = "Bluish performer's outfit"
	category = SLOT_W_UNIFORM
	path = /obj/item/clothing/under/singery/custom
	ckeywhitelist = list("killer402402")

/datum/gear/vermillion
	name = "Vermillion clothing"
	category = SLOT_W_UNIFORM
	path = /obj/item/clothing/suit/vermillion
	ckeywhitelist = list("fractious")

/datum/gear/AM4B
	name = "Foam Force AM4-B"
	category = SLOT_IN_BACKPACK
	path = /obj/item/gun/ballistic/automatic/AM4B
	ckeywhitelist = list("zeronetalpha")

/datum/gear/carrotsatchel
	name = "Carrot Satchel"
	category = SLOT_HANDS
	path = /obj/item/storage/backpack/satchel/carrot
	ckeywhitelist = list("improvedname")

/datum/gear/naomisweater
	name = "worn black sweater"
	category = SLOT_W_UNIFORM
	path = /obj/item/clothing/under/bb_sweater/black/naomi
	ckeywhitelist = list("technicalmagi")

/datum/gear/naomicollar
	name = "worn pet collar"
	category = SLOT_NECK
	path = /obj/item/clothing/neck/petcollar/naomi
	ckeywhitelist = list("technicalmagi")

/datum/gear/gladiator
    name = "Gladiator Armor"
    category = SLOT_WEAR_SUIT
    path = /obj/item/clothing/under/gladiator
    ckeywhitelist = list("aroche")

/datum/gear/bloodredtie
    name = "Blood Red Tie"
    category = SLOT_NECK
    path = /obj/item/clothing/neck/tie/bloodred
    ckeywhitelist = list("kyutness")

/datum/gear/puffydress
    name = "Puffy Dress"
    category = SLOT_WEAR_SUIT
    path = /obj/item/clothing/suit/puffydress
    ckeywhitelist = list("stallingratt")

/datum/gear/labredblack
    name = "Black and Red Coat"
    category = SLOT_WEAR_SUIT
    path = /obj/item/clothing/suit/toggle/labcoat/labredblack
    ckeywhitelist = list("blakeryan", "durandalphor")

/datum/gear/torisword
	name = "Rainbow Zweihander"
	category = SLOT_IN_BACKPACK
	path = /obj/item/twohanded/hypereutactic/toy/rainbow
	ckeywhitelist = list("annoymous35")

/datum/gear/darksabre
	name = "Dark Sabre"
	category = SLOT_IN_BACKPACK
	path = /obj/item/toy/sword/darksabre
	ckeywhitelist = list("inferno707")

datum/gear/darksabresheath
	name = "Dark Sabre Sheath"
	category = SLOT_IN_BACKPACK
	path = /obj/item/storage/belt/sabre/darksabre
	ckeywhitelist = list("inferno707")

/datum/gear/toriball
	name = "Rainbow Tennis Ball"
	category = SLOT_IN_BACKPACK
	path = /obj/item/toy/tennis/rainbow
	ckeywhitelist = list("annoymous35")

/datum/gear/izzyball
	name = "Katlin's Ball"
	category = SLOT_IN_BACKPACK
	path = /obj/item/toy/tennis/rainbow/izzy
	ckeywhitelist = list("izzyinbox")

/datum/gear/cloak
	name = "Green Cloak"
	category = SLOT_NECK
	path = /obj/item/clothing/neck/cloak/green
	ckeywhitelist = list("killer402402")

/datum/gear/steelflask
	name = "Steel Flask"
	category = SLOT_IN_BACKPACK
	path = /obj/item/reagent_containers/food/drinks/flask/steel
	cost = 2
	ckeywhitelist = list("johnnyvitrano")

/datum/gear/paperhat
	name = "Paper Hat"
	category = SLOT_HEAD
	path = /obj/item/clothing/head/paperhat
	ckeywhitelist = list("kered2")

/datum/gear/cloakce
	name = "Polychromic CE Cloak"
	category = SLOT_IN_BACKPACK
	path = /obj/item/clothing/neck/cloak/polychromic/polyce
	ckeywhitelist = list("worksbythesea", "blakeryan")

/datum/gear/ssk
	name = "Stun Sword Kit"
	category = SLOT_IN_BACKPACK
	path = 	/obj/item/ssword_kit
	ckeywhitelist = list("phillip458")

/datum/gear/techcoat
	name = "Techomancers Labcoat"
	category = SLOT_IN_BACKPACK
	path = /obj/item/clothing/suit/toggle/labcoat/mad/techcoat
	ckeywhitelist = list("wilchen")

/datum/gear/leechjar
	name = "Jar of Leeches"
	category = SLOT_IN_BACKPACK
	path = 	/obj/item/custom/leechjar
	ckeywhitelist = list("sgtryder")

/datum/gear/darkarmor
	name = "Dark Armor"
	category = SLOT_IN_BACKPACK
	path = /obj/item/clothing/suit/armor/vest/darkcarapace
	ckeywhitelist = list("inferno707")

/datum/gear/devilwings
	name = "Strange Wings"
	category = SLOT_NECK
	path = /obj/item/clothing/neck/devilwings
	ckeywhitelist = list("kitsun")

/datum/gear/flagcape
	name = "US Flag Cape"
	category = SLOT_IN_BACKPACK
	path = /obj/item/bedsheet/custom/flagcape
	ckeywhitelist = list("darnchacha")

/datum/gear/luckyjack
	name = "Lucky Jackboots"
	category = SLOT_IN_BACKPACK
	path = /obj/item/clothing/shoes/lucky
	ckeywhitelist = list("donaldtrumpthecommunist")

/datum/gear/raiqbawks
	name = "Miami Boombox"
	category = SLOT_HANDS
	cost = 2
	path = /obj/item/boombox/raiq
	ckeywhitelist = list("chefferz")

/datum/gear/m41
	name = "Toy M41"
	category = SLOT_IN_BACKPACK
	path = /obj/item/toy/gun/m41
	ckeywhitelist = list("thalverscholen")
