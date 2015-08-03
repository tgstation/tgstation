/obj/item/weapon/tankmanip
	name = "\improper Plasma Tank Manipulator"
	desc = "A device used by engineering cyborgs to hold and manipulate plasma tanks. Holds up to 3 tanks at a time."
	icon = 'icons/mob/robot_items.dmi'
	icon_state = "tankmanip0"
	opacity = 0
	density = 0
	anchored = 0.0
	var/tanks = 0
	var/list/storedtanks = list()
	var/mode = 1
	w_class = 3.0

/obj/item/weapon/tankmanip/New()
	desc = "A device used by engineering cyborgs to hold and manipulate plasma tanks. Holds up to 3 tanks at a time."
	return

/obj/item/weapon/tankmanip/examine()
	..()
	usr << "<span class='notice'>It is loaded with [tanks] tanks.</span>"

/obj/item/weapon/tankmanip/update_icon()
	..()
	switch(tanks)
		if(0) icon_state = "tankmanip0"
		if(1) icon_state = "tankmanip1"
		if(2) icon_state = "tankmanip2"
		if(3) icon_state = "tankmanip3"

/obj/item/weapon/tankmanip/attack_self(mob/user)
	if(tanks)
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 0)
		while(tanks)
			var/obj/item/weapon/tank/internals/plasma/T = storedtanks[1]
			storedtanks.Remove(T)
			T.loc = usr.loc
			tanks = storedtanks.len
		user << "<span class='notice'>You unload the tanks on the floor.</span>"
		update_icon()
	return

/obj/item/weapon/tankmanip/afterattack(obj/O, mob/user, proximity)
	..()
	if (istype(O, /obj/item/weapon/tank/internals/plasma))
		if (tanks <= 2)
			playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
			user << "<span class='notice'>You pick up [O].</span>"
			storedtanks.Add(O)
			O.loc = src
			tanks++
		else
			user << "<span class='warning'>The manipulator is full!</span>"
			return
	//Picks up tanks from the world

	if (istype(O, /obj/machinery/portable_atmospherics) && tanks)
		var/obj/machinery/portable_atmospherics/PA = O
		if (PA.holding)
			user << "<span class='warning'>There is already a tank inside!</span>"
			return
		else
			playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
			var/obj/item/weapon/tank/internals/plasma/P
			if(storedtanks.len == tanks)
				P = storedtanks[1]
				storedtanks.Remove(P)
			P.loc = PA
			PA.holding = P
			tanks--
			PA.update_icon()

	if (istype(O, /obj/structure/dispenser) && tanks)
		var/obj/structure/dispenser/D = O
		if(D.plasmatanks == 10)
			user << "<span class='warning'>The dispenser is full!</span>"
			return 1
		while((tanks) && (D.plasmatanks < 10))
			var/obj/item/weapon/tank/internals/plasma/T = storedtanks[1]
			D.platanks.Add(T)
			storedtanks.Remove(T)
			T.loc = D
			D.plasmatanks++
			tanks--
		playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
		D.update_icon()
		D.updateUsrDialog()
		user << "<span class='notice'>You unload some tanks into the dispenser.</span>"
	update_icon()