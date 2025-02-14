// Nuclear Operative Weapons and Ammunition

/datum/uplink_category/weapon_kits
	name = "Weapon Kits (Recommended)"
	weight = 30

/datum/uplink_item/weapon_kits
	category = /datum/uplink_category/weapon_kits
	surplus = 40
	purchasable_from = UPLINK_SERIOUS_OPS

// ~~ Ammunition Categories ~~

/datum/uplink_category/ammo_nuclear
	name = "Additional and Unique Ammunition"
	weight = 29

/datum/uplink_item/ammo_nuclear
	category = /datum/uplink_category/ammo_nuclear
	surplus = 40
	purchasable_from = UPLINK_SERIOUS_OPS

// Basic: Run of the mill ammunition for various firearms
/datum/uplink_item/ammo_nuclear/basic
	cost = 2

// Armor Penetrating: strong into armor, low damage
/datum/uplink_item/ammo_nuclear/ap
	cost = 4

// Hollow Point: weak into armor, high damage
/datum/uplink_item/ammo_nuclear/hp
	cost = 4

// Incendiary: sets target on fire, does less damage
/datum/uplink_item/ammo_nuclear/incendiary
	cost = 3

// Special: does something particularly extra than just any of the above
/datum/uplink_item/ammo_nuclear/special
	cost = 5

// ~~ Weapon Categories ~~

// Core Gear Box: This contains all the 'fundamental' equipment that most nuclear operatives probably should be buying. It isn't cheaper, but it is a quick and convenient method of acquiring all the gear necessary immediately.
// Only allows one purchase, and doesn't prevent the purchase of the contained items. Focused on newer players to help them understand what items they need to succeed, and to help older players quickly purchase the baseline gear they need.

/datum/uplink_item/weapon_kits/core
	name = "Core Equipment Box (Essential)"
	desc = "This box contains an airlock authentification override card, a MODsuit energy shield module, a C-4 explosive charge, a freedom implant and a stimpack injector. \
		The most important support items for most operatives to succeed in their mission, bundled together. It is highly recommend you buy this kit. \
		Note: This bundle is not at a discount. You can purchase all of these items separately. You do not NEED these items, but most operatives fail WITHOUT at \
		least SOME of these items. More experienced operatives can do without."
	item = /obj/item/storage/box/syndie_kit/core_gear
	//The cost for the core kit is always equivalent to the combined costs of the included items
	cost = (/datum/uplink_item/device_tools/doorjack::cost + /datum/uplink_item/implants/freedom::cost + /datum/uplink_item/explosives/c4::cost + /datum/uplink_item/device_tools/stimpack::cost +	/datum/uplink_item/suits/energy_shield::cost)
	limited_stock = 1
	cant_discount = TRUE
	purchasable_from = UPLINK_SERIOUS_OPS

//Low-cost firearms: Around 8 TC each. Meant for easy squad weapon purchases

/datum/uplink_item/weapon_kits/low_cost
	cost = 8
	surplus = 40
	purchasable_from = UPLINK_SERIOUS_OPS

// ~~ Bulldog Shotgun ~~

/datum/uplink_item/weapon_kits/low_cost/shotgun
	name = "Bulldog Shotgun Case (Moderate)"
	desc = "A fully-loaded 2-round burst fire drum-fed shotgun, complete with a secondary magazine you can hotswap. The gun has a handy label to explain how. \
		Compatible with all 12g rounds. Designed for close quarter anti-personnel engagements. Comes with three spare magazines."
	item = /obj/item/storage/toolbox/guncase/bulldog

/datum/uplink_item/ammo_nuclear/basic/buck
	name = "12g Buckshot Drum (Bulldog)"
	desc = "An additional 8-round buckshot magazine for use with the Bulldog shotgun. Front towards enemy."
	item = /obj/item/ammo_box/magazine/m12g
	purchasable_from = parent_type::purchasable_from | UPLINK_SPY

/datum/uplink_item/ammo_nuclear/basic/slug
	name = "12g Slug Drum (Bulldog)"
	desc = "An additional 8-round slug magazine for use with the Bulldog shotgun. \
		Now 8 times less likely to shoot your pals."
	item = /obj/item/ammo_box/magazine/m12g/slug
	purchasable_from = parent_type::purchasable_from | UPLINK_SPY

/datum/uplink_item/ammo_nuclear/incendiary/dragon
	name = "12g Dragon's Breath Drum (Bulldog)"
	desc = "An alternative 8-round dragon's breath magazine for use in the Bulldog shotgun. \
		'I'm a fire starter, twisted fire starter!'"
	item = /obj/item/ammo_box/magazine/m12g/dragon
	purchasable_from = parent_type::purchasable_from | UPLINK_SPY

/datum/uplink_item/ammo_nuclear/special/meteor
	name = "12g Meteorslug Shells (Bulldog)"
	desc = "An alternative 8-round meteorslug magazine for use in the Bulldog shotgun. \
		Great for blasting holes into the hull and knocking down enemies."
	item = /obj/item/ammo_box/magazine/m12g/meteor
	purchasable_from = parent_type::purchasable_from | UPLINK_SPY

// ~~ Ansem Pistol ~~

/datum/uplink_item/weapon_kits/low_cost/clandestine
	name = "Ansem Pistol Case (Easy/Spare)"
	desc = "A small, easily concealable handgun that uses 10mm auto rounds in 8-round magazines and is compatible \
			with suppressors. Comes with three spare magazines."
	item = /obj/item/storage/toolbox/guncase/clandestine

/datum/uplink_item/ammo_nuclear/basic/m10mm
	name = "10mm Handgun Magazine (Ansem)"
	desc = "An additional 8-round 10mm magazine, compatible with the Ansem pistol."
	item = /obj/item/ammo_box/magazine/m10mm
	purchasable_from = parent_type::purchasable_from | UPLINK_SPY

/datum/uplink_item/ammo_nuclear/ap/m10mm
	name = "10mm Armour Piercing Magazine (Ansem)"
	desc = "An additional 8-round 10mm magazine, compatible with the Ansem pistol. \
		These rounds are less effective at injuring the target but penetrate protective gear."
	item = /obj/item/ammo_box/magazine/m10mm/ap
	purchasable_from = parent_type::purchasable_from | UPLINK_SPY

/datum/uplink_item/ammo_nuclear/hp/m10mm
	name = "10mm Hollow Point Magazine (Ansem)"
	desc = "An additional 8-round 10mm magazine, compatible with the Ansem pistol. \
		These rounds are more damaging but ineffective against armour."
	item = /obj/item/ammo_box/magazine/m10mm/hp
	purchasable_from = parent_type::purchasable_from | UPLINK_SPY

/datum/uplink_item/ammo_nuclear/incendiary/m10mm
	name = "10mm Incendiary Magazine (Ansem)"
	desc = "An additional 8-round 10mm magazine, compatible with the Ansem pistol. \
		Loaded with incendiary rounds which inflict less damage, but ignite the target."
	item = /obj/item/ammo_box/magazine/m10mm/fire
	purchasable_from = parent_type::purchasable_from | UPLINK_SPY

//Medium-cost: 14 TC each. Meant for more expensive purchases with a goal in mind.

/datum/uplink_item/weapon_kits/medium_cost
	cost = 14
	surplus = 20
	purchasable_from = UPLINK_SERIOUS_OPS

// ~~ C-20r Submachine Gun ~~

/datum/uplink_item/weapon_kits/medium_cost/smg
	name = "C-20r Submachine Gun Case (Easy)"
	desc = "A fully-loaded Scarborough Arms bullpup submachine gun. The C-20r fires .45 rounds with a \
		24-round magazine and is compatible with suppressors. Comes with spare three magazines."
	item = /obj/item/storage/toolbox/guncase/c20r

/datum/uplink_item/ammo_nuclear/basic/smg
	name = ".45 SMG Magazine (C-20r)"
	desc = "An additional 24-round .45 magazine suitable for use with the C-20r submachine gun."
	item = /obj/item/ammo_box/magazine/smgm45

/datum/uplink_item/ammo_nuclear/ap/smg
	name = ".45 Armor Piercing SMG Magazine (C-20r)"
	desc = "An additional 24-round .45 magazine suitable for use with the C-20r submachine gun.\
		These rounds are less effective at injuring the target but penetrate protective gear."
	item = /obj/item/ammo_box/magazine/smgm45/ap

/datum/uplink_item/ammo_nuclear/hp/smg
	name = ".45 Hollow Point SMG Magazine (C-20r)"
	desc = "An additional 24-round .45 magazine suitable for use with the C-20r submachine gun.\
		These rounds are more damaging but ineffective against armour."
	item = /obj/item/ammo_box/magazine/smgm45/hp

/datum/uplink_item/ammo_nuclear/incendiary/smg
	name = ".45 Incendiary SMG Magazine (C-20r)"
	desc = "An additional 24-round .45 magazine suitable for use with the C-20r submachine gun.\
		Loaded with incendiary rounds which inflict little damage, but ignite the target."
	item = /obj/item/ammo_box/magazine/smgm45/incen
	cost = 4
	purchasable_from = UPLINK_SERIOUS_OPS

// ~~ Energy Sword and Shield & CQC ~~

/datum/uplink_item/weapon_kits/medium_cost/sword_and_board
	name = "Energy Shield and Sword Case (Very Hard)"
	desc = "A case containing an energy sword and energy shield. Paired together, it provides considerable defensive power without compromising lethal potency. \
		Perfect for the enterprising nuclear knight. Comes with a medieval helmet for your MODsuit!"
	item = /obj/item/storage/toolbox/guncase/sword_and_board

/datum/uplink_item/weapon_kits/medium_cost/cqc
	name = "CQC Equipment Case (Very Hard)"
	desc = "Contains a manual that instructs you in the ways of CQC, or Close Quarters Combat. Comes with a stealth implant, a pack of smokes and a snazzy bandana (use it with the hat stabilizers in your MODsuit)."
	item = /obj/item/storage/toolbox/guncase/cqc
	purchasable_from = UPLINK_ALL_SYNDIE_OPS
	surplus = 0

// ~~ Syndicate Revolver ~~
// Nuclear operatives get a special deal on their revolver purchase compared to traitors.

/datum/uplink_item/weapon_kits/medium_cost/revolvercase
	name = "Syndicate Revolver Case (Moderate)"
	desc = "Waffle Corp's modernized Syndicate revolver. Fires 7 brutal rounds of .357 Magnum. \
		A classic operative weapon, improved for the modern era. Comes with 3 additional speedloaders of .357."
	item = /obj/item/storage/toolbox/guncase/revolver

/datum/uplink_item/ammo_nuclear/basic/revolver
	name = ".357 Speed Loader (Revolver)"
	desc = "A speed loader that contains seven additional .357 Magnum rounds; usable with the Syndicate revolver. \
		For when you really need a lot of things dead. Unlike field agents, operatives get a premium price for their speedloaders!"
	item = /obj/item/ammo_box/a357
	purchasable_from = parent_type::purchasable_from | UPLINK_SPY

/datum/uplink_item/ammo_nuclear/special/revolver/phasic
	name = ".357 Phasic Speed Loader (Revolver)"
	desc = "A speed loader that contains seven additional .357 Magnum phasic rounds; usable with the Syndicate revolver. \
		These bullets are made from an experimental alloy, 'Ghost Lead', that allows it to pass through almost any non-organic material. \
		The name is a misnomer. It doesn't contain any lead whatsoever!"
	item = /obj/item/ammo_box/a357/phasic
	purchasable_from = parent_type::purchasable_from | UPLINK_SPY

/datum/uplink_item/ammo_nuclear/special/revolver/heartseeker
	name = ".357 Heartseeker Speed Loader (Revolver)"
	desc = "A speed loader that contains seven additional .357 Magnum heartseeker rounds; usable with the Syndicate revolver. \
		Able to veer straight into targets! Don't miss a shot with heartseeker! As seen in the hit NTFlik horror-space western film, Forget-Me-Not!	\
		Brought to you by Roseus Galactic!"
	item = /obj/item/ammo_box/a357/heartseeker
	cost = 3
	purchasable_from = parent_type::purchasable_from | UPLINK_SPY

// ~~ Grenade Launcher ~~
// 'If god had wanted you to live, he would not have created ME!'

/datum/uplink_item/weapon_kits/medium_cost/rawketlawnchair
	name = "Dardo-RE Rocket Propelled Grenade Launcher (Hard)"
	desc = "A reusable rocket propelled grenade launcher preloaded with a low-yield 84mm HE round. \
		Guaranteed to take your target out with a bang, or your money back! Comes with a bouquet of additional rockets!"
	item = /obj/item/storage/toolbox/guncase/rocketlauncher

/datum/uplink_item/ammo_nuclear/basic/rocket
	name = "84mm HE Rocket Bouquet (Rocket Launcher)"
	desc = "Three low-yield anti-personnel HE rocket wrapped in a bundle. Gonna take you out in style!"
	item = /obj/item/ammo_box/rocket

/datum/uplink_item/ammo_nuclear/ap/rocket
	name = "84mm HEAP Rocket (Rocket Launcher)"
	desc = "A high-yield HEAP rocket; extremely effective against literally everything and anything near that thing that doesn't exist anymore. \
			Strike fear into the hearts of your enemies."
	item = /obj/item/ammo_casing/rocket/heap

//High-cost: 18 TC each. Really should only be coming out during war for how powerful it is, or be the majority of your TC outside of war.

/datum/uplink_item/weapon_kits/high_cost
	cost = 18
	surplus = 10
	purchasable_from = UPLINK_SERIOUS_OPS

// ~~ L6 SAW Machine Gun ~~

/datum/uplink_item/weapon_kits/high_cost/machinegun
	name = "L6 Squad Automatic Weapon (Moderate)"
	desc = "A fully-loaded Aussec Armoury belt-fed machine gun. \
		This deadly weapon has a massive 50-round magazine of devastating 7mm ammunition."
	item = /obj/item/gun/ballistic/automatic/l6_saw

/datum/uplink_item/ammo_nuclear/basic/machinegun
	name = "7mm Box Magazine (L6 SAW)"
	desc = "A 50-round magazine of 7mm ammunition for use with the L6 SAW. \
		By the time you need to use this, you'll already be standing on a pile of corpses."
	item = /obj/item/ammo_box/magazine/m7mm

/datum/uplink_item/ammo_nuclear/ap/machinegun
	name = "7mm (Armor Penetrating) Box Magazine (L6 SAW)"
	desc = "A 50-round magazine of 7mm ammunition for use in the L6 SAW; equipped with special properties \
		to puncture even the most durable armor."
	item = /obj/item/ammo_box/magazine/m7mm/ap

/datum/uplink_item/ammo_nuclear/hp/machinegun
	name = "7mm (Hollow-Point) Box Magazine (L6 SAW)"
	desc = "A 50-round magazine of 7mm ammunition for use in the L6 SAW; equipped with hollow-point tips to help \
		with the unarmored masses of crew."
	item = /obj/item/ammo_box/magazine/m7mm/hollow

/datum/uplink_item/ammo_nuclear/incendiary/machinegun
	name = "7mm (Incendiary) Box Magazine (L6 SAW)"
	desc = "A 50-round magazine of 7mm ammunition for use in the L6 SAW; tipped with a special flammable \
		mixture that'll ignite anyone struck by the bullet. Some men just want to watch the world burn."
	item = /obj/item/ammo_box/magazine/m7mm/incen

/datum/uplink_item/ammo_nuclear/special/machinegun
	name = "7mm (Match) Box Magazine (L6 SAW)"
	desc = "A 50-round magazine of 7mm ammunition for use in the L6 SAW; you didn't know there was a demand for match grade \
		precision bullet hose ammo, but these rounds are finely tuned and perfect for ricocheting off walls all fancy-like."
	item = /obj/item/ammo_box/magazine/m7mm/match

// ~~ M-90gl Carbine ~~

/datum/uplink_item/weapon_kits/high_cost/carbine
	name = "M-90gl Carbine Case (Hard)"
	desc = "A fully-loaded, specialized three-round burst carbine that fires .223 ammunition from a 30 round magazine.\
		Comes with a 40mm underbarrel grenade launcher. Use secondary-fire to fire the grenade launcher. Also comes with two spare magazines \
		and a box of 40mm rubber slugs."
	item = /obj/item/storage/toolbox/guncase/m90gl

/datum/uplink_item/ammo_nuclear/basic/carbine
	name = ".223 Toploader Magazine (M-90gl)"
	desc = "An additional 30-round .223 magazine; suitable for use with the M-90gl carbine. \
		These bullets pack less punch than 7mm rounds, but they still offer more power than .45 ammo due to their innate armour penetration."
	item = /obj/item/ammo_box/magazine/m223

/datum/uplink_item/ammo_nuclear/special/carbine
	name = ".223 Toploader Phasic Magazine (M-90gl)"
	desc = "An additional 30-round .223 magazine; suitable for use with the M-90gl carbine. \
		These bullets are made from an experimental alloy, 'Ghost Lead', that allows it to pass through almost any non-organic material. \
		The name is a misnomer. It doesn't contain any lead whatsoever!"
	item = /obj/item/ammo_box/magazine/m223/phasic

/datum/uplink_item/ammo_nuclear/basic/carbine/a40mm
	name = "40mm Grenade Box (M-90gl)"
	desc = "A box of 40mm HE grenades for use with the M-90gl's under-barrel grenade launcher. \
		Your teammates will ask you to not shoot these down small hallways. \
		You'll do it anyway."
	item = /obj/item/ammo_box/a40mm

// ~~ Anti-Materiel Sniper Rifle ~~

/datum/uplink_item/weapon_kits/high_cost/sniper
	name = "Anti-Materiel Sniper Rifle Briefcase (Hard)"
	desc = "An outdated, but still extremely powerful anti-materiel sniper rifle. Fires .50 BMG cartridges from a 6 round magazine. \
		Can be fitted with a suppressor. If anyone asks how that even works, tell them it's Nanotrasen's fault. Comes with \
		3 spare magazines; 2 regular magazines and 1 disruptor magazine. Also comes with a suit and tie."
	item = /obj/item/storage/briefcase/sniper

/datum/uplink_item/ammo_nuclear/basic/sniper
	name = ".50 BMG Magazine (AMSR)"
	desc = "An additional standard 6-round magazine for use with .50 sniper rifles."
	item = /obj/item/ammo_box/magazine/sniper_rounds

/datum/uplink_item/ammo_nuclear/basic/sniper/surplussniper
	name = ".50 BMG Surplus Magazine Box (AMSR)"
	desc = "A box full of surplus .50 BMG magazines. Not as good as high quality magazines, \
		usually lacking the penetrative power and impact, but good enough to keep the gun firing. \
		Useful for arming a squad."
	cost = 7 //1 TC per magazine, special price for a special deal!
	item = /obj/item/storage/box/syndie_kit/sniper_surplus

/datum/uplink_item/ammo_nuclear/ap/sniper/penetrator
	name = ".50 BMG Penetrator Magazine (AMSR)"
	desc = "A 6-round magazine of penetrator ammo designed for use with .50 sniper rifles. \
		Can pierce walls and multiple enemies."
	item = /obj/item/ammo_box/magazine/sniper_rounds/penetrator

/datum/uplink_item/ammo_nuclear/incendiary/sniper
	name = ".50 BMG Incendiary Magazine (AMSR)"
	desc = "A 6-round magazine of incendiary ammo. \
		Sets your enemies ablaze, along with everyone else next to them!"
	item = /obj/item/ammo_box/magazine/sniper_rounds/incendiary

/datum/uplink_item/ammo_nuclear/basic/sniper/disruptor
	name = ".50 BMG Disruptor Magazine (AMSR)"
	desc = "A 6-round magazine of disruptor ammo designed for use with .50 sniper rifles. \
		Put your enemies and their alarm clock to sleep today!"
	item = /obj/item/ammo_box/magazine/sniper_rounds/disruptor

/datum/uplink_item/ammo_nuclear/special/sniper/marksman
	name = ".50 BMG Marksman Magazine (AMSR)"
	desc = "A 6-round magazine of marksman ammo designed for use with .50 sniper rifles. \
		Blast your enemies with instant shots! Just watch out for the rebound..."
	item = /obj/item/ammo_box/magazine/sniper_rounds/marksman

/datum/uplink_item/weapon_kits/high_cost/doublesword
	name = "Double-Bladed Energy Sword Case (Very Hard)"
	desc = "A case containing a double-bladed energy sword, anti-slip module, meth autoinjector, and a bar of soap. \
		Some say the most infamous nuclear operatives utilized this combination of equipment to slaughter hundreds \
		of Nanotrasen employees. However, some also say this is an embellishment from the Tiger Co-operative. \
		The soap did most of the work. Comes with a prisoner uniform so you fit the part."
	item = /obj/item/storage/toolbox/guncase/doublesword

//Meme weapons: Literally just weapons used as a joke, shouldn't be particularly expensive.

/datum/uplink_item/weapon_kits/surplus_smg
	name = "Surplus Smart-SMG (Flukie)"
	desc = "A failed experimental 'smart gun'. The use of .160 rocket propelled projectiles resulted in reduced stopping power \
		but increased overally accuracy so long as the shooter vaguely aimed towards their target. The relative increase in \
		operator effort from absurd recoil contradicted advertized advantages, resulting in poor market performance. However, \
		there sure are a lots still lying around in poorly secured warehouses. So we took them. And now you can have them. \
		If you REALLY want it. All I'm saying is: good luck."
	item = /obj/item/gun/ballistic/automatic/smartgun
	cost = 2
	purchasable_from = UPLINK_SERIOUS_OPS

/datum/uplink_item/ammo_nuclear/surplus_smg
	name = "Surplus Smart-SMG Magazine (Smartgun)"
	desc = "A large box magazine made for use in the Abielle smart-SMG."
	item = /obj/item/ammo_box/magazine/smartgun
	cost = 1
	purchasable_from = UPLINK_SERIOUS_OPS
	uplink_item_flags = SYNDIE_TRIPS_CONTRABAND

// Explosives and Grenades
// ~~ Grenades ~~

/datum/uplink_item/explosives/grenades
	cost = 15
	surplus = 35
	purchasable_from = UPLINK_ALL_SYNDIE_OPS

/datum/uplink_item/explosives/grenades/buzzkill
	name = "Buzzkill Grenade Box"
	desc = "A box with three grenades that release a swarm of angry bees upon activation. These bees indiscriminately attack friend or foe \
		with random toxins. Courtesy of the BLF and Tiger Cooperative."
	item = /obj/item/storage/box/syndie_kit/bee_grenades

/datum/uplink_item/explosives/grenades/virus_grenade
	name = "Fungal Tuberculosis Grenade Box"
	desc = "A primed bio-grenade packed into a compact box. Comes with five Bio Virus Antidote Kit (BVAK) \
		autoinjectors for rapid application on up to two targets each, a syringe, and a bottle containing \
		the BVAK solution."
	item = /obj/item/storage/box/syndie_kit/tuberculosisgrenade
	restricted = TRUE

/datum/uplink_item/explosives/grenades/viscerators
	name = "Viscerator Delivery Grenade Box"
	desc = "A box containing unique grenades that deploys a swarm of viscerators upon activation, which will chase down and shred \
		any non-operatives in the area."
	item = /obj/item/storage/box/syndie_kit/manhack_grenades

// ~~ Grenadier's Belt Kit ~~

/datum/uplink_item/weapon_kits/high_cost/grenadier
	name = "Grenadier's Belt and Grenade Launcher Kit (Hard)"
	desc = "A belt containing 26 lethally dangerous and destructive grenades, along with a grenade launcher to fire them. Comes with an extra multitool and screwdriver."
	item = /obj/item/storage/box/syndie_kit/demoman
	purchasable_from = UPLINK_SERIOUS_OPS

// ~~ Detonator: In case you lose the old one ~~

/datum/uplink_item/explosives/syndicate_detonator
	name = "Syndicate Detonator"
	desc = "The Syndicate detonator is a companion device to the Syndicate bomb. Simply press the included button \
		and an encrypted radio frequency will instruct all live Syndicate bombs to detonate. \
		Useful for when speed matters or you wish to synchronize multiple bomb blasts. Be sure to stand clear of \
		the blast radius before using the detonator."
	item = /obj/item/syndicatedetonator
	cost = 1
	purchasable_from = UPLINK_ALL_SYNDIE_OPS

// Support (Borgs and Reinforcements)

/datum/uplink_category/reinforcements
	name = "Reinforcements"
	weight = 28

/datum/uplink_item/reinforcements
	category = /datum/uplink_category/reinforcements
	surplus = 0
	cost = 35
	purchasable_from = UPLINK_SERIOUS_OPS
	restricted = TRUE
	refundable = TRUE

/datum/uplink_item/reinforcements/operative_reinforcement
	name = "Operative Reinforcements"
	desc = "Call in an additional team member from one of our factions. \
		They'll come equipped with a mere surplus SMG, so arming them is recommended."
	item = /obj/item/antag_spawner/nuke_ops

/datum/uplink_item/reinforcements/assault_borg
	name = "Syndicate Assault Cyborg"
	desc = "A cyborg designed and programmed for systematic extermination of non-Syndicate personnel. \
		Comes equipped with a self-resupplying LMG, a grenade launcher, energy sword, emag, pinpointer, flash and crowbar."
	item = /obj/item/antag_spawner/nuke_ops/borg_tele/assault

/datum/uplink_item/reinforcements/medical_borg
	name = "Syndicate Medical Cyborg"
	desc = "A combat medical cyborg. Has limited offensive potential, but makes more than up for it with its support capabilities. \
		It comes equipped with a nanite hypospray, a medical beamgun, combat defibrillator, full surgical kit including an energy saw, an emag, pinpointer and flash. \
		Thanks to its organ storage bag, it can perform surgery as well as any humanoid."
	item = /obj/item/antag_spawner/nuke_ops/borg_tele/medical

/datum/uplink_item/reinforcements/saboteur_borg
	name = "Syndicate Saboteur Cyborg"
	desc = "A streamlined engineering cyborg, equipped with covert modules. Also incapable of leaving the welder in the shuttle. \
		Aside from regular Engineering equipment, it comes with a special destination tagger that lets it traverse disposals networks. \
		Its chameleon projector lets it disguise itself as a Nanotrasen cyborg, on top it has thermal vision and a pinpointer."
	item = /obj/item/antag_spawner/nuke_ops/borg_tele/saboteur

/datum/uplink_item/reinforcements/overwatch_agent
	name = "Overwatch Intelligence Agent"
	desc = "An Overwatch Intelligence Agent is assigned to your operation. They can view your progress and help coordinate using your \
		operative team's body-cams. They can also pilot the shuttle remotely and view the station's camera net. \
		If you're a meathead who's just here to kill people and don't care about strategising or intel, you'll still have someone to bear witness to your murder-spree!"
	item = /obj/item/antag_spawner/nuke_ops/overwatch
	cost = 12
	purchasable_from = UPLINK_FIREBASE_OPS

// ~~ Disposable Sentry Gun ~~
// Technically not a spawn but it is a kind of reinforcement...I guess.

/datum/uplink_item/reinforcements/turretbox
	name = "Disposable Sentry Gun"
	desc = "A disposable sentry gun deployment system cleverly disguised as a toolbox, apply wrench for functionality."
	item = /obj/item/storage/toolbox/emergency/turret/nukie
	cost = 16
	restricted = FALSE
	refundable = FALSE

// Bundles

/datum/uplink_item/bundles_tc/cyber_implants
	name = "Cybernetic Implants Bundle"
	desc = "A box containing x-ray eyes, a CNS Rebooter and Reviver implant. Comes with an autosurgeon for each."
	item = /obj/item/storage/box/cyber_implants
	cost = 20 //worth 24 TC
	purchasable_from = UPLINK_SERIOUS_OPS

/datum/uplink_item/bundles_tc/medical
	name = "Medical bundle"
	desc = "The support specialist: Aid your fellow operatives with this medical bundle. Contains a tactical medkit, \
		a Donksoft LMG, a box of riot darts and a magboot MODsuit module to rescue your friends in no-gravity environments."
	item = /obj/item/storage/backpack/duffelbag/syndie/med/medicalbundle
	cost = 25 // normally 31
	purchasable_from = UPLINK_SERIOUS_OPS

/datum/uplink_item/bundles_tc/firestarter
	name = "Spetsnaz Pyro bundle"
	desc = "For systematic suppression of carbon lifeforms in close quarters: Contains an Elite MODsuit with a flamethrower attachment, \
		Stechkin APS machine pistol, two incendiary magazines, a minibomb and a stimulant syringe. \
		Order NOW and comrade Boris will throw in an extra tracksuit."
	item = /obj/item/storage/backpack/duffelbag/syndie/firestarter
	cost = 30
	purchasable_from = UPLINK_SERIOUS_OPS

/datum/uplink_item/bundles_tc/induction_kit
	name = "Syndicate Induction Kit"
	desc = "Met a fellow syndicate agent on the station? Kept some TC in reserve just in case? Or are you communicating with one via the Syndicate channel? \
		Get this kit and you'll be able to induct them into your operative team via a special implant. \
		Additionally, it contains an assortment of useful gear for new operatives, including a space suit, an Ansem pistol, two spare magazines, and more! \
		*NOT* for usage with Reinforcements, and does not brainwash the target!"
	item = /obj/item/storage/box/syndie_kit/induction_kit
	cost = 10
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/bundles_tc/cowboy
	name = "Syndicate Outlaw Kit"
	desc = "There've been high tales of an outlaw 'round these parts. A fella so ruthless and efficient no ranger could ever capture 'em. \
	Now you can be just like 'em! \
	This kit contains armor-lined cowboy equipment, a custom revolver and holster, and a horse with a complimentary apple to tame. \
	A lighter is also included, though you must supply your own smokes."
	item = /obj/item/storage/box/syndie_kit/cowboy
	cost = 18
	purchasable_from = UPLINK_SERIOUS_OPS

// Mech related gear

/datum/uplink_category/mech
	name = "Mech Reinforcement"
	weight = 27

/datum/uplink_item/mech
	category = /datum/uplink_category/mech
	surplus = 0
	purchasable_from = UPLINK_SERIOUS_OPS
	restricted = TRUE

// ~~ Mechs ~~

/datum/uplink_item/mech/gygax
	name = "Dark Gygax Exosuit"
	desc = "A lightweight exosuit, painted in a dark scheme. Its speed and equipment selection make it excellent \
		for hit-and-run style attacks. Features a scattershot shotgun, armor boosters against melee and ranged attacks, and ion thrusters."
	item = /obj/vehicle/sealed/mecha/gygax/dark/loaded
	cost = 60

/datum/uplink_item/mech/mauler
	name = "Mauler Exosuit"
	desc = "A massive and incredibly deadly military-grade exosuit. Features long-range targeting, thrust vectoring \
		and deployable smoke. Comes equipped with an LMG, scattershot carbine, missile rack, and an antiprojectile armor booster."
	item = /obj/vehicle/sealed/mecha/marauder/mauler/loaded
	cost = 100

// ~~ Mech Support ~~

/datum/uplink_item/mech/support_bag
	name = "Mech Support Kit Bag"
	desc = "A duffel bag containing ammo for four full reloads of the scattershot carbine which is equipped on standard Dark Gygax and Mauler exosuits. Also comes with some support equipment for maintaining the mech, including tools and an inducer."
	item = /obj/item/storage/backpack/duffelbag/syndie/ammo/mech
	cost = 4
	purchasable_from = UPLINK_SERIOUS_OPS

/datum/uplink_item/mech/support_bag/mauler
	name = "Mauler Ammo Bag"
	desc = "A duffel bag containing ammo for three full reloads of the LMG, scattershot carbine, and SRM-8 missile launcher that are equipped on a standard Mauler exosuit."
	item = /obj/item/storage/backpack/duffelbag/syndie/ammo/mauler
	cost = 6
	purchasable_from = UPLINK_SERIOUS_OPS

// Stealthy Tools

/datum/uplink_item/stealthy_tools/syndigaloshes/nuke
	item = /obj/item/clothing/shoes/chameleon/noslip
	cost = 4
	purchasable_from = UPLINK_SERIOUS_OPS

/datum/uplink_item/stealthy_weapons/romerol_kit
	name = "Romerol"
	desc = "A highly experimental bioterror agent which creates dormant nodules to be etched into the grey matter of the brain. \
		On death, these nodules take control of the dead body, causing limited revivification, \
		along with slurred speech, aggression, and the ability to infect others with this agent."
	item = /obj/item/storage/box/syndie_kit/romerol
	cost = 25
	purchasable_from = UPLINK_ALL_SYNDIE_OPS
	cant_discount = TRUE

// Modsuits

/datum/uplink_item/suits/modsuit/elite
	name = "Elite Syndicate MODsuit"
	desc = "An upgraded, elite version of the Syndicate MODsuit. It features fireproofing, and also \
		provides the user with superior armor and mobility compared to the standard Syndicate MODsuit."
	item = /obj/item/mod/control/pre_equipped/elite
	purchasable_from = (UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)

/datum/uplink_item/suits/energy_shield
	name = "MODsuit Energy Shield Module"
	desc = "An energy shield module for a MODsuit. The shields can stop a single impact \
		before needing to recharge. Used wisely, this module will keep you alive for a lot longer."
	item = /obj/item/mod/module/energy_shield
	cost = 8
	purchasable_from = (UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)

/datum/uplink_item/suits/emp_shield
	name = "MODsuit Advanced EMP Shield Module"
	desc = "An advanced EMP shield module for a MODsuit. It protects your entire body from electromagnetic pulses."
	item = /obj/item/mod/module/emp_shield/advanced
	cost = 5
	purchasable_from = (UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)

/datum/uplink_item/suits/injector
	name = "MODsuit Injector Module"
	desc = "An injector module for a MODsuit. It is an extendable piercing injector with 30u capacity."
	item = /obj/item/mod/module/injector
	cost = 2
	purchasable_from = (UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)

/datum/uplink_item/suits/holster
	name = "MODsuit Holster Module"
	desc = "A holster module for a MODsuit. It can stealthily store any not too heavy gun inside it."
	item = /obj/item/mod/module/holster
	cost = 2
	purchasable_from = (UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY)

/datum/uplink_item/device_tools/medgun_mod
	name = "Medbeam Gun Module"
	desc = "A wonder of Syndicate engineering, the Medbeam gun module, or Medi-Gun enables a medic to keep his fellow \
		operatives in the fight, even while under fire. Don't cross the streams!"
	item = /obj/item/mod/module/medbeam
	cost = 15
	purchasable_from = UPLINK_ALL_SYNDIE_OPS

/datum/uplink_item/suits/syndi_intellicard
	name = "Pre-Loaded Syndicate Intellicard"
	desc = "A syndicate intellicard that can be activated to download a captured Nanotrasen AI, modified with the standard syndicate lawset. You can slot it into your modsuit for a conversational partner! It can additionally control the MODsuit's modules at will, and move your body around even if you're in critical condition or dead. \
			However, due to failsafes activated during the extraction process, the AI is unable to interact with electronics from anywhere but direct proximity..."
	item = /obj/item/aicard/syndie/loaded
	cost = 12
	purchasable_from = UPLINK_ALL_SYNDIE_OPS
	refundable = TRUE

/datum/uplink_item/suits/synd_ai_upgrade
	name = "Syndicate AI Upgrade"
	desc = "...unless you buy the Syndicate Upgrade! This data chip allows the captured AI to increase its interaction range by two tiles per application. The Syndicate recommends three or four purchases at most, for a total of seven or infinite meters of range."
	item = /obj/item/computer_disk/syndie_ai_upgrade
	cost = 4
	purchasable_from = UPLINK_ALL_SYNDIE_OPS
	cant_discount = TRUE
	refundable = TRUE

// Devices

/datum/uplink_item/device_tools/assault_pod
	name = "Assault Pod Targeting Device"
	desc = "Use this to select the landing zone of your assault pod."
	item = /obj/item/assault_pod
	cost = 30
	surplus = 0
	purchasable_from = UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS
	restricted = TRUE
	purchasable_from = UPLINK_FIREBASE_OPS

/datum/uplink_item/device_tools/syndie_jaws_of_life
	name = "Syndicate Jaws of Life"
	desc = "Based on a Nanotrasen model, this powerful tool can be used as both a crowbar and a pair of wirecutters. \
		In its crowbar configuration, it can be used to force open airlocks. Very useful for entering the station or its departments."
	item = /obj/item/crowbar/power/syndicate
	cost = 4
	purchasable_from = UPLINK_SERIOUS_OPS | UPLINK_SPY

/datum/uplink_item/device_tools/medkit
	name = "Syndicate Combat Medic Kit"
	desc = "This first aid kit is a suspicious black and red. Included is a number of atropine medipens \
		for rapid stabilization and detonation prevention, sutures and regenerative mesh for wound treatment, and patches \
		for faster healing on the field. Also comes with basic medical tools and sterlizer."
	item = /obj/item/storage/medkit/tactical
	cost = 4
	purchasable_from = UPLINK_SERIOUS_OPS

/datum/uplink_item/device_tools/medkit/premium
	name = "Syndicate Combat Medical Suite"
	desc = "This first aid kit is a suspicious black and red. Included is an unloaded combat chemical injector \
		for suit-penetrative chem delivery, a medical science night vision HUD for quick identification of injured personnel and chemical supplies, \
		improved medical supplies, including Interdyne-approved pharmaceuticals, a hacked cybernetic surgery toolset arm implant, \
		and some helpful MODsuit modules for for field medical use and operative physiopharmaceutical augmentation."
	item = /obj/item/storage/medkit/tactical/premium
	cost = 15
	purchasable_from = UPLINK_SERIOUS_OPS

/datum/uplink_item/device_tools/potion
	name = "Syndicate Sentience Potion"
	item = /obj/item/slimepotion/slime/sentience/nuclear
	desc = "A potion recovered at great risk by undercover Syndicate operatives and then subsequently modified with Syndicate technology. \
		Using it will make any animal sentient, and bound to serve you, as well as implanting an internal radio for communication and an internal ID card for opening doors."
	cost = 4
	purchasable_from = UPLINK_SERIOUS_OPS | UPLINK_SPY
	restricted = TRUE

// Implants

/datum/uplink_item/implants/nuclear
	surplus = 0
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/implants/nuclear/deathrattle
	name = "Box of Deathrattle Implants"
	desc = "A collection of implants (and one reusable implanter) that should be injected into the team. When one of the team \
		dies, all other implant holders receive a mental message informing them of their teammates' name \
		and the location of their death. Unlike most implants, these are designed to be implanted \
		in any creature, biological or mechanical."
	item = /obj/item/storage/box/syndie_kit/imp_deathrattle
	cost = 4

/datum/uplink_item/implants/nuclear/microbomb
	name = "Microbomb Implant"
	desc = "An implant injected into the body, and later activated either manually or automatically upon death. \
		The more implants inside of you, the higher the explosive power. \
		This will permanently destroy your body, however."
	item = /obj/item/storage/box/syndie_kit/imp_microbomb
	cost = 2
	purchasable_from = UPLINK_SERIOUS_OPS | UPLINK_SPY

/datum/uplink_item/implants/nuclear/macrobomb
	name = "Macrobomb Implant"
	desc = "An implant injected into the body, and later activated either manually or automatically upon death. \
		Upon death, releases a massive explosion that will wipe out everything nearby."
	item = /obj/item/storage/box/syndie_kit/imp_macrobomb
	cost = 20
	restricted = TRUE

/datum/uplink_item/implants/nuclear/deniability
	name = "Tactical Deniability Implant"
	desc = "An implant injected into the brain, and later activated either manually or automatically upon entering critical condition. \
			Prevents collapsing from critical condition, but explodes after a while."
	item = /obj/item/storage/box/syndie_kit/imp_deniability
	cost = 6
	purchasable_from = UPLINK_SERIOUS_OPS | UPLINK_SPY

/datum/uplink_item/implants/nuclear/reviver
	name = "Reviver Implant"
	desc = "This implant will attempt to revive and heal you if you lose consciousness. Comes with an autosurgeon."
	item = /obj/item/autosurgeon/syndicate/reviver
	cost = 8

/datum/uplink_item/implants/nuclear/thermals
	name = "Thermal Eyes"
	desc = "These cybernetic eyes will give you thermal vision. Comes with a free autosurgeon."
	item = /obj/item/autosurgeon/syndicate/thermal_eyes
	cost = 8

/datum/uplink_item/implants/nuclear/implants/xray
	name = "X-ray Vision Implant"
	desc = "These cybernetic eyes will give you X-ray vision. Comes with an autosurgeon."
	item = /obj/item/autosurgeon/syndicate/xray_eyes
	cost = 8

/datum/uplink_item/implants/nuclear/antistun
	name = "CNS Rebooter Implant"
	desc = "This implant will help you get back up on your feet faster after being stunned. Comes with an autosurgeon."
	item = /obj/item/autosurgeon/syndicate/anti_stun
	cost = 8

// Badass (meme items)

/datum/uplink_item/badass/costumes
	surplus = 0
	purchasable_from = UPLINK_SERIOUS_OPS
	cost = 4
	cant_discount = TRUE

// Base Keys

/datum/uplink_category/base_keys
	name = "Base Keys"
	weight = 27

/datum/uplink_item/base_keys
	category = /datum/uplink_category/base_keys
	surplus = 0
	purchasable_from = UPLINK_NUKE_OPS
	cost = 15
	cant_discount = TRUE

/datum/uplink_item/base_keys/bomb_key
	name = "Syndicate Ordnance Laboratory Access Card"
	desc = "Do you fancy yourself an explosives expert? If so, then consider yourself lucky! With this special Authorization Key, \
		you can blow those corpo suits away with your very own home-made explosive devices. Made in your local firebase's \
		very own Ordnance Laboratory! *The Syndicate is not responsible for injuries or deaths sustained while utilizing the lab."
	item = /obj/item/keycard/syndicate_bomb

/datum/uplink_item/base_keys/bio_key
	name = "Syndicate Bio-Weapon Laboratory Access Card"
	desc = "In the right hands, even vile corpo technology can be turned into a vast arsenal of liberation and justice. From \
		micro-organism symbiosis to slime-core weaponization, this special Authorization Key can let you push past the boundaries \
		of bio-terrorism at breakneck speeds. As a bonus, these labs even come equipped with natural life support! *Plants not included."
	item = /obj/item/keycard/syndicate_bio
	purchasable_from = UPLINK_CLOWN_OPS | UPLINK_NUKE_OPS

/datum/uplink_item/base_keys/chem_key
	name = "Syndicate Chemical Plant Access Card"
	desc = "For some of our best Operatives, watching corpo space stations blow up with a flash of retribution just isn't enough. \
		Folks like those prefer a more personal touch to their artistry. For those interested, a special Authorization Key \
		can be instantly delivered to your location. Create groundbreaking chemical agents, cook up, sell the best of drugs, \
		and listen to the best classic music today!"
	item = /obj/item/keycard/syndicate_chem
	purchasable_from = UPLINK_CLOWN_OPS | UPLINK_NUKE_OPS

/datum/uplink_item/base_keys/fridge_key
	name = "Lopez's Access Card"
	desc = "Hungry? So is everyone in Firebase Balthazord. Lopez is a great cook, don't get me wrong, but he's stubborn when it \
		comes to the meal plans. Sometimes you just want to pig out. Listen, don't tell anyone, ok? I picked this out of his \
		pocket during this morning's briefing. He's been looking for it since. Take it, get into the fridge, and cook up whatever \
		you need before he gets back. And remember: DON'T TELL ANYONE! -M.T"
	item = /obj/item/keycard/syndicate_fridge
	cost = 5
	purchasable_from = UPLINK_CLOWN_OPS | UPLINK_NUKE_OPS

// Hats
// It is fundamental for the game's health for there to be a hat crate for nuclear operatives.

/datum/uplink_item/badass/hats
	name = "Hat Crate"
	desc = "Hat crate! Contains hats! HATS!!!"
	item = /obj/structure/closet/crate/large/hats
	cost = 5
	purchasable_from = UPLINK_ALL_SYNDIE_OPS
