///////////////////////////////////
////////  Mecha wreckage   ////////
///////////////////////////////////


/obj/structure/mecha_wreckage
	name = "exosuit wreckage"
	desc = "Remains of some unfortunate mecha. Completely unrepairable, but perhaps something can be salvaged."
	icon = 'icons/mecha/mecha.dmi'
	density = TRUE
	anchored = FALSE
	opacity = 0
	var/list/welder_salvage = list(/obj/item/stack/sheet/plasteel, /obj/item/stack/sheet/metal, /obj/item/stack/rods)
	var/list/wirecutters_salvage = list(/obj/item/stack/cable_coil)
	var/list/crowbar_salvage = list()
	var/salvage_num = 5
	var/mob/living/silicon/ai/AI //AIs to be salvaged

/obj/structure/mecha_wreckage/New(loc, mob/living/silicon/ai/AI_pilot)
	..()
	if(AI_pilot) //Type-checking for this is already done in mecha/Destroy()
		AI = AI_pilot
		AI.apply_damage(150, BURN) //Give the AI a bit of damage from the "shock" of being suddenly shut down
		AI.death() //The damage is not enough to kill the AI, but to be 'corrupted files' in need of repair.
		AI.forceMove(src) //Put the dead AI inside the wreckage for recovery
		add_overlay(mutable_appearance('icons/obj/projectiles.dmi', "green_laser")) //Overlay for the recovery beacon
		AI.controlled_mech = null
		AI.remote_control = null

/obj/structure/mecha_wreckage/examine(mob/user)
	..()
	if(AI)
		to_chat(user, "<span class='notice'>The AI recovery beacon is active.</span>")

/obj/structure/mecha_wreckage/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weldingtool))
		if(salvage_num <= 0)
			to_chat(user, "<span class='warning'>You don't see anything that can be cut with [I]!</span>")
			return
		var/obj/item/weldingtool/WT = I
		if(welder_salvage && welder_salvage.len && WT.remove_fuel(0, user))
			var/type = prob(70) ? pick(welder_salvage) : null
			if(type)
				var/N = new type(get_turf(user))
				user.visible_message("[user] cuts [N] from [src].", "<span class='notice'>You cut [N] from [src].</span>")
				if(istype(N, /obj/item/mecha_parts/part))
					welder_salvage -= type
				salvage_num--
			else
				to_chat(user, "<span class='warning'>You fail to salvage anything valuable from [src]!</span>")
		else
			return

	else if(istype(I, /obj/item/wirecutters))
		if(salvage_num <= 0)
			to_chat(user, "<span class='warning'>You don't see anything that can be cut with [I]!</span>")
			return
		else if(wirecutters_salvage && wirecutters_salvage.len)
			var/type = prob(70) ? pick(wirecutters_salvage) : null
			if(type)
				var/N = new type(get_turf(user))
				user.visible_message("[user] cuts [N] from [src].", "<span class='notice'>You cut [N] from [src].</span>")
				salvage_num--
			else
				to_chat(user, "<span class='warning'>You fail to salvage anything valuable from [src]!</span>")

	else if(istype(I, /obj/item/crowbar))
		if(crowbar_salvage && crowbar_salvage.len)
			var/obj/S = pick(crowbar_salvage)
			if(S)
				S.loc = get_turf(user)
				crowbar_salvage -= S
				user.visible_message("[user] pries [S] from [src].", "<span class='notice'>You pry [S] from [src].</span>")
			return
		else
			to_chat(user, "<span class='warning'>You don't see anything that can be pried with [I]!</span>")


/obj/structure/mecha_wreckage/transfer_ai(interaction, mob/user, null, obj/item/device/aicard/card)
	if(!..())
		return

 //Proc called on the wreck by the AI card.
	if(interaction == AI_TRANS_TO_CARD) //AIs can only be transferred in one direction, from the wreck to the card.
		if(!AI) //No AI in the wreck
			to_chat(user, "<span class='warning'>No AI backups found.</span>")
			return
		cut_overlays() //Remove the recovery beacon overlay
		AI.forceMove(card) //Move the dead AI to the card.
		card.AI = AI
		if(AI.client) //AI player is still in the dead AI and is connected
			to_chat(AI, "The remains of your file system have been recovered on a mobile storage device.")
		else //Give the AI a heads-up that it is probably going to get fixed.
			AI.notify_ghost_cloning("You have been recovered from the wreckage!", source = card)
		to_chat(user, "<span class='boldnotice'>Backup files recovered</span>: [AI.name] ([rand(1000,9999)].exe) salvaged from [name] and stored within local memory.")

	else
		return ..()


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
	desc = "..."

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
	desc = "All is right in the universe."

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
