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
 *		Whetstone
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

/obj/item/weapon/kitchen/utensil/fork/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!istype(M))
		return ..()

	if(user.zone_sel.selecting != "eyes" && user.zone_sel.selecting != "head")
		return ..()

	if (src.icon_state == "forkloaded") //This is a poor way of handling it, but a proper rewrite of the fork to allow for a more varied foodening can happen when I'm in the mood. --NEO
		if(M == user)
			M.visible_message("<span class='notice'>[user] eats a delicious forkful of omelette!</span>")
			M.reagents.add_reagent("nutriment", 1)
		else
			M.visible_message("<span class='notice'>[user] feeds [M] a delicious forkful of omelette!</span>")
			M.reagents.add_reagent("nutriment", 1)
		src.icon_state = "fork"
		return
	else
		if(user.disabilities & CLUMSY && prob(50))
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

/obj/item/weapon/kitchen/utensil/knife/suicide_act(mob/user)
	user.visible_message(pick("<span class='suicide'>[user] is slitting \his wrists with the [src.name]! It looks like \he's trying to commit suicide.</span>", \
						"<span class='suicide'>[user] is slitting \his throat with the [src.name]! It looks like \he's trying to commit suicide.</span>", \
						"<span class='suicide'>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</span>"))
	return (BRUTELOSS)

/obj/item/weapon/kitchen/utensil/knife/attack(target, mob/living/carbon/human/user)
	if(istype(user) && user.disabilities & CLUMSY && prob(50))
		user << "<span class='danger'>You accidentally cut yourself with \the [src].</span>"
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
	materials = list(MAT_METAL=12000)
	sharp = 1
	origin_tech = "materials=1"
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

	dismember_class = new /datum/dismember_class/low

/obj/item/weapon/kitchenknife/suicide_act(mob/user)
	user.visible_message(pick("<span class='suicide'>[user] is slitting \his wrists with the [src.name]! It looks like \he's trying to commit suicide.</span>", \
						"<span class='suicide'>[user] is slitting \his throat with the [src.name]! It looks like \he's trying to commit suicide.</span>", \
						"<span class='suicide'>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</span>"))
	return (BRUTELOSS)

/obj/item/weapon/kitchenknife/ritual
	name = "ritual knife"
	desc = "The unearthly energies that once powered this blade are now dormant."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"

/*
 * Bucher's cleaver
 */
/obj/item/weapon/kitchenknife/butcher
	name = "butcher's cleaver"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "butch"
	desc = "A huge thing used for chopping and chopping up meat. This includes clowns and clown-by-products."
	flags = CONDUCT
	force = 15.0
	w_class = 3.0
	throwforce = 8.0
	throw_speed = 3
	throw_range = 6
	materials = list(MAT_METAL=12000)
	sharp = 1
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
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")

/* Trays moved to /obj/item/weapon/storage/bag */

/*
 * Whetstone
 */

/obj/item/weapon/kitchen/whetstone
	name = "Whetstone"
	desc = "A tool used for sharpening your knives to make it easier to bork bork bork."
	icon_state = "whetstone"
	force = 5.0
	throwforce = 3.0
	throw_speed = 3
	throw_range = 7
	w_class = 3.0
	attack_verb = list("beaten", "battered", "bludgeoned")
	origin_tech = "materials=3"


/obj/item/weapon/kitchen/whetstone/attackby(obj/item/weapon/W, mob/user)
	if(isSharpenable(W))
		sharpen(W, src, user)
	else
		user << "You cannot sharpen [W][(src.sharp)? "" : " further"]."
	..()

/obj/item/weapon/kitchen/whetstone/Destroy()
	visible_message("The [src] crumbles away")
	..()


/obj/item/proc/isSharpenable(var/obj/item/W) //Proc that governs if you can sharpen it
	if(W.sharp == 2) //Too sharp
		return 0
	if (istype(W, /obj/item/weapon/hatchet))
		return 1
	if (istype(W, /obj/item/weapon/kitchenknife)) //Includes cleavers
		return 1

	return 0 //If none of the above

/obj/item/proc/sharpen(var/obj/item/O, var/obj/item/weapon/kitchen/whetstone/W, var/mob/user)
	if(!user)
		return 0
	user << "You start sharpening the [O]"
	if(do_after(user, 30, target = O))
		user.visible_message("[src] sharpens the [O]","You sharpen \the [O]", "You hear grinding")
		O.sharp++
		O.force += 9
		O.throwforce += 7
		O.name = "sharpened " + O.name
		qdel(W)
		return 1
	return 0

/obj/item/weapon/hatchet
	name = "hatchet"
	desc = "A very sharp axe blade upon a short fibremetal handle. It has a long history of chopping things, but now it is used for chopping wood."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "hatchet"
	flags = CONDUCT
	force = 12.0
	w_class = 1.0
	throwforce = 15.0
	throw_speed = 3
	throw_range = 4
	materials = list(MAT_METAL=15000)
	sharp = 1
	origin_tech = "materials=2;combat=1"
	attack_verb = list("chopped", "torn", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'

	dismember_class = new /datum/dismember_class/low/

/obj/item/weapon/hatchet/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is chopping at \himself with the [src.name]! It looks like \he's trying to commit suicide.</span>")
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return (BRUTELOSS)


/obj/item/weapon/scythe
	icon_state = "scythe0"
	name = "scythe"
	desc = "A sharp and curved blade on a long fibremetal handle, this tool makes it easy to reap what you sow."
	force = 13.0
	throwforce = 5.0
	throw_speed = 2
	throw_range = 3
	w_class = 4.0
	sharp = 1
	flags = CONDUCT | NOSHIELD
	slot_flags = SLOT_BACK
	origin_tech = "materials=2;combat=2"
	attack_verb = list("chopped", "sliced", "cut", "reaped")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/weapon/scythe/suicide_act(mob/user)  // maybe later i'll actually figure out how to make it behead them
	user.visible_message("<span class='suicide'>[user] is beheading \himself with the [src.name]! It looks like \he's trying to commit suicide.</span>")
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return (BRUTELOSS)