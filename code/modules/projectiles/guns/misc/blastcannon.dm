/obj/item/weapon/gun/blastcannon
	name = "pipe gun"
	desc = "A pipe welded onto a gun stock, with a mechanical trigger. The pipe has an opening near the top, and there seems to be a spring loaded wheel in the hole."
	icon_state = empty_blastcannon
	var/icon_state_loaded = loaded_blastcannon
	item_state = blastcannon_empty
	w_class = WEIGHT_CLASS_NORMAL
	force = 10
	fire_sound =
	needs_permit = FALSE
	clumsy_check = FALSE
	randomspread = FALSE

	var/obj/item/device/transfer_valve/bomb = null
	var/datum_gas_mixture/air1 = null
	var/datum_gas_mixture/air2 = null

/obj/item/weapon/gun/blastcannon/New()
	if(!firingpin)
		firingpin = new
	. = ..()

/obj/item/weapon/gun/blastcannon/Destroy()
	if(bomb)
		qdel(bomb)
		bomb = null
	air1 = null
	air2 = null
	. = ..()

/obj/item/weapon/gun/blastcannon/attack_self(mob/user)
	if(bomb)
		bomb.forceMove(user.loc)
		user.put_in_hands(bomb)
		user.visible_message("<span class='warning'>[user] detaches the [bomb] from the [src]</span>")
		bomb = null
	update_icon()
	. = ..(user)

/obj/item/weapon/gun/blastcannon/update_icon()
	if(bomb)
		icon_state = icon_state_loaded
		name = "blast cannon"
		desc = "A makeshift device used to concentrate a bomb's blast energy to a narrow wave."
	else
		icon_state = initial(icon_state)
		name = initial(name)
		desc = initial(desc)
	. = ..()

/obj/item/weapon/gun/blastcannon/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/device/transfer_valve))
		var/obj/item/device/transfer_valve/T = O
		if(!T.tank_one || !T.tank_two)
			user << "<span class='warning'>What good would an incomplete bomb do?</span>"
			return FALSE
		if(!user.drop_item(O))
			user << "<span class='warning'>The [O] seems to be stuck to your hand!</span>"
			return FALSE
		user.visible_message("<span class='warning'>[user] attaches the [O] to the [src]!</span>"
		bomb = O
		O.loc = src
		update_icon()
		return TRUE
	. = ..()

/obj/item/weapon/gun/blastcannon/afterattack(atom/target, mob/user, flag, params)
	if(!bomb)
		return


	var/power = calculate_bomb()
	qdel(bomb)
	update_icon()


 +
 +/obj/item/weapon/gun/projectile/blastcannon/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params, struggle = 0)
 +	if (istype(A, /obj/item/weapon/storage/backpack ))
 +		return
 +
 +	else if (A.loc == user.loc)
 +		return
 +
 +	else if (A.loc == user)
 +		return
 +
 +	else if (locate (/obj/structure/table, src.loc))
 +		return



 +		bomb_air_contents_1 = bomb.tank_one.air_contents
 +		bomb_air_contents_2 = bomb.tank_two.air_contents
 +
 +		bomb_air_contents_2.volume += bomb_air_contents_1.volume
 +		var/datum/gas_mixture/temp
 +		temp = bomb_air_contents_1.remove_ratio(1)
 +		bomb_air_contents_2.merge(temp)
 +
 +		if(!bomb_air_contents_2)
 +			return
 +
 +		if(bomb_air_contents_2)
 +			bomb_air_contents_2.react()
 +
 +		var/pressure = bomb_air_contents_2.return_pressure()
 +		var/cap = 0
 +		var/uncapped = 0
 +
 +		var/heavy_damage_range = 0
 +		var/medium_damage_range = 0
 +		var/light_damage_range = 0
 +
 +		if(pressure > TANK_FRAGMENT_PRESSURE)
 +			bomb_air_contents_2.react()
 +			bomb_air_contents_2.react()
 +			bomb_air_contents_2.react()
 +			pressure = bomb_air_contents_2.return_pressure()
 +			var/range = (pressure-TANK_FRAGMENT_PRESSURE)/TANK_FRAGMENT_SCALE
 +			uncapped = range
 +			if(!ignorecap)
 +				if(range > MAX_EXPLOSION_RANGE)
 +					cap = 1
 +				range = min(range, MAX_EXPLOSION_RANGE)
 +			var/turf/epicenter = get_turf(loc)
 +
 +			var/transfer_moles1 = (bomb.tank_one.air_contents.return_pressure() * bomb.tank_one.air_contents.volume)/(bomb.tank_one.air_contents.temperature * R_IDEAL_GAS_EQUATION)
 +			bomb.tank_one.air_contents.remove(transfer_moles1)
 +			var/transfer_moles2 = (bomb.tank_two.air_contents.return_pressure() * bomb.tank_two.air_contents.volume)/(bomb.tank_two.air_contents.temperature * R_IDEAL_GAS_EQUATION)
 +			bomb.tank_two.air_contents.remove(transfer_moles2)
 +
 +			bomb_air_contents_1 = null
 +			bomb_air_contents_2 = null
 +
 +			user.visible_message("<span class='danger'>[user] opens \the [bomb] on \his [src.name] and fires a blast wave at \the [A]!</span>","<span class='danger'>You open \the [bomb] on your [src.name] and fire a blast wave at \the [A]!</span>")
 +			var/sound = rand(1,6)
 +			switch(sound)
 +				if(1)
 +					playsound(user, 'sound/effects/Explosion1.ogg', 100, 1)
 +				if(2)
 +					playsound(user, 'sound/effects/Explosion2.ogg', 100, 1)
 +				if(3)
 +					playsound(user, 'sound/effects/Explosion3.ogg', 100, 1)
 +				if(4)
 +					playsound(user, 'sound/effects/Explosion4.ogg', 100, 1)
 +				if(5)
 +					playsound(user, 'sound/effects/Explosion5.ogg', 100, 1)
 +				if(6)
 +					playsound(user, 'sound/effects/Explosion6.ogg', 100, 1)
 +
 +			heavy_damage_range = round(range*0.25)
 +			medium_damage_range = round(range*0.5)
 +			light_damage_range = round(range)
 +
 +			if(ismob(src.loc))
 +				var/mob/shooter = src.loc
 +				var/turf/shooterturf = get_turf(shooter)
 +				var/area/R = get_area(shooterturf)
 +
 +				var/log_str = "Blast wave fired in <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[shooterturf.x];Y=[shooterturf.y];Z=[shooterturf.z]'>[R.name]</a> "
 +				log_str += "by [shooter.name]([shooter.ckey])"
 +
 +				log_str += "(<A HREF='?_src_=holder;adminmoreinfo=\ref[shooter]'>?</A>)"
 +
 +				message_admins(log_str, 0, 1)
 +				log_game(log_str)
 +
 +			for(var/obj/machinery/computer/bhangmeter/bhangmeter in doppler_arrays)
 +				if(bhangmeter)
 +					bhangmeter.sense_explosion(epicenter.x,epicenter.y,epicenter.z,round(uncapped*0.25), round(uncapped*0.5), round(uncapped),"???", cap)
 +
 +		else
 +			user.visible_message("<span class='danger'>[user] opens \the [bomb] on \his [src.name]!</span>","<span class='danger'>You open \the [bomb] on your [src.name]!</span>")
 +			user.visible_message("\The [bomb] on [user]'s [src.name] hisses pitifully.","\The [bomb] on your [src.name] hisses pitifully.")
 +			to_chat(user, "<span class='warning'>The bomb is a dud!</span>")
 +			var/ratio1 = bomb_air_contents_1.volume/bomb_air_contents_2.volume
 +			var/datum/gas_mixture/temp2
 +			temp2 = bomb_air_contents_2.remove_ratio(ratio1)
 +			bomb_air_contents_1.merge(temp2)
 +			bomb_air_contents_2.volume -=  bomb_air_contents_1.volume
 +
 +			bomb.tank_one.air_contents = bomb_air_contents_1
 +			bomb.tank_two.air_contents = bomb_air_contents_2
 +
 +		if(heavy_damage_range && medium_damage_range && light_damage_range)
 +			var/obj/item/projectile/bullet/blastwave/B = new(null)
 +			B.heavy_damage_range = heavy_damage_range
 +			B.medium_damage_range = medium_damage_range
 +			B.light_damage_range = light_damage_range
 +			in_chamber = B
 +			if(Fire(A,user,params, "struggle" = struggle))
 +				if(ismob(src.loc) && !isanimal(src.loc))
 +					var/mob/living/M = src.loc
 +					var/turf/Q = get_turf(M)
 +					var/turf/target
 +					var/throwdir = turn(M.dir, 180)
 +					if(istype(Q, /turf/space)) // if ended in space, then range is unlimited
 +						target = get_edge_target_turf(Q, throwdir)
 +					else						// otherwise limit to 10 tiles
 +						target = get_ranged_target_turf(Q, throwdir, 10)
 +					M.throw_at(target,100,4)
 +					if(!(M.flags & INVULNERABLE))
 +						M.apply_effects(0, 2)
 +						to_chat(user, "<span class='warning'>You're thrown back by the force of the blast!</span>")
 +
 +				bomb.damaged = 1
 +			else
 +				qdel(B)
 +				in_chamber = null





/obj/item/projectile/blastwave
	name = "blast wave"
	icon_state = "blastwave"
	damage = 0
	nodamage = FALSE
	forcedodge = TRUE
	var/heavy = 0
	var/medium = 0
	var/light = 0
	range = 150

/obj/item/projectile/blastwave/Range()
	..()
	if(heavy)
		loc.ex_act(1)
	else if(medium)
		loc.ex_act(2)
	else if(light)
		loc.ex_act(3)
	else
		qdel(src)
	heavy--
	medium--
	light--

/obj/item/projectile/blastwave/ex_act()
	return
