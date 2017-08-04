/*
 *	Everything derived from the common cardboard box.
 *	Basically everything except the original is a kit (starts full).
 *
 *	Contains:
 *		Empty box, starter boxes (survival/engineer),
 *		Latex glove and sterile mask boxes,
 *		Syringe, beaker, dna injector boxes,
 *		Blanks, flashbangs, and EMP grenade boxes,
 *		Tracking and chemical implant boxes,
 *		Prescription glasses and drinking glass boxes,
 *		Condiment bottle and silly cup boxes,
 *		Donkpocket and monkeycube boxes,
 *		ID and security PDA cart boxes,
 *		Handcuff, mousetrap, and pillbottle boxes,
 *		Snap-pops and matchboxes,
 *		Replacement light boxes.
 *		Action Figure Boxes
 *		Various paper bags.
 *
 *		For syndicate call-ins see uplink_kits.dm
 */

/obj/item/weapon/storage/box
	name = "box"
	desc = "It's just an ordinary box."
	icon_state = "box"
	item_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	resistance_flags = FLAMMABLE
	var/foldable = /obj/item/stack/sheet/cardboard
	var/illustration = "writing"

/obj/item/weapon/storage/box/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/weapon/storage/box/update_icon()
	. = ..()
	if(illustration)
		cut_overlays()
		add_overlay(illustration)

/obj/item/weapon/storage/box/attack_self(mob/user)
	..()

	if(!foldable)
		return
	if(contents.len)
		to_chat(user, "<span class='warning'>You can't fold this box with items still inside!</span>")
		return
	if(!ispath(foldable))
		return

	//Close any open UI windows first
	close_all()

	to_chat(user, "<span class='notice'>You fold [src] flat.</span>")
	var/obj/item/I = new foldable(get_turf(src))
	user.drop_item()
	user.put_in_hands(I)
	user.update_inv_hands()
	qdel(src)

/obj/item/weapon/storage/box/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/packageWrap))
		return 0
	return ..()


//Disk boxes
/obj/item/weapon/storage/box/disks
	name = "diskette box"
	illustration = "disk_kit"

/obj/item/weapon/storage/box/disks/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/disk/data(src)


/obj/item/weapon/storage/box/disks_plantgene
	name = "plant data disks box"
	illustration = "disk_kit"

/obj/item/weapon/storage/box/disks_plantgene/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/disk/plantgene(src)

// Ordinary survival box
/obj/item/weapon/storage/box/survival/PopulateContents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/weapon/tank/internals/emergency_oxygen(src)
	new /obj/item/weapon/reagent_containers/hypospray/medipen(src)

/obj/item/weapon/storage/box/survival/radio/PopulateContents()
	..() // we want the survival stuff too.
	new /obj/item/device/radio/off(src)

/obj/item/weapon/storage/box/survival_mining/PopulateContents()
	new /obj/item/clothing/mask/gas/explorer(src)
	new /obj/item/weapon/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/weapon/crowbar/red(src)
	new /obj/item/weapon/reagent_containers/hypospray/medipen(src)


// Engineer survival box
/obj/item/weapon/storage/box/engineer/PopulateContents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/weapon/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/weapon/reagent_containers/hypospray/medipen(src)

/obj/item/weapon/storage/box/engineer/radio/PopulateContents()
	..() // we want the regular items too.
	new /obj/item/device/radio/off(src)

// Syndie survival box
/obj/item/weapon/storage/box/syndie/PopulateContents()
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/weapon/tank/internals/emergency_oxygen/engi(src)

// Security survival box
/obj/item/weapon/storage/box/security/PopulateContents()
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/weapon/tank/internals/emergency_oxygen(src)
	new /obj/item/weapon/reagent_containers/hypospray/medipen(src)

/obj/item/weapon/storage/box/security/radio/PopulateContents()
	..() // we want the regular stuff too
	new /obj/item/device/radio/off(src)

/obj/item/weapon/storage/box/gloves
	name = "box of latex gloves"
	desc = "Contains sterile latex gloves."
	illustration = "latex"

/obj/item/weapon/storage/box/gloves/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/clothing/gloves/color/latex(src)

/obj/item/weapon/storage/box/masks
	name = "box of sterile masks"
	desc = "This box contains sterile medical masks."
	illustration = "sterile"

/obj/item/weapon/storage/box/masks/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/clothing/mask/surgical(src)

/obj/item/weapon/storage/box/syringes
	name = "box of syringes"
	desc = "A box full of syringes."
	illustration = "syringe"

/obj/item/weapon/storage/box/syringes/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/reagent_containers/syringe(src)

/obj/item/weapon/storage/box/medipens
	name = "box of medipens"
	desc = "A box full of epinephrine MediPens."
	illustration = "syringe"

/obj/item/weapon/storage/box/medipens/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/reagent_containers/hypospray/medipen(src)

/obj/item/weapon/storage/box/medipens/utility
	name = "stimpack value kit"
	desc = "A box with several stimpack medipens for the economical miner."
	illustration = "syringe"

/obj/item/weapon/storage/box/medipens/utility/PopulateContents()
	..() // includes regular medipens.
	for(var/i in 1 to 5)
		new /obj/item/weapon/reagent_containers/hypospray/medipen/stimpack(src)

/obj/item/weapon/storage/box/beakers
	name = "box of beakers"
	illustration = "beaker"

/obj/item/weapon/storage/box/beakers/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/reagent_containers/glass/beaker( src )

/obj/item/weapon/storage/box/injectors
	name = "box of DNA injectors"
	desc = "This box contains injectors, it seems."

/obj/item/weapon/storage/box/injectors/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/weapon/dnainjector/h2m(src)
	for(var/i in 1 to 3)
		new /obj/item/weapon/dnainjector/m2h(src)

/obj/item/weapon/storage/box/flashbangs
	name = "box of flashbangs (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause blindness or deafness in repeated use.</B>"
	icon_state = "secbox"
	illustration = "flashbang"

/obj/item/weapon/storage/box/flashbangs/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/grenade/flashbang(src)

/obj/item/weapon/storage/box/flashes
	name = "box of flashbulbs"
	desc = "<B>WARNING: Flashes can cause serious eye damage, protective eyewear is required.</B>"
	icon_state = "secbox"
	illustration = "flashbang"

/obj/item/weapon/storage/box/flashes/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/device/assembly/flash/handheld(src)

/obj/item/weapon/storage/box/wall_flash
	name = "wall-mounted flash kit"
	desc = "This box contains everything necessary to build a wall-mounted flash. <B>WARNING: Flashes can cause serious eye damage, protective eyewear is required.</B>"
	illustration = "flashbang"

/obj/item/weapon/storage/box/wall_flash/PopulateContents()
	var/id = rand(1000, 9999)
	// FIXME what if this conflicts with an existing one?

	new /obj/item/wallframe/button(src)
	new /obj/item/weapon/electronics/airlock(src)
	var/obj/item/device/assembly/control/flasher/remote = new(src)
	remote.id = id
	var/obj/item/wallframe/flasher/frame = new(src)
	frame.id = id
	new /obj/item/device/assembly/flash/handheld(src)
	new /obj/item/weapon/screwdriver(src)


/obj/item/weapon/storage/box/teargas
	name = "box of tear gas grenades (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause blindness and skin irritation.</B>"
	illustration = "flashbang"

/obj/item/weapon/storage/box/teargas/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/grenade/chem_grenade/teargas(src)

/obj/item/weapon/storage/box/emps
	name = "box of emp grenades"
	desc = "A box with 5 emp grenades."
	illustration = "flashbang"

/obj/item/weapon/storage/box/emps/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/weapon/grenade/empgrenade(src)

/obj/item/weapon/storage/box/trackimp
	name = "boxed tracking implant kit"
	desc = "Box full of scum-bag tracking utensils."
	illustration = "implant"

/obj/item/weapon/storage/box/trackimp/PopulateContents()
	for(var/i in 1 to 4)
		new /obj/item/weapon/implantcase/tracking(src)
	new /obj/item/weapon/implanter(src)
	new /obj/item/weapon/implantpad(src)
	new /obj/item/weapon/locator(src)

/obj/item/weapon/storage/box/minertracker
	name = "boxed tracking implant kit"
	desc = "For finding those who have died on the accursed lavaworld."
	illustration = "implant"

/obj/item/weapon/storage/box/minertracker/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/weapon/implantcase/tracking(src)
	new /obj/item/weapon/implanter(src)
	new /obj/item/weapon/implantpad(src)
	new /obj/item/weapon/locator(src)

/obj/item/weapon/storage/box/chemimp
	name = "boxed chemical implant kit"
	desc = "Box of stuff used to implant chemicals."
	illustration = "implant"

/obj/item/weapon/storage/box/chemimp/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/weapon/implantcase/chem(src)
	new /obj/item/weapon/implanter(src)
	new /obj/item/weapon/implantpad(src)

/obj/item/weapon/storage/box/exileimp
	name = "boxed exile implant kit"
	desc = "Box of exile implants. It has a picture of a clown being booted through the Gateway."
	illustration = "implant"

/obj/item/weapon/storage/box/exileimp/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/weapon/implantcase/exile(src)
	new /obj/item/weapon/implanter(src)

/obj/item/weapon/storage/box/bodybags
	name = "body bags"
	desc = "The label indicates that it contains body bags."
	illustration = "bodybags"

/obj/item/weapon/storage/box/bodybags/PopulateContents()
	..()
	for(var/i in 1 to 7)
		new /obj/item/bodybag(src)

/obj/item/weapon/storage/box/rxglasses
	name = "box of prescription glasses"
	desc = "This box contains nerd glasses."
	illustration = "glasses"

/obj/item/weapon/storage/box/rxglasses/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/clothing/glasses/regular(src)

/obj/item/weapon/storage/box/drinkingglasses
	name = "box of drinking glasses"
	desc = "It has a picture of drinking glasses on it."

/obj/item/weapon/storage/box/drinkingglasses/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(src)

/obj/item/weapon/storage/box/condimentbottles
	name = "box of condiment bottles"
	desc = "It has a large ketchup smear on it."

/obj/item/weapon/storage/box/condimentbottles/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/weapon/reagent_containers/food/condiment(src)

/obj/item/weapon/storage/box/cups
	name = "box of paper cups"
	desc = "It has pictures of paper cups on the front."

/obj/item/weapon/storage/box/cups/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )

/obj/item/weapon/storage/box/donkpockets
	name = "box of donk-pockets"
	desc = "<B>Instructions:</B> <I>Heat in microwave. Product will cool if not eaten within seven minutes.</I>"
	illustration = "donk_kit"

/obj/item/weapon/storage/box/donkpockets/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)

/obj/item/weapon/storage/box/monkeycubes
	name = "monkey cube box"
	desc = "Drymate brand monkey cubes. Just add water!"
	icon_state = "monkeycubebox"
	storage_slots = 7
	can_hold = list(/obj/item/weapon/reagent_containers/food/snacks/monkeycube)
	illustration = null

/obj/item/weapon/storage/box/monkeycubes/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/weapon/reagent_containers/food/snacks/monkeycube(src)

/obj/item/weapon/storage/box/ids
	name = "box of spare IDs"
	desc = "Has so many empty IDs."
	illustration = "id"

/obj/item/weapon/storage/box/ids/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/card/id(src)

//Some spare PDAs in a box
/obj/item/weapon/storage/box/PDAs
	name = "spare PDAs"
	desc = "A box of spare PDA microcomputers."
	illustration = "pda"

/obj/item/weapon/storage/box/PDAs/PopulateContents()
	new /obj/item/device/pda(src)
	new /obj/item/device/pda(src)
	new /obj/item/device/pda(src)
	new /obj/item/device/pda(src)
	new /obj/item/weapon/cartridge/head(src)

	var/newcart = pick(	/obj/item/weapon/cartridge/engineering,
						/obj/item/weapon/cartridge/security,
						/obj/item/weapon/cartridge/medical,
						/obj/item/weapon/cartridge/signal/toxins,
						/obj/item/weapon/cartridge/quartermaster)
	new newcart(src)

/obj/item/weapon/storage/box/silver_ids
	name = "box of spare silver IDs"
	desc = "Shiny IDs for important people."
	illustration = "id"

/obj/item/weapon/storage/box/silver_ids/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/card/id/silver(src)

/obj/item/weapon/storage/box/prisoner
	name = "box of prisoner IDs"
	desc = "Take away their last shred of dignity, their name."
	illustration = "id"

/obj/item/weapon/storage/box/prisoner/PopulateContents()
	..()
	new /obj/item/weapon/card/id/prisoner/one(src)
	new /obj/item/weapon/card/id/prisoner/two(src)
	new /obj/item/weapon/card/id/prisoner/three(src)
	new /obj/item/weapon/card/id/prisoner/four(src)
	new /obj/item/weapon/card/id/prisoner/five(src)
	new /obj/item/weapon/card/id/prisoner/six(src)
	new /obj/item/weapon/card/id/prisoner/seven(src)

/obj/item/weapon/storage/box/seccarts
	name = "box of PDA security cartridges"
	desc = "A box full of PDA cartridges used by Security."
	illustration = "pda"

/obj/item/weapon/storage/box/seccarts/PopulateContents()
	new /obj/item/weapon/cartridge/detective(src)
	for(var/i in 1 to 6)
		new /obj/item/weapon/cartridge/security(src)

/obj/item/weapon/storage/box/firingpins
	name = "box of standard firing pins"
	desc = "A box full of standard firing pins, to allow newly-developed firearms to operate."
	illustration = "id"

/obj/item/weapon/storage/box/firingpins/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/device/firing_pin(src)

/obj/item/weapon/storage/box/lasertagpins
	name = "box of laser tag firing pins"
	desc = "A box full of laser tag firing pins, to allow newly-developed firearms to require wearing brightly coloured plastic armor before being able to be used."
	illustration = "id"

/obj/item/weapon/storage/box/lasertagpins/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/device/firing_pin/tag/red(src)
		new /obj/item/device/firing_pin/tag/blue(src)

/obj/item/weapon/storage/box/handcuffs
	name = "box of spare handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "secbox"
	illustration = "handcuff"

/obj/item/weapon/storage/box/handcuffs/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/restraints/handcuffs(src)

/obj/item/weapon/storage/box/zipties
	name = "box of spare zipties"
	desc = "A box full of zipties."
	icon_state = "secbox"
	illustration = "handcuff"

/obj/item/weapon/storage/box/zipties/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/restraints/handcuffs/cable/zipties(src)

/obj/item/weapon/storage/box/alienhandcuffs
	name = "box of spare handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "alienbox"
	illustration = "handcuff"

/obj/item/weapon/storage/box/alienhandcuffs/PopulateContents()
	for(var/i in 1 to 7)
		new	/obj/item/weapon/restraints/handcuffs/alien(src)

/obj/item/weapon/storage/box/fakesyndiesuit
	name = "boxed space suit and helmet"
	desc = "A sleek, sturdy box used to hold replica spacesuits."
	icon_state = "syndiebox"

/obj/item/weapon/storage/box/fakesyndiesuit/PopulateContents()
	new /obj/item/clothing/head/syndicatefake(src)
	new /obj/item/clothing/suit/syndicatefake(src)

/obj/item/weapon/storage/box/mousetraps
	name = "box of Pest-B-Gon mousetraps"
	desc = "<span class='alert'>Keep out of reach of children.</span>"
	illustration = "mousetraps"

/obj/item/weapon/storage/box/mousetraps/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/device/assembly/mousetrap(src)

/obj/item/weapon/storage/box/pillbottles
	name = "box of pill bottles"
	desc = "It has pictures of pill bottles on its front."
	illustration = "pillbox"

/obj/item/weapon/storage/box/pillbottles/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/storage/pill_bottle(src)

/obj/item/weapon/storage/box/snappops
	name = "snap pop box"
	desc = "Eight wrappers of fun! Ages 8 and up. Not suitable for children."
	icon = 'icons/obj/toy.dmi'
	icon_state = "spbox"
	storage_slots = 8
	can_hold = list(/obj/item/toy/snappop)

/obj/item/weapon/storage/box/snappops/PopulateContents()
	for(var/i in 1 to storage_slots)
		new /obj/item/toy/snappop(src)

/obj/item/weapon/storage/box/matches
	name = "matchbox"
	desc = "A small box of Almost But Not Quite Plasma Premium Matches."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "matchbox"
	item_state = "zippo"
	storage_slots = 10
	w_class = WEIGHT_CLASS_TINY
	slot_flags = SLOT_BELT
	can_hold = list(/obj/item/weapon/match)

/obj/item/weapon/storage/box/matches/PopulateContents()
	for(var/i in 1 to storage_slots)
		new /obj/item/weapon/match(src)

/obj/item/weapon/storage/box/matches/attackby(obj/item/weapon/match/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/match))
		W.matchignite()

/obj/item/weapon/storage/box/lights
	name = "box of replacement bulbs"
	icon = 'icons/obj/storage.dmi'
	illustration = "light"
	desc = "This box is shaped on the inside so that only light tubes and bulbs fit."
	item_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	foldable = /obj/item/stack/sheet/cardboard //BubbleWrap
	storage_slots=21
	can_hold = list(/obj/item/weapon/light/tube, /obj/item/weapon/light/bulb)
	max_combined_w_class = 21
	use_to_pickup = 1 // for picking up broken bulbs, not that most people will try

/obj/item/weapon/storage/box/lights/bulbs/PopulateContents()
	for(var/i in 1 to 21)
		new /obj/item/weapon/light/bulb(src)

/obj/item/weapon/storage/box/lights/tubes
	name = "box of replacement tubes"
	illustration = "lighttube"

/obj/item/weapon/storage/box/lights/tubes/PopulateContents()
	for(var/i in 1 to 21)
		new /obj/item/weapon/light/tube(src)

/obj/item/weapon/storage/box/lights/mixed
	name = "box of replacement lights"
	illustration = "lightmixed"

/obj/item/weapon/storage/box/lights/mixed/PopulateContents()
	for(var/i in 1 to 14)
		new /obj/item/weapon/light/tube(src)
	for(var/i in 1 to 7)
		new /obj/item/weapon/light/bulb(src)


/obj/item/weapon/storage/box/deputy
	name = "box of deputy armbands"
	desc = "To be issued to those authorized to act as deputy of security."

/obj/item/weapon/storage/box/deputy/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/clothing/accessory/armband/deputy(src)

/obj/item/weapon/storage/box/metalfoam
	name = "box of metal foam grenades"
	desc = "To be used to rapidly seal hull breaches."
	illustration = "flashbang"

/obj/item/weapon/storage/box/metalfoam/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/grenade/chem_grenade/metalfoam(src)

/obj/item/weapon/storage/box/hug
	name = "box of hugs"
	desc = "A special box for sensitive people."
	icon_state = "hugbox"
	illustration = "heart"
	foldable = null

/obj/item/weapon/storage/box/hug/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] clamps the box of hugs on [user.p_their()] jugular! Guess it wasn't such a hugbox after all..</span>")
	return (BRUTELOSS)

/obj/item/weapon/storage/box/hug/attack_self(mob/user)
	..()
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(loc, "rustle", 50, 1, -5)
	user.visible_message("<span class='notice'>[user] hugs \the [src].</span>","<span class='notice'>You hug \the [src].</span>")

/obj/item/weapon/storage/box/hug/medical/PopulateContents()
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/ointment(src)
	new /obj/item/weapon/reagent_containers/hypospray/medipen(src)

/obj/item/weapon/storage/box/hug/survival/PopulateContents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/weapon/tank/internals/emergency_oxygen(src)
	new /obj/item/weapon/reagent_containers/hypospray/medipen(src)

/obj/item/weapon/storage/box/rubbershot
	name = "box of rubber shots"
	desc = "A box full of rubber shots, designed for riot shotguns."
	icon_state = "rubbershot_box"
	illustration = null

/obj/item/weapon/storage/box/rubbershot/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/ammo_casing/shotgun/rubbershot(src)

/obj/item/weapon/storage/box/lethalshot
	name = "box of lethal shotgun shots"
	desc = "A box full of lethal shots, designed for riot shotguns."
	icon_state = "lethalshot_box"
	illustration = null

/obj/item/weapon/storage/box/lethalshot/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/ammo_casing/shotgun/buckshot(src)

/obj/item/weapon/storage/box/beanbag
	name = "box of beanbags"
	desc = "A box full of beanbag shells."
	icon_state = "rubbershot_box"
	illustration = null

/obj/item/weapon/storage/box/beanbag/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/ammo_casing/shotgun/beanbag(src)

/obj/item/weapon/storage/box/actionfigure
	name = "box of action figures"
	desc = "The latest set of collectable action figures."
	icon_state = "box"

/obj/item/weapon/storage/box/actionfigure/PopulateContents()
	for(var/i in 1 to 4)
		var/randomFigure = pick(subtypesof(/obj/item/toy/figure))
		new randomFigure(src)

#define NODESIGN "None"
#define NANOTRASEN "NanotrasenStandard"
#define SYNDI "SyndiSnacks"
#define HEART "Heart"
#define SMILE "SmileyFace"

/obj/item/weapon/storage/box/papersack
	name = "paper sack"
	desc = "A sack neatly crafted out of paper."
	icon_state = "paperbag_None"
	item_state = "paperbag_None"
	resistance_flags = FLAMMABLE
	foldable = null
	var/design = NODESIGN

/obj/item/weapon/storage/box/papersack/update_icon()
	if(contents.len == 0)
		icon_state = "[item_state]"
	else icon_state = "[item_state]_closed"

/obj/item/weapon/storage/box/papersack/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/pen))
		//if a pen is used on the sack, dialogue to change its design appears
		if(contents.len)
			to_chat(user, "<span class='warning'>You can't modify this [src] with items still inside!</span>")
			return
		var/list/designs = list(NODESIGN, NANOTRASEN, SYNDI, HEART, SMILE, "Cancel")
		var/switchDesign = input("Select a Design:", "Paper Sack Design", designs[1]) in designs
		if(get_dist(usr, src) > 1)
			to_chat(usr, "<span class='warning'>You have moved too far away!</span>")
			return
		var/choice = designs.Find(switchDesign)
		if(design == designs[choice] || designs[choice] == "Cancel")
			return 0
		to_chat(usr, "<span class='notice'>You make some modifications to the [src] using your pen.</span>")
		design = designs[choice]
		icon_state = "paperbag_[design]"
		item_state = "paperbag_[design]"
		switch(designs[choice])
			if(NODESIGN)
				desc = "A sack neatly crafted out of paper."
			if(NANOTRASEN)
				desc = "A standard Nanotrasen paper lunch sack for loyal employees on the go."
			if(SYNDI)
				desc = "The design on this paper sack is a remnant of the notorious 'SyndieSnacks' program."
			if(HEART)
				desc = "A paper sack with a heart etched onto the side."
			if(SMILE)
				desc = "A paper sack with a crude smile etched onto the side."
		return 0
	else if(W.is_sharp())
		if(!contents.len)
			if(item_state == "paperbag_None")
				user.show_message("<span class='notice'>You cut eyeholes into the [src].</span>", 1)
				new /obj/item/clothing/head/papersack(user.loc)
				qdel(src)
				return 0
			else if(item_state == "paperbag_SmileyFace")
				user.show_message("<span class='notice'>You cut eyeholes into the [src] and modify the design.</span>", 1)
				new /obj/item/clothing/head/papersack/smiley(user.loc)
				qdel(src)
				return 0
	return ..()

#undef NODESIGN
#undef NANOTRASEN
#undef SYNDI
#undef HEART
#undef SMILE

/obj/item/weapon/storage/box/ingredients //This box is for the randomely chosen version the chef spawns with, it shouldn't actually exist.
	name = "ingredients box"
	illustration = "donk_kit"
	item_state = null

/obj/item/weapon/storage/box/ingredients/Initialize()
	..()
	if(item_state)
		name = "[name] ([item_state])"
		desc = "A box containing supplementary ingredients for the aspiring chef. This box's theme is '[item_state]'."

/obj/item/weapon/storage/box/ingredients/wildcard
	item_state = "wildcard"

/obj/item/weapon/storage/box/ingredients/wildcard/PopulateContents()
	for(var/i in 1 to 7)
		var/randomFood = pick(/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
							  /obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
							  /obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
							  /obj/item/weapon/reagent_containers/food/snacks/grown/potato,
							  /obj/item/weapon/reagent_containers/food/snacks/grown/potato/sweet,
							  /obj/item/weapon/reagent_containers/food/snacks/grown/apple,
							  /obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
							  /obj/item/weapon/reagent_containers/food/snacks/grown/cherries,
							  /obj/item/weapon/reagent_containers/food/snacks/grown/banana,
							  /obj/item/weapon/reagent_containers/food/snacks/grown/cabbage,
							  /obj/item/weapon/reagent_containers/food/snacks/grown/soybeans,
							  /obj/item/weapon/reagent_containers/food/snacks/grown/corn,
							  /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet,
							  /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle)
		new randomFood(src)

/obj/item/weapon/storage/box/ingredients/fiesta
	item_state = "fiesta"

/obj/item/weapon/storage/box/ingredients/fiesta/PopulateContents()
	new /obj/item/weapon/reagent_containers/food/snacks/tortilla(src)
	for(var/i in 1 to 2)
		new /obj/item/weapon/reagent_containers/food/snacks/grown/corn(src)
		new /obj/item/weapon/reagent_containers/food/snacks/grown/soybeans(src)
		new /obj/item/weapon/reagent_containers/food/snacks/grown/chili(src)

/obj/item/weapon/storage/box/ingredients/italian
	item_state = "italian"

/obj/item/weapon/storage/box/ingredients/italian/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/weapon/reagent_containers/food/snacks/grown/tomato(src)
		new /obj/item/weapon/reagent_containers/food/snacks/faggot(src)
	new /obj/item/weapon/reagent_containers/food/drinks/bottle/wine(src)

/obj/item/weapon/storage/box/ingredients/vegetarian
	item_state = "vegetarian"

/obj/item/weapon/storage/box/ingredients/vegetarian/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/weapon/reagent_containers/food/snacks/grown/carrot(src)
	new /obj/item/weapon/reagent_containers/food/snacks/grown/eggplant(src)
	new /obj/item/weapon/reagent_containers/food/snacks/grown/potato(src)
	new /obj/item/weapon/reagent_containers/food/snacks/grown/apple(src)
	new /obj/item/weapon/reagent_containers/food/snacks/grown/corn(src)
	new /obj/item/weapon/reagent_containers/food/snacks/grown/tomato(src)

/obj/item/weapon/storage/box/ingredients/american
	item_state = "american"

/obj/item/weapon/storage/box/ingredients/american/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/weapon/reagent_containers/food/snacks/grown/potato(src)
		new /obj/item/weapon/reagent_containers/food/snacks/grown/tomato(src)
		new /obj/item/weapon/reagent_containers/food/snacks/grown/corn(src)
	new /obj/item/weapon/reagent_containers/food/snacks/faggot(src)

/obj/item/weapon/storage/box/ingredients/fruity
	item_state = "fruity"

/obj/item/weapon/storage/box/ingredients/fruity/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/weapon/reagent_containers/food/snacks/grown/apple(src)
		new /obj/item/weapon/reagent_containers/food/snacks/grown/citrus/orange(src)
	new /obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lemon(src)
	new /obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lime(src)
	new /obj/item/weapon/reagent_containers/food/snacks/grown/watermelon(src)

/obj/item/weapon/storage/box/ingredients/sweets
	item_state = "sweets"

/obj/item/weapon/storage/box/ingredients/sweets/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/weapon/reagent_containers/food/snacks/grown/cherries(src)
		new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(src)
	new /obj/item/weapon/reagent_containers/food/snacks/chocolatebar(src)
	new /obj/item/weapon/reagent_containers/food/snacks/grown/cocoapod(src)
	new /obj/item/weapon/reagent_containers/food/snacks/grown/apple(src)

/obj/item/weapon/storage/box/ingredients/delights
	item_state = "delights"

/obj/item/weapon/storage/box/ingredients/delights/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/weapon/reagent_containers/food/snacks/grown/potato/sweet(src)
		new /obj/item/weapon/reagent_containers/food/snacks/grown/bluecherries(src)
	new /obj/item/weapon/reagent_containers/food/snacks/grown/vanillapod(src)
	new /obj/item/weapon/reagent_containers/food/snacks/grown/cocoapod(src)
	new /obj/item/weapon/reagent_containers/food/snacks/grown/berries(src)

/obj/item/weapon/storage/box/ingredients/grains
	item_state = "grains"

/obj/item/weapon/storage/box/ingredients/grains/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/weapon/reagent_containers/food/snacks/grown/oat(src)
	new /obj/item/weapon/reagent_containers/food/snacks/grown/wheat(src)
	new /obj/item/weapon/reagent_containers/food/snacks/grown/cocoapod(src)
	new /obj/item/weapon/reagent_containers/honeycomb(src)
	new /obj/item/seeds/poppy(src)

/obj/item/weapon/storage/box/ingredients/carnivore
	item_state = "carnivore"

/obj/item/weapon/storage/box/ingredients/carnivore/PopulateContents()
	new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/bear(src)
	new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/spider(src)
	new /obj/item/weapon/reagent_containers/food/snacks/spidereggs(src)
	new /obj/item/weapon/reagent_containers/food/snacks/carpmeat(src)
	new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/xeno(src)
	new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/corgi(src)
	new /obj/item/weapon/reagent_containers/food/snacks/faggot(src)

/obj/item/weapon/storage/box/ingredients/exotic
	item_state = "exotic"

/obj/item/weapon/storage/box/ingredients/exotic/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/weapon/reagent_containers/food/snacks/carpmeat(src)
		new /obj/item/weapon/reagent_containers/food/snacks/grown/soybeans(src)
		new /obj/item/weapon/reagent_containers/food/snacks/grown/cabbage(src)
	new /obj/item/weapon/reagent_containers/food/snacks/grown/chili(src)

/obj/item/weapon/storage/box/emptysandbags
	name = "box of empty sandbags"

/obj/item/weapon/storage/box/emptysandbags/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/emptysandbag(src)

/obj/item/weapon/storage/box/rndboards
	name = "\proper the liberator's legacy"
	desc = "A box containing a gift for worthy golems."

/obj/item/weapon/storage/box/rndboards/PopulateContents()
	new /obj/item/weapon/circuitboard/machine/protolathe(src)
	new /obj/item/weapon/circuitboard/machine/destructive_analyzer(src)
	new /obj/item/weapon/circuitboard/machine/circuit_imprinter(src)
	new /obj/item/weapon/circuitboard/computer/rdconsole(src)

/obj/item/weapon/storage/box/silver_sulf
	name = "box of silver sulfadiazine patches"
	desc = "Contains patches used to treat burns."

/obj/item/weapon/storage/box/silver_sulf/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/reagent_containers/pill/patch/silver_sulf(src)


/obj/item/weapon/storage/box/fountainpens
	name = "box of fountain pens"

/obj/item/weapon/storage/box/fountainpens/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/pen/fountain(src)