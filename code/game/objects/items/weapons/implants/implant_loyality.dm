/obj/item/weapon/implant/loyalty
	name = "mindshield implant"
	desc = "Protects against brainwashing."
	origin_tech = "materials=2;biotech=4;programming=4"
	activated = 0

/obj/item/weapon/implant/loyalty/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Nanotrasen Employee Management Implant<BR>
				<b>Life:</b> Ten years.<BR>
				<b>Important Notes:</b> Personnel injected with this device tend to be much more loyal to the company.<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a small pod of nanobots that will protect the hosts mental functions from outside influences.<BR>
				<b>Special Features:</b> Will prevent and cure most forms of brainwashing.<BR>
				<b>Integrity:</b> Implant will last so long as the nanobots are inside the bloodstream."}
	return dat


/obj/item/weapon/implant/loyalty/implant(mob/target)
	if(..())
		if((target.mind in (ticker.mode.head_revolutionaries | ticker.mode.get_gang_bosses())) || is_shadow_or_thrall(target))
			target.visible_message("<span class='warning'>The implant beeps out a warning. [target] is too corrupt to save!</span>", "<span class='warning'>You feel something trying to heal your mind...but you're too far gone.</span>")
			removed(target, 1)
			qdel(src)
			return -1
		if(target.mind in ticker.mode.get_gangsters())
			ticker.mode.remove_gangster(target.mind)
			target.visible_message("<span class='warning'>[src] was destroyed in the process!</span>", "<span class='notice'>You feel a sense of peace and security. You are now protected from brainwashing.</span>")
			removed(target, 1)
			qdel(src)
			return -1
		if(target.mind in ticker.mode.revolutionaries)
			ticker.mode.remove_revolutionary(target.mind)
		if(target.mind in ticker.mode.red_deity_followers|ticker.mode.blue_deity_followers)
			ticker.mode.remove_hog_follower(target.mind)
		if((target.mind in ticker.mode.cult) || (target.mind in ticker.mode.blue_deity_prophets|ticker.mode.red_deity_prophets))
			target << "<span class='warning'>You feel something trying to heal your mind...but you're too far gone!</span>"
		else
			target << "<span class='notice'>You feel a sense of peace and security. You are now protected from brainwashing.</span>"
		return 1
	return 0

/obj/item/weapon/implant/loyalty/removed(mob/target, var/silent = 0)
	if(..())
		if(target.stat != DEAD && !silent)
			target << "<span class='boldnotice'>Your mind suddenly feels terribly vulnerable. You are no longer safe from brainwashing.</span>"
		return 1
	return 0


/obj/item/weapon/implanter/loyalty
	name = "implanter (mindshield)"

/obj/item/weapon/implanter/loyalty/New()
	imp = new /obj/item/weapon/implant/loyalty(src)
	..()
	update_icon()


/obj/item/weapon/implantcase/loyalty
	name = "implant case - 'mindshield'"
	desc = "A glass case containing a mindshield implant."

/obj/item/weapon/implantcase/loyalty/New()
	imp = new /obj/item/weapon/implant/loyalty(src)
	..()