// Assuming this is http://en.wikipedia.org/wiki/Butane
// (Autoignition temp 288°C, or 561.15°K)
// Used in fueltanks exploding.
#define AUTOIGNITION_WELDERFUEL 561.15

/obj/structure/reagent_dispensers
	name = "Dispenser"
	desc = "..."
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"
	density = 1
	anchored = 0
	flags = FPRINT
	pressure_resistance = 2*ONE_ATMOSPHERE

	var/amount_per_transfer_from_this = 10
	var/possible_transfer_amounts = list(10,25,50,100)

/obj/structure/reagent_dispensers/attackby(obj/item/weapon/W as obj, mob/user as mob)
	return

/obj/structure/reagent_dispensers/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>It contains:</span>")
	if(reagents && reagents.reagent_list.len)
		for(var/datum/reagent/R in reagents.reagent_list)
			to_chat(user, "<span class='info'>[R.volume] units of [R.name]</span>")
	else
		to_chat(user, "<span class='info'>Nothing.</span>")

/obj/structure/reagent_dispensers/cultify()
	new /obj/structure/reagent_dispensers/bloodkeg(get_turf(src))
	..()

/obj/structure/reagent_dispensers/verb/set_APTFT() //set amount_per_transfer_from_this
	set name = "Set transfer amount"
	set category = "Object"
	set src in view(1)
	var/N = input("Amount per transfer from this:","[src]") as null|anything in possible_transfer_amounts
	if (N)
		amount_per_transfer_from_this = N

/obj/structure/reagent_dispensers/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				new /obj/effect/effect/water(src.loc)
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				new /obj/effect/effect/water(src.loc)
				qdel(src)
				return
		else
	return

/obj/structure/reagent_dispensers/blob_act()
	if(prob(50))
		new /obj/effect/effect/water(src.loc)
		qdel(src)

/obj/structure/reagent_dispensers/New()
	. = ..()
	create_reagents(1000)

	if (!possible_transfer_amounts)
		verbs -= /obj/structure/reagent_dispensers/verb/set_APTFT

/obj/structure/reagent_dispensers/proc/is_empty()
	return reagents.total_volume <= 0

//Dispensers
/obj/structure/reagent_dispensers/watertank
	name = "watertank"
	desc = "A watertank"
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"
	amount_per_transfer_from_this = 10

/obj/structure/reagent_dispensers/watertank/New()
	. = ..()
	reagents.add_reagent("water", 1000)

/obj/structure/reagent_dispensers/fueltank
	name = "fueltank"
	desc = "A fueltank"
	icon = 'icons/obj/objects.dmi'
	icon_state = "weldtank"
	amount_per_transfer_from_this = 10
	var/modded = 0
	var/obj/item/device/assembly_holder/rig = null

/*/obj/structure/reagent_dispensers/fueltank/hear_talk(mob/living/M, text)
	if(rig)
		rig.hear_talk(M,text)
*/

/obj/structure/reagent_dispensers/fueltank/examine(mob/user)
	..()
	if (modded)
		to_chat(user, "<span class='warning'>Fuel faucet is wrenched open, leaking the fuel!</span>")
	if(rig)
		to_chat(user, "<span class='notice'>There is some kind of device rigged to the tank.</span>")

/obj/structure/reagent_dispensers/fueltank/attack_hand()
	if (rig)
		usr.visible_message("[usr] begins to detach [rig] from \the [src].", "You begin to detach [rig] from \the [src]")
		if(do_after(usr, src, 20))
			usr.visible_message("<span class='notice'>[usr] detaches [rig] from \the [src].", "<span class='notice'> You detach [rig] from \the [src]</span>")
			if(rig)
				rig.loc = get_turf(usr)
				rig = null
			overlays = new/list()

/obj/structure/reagent_dispensers/fueltank/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W,/obj/item/weapon/wrench))
		user.visible_message("[user] wrenches [src]'s faucet [modded ? "closed" : "open"].", \
			"You wrench [src]'s faucet [modded ? "closed" : "open"]")
		modded = modded ? 0 : 1
	if (istype(W,/obj/item/device/assembly_holder))
		if (rig)
			to_chat(user, "<span class='warning'>There is another device in the way.</span>")
			return ..()
		user.visible_message("[user] begins rigging [W] to \the [src].", "You begin rigging [W] to \the [src]")
		if(do_after(user, src, 20))
			user.visible_message("<span class='notice'>[user] rigs [W] to \the [src].", "<span class='notice'> You rig [W] to \the [src]</span>")

			var/obj/item/device/assembly_holder/H = W
			if (istype(H.a_left,/obj/item/device/assembly/igniter) || istype(H.a_right,/obj/item/device/assembly/igniter))
				message_admins("[key_name_admin(user)] rigged fueltank at ([loc.x],[loc.y],[loc.z]) for explosion.")
				log_game("[key_name(user)] rigged fueltank at ([loc.x],[loc.y],[loc.z]) for explosion.")

			rig = W
			user.drop_item(W, src)

			var/icon/test = getFlatIcon(W)
			test.Shift(NORTH,1)
			test.Shift(EAST,6)
			overlays += test

	return ..()

/obj/structure/reagent_dispensers/fueltank/beam_connect(var/obj/effect/beam/B)
	..()
	apply_beam_damage(B)


/obj/structure/reagent_dispensers/fueltank/beam_disconnect(var/obj/effect/beam/B)
	..()
	apply_beam_damage(B)

/obj/structure/reagent_dispensers/fueltank/apply_beam_damage(var/obj/effect/beam/B)
	if(isturf(get_turf(src)) && B.get_damage() >= 15)
		explode()

/obj/structure/reagent_dispensers/fueltank/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet)||istype(Proj,/obj/item/projectile/ricochet))
		if(!istype(Proj ,/obj/item/projectile/beam/lastertag) && !istype(Proj ,/obj/item/projectile/beam/practice) )
			log_attack("<font color='red'>[key_name(Proj.firer)] shot [src]/([formatJumpTo(src)]) with a [Proj.type]</font>")
			if(Proj.firer)//turrets don't have "firers"
				Proj.firer.attack_log += "\[[time_stamp()]\] <b>[key_name(Proj.firer)]</b> shot <b>[src]([x],[y],[z])</b> with a <b>[Proj.type]</b>"
				msg_admin_attack("[key_name(Proj.firer)] shot [src]/([formatJumpTo(src)]) with a [Proj.type] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[Proj.firer.x];Y=[Proj.firer.y];Z=[Proj.firer.z]'>JMP</a>)") //BS12 EDIT ALG
			else
				msg_admin_attack("[src] was shot by a [Proj.type] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)") //BS12 EDIT ALG
			explode()

/obj/structure/reagent_dispensers/fueltank/blob_act()
	explode()

/obj/structure/reagent_dispensers/fueltank/ex_act()
	explode()

/obj/structure/reagent_dispensers/fueltank/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature >= AUTOIGNITION_WELDERFUEL)
		explode()

/obj/structure/reagent_dispensers/fueltank/Bumped(atom/AM)
	if (istype(AM, /obj/structure/bed/chair/vehicle/wizmobile))
		visible_message("<span class='danger'>\the [AM] crashes into \the [src]!!</span>")
		explode()
	return ..()

/obj/structure/reagent_dispensers/fueltank/proc/explode()
	if (reagents.total_volume > 500)
		explosion(src.loc,1,2,4)
	else if (reagents.total_volume > 100)
		explosion(src.loc,0,1,3)
	else
		explosion(src.loc,-1,1,2)
	if(src)
		qdel(src)

/obj/structure/reagent_dispensers/fueltank/New()
	. = ..()
	reagents.add_reagent("fuel", 1000)

/obj/structure/reagent_dispensers/peppertank
	name = "Pepper Spray Refiller"
	desc = "Refill pepper spray canisters."
	icon = 'icons/obj/objects.dmi'
	icon_state = "peppertank"
	anchored = 1
	density = 0
	amount_per_transfer_from_this = 45

/obj/structure/reagent_dispensers/peppertank/New()
	. = ..()
	reagents.add_reagent("condensedcapsaicin", 1000)

/obj/structure/reagent_dispensers/water_cooler
	name = "Water-Cooler"
	desc = "A machine that dispenses water to drink."
	amount_per_transfer_from_this = 5
	icon = 'icons/obj/vending.dmi'
	icon_state = "water_cooler"
	possible_transfer_amounts = null
	anchored = 1
	var/addedliquid = 500
	var/paper_cups = 10

/obj/structure/reagent_dispensers/water_cooler/New()
	. = ..()
	reagents.add_reagent("water", addedliquid)
	desc = "[initial(desc)] There's [paper_cups] paper cups stored inside."

/obj/structure/reagent_dispensers/water_cooler/attack_hand(mob/user as mob)
	if(paper_cups > 0)
		user.put_in_hands(new/obj/item/weapon/reagent_containers/food/drinks/sillycup())
		to_chat(user, "You pick up an empty paper cup from \the [src]")
		paper_cups--
		desc = "[initial(desc)] There's [paper_cups] paper cups stored inside."

/obj/structure/reagent_dispensers/water_cooler/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/structure/reagent_dispensers/water_cooler/attackby(obj/item/I as obj, mob/user as mob)
	if (iswelder(I))
		var/obj/item/weapon/weldingtool/WT = I
		if(WT.remove_fuel(0, user))
			new /obj/item/stack/sheet/mineral/plastic (src.loc,4)
			qdel(src)
			return
	else
		..()

/obj/structure/reagent_dispensers/beerkeg
	name = "beer keg"
	desc = "A beer keg"
	icon = 'icons/obj/objects.dmi'
	icon_state = "beertankTEMP"
	amount_per_transfer_from_this = 10

/obj/structure/reagent_dispensers/beerkeg/New()
	. = ..()
	reagents.add_reagent("beer", 1000)

/obj/structure/reagent_dispensers/bloodkeg
	name = "old keg"
	desc = "A very old-looking keg. Some red liquid periodically drips from it."
	icon = 'icons/obj/objects.dmi'
	icon_state = "bloodkeg"
	amount_per_transfer_from_this = 10

/obj/structure/reagent_dispensers/bloodkeg/New()
	. = ..()
	reagents.add_reagent("blood", 1000)

/obj/structure/reagent_dispensers/bloodkeg/cultify()
	return

/obj/structure/reagent_dispensers/beerkeg/blob_act()
	explosion(src.loc,0,3,5,7,10)
	qdel(src)

/obj/structure/reagent_dispensers/virusfood
	name = "Virus Food Dispenser"
	desc = "A dispenser of virus food."
	icon = 'icons/obj/objects.dmi'
	icon_state = "virusfoodtank"
	amount_per_transfer_from_this = 10
	anchored = 1

/obj/structure/reagent_dispensers/virusfood/New()
	. = ..()
	reagents.add_reagent("virusfood", 1000)

/obj/structure/reagent_dispensers/corn_oil_tank
	name = "oil vat"
	desc = "The greasiest place on the station, outside the captain's backroom."
	icon = 'icons/obj/objects.dmi'
	icon_state = "cornoiltank"
	amount_per_transfer_from_this = 50

/obj/structure/reagent_dispensers/corn_oil_tank/New()
	. = ..()
	reagents.add_reagent("cornoil", 1000)

/obj/structure/reagent_dispensers/silicate
	name = "\improper Silicate Tank"
	desc = "A tank filled with silicate."
	icon = 'icons/obj/objects.dmi'
	icon_state = "silicate tank"
	amount_per_transfer_from_this = 50

/obj/structure/reagent_dispensers/silicate/New()
	. = ..()
	reagents.add_reagent("silicate", 1000)

/obj/structure/reagent_dispensers/silicate/attackby(var/obj/item/W, var/mob/user)
	. = ..()
	if(.)
		return

	if(issilicatesprayer(W))
		var/obj/item/device/silicate_sprayer/S = W
		if(S.get_amount() >= S.max_silicate) // Already filled.
			to_chat(user, "<span class='notice'>\The [S] is already full!</span>")
			return

		reagents.trans_to(S, S.max_silicate)
		S.update_icon()
		to_chat(user, "<span class='notice'>Sprayer refilled.</span>")
		playsound(get_turf(src), 'sound/effects/refill.ogg', 50, 1, -6)
		return 1
