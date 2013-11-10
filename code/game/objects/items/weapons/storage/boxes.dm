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
		return
	if(!ispath(foldable))
		return

	//Close any open UI windows first
	var/found = 0
	for(var/mob/M in range(1))
		if(M.s_active == src)
			close(M)
		if(M == user)
			found = 1
	if(!found)	//User is too far away
		return

	user << "<span class='notice'>You fold [src] flat.</span>"
	var/obj/item/I = new foldable(get_turf(src))
	user.put_in_hands(I)
	del(src)


/obj/item/weapon/storage/box/survival
	New()
		..()
		contents = list()
		sleep(1)
		new /obj/item/clothing/mask/breath( src )
		new /obj/item/weapon/tank/emergency_oxygen( src )
		return

/obj/item/weapon/storage/box/engineer
	New()
		..()
		contents = list()
		sleep(1)
		new /obj/item/clothing/mask/breath( src )
		new /obj/item/weapon/tank/emergency_oxygen/engi( src )
		return

/obj/item/weapon/storage/box/gloves
	name = "box of latex gloves"
	desc = "Contains white gloves."
	icon_state = "latex"
	New()
		..()
		new /obj/item/clothing/gloves/latex(src)
		new /obj/item/clothing/gloves/latex(src)
		new /obj/item/clothing/gloves/latex(src)
		new /obj/item/clothing/gloves/latex(src)
		new /obj/item/clothing/gloves/latex(src)
		new /obj/item/clothing/gloves/latex(src)
		new /obj/item/clothing/gloves/latex(src)

/obj/item/weapon/storage/box/masks
	name = "sterile masks"
	desc = "This box contains masks of sterility."
	icon_state = "sterile"

	New()
		..()
		new /obj/item/clothing/mask/surgical(src)
		new /obj/item/clothing/mask/surgical(src)
		new /obj/item/clothing/mask/surgical(src)
		new /obj/item/clothing/mask/surgical(src)
		new /obj/item/clothing/mask/surgical(src)
		new /obj/item/clothing/mask/surgical(src)
		new /obj/item/clothing/mask/surgical(src)

/obj/item/weapon/storage/box/syringes
	name = "syringes"
	desc = "A box full of syringes."
	desc = "A biohazard alert warning is printed on the box"
	icon_state = "syringe"

	New()
		..()
		new /obj/item/weapon/reagent_containers/syringe( src )
		new /obj/item/weapon/reagent_containers/syringe( src )
		new /obj/item/weapon/reagent_containers/syringe( src )
		new /obj/item/weapon/reagent_containers/syringe( src )
		new /obj/item/weapon/reagent_containers/syringe( src )
		new /obj/item/weapon/reagent_containers/syringe( src )
		new /obj/item/weapon/reagent_containers/syringe( src )

/obj/item/weapon/storage/box/beakers
	name = "beaker box"
	icon_state = "beaker"

	New()
		..()
		new /obj/item/weapon/reagent_containers/glass/beaker( src )
		new /obj/item/weapon/reagent_containers/glass/beaker( src )
		new /obj/item/weapon/reagent_containers/glass/beaker( src )
		new /obj/item/weapon/reagent_containers/glass/beaker( src )
		new /obj/item/weapon/reagent_containers/glass/beaker( src )
		new /obj/item/weapon/reagent_containers/glass/beaker( src )
		new /obj/item/weapon/reagent_containers/glass/beaker( src )

/obj/item/weapon/storage/box/injectors
	name = "\improper DNA injectors"
	desc = "This box contains injectors it seems."

	New()
		..()
		new /obj/item/weapon/dnainjector/h2m(src)
		new /obj/item/weapon/dnainjector/h2m(src)
		new /obj/item/weapon/dnainjector/h2m(src)
		new /obj/item/weapon/dnainjector/m2h(src)
		new /obj/item/weapon/dnainjector/m2h(src)
		new /obj/item/weapon/dnainjector/m2h(src)

/obj/item/weapon/storage/box/blanks
	name = "box of blank shells"
	desc = "It has a picture of a gun and several warning symbols on the front."

	New()
		..()
		new /obj/item/ammo_casing/shotgun/blank(src)
		new /obj/item/ammo_casing/shotgun/blank(src)
		new /obj/item/ammo_casing/shotgun/blank(src)
		new /obj/item/ammo_casing/shotgun/blank(src)
		new /obj/item/ammo_casing/shotgun/blank(src)
		new /obj/item/ammo_casing/shotgun/blank(src)
		new /obj/item/ammo_casing/shotgun/blank(src)

/obj/item/weapon/storage/box/flashbangs
	name = "box of flashbangs (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause blindness or deafness in repeated use.</B>"
	icon_state = "flashbang"

	New()
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

	New()
		..()
		new /obj/item/device/flash(src)
		new /obj/item/device/flash(src)
		new /obj/item/device/flash(src)
		new /obj/item/device/flash(src)
		new /obj/item/device/flash(src)
		new /obj/item/device/flash(src)

/obj/item/weapon/storage/box/teargas
	name = "box of tear gas grenades (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause blindness and skin irritation.</B>"
	icon_state = "flashbang"

	New()
		..()
		new /obj/item/weapon/grenade/chem_grenade/teargas(src)
		new /obj/item/weapon/grenade/chem_grenade/teargas(src)
		new /obj/item/weapon/grenade/chem_grenade/teargas(src)
		new /obj/item/weapon/grenade/chem_grenade/teargas(src)
		new /obj/item/weapon/grenade/chem_grenade/teargas(src)
		new /obj/item/weapon/grenade/chem_grenade/teargas(src)
		new /obj/item/weapon/grenade/chem_grenade/teargas(src)

/obj/item/weapon/storage/box/emps
	name = "emp grenades"
	desc = "A box with 5 emp grenades."
	icon_state = "flashbang"

	New()
		..()
		new /obj/item/weapon/grenade/empgrenade(src)
		new /obj/item/weapon/grenade/empgrenade(src)
		new /obj/item/weapon/grenade/empgrenade(src)
		new /obj/item/weapon/grenade/empgrenade(src)
		new /obj/item/weapon/grenade/empgrenade(src)

/obj/item/weapon/storage/box/trackimp
	name = "tracking implant kit"
	desc = "Box full of scum-bag tracking utensils."
	icon_state = "implant"

	New()
		..()
		new /obj/item/weapon/implantcase/tracking(src)
		new /obj/item/weapon/implantcase/tracking(src)
		new /obj/item/weapon/implantcase/tracking(src)
		new /obj/item/weapon/implantcase/tracking(src)
		new /obj/item/weapon/implanter(src)
		new /obj/item/weapon/implantpad(src)
		new /obj/item/weapon/locator(src)

/obj/item/weapon/storage/box/chemimp
	name = "chemical implant kit"
	desc = "Box of stuff used to implant chemicals."
	icon_state = "implant"

	New()
		..()
		new /obj/item/weapon/implantcase/chem(src)
		new /obj/item/weapon/implantcase/chem(src)
		new /obj/item/weapon/implantcase/chem(src)
		new /obj/item/weapon/implantcase/chem(src)
		new /obj/item/weapon/implantcase/chem(src)
		new /obj/item/weapon/implanter(src)
		new /obj/item/weapon/implantpad(src)

/obj/item/weapon/storage/box/exileimp
	name = "exile implant kit"
	desc = "Box of exile implants. It has a picture of a clown being booted through the Gateway."
	icon_state = "implant"

	New()
		..()
		new /obj/item/weapon/implantcase/exile(src)
		new /obj/item/weapon/implantcase/exile(src)
		new /obj/item/weapon/implantcase/exile(src)
		new /obj/item/weapon/implantcase/exile(src)
		new /obj/item/weapon/implantcase/exile(src)
		new /obj/item/weapon/implanter(src)

/obj/item/weapon/storage/box/rxglasses
	name = "prescription glasses"
	desc = "This box contains nerd glasses."
	icon_state = "glasses"

	New()
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

	New()
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

	New()
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
	New()
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

	New()
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
	icon = 'icons/obj/food.dmi'
	icon_state = "monkeycubebox"
	storage_slots = 7
	can_hold = list("/obj/item/weapon/reagent_containers/food/snacks/monkeycube")
	New()
		..()
		for(var/i = 1; i <= 5; i++)
			new /obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped(src)

/obj/item/weapon/storage/box/ids
	name = "spare IDs"
	desc = "Has so many empty IDs."
	icon_state = "id"

	New()
		..()
		new /obj/item/weapon/card/id(src)
		new /obj/item/weapon/card/id(src)
		new /obj/item/weapon/card/id(src)
		new /obj/item/weapon/card/id(src)
		new /obj/item/weapon/card/id(src)
		new /obj/item/weapon/card/id(src)
		new /obj/item/weapon/card/id(src)

/obj/item/weapon/storage/box/prisoner
	name = "prisoner IDs"
	desc = "Take away their last shred of dignity, their name."
	icon_state = "id"

	New()
		..()
		new /obj/item/weapon/card/id/prisoner/one(src)
		new /obj/item/weapon/card/id/prisoner/two(src)
		new /obj/item/weapon/card/id/prisoner/three(src)
		new /obj/item/weapon/card/id/prisoner/four(src)
		new /obj/item/weapon/card/id/prisoner/five(src)
		new /obj/item/weapon/card/id/prisoner/six(src)
		new /obj/item/weapon/card/id/prisoner/seven(src)

/obj/item/weapon/storage/box/seccarts
	name = "Spare R.O.B.U.S.T. Cartridges"
	desc = "A box full of R.O.B.U.S.T. Cartridges, used by Security."
	icon_state = "pda"

	New()
		..()
		new /obj/item/weapon/cartridge/security(src)
		new /obj/item/weapon/cartridge/security(src)
		new /obj/item/weapon/cartridge/security(src)
		new /obj/item/weapon/cartridge/security(src)
		new /obj/item/weapon/cartridge/security(src)
		new /obj/item/weapon/cartridge/security(src)
		new /obj/item/weapon/cartridge/security(src)

/obj/item/weapon/storage/box/handcuffs
	name = "spare handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "handcuff"

	New()
		..()
		new /obj/item/weapon/handcuffs(src)
		new /obj/item/weapon/handcuffs(src)
		new /obj/item/weapon/handcuffs(src)
		new /obj/item/weapon/handcuffs(src)
		new /obj/item/weapon/handcuffs(src)
		new /obj/item/weapon/handcuffs(src)
		new /obj/item/weapon/handcuffs(src)

/obj/item/weapon/storage/box/fakesyndiesuit
	name = "Space Suit and Helmet"
	desc = "A sleek, sturdy box used to hold replica spacesuits."
	icon_state = "box_of_doom"

	New()
		..()
		new /obj/item/clothing/head/syndicatefake(src)
		new /obj/item/clothing/suit/syndicatefake(src)

/obj/item/weapon/storage/box/mousetraps
	name = "box of Pest-B-Gon Mousetraps"
	desc = "<B><FONT=red>WARNING:</FONT></B> <I>Keep out of reach of children</I>."
	icon_state = "mousetraps"

	New()
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
	New()
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
	can_hold = list("/obj/item/toy/snappop")
	New()
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
	flags = TABLEPASS
	slot_flags = SLOT_BELT

	New()
		..()
		for(var/i=1; i <= storage_slots; i++)
			new /obj/item/weapon/match(src)

	attackby(obj/item/weapon/match/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weapon/match) && W.lit == 0)
			W.lit = 1
			W.icon_state = "match_lit"
			processing_objects.Add(W)
		W.update_icon()
		return

/obj/item/weapon/storage/box/lights
	name = "replacement bulbs"
	icon = 'icons/obj/storage.dmi'
	icon_state = "light"
	desc = "This box is shaped on the inside so that only light tubes and bulbs fit."
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard //BubbleWrap
	storage_slots=21
	can_hold = list("/obj/item/weapon/light/tube", "/obj/item/weapon/light/bulb")
	max_combined_w_class = 21
	use_to_pickup = 1 // for picking up broken bulbs, not that most people will try

/obj/item/weapon/storage/box/lights/bulbs/New()
	..()
	for(var/i = 0; i < 21; i++)
		new /obj/item/weapon/light/bulb(src)

/obj/item/weapon/storage/box/lights/tubes
	name = "replacement tubes"
	icon_state = "lighttube"

/obj/item/weapon/storage/box/lights/tubes/New()
	..()
	for(var/i = 0; i < 21; i++)
		new /obj/item/weapon/light/tube(src)

/obj/item/weapon/storage/box/lights/mixed
	name = "replacement lights"
	icon_state = "lightmixed"

/obj/item/weapon/storage/box/lights/mixed/New()
	..()
	for(var/i = 0; i < 14; i++)
		new /obj/item/weapon/light/tube(src)
	for(var/i = 0; i < 7; i++)
		new /obj/item/weapon/light/bulb(src)