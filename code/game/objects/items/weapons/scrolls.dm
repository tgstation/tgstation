/obj/item/weapon/teleportation_scroll
	name = "scroll of teleportation"
	desc = "A scroll for moving around."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"
	var/uses = 4.0
	flags = FPRINT | TABLEPASS
	w_class = 2.0
	item_state = "paper"
	throw_speed = 4
	throw_range = 20
	origin_tech = "bluespace=4"

/obj/item/weapon/teleportation_scroll/attack_self(mob/user as mob)
	user.machine = src
	var/dat = "<B>Teleportation Scroll:</B><BR>"
	dat += "Number of uses: [src.uses]<BR>"
	dat += "<HR>"
	dat += "<B>Four uses use them wisely:</B><BR>"
	dat += "<A href='byond://?src=\ref[src];spell_teleport=1'>Teleport</A><BR>"
	dat += "Kind regards,<br>Wizards Federation<br><br>P.S. Don't forget to bring your gear, you'll need it to cast most spells.<HR>"
	user << browse(dat, "window=scroll")
	onclose(user, "scroll")
	return

/obj/item/weapon/teleportation_scroll/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained() || src.loc != usr)
		return
	var/mob/living/carbon/human/H = usr
	if (!( istype(H, /mob/living/carbon/human)))
		return 1
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))))
		usr.machine = src
		if (href_list["spell_teleport"])
			if (src.uses >= 1)
				src.uses -= 1
				usr.teleportscroll()
		if (istype(src.loc, /mob))
			attack_self(src.loc)
		else
			for(var/mob/M in viewers(1, src))
				if (M.client)
					src.attack_self(M)
	return