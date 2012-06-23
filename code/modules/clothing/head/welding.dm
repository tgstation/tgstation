/obj/item/clothing/head/welding
	name = "welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye."
	icon_state = "welding"
	flags = FPRINT | TABLEPASS | SUITSPACE | HEADCOVERSEYES | HEADCOVERSMOUTH
	see_face = 0.0
	item_state = "welding"
	protective_temperature = 1300
	m_amt = 3000
	g_amt = 1000
	var/up = 0
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES


	attack_self()
		toggle()


	verb/toggle()
		set category = "Object"
		set name = "Adjust welding mask"
		set src in usr

		if(usr.canmove && !usr.stat && !usr.restrained())
			if(src.up)
				src.up = !src.up
				src.see_face = !src.see_face
				src.flags |= HEADCOVERSEYES
				flags_inv |= HIDEMASK|HIDEEARS|HIDEEYES
				icon_state = "welding"
				usr << "You flip the mask down to protect your eyes."
			else
				src.up = !src.up
				src.see_face = !src.see_face
				src.flags &= ~HEADCOVERSEYES
				flags_inv &= ~(HIDEMASK|HIDEEARS|HIDEEYES)
				icon_state = "weldingup"
				usr << "You push the mask up out of your face."
			usr.update_inv_head()	//so our mob-overlays update