///////////////////////////////////
////////  Mecha wreckage   ////////
///////////////////////////////////


/obj/effect/decal/mecha_wreckage
	name = "Exosuit wreckage"
	desc = "Remains of some unfortunate mecha. Completely unrepairable."
	icon = 'icons/mecha/mecha.dmi'
	density = 1
	anchored = 0
	opacity = 0
	var/list/welder_salvage = list(/obj/item/stack/sheet/plasteel,/obj/item/stack/sheet/metal,/obj/item/stack/rods)
	var/list/wirecutters_salvage = list(/obj/item/weapon/cable_coil)
	var/list/crowbar_salvage
	var/salvage_num = 5

	New()
		..()
		crowbar_salvage = new
		return

/obj/effect/decal/mecha_wreckage/ex_act(severity)
	if(severity < 2)
		spawn
			del src
	return

/obj/effect/decal/mecha_wreckage/bullet_act(var/obj/item/projectile/Proj)
	return


/obj/effect/decal/mecha_wreckage/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(salvage_num <= 0)
			user << "You don't see anything that can be cut with [W]."
			return
		if (!isemptylist(welder_salvage) && WT.remove_fuel(0,user))
			var/type = prob(70)?pick(welder_salvage):null
			if(type)
				var/N = new type(get_turf(user))
				user.visible_message("[user] cuts [N] from [src]", "You cut [N] from [src]", "You hear a sound of welder nearby")
				if(istype(N, /obj/item/mecha_parts/part))
					welder_salvage -= type
				salvage_num--
			else
				user << "You failed to salvage anything valuable from [src]."
		else
			user << "\blue You need more welding fuel to complete this task."
			return
	if(istype(W, /obj/item/weapon/wirecutters))
		if(salvage_num <= 0)
			user << "You don't see anything that can be cut with [W]."
			return
		else if(!isemptylist(wirecutters_salvage))
			var/type = prob(70)?pick(wirecutters_salvage):null
			if(type)
				var/N = new type(get_turf(user))
				user.visible_message("[user] cuts [N] from [src].", "You cut [N] from [src].")
				salvage_num--
			else
				user << "You failed to salvage anything valuable from [src]."
	if(istype(W, /obj/item/weapon/crowbar))
		if(!isemptylist(crowbar_salvage))
			var/obj/S = pick(crowbar_salvage)
			if(S)
				S.loc = get_turf(user)
				crowbar_salvage -= S
				user.visible_message("[user] pries [S] from [src].", "You pry [S] from [src].")
			return
		else
			user << "You don't see anything that can be pried with [W]."
	else
		..()
	return


/obj/effect/decal/mecha_wreckage/gygax
	name = "Gygax wreckage"
	icon_state = "gygax-broken"

	New()
		..()
		var/list/parts = list(/obj/item/mecha_parts/part/gygax_torso,
									/obj/item/mecha_parts/part/gygax_head,
									/obj/item/mecha_parts/part/gygax_left_arm,
									/obj/item/mecha_parts/part/gygax_right_arm,
									/obj/item/mecha_parts/part/gygax_left_leg,
									/obj/item/mecha_parts/part/gygax_right_leg)
		for(var/i=0;i<2;i++)
			if(!isemptylist(parts) && prob(40))
				var/part = pick(parts)
				welder_salvage += part
				parts -= part
		return

/obj/effect/decal/mecha_wreckage/gygax/dark
	name = "Dark Gygax wreckage"
	icon_state = "darkgygax-broken"

/obj/effect/decal/mecha_wreckage/marauder
	name = "Marauder wreckage"
	icon_state = "marauder-broken"

/obj/effect/decal/mecha_wreckage/mauler
	name = "Mauler Wreckage"
	icon_state = "mauler-broken"
	desc = "The syndicate won't be very happy about this..."

/obj/effect/decal/mecha_wreckage/seraph
	name = "Seraph wreckage"
	icon_state = "seraph-broken"

/obj/effect/decal/mecha_wreckage/ripley
	name = "Ripley wreckage"
	icon_state = "ripley-broken"

	New()
		..()
		var/list/parts = list(/obj/item/mecha_parts/part/ripley_torso,
									/obj/item/mecha_parts/part/ripley_left_arm,
									/obj/item/mecha_parts/part/ripley_right_arm,
									/obj/item/mecha_parts/part/ripley_left_leg,
									/obj/item/mecha_parts/part/ripley_right_leg)
		for(var/i=0;i<2;i++)
			if(!isemptylist(parts) && prob(40))
				var/part = pick(parts)
				welder_salvage += part
				parts -= part
		return

/obj/effect/decal/mecha_wreckage/ripley/firefighter
	name = "Firefighter wreckage"
	icon_state = "firefighter-broken"

	New()
		..()
		var/list/parts = list(/obj/item/mecha_parts/part/ripley_torso,
									/obj/item/mecha_parts/part/ripley_left_arm,
									/obj/item/mecha_parts/part/ripley_right_arm,
									/obj/item/mecha_parts/part/ripley_left_leg,
									/obj/item/mecha_parts/part/ripley_right_leg,
									/obj/item/clothing/suit/fire)
		for(var/i=0;i<2;i++)
			if(!isemptylist(parts) && prob(40))
				var/part = pick(parts)
				welder_salvage += part
				parts -= part
		return

/obj/effect/decal/mecha_wreckage/ripley/deathripley
	name = "Death-Ripley wreckage"
	icon_state = "deathripley-broken"

/obj/effect/decal/mecha_wreckage/honker
	name = "Honker wreckage"
	icon_state = "honker-broken"

	New()
		..()
		var/list/parts = list(
								/obj/item/mecha_parts/chassis/honker,
								/obj/item/mecha_parts/part/honker_torso,
								/obj/item/mecha_parts/part/honker_head,
								/obj/item/mecha_parts/part/honker_left_arm,
								/obj/item/mecha_parts/part/honker_right_arm,
								/obj/item/mecha_parts/part/honker_left_leg,
								/obj/item/mecha_parts/part/honker_right_leg)
		for(var/i=0;i<2;i++)
			if(!isemptylist(parts) && prob(40))
				var/part = pick(parts)
				welder_salvage += part
				parts -= part
		return

/obj/effect/decal/mecha_wreckage/durand
	name = "Durand wreckage"
	icon_state = "durand-broken"

	New()
		..()
		var/list/parts = list(
									/obj/item/mecha_parts/part/durand_torso,
									/obj/item/mecha_parts/part/durand_head,
									/obj/item/mecha_parts/part/durand_left_arm,
									/obj/item/mecha_parts/part/durand_right_arm,
									/obj/item/mecha_parts/part/durand_left_leg,
									/obj/item/mecha_parts/part/durand_right_leg)
		for(var/i=0;i<2;i++)
			if(!isemptylist(parts) && prob(40))
				var/part = pick(parts)
				welder_salvage += part
				parts -= part
		return

/obj/effect/decal/mecha_wreckage/phazon
	name = "Phazon wreckage"
	icon_state = "phazon-broken"


/obj/effect/decal/mecha_wreckage/odysseus
	name = "Odysseus wreckage"
	icon_state = "odysseus-broken"

	New()
		..()
		var/list/parts = list(
									/obj/item/mecha_parts/part/odysseus_torso,
									/obj/item/mecha_parts/part/odysseus_head,
									/obj/item/mecha_parts/part/odysseus_left_arm,
									/obj/item/mecha_parts/part/odysseus_right_arm,
									/obj/item/mecha_parts/part/odysseus_left_leg,
									/obj/item/mecha_parts/part/odysseus_right_leg)
		for(var/i=0;i<2;i++)
			if(!isemptylist(parts) && prob(40))
				var/part = pick(parts)
				welder_salvage += part
				parts -= part
		return