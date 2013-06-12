/obj/item/weapon/melee/baton
	name = "stunbaton"
	desc = "A stun baton for incapacitating people with."
	icon_state = "stunbaton"
	item_state = "baton"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	force = 10
	throwforce = 7
	w_class = 3
	origin_tech = "combat=2"
	attack_verb = list("beaten")
	var/stunforce = 10
	var/status = 0
	var/obj/item/weapon/cell/high/bcell = null
	var/hitcost = 1000

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is putting the live [name] in \his mouth! It looks like \he's trying to commit suicide.</b>"
		return (FIRELOSS)

/obj/item/weapon/melee/baton/New()
	..()
	update_icon()
	return

/obj/item/weapon/melee/baton/loaded/New() //this one starts with a cell pre-installed.
	..()
	bcell = new(src)
	update_icon()
	return

/obj/item/weapon/melee/baton/proc/deductcharge(var/chrgdeductamt)
	if(bcell)
		if(bcell.use(chrgdeductamt))
			return 1
		else
			status = 0
			update_icon()
			return 0

/obj/item/weapon/melee/baton/update_icon()
	if(status)
		icon_state = "[initial(name)]_active"
	else if(!bcell)
		icon_state = "[initial(name)]_nocell"
	else
		icon_state = "[initial(name)]"

/obj/item/weapon/melee/baton/examine()
	set src in view(1)
	..()
	if(bcell)
		usr <<"<span class='notice'>The baton is [round(bcell.percent())]% charged.</span>"
	if(!bcell)
		usr <<"<span class='warning'>The baton does not have a power source installed.</span>"

/obj/item/weapon/melee/baton/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/cell))
		if(!bcell)
			user.drop_item()
			W.loc = src
			bcell = W
			user << "<span class='notice'>You install a cell in [src].</span>"
			update_icon()
		else
			user << "<span class='notice'>[src] already has a cell.</span>"

	else if(istype(W, /obj/item/weapon/screwdriver))
		if(bcell)
			bcell.updateicon()
			bcell.loc = get_turf(src.loc)
			bcell = null
			user << "<span class='notice'>You remove the cell from the [src].</span>"
			status = 0
			update_icon()
			return
		..()
	return

/obj/item/weapon/melee/baton/attack_self(mob/user)
	if(bcell && bcell.charge > hitcost)
		status = !status
		user << "<span class='notice'>[src] is now [status ? "on" : "off"].</span>"
		playsound(loc, "sparks", 75, 1, -1)
		update_icon()
	else
		status = 0
		if(!bcell)
			user << "<span class='warning'>[src] does not have a power source!</span>"
		else
			user << "<span class='warning'>[src] is out of charge.</span>"
	add_fingerprint(user)

/obj/item/weapon/melee/baton/attack(mob/M, mob/user)
	if(status && (CLUMSY in user.mutations) && prob(50))
		user << "<span class='danger'>You accidentally hit yourself with [src]!</span>"
		user.Weaken(stunforce*3)
		deductcharge(hitcost)
		return

	if(isrobot(M))
		..()
		return
	if(!isliving(M))
		return

	var/mob/living/L = M

	if(user.a_intent == "harm")
		..()
		playsound(loc, "swing_hit", 50, 1, -1)

	else if(!status)
		L.visible_message("<span class='warning'>[L] has been prodded with [src] by [user]. Luckily it was off.</span>")
		return

	if(status)
		user.lastattacked = L
		L.lastattacker = user

		L.Stun(stunforce)
		L.Weaken(stunforce)
		L.apply_effect(STUTTER, stunforce)

		L.visible_message("<span class='danger'>[L] has been stunned with [src] by [user]!</span>")
		playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)

		if(isrobot(loc))
			var/mob/living/silicon/robot/R = loc
			if(R && R.cell)
				R.cell.use(hitcost)
		else
			deductcharge(hitcost)

		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			H.forcesay(hit_appends)

		user.attack_log += "\[[time_stamp()]\]<font color='red'> Stunned [L.name] ([L.ckey]) with [name]</font>"
		L.attack_log += "\[[time_stamp()]\]<font color='orange'> Stunned by [user.name] ([user.ckey]) with [name]</font>"
		log_attack("<font color='red'>[user.name] ([user.ckey]) stunned [L.name] ([L.ckey]) with [name]</font>" )

/obj/item/weapon/melee/baton/emp_act(severity)
	if(bcell)
		deductcharge(1000 / severity)
		if(bcell.reliability != 100 && prob(50/severity))
			bcell.reliability -= 10 / severity
	..()

//Makeshift stun baton. Replacement for stun gloves.
/obj/item/weapon/melee/baton/cattleprod
	name = "stunprod"
	desc = "An improvised stun baton."
	icon_state = "stunprod_nocell"
	item_state = "prod"
	force = 3
	throwforce = 5
	stunforce = 5
	hitcost = 2500
	slot_flags = null