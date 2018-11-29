/obj/item/projectile/spellcard
	name = "enchanted card"
	desc = "A piece of paper enchanted to give it extreme durability and stiffness, along with a very hot burn to anyone unfortunate enough to get hit by a charged one."
	icon_state = "spellcard"
	damage_type = BURN
	damage = 2

/obj/item/projectile/spellcard/prehit(atom/A)
	. = ..()
	if(ismob(A))
		var/mob/M = A
		if(M.anti_magic_check())
			M.visible_message("<span class='warning'>[src] burns up and vanishes on contact with [M]!</span>")
			damage = 0
			return
