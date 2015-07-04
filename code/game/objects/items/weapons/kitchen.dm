/* Kitchen tools
 * Contains:
 *		Fork
 *		Kitchen knives
 *		Butcher's cleaver
 *		Rolling Pins
 */

/obj/item/weapon/kitchen
	icon = 'icons/obj/kitchen.dmi'

/obj/item/weapon/kitchen/fork
	name = "fork"
	desc = "Pointy."
	icon_state = "fork"
	force = 5.0
	w_class = 1.0
	throwforce = 0
	throw_speed = 3
	throw_range = 5
	flags = CONDUCT
	origin_tech = "materials=1"
	attack_verb = list("attacked", "stabbed", "poked")
	hitsound = 'sound/weapons/bladeslice.ogg'
	var/datum/reagent/forkload //used to eat omelette

/obj/item/weapon/kitchen/fork/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!istype(M))
		return ..()

	if(forkload)
		if(M == user)
			M.visible_message("<span class='notice'>[user] eats a delicious forkful of omelette!</span>")
			M.reagents.add_reagent(forkload.id, 1)
		else
			M.visible_message("<span class='notice'>[user] feeds [M] a delicious forkful of omelette!</span>")
			M.reagents.add_reagent(forkload.id, 1)
		icon_state = "fork"
		forkload = null
		return

	else if(user.zone_sel.selecting == "eyes")
		if(user.disabilities & CLUMSY && prob(50))
			M = user
		return eyestab(M,user)
	else
		return ..()


/obj/item/weapon/kitchen/knife
	name = "kitchen knife"
	icon_state = "knife"
	desc = "A general purpose Chef's Knife made by SpaceCook Incorporated. Guaranteed to stay sharp for years to come."
	flags = CONDUCT
	force = 10.0
	w_class = 2.0
	throwforce = 10.0
	hitsound = 'sound/weapons/bladeslice.ogg'
	throw_speed = 3
	throw_range = 6
	materials = list(MAT_METAL=12000)
	origin_tech = "materials=1"
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/kitchen/knife/suicide_act(mob/user)
	user.visible_message(pick("<span class='suicide'>[user] is slitting \his wrists with the [src.name]! It looks like \he's trying to commit suicide.</span>", \
						"<span class='suicide'>[user] is slitting \his throat with the [src.name]! It looks like \he's trying to commit suicide.</span>", \
						"<span class='suicide'>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</span>"))
	return (BRUTELOSS)

/obj/item/weapon/kitchen/knife/ritual
	name = "ritual knife"
	desc = "The unearthly energies that once powered this blade are now dormant."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	w_class = 3.0

/obj/item/weapon/kitchen/knife/butcher
	name = "butcher's cleaver"
	icon_state = "butch"
	desc = "A huge thing used for chopping and chopping up meat. This includes clowns and clown-by-products."
	flags = CONDUCT
	force = 15.0
	throwforce = 8.0
	attack_verb = list("cleaved", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	w_class = 3.0

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

/* Trays  moved to /obj/item/weapon/storage/bag */
