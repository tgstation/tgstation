// **********************
// Other harvested materials from plants (that are not food)
// **********************

/obj/item/weapon/grown // Grown weapons
	name = "grown_weapon"
	icon = 'icons/obj/hydroponics/harvest.dmi'
	var/seed = null
	var/plantname = ""
	var/product	//a type path
	var/lifespan = 0
	var/endurance = 15
	var/maturation = 7
	var/production = 7
	var/yield = 2
	var/potency = 20
	var/plant_type = 0

/obj/item/weapon/grown/New(newloc, new_potency = 50)
	..()
	potency = new_potency
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

	transform *= TransformUsingVariable(potency, 100, 0.5)

	if(seed && lifespan == 0) //This is for adminspawn or map-placed growns. They get the default stats of their seed type. This feels like a hack but people insist on putting these things on the map...
		var/obj/item/seeds/S = new seed(src)
		lifespan = S.lifespan
		endurance = S.endurance
		maturation = S.maturation
		production = S.production
		yield = S.yield
		qdel(S) //Foods drop their contents when eaten, so delete the default seed.

	create_reagents(50)
	add_juice()

/obj/item/weapon/grown/proc/add_juice()
	if(reagents)
		return 1
	return 0

/obj/item/weapon/grown/log
	seed = /obj/item/seeds/towermycelium
	name = "tower-cap log"
	desc = "It's better than bad, it's good!"
	icon_state = "logs"
	force = 5
	throwforce = 5
	w_class = 3.0
	throw_speed = 2
	throw_range = 3
	plant_type = 2
	origin_tech = "materials=1"
	attack_verb = list("bashed", "battered", "bludgeoned", "whacked")
	var/plank_type = /obj/item/stack/sheet/mineral/wood
	var/plank_name = "wooden planks"
	var/list/accepted = list(/obj/item/weapon/reagent_containers/food/snacks/grown/tobacco,
	/obj/item/weapon/reagent_containers/food/snacks/grown/tobacco/space,
	/obj/item/weapon/reagent_containers/food/snacks/grown/tea/aspera,
	/obj/item/weapon/reagent_containers/food/snacks/grown/tea/astra,
	/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/vulgaris,
	/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/deus,
	/obj/item/weapon/reagent_containers/food/snacks/grown/wheat)


/obj/item/weapon/grown/log/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	..()
	if(istype(W, /obj/item/weapon/circular_saw) || istype(W, /obj/item/weapon/hatchet) || (istype(W, /obj/item/weapon/twohanded/fireaxe) && W:wielded) || istype(W, /obj/item/weapon/melee/energy))
		user.show_message("<span class='notice'>You make [plank_name] out of \the [src]!</span>", 1)
		var/obj/item/stack/plank = new plank_type(user.loc, 1 + round(potency / 25))
		var/old_plank_amount = plank.amount
		for(var/obj/item/stack/ST in user.loc)
			if(ST != plank && istype(ST, plank_type) && ST.amount < ST.max_amount)
				ST.attackby(plank, user) //we try to transfer all old unfinished stacks to the new stack we created.
		if(plank.amount > old_plank_amount)
			user << "<span class='notice'>You add the newly-formed [plank_name] to the stack. It now contains [plank.amount] [plank_name].</span>"
		qdel(src)

	if(is_type_in_list(W,accepted))
		var/obj/item/weapon/reagent_containers/food/snacks/grown/leaf = W
		if(leaf.dry)
			user.show_message("<span class='notice'>You wrap \the [W] around the log, turning it into a torch!</span>")
			var/obj/item/device/flashlight/flare/torch/T = new /obj/item/device/flashlight/flare/torch(user.loc)
			usr.unEquip(W)
			usr.put_in_active_hand(T)
			qdel(leaf)
			qdel(src)
			return
		else
			usr << "<span class ='warning'>You must dry this first!</span>"

/obj/item/weapon/grown/log/steel
	seed = /obj/item/seeds/steelmycelium
	name = "steel-cap log"
	desc = "It's made of metal."
	icon_state = "steellogs"
	accepted = list()
	plank_type = /obj/item/stack/rods
	plank_name = "rods"

/obj/item/weapon/grown/sunflower // FLOWER POWER!
	seed = /obj/item/seeds/sunflowerseed
	name = "sunflower"
	desc = "It's beautiful! A certain person might beat you to death if you trample these."
	icon_state = "sunflower"
	damtype = "fire"
	force = 0
	slot_flags = SLOT_HEAD
	throwforce = 0
	w_class = 1.0
	throw_speed = 1
	throw_range = 3

/obj/item/weapon/grown/sunflower/attack(mob/M as mob, mob/user as mob)
	M << "<font color='green'><b> [user] smacks you with a sunflower!</font><font color='yellow'><b>FLOWER POWER<b></font>"
	user << "<font color='green'>Your sunflower's </font><font color='yellow'><b>FLOWER POWER</b></font><font color='green'>strikes [M]</font>"


/obj/item/weapon/grown/novaflower
	seed = /obj/item/seeds/novaflowerseed
	name = "novaflower"
	desc = "These beautiful flowers have a crisp smokey scent, like a summer bonfire."
	icon_state = "novaflower"
	damtype = "fire"
	force = 0
	slot_flags = SLOT_HEAD
	throwforce = 0
	w_class = 1.0
	throw_speed = 1
	throw_range = 3
	plant_type = 0
	attack_verb = list("roasted", "scorched", "burned")

/obj/item/weapon/grown/novaflower/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1)
		reagents.add_reagent("capsaicin", round((potency / 3.5), 1))
		reagents.add_reagent("condensedcapsaicin", round((potency / 4), 1))
	force = round((5 + potency / 5), 1)

/obj/item/weapon/grown/novaflower/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(!..()) return
	if(istype(M, /mob/living))
		M << "<span class='danger'>You are lit on fire from the intense heat of the [name]!</span>"
		M.adjust_fire_stacks(potency / 20)
		M.IgniteMob()

/obj/item/weapon/grown/novaflower/afterattack(atom/A as mob|obj, mob/user as mob,proximity)
	if(!proximity) return
	if(endurance > 0)
		endurance -= rand(1, (endurance / 3) + 1)
	else
		usr << "<span class='warning'>All the petals have fallen off the [name] from violent whacking!</span>"
		usr.unEquip(src)
		qdel(src)

/obj/item/weapon/grown/novaflower/pickup(mob/living/carbon/human/user as mob)
	if(!user.gloves)
		user << "<span class='danger'>The [name] burns your bare hand!</span>"
		user.adjustFireLoss(rand(1, 5))


/obj/item/weapon/grown/nettle //abstract type
	name = "nettle"
	desc = "It's probably <B>not</B> wise to touch it with bare hands..."
	icon = 'icons/obj/weapons.dmi'
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
	attack_verb = list("stung")

/obj/item/weapon/grown/nettle/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is eating some of the [src.name]! It looks like \he's trying to commit suicide.</span>")
	return (BRUTELOSS|TOXLOSS)

/obj/item/weapon/grown/nettle/pickup(mob/living/user as mob)
	if(!iscarbon(user))
		return 0
	var/mob/living/carbon/C = user
	if(ishuman(user))
		var/mob/living/carbon/human/H = C
		if(H.gloves)
			return 0
		var/organ = ((H.hand ? "l_":"r_") + "arm")
		var/obj/item/organ/limb/affecting = H.get_organ(organ)
		if(affecting.take_damage(0, force))
			H.update_damage_overlays(0)
	else
		C.take_organ_damage(0,force)
	C << "<span class='userdanger'>The nettle burns your bare hand!</span>"
	return 1

/obj/item/weapon/grown/nettle/afterattack(atom/A as mob|obj, mob/user as mob,proximity)
	if(!proximity) return
	if(force > 0)
		force -= rand(1, (force / 3) + 1) // When you whack someone with it, leaves fall off
	else
		usr << "All the leaves have fallen off the nettle from violent whacking."
		usr.unEquip(src)
		qdel(src)


/obj/item/weapon/grown/nettle/basic
	seed = /obj/item/seeds/nettleseed

/obj/item/weapon/grown/nettle/basic/add_juice()
	..()
	reagents.add_reagent("sacid", round((potency / 2), 1))
	force = round((5 + potency / 5), 1)


/obj/item/weapon/grown/nettle/death
	seed = /obj/item/seeds/deathnettleseed
	name = "deathnettle"
	desc = "The <span class='danger'>glowing</span> \black nettle incites <span class='boldannounce'>rage</span>\black in you just from looking at it!"
	icon_state = "deathnettle"
	force = 30
	throwforce = 15
	origin_tech = "combat=3"

/obj/item/weapon/grown/nettle/death/add_juice()
	..()
	reagents.add_reagent("facid", round((potency / 2), 1))
	force = round((5 + potency / 2.5), 1)

/obj/item/weapon/grown/nettle/death/pickup(mob/living/carbon/user as mob)
	if(..())
		if(prob(50))
			user.Paralyse(5)
			user << "<span class='userdanger'>You are stunned by the Deathnettle when you try picking it up!</span>"

/obj/item/weapon/grown/nettle/death/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(!..()) return
	if(istype(M, /mob/living))
		M << "<span class='danger'>You are stunned by the powerful acid of the Deathnettle!</span>"
		add_logs(user, M, "attacked", object= "[src.name]")

		M.eye_blurry += force/7
		if(prob(20))
			M.Paralyse(force / 6)
			M.Weaken(force / 15)
		M.drop_item()


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

/obj/item/weapon/grown/bananapeel/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is deliberately slipping on the [src.name]! It looks like \he's trying to commit suicide.</span>")
	playsound(loc, 'sound/misc/slip.ogg', 50, 1, -1)
	return (BRUTELOSS)

/obj/item/weapon/grown/bananapeel/Crossed(AM as mob|obj)
	if (istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		var/stun = Clamp(potency / 10, 1, 10)
		var/weaken = Clamp(potency / 20, 0.5, 5)
		M.slip(stun, weaken, src)
		return 1

/obj/item/weapon/grown/bananapeel/specialpeel     //used by /obj/item/clothing/shoes/clown_shoes/banana_shoes
	name = "synthesized banana peel"
	desc = "A synthetic banana peel."

/obj/item/weapon/grown/bananapeel/specialpeel/Crossed(AM)
	if(..())	qdel(src)

/obj/item/weapon/grown/bananapeel/mimanapeel
	name = "mimana peel"
	desc = "A mimana peel."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "mimana_peel"


/obj/item/weapon/grown/corncob
	name = "corn cob"
	desc = "A reminder of meals gone by."
	icon_state = "corncob"
	item_state = "corncob"
	w_class = 1.0
	throwforce = 0
	throw_speed = 3
	throw_range = 7

/obj/item/weapon/grown/corncob/attackby(obj/item/weapon/grown/W as obj, mob/user as mob, params)
	..()
	if(is_sharp(W))
		user << "<span class='notice'>You use [W] to fashion a pipe out of the corn cob!</span>"
		new /obj/item/clothing/mask/cigarette/pipe/cobpipe (user.loc)
		user.unEquip(src)
		qdel(src)
		return

/obj/item/weapon/grown/snapcorn
	name = "snap corn"
	desc = "A cob with snap pops"
	icon_state = "snapcorn"
	item_state = "corncob"
	w_class = 1.0
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	var/snap_pops = 1

/obj/item/weapon/grown/snapcorn/add_juice()
	..()
	snap_pops = max(round(potency/8), 1)

/obj/item/weapon/grown/snapcorn/attack_self(mob/user as mob)
	..()
	user << "<span class='notice'>You pick up a snap pops from the cob.</span>"
	var/obj/item/toy/snappop/S = new /obj/item/toy/snappop(user.loc)
	if(ishuman(user))
		user.put_in_hands(S)
	snap_pops -= 1
	if(!snap_pops)
		new /obj/item/weapon/grown/corncob(user.loc)
		qdel(src)
