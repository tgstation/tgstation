/obj/item/weapon/gun/hookshot/flesh //only intended to be used by borers
	name = "fleshshot"
	desc = "It looks like a hookshot made of muscle and skin."
	slot_flags = null
	mech_flags = MECH_SCAN_ILLEGAL
	w_class = 5
	fire_sound = 'sound/effects/flesh_squelch.ogg'
	empty_sound = null
	silenced = 1
	fire_volume = 250
	maxlength = 10
	clumsy_check = 0
	advanced_tool_user_check = 0
	nymph_check = 0
	hulk_check = 0
	golem_check = 0
	var/mob/living/simple_animal/borer/parent_borer = null
	var/image/item_overlay = null
	var/obj/item/to_be_dropped = null //to allow items to be dropped at range

/obj/item/weapon/gun/hookshot/flesh/New(turf/T, var/p_borer = null)
	..(T)
	if(istype(p_borer, /mob/living/simple_animal/borer))
		parent_borer = p_borer
	if(!parent_borer)
		qdel(src)

/obj/item/weapon/gun/hookshot/flesh/Destroy()//if a single link of the chain is destroyed, the rest of the chain is instantly destroyed as well.
	if(parent_borer)
		if(parent_borer.extend_o_arm == src)
			parent_borer.extend_o_arm = null
	..()

/obj/item/weapon/gun/hookshot/flesh/process_chambered()
	if(in_chamber)
		return 1

	if(panic)//if a part of the chain got deleted, we recreate it.
		for(var/i = 0;i <= maxlength; i++)
			var/obj/effect/overlay/hookchain/flesh/HC = links["[i]"]
			if(!HC)
				HC = new(src)
				HC.shot_from = src
				links["[i]"] = HC
			else
				HC.loc = src
		panic = 0

	if(!hook && !rewinding && !clockwerk && !check_tether())//if there is no projectile already, and we aren't currently rewinding the chain, or reeling in toward a target,
		hook = new/obj/item/projectile/hookshot/flesh(src, parent_borer)		//and that the hookshot isn't currently sustaining a tether, then we can fire.
		in_chamber = hook
		firer = loc
		update_icon()
		return 1
	return 0

/obj/item/weapon/gun/hookshot/flesh/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params, struggle = 0)//clicking anywhere reels the target to the player.
	if(flag)	return //we're placing gun on a table or in backpack
	if(check_tether())
		if(istype(chain_datum.extremity_B,/mob/living/carbon))
			if(parent_borer)
				if(parent_borer.host)
					var/mob/living/carbon/C = chain_datum.extremity_B
					to_chat(C, "<span class='warning'>\The [parent_borer.host]'s [parent_borer.hostlimb == LIMB_RIGHT_ARM ? "right" : "left"] arm reels you in!</span>")
		chain_datum.rewind_chain()
		return
	..()

/obj/item/weapon/gun/hookshot/flesh/rewind_chain()//brings the links back toward the player
	if(rewinding)
		return
	rewinding = 1
	for(var/j = 1; j <= maxlength; j++)
		var/pause = 0
		var/end_of_chain = 1
		for(var/i = maxlength; i > 0; i--)
			var/obj/effect/overlay/hookchain/HC = links["[i]"]
			if(!HC)
				cancel_chain()
				return
			if(HC.loc == src)
				continue
			if(HC.overlays.len)
				HC.overlays.len = 0
			pause = 1
			if(i > end_of_chain)
				end_of_chain = i
			var/obj/effect/overlay/hookchain/HC0 = links["[i-1]"]
			if(!HC0)
				cancel_chain()
				return
			HC.loc = HC0.loc
			HC.pixel_x = HC0.pixel_x
			HC.pixel_y = HC0.pixel_y
		var/obj/effect/overlay/hookchain/chain_end = links["[end_of_chain]"]
		if(chain_end && chain_end.loc != src)
//			chain_end.overlays.len = 0
			chain_end.overlays += item_overlay
			if(to_be_dropped)
				if(parent_borer && parent_borer.host && istype(parent_borer.host, /mob/living/carbon/human))
					var/mob/living/carbon/human/HT = parent_borer.host
					if(to_be_dropped.loc != HT)
						to_be_dropped.forceMove(get_turf(chain_end))
						to_be_dropped = null
		sleep(pause)
	rewinding = 0
	item_overlay = null
	update_icon()

//this datum contains all the data about a tether. It's extremities, which hookshot spawned it, and the list of all of its links.
/datum/chain/flesh
	var/mob/living/simple_animal/borer/parent_borer = null

/datum/chain/flesh/New()
	spawn()
		while(!parent_borer)
			if(istype(hookshot, /obj/item/weapon/gun/hookshot/flesh))
				var/obj/item/weapon/gun/hookshot/flesh/F = hookshot
				parent_borer = F.parent_borer
			sleep(1)
	..()

/datum/chain/flesh/process()
	if(!parent_borer)
		if(istype(hookshot, /obj/item/weapon/gun/hookshot/flesh))
			var/obj/item/weapon/gun/hookshot/flesh/F = hookshot
			parent_borer = F.parent_borer
	..()

/datum/chain/flesh/Delete_Chain()
	if(undergoing_deletion)
		return
	undergoing_deletion = 1
	if(extremity_A)
		if(snap)
			extremity_A.visible_message("The length of flesh snaps and lets go of \the [extremity_A].")
		extremity_A.tether = null
	if(extremity_B)
		if(snap)
			extremity_B.visible_message("The length of flesh snaps and lets go of \the [extremity_B].")
		extremity_B.tether = null
	for(var/i = 1; i<= links.len ;i++)
		var/obj/effect/overlay/chain/flesh/C = links["[i]"]
		qdel(C)
	if(hookshot)
		hookshot.chain_datum = null
		hookshot.update_icon()

/datum/chain/flesh/rewind_chain()
	rewinding = 1
	if(!extremity_A.tether)
		Delete_Chain()
		return
	for(var/i = 1; i<= links.len ;i++)
		var/obj/effect/overlay/chain/C1 = extremity_A.tether
		if(!C1)
			break
		var/obj/effect/overlay/chain/C2 = C1.extremity_B
		if(!C2)
			break

		if(istype(C2))
			var/turf/T = C1.loc
			C1.loc = extremity_A.loc
			C2.follow(C1,T)
			C2.extremity_A = extremity_A
			C2.update_overlays(C1)
			extremity_A.tether = C2
		else if(extremity_B)
			if(extremity_B.anchored)
				extremity_B.tether = null
				C1.extremity_B = null
				extremity_B = null
			else
				var/turf/U = C1.loc
				if(U && U.Enter(C2,C2.loc))//if we cannot pull the target through the turf, we just let him go.
					C2.loc = C1.loc
				else
					extremity_B.tether = null
					extremity_B = null
					C1.extremity_B = null

				if(istype(extremity_A,/mob/living))
					var/mob/living/L = extremity_A
					if(istype(C2, /obj/item))
						if(parent_borer)
							if(parent_borer.host)
								if(istype(parent_borer.host, /mob/living/carbon/human))
									if(L == parent_borer.host)
										var/mob/living/carbon/human/H = L
										if(parent_borer.hostlimb == LIMB_RIGHT_ARM)
											if(!H.get_held_item_by_index(GRASP_RIGHT_HAND))
												H.put_in_r_hand(C2)
											else
												C2.CtrlClick(H)
										else
											if(!H.get_held_item_by_index(GRASP_LEFT_HAND))
												H.put_in_l_hand(C2)
											else
												C2.CtrlClick(H)
					else
						C2.CtrlClick(L)
		C1.rewinding = 1
		qdel(C1)
		sleep(1)

	Delete_Chain()

//THE CHAIN THAT APPEARS WHEN YOU FIRE THE HOOKSHOT
/obj/effect/overlay/hookchain/flesh
	name = "length of flesh"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "flesh_chain"

//THE CHAIN THAT TETHERS STUFF TOGETHER
/obj/effect/overlay/chain/flesh
	name = "length of flesh"

/obj/effect/overlay/chain/flesh/update_icon()
	overlays.len = 0
	if(extremity_A && (loc != extremity_A.loc))
		overlays += image(icon,src,"flesh_chain",MOB_LAYER-0.1,get_dir(src,extremity_A))
	if(extremity_B && (loc != extremity_B.loc))
		overlays += image(icon,src,"flesh_chain",MOB_LAYER-0.1,get_dir(src,extremity_B))

///////////////PROJECTILE///////////////////

/obj/item/projectile/hookshot/flesh
	name = "claw"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = ""//"flesh_hookshot"
	kill_count = 11
	var/mob/living/simple_animal/borer/parent_borer = null
	var/image/item_overlay = null

/obj/item/projectile/hookshot/flesh/New(turf/T = null, var/p_borer = null)
	..(T)
	if(istype(p_borer, /mob/living/simple_animal/borer))
		parent_borer = p_borer
	update_icon()

/obj/item/projectile/hookshot/flesh/OnFired()
	..()
	update_icon()

/obj/item/projectile/hookshot/flesh/update_icon()
	overlays.len = 0
	var/obj/item/I = null
	if(!parent_borer)
		return
	else if(parent_borer.host)
		if(istype(parent_borer.host, /mob/living/carbon/human))
			var/mob/living/carbon/human/L = parent_borer.host
			if(parent_borer.hostlimb == LIMB_RIGHT_ARM)
				if(L.get_held_item_by_index(GRASP_RIGHT_HAND))
					I = L.get_held_item_by_index(GRASP_RIGHT_HAND)
			else
				if(L.get_held_item_by_index(GRASP_LEFT_HAND))
					I = L.get_held_item_by_index(GRASP_LEFT_HAND)
	if(I)
		item_overlay = image('icons/obj/projectiles_experimental.dmi', src, "nothing")
		item_overlay.appearance = I.appearance
		item_overlay.layer = src.layer

		overlays += item_overlay
		if(shot_from)
			var/obj/item/weapon/gun/hookshot/flesh/hookshot = shot_from
			hookshot.item_overlay = item_overlay

/obj/item/projectile/hookshot/flesh/process_step()
	var/sleeptime = 1
	if(src.loc)
		if(kill_count < 1)
			var/obj/item/weapon/gun/hookshot/flesh/hookshot = shot_from
			if(src.z != firer.z)
				hookshot.cancel_chain()
				bullet_die()

			spawn()
				hookshot.rewind_chain()
			bullet_die()

		var/obj/item/weapon/gun/hookshot/flesh/hookshot = shot_from
		if(!hookshot.item_overlay)
			item_overlay = null
			update_icon()
		else if(item_overlay != hookshot.item_overlay)
			item_overlay = hookshot.item_overlay

		if(hookshot.to_be_dropped)
			var/obj/item/dropping = hookshot.to_be_dropped
			if(parent_borer && parent_borer.host && istype(parent_borer.host, /mob/living/carbon/human))
				var/mob/living/carbon/human/HT = parent_borer.host
				if(dropping.loc != HT)
					dropping.forceMove(get_turf(src))
					hookshot.to_be_dropped = null

		if(dist_x > dist_y)
			sleeptime = bresenham_step(dist_x,dist_y,dx,dy)
		else
			sleeptime = bresenham_step(dist_y,dist_x,dy,dx)
		if(linear_movement)
			update_pixel()
			pixel_x = PixelX
			pixel_y = PixelY

		bumped = 0

		if(sleeptime)
//			var/obj/item/weapon/gun/hookshot/hookshot = shot_from
			var/obj/effect/overlay/hookchain/HC = hookshot.links["[length]"]
			if(!HC)//failsafe to prevent a game-crashing bug tied to missing links.
				visible_message("With a tearing noise, the length of flesh mysteriously snaps and retracts back into its arm.")
				hookshot.cancel_chain()
				bullet_die()
				return
			HC.loc = loc
			HC.pixel_x = pixel_x
			HC.pixel_y = pixel_y
			if(last_link)
				last_link.icon = bullet_master["fleshshot_chain_angle[target_angle]"]
			last_link = HC
			length++

			if(length < hookshot.maxlength)
				if(!("fleshshot_chain_angle[target_angle]" in bullet_master))
					var/icon/I = new('icons/obj/projectiles_experimental.dmi',"flesh_chain")
					I.Turn(target_angle+45)
					bullet_master["fleshshot_chain_angle[target_angle]"] = I
					var/icon/J = new('icons/obj/projectiles_experimental.dmi',"flesh_hookshot_pixel")
					J.Turn(target_angle+45)
					bullet_master["fleshshot_head_angle[target_angle]"] = J
				HC.icon = bullet_master["fleshshot_head_angle[target_angle]"]
			else
				if(!("fleshshot_head_angle[target_angle]" in bullet_master))
					var/icon/I = new('icons/obj/projectiles_experimental.dmi',"flesh_hookshot_pixel")
					I.Turn(target_angle+45)
					bullet_master["fleshshot_head_angle[target_angle]"] = I
				HC.icon = bullet_master["fleshshot_head_angle[target_angle]"]
				spawn()
					hookshot.rewind_chain()
				bullet_die()

		sleep(sleeptime)

/obj/item/projectile/hookshot/flesh/Bump(atom/A as mob|obj|turf|area)
	if(bumped)	return 0
	bumped = 1

	var/obj/item/weapon/gun/hookshot/flesh/hookshot = shot_from
	spawn()
		if(parent_borer)
			if(parent_borer.host)
				if(istype(parent_borer.host, /mob/living/carbon/human))
					var/mob/living/carbon/human/L = parent_borer.host
					if(parent_borer.hostlimb == LIMB_RIGHT_ARM)
						if(L.get_held_item_by_index(GRASP_RIGHT_HAND))
							if(!parent_borer.attack_cooldown)
								A.attackby(L.get_held_item_by_index(GRASP_RIGHT_HAND), L, 1, parent_borer)
								if(!parent_borer)	//There's already a check for this above, but for some reason when it hits an airlock it gets qdel()'d before it gets to this point.
									bullet_die()
									return
								parent_borer.attack_cooldown = 1
								parent_borer.reset_attack_cooldown()
							bullet_die()
							return
					else
						if(L.get_held_item_by_index(GRASP_LEFT_HAND))
							if(!parent_borer.attack_cooldown)
								A.attackby(L.get_held_item_by_index(GRASP_LEFT_HAND), L, 1, parent_borer)
								if(!parent_borer)
									bullet_die()
									return
								parent_borer.attack_cooldown = 1
								parent_borer.reset_attack_cooldown()
							bullet_die()
							return
		if(isturf(A))					//if we hit a wall or an anchored atom, we pull ourselves to it
			hookshot.clockwerk_chain(length)
		else if(istype(A,/atom/movable))
			var/atom/movable/AM = A
			if(AM.anchored)
				hookshot.clockwerk_chain(length)
			else if(!AM.tether && !firer.tether && !istype(AM,/obj/effect/))	//if we hit something that we can pull, let's tether ourselves to it

				if(length <= 2)		//unless we hit it at melee range, then let's just start pulling it
					AM.CtrlClick(firer)
					hookshot.cancel_chain()
					bullet_die()
					return

				var/datum/chain/flesh/chain_datum = new()
				hookshot.chain_datum = chain_datum
				chain_datum.hookshot = hookshot
				chain_datum.extremity_A = firer
				chain_datum.extremity_B = AM
				var/max_chains = length-1
				for(var/i = 1; i < max_chains; i++)		//first we create tether links on every turf that has one of the projectile's chain parts.
					var/obj/effect/overlay/hookchain/flesh/HC = hookshot.links["[i]"]
					if(!HC.loc || (HC.loc == hookshot))
						max_chains = i
						break
					var/obj/effect/overlay/chain/flesh/C = new(HC.loc)
					C.chain_datum = chain_datum
					chain_datum.links["[i]"] = C
				for(var/i = 1; i < max_chains; i++)		//then we link them together
					var/obj/effect/overlay/chain/flesh/C = chain_datum.links["[i]"]
					if(i == 1)
						firer.tether = C
						C.extremity_A = firer
						if(max_chains <= 2)
							C.extremity_B = AM
							C.update_overlays()
						else
							C.extremity_B = chain_datum.links["[i+1]"]
					else if(i == (max_chains-1))
						C.extremity_A = chain_datum.links["[i-1]"]
						C.extremity_B = AM
						AM.tether = C
						C.update_overlays()				//once we've placed and linked all the tether's links, we update their sprites
					else
						C.extremity_A = chain_datum.links["[i-1]"]
						C.extremity_B = chain_datum.links["[i+1]"]

				if(istype(firer, /mob) && isliving(AM))
					var/mob/living/L = AM
					log_attack("<font color='red'>[key_name(firer)] hooked [key_name(L)] with a [type]</font>")
					L.attack_log += "\[[time_stamp()]\] <b>[key_name(firer)]</b> hooked <b>[key_name(L)]</b> with a <b>[type]</b>"
					firer.attack_log += "\[[time_stamp()]\] <b>[key_name(firer)]</b> hooked <b>[key_name(L)]</b> with a <b>[type]</b>"

				hookshot.cancel_chain()					//then we remove the chain laid by the projectile
			else
				hookshot.rewind_chain()
		else
			hookshot.rewind_chain()					//hit something that we can neither pull ourselves to nor drag to us? Just retract the chain.
	bullet_die()
