/datum/uplink_category/ammo
	name = "Ammunition"
	weight = 11

/datum/uplink_item/ammo
	category = /datum/uplink_category/ammo
	surplus = 40

/datum/uplink_item/ammo/toydarts
	name = "Box of Riot Darts"
	desc = "A box of 40 Donksoft riot darts, for reloading any compatible foam dart magazine. Don't forget to share!"
	item = /obj/item/ammo_box/foambox/riot
	cost = 2
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = ~UPLINK_NUKE_OPS

/datum/uplink_item/ammo/pistol9mm
	name = "Pair of 9mm Handgun Magazines"
	desc = "Two additional 8-round 9mm magazine, compatible with the Makarov pistol."
	item = /obj/item/storage/box/syndie_kit/pistol9mmammo
	cost = 1
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	illegal_tech = FALSE

/datum/uplink_item/ammo/pistol9mmap
	name = "9mm Armour Piercing Magazine"
	desc = "An additional 8-round 9mm magazine, compatible with the Makarov pistol. \
			These rounds are less effective at injuring the target but penetrate protective gear."
	item = /obj/item/ammo_box/magazine/m9mm/ap
	cost = 2
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/ammo/pistol9mmhp
	name = "9mm Hollow Point Magazine"
	desc = "An additional 8-round 9mm magazine, compatible with the Makarov pistol. \
			These rounds are more damaging but ineffective against armour."
	item = /obj/item/ammo_box/magazine/m9mm/hp
	cost = 1
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/ammo/pistol9mmfire
	name = "9mm Incendiary Magazine"
	desc = "An additional 8-round 9mm magazine, compatible with the Makarov pistol. \
			Loaded with incendiary rounds which inflict little damage, but ignite the target."
	item = /obj/item/ammo_box/magazine/m9mm/fire
	cost = 1
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/ammo/pistol10mm
	name = "Pair of 10mm Handgun Magazines"
	desc = "Two additional 8-round 10mm magazines; compatible with the Viper."
	item = /obj/item/storage/box/syndie_kit/pistol10mmammo
	cost = 1
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/ammo/pistol10mm/random
	name = "Random 10mm Handgun Magazines"
	desc = "A box that contains three random 8-round 10mm magazines at a discount; compatible with the Viper."
	item = /obj/item/storage/box/syndie_kit/pistolammo/random
	cost = 2

/datum/uplink_item/ammo/pistol10mm/cs
	name = "10mm Caseless Magazine"
	desc = "An additional 8-round 10mm magazine; compatible with the Viper. \
			These rounds will leave no casings behind when fired."
	item = /obj/item/ammo_box/magazine/m10mm/cs

/datum/uplink_item/ammo/pistol10mm/ap
	name = "10mm Armor-Piercing Magazine"
	desc = "An additional 8-round 10mm magazine; compatible with the Viper. \
			These rounds are less effective at injuring the target but penetrate protective gear."
	item = /obj/item/ammo_box/magazine/m10mm/ap
	cost = 2

/datum/uplink_item/ammo/pistol10mm/hp
	name = "10mm Hollow-Point Magazine"
	desc = "An additional 8-round 10mm magazine; compatible with the Viper. \
			These rounds are more damaging but ineffective against armour."
	item = /obj/item/ammo_box/magazine/m10mm/hp

/datum/uplink_item/ammo/pistol10mm/sleepy
	name = "Pair of 10mm Soporific Magazines"
	desc = "Two additional 8-round 10mm magazines; compatible with the Viper. \
			These rounds will deliver small doses of tranqulizers on hit, knocking the target out after a few successive hits."
	item = /obj/item/storage/box/syndie_kit/pistolsleepyammo

/datum/uplink_item/ammo/pistol10mm/fire
	name = "10mm Incendiary Magazine"
	desc = "An additional 8-round 10mm magazine; compatible with the Viper. \
			Loaded with incendiary rounds which inflict reduced damage, but ignite the target."
	item = /obj/item/ammo_box/magazine/m10mm/fire

/datum/uplink_item/ammo/pistol10mm/emp
	name = "10mm EMP Magazine"
	desc = "An additional 8-round 10mm magazine; compatible with the Viper. \
			Loaded with bullets which release micro-electromagnetic pulses on hit, disrupting electronics on the target hit."
	item = /obj/item/ammo_box/magazine/m10mm/emp

/datum/uplink_item/ammo/handgun45
	name = "Pair of .45mm Handgun Magazines"
	desc = "Two additional 8-round .45mm magazines, compatible with the M1911 pistol and the Cobra."
	item = /obj/item/storage/box/syndie_kit/fourtyfivemmmagbox
	cost = 1
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/handgun45cs
	name = ".45mm Caseless Handgun Magazine"
	desc = "An additional 8-round Caseless .45mm magazine, compatible with the M1911 pistol and the Cobra."
	item = /obj/item/ammo_box/magazine/m45/cs
	cost = 1
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/handgun45sp
	name = "Pair of .45mm Soporific Handgun Magazines"
	desc = "A box containing two additional 8-round Soporific .45mm magazines, compatible with the M1911 pistol and the Cobra. \
			Shots aren't very lethal but greatly inhibit movement in the victim, multiple hits can render a target unconscious."
	item = /obj/item/storage/box/syndie_kit/fourtyfivemmmagboxsp
	cost = 1
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/handgun45ap
	name = ".45mm Armor Piercing Handgun Magazines"
	desc = "A single 8-round Armor Piercing .45mm magazines, compatible with the M1911 pistol and the Cobra. \
			Exceptional when used against armored targets."
	item = /obj/item/ammo_box/magazine/m45/ap
	cost = 2
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/handgun45hp
	name = ".45mm Hollow Point Handgun Magazines"
	desc = "A single 8-round Hollow Point .45mm magazines, compatible with the M1911 pistol and the Cobra. \
			Ineffective against armored targets, but very good again non-armored targets."
	item = /obj/item/ammo_box/magazine/m45/hp
	cost = 1
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/handgun45inc
	name = ".45mm Incendiary Handgun Magazines"
	desc = "A single 8-round Incendiary .45mm magazines, compatible with the M1911 pistol and the Cobra. \
			These bullets will lit your targets ablaze, though they don't leave behind a trail of fire."
	item = /obj/item/ammo_box/magazine/m45/inc
	cost = 1
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/handgun45emp
	name = ".45mm EMP Handgun Magazines"
	desc = "A single 8-round EMP .45mm magazines, compatible with the M1911 pistol and the Cobra. \
			Shots emit a tiny electro-magnetic pulse where they hit."
	item = /obj/item/ammo_box/magazine/m45/emp
	cost = 1
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/handgun45venom
	name = ".45mm Venom Handgun Magazines"
	desc = "A single 8-round Venom .45mm magazines, compatible with the M1911 pistol and the Cobra. \
			These bullets inject the victim with 4 units of Venom in addition to doing regular damage."
	item = /obj/item/ammo_box/magazine/m45/venom
	cost = 1
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/revolver
	name = ".357 Speed Loader"
	desc = "A speed loader that contains seven additional .357 Magnum rounds; usable with the .357 Revolver, Python, and Syndicate revolver. \
			For when you really need a lot of things dead."
	item = /obj/item/ammo_box/a357
	cost = 4
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS | UPLINK_SPY) //nukies get their own version
	illegal_tech = FALSE

/datum/uplink_item/ammo/revolver/random
	name = "Random .357 Speed Loader Box"
	desc = "A box with two random .357 speed loaders. Who knows what fun toys you might get?"
	item = /obj/item/storage/box/syndie_kit/revolverammo/random
	cost = 6

/datum/uplink_item/ammo/revolver/ironfeather
	name = ".357 Ironfeather Speed Loader Box"
	desc = "A speed loader that contains seven .357 Ironfeather; usable with the .357 Revolver, Python, and Syndicate revolver. \
			Ironfeather shells contain six pellets which are less damaging than buckshot but mildly better over range."
	item = /obj/item/storage/box/syndie_kit/revolvershotgunammo

/datum/uplink_item/ammo/revolver/nutcracker
	name = ".357 Nutcracker Speed Loader"
	desc = "A speed loader that contains seven .357 Nutcracker rounds; usable with the .357 Revolver, Python, and Syndicate revolver. \
			These rounds lose moderate stopping power in exchange for being able to rapidly destroy doors and windows."
	item = /obj/item/ammo_box/a357/nutcracker

/datum/uplink_item/ammo/revolver/metalshock
	name = ".357 Metalshock Speed Loader"
	desc = "A speed loader that contains seven .357 Metalshock rounds; usable with the .357 Revolver, Python, and Syndicate revolver. \
			These rounds convert some lethality into an electric payload, which can bounce between targets."
	item = /obj/item/ammo_box/a357/metalshock

/datum/uplink_item/ammo/revolver/heartpiercer
	name = ".357 Heartpiercer Speed Loader"
	desc = "A speed loader that contains seven .357 Heartpiercer rounds; usable with the .357 Revolver, Python, and Syndicate revolver. \
			These rounds are less damaging, but penetrate through armor and obstacles alike."
	item = /obj/item/ammo_box/a357/heartpiercer

/datum/uplink_item/ammo/revolver/wallstake
	name = ".357 Wallstake Speed Loader"
	desc = "A speed loader that contains seven .357 Wallstake rounds; usable with the .357 Revolver, Python, and Syndicate revolver. \
			These blunt rounds are slightly less damaging but can knock people against walls."
	item = /obj/item/ammo_box/a357/wallstake

/datum/uplink_item/ammo/deagle
	name = ".50 AE Handgun Magazine"
	desc = "An additional 7-round .50 AE magazine, compatible with the Desert Eagle."
	item = /obj/item/ammo_box/magazine/m50
	cost = 4
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/boltactionammo
	name = "Stripper Clips"
	desc = "Five stripper clips for those shoddy bolt action rifles we're selling you."
	item = /obj/item/storage/box/syndie_kit/stripperclips
	cost = 1
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/tommygun
	name = "Tommy Gun Drum Magazine"
	desc = "An additional 50-round .45 caliber drum magazine, compatible with the Tommy Gun."
	item = /obj/item/ammo_box/magazine/tommygunm45
	cost = 6
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/akm
	name = "Rifle Magazine (7.12x82mm)"
	desc = "An additional 30-round 7.12x82mm magazine, compatible with the AKM Assault Rifle."
	item = /obj/item/ammo_box/magazine/ak712x82
	cost = 3
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/akmap
	name = "Armor-Piercing Rifle Magazine (7.12x82mm)"
	desc = "An additional 30-round Armor-Piercing 7.12x82mm magazine, compatible with the AKM Assault Rifle."
	item = /obj/item/ammo_box/magazine/ak712x82/ap
	cost = 4
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/akmhp
	name = "Hollow-Point Rifle Magazine (7.12x82mm)"
	desc = "An additional 30-round Hollow-Point 7.12x82mm magazine, compatible with the AKM Assault Rifle."
	item = /obj/item/ammo_box/magazine/ak712x82/hp
	cost = 3
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/akmincendiary
	name = "Incendiary Rifle Magazine (7.12x82mm)"
	desc = "An additional 30-round Incendiary 7.12x82mm magazine, compatible with the AKM Assault Rifle."
	item = /obj/item/ammo_box/magazine/ak712x82/incendiary
	cost = 3
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/ammo9mmbox
	name = "Box of 9mm Rounds"
	desc = "An ammo box filled with 9mm rounds, used for restocking 9mm magazines. Contains 30 10mm bullets."
	item = /obj/item/ammo_box/c9mm
	cost = 2
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/ammo/ammo9mmboxmega
	name = "Box of 9mm Rounds"
	desc = "An ammo box filled with 9mm rounds, used for restocking 9mm magazines. Contains 60 10mm bullets."
	item = /obj/item/ammo_box/c9mm/sixty
	cost = 4
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/ammo10mmbox
	name = "Box of 10mm Rounds"
	desc = "An ammo box filled with 10mm rounds, used for restocking 10mm magazines. Contains 20 10mm bullets."
	item = /obj/item/ammo_box/c10mm
	cost = 1
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/ammo/ammo10mmboxcaseless
	name = "Box of 10mm Caseless Rounds"
	desc = "An ammo box filled with 10mm Caseless rounds, used for restocking 10mm magazines. Contains 20 10mm Caseless bullets."
	item = /obj/item/ammo_box/c10mm/cs
	cost = 2
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/ammo10mmboxtranq
	name = "Box of 10mm Soporific Rounds"
	desc = "An ammo box filled with 10mm Soporific rounds, used for restocking 10mm magazines. Contains 20 10mm Soporific bullets."
	item = /obj/item/ammo_box/c10mm/sp
	cost = 2
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/ammo10mmboxap
	name = "Box of 10mm AP Rounds"
	desc = "An ammo box filled with 10mm AP rounds, used for restocking 10mm magazines. Contains 20 10mm AP bullets."
	item = /obj/item/ammo_box/c10mm/ap
	cost = 3
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/ammo10mmboxhp
	name = "Box of 10mm HP Rounds"
	desc = "An ammo box filled with 10mm HP rounds, used for restocking 10mm magazines. Contains 20 10mm HP bullets."
	item = /obj/item/ammo_box/c10mm/hp
	cost = 2
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/ammo10mmboxincendiary
	name = "Box of 10mm Incendiary Rounds"
	desc = "An ammo box filled with 10mm Incendiary rounds, used for restocking 10mm magazines. Contains 20 10mm Incendiary bullets."
	item = /obj/item/ammo_box/c10mm/inc
	cost = 2
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/ammo10mmboxemp
	name = "Box of 10mm EMP Rounds"
	desc = "An ammo box filled with 10mm EMP rounds, used for restocking 10mm magazines. Contains 20 10mm EMP bullets."
	item = /obj/item/ammo_box/c10mm/emp
	cost = 2
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/ammo10mmboxmega
	name = "Mega Box of 10mm Rounds"
	desc = "An ammo box filled with 10mm rounds, used for restocking 10mm magazines. Contains 50 10mm bullets."
	item = /obj/item/ammo_box/c10mm/fifty
	cost = 3
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/ammo357box
	name = "Box of .357 Rounds"
	desc = "An ammo box filled with .357 rounds, used for restocking .357 speedloaders. Contains 20 .357 rounds."
	item = /obj/item/ammo_box/a357/no_direct
	cost = 8
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/ammo/ammo357boxironfeather
	name = "Box of Ironfeather .357 Rounds"
	desc = "An ammo box filled with .357 Ironfeather rounds, used for restocking .357 speedloaders. Contains 20 .357 Ironfeather rounds. \
			These rounds contain six pellets which are less damaging than buckshot but mildly better over range."
	item = /obj/item/ammo_box/a357/no_direct/ironfeather
	cost = 8
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/ammo357boxnutcracker
	name = "Box of Nutcracker .357 Rounds"
	desc = "An ammo box filled with .357 Nutcracker rounds, used for restocking .357 speedloaders. Contains 20 .357 Nutcracker rounds."
	item = /obj/item/ammo_box/a357/no_direct/nutcracker
	cost = 8
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/ammo357boxmetalshock
	name = "Box of Metalshock .357 Rounds"
	desc = "An ammo box filled with .357 Metalshock rounds, used for restocking .357 speedloaders. Contains 20 .357 Metalshock rounds."
	item = /obj/item/ammo_box/a357/no_direct/metalshock
	cost = 8
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/ammo357boxheartpiercer
	name = "Box of Heartpiercer .357 Rounds"
	desc = "An ammo box filled with .357 Heartpiercer rounds, used for restocking .357 speedloaders. Contains 20 .357 Heartpiercer rounds."
	item = /obj/item/ammo_box/a357/no_direct/heartpiercer
	cost = 8
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/ammo357boxwallstake
	name = "Box of Wallstake .357 Rounds"
	desc = "An ammo box filled with .357 Wallstake rounds, used for restocking .357 speedloaders. Contains 20 .357 Wallstake rounds."
	item = /obj/item/ammo_box/a357/no_direct/wallstake
	cost = 8
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/ammo45box
	name = "Box of .45 Rounds"
	desc = "An ammo box filled with .45 rounds, used for restocking .45 magazines. Contains 30 .45 bullets."
	item = /obj/item/ammo_box/c45/thirty
	cost = 2
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/ammo/ammo45boxcs
	name = "Box of .45 Caseless Rounds"
	desc = "An ammo box filled with .45 Caseless rounds, used for restocking .45 magazines. Contains 30 .45 Caseless bullets."
	item = /obj/item/ammo_box/c45/thirty/cs
	cost = 2
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/ammo45boxsp
	name = "Box of .45 Soporific Rounds"
	desc = "An ammo box filled with .45 Soporific rounds, used for restocking .45 magazines. Contains 30 .45 Soporific bullets."
	item = /obj/item/ammo_box/c45/thirty/sp
	cost = 2
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/ammo45boxap
	name = "Box of .45 Armor Piercing Rounds"
	desc = "An ammo box filled with .45 Armor Piercing rounds, used for restocking .45 magazines. Contains 30 .45 Armor Piercing bullets."
	item = /obj/item/ammo_box/c45/thirty/ap
	cost = 3
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/ammo45boxhp
	name = "Box of .45 Hollow Point Rounds"
	desc = "An ammo box filled with .45 Hollow Point rounds, used for restocking .45 magazines. Contains 30 .45 Hollow Point bullets."
	item = /obj/item/ammo_box/c45/thirty/hp
	cost = 2
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/ammo45boxinc
	name = "Box of .45 Incendiary Rounds"
	desc = "An ammo box filled with .45 Incendiary rounds, used for restocking .45 magazines. Contains 30 .45 Incendiary bullets."
	item = /obj/item/ammo_box/c45/thirty/inc
	cost = 2
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/ammo45boxemp
	name = "Box of .45 EMP Rounds"
	desc = "An ammo box filled with .45 EMP rounds, used for restocking .45 magazines. Contains 30 .45 EMP bullets."
	item = /obj/item/ammo_box/c45/thirty/emp
	cost = 2
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/ammo45boxvenom
	name = "Box of .45 Venom Rounds"
	desc = "An ammo box filled with .45 Venom rounds, used for restocking .45 magazines. Contains 30 .45 Venom bullets."
	item = /obj/item/ammo_box/c45/thirty/venom
	cost = 2
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/ammo45boxmega
	name = "Mega Box of .45 Rounds"
	desc = "An ammo box filled with .45 rounds, used for restocking .45 magazines. Contains 50 .45 bullets."
	item = /obj/item/ammo_box/c45/fifty
	cost = 3
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/ammo50box
	name = "Box of .50 AE Rounds"
	desc = "An ammo box filled with .50 AE rounds, used for restocking .50 AE magazines. Contains 20 .50 AE bullets."
	item = /obj/item/ammo_box/c50
	cost = 6
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/ammo/ammo50boxmega
	name = "Mega Box of .50 AE Rounds"
	desc = "An ammo box filled with .50 AE rounds, used for restocking .50 AE magazines. Contains 50 .50 AE bullets."
	item = /obj/item/ammo_box/c50/fifty
	cost = 8
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/ammo712box
	name = "Box of 7.12x82mm Rounds"
	desc = "An ammo box filled with 7.12x82mm rounds, used for restocking 7.12x82mm magazines. Contains 50 7.12x82mm bullets."
	item = /obj/item/ammo_box/n712x82
	cost = 5
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/ammo712boxmega
	name = "Mega Box of 7.12x82mm Rounds"
	desc = "An ammo box filled with 7.12x82mm rounds, used for restocking 7.12x82mm magazines. Contains 100 7.12x82mm bullets."
	item = /obj/item/ammo_box/n712x82/hundred
	cost = 9
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/mysteryshells
	name = "Mystery Shells Box"
	desc = "A box containing 14 shells for a shotgun of unknown variety, are you feeling lucky? Shells of all kinds are included, including the more expensive ones."
	item = /obj/item/storage/box/mysteryshells/syndi
	cost = 2
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/lethalshells
	name = "Lethal Shells Box"
	desc = "A box containing 14 lethal shells for a shotgun."
	item = /obj/item/storage/box/lethalshot/syndi
	cost = 2
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/dartshells
	name = "Dart Shells Box"
	desc = "A box containing 14 dart shells for a shotgun, you'll have to inject the shells with your own chemicals though."
	item = /obj/item/storage/box/dartshells/syndi
	cost = 1
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/incendiaryshells
	name = "Incendiary Shells Box"
	desc = "A box containing 14 incendiary shells for a shotgun."
	item = /obj/item/storage/box/incendiaryshells/syndi
	cost = 1
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/dragonshells
	name = "Dragon's Breath Shells Box"
	desc = "A box containing 14 dragon's breath shells for a shotgun. Each one fires a spread of incendiary pellets that light anyone caught in a blaze of glory."
	item = /obj/item/storage/box/dragonshells/syndi
	cost = 3
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE
	cant_discount = TRUE

/datum/uplink_item/ammo/syndieshotshells
	name = "Syndicate Buckshot Shells Box"
	desc = "A box containing 14 syndicate-made shells for a shotgun, these particular shells are more effective than nanotrasen-made shells."
	item = /obj/item/storage/box/syndieshotshells/syndi
	cost = 3
	purchasable_from = UPLINK_NUKE_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/syndieslugshells
	name = "Syndicate Slugs Box"
	desc = "A box containing 14 syndicate-made slugs for a shotgun, these particular slugs are more effective than nanotrasen-made shells."
	item = /obj/item/storage/box/syndieslugshells/syndi
	cost = 3
	purchasable_from = UPLINK_NUKE_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/tasershells
	name = "Taser Slugs Box"
	desc = "A box containing 14 taser slugs for a shotgun, effective in incapacitating single targets quickly."
	item = /obj/item/storage/box/tasershells/syndi
	cost = 3
	illegal_tech = FALSE
	cant_discount = TRUE
	progression_minimum = 20 MINUTES

/datum/uplink_item/ammo/meteorshells
	name = "Meteor Slugs Box"
	desc = "A box containing 14 meteor slugs for a shotgun, they deal less damage than normal slugs but the shots always paralyze the target through sheer blunt force."
	item = /obj/item/storage/box/meteorshells/syndi
	cost = 3
	illegal_tech = FALSE
	cant_discount = TRUE
	progression_minimum = 40 MINUTES

/datum/uplink_item/ammo/pulseshells
	name = "Pulse Shells Box"
	desc = "A box containing 14 pulse shells for a shotgun, extremely effective against all targets and often leave behind fire to ignite foes."
	item = /obj/item/storage/box/pulseshells/syndi
	cost = 6
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE
	cant_discount = TRUE
	progression_minimum = 50 MINUTES

/datum/uplink_item/ammo/frag12shells
	name = "Frag 12 Shells Box"
	desc = "A box containing 14 frag-12 shells for a shotgun, each one causes a small explosion."
	item = /obj/item/storage/box/frag12shells/syndi
	cost = 5
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE
	cant_discount = TRUE
	progression_minimum = 30 MINUTES

/datum/uplink_item/ammo/flechetteshells
	name = "Flechette Shells Box"
	desc = "A box containing 14 flechette shells for a shotgun, they're slightly better than normal buckshot with a tighter spread and armor penetration."
	item = /obj/item/storage/box/flechetteshells/syndi
	cost = 3
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE
	cant_discount = TRUE

/datum/uplink_item/ammo/rubbershotshells
	name = "Rubbershot Shells Box"
	desc = "A box containing 14 rubbershot shells for a shotgun, they're useful in subdueing multiple targets in a less-lethal manner."
	item = /obj/item/storage/box/rubbershotshells/syndi
	cost = 2
	illegal_tech = FALSE
	cant_discount = TRUE
	progression_minimum = 5 MINUTES

/datum/uplink_item/ammo/ionshells
	name = "ION Shells Box"
	desc = "A box containing 14 ion shells for a shotgun, each shot induces a tiny emp, perfect against silicon-based lifeforms."
	item = /obj/item/storage/box/ionshells/syndi
	cost = 2
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE
	cant_discount = TRUE
	progression_minimum = 5 MINUTES

/datum/uplink_item/ammo/lasershells
	name = "Laser Buckshot Shells Box"
	desc = "A box containing 14 laser buckshot shells for a shotgun, fires lethal lasers instead of pellets."
	item = /obj/item/storage/box/lasershells/syndi
	cost = 2
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE
	cant_discount = TRUE

/datum/uplink_item/ammo/uraniumshells
	name = "Uranium Shells Box"
	desc = "A box containing 14 uranium shells for a shotgun, they all have high damage and armor penetration. Pellets penetrate targets and continue flying."
	item = /obj/item/storage/box/uraniumshells/syndi
	cost = 3
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE
	cant_discount = TRUE
	progression_minimum = 20 MINUTES

/datum/uplink_item/ammo/cryoshotshells
	name = "Cryoshot Shells Box"
	desc = "A box containing 14 cryoshot shells for a shotgun, they deal little damage but drastically reduce the target's body temperature."
	item = /obj/item/storage/box/cryoshotshells/syndi
	cost = 3
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE
	cant_discount = TRUE

/datum/uplink_item/ammo/bioterrorshells
	name = "Bioterror Shells Box"
	desc = "A box containing 14 bioterror dart shells for a shotgun, we've filled them with 6 units of five different toxins for destroying pesky personnel."
	item = /obj/item/storage/box/bioterrorshells/syndi
	cost = 3
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE
	cant_discount = TRUE
/** Only fits into breaching shotguns, may want to make a new version of the ammo.
/datum/uplink_item/ammo/breachershells
	name = "Breacher Shells Box"
	desc = "A box containing 14 breacher shells for a shotgun, exceptional at destroying airlocks and windows. Not effective against actual enemies."
	item = /obj/item/storage/box/breachershells/syndi
	cost = 2
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE
**/
/datum/uplink_item/ammo/thundershotshells
	name = "Thundershot Shells Box"
	desc = "A box containing 14 thundershot shells for a shotgun, fires 3 pellets but does little damage. Pellets will shock everyone nearby -- including you."
	item = /obj/item/storage/box/thundershotshells/syndi
	cost = 3
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE
	cant_discount = TRUE

/datum/uplink_item/ammo/hardlightshells
	name = "Hardlight Shells Box"
	desc = "A box containing 14 hardlight shells for a shotgun, they only tire your foes, draining their stamina. Otherwise they're basically energy buckshot."
	item = /obj/item/storage/box/hardlightshells/syndi
	cost = 1
	illegal_tech = FALSE
	cant_discount = TRUE

/datum/uplink_item/ammo/ripshells
	name = "RIP Shells Box"
	desc = "A box containing 14 rip shells for a shotgun, fires two slugs at once, dealing twice the damage. They're super-ineffective against any armor, aim for the legs."
	item = /obj/item/storage/box/ripshells/syndi
	cost = 3
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE
	cant_discount = TRUE

/datum/uplink_item/ammo/anarchyshells
	name = "Anarchy Shells Box"
	desc = "A box containing 14 anarchy shells for a shotgun, fires 3 pellets that bounce off walls, they deal little damage outright though."
	item = /obj/item/storage/box/anarchyshells/syndi
	cost = 1
	illegal_tech = FALSE
	cant_discount = TRUE

/datum/uplink_item/ammo/clownshellsclownop
	name = "Fake Shotgun Shells Box"
	desc = "A box containing 14 fake shells for a shotgun, for when you love wasting your telecrystals on harmless pranks."
	item = /obj/item/storage/box/clownshells/syndi
	cost = 0
	limited_stock = 5
	purchasable_from = UPLINK_CLOWN_OPS
	illegal_tech = FALSE
	cant_discount = TRUE

/datum/uplink_item/ammo/clownshells
	name = "Fake Shotgun Shells Box"
	desc = "A box containing 14 fake shells for a shotgun, for when you love wasting security's time. Have this one on us, sponsored by the folks on Clown-p55."
	item = /obj/item/storage/box/clownshells/syndi
	cost = 0
	limited_stock = 1
	purchasable_from = UPLINK_TRAITORS
	illegal_tech = FALSE
	cant_discount = TRUE

/datum/uplink_item/ammo/magspears
	name = "Magspear Quiver"
	desc = "A quiver containing 20 magspears for use with the kinetic speargun."
	item = /obj/item/storage/magspear_quiver
	cost = 4
	surplus = 0
	illegal_tech = TRUE
	cant_discount = TRUE

/datum/uplink_item/ammo/bioterrorammo
	name = "Bioterror Chemical Package"
	desc = "An box containing most of the chemicals we'd normally provide in a chemical kit, but we've added condensed capsaicin and have elected to increased the amounts of each chemical to 100 units."
	item = /obj/item/storage/box/syndie_kit/bioterrorammo
	cost = 10
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/ammo/bioterrorammodeluxe
	name = "Deluxe Bioterror Chemical Package"
	desc = "An box containing most of the chemicals we'd normally provide in a chemical kit, but we've added nearly every toxin known to us and have elected to increased the amounts of each chemical to 100 units. Additionally, we added a few non-toxins to spice things up."
	item = /obj/item/storage/box/syndie_kit/bioterrorammodeluxe
	cost = 20
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
