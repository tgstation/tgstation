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
 *
 *		For syndicate call-ins see uplink_kits.dm
 */

/obj/item/weapon/storage/box
	name = "box"
	desc = "It's just an ordinary box."
	icon_state = "box"
	item_state = "syringe_kit"
	var/foldable = /obj/item/stack/sheet/cardboard


/obj/item/weapon/storage/box/attack_self(mob/user)
	..()

	if(!foldable)
		return
	if(contents.len)
		user << "<span class='notice'>You can't fold this box with items still inside.</span>"
		return
	if(!ispath(foldable))
		return

	//Close any open UI windows first
	close_all()

	user << "<span class='notice'>You fold [src] flat.</span>"
	var/obj/item/I = new foldable(get_turf(src))
	user.drop_item()
	user.put_in_hands(I)
	user.update_inv_l_hand()
	user.update_inv_r_hand()
	qdel(src)

/obj/item/weapon/storage/box/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/packageWrap))
		return 0
	..()


/obj/item/weapon/storage/box/survival

/obj/item/weapon/storage/box/survival/New()
	..()
	contents = list()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/weapon/tank/internals/emergency_oxygen(src)
	new /obj/item/weapon/reagent_containers/hypospray/medipen(src)
	return

/obj/item/weapon/storage/box/engineer

/obj/item/weapon/storage/box/engineer/New()
	..()
	contents = list()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/weapon/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/weapon/reagent_containers/hypospray/medipen(src)
	return

/obj/item/weapon/storage/box/gloves
	name = "box of latex gloves"
	desc = "Contains sterile latex gloves."
	icon_state = "latex"

/obj/item/weapon/storage/box/gloves/New()
	..()
	new /obj/item/clothing/gloves/color/latex(src)
	new /obj/item/clothing/gloves/color/latex(src)
	new /obj/item/clothing/gloves/color/latex(src)
	new /obj/item/clothing/gloves/color/latex(src)
	new /obj/item/clothing/gloves/color/latex(src)
	new /obj/item/clothing/gloves/color/latex(src)
	new /obj/item/clothing/gloves/color/latex(src)

/obj/item/weapon/storage/box/masks
	name = "box of sterile masks"
	desc = "This box contains sterile medical masks."
	icon_state = "sterile"

/obj/item/weapon/storage/box/masks/New()
	..()
	new /obj/item/clothing/mask/surgical(src)
	new /obj/item/clothing/mask/surgical(src)
	new /obj/item/clothing/mask/surgical(src)
	new /obj/item/clothing/mask/surgical(src)
	new /obj/item/clothing/mask/surgical(src)
	new /obj/item/clothing/mask/surgical(src)
	new /obj/item/clothing/mask/surgical(src)

/obj/item/weapon/storage/box/syringes
	name = "box of syringes"
	desc = "A box full of syringes."
	desc = "A biohazard alert warning is printed on the box"
	icon_state = "syringe"

/obj/item/weapon/storage/box/syringes/New()
	..()
	new /obj/item/weapon/reagent_containers/syringe( src )
	new /obj/item/weapon/reagent_containers/syringe( src )
	new /obj/item/weapon/reagent_containers/syringe( src )
	new /obj/item/weapon/reagent_containers/syringe( src )
	new /obj/item/weapon/reagent_containers/syringe( src )
	new /obj/item/weapon/reagent_containers/syringe( src )
	new /obj/item/weapon/reagent_containers/syringe( src )

/obj/item/weapon/storage/box/medipens
	name = "box of medipens"
	desc = "A box full of epinephrine MediPens."
	icon_state = "syringe"

/obj/item/weapon/storage/box/medipens/New()
	..()
	new /obj/item/weapon/reagent_containers/hypospray/medipen( src )
	new /obj/item/weapon/reagent_containers/hypospray/medipen( src )
	new /obj/item/weapon/reagent_containers/hypospray/medipen( src )
	new /obj/item/weapon/reagent_containers/hypospray/medipen( src )
	new /obj/item/weapon/reagent_containers/hypospray/medipen( src )
	new /obj/item/weapon/reagent_containers/hypospray/medipen( src )
	new /obj/item/weapon/reagent_containers/hypospray/medipen( src )

/obj/item/weapon/storage/box/medipens/utility
	name = "stimpack value kit"
	desc = "A box with several stimpack medipens for the economical miner."
	icon_state = "syringe"

/obj/item/weapon/storage/box/medipens/utility/New()
	..()
	new /obj/item/weapon/reagent_containers/hypospray/medipen/stimpack(src)
	new /obj/item/weapon/reagent_containers/hypospray/medipen/stimpack(src)
	new /obj/item/weapon/reagent_containers/hypospray/medipen/stimpack(src)
	new /obj/item/weapon/reagent_containers/hypospray/medipen/stimpack(src)
	new /obj/item/weapon/reagent_containers/hypospray/medipen/stimpack(src)

/obj/item/weapon/storage/box/beakers
	name = "box of beakers"
	icon_state = "beaker"

/obj/item/weapon/storage/box/beakers/New()
	..()
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )

/obj/item/weapon/storage/box/injectors
	name = "box of DNA injectors"
	desc = "This box contains injectors it seems."

/obj/item/weapon/storage/box/injectors/New()
	..()
	new /obj/item/weapon/dnainjector/h2m(src)
	new /obj/item/weapon/dnainjector/h2m(src)
	new /obj/item/weapon/dnainjector/h2m(src)
	new /obj/item/weapon/dnainjector/m2h(src)
	new /obj/item/weapon/dnainjector/m2h(src)
	new /obj/item/weapon/dnainjector/m2h(src)

/obj/item/weapon/storage/box/flashbangs
	name = "box of flashbangs (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause blindness or deafness in repeated use.</B>"
	icon_state = "flashbang"

/obj/item/weapon/storage/box/flashbangs/New()
	..()
	new /obj/item/weapon/grenade/flashbang(src)
	new /obj/item/weapon/grenade/flashbang(src)
	new /obj/item/weapon/grenade/flashbang(src)
	new /obj/item/weapon/grenade/flashbang(src)
	new /obj/item/weapon/grenade/flashbang(src)
	new /obj/item/weapon/grenade/flashbang(src)
	new /obj/item/weapon/grenade/flashbang(src)

/obj/item/weapon/storage/box/flashes
	name = "box of flashbulbs"
	desc = "<B>WARNING: Flashes can cause serious eye damage, protective eyewear is required.</B>"
	icon_state = "flashbang"

/obj/item/weapon/storage/box/flashes/New()
	..()
	new /obj/item/device/flash/handheld(src)
	new /obj/item/device/flash/handheld(src)
	new /obj/item/device/flash/handheld(src)
	new /obj/item/device/flash/handheld(src)
	new /obj/item/device/flash/handheld(src)
	new /obj/item/device/flash/handheld(src)

/obj/item/weapon/storage/box/teargas
	name = "box of tear gas grenades (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause blindness and skin irritation.</B>"
	icon_state = "flashbang"

/obj/item/weapon/storage/box/teargas/New()
	..()
	new /obj/item/weapon/grenade/chem_grenade/teargas(src)
	new /obj/item/weapon/grenade/chem_grenade/teargas(src)
	new /obj/item/weapon/grenade/chem_grenade/teargas(src)
	new /obj/item/weapon/grenade/chem_grenade/teargas(src)
	new /obj/item/weapon/grenade/chem_grenade/teargas(src)
	new /obj/item/weapon/grenade/chem_grenade/teargas(src)
	new /obj/item/weapon/grenade/chem_grenade/teargas(src)

/obj/item/weapon/storage/box/emps
	name = "box of emp grenades"
	desc = "A box with 5 emp grenades."
	icon_state = "flashbang"

/obj/item/weapon/storage/box/emps/New()
	..()
	new /obj/item/weapon/grenade/empgrenade(src)
	new /obj/item/weapon/grenade/empgrenade(src)
	new /obj/item/weapon/grenade/empgrenade(src)
	new /obj/item/weapon/grenade/empgrenade(src)
	new /obj/item/weapon/grenade/empgrenade(src)

/obj/item/weapon/storage/box/trackimp
	name = "boxed tracking implant kit"
	desc = "Box full of scum-bag tracking utensils."
	icon_state = "implant"

/obj/item/weapon/storage/box/trackimp/New()
	..()
	new /obj/item/weapon/implantcase/tracking(src)
	new /obj/item/weapon/implantcase/tracking(src)
	new /obj/item/weapon/implantcase/tracking(src)
	new /obj/item/weapon/implantcase/tracking(src)
	new /obj/item/weapon/implanter(src)
	new /obj/item/weapon/implantpad(src)
	new /obj/item/weapon/locator(src)

/obj/item/weapon/storage/box/chemimp
	name = "boxed chemical implant kit"
	desc = "Box of stuff used to implant chemicals."
	icon_state = "implant"

/obj/item/weapon/storage/box/chemimp/New()
	..()
	new /obj/item/weapon/implantcase/chem(src)
	new /obj/item/weapon/implantcase/chem(src)
	new /obj/item/weapon/implantcase/chem(src)
	new /obj/item/weapon/implantcase/chem(src)
	new /obj/item/weapon/implantcase/chem(src)
	new /obj/item/weapon/implanter(src)
	new /obj/item/weapon/implantpad(src)

/obj/item/weapon/storage/box/exileimp
	name = "boxed exile implant kit"
	desc = "Box of exile implants. It has a picture of a clown being booted through the Gateway."
	icon_state = "implant"

/obj/item/weapon/storage/box/exileimp/New()
	..()
	new /obj/item/weapon/implantcase/exile(src)
	new /obj/item/weapon/implantcase/exile(src)
	new /obj/item/weapon/implantcase/exile(src)
	new /obj/item/weapon/implantcase/exile(src)
	new /obj/item/weapon/implantcase/exile(src)
	new /obj/item/weapon/implanter(src)

/obj/item/weapon/storage/box/rxglasses
	name = "box of prescription glasses"
	desc = "This box contains nerd glasses."
	icon_state = "glasses"

/obj/item/weapon/storage/box/rxglasses/New()
	..()
	new /obj/item/clothing/glasses/regular(src)
	new /obj/item/clothing/glasses/regular(src)
	new /obj/item/clothing/glasses/regular(src)
	new /obj/item/clothing/glasses/regular(src)
	new /obj/item/clothing/glasses/regular(src)
	new /obj/item/clothing/glasses/regular(src)
	new /obj/item/clothing/glasses/regular(src)

/obj/item/weapon/storage/box/drinkingglasses
	name = "box of drinking glasses"
	desc = "It has a picture of drinking glasses on it."

/obj/item/weapon/storage/box/drinkingglasses/New()
	..()
	new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(src)
	new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(src)
	new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(src)
	new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(src)
	new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(src)
	new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(src)

/obj/item/weapon/storage/box/condimentbottles
	name = "box of condiment bottles"
	desc = "It has a large ketchup smear on it."

/obj/item/weapon/storage/box/condimentbottles/New()
	..()
	new /obj/item/weapon/reagent_containers/food/condiment(src)
	new /obj/item/weapon/reagent_containers/food/condiment(src)
	new /obj/item/weapon/reagent_containers/food/condiment(src)
	new /obj/item/weapon/reagent_containers/food/condiment(src)
	new /obj/item/weapon/reagent_containers/food/condiment(src)
	new /obj/item/weapon/reagent_containers/food/condiment(src)

/obj/item/weapon/storage/box/cups
	name = "box of paper cups"
	desc = "It has pictures of paper cups on the front."

/obj/item/weapon/storage/box/cups/New()
	..()
	new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )
	new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )
	new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )
	new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )
	new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )
	new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )
	new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )

/obj/item/weapon/storage/box/donkpockets
	name = "box of donk-pockets"
	desc = "<B>Instructions:</B> <I>Heat in microwave. Product will cool if not eaten within seven minutes.</I>"
	icon_state = "donk_kit"

/obj/item/weapon/storage/box/donkpockets/New()
	..()
	new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)
	new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)
	new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)
	new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)
	new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)
	new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)

/obj/item/weapon/storage/box/monkeycubes
	name = "monkey cube box"
	desc = "Drymate brand monkey cubes. Just add water!"
	icon = 'icons/obj/food/food.dmi'
	icon_state = "monkeycubebox"
	storage_slots = 7
	can_hold = list(/obj/item/weapon/reagent_containers/food/snacks/monkeycube)

/obj/item/weapon/storage/box/monkeycubes/New()
	..()
	for(var/i = 1; i <= 5; i++)
		new /obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped(src)


/obj/item/weapon/storage/box/permits
	name = "box of construction permits"
	desc = "A box for containing construction permits, used to officially declare built rooms as additions to the station."
	icon_state = "id"

/obj/item/weapon/storage/box/permits/New() //There's only a few, so blueprints are still useful beyond setting every room's name to PRIMARY FART STORAGE
	..()
	new /obj/item/areaeditor/permit(src)
	new /obj/item/areaeditor/permit(src)
	new /obj/item/areaeditor/permit(src)


/obj/item/weapon/storage/box/ids
	name = "box of spare IDs"
	desc = "Has so many empty IDs."
	icon_state = "id"

/obj/item/weapon/storage/box/ids/New()
	..()
	new /obj/item/weapon/card/id(src)
	new /obj/item/weapon/card/id(src)
	new /obj/item/weapon/card/id(src)
	new /obj/item/weapon/card/id(src)
	new /obj/item/weapon/card/id(src)
	new /obj/item/weapon/card/id(src)
	new /obj/item/weapon/card/id(src)

/obj/item/weapon/storage/box/silver_ids
	name = "box of spare silver IDs"
	desc = "Shiny IDs for important people."
	icon_state = "id"

/obj/item/weapon/storage/box/silver_ids/New()
	..()
	new /obj/item/weapon/card/id/silver(src)
	new /obj/item/weapon/card/id/silver(src)
	new /obj/item/weapon/card/id/silver(src)
	new /obj/item/weapon/card/id/silver(src)
	new /obj/item/weapon/card/id/silver(src)
	new /obj/item/weapon/card/id/silver(src)
	new /obj/item/weapon/card/id/silver(src)

/obj/item/weapon/storage/box/prisoner
	name = "box of prisoner IDs"
	desc = "Take away their last shred of dignity, their name."
	icon_state = "id"

/obj/item/weapon/storage/box/prisoner/New()
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
	icon_state = "pda"

/obj/item/weapon/storage/box/seccarts/New()
	..()
	new /obj/item/weapon/cartridge/detective(src)
	new /obj/item/weapon/cartridge/security(src)
	new /obj/item/weapon/cartridge/security(src)
	new /obj/item/weapon/cartridge/security(src)
	new /obj/item/weapon/cartridge/security(src)
	new /obj/item/weapon/cartridge/security(src)
	new /obj/item/weapon/cartridge/security(src)

/obj/item/weapon/storage/box/firingpins
	name = "box of standard firing pins"
	desc = "A box full of standard firing pins, to allow newly-developed firearms to operate."
	icon_state = "id"

/obj/item/weapon/storage/box/firingpins/New()
	..()
	new /obj/item/device/firing_pin(src)
	new /obj/item/device/firing_pin(src)
	new /obj/item/device/firing_pin(src)
	new /obj/item/device/firing_pin(src)
	new /obj/item/device/firing_pin(src)
	new /obj/item/device/firing_pin(src)
	new /obj/item/device/firing_pin(src)

/obj/item/weapon/storage/box/handcuffs
	name = "box of spare handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "handcuff"

/obj/item/weapon/storage/box/handcuffs/New()
	..()
	new /obj/item/weapon/restraints/handcuffs(src)
	new /obj/item/weapon/restraints/handcuffs(src)
	new /obj/item/weapon/restraints/handcuffs(src)
	new /obj/item/weapon/restraints/handcuffs(src)
	new /obj/item/weapon/restraints/handcuffs(src)
	new /obj/item/weapon/restraints/handcuffs(src)
	new /obj/item/weapon/restraints/handcuffs(src)

/obj/item/weapon/storage/box/zipties
	name = "box of spare zipties"
	desc = "A box full of zipties."
	icon_state = "handcuff"

/obj/item/weapon/storage/box/zipties/New()
	..()
	new /obj/item/weapon/restraints/handcuffs/cable/zipties(src)
	new /obj/item/weapon/restraints/handcuffs/cable/zipties(src)
	new /obj/item/weapon/restraints/handcuffs/cable/zipties(src)
	new /obj/item/weapon/restraints/handcuffs/cable/zipties(src)
	new /obj/item/weapon/restraints/handcuffs/cable/zipties(src)
	new /obj/item/weapon/restraints/handcuffs/cable/zipties(src)
	new /obj/item/weapon/restraints/handcuffs/cable/zipties(src)

/obj/item/weapon/storage/box/fakesyndiesuit
	name = "boxed space suit and helmet"
	desc = "A sleek, sturdy box used to hold replica spacesuits."
	icon_state = "box_of_doom"

/obj/item/weapon/storage/box/fakesyndiesuit/New()
	..()
	new /obj/item/clothing/head/syndicatefake(src)
	new /obj/item/clothing/suit/syndicatefake(src)

/obj/item/weapon/storage/box/mousetraps
	name = "box of Pest-B-Gon mousetraps"
	desc = "<span class='alert'>Keep out of reach of children.</span>"
	icon_state = "mousetraps"

/obj/item/weapon/storage/box/mousetraps/New()
	..()
	new /obj/item/device/assembly/mousetrap( src )
	new /obj/item/device/assembly/mousetrap( src )
	new /obj/item/device/assembly/mousetrap( src )
	new /obj/item/device/assembly/mousetrap( src )
	new /obj/item/device/assembly/mousetrap( src )
	new /obj/item/device/assembly/mousetrap( src )

/obj/item/weapon/storage/box/pillbottles
	name = "box of pill bottles"
	desc = "It has pictures of pill bottles on its front."
	icon_state = "pillbox"

/obj/item/weapon/storage/box/pillbottles/New()
	..()
	new /obj/item/weapon/storage/pill_bottle( src )
	new /obj/item/weapon/storage/pill_bottle( src )
	new /obj/item/weapon/storage/pill_bottle( src )
	new /obj/item/weapon/storage/pill_bottle( src )
	new /obj/item/weapon/storage/pill_bottle( src )
	new /obj/item/weapon/storage/pill_bottle( src )
	new /obj/item/weapon/storage/pill_bottle( src )

/obj/item/weapon/storage/box/snappops
	name = "snap pop box"
	desc = "Eight wrappers of fun! Ages 8 and up. Not suitable for children."
	icon = 'icons/obj/toy.dmi'
	icon_state = "spbox"
	storage_slots = 8
	can_hold = list(/obj/item/toy/snappop)

/obj/item/weapon/storage/box/snappops/New()
	..()
	for(var/i=1; i <= storage_slots; i++)
		new /obj/item/toy/snappop(src)

/obj/item/weapon/storage/box/matches
	name = "matchbox"
	desc = "A small box of Almost But Not Quite Plasma Premium Matches."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "matchbox"
	item_state = "zippo"
	storage_slots = 10
	w_class = 1
	slot_flags = SLOT_BELT
	can_hold = list(/obj/item/weapon/match)

/obj/item/weapon/storage/box/matches/New()
	..()
	for(var/i=1; i <= storage_slots; i++)
		new /obj/item/weapon/match(src)

/obj/item/weapon/storage/box/matches/attackby(obj/item/weapon/match/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/match))
		W.matchignite()
	return

/obj/item/weapon/storage/box/lights
	name = "box of replacement bulbs"
	icon = 'icons/obj/storage.dmi'
	icon_state = "light"
	desc = "This box is shaped on the inside so that only light tubes and bulbs fit."
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard //BubbleWrap
	storage_slots=21
	can_hold = list(/obj/item/weapon/light/tube, /obj/item/weapon/light/bulb)
	max_combined_w_class = 21
	use_to_pickup = 1 // for picking up broken bulbs, not that most people will try

/obj/item/weapon/storage/box/lights/bulbs/New()
	..()
	for(var/i = 0; i < 21; i++)
		new /obj/item/weapon/light/bulb(src)

/obj/item/weapon/storage/box/lights/tubes
	name = "box of replacement tubes"
	icon_state = "lighttube"

/obj/item/weapon/storage/box/lights/tubes/New()
	..()
	for(var/i = 0; i < 21; i++)
		new /obj/item/weapon/light/tube(src)

/obj/item/weapon/storage/box/lights/mixed
	name = "box of replacement lights"
	icon_state = "lightmixed"

/obj/item/weapon/storage/box/lights/mixed/New()
	..()
	for(var/i = 0; i < 14; i++)
		new /obj/item/weapon/light/tube(src)
	for(var/i = 0; i < 7; i++)
		new /obj/item/weapon/light/bulb(src)


/obj/item/weapon/storage/box/deputy
	name = "box of deputy armbands"
	desc = "To be issued to those authorized to act as deputy of security."

/obj/item/weapon/storage/box/deputy/New()
	..()
	new /obj/item/clothing/tie/armband/deputy(src)
	new /obj/item/clothing/tie/armband/deputy(src)
	new /obj/item/clothing/tie/armband/deputy(src)
	new /obj/item/clothing/tie/armband/deputy(src)
	new /obj/item/clothing/tie/armband/deputy(src)
	new /obj/item/clothing/tie/armband/deputy(src)
	new /obj/item/clothing/tie/armband/deputy(src)

/obj/item/weapon/storage/box/metalfoam
	name = "box of metal foam grenades"
	desc = "To be used to rapidly seal hull breaches"
	icon_state = "flashbang"

/obj/item/weapon/storage/box/metalfoam/New()
	..()
	new /obj/item/weapon/grenade/chem_grenade/metalfoam(src)
	new /obj/item/weapon/grenade/chem_grenade/metalfoam(src)
	new /obj/item/weapon/grenade/chem_grenade/metalfoam(src)
	new /obj/item/weapon/grenade/chem_grenade/metalfoam(src)
	new /obj/item/weapon/grenade/chem_grenade/metalfoam(src)
	new /obj/item/weapon/grenade/chem_grenade/metalfoam(src)
	new /obj/item/weapon/grenade/chem_grenade/metalfoam(src)