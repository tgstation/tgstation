

//Creates a throwing star
/obj/item/clothing/suit/space/space_ninja/proc/ninjastar()
	set name = "Create Throwing Stars (1E)"
	set desc = "Creates some throwing stars"
	set category = "Ninja Ability"
	set popup_menu = 0

	if(!ninjacost(10))
		var/mob/living/carbon/human/H = affecting
		var/slot = H.hand ? slot_l_hand : slot_r_hand

		if(H.equip_to_slot_or_del(new /obj/item/weapon/throwing_star/ninja(H), slot))
			H << "<span class='notice'>A throwing star has been created in your hand!</span>"

		H.throw_mode_on() //So they can quickly throw it.


/obj/item/weapon/throwing_star/ninja
	name = "ninja throwing star"
	throwforce = 30
	embedded_pain_multiplier = 6
