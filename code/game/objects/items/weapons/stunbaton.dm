/obj/item/weapon/melee/baton
	name = "stun baton"
	desc = "A stun baton for incapacitating people with."
	icon_state = "stun baton"
	item_state = "baton"
	flags = FPRINT
	slot_flags = SLOT_BELT
	force = 10
	throwforce = 7
	w_class = 3
	origin_tech = "combat=2"
	attack_verb = list("beaten")
	var/stunforce = 10
	var/status = 0
	var/obj/item/weapon/cell/bcell = null
	var/hitcost = 100 // 10 hits on crap cell
	var/mob/foundmob = "" //Used in throwing proc.

	suicide_act(mob/user)
		to_chat(viewers(user), "<span class='danger'>[user] is putting the live [src.name] in \his mouth! It looks like \he's trying to commit suicide.</span>")
		return (FIRELOSS)

/obj/item/weapon/melee/baton/New()
	..()
	update_icon()
	return

/obj/item/weapon/melee/baton/loaded/New() //this one starts with a cell pre-installed.
	..()
	bcell = new(src)
	bcell.charge=bcell.maxcharge // Charge this shit
	update_icon()
	return

/obj/item/weapon/melee/baton/proc/deductcharge(var/chrgdeductamt)
	if(bcell)
		if(bcell.use(chrgdeductamt))
			if(bcell.charge < hitcost)
				status = 0
				update_icon()
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

/obj/item/weapon/melee/baton/examine(mob/user)
	..()
	if(bcell)
		to_chat(user, "<span class='info'>The baton is [round(bcell.percent())]% charged.</span>")
	if(!bcell)
		to_chat(user, "<span class='warning'>The baton does not have a power source installed.</span>")

/obj/item/weapon/melee/baton/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/cell))
		if(!bcell)
			user.drop_item(W, src)
			bcell = W
			to_chat(user, "<span class='notice'>You install a cell in [src].</span>")
			update_icon()
		else
			to_chat(user, "<span class='notice'>[src] already has a cell.</span>")

	else if(istype(W, /obj/item/weapon/screwdriver))
		if(bcell)
			bcell.updateicon()
			bcell.loc = get_turf(src.loc)
			bcell = null
			to_chat(user, "<span class='notice'>You remove the cell from the [src].</span>")
			status = 0
			update_icon()
			return
		..()
	return

/obj/item/weapon/melee/baton/attack_self(mob/user)
	if(status && (M_CLUMSY in user.mutations) && prob(50))
		user.simple_message("<span class='warning'>You grab the [src] on the wrong side.</span>",
			"<span class='danger'>The [name] blasts you with its power!</span>")
		user.Weaken(stunforce*3)
		deductcharge(hitcost)
		return
	if(bcell && bcell.charge >= hitcost)
		status = !status
		user.simple_message("<span class='notice'>[src] is now [status ? "on" : "off"].</span>",
			"<span class='notice'>[src] is now [pick("drowsy","hungry","thirsty","bored","unhappy")].</span>")
		playsound(loc, "sparks", 75, 1, -1)
		update_icon()
	else
		status = 0
		if(!bcell)
			user.simple_message("<span class='warning'>[src] does not have a power source!</span>",
				"<span class='warning'>[src] has no pulse and its soul has departed...</span>")
		else
			user.simple_message("<span class='warning'>[src] is out of charge.</span>",
				"<span class='warning'>[src] refuses to obey you.</span>")
	add_fingerprint(user)

/obj/item/weapon/melee/baton/attack(mob/M, mob/user)
	if(status && (M_CLUMSY in user.mutations) && prob(50))
		user.simple_message("<span class='danger'>You accidentally hit yourself with [src]!</span>",
			"<span class='danger'>The [name] goes mad!</span>")
		user.Weaken(stunforce*3)
		deductcharge(hitcost)
		return

	if(isrobot(M))
		..()
		return
	if(!isliving(M))
		return

	var/mob/living/L = M

	var/hit = 1
	if(user.a_intent == I_HURT)
		hit = ..()
		if(hit)
			playsound(loc, "swing_hit", 50, 1, -1)
	else
		hit = -1
		if(!status)
			L.visible_message("<span class='attack'>[L] has been prodded with the [src] by [user]. Luckily it was off.</span>",
				self_drugged_message="<span class='warning'>The [name] decides to spare this one.</span>")
			return

	if(status && hit)
		if(hit == -1)
			//Copypasted from human/attacked_by()
			var/target_zone = get_zone_with_miss_chance(user.zone_sel.selecting, L)
			if(user == L) // Attacking yourself can't miss
				target_zone = user.zone_sel.selecting
			if(!target_zone && !L.stat)
				visible_message("<span class='danger'>[user] misses [L] with \the [src]!</span>")
				return
		user.lastattacked = L
		L.lastattacker = user

		L.Stun(stunforce)
		L.Weaken(stunforce)
		L.apply_effect(STUTTER, stunforce)

		L.visible_message("<span class='danger'>[L] has been stunned with [src] by [user]!</span>",
			self_drugged_message="<span class='danger'>The [src.name] absorbs [L]'s life!</span>")
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
		if(!iscarbon(user))
			M.LAssailant = null
		else
			M.LAssailant = user

/obj/item/weapon/melee/baton/throw_impact(atom/hit_atom)
	foundmob = directory[ckey(fingerprintslast)]
	if (prob(50))
		if(istype(hit_atom, /mob/living))
			var/mob/living/L = hit_atom
			if(status)
				if(foundmob)
					foundmob.lastattacked = L
					L.lastattacker = foundmob

				L.Stun(stunforce)
				L.Weaken(stunforce)
				L.apply_effect(STUTTER, stunforce)

				L.visible_message("<span class='danger'>[L] has been stunned with [src] by [foundmob ? foundmob : "Unknown"]!</span>")
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

				foundmob.attack_log += "\[[time_stamp()]\]<font color='red'> Stunned [L.name] ([L.ckey]) with [name]</font>"
				L.attack_log += "\[[time_stamp()]\]<font color='orange'> Stunned by thrown [src] by [istype(foundmob) ? foundmob.name : ""] ([istype(foundmob) ? foundmob.ckey : ""])</font>"
				log_attack("<font color='red'>Flying [src.name], thrown by [istype(foundmob) ? foundmob.name : ""] ([istype(foundmob) ? foundmob.ckey : ""]) stunned [L.name] ([L.ckey])</font>" )
				if(!iscarbon(foundmob))
					L.LAssailant = null
				else
					L.LAssailant = foundmob

				return
	return ..()

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