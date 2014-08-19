var/global/super_fryer = 1

/obj/machinery/deepfryer
	name = "deep fryer"
	desc = "Deep fried <i>everything</i>."
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "fryer_off"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 500
	var/on = FALSE	//Is it deep frying already?
	var/obj/item/frying = null	//What's being fried RIGHT NOW?

/obj/machinery/deepfryer/examine()
	..()
	if(frying)
		usr << "You can make out [frying] in the oil."

/obj/machinery/deepfryer/attackby(obj/item/I, mob/user)
	if(on)
		user << "<span class='notice'>[src] is currently deep frying something!</span>"
		return
	if(istype(I,/obj/item/weapon/wrench))
		if(!anchored)
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			if(do_after(user, 30))
				anchored = 1
				user << "You wrench [src] in place."
			return
		else
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			if(do_after(user, 30))
				anchored = 0
				user << "You unwrench [src]."
			return
	if(!anchored)
		user << "<span class='warning'>[src] must be anchored first!</span>"
		return
	if(!super_fryer == 1)
		if(!istype(I, /obj/item/weapon/reagent_containers/food))
			user << "Dear god man, that's not edible!"
			return
	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/deepfryholder))
		user << "<span class='userdanger'>[I] is already deepfried, you vomituous deviant.</span>"
		return
	if(istype(I, /obj/item/weapon/grab) || istype(I, /obj/item/tk_grab))
		user << "<span class='warning'>That isn't going to fit.</span>"
		return
	if(istype(I, /obj/item/weapon/reagent_containers/glass))
		user << "<span class='warning'>That would probably break [src].</span>"
		return
	if(istype(I, /obj/item/weapon/disk/nuclear))
		user << "Central command would kill you if you deep fried that."
		return
	user << "<span class='notice'>You put [I] into [src].</span>"
	on = TRUE
	user.drop_item()
	frying = I
	frying.loc = src
	icon_state = "fryer_on"
	sleep(200)

	if(frying && frying.loc == src)
		var/obj/item/weapon/reagent_containers/food/snacks/deepfryholder/S = new(get_turf(src))
		if(istype(frying, /obj/item/weapon/reagent_containers/))
			var/obj/item/weapon/reagent_containers/food = frying
			food.reagents.trans_to(S, food.reagents.total_volume)
		S.color = "#FFAD33"
		S.icon = frying.icon
		S.icon_state = frying.icon_state
		S.overlays += frying.overlays
		S.name = "deep fried [frying.name]"
		S.desc = I.desc
		qdel(frying)
		icon_state = "fryer_off"
		on = FALSE
		playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)


/obj/machinery/deepfryer/attack_hand(mob/user)
	if(istype(user, /mob/dead/observer))
		user << "You attempt to interact with the deep fryer. You notice your hand goes straight through the fryer. You wonder why you tried this." // WHO THE HELL MADE GHOSTS CALL ATTACK_HAND I NEVER ACCOUNTED FOR THIS - Iamgoofball
		return
	if(on && frying)
		user << "<span class='notice'>You pull [frying] from [src]! It looks like you were just in time!</span>"
		user.put_in_hands(frying)
		frying = null
		on = FALSE
		icon_state = "fryer_off"
		return
	..()

/client/proc/fryer_toggle()
	set name = "Toggle fryers frying non-food"
	set desc = "Toggle fryers frying non-food items."
	set category = "Debug"

	super_fryer = !super_fryer
	if(!super_fryer)
		world << "<b>Fryers can no longer fry non-food items.</b>"
		log_admin("[key_name(usr)] made fryers no longer fry non-food items.")
		message_admins("\blue [key_name(usr)] made fryers no longer fry non-food items.", 1)
	else
		world << "<b>Fryers can now fry non-food items.</b>"
		log_admin("[key_name(usr)] made fryers able to fry non-food items.")
		message_admins("\blue [key_name(usr)] made fryers able to fry non-food items.", 1)
