/obj/item/storage/belt
	name = "belt"
	desc = "Can hold various things."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "utilitybelt"
	item_state = "utility"
	lefthand_file = 'icons/mob/inhands/equipment/belt_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/belt_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	attack_verb = list("whipped", "lashed", "disciplined")
	max_integrity = 300
	var/content_overlays = FALSE //If this is true, the belt will gain overlays based on what it's holding

/obj/item/storage/belt/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins belting [user.p_them()]self with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/storage/belt/update_icon()
	cut_overlays()
	if(content_overlays)
		for(var/obj/item/I in contents)
			var/mutable_appearance/M = I.get_belt_overlay()
			add_overlay(M)
	..()

/obj/item/storage/belt/Initialize()
	. = ..()
	update_icon()

/obj/item/storage/belt/utility
	name = "toolbelt" //Carn: utility belt is nicer, but it bamboozles the text parsing.
	desc = "Holds tools."
	icon_state = "utilitybelt"
	item_state = "utility"
	content_overlays = TRUE

/obj/item/storage/belt/utility/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	var/static/list/can_hold = typecacheof(list(
		/obj/item/crowbar,
		/obj/item/screwdriver,
		/obj/item/weldingtool,
		/obj/item/wirecutters,
		/obj/item/wrench,
		/obj/item/multitool,
		/obj/item/flashlight,
		/obj/item/stack/cable_coil,
		/obj/item/t_scanner,
		/obj/item/analyzer,
		/obj/item/geiger_counter,
		/obj/item/extinguisher/mini,
		/obj/item/radio,
		/obj/item/clothing/gloves,
		/obj/item/holosign_creator,
		/obj/item/assembly/signaler
		))
	STR.can_hold = can_hold

/obj/item/storage/belt/utility/chief
	name = "\improper Chief Engineer's toolbelt" //"the Chief Engineer's toolbelt", because "Chief Engineer's toolbelt" is not a proper noun
	desc = "Holds tools, looks snazzy."
	icon_state = "utilitybelt_ce"
	item_state = "utility_ce"

/obj/item/storage/belt/utility/chief/full/PopulateContents()
	new /obj/item/screwdriver/power(src)
	new /obj/item/crowbar/power(src)
	new /obj/item/weldingtool/experimental(src)//This can be changed if this is too much
	new /obj/item/multitool(src)
	new /obj/item/stack/cable_coil(src,30,pick("red","yellow","orange"))
	new /obj/item/extinguisher/mini(src)
	new /obj/item/analyzer(src)
	//much roomier now that we've managed to remove two tools

/obj/item/storage/belt/utility/full/PopulateContents()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/wirecutters(src)
	new /obj/item/multitool(src)
	new /obj/item/stack/cable_coil(src,30,pick("red","yellow","orange"))

/obj/item/storage/belt/utility/full/engi/PopulateContents()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool/largetank(src)
	new /obj/item/crowbar(src)
	new /obj/item/wirecutters(src)
	new /obj/item/multitool(src)
	new /obj/item/stack/cable_coil(src,30,pick("red","yellow","orange"))


/obj/item/storage/belt/utility/atmostech/PopulateContents()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/wirecutters(src)
	new /obj/item/t_scanner(src)
	new /obj/item/extinguisher/mini(src)

/obj/item/storage/belt/utility/servant/PopulateContents()
	new /obj/item/screwdriver/brass(src)
	new /obj/item/wirecutters/brass(src)
	new /obj/item/wrench/brass(src)
	new /obj/item/crowbar/brass(src)
	new /obj/item/weldingtool/experimental/brass(src)
	new /obj/item/multitool(src)
	new /obj/item/stack/cable_coil(src, 30, "yellow")

/obj/item/storage/belt/medical
	name = "medical belt"
	desc = "Can hold various medical equipment."
	icon_state = "medicalbelt"
	item_state = "medical"

/obj/item/storage/belt/medical/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_BULKY
	STR.can_hold = typecacheof(list(
		/obj/item/healthanalyzer,
		/obj/item/dnainjector,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/medspray,
		/obj/item/lighter,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/pill_bottle,
		/obj/item/stack/medical,
		/obj/item/flashlight/pen,
		/obj/item/extinguisher/mini,
		/obj/item/reagent_containers/hypospray,
		/obj/item/sensor_device,
		/obj/item/radio,
		/obj/item/clothing/gloves/,
		/obj/item/lazarus_injector,
		/obj/item/bikehorn/rubberducky,
		/obj/item/clothing/mask/surgical,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/breath/medical,
		/obj/item/surgical_drapes, //for true paramedics
		/obj/item/scalpel,
		/obj/item/circular_saw,
		/obj/item/surgicaldrill,
		/obj/item/retractor,
		/obj/item/cautery,
		/obj/item/hemostat,
		/obj/item/geiger_counter,
		/obj/item/clothing/neck/stethoscope,
		/obj/item/stamp,
		/obj/item/clothing/glasses,
		/obj/item/wrench/medical,
		/obj/item/clothing/mask/muzzle,
		/obj/item/storage/bag/chemistry,
		/obj/item/storage/bag/bio,
		/obj/item/reagent_containers/blood,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/gun/syringe/syndicate,
		/obj/item/implantcase,
		/obj/item/implant,
		/obj/item/implanter,
		/obj/item/pinpointer/crew
		))

/obj/item/storage/belt/security
	name = "security belt"
	desc = "Can hold security gear like handcuffs and flashes."
	icon_state = "securitybelt"
	item_state = "security"//Could likely use a better one.
	content_overlays = TRUE

/obj/item/storage/belt/security/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 5
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.can_hold = typecacheof(list(
		/obj/item/melee/baton,
		/obj/item/melee/classic_baton,
		/obj/item/grenade,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash/handheld,
		/obj/item/clothing/glasses,
		/obj/item/ammo_casing/shotgun,
		/obj/item/ammo_box,
		/obj/item/reagent_containers/food/snacks/donut,
		/obj/item/kitchen/knife/combat,
		/obj/item/flashlight/seclite,
		/obj/item/melee/classic_baton/telescopic,
		/obj/item/radio,
		/obj/item/clothing/gloves,
		/obj/item/restraints/legcuffs/bola
		))

/obj/item/storage/belt/security/full/PopulateContents()
	new /obj/item/reagent_containers/spray/pepper(src)
	new /obj/item/restraints/handcuffs(src)
	new /obj/item/grenade/flashbang(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/melee/baton/loaded(src)
	update_icon()

/obj/item/storage/belt/mining
	name = "explorer's webbing"
	desc = "A versatile chest rig, cherished by miners and hunters alike."
	icon_state = "explorer1"
	item_state = "explorer1"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/belt/mining/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 6
	STR.max_w_class = WEIGHT_CLASS_BULKY
	STR.max_combined_w_class = 20
	STR.can_hold = typecacheof(list(
		/obj/item/crowbar,
		/obj/item/screwdriver,
		/obj/item/weldingtool,
		/obj/item/wirecutters,
		/obj/item/wrench,
		/obj/item/multitool,
		/obj/item/flashlight,
		/obj/item/stack/cable_coil,
		/obj/item/analyzer,
		/obj/item/extinguisher/mini,
		/obj/item/radio,
		/obj/item/clothing/gloves,
		/obj/item/resonator,
		/obj/item/mining_scanner,
		/obj/item/pickaxe,
		/obj/item/stack/sheet/animalhide,
		/obj/item/stack/sheet/sinew,
		/obj/item/stack/sheet/bone,
		/obj/item/lighter,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/reagent_containers/food/drinks/bottle,
		/obj/item/stack/medical,
		/obj/item/kitchen/knife,
		/obj/item/reagent_containers/hypospray,
		/obj/item/gps,
		/obj/item/storage/bag/ore,
		/obj/item/survivalcapsule,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/reagent_containers/pill,
		/obj/item/storage/pill_bottle,
		/obj/item/stack/ore,
		/obj/item/reagent_containers/food/drinks,
		/obj/item/organ/regenerative_core,
		/obj/item/wormhole_jaunter,
		/obj/item/storage/bag/plants,
		/obj/item/stack/marker_beacon
		))


/obj/item/storage/belt/mining/vendor
	contents = newlist(/obj/item/survivalcapsule)

/obj/item/storage/belt/mining/alt
	icon_state = "explorer2"
	item_state = "explorer2"

/obj/item/storage/belt/mining/primitive
	name = "hunter's belt"
	desc = "A versatile belt, woven from sinew."
	icon_state = "ebelt"
	item_state = "ebelt"

/obj/item/storage/belt/mining/primitive/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 5

/obj/item/storage/belt/soulstone
	name = "soul stone belt"
	desc = "Designed for ease of access to the shards during a fight, as to not let a single enemy spirit slip away."
	icon_state = "soulstonebelt"
	item_state = "soulstonebelt"

/obj/item/storage/belt/soulstone/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 6
	STR.can_hold = typecacheof(list(
		/obj/item/soulstone
		))

/obj/item/storage/belt/soulstone/full/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/soulstone(src)

/obj/item/storage/belt/soulstone/full/chappy/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/soulstone/anybody/chaplain(src)

/obj/item/storage/belt/champion
	name = "championship belt"
	desc = "Proves to the world that you are the strongest!"
	icon_state = "championbelt"
	item_state = "champion"
	materials = list(MAT_GOLD=400)

/obj/item/storage/belt/champion/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 1
	STR.can_hold = list(
		/obj/item/clothing/mask/luchador
		)

/obj/item/storage/belt/military
	name = "chest rig"
	desc = "A set of tactical webbing worn by Syndicate boarding parties."
	icon_state = "militarywebbing"
	item_state = "militarywebbing"

/obj/item/storage/belt/military/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/belt/military/snack
	name = "tactical snack rig"

/obj/item/storage/belt/military/snack/Initialize()
	. = ..()
	var/sponsor = pick("DonkCo", "Waffle Co.", "Roffle Co.", "Gorlax Marauders", "Tiger Cooperative")
	desc = "A set of snack-tical webbing worn by athletes of the [sponsor] VR sports division."

/obj/item/storage/belt/military/snack/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 6
	STR.max_w_class = WEIGHT_CLASS_SMALL
	STR.can_hold = typecacheof(list(
		/obj/item/reagent_containers/food/snacks,
		/obj/item/reagent_containers/food/drinks
		))
	
	var/amount = 5
	var/rig_snacks
	while(contents.len <= amount)
		rig_snacks = pick(list(
		/obj/item/reagent_containers/food/snacks/candy,
		/obj/item/reagent_containers/food/drinks/dry_ramen,
		/obj/item/reagent_containers/food/snacks/chips,
		/obj/item/reagent_containers/food/snacks/sosjerky,
		/obj/item/reagent_containers/food/snacks/syndicake,
		/obj/item/reagent_containers/food/snacks/spacetwinkie,
		/obj/item/reagent_containers/food/snacks/cheesiehonkers,
		/obj/item/reagent_containers/food/snacks/nachos,
		/obj/item/reagent_containers/food/snacks/cheesynachos,
		/obj/item/reagent_containers/food/snacks/cubannachos,
		/obj/item/reagent_containers/food/snacks/nugget,
		/obj/item/reagent_containers/food/snacks/pastatomato,
		/obj/item/reagent_containers/food/snacks/rofflewaffles,
		/obj/item/reagent_containers/food/snacks/donkpocket,
		/obj/item/reagent_containers/food/drinks/soda_cans/cola,
		/obj/item/reagent_containers/food/drinks/soda_cans/space_mountain_wind,
		/obj/item/reagent_containers/food/drinks/soda_cans/dr_gibb,
		/obj/item/reagent_containers/food/drinks/soda_cans/starkist,
		/obj/item/reagent_containers/food/drinks/soda_cans/space_up,
		/obj/item/reagent_containers/food/drinks/soda_cans/pwr_game,
		/obj/item/reagent_containers/food/drinks/soda_cans/lemon_lime,
		/obj/item/reagent_containers/food/drinks/drinkingglass/filled/nuka_cola
		))
		new rig_snacks(src)

/obj/item/storage/belt/military/abductor
	name = "agent belt"
	desc = "A belt used by abductor agents."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "belt"
	item_state = "security"

/obj/item/storage/belt/military/abductor/full/PopulateContents()
	new /obj/item/screwdriver/abductor(src)
	new /obj/item/wrench/abductor(src)
	new /obj/item/weldingtool/abductor(src)
	new /obj/item/crowbar/abductor(src)
	new /obj/item/wirecutters/abductor(src)
	new /obj/item/multitool/abductor(src)
	new /obj/item/stack/cable_coil(src,30,"white")

/obj/item/storage/belt/military/army
	name = "army belt"
	desc = "A belt used by military forces."
	icon_state = "grenadebeltold"
	item_state = "security"

/obj/item/storage/belt/military/assault
	name = "assault belt"
	desc = "A tactical assault belt."
	icon_state = "assaultbelt"
	item_state = "security"

/obj/item/storage/belt/military/assault/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 6

/obj/item/storage/belt/grenade
	name = "grenadier belt"
	desc = "A belt for holding grenades."
	icon_state = "grenadebeltnew"
	item_state = "security"

/obj/item/storage/belt/grenade/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 30
	STR.display_numerical_stacking = TRUE
	STR.max_combined_w_class = 60
	STR.max_w_class = WEIGHT_CLASS_BULKY
	STR.can_hold = typecacheof(list(
		/obj/item/grenade,
		/obj/item/screwdriver,
		/obj/item/lighter,
		/obj/item/multitool,
		/obj/item/reagent_containers/food/drinks/bottle/molotov,
		/obj/item/grenade/plastic/c4,
		))

/obj/item/storage/belt/grenade/full/PopulateContents()
	new /obj/item/grenade/flashbang(src)
	new /obj/item/grenade/smokebomb(src)
	new /obj/item/grenade/smokebomb(src)
	new /obj/item/grenade/smokebomb(src)
	new /obj/item/grenade/smokebomb(src)
	new /obj/item/grenade/empgrenade(src)
	new /obj/item/grenade/empgrenade(src)
	new /obj/item/grenade/syndieminibomb/concussion/frag(src)
	new /obj/item/grenade/syndieminibomb/concussion/frag(src)
	new /obj/item/grenade/syndieminibomb/concussion/frag(src)
	new /obj/item/grenade/syndieminibomb/concussion/frag(src)
	new /obj/item/grenade/syndieminibomb/concussion/frag(src)
	new /obj/item/grenade/syndieminibomb/concussion/frag(src)
	new /obj/item/grenade/syndieminibomb/concussion/frag(src)
	new /obj/item/grenade/syndieminibomb/concussion/frag(src)
	new /obj/item/grenade/syndieminibomb/concussion/frag(src)
	new /obj/item/grenade/syndieminibomb/concussion/frag(src)
	new /obj/item/grenade/gluon(src)
	new /obj/item/grenade/gluon(src)
	new /obj/item/grenade/gluon(src)
	new /obj/item/grenade/gluon(src)
	new /obj/item/grenade/chem_grenade/incendiary(src)
	new /obj/item/grenade/chem_grenade/incendiary(src)
	new /obj/item/grenade/chem_grenade/facid(src)
	new /obj/item/grenade/syndieminibomb(src)
	new /obj/item/grenade/syndieminibomb(src)
	new /obj/item/screwdriver(src)
	new /obj/item/multitool(src)

/obj/item/storage/belt/wands
	name = "wand belt"
	desc = "A belt designed to hold various rods of power. A veritable fanny pack of exotic magic."
	icon_state = "soulstonebelt"
	item_state = "soulstonebelt"

/obj/item/storage/belt/wands/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 6
	STR.can_hold = typecacheof(list(
		/obj/item/gun/magic/wand
		))

/obj/item/storage/belt/wands/full/PopulateContents()
	new /obj/item/gun/magic/wand/death(src)
	new /obj/item/gun/magic/wand/resurrection(src)
	new /obj/item/gun/magic/wand/polymorph(src)
	new /obj/item/gun/magic/wand/teleport(src)
	new /obj/item/gun/magic/wand/door(src)
	new /obj/item/gun/magic/wand/fireball(src)

	for(var/obj/item/gun/magic/wand/W in contents) //All wands in this pack come in the best possible condition
		W.max_charges = initial(W.max_charges)
		W.charges = W.max_charges

/obj/item/storage/belt/janitor
	name = "janibelt"
	desc = "A belt used to hold most janitorial supplies."
	icon_state = "janibelt"
	item_state = "janibelt"

/obj/item/storage/belt/janitor/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 6
	STR.max_w_class = WEIGHT_CLASS_BULKY // Set to this so the  light replacer can fit.
	STR.can_hold = typecacheof(list(
		/obj/item/grenade/chem_grenade,
		/obj/item/lightreplacer,
		/obj/item/flashlight,
		/obj/item/reagent_containers/spray,
		/obj/item/soap,
		/obj/item/holosign_creator,
		/obj/item/key/janitor,
		/obj/item/clothing/gloves,
		/obj/item/melee/flyswatter,
		/obj/item/assembly/mousetrap
		))

/obj/item/storage/belt/bandolier
	name = "bandolier"
	desc = "A bandolier for holding shotgun ammunition."
	icon_state = "bandolier"
	item_state = "bandolier"

/obj/item/storage/belt/bandolier/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 18
	STR.display_numerical_stacking = TRUE
	STR.can_hold = typecacheof(list(
		/obj/item/ammo_casing/shotgun
		))

/obj/item/storage/belt/holster
	name = "shoulder holster"
	desc = "A holster to carry a handgun and ammo. WARNING: Badasses only."
	icon_state = "holster"
	item_state = "holster"
	alternate_worn_layer = UNDER_SUIT_LAYER

/obj/item/storage/belt/holster/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 3
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.can_hold = typecacheof(list(
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/gun/ballistic/revolver,
		/obj/item/ammo_box,
		))

/obj/item/storage/belt/holster/full/PopulateContents()
	new /obj/item/gun/ballistic/revolver/detective(src)
	new /obj/item/ammo_box/c38(src)
	new /obj/item/ammo_box/c38(src)

/obj/item/storage/belt/fannypack
	name = "fannypack"
	desc = "A dorky fannypack for keeping small items in."
	icon_state = "fannypack_leather"
	item_state = "fannypack_leather"

/obj/item/storage/belt/fannypack/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 3
	STR.max_w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/belt/fannypack/black
	name = "black fannypack"
	icon_state = "fannypack_black"
	item_state = "fannypack_black"

/obj/item/storage/belt/fannypack/red
	name = "red fannypack"
	icon_state = "fannypack_red"
	item_state = "fannypack_red"

/obj/item/storage/belt/fannypack/purple
	name = "purple fannypack"
	icon_state = "fannypack_purple"
	item_state = "fannypack_purple"

/obj/item/storage/belt/fannypack/blue
	name = "blue fannypack"
	icon_state = "fannypack_blue"
	item_state = "fannypack_blue"

/obj/item/storage/belt/fannypack/orange
	name = "orange fannypack"
	icon_state = "fannypack_orange"
	item_state = "fannypack_orange"

/obj/item/storage/belt/fannypack/white
	name = "white fannypack"
	icon_state = "fannypack_white"
	item_state = "fannypack_white"

/obj/item/storage/belt/fannypack/green
	name = "green fannypack"
	icon_state = "fannypack_green"
	item_state = "fannypack_green"

/obj/item/storage/belt/fannypack/pink
	name = "pink fannypack"
	icon_state = "fannypack_pink"
	item_state = "fannypack_pink"

/obj/item/storage/belt/fannypack/cyan
	name = "cyan fannypack"
	icon_state = "fannypack_cyan"
	item_state = "fannypack_cyan"

/obj/item/storage/belt/fannypack/yellow
	name = "yellow fannypack"
	icon_state = "fannypack_yellow"
	item_state = "fannypack_yellow"

/obj/item/storage/belt/sabre
	name = "sabre sheath"
	desc = "An ornate sheath designed to hold an officer's blade."
	icon_state = "sheath"
	item_state = "sheath"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/belt/sabre/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 1
	STR.rustle_sound = FALSE
	STR.max_w_class = WEIGHT_CLASS_BULKY
	STR.can_hold = typecacheof(list(
		/obj/item/melee/sabre
		))

/obj/item/storage/belt/sabre/examine(mob/user)
	..()
	if(length(contents))
		to_chat(user, "<span class='notice'>Alt-click it to quickly draw the blade.</span>")

/obj/item/storage/belt/sabre/AltClick(mob/user)
	if(!iscarbon(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	if(length(contents))
		var/obj/item/I = contents[1]
		user.visible_message("[user] takes [I] out of [src].", "<span class='notice'>You take [I] out of [src].</span>")
		user.put_in_hands(I)
		update_icon()
	else
		to_chat(user, "[src] is empty.")

/obj/item/storage/belt/sabre/update_icon()
	icon_state = "sheath"
	item_state = "sheath"
	if(contents.len)
		icon_state += "-sabre"
		item_state += "-sabre"
	if(loc && isliving(loc))
		var/mob/living/L = loc
		L.regenerate_icons()
	..()

/obj/item/storage/belt/sabre/PopulateContents()
	new /obj/item/melee/sabre(src)
	update_icon()
