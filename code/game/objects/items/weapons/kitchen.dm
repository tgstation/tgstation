/* Kitchen tools
 * Contains:
 *		Utensils
 *		Spoons
 *		Forks
 *		Knives
 *		Kitchen knives
 *		Butcher's cleaver
 *		Rolling Pins
 *		Trays
 */

/obj/item/weapon/kitchen
	icon = 'icons/obj/kitchen.dmi'

/*
 * Utensils
 */
/obj/item/weapon/kitchen/utensil
	force = 5.0
	w_class = 1.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	flags = FPRINT
	siemens_coefficient = 1
	origin_tech = "materials=1"
	attack_verb = list("attacked", "stabbed", "poked")

/obj/item/weapon/kitchen/utensil/New()
	. = ..()

	if (prob(60))
		src.pixel_y = rand(0, 4)

/*
 * Spoons
 */
/obj/item/weapon/kitchen/utensil/spoon
	name = "spoon"
	desc = "SPOON!"
	icon_state = "spoon"
	attack_verb = list("attacked", "poked")
	melt_temperature = MELTPOINT_STEEL

/obj/item/weapon/kitchen/utensil/spoon/plastic
	name = "plastic spoon"
	desc = "Super dull action!"
	icon_state = "pspoon"
	melt_temperature = MELTPOINT_PLASTIC

/*
 * Forks
 */
/obj/item/weapon/kitchen/utensil/fork
	name = "fork"
	desc = "Pointy."
	icon_state = "fork"
	sharpness = 0.6
	var/loaded_food_name
	var/image/loaded_food
	melt_temperature = MELTPOINT_STEEL

/obj/item/weapon/kitchen/utensil/fork/New()
	..()
	reagents = new(10)
	reagents.my_atom = src

/obj/item/weapon/kitchen/utensil/fork/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M) || !istype(user))
		return ..()

	if(user.zone_sel.selecting != "eyes" && user.zone_sel.selecting != "head" && M != user && !loaded_food)
		return ..()

	if (src.loaded_food)
		reagents.update_total()
		if(M == user)
			user.visible_message("<span class='notice'>[user] eats a delicious forkful of [loaded_food_name]!</span>")
		else
			user.visible_message("<span class='notice'>[user] feeds [M] a delicious forkful of [loaded_food_name]!</span>")
		reagents.reaction(M, INGEST)
		reagents.trans_to(M.reagents, reagents.total_volume)
		overlays -= loaded_food
		del(loaded_food)
		loaded_food_name = null
		return
	else
		if((M_CLUMSY in user.mutations) && prob(50))
			return eyestab(user,user)
		else
			return eyestab(M, user)

/obj/item/weapon/kitchen/utensil/fork/examine(mob/user)
	..()
	if(loaded_food)
		user.show_message("It has a forkful of [loaded_food_name] on it.")

/obj/item/weapon/kitchen/utensil/fork/proc/load_food(obj/item/weapon/reagent_containers/food/snacks/snack, mob/user)
	if(!snack || !user || !istype(snack) || !istype(user))
		return

	if(loaded_food)
		to_chat(user, "<span class='notice'>You already have food on \the [src].</span>")
		return

	if(snack.wrapped)
		to_chat(user, "<span class='notice'>You can't eat packaging!</span>")
		return

	if(snack.reagents.total_volume)
		loaded_food_name = snack.name
		var/icon/food_to_load = getFlatIcon(snack)
		food_to_load.Scale(16,16)
		loaded_food = image(food_to_load)
		loaded_food.pixel_x = 8 + src.pixel_x
		loaded_food.pixel_y = 15 + src.pixel_y
		src.overlays += loaded_food
		if(snack.reagents.total_volume > snack.bitesize)
			snack.reagents.trans_to(src, snack.bitesize)
		else
			snack.reagents.trans_to(src, snack.reagents.total_volume)
			snack.bitecount++
			snack.On_Consume(user)
	return 1

/obj/item/weapon/kitchen/utensil/fork/plastic
	name = "plastic fork"
	desc = "Yay, no washing up to do."
	icon_state = "pfork"
	melt_temperature = MELTPOINT_PLASTIC

/*
 * Knives
 */
/obj/item/weapon/kitchen/utensil/knife
	name = "knife"
	desc = "Can cut through any food."
	icon_state = "knife"
	force = 10.0
	throwforce = 10.0
	sharpness = 1.2
	melt_temperature = MELTPOINT_STEEL

/obj/item/weapon/kitchen/utensil/knife/suicide_act(mob/user)
	to_chat(viewers(user), pick("<span class='danger'>[user] is slitting \his wrists with the [src.name]! It looks like \he's trying to commit suicide.</span>", \
						"<span class='danger'>[user] is slitting \his throat with the [src.name]! It looks like \he's trying to commit suicide.</span>", \
						"<span class='danger'>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</span>"))
	return (BRUTELOSS)

/obj/item/weapon/kitchen/utensil/knife/attack(target as mob, mob/living/user as mob)
	if ((M_CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class='warning'>You accidentally cut yourself with the [src].</span>")
		user.take_organ_damage(20)
		return
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()

/obj/item/weapon/kitchen/utensil/knife/plastic
	name = "plastic knife"
	desc = "The bluntest of blades."
	icon_state = "pknife"
	force = 2
	throwforce = 1
	sharpness = 0.8
	melt_temperature = MELTPOINT_PLASTIC

/*
 * Kitchen knives
 */
/obj/item/weapon/kitchen/utensil/knife/large
	name = "kitchen knife"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "knife"
	desc = "A general purpose Chef's Knife made by SpaceCook Incorporated. Guaranteed to stay sharp for years to come."
	flags = FPRINT
	siemens_coefficient = 1
	sharpness = 1.5
	force = 10.0
	w_class = 3.0
	throwforce = 6.0
	throw_speed = 3
	throw_range = 6
	starting_materials = list(MAT_IRON = 12000)
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL
	origin_tech = "materials=1"
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/kitchen/utensil/knife/large/suicide_act(mob/user)
	to_chat(viewers(user), pick("<span class='danger'>[user] is slitting \his wrists with the [src.name]! It looks like \he's trying to commit suicide.</span>", \
						"<span class='danger'>[user] is slitting \his throat with the [src.name]! It looks like \he's trying to commit suicide.</span>", \
						"<span class='danger'>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</span>"))
	return (BRUTELOSS)

/obj/item/weapon/kitchen/utensil/knife/large/ritual
	name = "ritual knife"
	desc = "The unearthly energies that once powered this blade are now dormant."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"

/*
 * Butcher's cleaver
 */
/obj/item/weapon/kitchen/utensil/knife/large/butch
	name = "butcher's cleaver"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "butch"
	hitsound = "sound/weapons/rapidslice.ogg"
	desc = "A huge thing used for chopping and chopping up meat. This includes clowns and clown-by-products."
	flags = FPRINT
	siemens_coefficient = 1
	sharpness = 1.2
	force = 15.0
	w_class = 2.0
	throwforce = 8.0
	throw_speed = 3
	throw_range = 6
	starting_materials = list(MAT_IRON = 12000)
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL
	origin_tech = "materials=1"
	attack_verb = list("cleaved", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/kitchen/utensil/knife/large/butch/meatcleaver
	name = "meat cleaver"
	icon_state = "mcleaver"
	desc = "A huge thing used for chopping and chopping up meat. This includes clowns and clown-by-products."
	force = 25.0
	throwforce = 15.0

/obj/item/weapon/kitchen/utensil/knife/large/butch/meatcleaver/throw_impact(atom/hit_atom)
	if(istype(hit_atom, /mob/living) && prob(85))
		var/mob/living/L = hit_atom
		L.Stun(5)
		L.Weaken(5)
	return ..()

/*
 * Rolling Pins
 */

/obj/item/weapon/kitchen/rollingpin
	name = "rolling pin"
	desc = "Used to knock out the Bartender."
	icon_state = "rolling_pin"
	hitsound = "sound/weapons/smash.ogg"
	force = 8.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 7
	w_class = 3.0
	autoignition_temperature=AUTOIGNITION_WOOD
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked") //I think the rollingpin attackby will end up ignoring this anyway.

/obj/item/weapon/kitchen/rollingpin/attack(mob/living/M as mob, mob/living/user as mob)
	if ((M_CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class='warning'>The [src] slips out of your hand and hits your head.</span>")
		user.take_organ_damage(10)
		user.Paralyse(2)
		return
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")

	log_attack("<font color='red'>[user.name] ([user.ckey]) used the [src.name] to attack [M.name] ([M.ckey])</font>")
	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user

	var/t = user:zone_sel.selecting
	if (t == "head")
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if (H.stat < 2 && H.health < 50 && prob(90))
				// ******* Check
				if (istype(H, /obj/item/clothing/head) && H.flags & 8 && prob(80))
					to_chat(H, "<span class='warning'>The helmet protects you from being hit hard in the head!</span>")
					return
				var/time = rand(2, 6)
				if (prob(75))
					H.Paralyse(time)
				else
					H.Stun(time)
				if(H.stat != 2)	H.stat = 1
				user.visible_message("<span class='danger'><B>[H] has been knocked unconscious!</B>", "<span class='warning'>You knock [H] unconscious!</span></span>")
				return
			else
				H.visible_message("<span class='warning'>[user] tried to knock [H] unconscious!</span>", "<span class='warning'>[user] tried to knock you unconscious!</span>")
				H.eye_blurry += 3
	return ..()

/*
 * Trays - Agouri
 */
/obj/item/weapon/tray
	name = "tray"
	icon = 'icons/obj/food.dmi'
	icon_state = "tray"
	desc = "A metal tray to lay food on."
	throwforce = 12.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	flags = FPRINT
	siemens_coefficient = 1
	starting_materials = list(MAT_IRON = 3000)
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL
	var/list/carrying = list() // List of things on the tray. - Doohl
	var/max_carry = 10 // w_class = 1 -- takes up 1
					   // w_class = 2 -- takes up 3
					   // w_class = 3 -- takes up 5

/obj/item/weapon/tray/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)

	// Drop all the things. All of them.
	overlays.len = 0
	for(var/obj/item/I in carrying)
		I.loc = M.loc
		carrying.Remove(I)
		if(isturf(I.loc))
			spawn()
				for(var/i = 1, i <= rand(1,2), i++)
					if(I)
						step(I, pick(NORTH,SOUTH,EAST,WEST))
						sleep(rand(2,4))


	if((M_CLUMSY in user.mutations) && prob(50))              //What if he's a clown?
		to_chat(M, "<span class='warning'>You accidentally slam yourself with the [src]!</span>")
		M.Weaken(1)
		user.take_organ_damage(2)
		if(prob(50))
			playsound(M, 'sound/items/trayhit1.ogg', 50, 1)
			return
		else
			playsound(M, 'sound/items/trayhit2.ogg', 50, 1) //sound playin'
			return //it always returns, but I feel like adding an extra return just for safety's sakes. EDIT; Oh well I won't :3

	var/mob/living/carbon/human/H = M      ///////////////////////////////////// /Let's have this ready for later.


	if(!(user.zone_sel.selecting == ("eyes" || "head"))) //////////////hitting anything else other than the eyes
		if(prob(33))
			src.add_blood(H)
			var/turf/location = H.loc
			if (istype(location, /turf/simulated))
				location.add_blood(H)     ///Plik plik, the sound of blood

		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")

		log_attack("<font color='red'>[user.name] ([user.ckey]) used the [src.name] to attack [M.name] ([M.ckey])</font>")
		if(!iscarbon(user))
			M.LAssailant = null
		else
			M.LAssailant = user

		if(prob(15))
			M.Weaken(3)
			M.take_organ_damage(3)
		else
			M.take_organ_damage(5)
		if(prob(50))
			playsound(M, 'sound/items/trayhit1.ogg', 50, 1)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("<span class='danger'>[] slams [] with the tray!</span>", user, M), 1)
			return
		else
			playsound(M, 'sound/items/trayhit2.ogg', 50, 1)  //we applied the damage, we played the sound, we showed the appropriate messages. Time to return and stop the proc
			for(var/mob/O in viewers(M, null))
				O.show_message(text("<span class='danger'>[] slams [] with the tray!</span>", user, M), 1)
			return




	if(istype(M, /mob/living/carbon/human) && H.check_body_part_coverage(EYES))
		to_chat(H, "<span class='warning'>You get slammed in the face with the tray, against your mask!</span>")
		if(prob(33))
			src.add_blood(H)
			if (H.wear_mask)
				H.wear_mask.add_blood(H)
			if (H.head)
				H.head.add_blood(H)
			if (H.glasses && prob(33))
				H.glasses.add_blood(H)
			var/turf/location = H.loc
			if (istype(location, /turf/simulated))     //Addin' blood! At least on the floor and item :v
				location.add_blood(H)

		if(prob(50))
			playsound(M, 'sound/items/trayhit1.ogg', 50, 1)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("<span class='danger'>[] slams [] with the tray!</span>", user, M), 1)
		else
			playsound(M, 'sound/items/trayhit2.ogg', 50, 1)  //sound playin'
			for(var/mob/O in viewers(M, null))
				O.show_message(text("<span class='danger'>[] slams [] with the tray!</span>", user, M), 1)
		if(prob(10))
			M.Stun(rand(1,3))
			M.take_organ_damage(3)
			return
		else
			M.take_organ_damage(5)
			return

	else //No eye or head protection, tough luck!
		to_chat(M, "<span class='warning'>You get slammed in the face with the tray!</span>")
		if(prob(33))
			src.add_blood(M)
			var/turf/location = H.loc
			if (istype(location, /turf/simulated))
				location.add_blood(H)

		if(prob(50))
			playsound(M, 'sound/items/trayhit1.ogg', 50, 1)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("<span class='danger'>[] slams [] in the face with the tray!</span>", user, M), 1)
		else
			playsound(M, 'sound/items/trayhit2.ogg', 50, 1)  //sound playin' again
			for(var/mob/O in viewers(M, null))
				O.show_message(text("<span class='danger'>[] slams [] in the face with the tray!</span>", user, M), 1)
		if(prob(30))
			M.Stun(rand(2,4))
			M.take_organ_damage(4)
			return
		else
			M.take_organ_damage(8)
			if(prob(30))
				M.Weaken(2)
				return
			return

/obj/item/weapon/tray/var/cooldown = 0	//shield bash cooldown. based on world.time

/obj/item/weapon/tray/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/kitchen/rollingpin))
		if(cooldown < world.time - 25)
			user.visible_message("<span class='warning'>[user] bashes [src] with [W]!</span>")
			playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, 1)
			cooldown = world.time
	else
		..()

/*
===============~~~~~================================~~~~~====================
=																			=
=  Code for trays carrying things. By Doohl for Doohl erryday Doohl Doohl~  =
=																			=
===============~~~~~================================~~~~~====================
*/
/obj/item/weapon/tray/proc/calc_carry()
	// calculate the weight of the items on the tray
	var/val = 0 // value to return

	for(var/obj/item/I in carrying)
		if(I.w_class == 1.0)
			val ++
		else if(I.w_class == 2.0)
			val += 3
		else
			val += 5

	return val

/obj/item/weapon/tray/pickup(mob/user)

	if(!isturf(loc))
		return

	for(var/obj/item/I in loc)
		if( I != src && !I.anchored && !istype(I, /obj/item/clothing/under) && !istype(I, /obj/item/clothing/suit) && !istype(I, /obj/item/projectile) )
			var/add = 0
			if(I.w_class == 1.0)
				add = 1
			else if(I.w_class == 2.0)
				add = 3
			else
				add = 5
			if(calc_carry() + add >= max_carry)
				break

			I.loc = src
			carrying.Add(I)

			var/image/image = image(icon = null) //image(appearance = ...) doesn't work, and neither does image().
			image.appearance = I.appearance
			image.layer = I.layer + 30

			overlays += image
			//overlays += image("icon" = I.icon, "icon_state" = I.icon_state, "layer" = 30 + I.layer)

/obj/item/weapon/tray/dropped(mob/user)

	var/mob/living/M
	for(M in src.loc) //to handle hand switching
		return

	var/foundtable = 0
	for(var/obj/structure/table/T in loc)
		foundtable = 1
		break

	overlays.len = 0

	for(var/obj/item/I in carrying)
		I.loc = loc
		carrying.Remove(I)
		if(!foundtable && isturf(loc))
			// if no table, presume that the person just shittily dropped the tray on the ground and made a mess everywhere!
			spawn()
				for(var/i = 1, i <= rand(1,2), i++)
					if(I)
						step(I, pick(NORTH,SOUTH,EAST,WEST))
						sleep(rand(2,4))





/////////////////////////////////////////////////////////////////////////////////////////
//Enough with the violent stuff, here's what happens if you try putting food on it
/////////////////////////////////////////////////////////////////////////////////////////////



/*/obj/item/weapon/tray/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/kitchen/utensil/fork))
		if (W.icon_state == "forkloaded")
			to_chat(user, "<span class='warning'>You already have omelette on your fork.</span>")
			return
		W.icon = 'icons/obj/kitchen.dmi'
		W.icon_state = "forkloaded"
		to_chat(viewers(3,user), "[user] takes a piece of omelette with his fork!")
		reagents.remove_reagent("nutriment", 1)
		if (reagents.total_volume <= 0)
			del(src)*/


/*			if (prob(33))
						var/turf/location = H.loc
						if (istype(location, /turf/simulated))
							location.add_blood(H)
					if (H.wear_mask)
						H.wear_mask.add_blood(H)
					if (H.head)
						H.head.add_blood(H)
					if (H.glasses && prob(33))
						H.glasses.add_blood(H)
					if (istype(user, /mob/living/carbon/human))
						var/mob/living/carbon/human/user2 = user
						if (user2.gloves)
							user2.gloves.add_blood(H)
						else
							user2.add_blood(H)
						if (prob(15))
							if (user2.wear_suit)
								user2.wear_suit.add_blood(H)
							else if (user2.w_uniform)
								user2.w_uniform.add_blood(H)*/
