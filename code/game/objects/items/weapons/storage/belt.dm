/obj/item/weapon/storage/belt
	name = "belt"
	desc = "Can hold various things."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "utilitybelt"
	item_state = "utility"
	slot_flags = SLOT_BELT
	attack_verb = list("whipped", "lashed", "disciplined")
	obj_integrity = 300
	max_integrity = 300

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
		/obj/item/clothing/gloves
		)

/obj/item/weapon/storage/belt/utility/chief
	name = "Chief Engineer's toolbelt"
	desc = "Holds tools, looks snazzy"
	icon_state = "utilitybelt_ce"
	item_state = "utility_ce"

/obj/item/weapon/storage/belt/utility/chief/full/PopulateContents()
	new /obj/item/weapon/screwdriver/power(src)
	new /obj/item/weapon/crowbar/power(src)
	new /obj/item/weapon/weldingtool/experimental(src)//This can be changed if this is too much
	new /obj/item/device/multitool(src)
	new /obj/item/stack/cable_coil(src,30,pick("red","yellow","orange"))
	new /obj/item/weapon/extinguisher/mini(src)
	new /obj/item/device/analyzer(src)
	//much roomier now that we've managed to remove two tools


/obj/item/weapon/storage/belt/utility/full/PopulateContents()
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/weldingtool(src)
	new /obj/item/weapon/crowbar(src)
	new /obj/item/weapon/wirecutters(src)
	new /obj/item/device/multitool(src)
	new /obj/item/stack/cable_coil(src,30,pick("red","yellow","orange"))


/obj/item/weapon/storage/belt/utility/atmostech/PopulateContents()
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
	max_w_class = WEIGHT_CLASS_BULKY
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
		/obj/item/clothing/neck/stethoscope,
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
	max_w_class = WEIGHT_CLASS_NORMAL //Because the baton wouldn't fit otherwise. - Neerti
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

/obj/item/weapon/storage/belt/security/full/PopulateContents()
	new /obj/item/weapon/reagent_containers/spray/pepper(src)
	new /obj/item/weapon/restraints/handcuffs(src)
	new /obj/item/weapon/grenade/flashbang(src)
	new /obj/item/device/assembly/flash/handheld(src)
	new /obj/item/weapon/melee/baton/loaded(src)
	update_icon()


/obj/item/weapon/storage/belt/mining
	name = "explorer's webbing"
	desc = "A versatile chest rig, cherished by miners and hunters alike."
	icon_state = "explorer1"
	item_state = "explorer1"
	storage_slots = 6
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_BULKY //Pickaxes are big.
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
		/obj/item/weapon/reagent_containers/food/drinks,
		/obj/item/organ/regenerative_core,
		/obj/item/device/wormhole_jaunter,
		/obj/item/weapon/storage/bag/plants,
		/obj/item/stack/marker_beacon
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

/obj/item/weapon/storage/belt/soulstone/full/PopulateContents()
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
	name = "chest rig"
	desc = "A set of tactical webbing worn by Syndicate boarding parties."
	icon_state = "militarywebbing"
	item_state = "militarywebbing"
	max_w_class = WEIGHT_CLASS_SMALL

/obj/item/weapon/storage/belt/military/abductor
	name = "agent belt"
	desc = "A belt used by abductor agents."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "belt"
	item_state = "security"

/obj/item/weapon/storage/belt/military/abductor/full/PopulateContents()
	new /obj/item/weapon/screwdriver/abductor(src)
	new /obj/item/weapon/wrench/abductor(src)
	new /obj/item/weapon/weldingtool/abductor(src)
	new /obj/item/weapon/crowbar/abductor(src)
	new /obj/item/weapon/wirecutters/abductor(src)
	new /obj/item/device/multitool/abductor(src)
	new /obj/item/stack/cable_coil(src,30,"white")


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
	max_w_class = WEIGHT_CLASS_BULKY
	display_contents_with_number = TRUE
	storage_slots = 30
	max_combined_w_class = 60 //needs to be this high
	can_hold = list(
		/obj/item/weapon/grenade,
		/obj/item/weapon/screwdriver,
		/obj/item/weapon/lighter,
		/obj/item/device/multitool,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/molotov,
		/obj/item/weapon/grenade/plastic/c4,
		)
/obj/item/weapon/storage/belt/grenade/full/PopulateContents()
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

/obj/item/weapon/storage/belt/wands/full/PopulateContents()
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
	max_w_class = WEIGHT_CLASS_BULKY // Set to this so the  light replacer can fit.
	can_hold = list(
		/obj/item/weapon/grenade/chem_grenade,
		/obj/item/device/lightreplacer,
		/obj/item/device/flashlight,
		/obj/item/weapon/reagent_containers/spray,
		/obj/item/weapon/soap,
		/obj/item/weapon/holosign_creator,
		/obj/item/key/janitor,
		/obj/item/clothing/gloves
		)

/obj/item/weapon/storage/belt/bandolier
	name = "bandolier"
	desc = "A bandolier for holding shotgun ammunition."
	icon_state = "bandolier"
	item_state = "bandolier"
	storage_slots = 18
	display_contents_with_number = TRUE
	can_hold = list(
		/obj/item/ammo_casing/shotgun
		)

/obj/item/weapon/storage/belt/holster
	name = "shoulder holster"
	desc = "A holster to carry a handgun and ammo. WARNING: Badasses only."
	icon_state = "holster"
	item_state = "holster"
	storage_slots = 3
	max_w_class = WEIGHT_CLASS_NORMAL
	can_hold = list(
		/obj/item/weapon/gun/ballistic/automatic/pistol,
		/obj/item/weapon/gun/ballistic/revolver,
		/obj/item/ammo_box,
		)
	alternate_worn_layer = UNDER_SUIT_LAYER

/obj/item/weapon/storage/belt/holster/full/PopulateContents()
	new /obj/item/weapon/gun/ballistic/revolver/detective(src)
	new /obj/item/ammo_box/c38(src)
	new /obj/item/ammo_box/c38(src)

/obj/item/weapon/storage/belt/fannypack
	name = "fannypack"
	desc = "A dorky fannypack for keeping small items in."
	icon_state = "fannypack_leather"
	item_state = "fannypack_leather"
	storage_slots = 3
	max_w_class = WEIGHT_CLASS_SMALL

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

/obj/item/weapon/storage/belt/sabre
	name = "sabre sheath"
	desc = "An ornate sheath designed to hold an officer's blade."
	icon_state = "sheath"
	item_state = "sheath"
	storage_slots = 1
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_BULKY
	can_hold = list(
		/obj/item/weapon/melee/sabre
		)

/obj/item/weapon/storage/belt/sabre/examine(mob/user)
	..()
	if(contents.len)
		to_chat(user, "<span class='notice'>Alt-click it to quickly draw the blade.</span>")

/obj/item/weapon/storage/belt/sabre/AltClick(mob/user)
	if(!ishuman(user) || !user.canUseTopic(src, be_close=TRUE))
		return
	if(contents.len)
		var/obj/item/I = contents[1]
		user.visible_message("[user] takes [I] out of [src].", "<span class='notice'>You take [I] out of [src].</span>",\
		)
		user.put_in_hands(I)
		update_icon()
	else
		to_chat(user, "[src] is empty.")

/obj/item/weapon/storage/belt/sabre/update_icon()
	icon_state = "sheath"
	item_state = "sheath"
	if(contents.len)
		icon_state += "-sabre"
		item_state += "-sabre"
	if(loc && isliving(loc))
		var/mob/living/L = loc
		L.regenerate_icons()
	..()


/obj/item/weapon/storage/belt/sabre/PopulateContents()
	new /obj/item/weapon/melee/sabre(src)
	update_icon()
