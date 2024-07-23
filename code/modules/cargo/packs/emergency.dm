/datum/supply_pack/emergency
	group = "Emergency"
	discountable = SUPPLY_PACK_UNCOMMON_DISCOUNTABLE

/datum/supply_pack/emergency/bio
	name = "Biological Emergency Crate"
	desc = "This crate includes 2 complete bio suits, along with a box containing sterile masks and latex gloves, providing effective protection against viruses."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/clothing/head/bio_hood/general = 2,
					/obj/item/clothing/suit/bio_suit/general = 2,
					/obj/item/storage/bag/bio,
					/obj/item/reagent_containers/syringe/antiviral = 2,
					/obj/item/clothing/gloves/latex/nitrile = 2,
					/obj/item/storage/box/masks,
					/obj/item/storage/box/gloves,
				)
	crate_name = "bio suit crate"

/datum/supply_pack/emergency/equipment
	name = "Emergency Bot/Internals Crate"
	desc = "Explosions got you down? These supplies are guaranteed to patch up holes, \
		in stations and people alike! Comes with two floorbots, two medbots, five oxygen \
		masks and five small oxygen tanks."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(
		/mob/living/basic/bot/medbot = 2,
		/mob/living/simple_animal/bot/floorbot = 2,
		/obj/item/tank/internals/emergency_oxygen = 5,
		/obj/item/clothing/mask/breath = 5,
	)
	crate_name = "emergency crate"
	crate_type = /obj/structure/closet/crate/internals

/datum/supply_pack/emergency/bomb
	name = "Explosive Emergency Crate"
	desc = "Science gone bonkers? Beeping behind the airlock? Buy now and be the hero the station des... \
		I mean needs! (time not included). Contains one bomb suit and hood, gas mask, and bomb defusal tools."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/clothing/head/utility/bomb_hood,
					/obj/item/clothing/suit/utility/bomb_suit,
					/obj/item/clothing/mask/gas,
					/obj/item/screwdriver,
					/obj/item/wirecutters,
					/obj/item/multitool,
				)
	crate_name = "bomb suit crate"

/datum/supply_pack/emergency/firefighting
	name = "Firefighting Crate"
	desc = "Only you can prevent station fires. Partner up with two firefighter suits, gas masks, \
		flashlights, large oxygen tanks, extinguishers, and hardhats!"
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/clothing/suit/utility/fire/firefighter = 2,
					/obj/item/clothing/mask/gas = 2,
					/obj/item/flashlight = 2,
					/obj/item/tank/internals/oxygen/red = 2,
					/obj/item/extinguisher/advanced = 2,
					/obj/item/clothing/head/utility/hardhat/red = 2,
				)
	crate_name = "firefighting crate"

/datum/supply_pack/emergency/atmostank
	name = "Firefighting Tank Backpack"
	desc = "Mow down fires with this high-capacity fire fighting tank backpack."
	cost = CARGO_CRATE_VALUE * 1.8
	access = ACCESS_ATMOSPHERICS
	contains = list(/obj/item/watertank/atmos)
	crate_name = "firefighting backpack crate"
	crate_type = /obj/structure/closet/crate/secure/engineering/atmos

/datum/supply_pack/emergency/internals
	name = "Internals Crate"
	desc = "Master your life energy and control your breathing with three breath masks, \
		three emergency oxygen tanks and three large air tanks." // IS THAT A
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/clothing/mask/gas = 3,
					/obj/item/clothing/mask/breath = 3,
					/obj/item/tank/internals/emergency_oxygen = 3,
					/obj/item/tank/internals/oxygen = 3,
				)
	crate_name = "internals crate"
	crate_type = /obj/structure/closet/crate/internals

/datum/supply_pack/emergency/metalfoam
	name = "Metal Foam Grenade Crate"
	desc = "Seal up those pesky hull breaches with seven metal foam grenades."
	cost = CARGO_CRATE_VALUE * 2.4
	contains = list(/obj/item/storage/box/metalfoam)
	crate_name = "metal foam grenade crate"

/datum/supply_pack/emergency/plasma_spacesuit
	name = "Plasmaman Space Envirosuits"
	desc = "Contains two space-worthy envirosuits for Plasmamen. \
		Order now and we'll throw in two free helmets!"
	cost = CARGO_CRATE_VALUE * 3.5
	access = ACCESS_EVA
	contains = list(/obj/item/clothing/suit/space/eva/plasmaman = 2,
					/obj/item/clothing/head/helmet/space/plasmaman = 2,
				)
	crate_name = "plasmaman EVA crate"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/emergency/plasmaman
	name = "Plasmaman Supply Kit"
	desc = "Keep those Plasmamen alive with two sets of Plasmaman outfits. \
		Each set contains a plasmaman jumpsuit, gloves, internals tank, and helmet."
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/obj/item/clothing/under/plasmaman = 2,
					/obj/item/tank/internals/plasmaman/belt/full = 2,
					/obj/item/clothing/head/helmet/space/plasmaman = 2,
					/obj/item/clothing/gloves/color/plasmaman = 2,
				)
	crate_name = "plasmaman supply kit"

/datum/supply_pack/emergency/radiation
	name = "Radiation Protection Crate"
	desc = "Survive the Nuclear Apocalypse and Supermatter Engine alike with two sets of radiation suits. \
		Each set contains a helmet, suit, and Geiger counter. We'll even throw in a bottle of vodka and some glasses too, \
		considering the life-expectancy of people who order this."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/clothing/head/utility/radiation = 2,
					/obj/item/clothing/suit/utility/radiation = 2,
					/obj/item/geiger_counter = 2,
					/obj/item/reagent_containers/cup/glass/bottle/vodka,
					/obj/item/reagent_containers/cup/glass/drinkingglass/shotglass = 2,
				)
	crate_name = "radiation protection crate"
	crate_type = /obj/structure/closet/crate/radiation

/datum/supply_pack/emergency/spacesuit
	name = "Space Suit Crate"
	desc = "Contains one aging suit from Space-Goodwill and a jetpack."
	cost = CARGO_CRATE_VALUE * 3
	access = ACCESS_EVA
	contains = list(/obj/item/clothing/suit/space,
					/obj/item/clothing/head/helmet/space,
					/obj/item/clothing/mask/breath,
					/obj/item/tank/jetpack/carbondioxide,
				)
	crate_name = "space suit crate"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/emergency/weedcontrol
	name = "Weed Control Crate"
	desc = "Keep those invasive species OUT. Contains a scythe, leather gloves, gasmask, and two anti-weed chemical grenades. \
		Warranty void if used on ambrosia."
	cost = CARGO_CRATE_VALUE * 2.5
	access = ACCESS_HYDROPONICS
	contains = list(/obj/item/scythe,
					/obj/item/clothing/gloves/botanic_leather,
					/obj/item/clothing/mask/gas,
					/obj/item/grenade/chem_grenade/antiweed = 2,
				)
	crate_name = "weed control crate"
	crate_type = /obj/structure/closet/crate/secure/hydroponics

/datum/supply_pack/emergency/mothic_rations
	name = "Surplus Mothic Rations Triple-Pak"
	desc = "Crew starving? Chef slacking off? Keep everyone fed on the barest minimum of what can be considered food \
		with surplus ration packs, directly from the Mothic Fleet! Pack includes 3 packs of 3 bars each."
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/obj/item/storage/box/mothic_rations = 3)
	crate_name = "surplus rations box"
	crate_type = /obj/structure/closet/crate/cardboard/mothic
