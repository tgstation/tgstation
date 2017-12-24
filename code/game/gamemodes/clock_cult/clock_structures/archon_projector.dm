/obj/structure/destructible/clockwork/archon_projector
	name = "archon projector"
	desc = "It appears to be a large, brass turret. Looks dangerous."
	clockwork_desc = "A turret which will automatically aim and shoot at any heretics. Projectiles will weaken if they go through glass."
	icon_state = "turret_base"
	break_message = "The turret collapses into several shards of brass."
	max_integrity = 75
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	construction_value = 25
	var/atom/movable/target
	var/list/idle_messages = list("'s gun whirrs idly", " clicks as it tries to find a target")
	var/gun_dir = SOUTH
	var/sight_range = 6
	var/last_fire = 0

/obj/structure/destructible/clockwork/archon_projector/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess, src)
	update_icon()

/obj/structure/destructible/clockwork/archon_projector/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/structure/destructible/clockwork/archon_projector/update_icon()
	. = ..()
	cut_overlays()
	var/image/gun_overlay = image(icon, icon_state = "turret_gun", dir = gun_dir)
	add_overlay(gun_overlay)

/obj/structure/destructible/clockwork/archon_projector/proc/turn_gun(_dir)
	gun_dir = _dir
	update_icon()

/obj/structure/destructible/clockwork/archon_projector/examine(mob/user)
	..()
	to_chat(user, "<span class='brass'>[target ? "<b>It's fixated on [target]!</b>" : "It's whirring quietly, trying to find a target."]</span>")
	to_chat(user, "<span class='brass'>[get_clockwork_power(ARCHON_FIRE_POWER) ? "It has enough power to shoot." : "<b>It does not have enough power to shoot!</b>"]</span>")

/obj/structure/destructible/clockwork/archon_projector/process()
	if(!anchored)
		lose_target()
		return
	if(!get_clockwork_power(ARCHON_FIRE_POWER))
		return
	var/list/validtargets = acquire_nearby_targets()
	if(target)
		if(!(target in validtargets))
			lose_target()
		else if(world.time > last_fire + 25)
			if(prob(50))
				playsound(src, 'sound/machines/clockcult/ocularwarden-dot1.ogg',75 * get_efficiency_mod(),1)
			else
				playsound(src, 'sound/machines/clockcult/ocularwarden-dot2.ogg',75 * get_efficiency_mod(),1)
			turn_gun(get_dir(get_turf(src), get_turf(target)))
			var/obj/item/projectile/archon_energy/P = new(loc)
			P.firer = src
			P.preparePixelProjectile(target, src)
			P.fire()
			last_fire = world.time
			adjust_clockwork_power(-ARCHON_FIRE_POWER)
	else
		if(validtargets.len)
			target = pick(validtargets)
			playsound(src,'sound/machines/clockcult/ocularwarden-target.ogg',50,1)
			visible_message("<span class='warning'>[src] whirrs, before its gun swivels to face [target]!</span>")
			if(isliving(target))
				var/mob/living/L = target
				to_chat(L, "<span class='neovgre_large'><i>\"TARGET ACQUIRED.\"</i></span>")
			else if(ismecha(target))
				var/obj/mecha/M = target
				to_chat(M.occupant, "<span class='neovgre_large'><i>\"TARGET ACQUIRED.\"</i></span>")
		else if(prob(0.5)) //Extremely low chance because of how fast the subsystem it uses processes
			if(prob(50))
				visible_message("<span class='notice'>[src][pick(idle_messages)]</span>")
			else
				setDir(pick(GLOB.alldirs))//Random rotation

/obj/structure/destructible/clockwork/archon_projector/proc/acquire_nearby_targets()
	. = list()
	for(var/mob/living/L in view(sight_range, src))
		if(is_servant_of_ratvar(L) || L.null_rod_check())
			continue
		if(L.stat || L.restrained() || L.buckled || L.lying)
			continue
		if(ishostile(L))
			var/mob/living/simple_animal/hostile/H = L
			if(("ratvar" in H.faction) || (!H.mind && "neutral" in H.faction))
				continue
			if(ismegafauna(H) || (!H.mind && H.AIStatus == AI_OFF))
				continue
		else if(isrevenant(L))
			var/mob/living/simple_animal/revenant/R = L
			if(R.stasis) //Don't target any revenants that are respawning
				continue
		else if(!L.mind)
			continue
		. += L
	var/list/viewcache = list()
	for(var/N in GLOB.mechas_list)
		var/obj/mecha/M = N
		if(get_dist(M, src) <= sight_range && M.occupant && !is_servant_of_ratvar(M.occupant))
			if(!length(viewcache))
				for (var/obj/Z in view(sight_range, src))
					viewcache += Z
			if (M in viewcache)
				. += M

/obj/structure/destructible/clockwork/archon_projector/proc/lose_target()
	if(!target)
		return FALSE
	target = null
	visible_message("<span class='warning'>[src] whirrs, before it's gun settles.</span>")
	return TRUE

/obj/item/projectile/archon_energy
	name = "archon energy"
	icon_state = "arcane_barrage"
	damage = 17.5
	speed = 0.5
	damage_type = BURN
	jitter = 10
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE

/obj/item/projectile/archon_energy/Initialize()
	. = ..()
	if(GLOB.ratvar_approaches || GLOB.ratvar_awakens)
		damage = 19.75
		speed = 0.45


/obj/item/projectile/archon_energy/Crossed(atom/movable/AM)
	. = ..()
	if(istype(AM, /obj/structure/window))
		damage *= 0.75
		jitter *= 1.75 //it loses damage due to the particles vibrating more when they pass through a window, and it transfers the jitter-iness to the target
