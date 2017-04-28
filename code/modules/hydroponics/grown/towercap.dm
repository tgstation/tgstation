/obj/item/seeds/tower
	name = "pack of tower-cap mycelium"
	desc = "This mycelium grows into tower-cap mushrooms."
	icon_state = "mycelium-tower"
	species = "towercap"
	plantname = "Tower Caps"
	product = /obj/item/weapon/grown/log
	lifespan = 80
	endurance = 50
	maturation = 15
	production = 1
	yield = 5
	potency = 50
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	icon_dead = "towercap-dead"
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism)
	mutatelist = list(/obj/item/seeds/tower/steel)

/obj/item/seeds/tower/steel
	name = "pack of steel-cap mycelium"
	desc = "This mycelium grows into steel logs."
	icon_state = "mycelium-steelcap"
	species = "steelcap"
	plantname = "Steel Caps"
	product = /obj/item/weapon/grown/log/steel
	mutatelist = list()
	rarity = 20




/obj/item/weapon/grown/log
	seed = /obj/item/seeds/tower
	name = "tower-cap log"
	desc = "It's better than bad, it's good!"
	icon_state = "logs"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 2
	throw_range = 3
	origin_tech = "materials=1"
	attack_verb = list("bashed", "battered", "bludgeoned", "whacked")
	var/plank_type = /obj/item/stack/sheet/mineral/wood
	var/plank_name = "wooden planks"
	var/list/accepted = list(/obj/item/weapon/reagent_containers/food/snacks/grown/tobacco,
	/obj/item/weapon/reagent_containers/food/snacks/grown/tea,
	/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/vulgaris,
	/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/deus,
	/obj/item/weapon/reagent_containers/food/snacks/grown/wheat)


/obj/item/weapon/grown/log/attackby(obj/item/weapon/W, mob/user, params)
	if(W.sharpness)
		user.show_message("<span class='notice'>You make [plank_name] out of \the [src]!</span>", 1)
		var/seed_modifier = 0
		if(seed)
			seed_modifier = round(seed.potency / 25)
		var/obj/item/stack/plank = new plank_type(user.loc, 1 + seed_modifier)
		var/old_plank_amount = plank.amount
		for(var/obj/item/stack/ST in user.loc)
			if(ST != plank && istype(ST, plank_type) && ST.amount < ST.max_amount)
				ST.attackby(plank, user) //we try to transfer all old unfinished stacks to the new stack we created.
		if(plank.amount > old_plank_amount)
			to_chat(user, "<span class='notice'>You add the newly-formed [plank_name] to the stack. It now contains [plank.amount] [plank_name].</span>")
		qdel(src)

	if(is_type_in_list(W,accepted))
		var/obj/item/weapon/reagent_containers/food/snacks/grown/leaf = W
		if(leaf.dry)
			user.show_message("<span class='notice'>You wrap \the [W] around the log, turning it into a torch!</span>")
			var/obj/item/device/flashlight/flare/torch/T = new /obj/item/device/flashlight/flare/torch(user.loc)
			usr.dropItemToGround(W)
			usr.put_in_active_hand(T)
			qdel(leaf)
			qdel(src)
			return
		else
			to_chat(usr, "<span class ='warning'>You must dry this first!</span>")
	else
		return ..()

/obj/item/weapon/grown/log/tree
	seed = null
	name = "wood log"
	desc = "TIMMMMM-BERRRRRRRRRRR!"

/obj/item/weapon/grown/log/steel
	seed = /obj/item/seeds/tower/steel
	name = "steel-cap log"
	desc = "It's made of metal."
	icon_state = "steellogs"
	accepted = list()
	plank_type = /obj/item/stack/rods
	plank_name = "rods"


/////////BONFIRES//////////

/obj/structure/bonfire
	name = "bonfire"
	desc = "For grilling, broiling, charring, smoking, heating, roasting, toasting, simmering, searing, melting, and occasionally burning things."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "bonfire"
	density = FALSE
	anchored = TRUE
	buckle_lying = 0
	var/burning = 0
	var/fire_stack_strength = 5

/obj/structure/bonfire/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/rods) && !can_buckle)
		var/obj/item/stack/rods/R = W
		R.use(1)
		can_buckle = 1
		buckle_requires_restraints = 1
		to_chat(user, "<span class='italics'>You add a rod to [src].")
		var/mutable_appearance/rod_underlay = mutable_appearance('icons/obj/hydroponics/equipment.dmi', "bonfire_rod")
		rod_underlay.pixel_y = 16
		underlays += rod_underlay
	if(W.is_hot())
		StartBurning()


/obj/structure/bonfire/attack_hand(mob/user)
	if(burning)
		to_chat(user, "<span class='warning'>You need to extinguish [src] before removing the logs!")
		return
	if(!has_buckled_mobs() && do_after(user, 50, target = src))
		for(var/I in 1 to 5)
			var/obj/item/weapon/grown/log/L = new /obj/item/weapon/grown/log(src.loc)
			L.pixel_x += rand(1,4)
			L.pixel_y += rand(1,4)
		qdel(src)
		return
	..()


/obj/structure/bonfire/proc/CheckOxygen()
	if(isopenturf(loc))
		var/turf/open/O = loc
		if(O.air)
			var/G = O.air.gases
			if(G["o2"][MOLES] > 16)
				return 1
	return 0

/obj/structure/bonfire/proc/StartBurning()
	if(!burning && CheckOxygen())
		icon_state = "bonfire_on_fire"
		burning = 1
		set_light(6)
		Burn()
		START_PROCESSING(SSobj, src)

/obj/structure/bonfire/fire_act(exposed_temperature, exposed_volume)
	StartBurning()

/obj/structure/bonfire/Crossed(atom/movable/AM)
	if(burning)
		Burn()

/obj/structure/bonfire/proc/Burn()
	var/turf/current_location = get_turf(src)
	current_location.hotspot_expose(1000,500,1)
	for(var/A in current_location)
		if(A == src)
			continue
		if(isobj(A))
			var/obj/O = A
			O.fire_act(1000, 500)
		else if(isliving(A))
			var/mob/living/L = A
			L.adjust_fire_stacks(fire_stack_strength)
			L.IgniteMob()

/obj/structure/bonfire/process()
	if(!CheckOxygen())
		extinguish()
		return
	Burn()

/obj/structure/bonfire/extinguish()
	if(burning)
		icon_state = "bonfire"
		burning = 0
		set_light(0)
		STOP_PROCESSING(SSobj, src)

/obj/structure/bonfire/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	if(..())
		M.pixel_y += 13

/obj/structure/bonfire/unbuckle_mob(mob/living/buckled_mob, force=FALSE)
	if(..())
		buckled_mob.pixel_y -= 13
