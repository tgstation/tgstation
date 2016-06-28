
/************************
* PORTABLE TURRET COVER *
************************/

/obj/machinery/porta_turret_cover
	name = "turret"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "turretCover"
	anchored = 1
	layer = HIGH_OBJ_LAYER
	density = 0
	var/obj/machinery/porta_turret/parent_turret = null


//The below code is pretty much just recoded from the initial turret object. It's necessary but uncommented because it's exactly the same!
//>necessary
//I'm not fixing it because i'm fucking bored of this code already, but someone should just reroute these to the parent turret's procs.

/obj/machinery/porta_turret_cover/attack_ai(mob/user)
	. = ..()
	if(.)
		return

	return parent_turret.attack_ai(user)


/obj/machinery/porta_turret_cover/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	return parent_turret.attack_hand(user)


/obj/machinery/porta_turret_cover/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/wrench) && !parent_turret.on)
		if(parent_turret.raised)
			return

		if(!parent_turret.anchored)
			parent_turret.anchored = 1
			parent_turret.invisibility = INVISIBILITY_OBSERVER
			parent_turret.icon_state = "grey_target_prism"
			user << "<span class='notice'>You secure the exterior bolts on the turret.</span>"
		else
			parent_turret.anchored = 0
			user << "<span class='notice'>You unsecure the exterior bolts on the turret.</span>"
			parent_turret.icon_state = "turretCover"
			parent_turret.invisibility = 0
			qdel(src)

	else if(I.GetID())
		if(parent_turret.allowed(user))
			parent_turret.locked = !parent_turret.locked
			user << "<span class='notice'>Controls are now [parent_turret.locked ? "locked" : "unlocked"].</span>"
			updateUsrDialog()
		else
			user << "<span class='notice'>Access denied.</span>"
	else if(istype(I,/obj/item/device/multitool) && !parent_turret.locked)
		var/obj/item/device/multitool/M = I
		M.buffer = parent_turret
		user << "<span class='notice'>You add [parent_turret] to multitool buffer.</span>"
	else
		return ..()

/obj/machinery/porta_turret_cover/attacked_by(obj/item/I, mob/user)
	parent_turret.attacked_by(I, user)

/obj/machinery/porta_turret_cover/can_be_overridden()
	. = 0

/obj/machinery/porta_turret_cover/emag_act(mob/user)
	if(!parent_turret.emagged)
		user << "<span class='notice'>You short out [parent_turret]'s threat assessment circuits.</span>"
		visible_message("[parent_turret] hums oddly...")
		parent_turret.emagged = 1
		parent_turret.on = 0
		spawn(40)
			parent_turret.on = 1
