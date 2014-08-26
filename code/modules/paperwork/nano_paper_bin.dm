/obj/item/weapon/paper_bin/nano
	name = "Nano paper dispenser"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "np_dispenser"
	item_state = "sheet-metal"
	throwforce = 1
	w_class = 3
	throw_speed = 3
	throw_range = 3
	var/ressources = 30	// how much nano paper it contains
	var/max_ressources = 30 // the maxium amount of paper it can contain, un-used for now
	autoignition_temperature = 1000 // Kelvin
	fire_fuel = 1


/obj/item/weapon/paper_bin/nano/MouseDrop(mob/user as mob)
	if((user == usr && (!( usr.restrained() ) && (!( usr.stat ) && (usr.contents.Find(src) || in_range(src, usr))))))
		if(!istype(usr, /mob/living/carbon/slime) && !istype(usr, /mob/living/simple_animal))
			if( !usr.get_active_hand() )		//if active hand is empty
				src.loc = user
				user.put_in_hands(src)
				user.visible_message("<span class='notice'>[user] picks up the [src].</span>", "<span class='notice'>You pick-up the [src]</span>")

	return


/obj/item/weapon/paper_bin/nano/attack_paw(mob/user as mob)
	return attack_hand(user)


/obj/item/weapon/paper_bin/nano/attack_hand(mob/user as mob)
	if(ressources > 0)
		ressources--
		var/obj/item/weapon/paper/nano/p
		p = new /obj/item/weapon/paper/nano
		p.loc = user.loc
		user.put_in_hands(p)
		user << "<span class='notice'>the [src] spits out a [p]</span>"
		if(ressources == 0)
			user << "<span class=notice> The dispenser is now empty!"
	else
		user << "<span class='notice'>The [src] is empty!</span>"
		update_icon()
	add_fingerprint(user)
	return


/obj/item/weapon/paper_bin/nano/attackby(var/obj/item/stack/sheet/plasteel/i as obj, mob/user as mob)
	if(!istype(i))
		return
	if(ressources > 0)
		user << "<span class=notice> The dispenser needs to be empty before it can be reloaded!"
		return

	user << "<span class='notice'>you load the [i] in the dispenser</span>"
	i:amount--
	if(i:amount < 1)
		del(i)
	ressources += 30
	update_icon()


/obj/item/weapon/paper_bin/nano/examine()
	set src in oview(1)
	var/desc = "<span class='notice'>This machine dispenses nano paper</span>"
	usr << desc

	if(in_range(usr, src))
		if(ressources)
			usr << "<span class='notice'>There is [ressources] nano paper left in the dispenser!</span>"
		else
			usr << "<span class='notice'>The nano paper dispenser is empty! add more plasteel to refil!</span>"
		return


/obj/item/weapon/paper_bin/nano/update_icon()
	if(ressources < 1)
		icon_state = "np_dispenser_empty"
	else
		icon_state = "np_dispenser"