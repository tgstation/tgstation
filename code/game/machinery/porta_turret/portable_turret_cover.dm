
/************************
* PORTABLE TURRET COVER *
************************/

/obj/machinery/porta_turret_cover
	name = "turret"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "turretCover"
	anchored = 1
	layer = 3.5
	density = 0
	var/obj/machinery/porta_turret/Parent_Turret = null


//The below code is pretty much just recoded from the initial turret object. It's necessary but uncommented because it's exactly the same!
//>necessary
//I'm not fixing it because i'm fucking bored of this code already, but someone should just reroute these to the parent turret's procs.

/obj/machinery/porta_turret_cover/attack_ai(mob/user)
	. = ..()
	if(.)
		return

	return Parent_Turret.attack_ai(user)


/obj/machinery/porta_turret_cover/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	return Parent_Turret.attack_hand(user)


/obj/machinery/porta_turret_cover/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/wrench) && !Parent_Turret.on)
		if(Parent_Turret.raised) return

		if(!Parent_Turret.anchored)
			Parent_Turret.anchored = 1
			Parent_Turret.invisibility = INVISIBILITY_OBSERVER
			Parent_Turret.icon_state = "grey_target_prism"
			user << "<span class='notice'>You secure the exterior bolts on the turret.</span>"
		else
			Parent_Turret.anchored = 0
			user << "<span class='notice'>You unsecure the exterior bolts on the turret.</span>"
			Parent_Turret.icon_state = "turretCover"
			Parent_Turret.invisibility = 0
			qdel(src)

	else if(istype(I, /obj/item/weapon/card/id)||istype(I, /obj/item/device/pda))
		if(Parent_Turret.allowed(user))
			Parent_Turret.locked = !Parent_Turret.locked
			user << "<span class='notice'>Controls are now [Parent_Turret.locked ? "locked" : "unlocked"].</span>"
			updateUsrDialog()
		else
			user << "<span class='notice'>Access denied.</span>"
	else if(istype(I,/obj/item/device/multitool) && !Parent_Turret.locked)
		var/obj/item/device/multitool/M = I
		M.buffer = Parent_Turret
		user << "<span class='notice'>You add [Parent_Turret] to multitool buffer.</span>"
	else
		user.changeNext_move(CLICK_CD_MELEE)
		Parent_Turret.health -= I.force * 0.5
		if(Parent_Turret.health <= 0)
			Parent_Turret.die()
		if(I.force * 0.5 > 2)
			if(!Parent_Turret.attacked && !Parent_Turret.emagged)
				Parent_Turret.attacked = 1
				spawn()
					sleep(30)
					Parent_Turret.attacked = 0
		..()

/obj/machinery/porta_turret_cover/can_be_overridden()
	. = 0

/obj/machinery/porta_turret_cover/emag_act(mob/user)
	if(!Parent_Turret.emagged)
		user << "<span class='notice'>You short out [Parent_Turret]'s threat assessment circuits.</span>"
		visible_message("[Parent_Turret] hums oddly...")
		Parent_Turret.emagged = 1
		Parent_Turret.on = 0
		sleep(40)
		Parent_Turret.on = 1
