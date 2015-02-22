//Zipties. Stackable handcuffs for operators.

/obj/item/stack/zipties
	name = "zipties"
	desc = "Plastic, stackable handcuffs that can be used to restrain temporarily but are destroyed after use. For true operators."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "cuff_white"
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = 2.0
	throw_speed = 3
	throw_range = 5
	amount = 5
	max_amount = 5
	var/breakouttime = 300 //Deciseconds = 30s

/obj/item/stack/zipties/used
	desc = "A pair of broken, unusable zipties."
	icon_state = "cuff_white_used"

/obj/item/stack/zipties/used/attack()
	return

/obj/item/stack/zipties/attack(mob/living/carbon/C, mob/living/carbon/human/user)
	if(user.disabilities & CLUMSY && prob(50))
		user << "<span class='warning'>Uh... how do those things work?!</span>"
		apply_cuffs(user,user)

	if(!C.handcuffed)
		C.visible_message("<span class='danger'>[user] is trying to ziptie [C]!</span>", \
							"<span class='userdanger'>[user] is trying to ziptie [C]!</span>")

		playsound(loc, 'sound/weapons/cablecuff.ogg', 30, 1, -2)
		if(do_mob(user, C, 30))
			apply_cuffs(C,user)
			user << "<span class='notice'>You ziptie [C].</span>"
			feedback_add_details("zipties","C")

			add_logs(user, C, "ziptied")
		else
			user << "<span class='warning'>You fail to ziptie [C].</span>"

/obj/item/stack/zipties/proc/apply_cuffs(mob/living/carbon/target, mob/user)
	if(!target.handcuffed)
		if(use(1))
			target.handcuffed = new /obj/item/stack/zipties/used(target)
			target.update_inv_handcuffed(0)
			return

/obj/item/stack/zipties/cyborg
	is_cyborg = 1
	cost = 100