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
	throwforce = 0
	throw_speed = 3
	throw_range = 5
	flags = CONDUCT
	origin_tech = "materials=1"
	attack_verb = list("attacked", "stabbed", "poked")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/weapon/kitchen/utensil/New()
	if (prob(60))
		src.pixel_y = rand(0, 4)
	return

/*
 * Spoons
 */
 /obj/item/weapon/kitchen/utensil/spoon
	name = "spoon"
	desc = "SPOON!"
	icon_state = "spoon"
	attack_verb = list("attacked", "poked")

/*
 * Forks
 */
/obj/item/weapon/kitchen/utensil/fork
	name = "fork"
	desc = "Pointy."
	icon_state = "fork"

/obj/item/weapon/kitchen/utensil/fork/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return ..()

	if(user.zone_sel.selecting != "eyes" && user.zone_sel.selecting != "head")
		return ..()

	if (src.icon_state == "forkloaded") //This is a poor way of handling it, but a proper rewrite of the fork to allow for a more varied foodening can happen when I'm in the mood. --NEO
		if(M == user)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\blue [] eats a delicious forkful of omelette!", user), 1)
				M.reagents.add_reagent("nutriment", 1)
		else
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\blue [] feeds [] a delicious forkful of omelette!", user, M), 1)
				M.reagents.add_reagent("nutriment", 1)
		src.icon_state = "fork"
		return
	else
		if((CLUMSY in user.mutations) && prob(50))
			M = user
		return eyestab(M,user)

/*
 * Knives
 */
/obj/item/weapon/kitchen/utensil/knife
	name = "knife"
	desc = "Can cut through any food."
	icon_state = "knife"
	force = 10.0
	throwforce = 10.0

	suicide_act(mob/user)
		viewers(user) << pick("<span class='suicide'>[user] is slitting \his wrists with the [src.name]! It looks like \he's trying to commit suicide.</span>", \
							"<span class='suicide'>[user] is slitting \his throat with the [src.name]! It looks like \he's trying to commit suicide.</span>", \
							"<span class='suicide'>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</span>")
		return (BRUTELOSS)

/obj/item/weapon/kitchen/utensil/knife/attack(target as mob, mob/living/user as mob)
	if ((CLUMSY in user.mutations) && prob(50))
		user << "<span class='danger'> You accidentally cut yourself with the [src].</span>"
		user.take_organ_damage(20)
		return
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()

/*
 * Kitchen knives
 */
/obj/item/weapon/kitchenknife
	name = "kitchen knife"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "knife"
	desc = "A general purpose Chef's Knife made by SpaceCook Incorporated. Guaranteed to stay sharp for years to come."
	flags = CONDUCT
	force = 10.0
	w_class = 3.0
	throwforce = 10.0
	throw_speed = 3
	throw_range = 6
	m_amt = 12000
	origin_tech = "materials=1"
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

	suicide_act(mob/user)
		viewers(user) << pick("<span class='suicide'>[user] is slitting \his wrists with the [src.name]! It looks like \he's trying to commit suicide.</span>", \
							"<span class='suicide'>[user] is slitting \his throat with the [src.name]! It looks like \he's trying to commit suicide.</span>", \
							"<span class='suicide'>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</span>")
		return (BRUTELOSS)

/obj/item/weapon/kitchenknife/ritual
	name = "ritual knife"
	desc = "The unearthly energies that once powered this blade are now dormant."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"

/*
 * Bucher's cleaver
 */
/obj/item/weapon/butch
	name = "butcher's cleaver"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "butch"
	desc = "A huge thing used for chopping and chopping up meat. This includes clowns and clown-by-products."
	flags = CONDUCT
	force = 15.0
	w_class = 2.0
	throwforce = 8.0
	throw_speed = 3
	throw_range = 6
	m_amt = 12000
	origin_tech = "materials=1"
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("cleaved", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/*
 * Rolling Pins
 */

/obj/item/weapon/kitchen/rollingpin
	name = "rolling pin"
	desc = "Used to knock out the Bartender."
	icon_state = "rolling_pin"
	force = 8.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 7
	w_class = 3.0
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked") //I think the rollingpin attackby will end up ignoring this anyway.

/obj/item/weapon/kitchen/rollingpin/attack(mob/living/M as mob, mob/living/user as mob)
	if ((CLUMSY in user.mutations) && prob(50))
		user << "<span class='danger'>The [src] slips out of your hand and hits your head.</span>"
		user.take_organ_damage(10)
		user.Paralyse(2)
		return

	add_logs(user, M, "attacked", object="[src.name]")

	var/t = user:zone_sel.selecting
	if (t == "head")
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if (H.stat < 2 && H.health < 50 && prob(90))
				// ******* Check
				if (istype(H, /obj/item/clothing/head) && H.flags & 8 && prob(80))
					H << "<span class='danger'> The helmet protects you from being hit hard in the head!</span>"
					return
				var/time = rand(2, 6)
				if (prob(75))
					H.Paralyse(time)
				else
					H.Stun(time)
				if(H.stat != 2)	H.stat = 1
				user.visible_message("<span class='danger'>[H] has been knocked unconscious!</span>", "<span class='userdanger'>You knock [H] unconscious!</span>")
				return
			else
				H.visible_message("<span class='danger'> [user] tried to knock [H] unconscious!</span>", "<span class='danger'> [user] tried to knock you unconscious!</span>")
				H.eye_blurry += 3

	return ..()

/* Trays moved to /obj/item/weapon/storage/bag */
