//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/obj/item/weapon/paper_bin
	name = "paper bin"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_bin1"
	item_state = "sheet-metal"
	throwforce = 1
	w_class = 3
	throw_speed = 3
	throw_range = 7
	pressure_resistance = 10
	var/amount = 30	//How much paper is in the bin.
	var/list/papers = new/list() //List of papers put in the bin for reference.
	var/sealed = 1  //If it's brandnew and unopened, it's sealed.

	MouseDrop(mob/user as mob)
		if ((user == usr && (!( usr.restrained() ) && (!( usr.stat ) && (usr.contents.Find(src) || in_range(src, usr))))))
			if(!istype(usr, /mob/living/carbon/metroid) && !istype(usr, /mob/living/simple_animal))
				if( !usr.get_active_hand() )		//if active hand is empty
					attack_hand(usr, 1, 1)

		return


	attack_paw(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		if (amount >= 1)
			amount--
			if(amount==0)
				update_icon()

			var/obj/item/weapon/paper/P
			if (papers.len > 0) // If there's any custom paper on the stack, use that instead of creating a new paper.
				P = papers[papers.len]
				papers.Remove(P)
			else
				P = new /obj/item/weapon/paper
				if(Holiday == "April Fool's Day")
					if(prob(30))
						P.info = "<font face=\"[P.crayonfont]\" color=\"red\"><b>HONK HONK HONK HONK HONK HONK HONK<br>HOOOOOOOOOOOOOOOOOOOOOONK<br>APRIL FOOLS</b></font>"
						P.rigged = 1
						P.updateinfolinks()

			P.loc = user.loc
			if(ishuman(user))
				user.put_in_hands(P)
				user << "<span class='notice'>You take a paper out of the bin.</span>"
			else
				P.loc = get_turf_loc(src)
				user << "<span class='notice'>You take a paper out of the bin.</span>"
		else
			user << "<span class='notice'>The paper bin is empty!</span>"

		add_fingerprint(user)
		return

	attackby(obj/item/weapon/paper/i as obj, mob/user as mob)
		if(!istype(i))
			return

		user.drop_item()
		i.loc = src
		usr << "<span class='notice'>You put the paper on the top of the paper bin.</span>"
		papers.Add(i)
		amount++

	examine()
		set src in oview(1)

		if(amount)
			usr << "<span class='notice'>There " + (amount > 1 ? "are [amount] papers" : "is one paper") + " in the bin.</span>"
		else
			usr << "<span class='notice'>There are no papers in the bin.</span>"
		return

	update_icon()
		if(amount < 1)
			icon_state = "paper_bin0"
		else
			icon_state = "paper_bin1"
