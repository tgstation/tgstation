/obj/item/weapon/reagent_containers/pill
	name = "pill"
	desc = "A tablet or capsule."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "pill"
	item_state = "pill"
	possible_transfer_amounts = list()
	volume = 50
	var/apply_type = INGEST
	var/apply_method = "swallow"
	var/roundstart = 0
	var/self_delay = 0 //pills are instant, this is because patches inheret their aplication from pills

/obj/item/weapon/reagent_containers/pill/New()
	..()
	if(!icon_state)
		icon_state = "pill[rand(1,20)]"
	if(reagents.total_volume && roundstart)
		name += " ([reagents.total_volume]u)"


/obj/item/weapon/reagent_containers/pill/attack_self(mob/user)
	return


/obj/item/weapon/reagent_containers/pill/attack(mob/M, mob/user, def_zone, self_delay)
	if(user.zone_selected == "groin" && user.a_intent == "grab")
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/organ/internal/butt/B = H.getorgan(/obj/item/organ/internal/butt)
			if(B)
				if(!H.w_uniform)
					var/buttspace = B.capacity - B.stored
					if(!itemstorevalue)
						switch(w_class)
							if(1) itemstorevalue += 1 // tiny
							if(2) itemstorevalue += 2 // small
							if(3) itemstorevalue += 4 // normal
							else itemstorevalue = -1 // too big in case we decide to add huge pills(?)
					if(itemstorevalue != -1)//if the item is not too big
						if(B.stored < B.capacity && itemstorevalue <= buttspace) // if the butt can still hold an item
							if(H == user)
								user.visible_message("<span class='notice'>You stuff \the [src] into your butt.</span>", "<span class='warning'>[user] stuffs \the [src] into his own butt.</span>")
							else
								H.visible_message("<span class='warning'>[user] attempts to stuff \the [src] inside [H]'s butt...</span>", "<span class='warning'>You attempt to stuff \the [src] inside [H]'s butt...</span>")
								if(!do_mob(user, H))
									if(H == user)
										user << "<span class='warning'>You fail to stuff \the [src] in your butt.</span>"
									else
										user << "<span class='warning'>You fail to stuff \the [src] in [H]'s butt.</span>"
									return 0
								H.visible_message("<span class='danger'>[user] stuffs \the [src] inside [H]'s butt.</span>", "<span class='userdanger'>You stuff \the [src] inside [H]'s butt.</span>")
							user.unEquip(src)
							add_logs(user, M, "stuffed", object="[reagentlist(src)]")
							B.contents += src
							B.stored += itemstorevalue
							for(var/i = 1 to reagents.total_volume)
								if(!(src in B.contents))
									break
								sleep(50)
								reagents.trans_to(M, 1)
								i++

							// Safely remove the item we have consumed
							if(B)
								if(B.contents)
									B.contents -= src

								B.stored -= itemstorevalue

							qdel(src)

							return 1
						else
							if(H == user)
								user << "<span class='warning'>Your butt is full!</span>"
							else
								user << "<span class='warning'>[H]'s butt is full!</span>"
							return 0
					else
						if(H == user)
							user << "<span class='warning'>This item is too big to fit in your butt!</span>"
						else
							user << "<span class='warning'>This item is too big to fit in [H]'s butt!</span>"
						return 0
				else
					if(H == user)
						user << "<span class='warning'>You'll need to remove your jumpsuit first.</span>"
					else
						user << "<span class='warning'>You'll need to remove [H]'s jumpsuit first.</span>"
						H << "<span class='warning'>You feel your butt being poked with \the [src]!</span>"
						user.visible_message("<span class='warning'>[user] pokes [H]'s butt with \the [src]!</span>", "<span class='warning'>You poke [H]'s butt with \the [src]!</span>")
					return 0
			else
				if(H == user)
					user << "<span class='warning'>You have no butt!</span>"
				else
					user << "<span class='warning'>[H] has no butt!</span>"
				return 0
		else
			user << "<span class='warning'>You can only do that to humans.</span>"
			return 0

	if(!canconsume(M, user))
		return 0

	if(M == user)
		M.visible_message("<span class='notice'>[user] attempts to [apply_method] [src].</span>")
		if(self_delay)
			if(!do_mob(user, M, self_delay))
				return 0
		M << "<span class='notice'>You [apply_method] [src].</span>"

	else
		M.visible_message("<span class='danger'>[user] attempts to force [M] to [apply_method] [src].</span>", \
							"<span class='userdanger'>[user] attempts to force [M] to [apply_method] [src].</span>")
		if(!do_mob(user, M))
			return 0
		M.visible_message("<span class='danger'>[user] forces [M] to [apply_method] [src].</span>", \
							"<span class='userdanger'>[user] forces [M] to [apply_method] [src].</span>")


	user.unEquip(src) //icon update
	add_logs(user, M, "fed", reagentlist(src))
	loc = M //Put the pill inside the mob. This fixes the issue where the pill appears to drop to the ground after someone eats it.

	if(reagents.total_volume)
		reagents.reaction(M, apply_type)
		reagents.trans_to(M, reagents.total_volume)
		qdel(src)
		return 1
	else
		qdel(src)
		return 1
	return 0


/obj/item/weapon/reagent_containers/pill/afterattack(obj/target, mob/user , proximity)
	if(!proximity) return
	if(target.is_open_container() != 0 && target.reagents)
		if(!target.reagents.total_volume)
			user << "<span class='warning'>[target] is empty! There's nothing to dissolve [src] in.</span>"
			return
		user << "<span class='notice'>You dissolve [src] in [target].</span>"
		for(var/mob/O in viewers(2, user))	//viewers is necessary here because of the small radius
			O << "<span class='warning'>[user] slips something into [target]!</span>"
		reagents.trans_to(target, reagents.total_volume)
		spawn(5)
			qdel(src)

/obj/item/weapon/reagent_containers/pill/tox
	name = "toxins pill"
	desc = "Highly toxic."
	icon_state = "pill5"
	list_reagents = list("toxin" = 50)
	roundstart = 1
/obj/item/weapon/reagent_containers/pill/cyanide
	name = "cyanide pill"
	desc = "Don't swallow this."
	icon_state = "pill5"
	list_reagents = list("cyanide" = 50)
	roundstart = 1
/obj/item/weapon/reagent_containers/pill/adminordrazine
	name = "adminordrazine pill"
	desc = "It's magic. We don't have to explain it."
	icon_state = "pill16"
	list_reagents = list("adminordrazine" = 50)
	roundstart = 1
/obj/item/weapon/reagent_containers/pill/morphine
	name = "morphine pill"
	desc = "Commonly used to treat insomnia."
	icon_state = "pill8"
	list_reagents = list("morphine" = 30)
	roundstart = 1
/obj/item/weapon/reagent_containers/pill/stimulant
	name = "stimulant pill"
	desc = "Often taken by overworked employees, athletes, and the inebriated. You'll snap to attention immediately!"
	icon_state = "pill19"
	list_reagents = list("ephedrine" = 10, "antihol" = 10, "coffee" = 30)
	roundstart = 1
/obj/item/weapon/reagent_containers/pill/salbutamol
	name = "salbutamol pill"
	desc = "Used to treat oxygen deprivation."
	icon_state = "pill16"
	list_reagents = list("salbutamol" = 30)
	roundstart = 1
/obj/item/weapon/reagent_containers/pill/charcoal
	name = "antitoxin pill"
	desc = "Neutralizes many common toxins."
	icon_state = "pill17"
	list_reagents = list("charcoal" = 50)
	roundstart = 1
/obj/item/weapon/reagent_containers/pill/epinephrine
	name = "epinephrine pill"
	desc = "Used to stabilize patients."
	icon_state = "pill5"
	list_reagents = list("epinephrine" = 15)
	roundstart = 1
/obj/item/weapon/reagent_containers/pill/mannitol
	name = "mannitol pill"
	desc = "Used to treat brain damage."
	icon_state = "pill17"
	list_reagents = list("mannitol" = 50)
	roundstart = 1
/obj/item/weapon/reagent_containers/pill/mutadone
	name = "mutadone pill"
	desc = "Used to treat genetic damage."
	icon_state = "pill20"
	list_reagents = list("mutadone" = 50)
	roundstart = 1
/obj/item/weapon/reagent_containers/pill/salicyclic
	name = "salicylic acid pill"
	desc = "Used to dull pain."
	icon_state = "pill9"
	list_reagents = list("sal_acid" = 24)
	roundstart = 1
/obj/item/weapon/reagent_containers/pill/oxandrolone
	name = "oxandrolone pill"
	desc = "Used to stimulate burn healing."
	icon_state = "pill11"
	list_reagents = list("oxandrolone" = 24)
	roundstart = 1

/obj/item/weapon/reagent_containers/pill/insulin
	name = "insulin pill"
	desc = "Handles hyperglycaemic coma."
	icon_state = "pill18"
	list_reagents = list("insulin" = 50)
	roundstart = 1
