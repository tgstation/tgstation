/obj/item/weapon/miami
	name = "base hotline miami weapon"
	desc = "Yell at Xhuis if you see this!"
	icon = 'icons/obj/miami.dmi'
	icon_state = "miamiknife"
	throwforce = 10
	w_class = 1
	throw_speed = 2
	throw_range = 7
	force = 10
	m_amt = 10
	g_amt = 10

/obj/item/weapon/miami/knife
	name = "pocket knife"
	desc = "A small stainless-steel pocket knife. It's as sharp as the edge of a flatline."
	hitsound = 'sound/weapons/bladeslice.ogg'
	w_class = 2
	throwforce = 15
	m_amt = 75
	g_amt = 0
	embed_chance = 100
	embedded_fall_chance = 25

/obj/item/weapon/miami/bat
	name = "baseball bat"
	desc = "A heavy wooden baseball bat."
	icon_state = "miamibat"
	w_class = 4
	force = 17
	throwforce = 5
	throw_range = 3
	m_amt = 0
	g_amt = 0

/obj/item/weapon/miami/pipe
	name = "lead pipe"
	desc = "A section of lead piping. It seems designed to transport hydrogen gas."
	icon_state = "miamipipe"
	w_class = 3
	force = 12
	throwforce = 5
	throw_range = 4
	m_amt = 100
	g_amt = 0

/obj/item/weapon/twohanded/golf_club
	name = "golf club"
	desc = "A golf club. It's long, heavy, and worn down - probably because of all its use in Paris."
	icon = 'icons/obj/miami.dmi'
	icon_state = "miamigolf0"
	w_class = 4
	force = 5
	force_unwielded = 5
	force_wielded = 17
	throwforce = 3
	throw_range = 1
	m_amt = 200
	g_amt = 0

/obj/item/weapon/twohanded/golf_club/update_icon()
	icon_state = "miamigolf[wielded]"
	return

/obj/item/weapon/miami/frying_pan
	name = "frying pan"
	desc = "A grease-free steel frying pan. Reminds you of silver lights."
	icon_state = "miamipan"
	hitsound = 'sound/items/trayhit2.ogg'
	w_class = 3
	force = 14
	throwforce = 4
	m_amt = 150
	g_amt = 0

/obj/item/weapon/twohanded/sledgehammer
	name = "sledgehammer"
	desc = "A massive sledgehammer. It's unwieldly and probably more effective in two hands."
	icon = 'icons/obj/miami.dmi'
	icon_state = "miamisledgehammer0"
	force = 7
	force_unwielded = 7
	force_wielded = 22
	throwforce = 10
	throw_range = 1
	w_class = 5
	m_amt = 75 //the hammer head

/obj/item/weapon/twohanded/sledgehammer/update_icon()
	icon_state = "miamisledgehammer[wielded]"
	return

/obj/item/weapon/miami/machete
	name = "machete"
	desc = "A utilitarian machete. Bring out your inner animal."
	icon_state = "miamimachete"
	hitsound = 'sound/weapons/bladeslice.ogg'
	force = 12
	throwforce = 14
	embed_chance = 33
	embedded_fall_chance = 50
	m_amt = 105
	g_amt = 0

/obj/item/weapon/miami/hammer
	name = "hammer"
	desc = "A utility hammer, found in any good carpenter's toolbox. Used by assassins in deep cover."
	icon_state = "miamihammer"
	force = 9
	throwforce = 4
	m_amt = 25
