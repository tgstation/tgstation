
/obj/item/weapon/storage/lglo_kit
	name = "Latex Gloves"
	desc = "Contains white gloves."
	icon_state = "latex"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

	New()
		new /obj/item/clothing/gloves/latex(src)
		new /obj/item/clothing/gloves/latex(src)
		new /obj/item/clothing/gloves/latex(src)
		new /obj/item/clothing/gloves/latex(src)
		new /obj/item/clothing/gloves/latex(src)
		new /obj/item/clothing/gloves/latex(src)
		new /obj/item/clothing/gloves/latex(src)
		..()
		return

/obj/item/weapon/storage/blankbox
	name = "box of blank shells"
	desc = "It has a picture of a gun and several warning symbols on the front."
	icon_state = "box"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

	New()
		new /obj/item/ammo_casing/shotgun/blank(src)
		new /obj/item/ammo_casing/shotgun/blank(src)
		new /obj/item/ammo_casing/shotgun/blank(src)
		new /obj/item/ammo_casing/shotgun/blank(src)
		new /obj/item/ammo_casing/shotgun/blank(src)
		new /obj/item/ammo_casing/shotgun/blank(src)
		new /obj/item/ammo_casing/shotgun/blank(src)
		..()
		return

/obj/item/weapon/storage/beakerbox
	name = "Beaker Box"
	icon_state = "beaker"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

	New()
		..()
		new /obj/item/weapon/reagent_containers/glass/beaker( src )
		new /obj/item/weapon/reagent_containers/glass/beaker( src )
		new /obj/item/weapon/reagent_containers/glass/beaker( src )
		new /obj/item/weapon/reagent_containers/glass/beaker( src )
		new /obj/item/weapon/reagent_containers/glass/beaker( src )
		new /obj/item/weapon/reagent_containers/glass/beaker( src )
		new /obj/item/weapon/reagent_containers/glass/beaker( src )

/obj/item/weapon/storage/flashbang_kit
	name = "flashbangs (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause blindness or deafness in repeated use.</B>"
	icon_state = "flashbang"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

	New()
		new /obj/item/weapon/grenade/flashbang(src)
		new /obj/item/weapon/grenade/flashbang(src)
		new /obj/item/weapon/grenade/flashbang(src)
		new /obj/item/weapon/grenade/flashbang(src)
		new /obj/item/weapon/grenade/flashbang(src)
		new /obj/item/weapon/grenade/flashbang(src)
		new /obj/item/weapon/grenade/flashbang(src)
		..()
		return

/obj/item/weapon/storage/emp_kit
	name = "emp grenades"
	desc = "A box with 5 emp grenades."
	icon_state = "flashbang"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

	New()
		new /obj/item/weapon/grenade/empgrenade(src)
		new /obj/item/weapon/grenade/empgrenade(src)
		new /obj/item/weapon/grenade/empgrenade(src)
		new /obj/item/weapon/grenade/empgrenade(src)
		new /obj/item/weapon/grenade/empgrenade(src)
		..()
		return

/obj/item/weapon/storage/stma_kit
	name = "Sterile Masks"
	desc = "This box contains masks of sterility."
	icon_state = "sterile"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

	New()
		new /obj/item/clothing/mask/surgical(src)
		new /obj/item/clothing/mask/surgical(src)
		new /obj/item/clothing/mask/surgical(src)
		new /obj/item/clothing/mask/surgical(src)
		new /obj/item/clothing/mask/surgical(src)
		new /obj/item/clothing/mask/surgical(src)
		new /obj/item/clothing/mask/surgical(src)
		..()
		return

/obj/item/weapon/storage/gl_kit
	name = "Prescription Glasses"
	desc = "This box contains nerd glasses."
	icon_state = "glasses"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

	New()
		new /obj/item/clothing/glasses/regular(src)
		new /obj/item/clothing/glasses/regular(src)
		new /obj/item/clothing/glasses/regular(src)
		new /obj/item/clothing/glasses/regular(src)
		new /obj/item/clothing/glasses/regular(src)
		new /obj/item/clothing/glasses/regular(src)
		new /obj/item/clothing/glasses/regular(src)
		..()
		return

/obj/item/weapon/storage/trackimp_kit
	name = "Tracking Implant Kit"
	desc = "Box full of scum-bag tracking utensils."
	icon_state = "implant"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

	New()
		new /obj/item/weapon/implantcase/tracking(src)
		new /obj/item/weapon/implantcase/tracking(src)
		new /obj/item/weapon/implantcase/tracking(src)
		new /obj/item/weapon/implantcase/tracking(src)
		new /obj/item/weapon/implanter(src)
		new /obj/item/weapon/implantpad(src)
		new /obj/item/weapon/locator(src)
		..()
		return

/obj/item/weapon/storage/chemimp_kit
	name = "Chemical Implant Kit"
	desc = "Box of stuff used to implant chemicals."
	icon_state = "implant"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

	New()
		new /obj/item/weapon/implantcase/chem(src)
		new /obj/item/weapon/implantcase/chem(src)
		new /obj/item/weapon/implantcase/chem(src)
		new /obj/item/weapon/implantcase/chem(src)
		new /obj/item/weapon/implantcase/chem(src)
		new /obj/item/weapon/implanter(src)
		new /obj/item/weapon/implantpad(src)
		..()
		return

/obj/item/weapon/storage/injectbox
	name = "DNA-Injectors"
	desc = "This box contains injectors it seems."
	icon_state = "box"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

	New()
		new /obj/item/weapon/dnainjector/h2m(src)
		new /obj/item/weapon/dnainjector/h2m(src)
		new /obj/item/weapon/dnainjector/h2m(src)
		new /obj/item/weapon/dnainjector/m2h(src)
		new /obj/item/weapon/dnainjector/m2h(src)
		new /obj/item/weapon/dnainjector/m2h(src)
		..()
		return

/obj/item/weapon/storage/id_kit
	name = "Spare IDs"
	desc = "Has so many empty IDs."
	icon_state = "id"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

	New()
		new /obj/item/weapon/card/id(src)
		new /obj/item/weapon/card/id(src)
		new /obj/item/weapon/card/id(src)
		new /obj/item/weapon/card/id(src)
		new /obj/item/weapon/card/id(src)
		new /obj/item/weapon/card/id(src)
		new /obj/item/weapon/card/id(src)
		..()
		return

/obj/item/weapon/storage/handcuff_kit
	name = "Spare Handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "handcuff"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

	New()
		new /obj/item/weapon/handcuffs(src)
		new /obj/item/weapon/handcuffs(src)
		new /obj/item/weapon/handcuffs(src)
		new /obj/item/weapon/handcuffs(src)
		new /obj/item/weapon/handcuffs(src)
		new /obj/item/weapon/handcuffs(src)
		new /obj/item/weapon/handcuffs(src)
		..()
		return

/obj/item/weapon/storage/seccart_kit
	name = "Spare R.O.B.U.S.T. Cartridges"
	desc = "A box full of R.O.B.U.S.T. Cartridges, used by Security."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pdabox"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

	New()
		new /obj/item/weapon/cartridge/security(src)
		new /obj/item/weapon/cartridge/security(src)
		new /obj/item/weapon/cartridge/security(src)
		new /obj/item/weapon/cartridge/security(src)
		new /obj/item/weapon/cartridge/security(src)
		new /obj/item/weapon/cartridge/security(src)
		new /obj/item/weapon/cartridge/security(src)
		..()
		return

/obj/item/weapon/storage/donkpocket_kit
	name = "box of donk-pockets"
	desc = "<B>Instructions:</B> <I>Heat in microwave. Product will cool if not eaten within seven minutes.</I>"
	icon_state = "donk_kit"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

	New()
		new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)
		new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)
		new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)
		new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)
		new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)
		new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)
		..()
		return

/obj/item/weapon/storage/condimentbottles
	name = "box of condiment bottles"
	desc = "It has a large ketchup smear on it."
	icon_state = "box"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

	New()
		new /obj/item/weapon/reagent_containers/food/condiment(src)
		new /obj/item/weapon/reagent_containers/food/condiment(src)
		new /obj/item/weapon/reagent_containers/food/condiment(src)
		new /obj/item/weapon/reagent_containers/food/condiment(src)
		new /obj/item/weapon/reagent_containers/food/condiment(src)
		new /obj/item/weapon/reagent_containers/food/condiment(src)
		..()
		return

/obj/item/weapon/storage/drinkingglasses
	name = "box of drinking glasses"
	desc = "It has a picture of drinking glasses on it."
	icon_state = "box"
	item_state = "syringe_kit"

	New()
		new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(src)
		new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(src)
		new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(src)
		new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(src)
		new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(src)
		new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(src)
		..()
		return

/obj/item/weapon/storage/cupbox
	name = "box of paper cups"
	desc = "It has pictures of paper cups on the front."
	icon_state = "box"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap
	New()
		..()
		new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )
		new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )
		new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )
		new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )
		new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )
		new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )
		new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )

/obj/item/weapon/storage/dice
	name = "pack of dice"
	desc = "It's a small container with dice inside."
	icon_state = "pill_canister"
	icon = 'icons/obj/chemical.dmi'
	item_state = "contsolid"
	w_class = 2.0
	can_hold = list("/obj/item/weapon/dice")

	New()
		new /obj/item/weapon/dice( src )
		new /obj/item/weapon/dice/d20( src )
		..()
		return

/obj/item/weapon/storage/pillbottlebox
	name = "box of pill bottles"
	desc = "It has pictures of pill bottles on its front."
	icon_state = "pillbox"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

	New()
		new /obj/item/weapon/storage/pill_bottle( src )
		new /obj/item/weapon/storage/pill_bottle( src )
		new /obj/item/weapon/storage/pill_bottle( src )
		new /obj/item/weapon/storage/pill_bottle( src )
		new /obj/item/weapon/storage/pill_bottle( src )
		new /obj/item/weapon/storage/pill_bottle( src )
		new /obj/item/weapon/storage/pill_bottle( src )
		..()
		return

/obj/item/weapon/storage/mousetraps
	name = "box of Pest-B-Gon Mousetraps"
	desc = "<B><FONT=red>WARNING:</FONT></B> <I>Keep out of reach of children</I>."
	icon_state = "mousetraps"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard //BubbleWrap

	New()
		new /obj/item/device/assembly/mousetrap( src )
		new /obj/item/device/assembly/mousetrap( src )
		new /obj/item/device/assembly/mousetrap( src )
		new /obj/item/device/assembly/mousetrap( src )
		new /obj/item/device/assembly/mousetrap( src )
		new /obj/item/device/assembly/mousetrap( src )
		..()
		return