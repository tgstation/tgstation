// **********************
// Other harvested materials from plants (that are not food)
// **********************

/obj/item/weapon/grown // Grown weapons
	name = "grown_weapon"
	icon = 'icons/obj/weapons.dmi'
	var/seed = ""
	var/plantname = ""
	var/product	//a type path
	var/lifespan = 20
	var/endurance = 15
	var/maturation = 7
	var/production = 7
	var/yield = 2
	var/potency = 20
	var/plant_type = 0

/obj/item/weapon/grown/New(newloc, potency = 50)
	..()
	src.potency = potency
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

	transform *= TransformUsingVariable(potency, 100, 0.5)

	create_reagents(50)

/obj/item/weapon/grown/proc/changePotency(newValue) //-QualityVan
	potency = newValue
	transform *= TransformUsingVariable(potency, 100, 0.5) //Makes the resulting produce's sprite larger or smaller based on potency!

/obj/item/weapon/grown/log
	name = "tower-cap log"
	desc = "It's better than bad, it's good!"
	icon = 'icons/obj/harvest.dmi'
	icon_state = "logs"
	force = 5
	throwforce = 5
	w_class = 3.0
	throw_speed = 2
	throw_range = 3
	plant_type = 2
	origin_tech = "materials=1"
	seed = "/obj/item/seeds/towermycelium"
	attack_verb = list("bashed", "battered", "bludgeoned", "whacked")
	var/list/accepted = list(/obj/item/weapon/reagent_containers/food/snacks/grown/tobacco,
	/obj/item/weapon/reagent_containers/food/snacks/grown/tobacco,
	/obj/item/weapon/reagent_containers/food/snacks/grown/tobacco_space,
	/obj/item/weapon/reagent_containers/food/snacks/grown/tea_aspera,
	/obj/item/weapon/reagent_containers/food/snacks/grown/tea_astra,
	/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
	/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiadeus,
	/obj/item/weapon/reagent_containers/food/snacks/grown/wheat)
	
	New(var/loc, var/potency = 10)
		..()

/obj/item/weapon/grown/log/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/circular_saw) || istype(W, /obj/item/weapon/hatchet) || (istype(W, /obj/item/weapon/twohanded/fireaxe) && W:wielded) || istype(W, /obj/item/weapon/melee/energy))
		user.show_message("<span class='notice'>You make planks out of the [src]!</span>", 1)
		for(var/i=0,i<2,i++)
			var/obj/item/stack/sheet/mineral/wood/NG = new (user.loc)
			for (var/obj/item/stack/sheet/mineral/wood/G in user.loc)
				if(G==NG)
					continue
				if(G.amount>=G.max_amount)
					continue
				G.attackby(NG, user)
				usr << "You add the newly-formed wood to the stack. It now contains [NG.amount] planks."
		qdel(src)
		return
	if(is_type_in_list(W,accepted))
		var/obj/item/weapon/reagent_containers/food/snacks/grown/leaf = W
		if(leaf.dry)
			user.show_message("<span class='notice'>You wrap the [W] around the log, turning it into a torch!</span>")
			var/obj/item/device/flashlight/flare/torch/T = new /obj/item/device/flashlight/flare/torch(user.loc)
			usr.unEquip(W)
			usr.put_in_active_hand(T)
			qdel(leaf)
			qdel(src)
			return
		else
			usr << "\red You must dry this first."

/obj/item/weapon/grown/sunflower // FLOWER POWER!
	name = "sunflower"
	desc = "It's beautiful! A certain person might beat you to death if you trample these."
	icon = 'icons/obj/harvest.dmi'
	icon_state = "sunflower"
	damtype = "fire"
	force = 0
	slot_flags = SLOT_HEAD
	throwforce = 0
	w_class = 1.0
	throw_speed = 1
	throw_range = 3
	plant_type = 0
	seed = "/obj/item/seeds/sunflowerseed"
	
	New(var/loc, var/potency = 10)
		..()

/obj/item/weapon/grown/novaflower
	name = "novaflower"
	desc = "These beautiful flowers have a crisp smokey scent, like a summer bonfire."
	icon = 'icons/obj/harvest.dmi'
	icon_state = "novaflower"
	damtype = "fire"
	force = 0
	slot_flags = SLOT_HEAD
	throwforce = 0
	w_class = 1.0
	throw_speed = 1
	throw_range = 3
	plant_type = 0
	seed = "/obj/item/seeds/novaflowerseed"
	attack_verb = list("seared", "heated", "whacked", "steamed")
	New(var/loc, var/potency = 10)
		..()
		if(reagents)
			reagents.add_reagent("nutriment", 1)
			reagents.add_reagent("capsaicin", round(potency, 1))
		force = round((5+potency/5), 1)

/obj/item/weapon/grown/nettle // -- Skie
	desc = "It's probably <B>not</B> wise to touch it with bare hands..."
	icon = 'icons/obj/weapons.dmi'
	name = "nettle"
	icon_state = "nettle"
	damtype = "fire"
	force = 15
	hitsound = 'sound/weapons/bladeslice.ogg'
	throwforce = 5
	w_class = 1.0
	throw_speed = 1
	throw_range = 3
	plant_type = 1
	origin_tech = "combat=1"
	seed = "/obj/item/seeds/nettleseed"
	New(var/loc, var/potency = 10)
		..()
		if(reagents)
			reagents.add_reagent("nutriment", 1)
			reagents.add_reagent("sacid", round(potency, 1))
		force = round((5+potency/5), 1)

/obj/item/weapon/grown/deathnettle // -- Skie
	desc = "The \red glowing \black nettle incites \red<B> rage</B>\black in you just from looking at it!"
	icon = 'icons/obj/weapons.dmi'
	name = "deathnettle"
	icon_state = "deathnettle"
	damtype = "fire"
	force = 30
	hitsound = 'sound/weapons/bladeslice.ogg'
	throwforce = 15
	w_class = 1.0
	throw_speed = 1
	throw_range = 3
	plant_type = 1
	seed = "/obj/item/seeds/deathnettleseed"
	origin_tech = "combat=3"
	attack_verb = list("stung")
	New(var/loc, var/potency = 10)
		..()
		if(reagents)
			reagents.add_reagent("nutriment", 1)
			reagents.add_reagent("pacid", round(potency, 1))
		force = round((5+potency/2.5), 1)

	suicide_act(mob/user)
		viewers(user) << "<span class='suicide'>[user] is eating some of the [src.name]! It looks like \he's trying to commit suicide.</span>"
		return (BRUTELOSS|TOXLOSS)

/obj/item/weapon/grown/bananapeel
	name = "banana peel"
	desc = "A peel from a banana."
	icon = 'icons/obj/items.dmi'
	icon_state = "banana_peel"
	item_state = "banana_peel"
	w_class = 1.0
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	New(var/loc, var/potency = 10)
		..()

/obj/item/weapon/grown/corncob
	name = "corn cob"
	desc = "A reminder of meals gone by."
	icon = 'icons/obj/harvest.dmi'
	icon_state = "corncob"
	item_state = "corncob"
	w_class = 1.0
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	New(var/loc, var/potency = 10)
		..()
