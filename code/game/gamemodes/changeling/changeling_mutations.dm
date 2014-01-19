//This only contains the arm blade for now because I'm a lazy fuck. Yers truely, Miauw, resident lazy fuck.
/obj/item/weapon/melee/arm_blade
	name = "arm blade"
	desc = "A grotesque blade made out of bone and flesh that cleaves through people as a hot knife through butter"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "arm_blade"
	item_state = "arm_blade"
	flags = ABSTRACT
	w_class = 5.0
	force = 25
	throwforce = 0 //Just to be on the safe side
	throw_range = 0
	throw_speed = 0

/obj/item/weapon/melee/arm_blade/New()
	..()
	loc.visible_message("<span class='warning'>A grotesque blade forms around [name]\'s arm!</span>", "<span class='warning'>Your arm twists and mutates, transforming it into a deadly blade.</span>", "<span class='warning'>You hear organic matter ripping and tearing!</span>")

/obj/item/weapon/melee/arm_blade/dropped(mob/user)
	visible_message("<span class='warning'>With a sickening crunch, [user] reforms his blade into an arm!</span>", "<span class='notice'>You assimilate your blade into your body</span>", "<span class='warning>You hear organic matter ripping and tearing!</span>")
	del src

/obj/item/weapon/melee/arm_blade/afterattack(atom/target, mob/user, proximity)
	if(istype(target, /obj/structure/table))
		var/obj/structure/table/T = target
		T.table_destroy(1, user)

	if(istype(target, /obj/machinery/computer))
		var/obj/machinery/computer/C = target
		C.attack_alien(user)
