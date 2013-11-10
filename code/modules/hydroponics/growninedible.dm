// **********************
// Other harvested materials from plants (that are not food)
// **********************

/obj/item/weapon/grown // Grown weapons
	name = "grown_weapon"
	icon = 'icons/obj/weapons.dmi'
	var/seed = ""
	var/plantname = ""
	var/product	//a type path
	var/species = ""
	var/lifespan = 20
	var/endurance = 15
	var/maturation = 7
	var/production = 7
	var/yield = 2
	var/potency = 1
	var/plant_type = 0
	New()
		create_reagents(50)

/obj/item/weapon/grown/proc/changePotency(newValue) //-QualityVan
	potency = newValue

/obj/item/weapon/grown/log
	name = "tower-cap log"
	desc = "It's better than bad, it's good!"
	icon = 'icons/obj/harvest.dmi'
	icon_state = "logs"
	force = 5
	flags = TABLEPASS
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	plant_type = 2
	origin_tech = "materials=1"
	seed = "/obj/item/seeds/towermycelium"
	attack_verb = list("bashed", "battered", "bludgeoned", "whacked")

/obj/item/weapon/grown/log/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/circular_saw) || istype(W, /obj/item/weapon/hatchet) || (istype(W, /obj/item/weapon/twohanded/fireaxe) && W:wielded) || istype(W, /obj/item/weapon/melee/energy))
		user.show_message("<span class='notice'>You make planks out of the [src]!</span>", 1)
		for(var/i=0,i<2,i++)
			var/obj/item/stack/sheet/wood/NG = new (user.loc)
			for (var/obj/item/stack/sheet/wood/G in user.loc)
				if(G==NG)
					continue
				if(G.amount>=G.max_amount)
					continue
				G.attackby(NG, user)
				usr << "You add the newly-formed wood to the stack. It now contains [NG.amount] planks."
		del(src)
		return

/obj/item/weapon/grown/sunflower // FLOWER POWER!
	name = "sunflower"
	desc = "It's beautiful! A certain person might beat you to death if you trample these."
	icon = 'icons/obj/harvest.dmi'
	icon_state = "sunflower"
	damtype = "fire"
	force = 0
	flags = TABLEPASS
	slot_flags = SLOT_HEAD
	throwforce = 1
	w_class = 1.0
	throw_speed = 1
	throw_range = 3
	plant_type = 0
	seed = "/obj/item/seeds/sunflower"

/obj/item/weapon/grown/novaflower
	name = "novaflower"
	desc = "These beautiful flowers have a crisp smokey scent, like a summer bonfire."
	icon = 'icons/obj/harvest.dmi'
	icon_state = "novaflower"
	damtype = "fire"
	force = 0
	flags = TABLEPASS
	slot_flags = SLOT_HEAD
	throwforce = 1
	w_class = 1.0
	throw_speed = 1
	throw_range = 3
	plant_type = 0
	seed = "/obj/item/seeds/novaflower"
	attack_verb = list("seared", "heated", "whacked", "steamed")
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
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
	flags = TABLEPASS
	throwforce = 1
	w_class = 1.0
	throw_speed = 1
	throw_range = 3
	plant_type = 1
	origin_tech = "combat=1"
	seed = "/obj/item/seeds/nettleseed"
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
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
	flags = TABLEPASS
	throwforce = 1
	w_class = 1.0
	throw_speed = 1
	throw_range = 3
	plant_type = 1
	seed = "/obj/item/seeds/deathnettleseed"
	origin_tech = "combat=3"
	attack_verb = list("stung")
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1)
			reagents.add_reagent("pacid", round(potency, 1))
			force = round((5+potency/2.5), 1)

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is eating some of the [src.name]! It looks like \he's trying to commit suicide.</b>"
		return (BRUTELOSS|TOXLOSS)

