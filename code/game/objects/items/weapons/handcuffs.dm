
/obj/item/weapon/restraints
	var/breakouttime = 600

//Handcuffs

/obj/item/weapon/restraints/handcuffs
	name = "handcuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "handcuff"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = 2.0
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL=500)
	origin_tech = "materials=1"
	breakouttime = 600 //Deciseconds = 60s = 1 minute
	var/cuffsound = 'sound/weapons/handcuffs.ogg'
	var/trashtype = null //for disposable cuffs

/obj/item/weapon/restraints/handcuffs/attack(mob/living/carbon/C, mob/living/carbon/human/user)
	if(!istype(C))
		return
	if(user.disabilities & CLUMSY && prob(50))
		user << "<span class='warning'>Uh... how do those things work?!</span>"
		apply_cuffs(user,user)
		return

	if(!C.handcuffed)
		C.visible_message("<span class='danger'>[user] is trying to put [src.name] on [C]!</span>", \
							"<span class='userdanger'>[user] is trying to put [src.name] on [C]!</span>")

		playsound(loc, cuffsound, 30, 1, -2)
		if(do_mob(user, C, 30))
			apply_cuffs(C,user)
			user << "<span class='notice'>You handcuff [C].</span>"
			if(istype(src, /obj/item/weapon/restraints/handcuffs/cable))
				feedback_add_details("handcuffs","C")
			else
				feedback_add_details("handcuffs","H")

			add_logs(user, C, "handcuffed")
		else
			user << "<span class='warning'>You fail to handcuff [C]!</span>"

/obj/item/weapon/restraints/handcuffs/proc/apply_cuffs(mob/living/carbon/target, mob/user)
	if(!target.handcuffed)
		if(!user.drop_item())
			return
		//target.throw_alert("handcuffed", src) // Can't do this because escaping cuffs isn't standardized. Also zipties.
		if(trashtype)
			target.handcuffed = new trashtype(target)
			qdel(src)
		else
			loc = target
			target.handcuffed = src
		target.update_inv_handcuffed(0)
		return

/obj/item/weapon/restraints/handcuffs/cable
	name = "cable restraints"
	desc = "Looks like some cables tied together. Could be used to tie something up."
	icon_state = "cuff_red"
	item_state = "coil_red"
	breakouttime = 300 //Deciseconds = 30s
	cuffsound = 'sound/weapons/cablecuff.ogg'

/obj/item/weapon/restraints/handcuffs/cable/red
	icon_state = "cuff_red"

/obj/item/weapon/restraints/handcuffs/cable/yellow
	icon_state = "cuff_yellow"

/obj/item/weapon/restraints/handcuffs/cable/blue
	icon_state = "cuff_blue"
	item_state = "coil_blue"

/obj/item/weapon/restraints/handcuffs/cable/green
	icon_state = "cuff_green"

/obj/item/weapon/restraints/handcuffs/cable/pink
	icon_state = "cuff_pink"

/obj/item/weapon/restraints/handcuffs/cable/orange
	icon_state = "cuff_orange"

/obj/item/weapon/restraints/handcuffs/cable/cyan
	icon_state = "cuff_cyan"

/obj/item/weapon/restraints/handcuffs/cable/white
	icon_state = "cuff_white"

/obj/item/weapon/restraints/handcuffs/cable/attackby(var/obj/item/I, mob/user as mob, params)
	..()
	if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = I
		if (R.use(1))
			var/obj/item/weapon/wirerod/W = new /obj/item/weapon/wirerod
			if(!remove_item_from_storage(user))
				user.unEquip(src)
			user.put_in_hands(W)
			user << "<span class='notice'>You wrap the cable restraint around the top of the rod.</span>"
			qdel(src)
		else
			user << "<span class='warning'>You need one rod to make a wired rod!</span>"
			return

/obj/item/weapon/restraints/handcuffs/cable/zipties/cyborg/attack(mob/living/carbon/C, mob/user)
	if(isrobot(user))
		if(!C.handcuffed)
			playsound(loc, 'sound/weapons/cablecuff.ogg', 30, 1, -2)
			C.visible_message("<span class='danger'>[user] is trying to put zipties on [C]!</span>", \
								"<span class='userdanger'>[user] is trying to put zipties on [C]!</span>")
			if(do_mob(user, C, 30))
				if(!C.handcuffed)
					C.handcuffed = new /obj/item/weapon/restraints/handcuffs/cable/zipties/used(C)
					C.update_inv_handcuffed(0)
					user << "<span class='notice'>You handcuff [C].</span>"
					add_logs(user, C, "handcuffed")
			else
				user << "<span class='warning'>You fail to handcuff [C]!</span>"

/obj/item/weapon/restraints/handcuffs/cable/zipties
	name = "zipties"
	desc = "Plastic, disposable zipties that can be used to restrain temporarily but are destroyed after use."
	icon_state = "cuff_white"
	breakouttime = 450 //Deciseconds = 45s
	trashtype = /obj/item/weapon/restraints/handcuffs/cable/zipties/used

/obj/item/weapon/restraints/handcuffs/cable/zipties/used
	desc = "A pair of broken zipties."
	icon_state = "cuff_white_used"

/obj/item/weapon/restraints/handcuffs/cable/zipties/used/attack()
	return


//Legcuffs

/obj/item/weapon/restraints/legcuffs
	name = "leg cuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "handcuff"
	flags = CONDUCT
	throwforce = 0
	w_class = 3.0
	origin_tech = "materials=1"
	slowdown = 7
	breakouttime = 300	//Deciseconds = 30s = 0.5 minute

/obj/item/weapon/restraints/legcuffs/beartrap
	name = "bear trap"
	throw_speed = 1
	throw_range = 1
	icon_state = "beartrap"
	desc = "A trap used to catch bears and other legged creatures."
	var/armed = 0
	var/trap_damage = 20

/obj/item/weapon/restraints/legcuffs/beartrap/New()
	..()
	icon_state = "[initial(icon_state)][armed]"

/obj/item/weapon/restraints/legcuffs/beartrap/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is sticking \his head in the [src.name]! It looks like \he's trying to commit suicide.</span>")
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return (BRUTELOSS)

/obj/item/weapon/restraints/legcuffs/beartrap/attack_self(mob/user as mob)
	..()
	if(ishuman(user) && !user.stat && !user.restrained())
		armed = !armed
		icon_state = "[initial(icon_state)][armed]"
		user << "<span class='notice'>[src] is now [armed ? "armed" : "disarmed"]</span>"

/obj/item/weapon/restraints/legcuffs/beartrap/Crossed(AM as mob|obj)
	if(armed && isturf(src.loc))
		if(isliving(AM))
			var/mob/living/L = AM
			var/snap = 0
			var/def_zone = "chest"
			if(iscarbon(L))
				var/mob/living/carbon/C = L
				snap = 1
				if(!C.lying)
					def_zone = pick("l_leg", "r_leg")
					if(!C.legcuffed) //beartrap can't cuff your leg if there's already a beartrap or legcuffs.
						C.legcuffed = src
						src.loc = C
						C.update_inv_legcuffed(0)
						feedback_add_details("handcuffs","B") //Yes, I know they're legcuffs. Don't change this, no need for an extra variable. The "B" is used to tell them apart.
			else if(isanimal(L))
				var/mob/living/simple_animal/SA = L
				if(!SA.flying && SA.mob_size > MOB_SIZE_TINY)
					snap = 1
			if(snap)
				armed = 0
				icon_state = "[initial(icon_state)][armed]"
				playsound(src.loc, 'sound/effects/snap.ogg', 50, 1)
				L.visible_message("<span class='danger'>[L] triggers \the [src].</span>", \
						"<span class='userdanger'>You trigger \the [src]!</span>")
				L.apply_damage(trap_damage,BRUTE, def_zone)
	..()

/obj/item/weapon/restraints/legcuffs/beartrap/energy
	name = "energy snare"
	armed = 1
	icon_state = "e_snare"
	trap_damage = 0

/obj/item/weapon/restraints/legcuffs/beartrap/energy/New()
	..()
	spawn(100)
		if(!istype(loc, /mob))
			var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread
			sparks.set_up(1, 1, src)
			sparks.start()
			qdel(src)

/obj/item/weapon/restraints/legcuffs/beartrap/energy/dropped()
	..()
	qdel(src)

/obj/item/weapon/restraints/legcuffs/beartrap/energy/attack_hand(mob/user)
	Crossed(user) //honk
