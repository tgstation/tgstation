<<<<<<< HEAD
/obj/item/weapon/storage/belt
	name = "belt"
	desc = "Can hold various things."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "utilitybelt"
	item_state = "utility"
	slot_flags = SLOT_BELT
	attack_verb = list("whipped", "lashed", "disciplined")

/obj/item/weapon/storage/belt/update_icon()
	cut_overlays()
	for(var/obj/item/I in contents)
		add_overlay("[I.name]")
	..()

/obj/item/weapon/storage/belt/utility
	name = "toolbelt" //Carn: utility belt is nicer, but it bamboozles the text parsing.
	desc = "Holds tools."
	icon_state = "utilitybelt"
	item_state = "utility"
	can_hold = list(
		/obj/item/weapon/crowbar,
		/obj/item/weapon/screwdriver,
		/obj/item/weapon/weldingtool,
		/obj/item/weapon/wirecutters,
		/obj/item/weapon/wrench,
		/obj/item/device/multitool,
		/obj/item/device/flashlight,
		/obj/item/stack/cable_coil,
		/obj/item/device/t_scanner,
		/obj/item/device/analyzer,
		/obj/item/weapon/extinguisher/mini,
		/obj/item/device/radio,
		/obj/item/clothing/gloves/
		)

/obj/item/weapon/storage/belt/utility/full/New()
	..()
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/weldingtool(src)
	new /obj/item/weapon/crowbar(src)
	new /obj/item/weapon/wirecutters(src)
	new /obj/item/device/multitool(src)
	new /obj/item/stack/cable_coil(src,30,pick("red","yellow","orange"))


/obj/item/weapon/storage/belt/utility/atmostech/New()
	..()
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/weldingtool(src)
	new /obj/item/weapon/crowbar(src)
	new /obj/item/weapon/wirecutters(src)
	new /obj/item/device/t_scanner(src)
	new /obj/item/weapon/extinguisher/mini(src)



/obj/item/weapon/storage/belt/medical
	name = "medical belt"
	desc = "Can hold various medical equipment."
	icon_state = "medicalbelt"
	item_state = "medical"
	max_w_class = 4
	can_hold = list(
		/obj/item/device/healthanalyzer,
		/obj/item/weapon/dnainjector,
		/obj/item/weapon/reagent_containers/dropper,
		/obj/item/weapon/reagent_containers/glass/beaker,
		/obj/item/weapon/reagent_containers/glass/bottle,
		/obj/item/weapon/reagent_containers/pill,
		/obj/item/weapon/reagent_containers/syringe,
		/obj/item/weapon/lighter,
		/obj/item/weapon/storage/fancy/cigarettes,
		/obj/item/weapon/storage/pill_bottle,
		/obj/item/stack/medical,
		/obj/item/device/flashlight/pen,
		/obj/item/weapon/extinguisher/mini,
		/obj/item/weapon/reagent_containers/hypospray,
		/obj/item/device/sensor_device,
		/obj/item/device/radio,
		/obj/item/clothing/gloves/,
		/obj/item/weapon/lazarus_injector,
		/obj/item/weapon/bikehorn/rubberducky,
		/obj/item/clothing/mask/surgical,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/breath/medical,
		/obj/item/weapon/surgical_drapes, //for true paramedics
		/obj/item/weapon/scalpel,
		/obj/item/weapon/circular_saw,
		/obj/item/weapon/surgicaldrill,
		/obj/item/weapon/retractor,
		/obj/item/weapon/cautery,
		/obj/item/weapon/hemostat,
		/obj/item/device/geiger_counter,
		/obj/item/clothing/tie/stethoscope,
		/obj/item/weapon/stamp,
		/obj/item/clothing/glasses,
		/obj/item/weapon/wrench/medical,
		/obj/item/clothing/mask/muzzle,
		/obj/item/weapon/storage/bag/chemistry,
		/obj/item/weapon/storage/bag/bio,
		/obj/item/weapon/reagent_containers/blood,
		/obj/item/weapon/tank/internals/emergency_oxygen
		)


/obj/item/weapon/storage/belt/security
	name = "security belt"
	desc = "Can hold security gear like handcuffs and flashes."
	icon_state = "securitybelt"
	item_state = "security"//Could likely use a better one.
	storage_slots = 5
	max_w_class = 3 //Because the baton wouldn't fit otherwise. - Neerti
	can_hold = list(
		/obj/item/weapon/melee/baton,
		/obj/item/weapon/melee/classic_baton,
		/obj/item/weapon/grenade,
		/obj/item/weapon/reagent_containers/spray/pepper,
		/obj/item/weapon/restraints/handcuffs,
		/obj/item/device/assembly/flash/handheld,
		/obj/item/clothing/glasses,
		/obj/item/ammo_casing/shotgun,
		/obj/item/ammo_box,
		/obj/item/weapon/reagent_containers/food/snacks/donut,
		/obj/item/weapon/reagent_containers/food/snacks/donut/jelly,
		/obj/item/weapon/kitchen/knife/combat,
		/obj/item/device/flashlight/seclite,
		/obj/item/weapon/melee/classic_baton/telescopic,
		/obj/item/device/radio,
		/obj/item/clothing/gloves/,
		/obj/item/weapon/restraints/legcuffs/bola
		)

/obj/item/weapon/storage/belt/security/full/New()
	..()
	new /obj/item/weapon/reagent_containers/spray/pepper(src)
	new /obj/item/weapon/restraints/handcuffs(src)
	new /obj/item/weapon/grenade/flashbang(src)
	new /obj/item/device/assembly/flash/handheld(src)
	new /obj/item/weapon/melee/baton/loaded(src)


/obj/item/weapon/storage/belt/mining
	name = "explorer's webbing"
	desc = "A versatile chest rig, cherished by miners and hunters alike."
	icon_state = "explorer1"
	item_state = "explorer1"
	storage_slots = 6
	w_class = 4
	max_w_class = 4 //Pickaxes are big.
	max_combined_w_class = 20 //Not an issue with this whitelist, probably.
	can_hold = list(
		/obj/item/weapon/crowbar,
		/obj/item/weapon/screwdriver,
		/obj/item/weapon/weldingtool,
		/obj/item/weapon/wirecutters,
		/obj/item/weapon/wrench,
		/obj/item/device/flashlight,
		/obj/item/stack/cable_coil,
		/obj/item/device/analyzer,
		/obj/item/weapon/extinguisher/mini,
		/obj/item/device/radio,
		/obj/item/clothing/gloves,
		/obj/item/weapon/resonator,
		/obj/item/device/mining_scanner,
		/obj/item/weapon/pickaxe,
		/obj/item/stack/sheet/animalhide,
		/obj/item/stack/sheet/sinew,
		/obj/item/stack/sheet/bone,
		/obj/item/weapon/lighter,
		/obj/item/weapon/storage/fancy/cigarettes,
		/obj/item/weapon/reagent_containers/food/drinks/bottle,
		/obj/item/stack/medical,
		/obj/item/weapon/kitchen/knife,
		/obj/item/weapon/reagent_containers/hypospray,
		/obj/item/device/gps,
		/obj/item/weapon/storage/bag/ore,
		/obj/item/weapon/survivalcapsule,
		/obj/item/device/t_scanner/adv_mining_scanner,
		/obj/item/weapon/reagent_containers/pill,
		/obj/item/weapon/storage/pill_bottle,
		/obj/item/weapon/ore,
		/obj/item/weapon/reagent_containers/food/drinks
		)


/obj/item/weapon/storage/belt/mining/vendor
	contents = newlist(/obj/item/weapon/survivalcapsule)

/obj/item/weapon/storage/belt/mining/alt
	icon_state = "explorer2"
	item_state = "explorer2"

/obj/item/weapon/storage/belt/mining/primitive
	name = "hunter's belt"
	desc = "A versatile belt, woven from sinew."
	storage_slots = 5
	icon_state = "ebelt"
	item_state = "ebelt"

/obj/item/weapon/storage/belt/soulstone
	name = "soul stone belt"
	desc = "Designed for ease of access to the shards during a fight, as to not let a single enemy spirit slip away"
	icon_state = "soulstonebelt"
	item_state = "soulstonebelt"
	storage_slots = 6
	can_hold = list(
		/obj/item/device/soulstone
		)

/obj/item/weapon/storage/belt/soulstone/full/New()
	..()
	for(var/i in 1 to 6)
		new /obj/item/device/soulstone(src)

/obj/item/weapon/storage/belt/champion
	name = "championship belt"
	desc = "Proves to the world that you are the strongest!"
	icon_state = "championbelt"
	item_state = "champion"
	materials = list(MAT_GOLD=400)
	storage_slots = 1
	can_hold = list(
		/obj/item/clothing/mask/luchador
		)

/obj/item/weapon/storage/belt/military
	name = "military belt"
	desc = "A syndicate belt designed to be used by boarding parties.  Its style is modeled after the hardsuits they wear."
	icon_state = "militarybelt"
	item_state = "military"
	max_w_class = 2

/obj/item/weapon/storage/belt/military/army
	name = "army belt"
	desc = "A belt used by military forces."
	icon_state = "grenadebeltold"
	item_state = "security"

/obj/item/weapon/storage/belt/military/assault
	name = "assault belt"
	desc = "A tactical assault belt."
	icon_state = "assaultbelt"
	item_state = "security"
	storage_slots = 6

/obj/item/weapon/storage/belt/grenade
	name = "grenadier belt"
	desc = "A belt for holding grenades."
	icon_state = "grenadebeltnew"
	item_state = "security"
	max_w_class = 4
	storage_slots = 30
	can_hold = list(
		/obj/item/weapon/grenade,
		/obj/item/weapon/screwdriver,
		/obj/item/weapon/lighter,
		/obj/item/device/multitool,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/molotov,
		/obj/item/weapon/c4,
		)
/obj/item/weapon/storage/belt/grenade/full/New()
	..()
	new /obj/item/weapon/grenade/flashbang(src)
	new /obj/item/weapon/grenade/smokebomb(src)
	new /obj/item/weapon/grenade/smokebomb(src)
	new /obj/item/weapon/grenade/smokebomb(src)
	new /obj/item/weapon/grenade/smokebomb(src)
	new /obj/item/weapon/grenade/empgrenade(src)
	new /obj/item/weapon/grenade/empgrenade(src)
	new /obj/item/weapon/grenade/syndieminibomb/concussion/frag(src)
	new /obj/item/weapon/grenade/syndieminibomb/concussion/frag(src)
	new /obj/item/weapon/grenade/syndieminibomb/concussion/frag(src)
	new /obj/item/weapon/grenade/syndieminibomb/concussion/frag(src)
	new /obj/item/weapon/grenade/syndieminibomb/concussion/frag(src)
	new /obj/item/weapon/grenade/syndieminibomb/concussion/frag(src)
	new /obj/item/weapon/grenade/syndieminibomb/concussion/frag(src)
	new /obj/item/weapon/grenade/syndieminibomb/concussion/frag(src)
	new /obj/item/weapon/grenade/syndieminibomb/concussion/frag(src)
	new /obj/item/weapon/grenade/syndieminibomb/concussion/frag(src)
	new /obj/item/weapon/grenade/gluon(src)
	new /obj/item/weapon/grenade/gluon(src)
	new /obj/item/weapon/grenade/gluon(src)
	new /obj/item/weapon/grenade/gluon(src)
	new /obj/item/weapon/grenade/chem_grenade/incendiary(src)
	new /obj/item/weapon/grenade/chem_grenade/incendiary(src)
	new /obj/item/weapon/grenade/chem_grenade/facid(src)
	new /obj/item/weapon/grenade/syndieminibomb(src)
	new /obj/item/weapon/grenade/syndieminibomb(src)
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/device/multitool(src)

/obj/item/weapon/storage/belt/wands
	name = "wand belt"
	desc = "A belt designed to hold various rods of power. A veritable fanny pack of exotic magic."
	icon_state = "soulstonebelt"
	item_state = "soulstonebelt"
	storage_slots = 6
	can_hold = list(
		/obj/item/weapon/gun/magic/wand
		)

/obj/item/weapon/storage/belt/wands/full/New()
	..()
	new /obj/item/weapon/gun/magic/wand/death(src)
	new /obj/item/weapon/gun/magic/wand/resurrection(src)
	new /obj/item/weapon/gun/magic/wand/polymorph(src)
	new /obj/item/weapon/gun/magic/wand/teleport(src)
	new /obj/item/weapon/gun/magic/wand/door(src)
	new /obj/item/weapon/gun/magic/wand/fireball(src)

	for(var/obj/item/weapon/gun/magic/wand/W in contents) //All wands in this pack come in the best possible condition
		W.max_charges = initial(W.max_charges)
		W.charges = W.max_charges

/obj/item/weapon/storage/belt/janitor
	name = "janibelt"
	desc = "A belt used to hold most janitorial supplies."
	icon_state = "janibelt"
	item_state = "janibelt"
	storage_slots = 6
	max_w_class = 4 // Set to this so the  light replacer can fit.
	can_hold = list(
		/obj/item/weapon/grenade/chem_grenade,
		/obj/item/device/lightreplacer,
		/obj/item/device/flashlight,
		/obj/item/weapon/reagent_containers/spray,
		/obj/item/weapon/soap,
		/obj/item/weapon/holosign_creator,
		/obj/item/key/janitor,
		/obj/item/clothing/gloves/
		)

/obj/item/weapon/storage/belt/bandolier
	name = "bandolier"
	desc = "A bandolier for holding shotgun ammunition."
	icon_state = "bandolier"
	item_state = "bandolier"
	storage_slots = 18
	can_hold = list(
		/obj/item/ammo_casing/shotgun
		)

/obj/item/weapon/storage/belt/holster
	name = "shoulder holster"
	desc = "A holster to carry a handgun and ammo. WARNING: Badasses only."
	icon_state = "holster"
	item_state = "holster"
	storage_slots = 3
	max_w_class = 3
	can_hold = list(
		/obj/item/weapon/gun/projectile/automatic/pistol,
		/obj/item/weapon/gun/projectile/revolver,
		/obj/item/ammo_box,
		)
	alternate_worn_layer = UNDER_SUIT_LAYER

/obj/item/weapon/storage/belt/fannypack
	name = "fannypack"
	desc = "A dorky fannypack for keeping small items in."
	icon_state = "fannypack_leather"
	item_state = "fannypack_leather"
	storage_slots = 3
	max_w_class = 2

/obj/item/weapon/storage/belt/fannypack/black
	name = "black fannypack"
	icon_state = "fannypack_black"
	item_state = "fannypack_black"

/obj/item/weapon/storage/belt/fannypack/red
	name = "red fannypack"
	icon_state = "fannypack_red"
	item_state = "fannypack_red"

/obj/item/weapon/storage/belt/fannypack/purple
	name = "purple fannypack"
	icon_state = "fannypack_purple"
	item_state = "fannypack_purple"

/obj/item/weapon/storage/belt/fannypack/blue
	name = "blue fannypack"
	icon_state = "fannypack_blue"
	item_state = "fannypack_blue"

/obj/item/weapon/storage/belt/fannypack/orange
	name = "orange fannypack"
	icon_state = "fannypack_orange"
	item_state = "fannypack_orange"

/obj/item/weapon/storage/belt/fannypack/white
	name = "white fannypack"
	icon_state = "fannypack_white"
	item_state = "fannypack_white"

/obj/item/weapon/storage/belt/fannypack/green
	name = "green fannypack"
	icon_state = "fannypack_green"
	item_state = "fannypack_green"

/obj/item/weapon/storage/belt/fannypack/pink
	name = "pink fannypack"
	icon_state = "fannypack_pink"
	item_state = "fannypack_pink"

/obj/item/weapon/storage/belt/fannypack/cyan
	name = "cyan fannypack"
	icon_state = "fannypack_cyan"
	item_state = "fannypack_cyan"

/obj/item/weapon/storage/belt/fannypack/yellow
	name = "yellow fannypack"
	icon_state = "fannypack_yellow"
	item_state = "fannypack_yellow"

/obj/item/weapon/storage/belt/rapier
	name = "rapier sheath"
	desc = "Can hold rapiers."
	icon_state = "sheath"
	item_state = "sheath"
	storage_slots = 1
	max_w_class = 4
	can_hold = list(
		/obj/item/weapon/melee/rapier
		)

/obj/item/weapon/storage/belt/rapier/update_icon()
	icon_state = "[initial(icon_state)]"
	item_state = "[initial(item_state)]"
	if(contents.len)
		icon_state = "[initial(icon_state)]-rapier"
		item_state = "[initial(item_state)]-rapier"
	if(loc && istype(loc, /mob/living))
		var/mob/living/L = loc
		L.regenerate_icons()
	..()

/obj/item/weapon/storage/belt/rapier/New()
	..()
	new /obj/item/weapon/melee/rapier(src)
=======
/obj/item/weapon/storage/belt
	name = "belt"
	desc = "Can hold various things."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "utilitybelt"
	item_state = "utility"
	flags = FPRINT
	slot_flags = SLOT_BELT
	attack_verb = list("whips", "lashes", "disciplines")


/obj/item/weapon/storage/belt/proc/can_use()
	if(!ismob(loc)) return 0
	var/mob/M = loc
	if(src in M.get_equipped_items())
		return 1
	else
		return 0

/obj/item/weapon/storage/belt/can_quick_store(var/obj/item/I)
	return can_be_inserted(I,1)

/obj/item/weapon/storage/belt/quick_store(var/obj/item/I)
	return handle_item_insertion(I,0)

/obj/item/weapon/storage/belt/utility
	name = "tool-belt" //Carn: utility belt is nicer, but it bamboozles the text parsing.
	desc = "It has a tag that rates it for compatibility with standard tools, device analyzers, flashlights, cables, engineering tape, small fire extinguishers, compressed matter cartridges, light replacers, and fuel cans."
	icon_state = "utilitybelt"
	item_state = "utility"
	w_class = W_CLASS_LARGE
	storage_slots = 14
	max_combined_w_class = 200 //This actually doesn't matter as long as it is arbitrarily high, bar will be set by storage slots
	can_only_hold = list(
		"/obj/item/weapon/crowbar",
		"/obj/item/weapon/screwdriver",
		"/obj/item/weapon/weldingtool",
		"/obj/item/weapon/solder",
		"/obj/item/weapon/wirecutters",
		"/obj/item/weapon/wrench",
		"/obj/item/device/multitool",
		"/obj/item/device/flashlight",
		"/obj/item/stack/cable_coil",
		"/obj/item/device/t_scanner",
		"/obj/item/device/analyzer",
		"/obj/item/taperoll/engineering",
		"/obj/item/taperoll/atmos",
		"/obj/item/weapon/extinguisher",
		"/obj/item/weapon/rcd_ammo",
		"/obj/item/weapon/reagent_containers/glass/fuelcan",
		"/obj/item/device/lightreplacer",
		"/obj/item/device/device_analyser",
		"/obj/item/device/silicate_sprayer"
		)

/obj/item/weapon/storage/belt/utility/complete/New()
	..()
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/weldingtool(src)
	new /obj/item/weapon/crowbar(src)
	new /obj/item/weapon/wirecutters(src)
	new /obj/item/device/multitool(src)
	new /obj/item/stack/cable_coil(src,30,pick("red","yellow","orange"))

/obj/item/weapon/storage/belt/utility/full/New()
	..()
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/weldingtool(src)
	new /obj/item/weapon/crowbar(src)
	new /obj/item/weapon/wirecutters(src)
	new /obj/item/stack/cable_coil(src,30,pick("red","yellow","orange"))


/obj/item/weapon/storage/belt/utility/atmostech/New()
	..()
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/weldingtool(src)
	new /obj/item/weapon/crowbar(src)
	new /obj/item/weapon/wirecutters(src)
	new /obj/item/device/t_scanner(src)

/obj/item/weapon/storage/belt/utility/chief
	name = "advanced tool-belt"
	desc = "The ancestral belt of Many-APCs-Charging, the original chief engineer from Space Native America. It's made out of the skins of the ancient enemy of engineers, giant spiders."
	icon_state = "utilitychief"
	item_state = "utilitychief"
	w_class = W_CLASS_LARGE
	storage_slots = 14
	can_only_hold = list(
		"/obj/item/weapon/crowbar",
		"/obj/item/weapon/screwdriver",
		"/obj/item/weapon/weldingtool",
		"/obj/item/weapon/solder",
		"/obj/item/weapon/wirecutters",
		"/obj/item/weapon/wrench",
		"/obj/item/device/multitool",
		"/obj/item/device/flashlight",
		"/obj/item/stack/cable_coil",
		"/obj/item/device/t_scanner",
		"/obj/item/device/analyzer",
		"/obj/item/taperoll/engineering",
		"/obj/item/taperoll/atmos",
		"/obj/item/weapon/extinguisher",
		"/obj/item/device/rcd/matter/engineering",
		"/obj/item/device/rcd/rpd",
		"/obj/item/device/rcd/tile_painter",
		"/obj/item/weapon/storage/component_exchanger",
		"/obj/item/weapon/rcd_ammo",
		"/obj/item/weapon/reagent_containers/glass/fuelcan",
		"/obj/item/blueprints",
		"/obj/item/device/lightreplacer",
		"/obj/item/device/device_analyser",
		"/obj/item/weapon/rcl",
		"/obj/item/device/silicate_sprayer"
		)

/obj/item/weapon/storage/belt/utility/chief/full/New() //This is mostly for testing I guess
	..()
	new /obj/item/weapon/crowbar(src)
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/weldingtool/hugetank(src)
	new /obj/item/weapon/wirecutters(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/device/multitool(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/device/t_scanner(src)
	new /obj/item/device/analyzer(src)
	new /obj/item/weapon/solder/pre_fueled(src)
	new /obj/item/device/silicate_sprayer(src)
	new /obj/item/device/rcd/rpd(src)
	new /obj/item/device/rcd/matter/engineering/pre_loaded(src)


/obj/item/weapon/storage/belt/medical
	name = "medical belt"
	desc = "Can hold various medical equipment."
	icon_state = "medicalbelt"
	item_state = "medical"
	can_only_hold = list(
		"/obj/item/device/healthanalyzer",
		"/obj/item/weapon/dnainjector",
		"/obj/item/weapon/reagent_containers/dropper",
		"/obj/item/weapon/reagent_containers/glass/beaker",
		"/obj/item/weapon/reagent_containers/glass/bottle",
		"/obj/item/weapon/reagent_containers/pill",
		"/obj/item/weapon/reagent_containers/syringe",
		"/obj/item/weapon/reagent_containers/glass/dispenser",
		"/obj/item/weapon/lighter/zippo",
		"/obj/item/weapon/storage/fancy/cigarettes",
		"/obj/item/weapon/storage/pill_bottle",
		"/obj/item/stack/medical",
		"/obj/item/device/flashlight/pen",
		"/obj/item/clothing/mask/surgical",
		"/obj/item/clothing/gloves/latex",
        "/obj/item/weapon/reagent_containers/hypospray/autoinjector",
		"/obj/item/device/mass_spectrometer",
		"/obj/item/device/gps/paramedic",
		"/obj/item/device/antibody_scanner",
		"/obj/item/weapon/switchtool/surgery"
	)


/obj/item/weapon/storage/belt/security
	name = "security belt"
	desc = "Can hold security gear like handcuffs and flashes."
	icon_state = "securitybelt"
	item_state = "security"//Could likely use a better one.
	storage_slots = 7
	max_combined_w_class = 21
	can_only_hold = list(
		"/obj/item/weapon/grenade",
		"/obj/item/weapon/reagent_containers/spray/pepper",
		"/obj/item/weapon/handcuffs",
		"/obj/item/device/flash",
		"/obj/item/clothing/glasses",
		"/obj/item/ammo_casing/shotgun",
		"/obj/item/ammo_storage",
		"/obj/item/weapon/reagent_containers/food/snacks/donut/normal",
		"/obj/item/weapon/reagent_containers/food/snacks/donut/jelly",
		"/obj/item/weapon/melee/baton",
		"/obj/item/weapon/gun/energy/taser",
		"/obj/item/weapon/lighter/zippo",
		"/obj/item/weapon/cigpacket",
		"/obj/item/clothing/glasses/hud/security",
		"/obj/item/device/flashlight",
		"/obj/item/device/pda",
		"/obj/item/device/radio/headset",
		"/obj/item/weapon/melee/baton",
		"/obj/item/taperoll/police",
		"/obj/item/weapon/gun/energy/taser",
		"/obj/item/weapon/legcuffs/bolas",
		"/obj/item/device/hailer",
		"obj/item/weapon/melee/telebaton",
		"/obj/item/device/gps/secure"
		)
/obj/item/weapon/storage/belt/security/batmanbelt
	name = "batbelt"
	desc = "For all your crime-fighting bat needs."
	icon_state = "bmbelt"
	item_state = "bmbelt"

/obj/item/weapon/storage/belt/security/batmanbelt/New()
	..()
	can_only_hold |= "/obj/item/weapon/gun/hookshot"

/obj/item/weapon/storage/belt/soulstone
	name = "soul stone belt"
	desc = "Designed for ease of access to the shards during a fight, as to not let a single enemy spirit slip away"
	icon_state = "soulstonebelt"
	item_state = "soulstonebelt"
	storage_slots = 6
	can_only_hold = list(
		"/obj/item/device/soulstone"
		)

/obj/item/weapon/storage/belt/soulstone/full/New()
	..()
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)


/obj/item/weapon/storage/belt/champion
	name = "championship belt"
	desc = "Proves to the world that you are the strongest!"
	icon_state = "championbelt"
	item_state = "champion"
	storage_slots = 1
	can_only_hold = list(
		"/obj/item/clothing/mask/luchador"
		)


/obj/item/weapon/storage/belt/skull
	name = "trophy-belt" //FATALITY
	desc = "Excellent for holding the heads of your fallen foes."
	icon_state = "utilitybelt"
	item_state = "utility"
	max_combined_w_class = 28
	can_only_hold = list(
 		"/obj/item/weapon/organ/head"
 	)


/obj/item/weapon/storage/belt/mining
	name = "mining gear belt"
	desc = "Can hold various mining gear like pickaxes or drills."
	icon_state = "miningbelt"
	item_state = "mining"
	w_class = W_CLASS_LARGE
	max_combined_w_class = 28
	can_only_hold = list(
		"/obj/item/weapon/storage/bag/ore",
		"/obj/item/weapon/pickaxe/shovel",
		"/obj/item/weapon/storage/box/samplebags",
		"/obj/item/device/core_sampler",
		"/obj/item/device/beacon_locator",
		"/obj/item/beacon",
		"/obj/item/device/gps",
		"/obj/item/device/measuring_tape",
		"/obj/item/device/flashlight",
		"/obj/item/weapon/pickaxe",
		"/obj/item/device/depth_scanner",
		"/obj/item/weapon/paper",
		"/obj/item/weapon/pen",
		"/obj/item/clothing/glasses",
		"/obj/item/weapon/wrench",
		"/obj/item/device/mining_scanner",
		"/obj/item/weapon/crowbar",
		"/obj/item/weapon/storage/box/excavation",
		"/obj/item/weapon/gun/energy/kinetic_accelerator",
		"/obj/item/weapon/resonator",
		"/obj/item/device/wormhole_jaunter",
		"/obj/item/weapon/lazarus_injector",
		"/obj/item/weapon/anobattery",
		"/obj/item/weapon/mining_drone_cube")

/obj/item/weapon/storage/belt/lazarus
	name = "trainer's belt"
	desc = "For the pokemo- mining master, holds your lazarus capsules."
	icon_state = "lazarusbelt_0"
	item_state = "lazbelt"
	w_class = W_CLASS_LARGE
	max_combined_w_class = 28
	storage_slots = 6
	can_only_hold = list(
		"/obj/item/device/mobcapsule",
		"/obj/item/weapon/lazarus_injector")

/obj/item/weapon/storage/belt/lazarus/New()
	..()
	update_icon()


/obj/item/weapon/storage/belt/lazarus/update_icon()
	..()
	icon_state = "lazarusbelt_[contents.len]"

/obj/item/weapon/storage/belt/lazarus/attackby(obj/item/W, mob/user)
	var/amount = contents.len
	. = ..()
	if(amount != contents.len)
		update_icon()

/obj/item/weapon/storage/belt/lazarus/remove_from_storage(obj/item/W as obj, atom/new_location)
	..()
	update_icon()

/obj/item/weapon/storage/belt/lazarus/antag
	icon_state = "lazarusbelt"

/obj/item/weapon/storage/belt/lazarus/antag/New(loc, mob/user)
	var/blocked = list(
	/mob/living/simple_animal/hostile/hivebot/tele,
	)
	var/list/critters = existing_typesof(/mob/living/simple_animal/hostile) - blocked // list of possible hostile mobs
	critters = shuffle(critters)
	while(contents.len < 6)
		var/obj/item/device/mobcapsule/MC = new /obj/item/device/mobcapsule(src)
		var/chosen = pick(critters)
		critters -= chosen
		var/mob/living/simple_animal/hostile/NM = new chosen(MC)
		NM.faction = "lazarus \ref[user]"
		NM.friends += user
		MC.contained_mob = NM
		MC.name = "lazarus capsule - [NM.name]"
	..()

/obj/item/weapon/storage/belt/thunderdome
	name = "Thunderdome Belt"
	desc = "Can hold the thunderdome IDs of your fallen foes."
	item_state = ""
	storage_slots = 30
	can_only_hold = list("/obj/item/weapon/card/id/thunderdome")

/obj/item/weapon/storage/belt/thunderdome/green
	icon_state = "td_belt-green"

/obj/item/weapon/storage/belt/thunderdome/red
	icon_state = "td_belt-red"

/obj/item/weapon/storage/belt/security/doomguy
	name = "Doomguy's belt"
	desc = ""
	icon_state = "doom"
	item_state = "doom"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
