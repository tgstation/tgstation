/* Backpacks
 * Contains:
 *		Backpack
 *		Backpack Types
 *		Satchel Types
 */

/*
 * Backpack
 */

/obj/item/weapon/storage/backpack
	name = "backpack"
	desc = "You wear this on your back and put items into it."
	icon_state = "backpack"
	item_state = "backpack"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK	//ERROOOOO
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 21
	storage_slots = 21
	resistance_flags = 0
	obj_integrity = 300
	max_integrity = 300

/*
 * Backpack Types
 */

/obj/item/weapon/storage/backpack/holding
	name = "bag of holding"
	desc = "A backpack that opens into a localized pocket of Blue Space."
	origin_tech = "bluespace=5;materials=4;engineering=4;plasmatech=5"
	icon_state = "holdingpack"
	item_state = "holdingpack"
	max_w_class = WEIGHT_CLASS_GIGANTIC
	max_combined_w_class = 35
	resistance_flags = FIRE_PROOF
	var/pshoom = 'sound/items/pshoom.ogg'
	var/alt_sound = 'sound/items/pshoom_2.ogg'
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 60, acid = 50)


/obj/item/weapon/storage/backpack/holding/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is jumping into [src]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	user.drop_item()
	user.Stun(100)
	sleep(20)
	playsound(src, "rustle", 50, 1, -5)
	qdel(user)
	return

/obj/item/weapon/storage/backpack/holding/content_can_dump(atom/dest_object, mob/user)
	if(Adjacent(user))
		if(get_dist(user, dest_object) < 8)
			if(dest_object.storage_contents_dump_act(src, user))
				if(alt_sound && prob(1))
					playsound(src, alt_sound, 40, 1)
				else
					playsound(src, pshoom, 40, 1)
				user.Beam(dest_object,icon_state="rped_upgrade",time=5)
				return 1
		to_chat(user, "The [src.name] buzzes.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
	return 0

/obj/item/weapon/storage/backpack/holding/handle_item_insertion(obj/item/W, prevent_warning = 0, mob/user)
	if((istype(W, /obj/item/weapon/storage/backpack/holding) || count_by_type(W.GetAllContents(), /obj/item/weapon/storage/backpack/holding)))
		var/safety = alert(user, "Doing this will have extremely dire consequences for the station and its crew. Be sure you know what you're doing.", "Put in [name]?", "Proceed", "Abort")
		if(safety == "Abort" || !in_range(src, user) || !src || !W || user.incapacitated())
			return
		investigate_log("has become a singularity. Caused by [user.key]", INVESTIGATE_SINGULO)
		to_chat(user, "<span class='danger'>The Bluespace interfaces of the two devices catastrophically malfunction!</span>")
		qdel(W)
		var/obj/singularity/singulo = new /obj/singularity (get_turf(src))
		singulo.energy = 300 //should make it a bit bigger~
		message_admins("[key_name_admin(user)] detonated a bag of holding")
		log_game("[key_name(user)] detonated a bag of holding")
		qdel(src)
		singulo.process()
		return
	. = ..()

/obj/item/weapon/storage/backpack/holding/singularity_act(current_size)
	var/dist = max((current_size - 2),1)
	explosion(src.loc,(dist),(dist*2),(dist*4))
	return


/obj/item/weapon/storage/backpack/santabag
	name = "Santa's Gift Bag"
	desc = "Space Santa uses this to deliver toys to all the nice children in space in Christmas! Wow, it's pretty big!"
	icon_state = "giftbag0"
	item_state = "giftbag"
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 60

/obj/item/weapon/storage/backpack/santabag/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] places [src] over their head and pulls it tight! It looks like they aren't in the Christmas spirit...</span>")
	return (OXYLOSS)

/obj/item/weapon/storage/backpack/cultpack
	name = "trophy rack"
	desc = "It's useful for both carrying extra gear and proudly declaring your insanity."
	icon_state = "cultpack"
	item_state = "backpack"

/obj/item/weapon/storage/backpack/clown
	name = "Giggles von Honkerton"
	desc = "It's a backpack made by Honk! Co."
	icon_state = "clownpack"
	item_state = "clownpack"

/obj/item/weapon/storage/backpack/explorer
	name = "explorer bag"
	desc = "A robust backpack for stashing your loot."
	icon_state = "explorerpack"
	item_state = "explorerpack"

/obj/item/weapon/storage/backpack/mime
	name = "Parcel Parceaux"
	desc = "A silent backpack made for those silent workers. Silence Co."
	icon_state = "mimepack"
	item_state = "mimepack"

/obj/item/weapon/storage/backpack/medic
	name = "medical backpack"
	desc = "It's a backpack especially designed for use in a sterile environment."
	icon_state = "medicalpack"
	item_state = "medicalpack"

/obj/item/weapon/storage/backpack/security
	name = "security backpack"
	desc = "It's a very robust backpack."
	icon_state = "securitypack"
	item_state = "securitypack"

/obj/item/weapon/storage/backpack/captain
	name = "captain's backpack"
	desc = "It's a special backpack made exclusively for Nanotrasen officers."
	icon_state = "captainpack"
	item_state = "captainpack"
	resistance_flags = 0

/obj/item/weapon/storage/backpack/industrial
	name = "industrial backpack"
	desc = "It's a tough backpack for the daily grind of station life."
	icon_state = "engiepack"
	item_state = "engiepack"
	resistance_flags = FIRE_PROOF

/obj/item/weapon/storage/backpack/botany
	name = "botany backpack"
	desc = "It's a backpack made of all-natural fibers."
	icon_state = "botpack"
	item_state = "botpack"

/obj/item/weapon/storage/backpack/chemistry
	name = "chemistry backpack"
	desc = "A backpack specially designed to repel stains and hazardous liquids."
	icon_state = "chempack"
	item_state = "chempack"

/obj/item/weapon/storage/backpack/genetics
	name = "genetics backpack"
	desc = "A bag designed to be super tough, just in case someone hulks out on you."
	icon_state = "genepack"
	item_state = "genepack"

/obj/item/weapon/storage/backpack/science
	name = "science backpack"
	desc = "A specially designed backpack. It's fire resistant and smells vaguely of plasma."
	icon_state = "toxpack"
	item_state = "toxpack"
	resistance_flags = 0

/obj/item/weapon/storage/backpack/virology
	name = "virology backpack"
	desc = "A backpack made of hypo-allergenic fibers. It's designed to help prevent the spread of disease. Smells like monkey."
	icon_state = "viropack"
	item_state = "viropack"


/*
 * Satchel Types
 */

/obj/item/weapon/storage/backpack/satchel
	name = "satchel"
	desc = "A trendy looking satchel."
	icon_state = "satchel-norm"
	species_exception = list(/datum/species/angel) //satchels can be equipped since they are on the side, not back

/obj/item/weapon/storage/backpack/satchel/leather
	name = "leather satchel"
	desc = "It's a very fancy satchel made with fine leather."
	icon_state = "satchel"
	resistance_flags = 0

/obj/item/weapon/storage/backpack/satchel/leather/withwallet/PopulateContents()
	new /obj/item/weapon/storage/wallet/random(src)

/obj/item/weapon/storage/backpack/satchel/eng
	name = "industrial satchel"
	desc = "A tough satchel with extra pockets."
	icon_state = "satchel-eng"
	item_state = "engiepack"
	resistance_flags = 0

/obj/item/weapon/storage/backpack/satchel/med
	name = "medical satchel"
	desc = "A sterile satchel used in medical departments."
	icon_state = "satchel-med"
	item_state = "medicalpack"

/obj/item/weapon/storage/backpack/satchel/vir
	name = "virologist satchel"
	desc = "A sterile satchel with virologist colours."
	icon_state = "satchel-vir"
	item_state = "satchel-vir"

/obj/item/weapon/storage/backpack/satchel/chem
	name = "chemist satchel"
	desc = "A sterile satchel with chemist colours."
	icon_state = "satchel-chem"
	item_state = "satchel-chem"

/obj/item/weapon/storage/backpack/satchel/gen
	name = "geneticist satchel"
	desc = "A sterile satchel with geneticist colours."
	icon_state = "satchel-gen"
	item_state = "satchel-gen"

/obj/item/weapon/storage/backpack/satchel/tox
	name = "scientist satchel"
	desc = "Useful for holding research materials."
	icon_state = "satchel-tox"
	item_state = "satchel-tox"
	resistance_flags = 0

/obj/item/weapon/storage/backpack/satchel/hyd
	name = "botanist satchel"
	desc = "A satchel made of all natural fibers."
	icon_state = "satchel-hyd"
	item_state = "satchel-hyd"

/obj/item/weapon/storage/backpack/satchel/sec
	name = "security satchel"
	desc = "A robust satchel for security related needs."
	icon_state = "satchel-sec"
	item_state = "securitypack"

/obj/item/weapon/storage/backpack/satchel/explorer
	name = "explorer satchel"
	desc = "A robust satchel for stashing your loot."
	icon_state = "satchel-explorer"
	item_state = "securitypack"

/obj/item/weapon/storage/backpack/satchel/cap
	name = "captain's satchel"
	desc = "An exclusive satchel for Nanotrasen officers."
	icon_state = "satchel-cap"
	item_state = "captainpack"
	resistance_flags = 0

/obj/item/weapon/storage/backpack/satchel/flat
	name = "smuggler's satchel"
	desc = "A very slim satchel that can easily fit into tight spaces."
	icon_state = "satchel-flat"
	w_class = WEIGHT_CLASS_NORMAL //Can fit in backpacks itself.
	max_combined_w_class = 15
	level = 1
	cant_hold = list(/obj/item/weapon/storage/backpack/satchel/flat) //muh recursive backpacks

/obj/item/weapon/storage/backpack/satchel/flat/hide(var/intact)
	if(intact)
		invisibility = INVISIBILITY_MAXIMUM
		anchored = 1 //otherwise you can start pulling, cover it, and drag around an invisible backpack.
		icon_state = "[initial(icon_state)]2"
	else
		invisibility = initial(invisibility)
		anchored = 0
		icon_state = initial(icon_state)

/obj/item/weapon/storage/backpack/satchel/flat/Initialize(mapload)
	..()
	SSpersistence.new_secret_satchels += src

/obj/item/weapon/storage/backpack/satchel/flat/PopulateContents()
	new /obj/item/stack/tile/plasteel(src)
	new /obj/item/weapon/crowbar(src)

/obj/item/weapon/storage/backpack/satchel/flat/Destroy()
	SSpersistence.new_secret_satchels -= src
	return ..()

/obj/item/weapon/storage/backpack/satchel/flat/secret
	var/list/reward_one_of_these = list() //Intended for map editing
	var/list/reward_all_of_these = list() //use paths!
	var/revealed = 0

/obj/item/weapon/storage/backpack/satchel/flat/secret/Initialize()
	..()

	if(isfloorturf(loc) && !istype(loc,/turf/open/floor/plating/))
		hide(1)

/obj/item/weapon/storage/backpack/satchel/flat/secret/hide(intact)
	..()
	if(!intact && !revealed)
		if(reward_one_of_these.len > 0)
			var/reward = pick(reward_one_of_these)
			new reward(src)
		for(var/R in reward_all_of_these)
			new R(src)
		revealed = 1

/obj/item/weapon/storage/backpack/duffelbag
	name = "duffel bag"
	desc = "A large duffel bag for holding extra things."
	icon_state = "duffel"
	item_state = "duffel"
	slowdown = 1
	max_combined_w_class = 30

/obj/item/weapon/storage/backpack/duffelbag/captain
	name = "captain's duffel bag"
	desc = "A large duffel bag for holding extra captainly goods."
	icon_state = "duffel-captain"
	item_state = "duffel-captain"
	resistance_flags = 0

/obj/item/weapon/storage/backpack/duffelbag/med
	name = "medical duffel bag"
	desc = "A large duffel bag for holding extra medical supplies."
	icon_state = "duffel-med"
	item_state = "duffel-med"

/obj/item/weapon/storage/backpack/duffelbag/med/surgery
	name = "surgical duffel bag"
	desc = "A large duffel bag for holding extra medical supplies - this one seems to be designed for holding surgical tools."

/obj/item/weapon/storage/backpack/duffelbag/med/surgery/PopulateContents()
	new /obj/item/weapon/scalpel(src)
	new /obj/item/weapon/hemostat(src)
	new /obj/item/weapon/retractor(src)
	new /obj/item/weapon/circular_saw(src)
	new /obj/item/weapon/surgicaldrill(src)
	new /obj/item/weapon/cautery(src)
	new /obj/item/weapon/surgical_drapes(src)
	new /obj/item/clothing/mask/surgical(src)
	new /obj/item/weapon/razor(src)

/obj/item/weapon/storage/backpack/duffelbag/sec
	name = "security duffel bag"
	desc = "A large duffel bag for holding extra security supplies and ammunition."
	icon_state = "duffel-sec"
	item_state = "duffel-sec"

/obj/item/weapon/storage/backpack/duffelbag/sec/surgery
	name = "surgical duffel bag"
	desc = "A large duffel bag for holding extra supplies - this one has a material inlay with space for various sharp-looking tools."

/obj/item/weapon/storage/backpack/duffelbag/sec/surgery/PopulateContents()
	new /obj/item/weapon/scalpel(src)
	new /obj/item/weapon/hemostat(src)
	new /obj/item/weapon/retractor(src)
	new /obj/item/weapon/circular_saw(src)
	new /obj/item/weapon/surgicaldrill(src)
	new /obj/item/weapon/cautery(src)
	new /obj/item/weapon/surgical_drapes(src)
	new /obj/item/clothing/mask/surgical(src)

/obj/item/weapon/storage/backpack/duffelbag/engineering
	name = "industrial duffel bag"
	desc = "A large duffel bag for holding extra tools and supplies."
	icon_state = "duffel-eng"
	item_state = "duffel-eng"
	resistance_flags = 0

/obj/item/weapon/storage/backpack/duffelbag/drone
	name = "drone duffel bag"
	desc = "A large duffel bag for holding tools and hats."
	icon_state = "duffel-drone"
	item_state = "duffel-drone"
	resistance_flags = FIRE_PROOF

/obj/item/weapon/storage/backpack/duffelbag/drone/PopulateContents()
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/weldingtool(src)
	new /obj/item/weapon/crowbar(src)
	new /obj/item/stack/cable_coil/random(src)
	new /obj/item/weapon/wirecutters(src)
	new /obj/item/device/multitool(src)

/obj/item/weapon/storage/backpack/duffelbag/clown
	name = "clown's duffel bag"
	desc = "A large duffel bag for holding lots of funny gags!"
	icon_state = "duffel-clown"
	item_state = "duffel-clown"

/obj/item/weapon/storage/backpack/duffelbag/clown/cream_pie/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/weapon/reagent_containers/food/snacks/pie/cream(src)

/obj/item/weapon/storage/backpack/duffelbag/syndie
	name = "suspicious looking duffel bag"
	desc = "A large duffel bag for holding extra tactical supplies."
	icon_state = "duffel-syndie"
	item_state = "duffel-syndie"
	origin_tech = "syndicate=1"
	silent = 1
	slowdown = 0

/obj/item/weapon/storage/backpack/duffelbag/syndie/hitman
	desc = "A large duffel bag for holding extra things. There is a NanoTrasen logo on the back."
	icon_state = "duffel-syndieammo"
	item_state = "duffel-syndieammo"

/obj/item/weapon/storage/backpack/duffelbag/syndie/hitman/PopulateContents()
	new /obj/item/clothing/under/lawyer/blacksuit(src)
	new /obj/item/clothing/accessory/waistcoat(src)
	new /obj/item/clothing/suit/toggle/lawyer/black(src)
	new /obj/item/clothing/shoes/laceup(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/clothing/head/fedora(src)

/obj/item/weapon/storage/backpack/duffelbag/syndie/med
	name = "medical duffel bag"
	desc = "A large duffel bag for holding extra tactical medical supplies."
	icon_state = "duffel-syndiemed"
	item_state = "duffel-syndiemed"

/obj/item/weapon/storage/backpack/duffelbag/syndie/surgery
	name = "surgery duffel bag"
	desc = "A suspicious looking duffel bag for holding surgery tools."
	icon_state = "duffel-syndiemed"
	item_state = "duffel-syndiemed"

/obj/item/weapon/storage/backpack/duffelbag/syndie/surgery/PopulateContents()
	new /obj/item/weapon/scalpel(src)
	new /obj/item/weapon/hemostat(src)
	new /obj/item/weapon/retractor(src)
	new /obj/item/weapon/circular_saw(src)
	new /obj/item/weapon/surgicaldrill(src)
	new /obj/item/weapon/cautery(src)
	new /obj/item/weapon/surgical_drapes(src)
	new /obj/item/clothing/suit/straight_jacket(src)
	new /obj/item/clothing/mask/muzzle(src)
	new /obj/item/device/mmi/syndie(src)

/obj/item/weapon/storage/backpack/duffelbag/syndie/ammo
	name = "ammunition duffel bag"
	desc = "A large duffel bag for holding extra weapons ammunition and supplies."
	icon_state = "duffel-syndieammo"
	item_state = "duffel-syndieammo"

/obj/item/weapon/storage/backpack/duffelbag/syndie/ammo/shotgun
	desc = "A large duffel bag, packed to the brim with Bulldog shotgun ammo."

/obj/item/weapon/storage/backpack/duffelbag/syndie/ammo/shotgun/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/ammo_box/magazine/m12g(src)
	new /obj/item/ammo_box/magazine/m12g/buckshot(src)
	new /obj/item/ammo_box/magazine/m12g/slug(src)
	new /obj/item/ammo_box/magazine/m12g/dragon(src)

/obj/item/weapon/storage/backpack/duffelbag/syndie/ammo/smg
	desc = "A large duffel bag, packed to the brim with C20r magazines."

/obj/item/weapon/storage/backpack/duffelbag/syndie/ammo/smg/PopulateContents()
	for(var/i in 1 to 9)
		new /obj/item/ammo_box/magazine/smgm45(src)

/obj/item/weapon/storage/backpack/duffelbag/syndie/c20rbundle
	desc = "A large duffel bag containing a C20r, some magazines, and a cheap looking suppressor."

/obj/item/weapon/storage/backpack/duffelbag/syndie/c20rbundle/PopulateContents()
	new /obj/item/ammo_box/magazine/smgm45(src)
	new /obj/item/ammo_box/magazine/smgm45(src)
	new /obj/item/weapon/gun/ballistic/automatic/c20r(src)
	new /obj/item/weapon/suppressor/specialoffer(src)

/obj/item/weapon/storage/backpack/duffelbag/syndie/bulldogbundle
	desc = "A large duffel bag containing a Bulldog, several drums, and a collapsed hardsuit."

/obj/item/weapon/storage/backpack/duffelbag/syndie/bulldogbundle/PopulateContents()
	new /obj/item/ammo_box/magazine/m12g(src)
	new /obj/item/weapon/gun/ballistic/automatic/shotgun/bulldog(src)
	new /obj/item/ammo_box/magazine/m12g/buckshot(src)
	new /obj/item/clothing/glasses/thermal/syndi(src)

/obj/item/weapon/storage/backpack/duffelbag/syndie/med/medicalbundle
	desc = "A large duffel bag containing a medical equipment, a Donksoft machine gun, a big jumbo box of darts, and a knock-off pair of magboots."

/obj/item/weapon/storage/backpack/duffelbag/syndie/med/medicalbundle/PopulateContents()
	new /obj/item/clothing/shoes/magboots/syndie(src)
	new /obj/item/weapon/storage/firstaid/tactical(src)
	new /obj/item/weapon/gun/ballistic/automatic/l6_saw/toy(src)
	new /obj/item/ammo_box/foambox/riot(src)

/obj/item/weapon/storage/backpack/duffelbag/syndie/med/medicalbundle
	desc = "A large duffel bag containing a medical equipment, a Donksoft machine gun, a big jumbo box of darts, and a knock-off pair of magboots."

/obj/item/weapon/storage/backpack/duffelbag/syndie/med/medicalbundle/PopulateContents()
	new /obj/item/clothing/shoes/magboots/syndie(src)
	new /obj/item/weapon/storage/firstaid/tactical(src)
	new /obj/item/weapon/gun/ballistic/automatic/l6_saw/toy(src)
	new /obj/item/ammo_box/foambox/riot(src)

/obj/item/weapon/storage/backpack/duffelbag/syndie/med/bioterrorbundle
	desc = "A large duffel bag containing a deadly chemicals, a chemical spray, chemical grenade, a Donksoft assault rifle, riot grade darts, a minature syringe gun, and a box of syringes"

/obj/item/weapon/storage/backpack/duffelbag/syndie/med/bioterrorbundle/PopulateContents()
	new /obj/item/weapon/reagent_containers/spray/chemsprayer/bioterror(src)
	new /obj/item/weapon/storage/box/syndie_kit/chemical(src)
	new /obj/item/weapon/gun/syringe/syndicate(src)
	new /obj/item/weapon/gun/ballistic/automatic/c20r/toy(src)
	new /obj/item/weapon/storage/box/syringes(src)
	new /obj/item/ammo_box/foambox/riot(src)
	new /obj/item/weapon/grenade/chem_grenade/bioterrorfoam(src)

/obj/item/weapon/storage/backpack/duffelbag/syndie/c4/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/weapon/grenade/plastic/c4(src)

/obj/item/weapon/storage/backpack/duffelbag/syndie/x4/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/weapon/grenade/plastic/x4(src)

/obj/item/weapon/storage/backpack/duffelbag/syndie/firestarter
	desc = "A large duffel bag containing New Russian pyro backpack sprayer, a pistol, a pipebomb, fireproof hardsuit, ammo, and other equipment."

/obj/item/weapon/storage/backpack/duffelbag/syndie/firestarter/PopulateContents()
	new /obj/item/clothing/under/syndicate/soviet(src)
	new /obj/item/weapon/watertank/operator(src)
	new /obj/item/clothing/suit/space/hardsuit/syndi/elite(src)
	new /obj/item/weapon/gun/ballistic/automatic/pistol/APS(src)
	new /obj/item/ammo_box/magazine/pistolm9mm(src)
	new /obj/item/ammo_box/magazine/pistolm9mm(src)
	new /obj/item/weapon/reagent_containers/food/drinks/bottle/vodka/badminka(src)
	new /obj/item/weapon/reagent_containers/syringe/stimulants(src)
	new /obj/item/weapon/grenade/syndieminibomb(src)
