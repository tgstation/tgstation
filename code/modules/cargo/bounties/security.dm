/datum/bounty/item/security/securitybelt
	name = "Security Belt"
	description = "CentCom is having difficulties with their security belts. Ship one from the station to receive compensation."
	reward = 800
	wanted_types = list(/obj/item/storage/belt/security)

/datum/bounty/item/security/sechuds
	name = "Security HUDSunglasses"
	description = "CentCom screwed up and ordered the wrong type of security sunglasses. They request the station ship some of theirs."
	reward = 800
	wanted_types = list(/obj/item/clothing/glasses/hud/security/sunglasses)

/datum/bounty/item/security/riotshotgun
	name = "Riot Shotguns"
	description = "Hooligans have boarded CentCom! Ship riot shotguns quick, or things are going to get dirty."
	reward = 5000
	required_count = 2
	wanted_types = list(/obj/item/gun/ballistic/shotgun/riot)

/datum/bounty/item/security/recharger
	name = "Rechargers"
	description = "Nanotrasen military academy is conducting marksmanship exercises. They request that rechargers be shipped."
	reward = 2000
	required_count = 3
	wanted_types = list(/obj/machinery/recharger)
