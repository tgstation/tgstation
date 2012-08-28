/obj/item/weapon/dice
	name = "d6"
	desc = "A dice with six sides."
	var/sides = 6
	icon = 'icons/obj/dice.dmi'
	icon_state = "d66"

/obj/item/weapon/dice/New()
	icon_state = "[name][rand(sides)]"

/obj/item/weapon/dice/d20
	name = "d20"
	desc = "A dice with twenty sides."
	sides = 20
	icon_state = "d2020"

/obj/item/weapon/dice/attack_self(mob/user as mob)
	var/result = rand(1, sides)
	var/comment = ""
	if(sides == 20 && result == 20)
		comment = "Nat 20!"
	else if(sides == 20 && result == 1)
		comment = "Ouch, bad luck."
	icon_state = "[name][result]"
	user.visible_message("<span class='notice'>[user] has thrown [src]. It lands on [result]. [comment]</span>", \
						 "<span class='notice'>You throw [src]. It lands on a [result]. [comment]</span>", \
						 "<span class='notice'>You hear [src] landing on a [result]. [comment]</span>")