/obj/item/projectile/hookshot
	name = "hook"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "hookshot"
	damage = 0
	nodamage = 1
	var/length = 1
	kill_count = 15
	var/obj/effect/overlay/hookchain/last_link = null

/obj/item/projectile/hookshot/process_step()
	var/sleeptime = 1
	if(src.loc)
		if(kill_count < 1)
			var/obj/item/weapon/gun/hookshot/hookshot = shot_from
			if(src.z != firer.z)
				hookshot.cancel_chain()
				bullet_die()

			spawn()
				hookshot.rewind_chain()
			bullet_die()

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
			var/obj/item/weapon/gun/hookshot/hookshot = shot_from
			var/obj/effect/overlay/hookchain/HC = hookshot.links["[length]"]
			if(!HC)//failsafe to prevent a game-crashing bug tied to missing links.
				visible_message("With a CLANG noise, the chain mysteriously snaps and rewinds back into the hookshot.")
				hookshot.cancel_chain()
				bullet_die()
			HC.loc = loc
			HC.pixel_x = pixel_x
			HC.pixel_y = pixel_y
			if(last_link)
				last_link.icon = bullet_master["hookshot_chain_angle[target_angle]"]
			last_link = HC
			length++

			if(length < hookshot.maxlength)
				if(!("hookshot_chain_angle[target_angle]" in bullet_master))
					var/icon/I = new('icons/obj/projectiles_experimental.dmi',"hookshot_chain")
					I.Turn(target_angle+45)
					bullet_master["hookshot_chain_angle[target_angle]"] = I
					var/icon/J = new('icons/obj/projectiles_experimental.dmi',"hookshot_pixel")
					J.Turn(target_angle+45)
					bullet_master["hookshot_head_angle[target_angle]"] = J
				HC.icon = bullet_master["hookshot_head_angle[target_angle]"]
			else
				if(!("hookshot_head_angle[target_angle]" in bullet_master))
					var/icon/I = new('icons/obj/projectiles_experimental.dmi',"hookshot_pixel")
					I.Turn(target_angle+45)
					bullet_master["hookshot_head_angle[target_angle]"] = I
				HC.icon = bullet_master["hookshot_head_angle[target_angle]"]
				spawn()
					hookshot.rewind_chain()
				bullet_die()

		sleep(sleeptime)

/obj/item/projectile/hookshot/bullet_die()
	var/obj/item/weapon/gun/hookshot/hookshot = shot_from
	hookshot.hook = null
	spawn()
		OnDeath()
		returnToPool(src)

/obj/item/projectile/hookshot/Destroy()
	var/obj/item/weapon/gun/hookshot/hookshot = shot_from
	if(hookshot)
		if(!hookshot.clockwerk && !hookshot.rewinding)
			hookshot.rewind_chain()
		hookshot.hook = null
	..()

/obj/item/projectile/hookshot/Bump(atom/A as mob|obj|turf|area)
	if(bumped)	return 0
	bumped = 1

	var/obj/item/weapon/gun/hookshot/hookshot = shot_from
	spawn()
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

				var/datum/chain/chain_datum = new()
				hookshot.chain_datum = chain_datum
				chain_datum.hookshot = hookshot
				chain_datum.extremity_A = firer
				chain_datum.extremity_B = AM
				var/max_chains = length-1
				for(var/i = 1; i < max_chains; i++)		//first we create tether links on every turf that has one of the projectile's chain parts.
					var/obj/effect/overlay/hookchain/HC = hookshot.links["[i]"]
					if(!HC.loc || (HC.loc == hookshot))
						max_chains = i
						break
					var/obj/effect/overlay/chain/C = new(HC.loc)
					C.chain_datum = chain_datum
					chain_datum.links["[i]"] = C
				for(var/i = 1; i < max_chains; i++)		//then we link them together
					var/obj/effect/overlay/chain/C = chain_datum.links["[i]"]
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


/obj/item/projectile/hookshot/cultify()
	return

/obj/item/projectile/hookshot/singularity_act()
	return

/obj/item/projectile/hookshot/ex_act()
	return
