/* Stimpak */
/datum/uplink_item/stealthy_tools/stimpack
	name = "Syndicate Nano-Booster"
	desc = "Also known as the 'Call of Duty' this powerful cluster of medical nanites effectively heals all damage \
	over time. If you are injured simply get to cover and wait a while and your wounds will vanish before your eyes. \
	It's duration is roughly five minutes."
	item = /obj/item/reagent_containers/syringe/nanoboost
	cost = 5
	surplus = 90

/* Implants */
/datum/uplink_item/implants/adrenal
	name = "Combat Stimulant Implant"
	desc = "An implant injected into the body, and later activated at the user's will. It will inject a chemical \
			cocktail which has a very potent healing effect."
	item = /obj/item/storage/box/syndie_kit/imp_comstimms
	cost = 8
	player_minimum = 0 //Healing like this, while strong as heck, isn't going to help you murderbone like antistuns can.

/datum/uplink_item/implants/mindslave
	name = "Mindslave Implant"
	desc = "An implant injected into another body, forcing the victim to obey any command by the user for around 15 to 20 mintues."
	exclude_modes = list(/datum/game_mode/nuclear)
	item = /obj/item/storage/box/syndie_kit/imp_mindslave
	cost = 8
	surplus = 20

/datum/uplink_item/implants/greatermindslave
	name = "Greater Mindslave Implant"
	desc = "An implant injected into another body, forcing the victim to obey any command by the user, it does not expire like a regular mindslave implant."
	item = /obj/item/storage/box/syndie_kit/imp_gmindslave
	cost = 16

/* Botany */
/datum/uplink_item/role_restricted/lawnmower
	name = "Gas powered lawn mower"
	desc = "A lawn mower is a machine utilizing one or more revolving blades to cut a grass surface to an even height, or bodies if that's your thing"
	restricted_roles = list("Botanist")
	cost = 14
	item = /obj/vehicle/lawnmower/emagged
	
/datum/uplink_item/role_restricted/echainsaw
	name = "Energy Chainsaw"
	desc = "An incredibly deadly modified chainsaw with plasma-based energy blades instead of metal and a slick black-and-red finish. While it rips apart matter with extreme efficiency, it is heavy, large, and monstrously loud."
	restricted_roles = list("Botanist", "Chef", "Bartender")
	item = /obj/item/twohanded/required/chainsaw/energy
	cost = 16

/* Glock */
/datum/uplink_item/dangerous/g17
	name = "Glock 17 Handgun"
	desc = "A simple yet popular handgun chambered in 9mm. Made out of strong but lightweight polymer. The standard magazine can hold up to 14 9mm cartridges. Compatible with a universal suppressor."
	item = /obj/item/gun/ballistic/automatic/pistol/g17
	cost = 10
	surplus = 15

/datum/uplink_item/ammo/g17
	name = "9mm Handgun Magazine"
	desc = "An additional 14-round 9mm magazine; compatible with the Glock 17 pistol."
	item = /obj/item/ammo_box/magazine/g17
	cost = 1

/datum/uplink_item/dangerous/revolver
	cost = 10
	surplus = 45

/* Sports */
/datum/uplink_item/badass/sports
	name = "Sports bundle"
	desc = "A hand-selected box of paraphernalia from one of the best sports. \
			Currently available are hockey, wrestling, football, and bowling kits."
	item = /obj/item/paper
	cost = 20
	exclude_modes = list(/datum/game_mode/nuclear)
	cant_discount = TRUE

/* Holo Parasites */
/datum/uplink_item/dangerous/guardian
	name = "Holoparasites"
	desc = "Though capable of near sorcerous feats via use of hardlight holograms and nanomachines, they require an organic host as a home base and source of fuel."
	item = /obj/item/storage/box/syndie_kit/guardian
	cost = 20
	exclude_modes = list(/datum/game_mode/nuclear)

/datum/uplink_item/badass/sports/spawn_item(turf/loc, obj/item/device/uplink/U)
	var/list/possible_items = list(
								"/obj/item/storage/box/syndie_kit/wrestling",
								"/obj/item/storage/box/syndie_kit/bowling",
								"/obj/item/storage/box/syndie_kit/hockey",
								"/obj/item/storage/box/syndie_kit/football"
								)
	if(possible_items.len)
		var/obj/item/I = pick(possible_items)
		return new I(loc)

/datum/uplink_item/nukeoffer/blastco
	name = "Unlock the BlastCo(tm) Armory"
	desc = "Enough gear to fully equip a team with explosive based weaponry."
	item = /obj/item/paper
	cost = 200

/datum/uplink_item/nukeoffer/blastco/spawn_item(turf/loc, obj/item/device/uplink/U)
	LAZYINITLIST(blastco_doors)
	if(LAZYLEN(blastco_doors))
		for(var/V in blastco_doors)
			var/obj/machinery/door/poddoor/shutters/blastco/X = V
			X.open()
		loc.visible_message("<span class='notice'>The Armory has been unlocked successfully!</span>")
	else
		loc.visible_message("<span class='warning'>The purchase was unsuccessful, and spent telecrystals have been refunded.</span>")
		U.telecrystals += cost //So the admins don't have to refund you
	return

/datum/uplink_item/role_restricted/firesuit_syndie
	name = "Syndicate Firesuit"
	desc = "A less heavy, armored version of the common firesuit developed by a now-defunct, \
	Syndicate-affiliated collective with a penchant for arson. It offers complete fireproofing, \
	spaceproofing, the added bonus of not slowing the wearer while equipped and it fits into any backpack. \
	Comes in conspicuous red/orange colors. Helmet included."
	cost = 4
	item = /obj/item/storage/box/syndie_kit/firesuit/
	restricted_roles = list("Atmospheric Technician")

/datum/uplink_item/role_restricted/fire_axe
	name = "Fire Axe"
	desc = "A rather blunt fire axe recovered from the burnt out wreck of an old space station. \
	Warm to the touch, this axe will set fire to anyone struck with it as long as you hold it with\
	two hands. The more you strike them, the hotter they burn, it will deal bonus fire damage to lit\
	targets and will enable you to shoot gouts of fire that will set them ablaze. It will also apply thermite to\
	standard walls and ignite them on a second hit."
	cost = 10
	item = /obj/item/twohanded/fireaxe/fireyaxe
	restricted_roles = list("Atmospheric Technician")

/datum/uplink_item/role_restricted/retardhorn
	name = "Extra Annoying Bike Horn."
	desc = "This bike horn has been carefully tuned by the clown federation to subtly affect the brains of those who\
	 hear it using advanced sonic techniques. To the untrained eye, a golden bike horn but each honk will cause small\
	  amounts of brain damage, most targets will be reduced to a gibbering wreck before they catch on."
	cost = 5
	item = /obj/item/bikehorn/golden/retardhorn
	restricted_roles = list("Clown")

/datum/uplink_item/ammo/pistol
	desc = "An additional 8-round 10mm magazine; compatible with the Stechkin Pistol. These \
			are dirt cheap but aren't as effective as .357 rounds."

/datum/uplink_item/ammo/revolver
	cost = 2

/datum/uplink_item/dangerous/butterfly
	name = "Energy Butterfly Knife"
	desc = "A highly lethal and concealable knife that causes critical backstab damage when used with harm intent."
	cost = 12//80 backstab damage and armour pierce isn't a fucking joke
	item = /obj/item/melee/transforming/butterfly/energy
	surplus = 15

/datum/uplink_item/dangerous/beenade
	name = "Bee delivery grenade"
	desc = "This grenade is filled with several random posionous bees. Fun for the whole family!"
	cost = 4
	item = /obj/item/grenade/spawnergrenade/beenade
	surplus = 30
