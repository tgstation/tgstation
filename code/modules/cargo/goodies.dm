
/datum/supply_pack/goody
	access = NONE
	group = "Goodies"
	goody = TRUE

/datum/supply_pack/goody/dumdum38
	name = ".38 DumDum Speedloader"
	desc = "Contains one speedloader of .38 DumDum ammunition, good for embedding in soft targets."
	cost = PAYCHECK_CREW * 2
	access_view = ACCESS_BRIG
	contains = list(/obj/item/ammo_box/c38/dumdum)

/datum/supply_pack/goody/match38
	name = ".38 Match Grade Speedloader"
	desc = "Contains one speedloader of match grade .38 ammunition, perfect for showing off trickshots."
	cost = PAYCHECK_CREW * 2
	access_view = ACCESS_BRIG
	contains = list(/obj/item/ammo_box/c38/match)

/datum/supply_pack/goody/rubber
	name = ".38 Rubber Speedloader"
	desc = "Contains one speedloader of bouncy rubber .38 ammunition, for when you want to bounce your shots off anything and everything."
	cost = PAYCHECK_CREW * 1.5
	access_view = ACCESS_BRIG
	contains = list(/obj/item/ammo_box/c38/match/bouncy)

/datum/supply_pack/goody/mars_single
	name = "Colt Detective Special Single-Pack"
	desc = "The HoS took your gun and your badge? No problem! Just pay the absurd taxation fee and you too can be reunited with the lethal power of a .38!"
	cost = PAYCHECK_CREW * 40 //they really mean a premium here
	access_view = ACCESS_DETECTIVE
	contains = list(/obj/item/gun/ballistic/revolver/c38/detective)

/datum/supply_pack/goody/stingbang
	name = "Stingbang Single-Pack"
	desc = "Contains one \"stingbang\" grenade, perfect for playing meanhearted pranks."
	cost = PAYCHECK_COMMAND * 2.5
	access_view = ACCESS_BRIG
	contains = list(/obj/item/grenade/stingbang)

/datum/supply_pack/goody/Survivalknives_single
	name = "Survival Knife Single-Pack"
	desc = "Contains one sharpened survival knive. Guaranteed to fit snugly inside any Nanotrasen-standard boot."
	cost = PAYCHECK_COMMAND * 1.75
	contains = list(/obj/item/knife/combat/survival)

/datum/supply_pack/goody/ballistic_single
	name = "Combat Shotgun Single-Pack"
	desc = "For when the enemy absolutely needs to be replaced with lead. Contains one Aussec-designed Combat Shotgun, and one Shotgun Bandolier."
	cost = PAYCHECK_COMMAND * 15
	access_view = ACCESS_ARMORY
	contains = list(/obj/item/gun/ballistic/shotgun/automatic/combat, /obj/item/storage/belt/bandolier)

/datum/supply_pack/goody/energy_single
	name = "Energy Gun Single-Pack"
	desc = "Contains one energy gun, capable of firing both nonlethal and lethal blasts of light."
	cost = PAYCHECK_COMMAND * 12
	access_view = ACCESS_ARMORY
	contains = list(/obj/item/gun/energy/e_gun)

/datum/supply_pack/goody/hell_single
	name = "Hellgun Kit Single-Pack"
	desc = "Contains one hellgun degradation kit, an old pattern of laser gun infamous for its ability to horribly disfigure targets with burns. Technically violates the Space Geneva Convention when used on humanoids."
	cost = PAYCHECK_CREW * 2
	access_view = ACCESS_ARMORY
	contains = list(/obj/item/weaponcrafting/gunkit/hellgun)

/datum/supply_pack/goody/thermal_single
	name = "Thermal Pistol Holster Single-Pack"
	desc = "Contains twinned thermal pistols in a holster, ready for use in the field."
	cost = PAYCHECK_COMMAND * 15
	access_view = ACCESS_ARMORY
	contains = list(/obj/item/storage/belt/holster/thermal)

/datum/supply_pack/goody/sologamermitts
	name = "Insulated Gloves Single-Pack"
	desc = "The backbone of modern society. Barely ever ordered for actual engineering."
	cost = PAYCHECK_CREW * 8
	contains = list(/obj/item/clothing/gloves/color/yellow)

/datum/supply_pack/goody/gripper_single
	name = "Gripper Gloves Single-Pack"
	desc = "A spare pair of gripper gloves. Perfect for when the security vendor is empty (or when you're not actually a security officer)."
	cost = PAYCHECK_COMMAND * 6
	contains = list(/obj/item/clothing/gloves/tackler)

/datum/supply_pack/goody/firstaidbruises_single
	name = "Bruise Treatment Kit Single-Pack"
	desc = "A single brute medkit, perfect for recovering from being crushed in an airlock. Did you know people get crushed in airlocks all the time? Interesting..."
	cost = PAYCHECK_CREW * 4
	contains = list(/obj/item/storage/medkit/brute)

/datum/supply_pack/goody/firstaidburns_single
	name = "Burn Treatment Kit Single-Pack"
	desc = "A single burn medkit. The advertisement displays a winking atmospheric technician giving a thumbs up, saying \"Mistakes happen!\""
	cost = PAYCHECK_CREW * 4
	contains = list(/obj/item/storage/medkit/fire)

/datum/supply_pack/goody/firstaid_single
	name = "First Aid Kit Single-Pack"
	desc = "A single medkit, fit for healing most types of bodily harm."
	cost = PAYCHECK_CREW * 3
	contains = list(/obj/item/storage/medkit/regular)

/datum/supply_pack/goody/firstaidoxygen_single
	name = "Oxygen Deprivation Kit Single-Pack"
	desc = "A single oxygen deprivation medkit, marketed heavily to those with crippling fears of asphyxiation."
	cost = PAYCHECK_CREW * 4
	contains = list(/obj/item/storage/medkit/o2)

/datum/supply_pack/goody/firstaidtoxins_single
	name = "Toxin Treatment Kit Single-Pack"
	desc = "A single first aid kit focused on healing damage dealt by heavy toxins."
	cost = PAYCHECK_CREW * 4
	contains = list(/obj/item/storage/medkit/toxin)

/datum/supply_pack/goody/toolbox // mostly just to water down coupon probability
	name = "Mechanical Toolbox"
	desc = "A fully stocked mechanical toolbox, for when you're too lazy to just print them out."
	cost = PAYCHECK_CREW * 3
	contains = list(/obj/item/storage/toolbox/mechanical)

/datum/supply_pack/goody/valentine
	name = "Valentine Card"
	desc = "Make an impression on that special someone! Comes with one valentine card and a free candy heart!"
	cost = PAYCHECK_CREW * 2
	contains = list(/obj/item/valentine, /obj/item/food/candyheart)

/datum/supply_pack/goody/beeplush
	name = "Bee Plushie"
	desc = "The most important thing you could possibly spend your hard-earned money on."
	cost = PAYCHECK_CREW * 4
	contains = list(/obj/item/toy/plush/beeplushie)

/datum/supply_pack/goody/dog_bone
	name = "Jumbo Dog Bone"
	desc = "The best dog bone money can have exported to a space station. A perfect gift for a dog."
	cost = PAYCHECK_COMMAND * 4
	contains = list(/obj/item/dog_bone)

/datum/supply_pack/goody/dyespray
	name = "Hair Dye Spray"
	desc = "A cool spray to dye your hair with awesome colors!"
	cost = PAYCHECK_CREW * 2
	contains = list(/obj/item/dyespray)

/datum/supply_pack/goody/beach_ball
	name = "Beach Ball"
	// uses desc from item
	cost = PAYCHECK_CREW
	contains = list(/obj/item/toy/beach_ball/branded)

/datum/supply_pack/goody/beach_ball/New()
	..()
	var/obj/item/toy/beach_ball/branded/beachball_type = /obj/item/toy/beach_ball/branded
	desc = initial(beachball_type.desc)

/datum/supply_pack/goody/medipen_twopak
	name = "Medipen Two-Pak"
	desc = "Contains one standard epinephrine medipen and one standard emergency medkit medipen. For when you want to prepare for the worst."
	cost = PAYCHECK_CREW * 2
	contains = list(/obj/item/reagent_containers/hypospray/medipen, /obj/item/reagent_containers/hypospray/medipen/ekit)

/datum/supply_pack/goody/mothic_rations
	name = "Surplus Mothic Ration Pack"
	desc = "A single surplus ration pack from the Mothic Fleet. Comes with 3 random sustenance bars, and a package of Activin chewing gum."
	cost = PAYCHECK_COMMAND * 2
	contains = list(/obj/item/storage/box/mothic_rations)

/datum/supply_pack/goody/ready_donk
	name = "Ready-Donk Single Meal"
	desc = "A complete meal package for the terminally lazy. Contains one Ready-Donk meal."
	cost = PAYCHECK_CREW * 2
	contains = list(/obj/item/food/ready_donk)

/datum/supply_pack/goody/pill_mutadone
	name = "Emergency Mutadone Pill"
	desc = "A single pill for curing genetic defects. Useful for when you can't procure one from medbay."
	cost = PAYCHECK_CREW * 2.5
	contains = list(/obj/item/reagent_containers/pill/mutadone)

/datum/supply_pack/goody/rapid_lighting_device
	name = "Rapid Lighting Device (RLD)"
	desc = "A device used to rapidly provide lighting sources to an area. Reload with iron, plasteel, glass or compressed matter cartridges."
	cost = PAYCHECK_CREW * 10
	contains = list(/obj/item/construction/rld)

/datum/supply_pack/goody/moth_encryption_key
	name = "Moffic radio encryption key"
	desc = "A hi-tech radio encryption key that allows the wearer to understand moffic when the radio is worn."
	cost = PAYCHECK_CREW * 12
	contains = list(/obj/item/encryptionkey/moth)

/datum/supply_pack/goody/lizard_encryption_key
	name = "Draconic radio encryption key"
	desc = "A hi-tech radio encryption key that allows the wearer to understand draconic when the radio is worn."
	cost = PAYCHECK_CREW * 12
	contains = list(/obj/item/encryptionkey/tiziran)

/datum/supply_pack/goody/plasmaman_encryption_key
	name = "Calcic radio encryption key"
	desc = "A hi-tech radio encryption key that allows the wearer to understand calcic when the radio is worn."
	cost = PAYCHECK_CREW * 12
	contains = list(/obj/item/encryptionkey/plasmaman)

/datum/supply_pack/goody/ethereal_encryption_key
	name = "Voltaic radio encryption key"
	desc = "A hi-tech radio encryption key that allows the wearer to understand voltaic when the radio is worn."
	cost = PAYCHECK_CREW * 12
	contains = list(/obj/item/encryptionkey/ethereal)

/datum/supply_pack/goody/felinid_encryption_key
	name = "Felinid radio encryption key"
	desc = "A hi-tech radio encryption key that allows the wearer to understand nekomimetic when the radio is worn."
	cost = PAYCHECK_CREW * 12
	contains = list(/obj/item/encryptionkey/felinid)

/datum/supply_pack/goody/fishing_toolbox
	name = "Fishing toolbox"
	desc = "Complete toolbox set for your fishing adventure. Advanced hooks and lines sold separetely."
	cost = PAYCHECK_CREW * 2
	contains = list(/obj/item/storage/toolbox/fishing)

/datum/supply_pack/goody/fishing_hook_set
	name = "Fishing Hooks Set"
	desc = "Set of various fishing hooks."
	cost = PAYCHECK_CREW
	contains = list(/obj/item/storage/box/fishing_hooks)

/datum/supply_pack/goody/fishing_line_set
	name = "Fishing Lines Set"
	desc = "Set of various fishing lines."
	cost = PAYCHECK_CREW
	contains = list(/obj/item/storage/box/fishing_lines)

/datum/supply_pack/goody/fishing_hook_rescue
	name = "Rescue Fishing Hook"
	desc = "For when your fellow miner has inevitably fallen into a chasm, and it's up to you to save them."
	cost = PAYCHECK_CREW * 12
	contains = list(/obj/item/fishing_hook/rescue)

/datum/supply_pack/goody/premium_bait
	name = "Deluxe fishing bait"
	desc = "When the standard variety is not good enough for you."
	cost = PAYCHECK_CREW
	contains = list(/obj/item/bait_can/worm/premium)

/datum/supply_pack/goody/coffee_mug
	name = "Coffee Mug"
	desc = "A bog standard coffee mug, for drinking coffee."
	cost = PAYCHECK_LOWER
	contains = list(/obj/item/reagent_containers/cup/glass/mug)

/datum/supply_pack/goody/nt_mug
	name = "Nanotrasen Coffee Mug"
	desc = "A blue mug bearing the logo of your corporate masters. Usually given out at inductions or events, we'll send one out special for a nominal fee."
	cost = PAYCHECK_LOWER
	contains = list(/obj/item/reagent_containers/cup/glass/mug/nanotrasen)

/datum/supply_pack/goody/coffee_cartridge
	name = "Coffee Cartridge"
	desc = "A basic cartridge for a coffeemaker. Makes 4 pots."
	cost = PAYCHECK_LOWER
	contains = list(/obj/item/coffee_cartridge)

/datum/supply_pack/goody/coffee_cartridge_fancy
	name = "Fancy Coffee Cartridge"
	desc = "A fancy cartridge for a coffeemaker. Makes 4 pots."
	cost = PAYCHECK_CREW
	contains = list(/obj/item/coffee_cartridge/fancy)

/datum/supply_pack/goody/coffeepot
	name = "Coffeepot"
	desc = "A standard-sized coffeepot, for use with a coffeemaker."
	cost = PAYCHECK_CREW
	contains = list(/obj/item/reagent_containers/cup/coffeepot)
