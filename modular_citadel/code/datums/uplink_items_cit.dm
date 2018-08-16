/*/datum/uplink_item/stealthy_tools/syndi_borer
	name = "Syndicate Brain Slug"
	desc = "A small cortical borer, modified to be completely loyal to the owner. \
			Genetically infertile, these brain slugs can assist medically in a support role, or take direct action \
			to assist their host."
	item = /obj/item/antag_spawner/syndi_borer
	refundable = TRUE
	cost = 10
	surplus = 20 //Let's not have this be too common
	exclude_modes = list(/datum/game_mode/nuclear) */

/datum/uplink_item/stealthy_tools/holoparasite
	name="Holoparasite Injector"
	desc="An injector containing a swarm of holographic parasites. \
			They mimic the function of the guardians employed by the Space Wizard Federation, and their form can be selected upon application \
			NOTE: The precise nature of the symbiosis required by the parasites renders them incompatible with changelings" //updated to actually describe what they do and warn traitorchans not to buy it
	item = /obj/item/storage/box/syndie_kit/holoparasite
	refundable = TRUE
	cant_discount = TRUE
	cost = 15
	surplus = 20 //Nobody needs a ton of parasites
	exclude_modes = list(/datum/game_mode/nuclear)
	refund_path = /obj/item/guardiancreator/tech/choose/traitor


/obj/item/storage/box/syndie_kit/holoparasite
	name = "box"

/obj/item/storage/box/syndie_kit/holoparasite/PopulateContents()
	new /obj/item/guardiancreator/tech/choose/traitor(src)
	new /obj/item/paper/guides/antag/guardian(src)

/datum/uplink_item/dangerous/antitank
	name = "Anti Tank Pistol"
	desc = "Essentially amounting to a sniper rifle with no stock and barrel (or indeed, any rifling at all), \
			this extremely dubious pistol is guaranteed to dislocate your wrists and hit the broad side of a barn! \
	 		Uses sniper ammo. \
	 		Bullets tend to veer off-course. We are not responsible for any unintentional damage or injury resulting from inaacuracy."
	item = /obj/item/gun/ballistic/automatic/pistol/antitank/syndicate
	cost = 14
	surplus = 25
	include_modes = list(/datum/game_mode/nuclear)

/*		Commented out due to introduction of reskinnable stetchkins. May still have a niche if people decide it somehow has value.
/datum/uplink_item/dangerous/stealthpistol
	name = "Stealth Pistol"
	desc = "A compact, easily concealable bullpup pistol that fires 10mm auto rounds in 8 round magazines. \
			Has an integrated suppressor."
	item = /obj/item/gun/ballistic/automatic/pistol/stealth
	cost = 10
	surplus = 30
*/

///Soporific 10mm mags///

/datum/uplink_item/ammo/pistolzzz
	name = "10mm Soporific Magazine"
	desc = "An additional 8-round 10mm magazine; compatible with the Stechkin Pistol. Loaded with soporific rounds that put the target to sleep. \
			NOTE: Soporific is not instant acting due to the constraints of the round's scale. Will usually require three shots to take effect."
	item = /obj/item/ammo_box/magazine/m10mm/soporific
	cost = 2

///flechette memes///

/datum/uplink_item/dangerous/flechettegun
	name = "Flechette Launcher"
	desc = "A compact bullpup that fires micro-flechettes.\
			Flechettes have very poor performance idividually, but can be very deadly in numbers. \
			Pre-loaded with armor piercing flechettes that are capable of puncturing most kinds of armor."
	item = /obj/item/gun/ballistic/automatic/flechette
	cost = 12
	surplus = 30
	include_modes = list(/datum/game_mode/nuclear)

/datum/uplink_item/ammo/flechetteap
	name = "Armor Piercing Flechette Magazine"
	desc = "An additional 40-round flechette magazine; compatible with the Flechette Launcer. \
			Loaded with armor piercing flechettes that very nearly ignore armor, but are not very effective agaisnt flesh."
	item = /obj/item/ammo_box/magazine/flechette
	cost = 2
	include_modes = list(/datum/game_mode/nuclear)

/datum/uplink_item/ammo/flechettes
	name = "Serrated Flechette Magazine"
	desc = "An additional 40-round flechette magazine; compatible with the Flechette Launcer. \
			Loaded with serrated flechettes that shreds flesh, but is stopped dead in its tracks by armor. \
			These flechettes are highly likely to sever arteries, and even limbs."
	item = /obj/item/ammo_box/magazine/flechette/s
	cost = 2
	include_modes = list(/datum/game_mode/nuclear)

///shredder///

/datum/uplink_item/nukeoffer/shredder
	name = "Shredder bundle"
	desc = "A truly horrific weapon designed simply to maim its victim, the CX Shredder is banned by several intergalactic treaties. \
			You'll get two of them with this. And spare ammo to boot. And we'll throw in an extra elite hardsuit and chest rig to hold them all!"
	item = /obj/item/storage/backpack/duffelbag/syndie/shredderbundle
	cost = 30 // normally 41

///Modular Pistols///

/datum/uplink_item/bundle/modular
	name="Modular Pistol Kit"
	desc="A heavy briefcase containing one modular pistol (chambered in 10mm), one supressor, and spare ammunition, including a box of soporific ammo. \
		Includes a suit jacket that is padded with a robust liner."
	item = /obj/item/storage/briefcase/modularbundle
	cost = 12

//////Bundle stuff//////

///bundle category///

/datum/uplink_item/bundle
	category = "Bundles"
	surplus = 0
	cant_discount = TRUE

///place bundle storage items here I guess///

/obj/item/storage/briefcase/modularbundle
	name = "briefcase"
	desc = "It's label reads genuine hardened Captain leather, but suspiciously has no other tags or branding."
	icon_state = "briefcase"
	flags_1 = CONDUCT_1
	force = 10
	hitsound = "swing_hit"
	throw_speed = 2
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")
	resistance_flags = FLAMMABLE
	max_integrity = 150

/obj/item/storage/briefcase/modularbundle/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/modular(src)
	new /obj/item/suppressor(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm/soporific(src)
	new /obj/item/ammo_box/c10mm/soporific(src)
	new /obj/item/clothing/under/lawyer/blacksuit(src)
	new /obj/item/clothing/accessory/waistcoat(src)
	new /obj/item/clothing/suit/toggle/lawyer/black/syndie(src)

/obj/item/clothing/suit/toggle/lawyer/black/syndie
	desc = "A snappy dress jacket. Suspiciously has no tags or branding."
	armor = list(melee = 10, bullet = 10, laser = 10, energy = 10, bomb = 10)

/obj/item/storage/backpack/duffelbag/syndie/shredderbundle
	desc = "A large duffel bag containing two CX Shredders, some magazines, an elite hardsuit, and a chest rig."

/obj/item/storage/backpack/duffelbag/syndie/shredderbundle/PopulateContents()
	new /obj/item/ammo_box/magazine/flechette/shredder(src)
	new /obj/item/ammo_box/magazine/flechette/shredder(src)
	new /obj/item/ammo_box/magazine/flechette/shredder(src)
	new /obj/item/ammo_box/magazine/flechette/shredder(src)
	new /obj/item/gun/ballistic/automatic/flechette/shredder(src)
	new /obj/item/gun/ballistic/automatic/flechette/shredder(src)
	new /obj/item/storage/belt/military(src)
	new /obj/item/clothing/suit/space/hardsuit/syndi/elite(src)

///End of Bundle stuff///


/*/////////////////////////////////////////////////////////////////////////
/////////////		The TRUE Energy Sword		///////////////////////////
*//////////////////////////////////////////////////////////////////////////

/datum/uplink_item/dangerous/cxneb
	name = "Dragon's Tooth Non-Eutactic Blade"
	desc = "An illegal modification of a weapon that is functionally identical to the energy sword, \
			the Non-Eutactic Blade (NEB) forges a hardlight blade on-demand, \
	 		generating an extremely sharp, unbreakable edge that is guaranteed to satisfy your every need. \
	 		This particular model has a polychromic hardlight generator, allowing you to murder in style! \
	 		The illegal modifications bring this weapon up to par with the classic energy sword, and also gives it the energy sword's distinctive sounds."
	item = /obj/item/melee/transforming/energy/sword/cx/traitor
	cost = 8