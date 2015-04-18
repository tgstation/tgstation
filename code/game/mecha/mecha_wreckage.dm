///////////////////////////////////
////////  Mecha wreckage   ////////
///////////////////////////////////


/obj/structure/mecha_wreckage
	name = "exosuit wreckage"
	desc = "Remains of some unfortunate mecha. Completely unrepairable."
	icon = 'icons/mecha/mecha.dmi'
	density = 1
	anchored = 0
	opacity = 0
	var/list/welder_salvage = list(/obj/item/stack/sheet/plasteel,/obj/item/stack/sheet/metal,/obj/item/stack/rods)
	var/list/wirecutters_salvage = list(/obj/item/stack/cable_coil)
	var/list/crowbar_salvage = list()
	var/salvage_num = 5

/obj/structure/mecha_wreckage/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/weldingtool))
		if(salvage_num <= 0)
			user << "<span class='warning'>You don't see anything that can be cut with [I]!</span>"
			return
		var/obj/item/weapon/weldingtool/WT = I
		if(welder_salvage && welder_salvage.len && WT.remove_fuel(0, user))
			var/type = prob(70) ? pick(welder_salvage) : null
			if(type)
				var/N = new type(get_turf(user))
				user.visible_message("<span class='notice'>[user] cuts [N] from [src].</span>", "<span class='notice'>You cut [N] from [src].</span>")
				if(istype(N, /obj/item/mecha_parts/part))
					welder_salvage -= type
				salvage_num--
			else
				user << "<span class='warning'>You fail to salvage anything valuable from [src]!</span>"
		else
			return

	if(istype(I, /obj/item/weapon/wirecutters))
		if(salvage_num <= 0)
			user << "<span class='warning'>You don't see anything that can be cut with [I]!</span>"
			return
		else if(wirecutters_salvage && wirecutters_salvage.len)
			var/type = prob(70) ? pick(wirecutters_salvage) : null
			if(type)
				var/N = new type(get_turf(user))
				user.visible_message("<span class='notice'>[user] cuts [N] from [src].</span>", "<span class='notice'>You cut [N] from [src].</span>")
				salvage_num--
			else
				user << "<span class='warning'>You fail to salvage anything valuable from [src]!</span>"

	if(istype(I, /obj/item/weapon/crowbar))
		if(crowbar_salvage && crowbar_salvage.len)
			var/obj/S = pick(crowbar_salvage)
			if(S)
				S.loc = get_turf(user)
				crowbar_salvage -= S
				user.visible_message("<span class='notice'>[user] pries [S] from [src].</span>", "<span class='notice'>You pry [S] from [src].</span>")
			return
		else
			user << "<span class='warning'>You don't see anything that can be pried with [I]!</span>"

	else
		..()


/obj/structure/mecha_wreckage/gygax
	name = "\improper Gygax wreckage"
	icon_state = "gygax-broken"

/obj/structure/mecha_wreckage/gygax/New()
	..()
	var/list/parts = list(/obj/item/mecha_parts/part/gygax_torso,
								/obj/item/mecha_parts/part/gygax_head,
								/obj/item/mecha_parts/part/gygax_left_arm,
								/obj/item/mecha_parts/part/gygax_right_arm,
								/obj/item/mecha_parts/part/gygax_left_leg,
								/obj/item/mecha_parts/part/gygax_right_leg)
	for(var/i = 0; i < 2; i++)
		if(parts.len && prob(40))
			var/part = pick(parts)
			welder_salvage += part
			parts -= part



/obj/structure/mecha_wreckage/gygax/dark
	name = "\improper Dark Gygax wreckage"
	icon_state = "darkgygax-broken"

/obj/structure/mecha_wreckage/marauder
	name = "\improper Marauder wreckage"
	icon_state = "marauder-broken"

/obj/structure/mecha_wreckage/mauler
	name = "\improper Mauler wreckage"
	icon_state = "mauler-broken"
	desc = "The syndicate won't be very happy about this..."

/obj/structure/mecha_wreckage/seraph
	name = "\improper Seraph wreckage"
	icon_state = "seraph-broken"

/obj/structure/mecha_wreckage/reticence
	name = "\improper Reticence wreckage"
	icon_state = "reticence-broken"
	color = "#87878715"

/obj/structure/mecha_wreckage/ripley
	name = "\improper Ripley wreckage"
	icon_state = "ripley-broken"

/obj/structure/mecha_wreckage/ripley/New()
	..()
	var/list/parts = list(/obj/item/mecha_parts/part/ripley_torso,
								/obj/item/mecha_parts/part/ripley_left_arm,
								/obj/item/mecha_parts/part/ripley_right_arm,
								/obj/item/mecha_parts/part/ripley_left_leg,
								/obj/item/mecha_parts/part/ripley_right_leg)
	for(var/i = 0; i < 2; i++)
		if(parts.len && prob(40))
			var/part = pick(parts)
			welder_salvage += part
			parts -= part


/obj/structure/mecha_wreckage/ripley/firefighter
	name = "\improper Firefighter wreckage"
	icon_state = "firefighter-broken"

/obj/structure/mecha_wreckage/ripley/firefighter/New()
	..()
	var/list/parts = list(/obj/item/mecha_parts/part/ripley_torso,
								/obj/item/mecha_parts/part/ripley_left_arm,
								/obj/item/mecha_parts/part/ripley_right_arm,
								/obj/item/mecha_parts/part/ripley_left_leg,
								/obj/item/mecha_parts/part/ripley_right_leg,
								/obj/item/clothing/suit/fire)
	for(var/i = 0; i < 2; i++)
		if(parts.len && prob(40))
			var/part = pick(parts)
			welder_salvage += part
			parts -= part


/obj/structure/mecha_wreckage/ripley/deathripley
	name = "\improper Death-Ripley wreckage"
	icon_state = "deathripley-broken"


/obj/structure/mecha_wreckage/honker
	name = "\improper H.O.N.K wreckage"
	icon_state = "honker-broken"

/obj/structure/mecha_wreckage/honker/New()
	..()
	var/list/parts = list(
							/obj/item/mecha_parts/chassis/honker,
							/obj/item/mecha_parts/part/honker_torso,
							/obj/item/mecha_parts/part/honker_head,
							/obj/item/mecha_parts/part/honker_left_arm,
							/obj/item/mecha_parts/part/honker_right_arm,
							/obj/item/mecha_parts/part/honker_left_leg,
							/obj/item/mecha_parts/part/honker_right_leg)
	for(var/i = 0; i < 2; i++)
		if(parts.len && prob(40))
			var/part = pick(parts)
			welder_salvage += part
			parts -= part


/obj/structure/mecha_wreckage/durand
	name = "\improper Durand wreckage"
	icon_state = "durand-broken"

/obj/structure/mecha_wreckage/durand/New()
	..()
	var/list/parts = list(
								/obj/item/mecha_parts/part/durand_torso,
								/obj/item/mecha_parts/part/durand_head,
								/obj/item/mecha_parts/part/durand_left_arm,
								/obj/item/mecha_parts/part/durand_right_arm,
								/obj/item/mecha_parts/part/durand_left_leg,
								/obj/item/mecha_parts/part/durand_right_leg)
	for(var/i = 0; i < 2; i++)
		if(parts.len && prob(40))
			var/part = pick(parts)
			welder_salvage += part
			parts -= part


/obj/structure/mecha_wreckage/phazon
	name = "\improper Phazon wreckage"
	icon_state = "phazon-broken"


/obj/structure/mecha_wreckage/odysseus
	name = "\improper Odysseus wreckage"
	icon_state = "odysseus-broken"

/obj/structure/mecha_wreckage/odysseus/New()
	..()
	var/list/parts = list(
								/obj/item/mecha_parts/part/odysseus_torso,
								/obj/item/mecha_parts/part/odysseus_head,
								/obj/item/mecha_parts/part/odysseus_left_arm,
								/obj/item/mecha_parts/part/odysseus_right_arm,
								/obj/item/mecha_parts/part/odysseus_left_leg,
								/obj/item/mecha_parts/part/odysseus_right_leg)
	for(var/i = 0; i < 2; i++)
		if(parts.len && prob(40))
			var/part = pick(parts)
			welder_salvage += part
			parts -= part