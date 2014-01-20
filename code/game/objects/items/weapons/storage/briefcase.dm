/obj/item/weapon/storage/briefcase
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. Its owner must be a real professional."
	icon_state = "briefcase"
	flags = CONDUCT
	force = 10.0
	throw_speed = 1
	throw_range = 4
	w_class = 4.0
	max_w_class = 3
	max_combined_w_class = 21

/obj/item/weapon/storage/briefcase/New()
	..()
	new /obj/item/weapon/paper(src)
	new /obj/item/weapon/paper(src)
	new /obj/item/weapon/paper(src)
	new /obj/item/weapon/paper(src)
	new /obj/item/weapon/paper(src)
	new /obj/item/weapon/paper(src)
	new /obj/item/weapon/pen(src)

/obj/item/weapon/storage/briefcase/attack(mob/living/M as mob, mob/living/user as mob)
	if ((CLUMSY in user.mutations) && prob(50))
		user << "\red The [src] slips out of your hand and hits your head."
		user.take_organ_damage(10)
		user.Paralyse(2)
		return