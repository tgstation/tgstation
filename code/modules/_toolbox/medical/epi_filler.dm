/obj/structure/epifiller
	name = "epipen refiller"
	desc = "Allows quick refilling of epipens."
	icon = 'icons/oldschool/objects.dmi'
	icon_state = "epifiller"
	var/maximum_volume = 30
	var/emagged = 0
	var/recharge_amt = 1
	var/recharge_delay = 1
	var/recharge_tick = 0
	var/emagged_chem = "toxin"
	var/normal_chem = "epinephrine"
	anchored = 1

/obj/structure/epifiller/Initialize()
	. = ..()
	anchored = 1

/obj/structure/epifiller/process()
	recharge_tick++
	if (recharge_tick > recharge_delay)
		recharge_tick = 0
		reagents.add_reagent(emagged == 0 ? normal_chem : emagged_chem,recharge_amt)

/obj/structure/epifiller/New()
	create_reagents(maximum_volume)
	reagents.add_reagent(normal_chem, maximum_volume)
	..()
	START_PROCESSING(SSobj, src)

/obj/structure/epifiller/Destroy()
	STOP_PROCESSING(SSobj, src)
	..()

/obj/structure/epifiller/examine(mob/user)
	..()
	if(reagents.total_volume)
		to_chat(user, "<span class='notice'>It has [reagents.total_volume] units left.</span>")
	else
		to_chat(user, "<span class='danger'>It's empty.</span>")

/obj/structure/epifiller/attackby(obj/item/W, mob/user, params)
	var/obj/item/reagent_containers/hypospray/medipen/pen = W
	if(istype(pen) && pen.type == /obj/item/reagent_containers/hypospray/medipen)
		if (!(pen.reagents) || (pen.reagents.total_volume))
			return
		if (pen.reagents.maximum_volume > reagents.total_volume)
			to_chat(user, "<span class='danger'>\The [src] doesn't have enough chemicals to refill \the [pen]!</span>")
			return
		reagents.trans_to(pen,pen.reagents.maximum_volume)
		pen.update_icon()
		user.visible_message("<span class='notice'>[user] refills \the [pen].</span>","<span class='notice'>You refill \the [pen].</span>")
		playsound(src, 'sound/effects/refill.ogg', 50, 0, null)
	else if (istype(pen))
		to_chat(user, "<span class='danger'>\The [src] can only be used with epinephrine medipens.")
	else
		return ..()

/obj/structure/epifiller/emag_act(mob/user)
	if (emagged)
		return
	to_chat(user, "<span class='danger'>You emag \the [src].</span>")
	emagged = 1
	reagents.del_reagent(normal_chem)
	reagents.add_reagent(emagged_chem,reagents.maximum_volume)
	flick("epifiller_emagging",src)
	icon_state = "epifiller_emagged"
	playsound(src.loc, "sparks", 100, 1)
