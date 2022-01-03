/obj/item/dye
	name = "dye"
	desc = "A small bottle of dye."
	icon = 'icons/obj/barber_and_tailor.dmi'
	icon_state = "dye_pack"

/obj/item/dye/attack(mob/living/dye_target, mob/living/dye_user, params)
	. = ..()
	if(.)
		return TRUE
	if(!dye_target.Adjacent(dye_user) || !ishuman(dye_target))
		return
	var/is_right_clicking = LAZYACCESS(params2list(params), RIGHT_CLICK)
	if(is_right_clicking)
		dye_user.balloon_alert(dye_user, "dying hair")
	else
		dye_user.balloon_alert(dye_user, "dying facial hair")
	if(do_after(dye_user, 5 SECONDS, dye_target))
		var/mob/living/carbon/human/human_dye_target = dye_target
		if(is_right_clicking)
			dye_user.balloon_alert(dye_user, "dyed hair")
			human_dye_target.facial_hair_color = color
			human_dye_target.update_hair()
			human_dye_target.dna.update_dna_identity()
		else
			dye_user.balloon_alert(dye_user, "dyed facial hair")
			human_dye_target.hair_color = color
			human_dye_target.update_hair()
			human_dye_target.dna.update_dna_identity()
		qdel(src)
