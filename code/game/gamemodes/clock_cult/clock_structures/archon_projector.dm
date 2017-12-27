/obj/structure/destructible/clockwork/turret/archon_projector
	name = "archon projector"
	desc = "It appears to be a large, brass turret. Looks dangerous."
	clockwork_desc = "A turret which will automatically aim and shoot at any heretics. Projectiles will weaken if they go through glass."
	icon_state = "turret_base"
	break_message = "The turret whirrs worringly, before letting out a final cry as it collapses into shards of brass."
	max_integrity = 75
	construction_value = 25
	losetarget_message = " whirrs, before it's gun settles."
	target_range = 7
	var/list/idle_messages = list("'s gun whirrs idly", " clicks as it tries to find a target")
	var/gun_dir = SOUTH
	var/last_fire = 0

/obj/structure/destructible/clockwork/turret/archon_projector/Initialize()
	. = ..()
	update_icon()

/obj/structure/destructible/clockwork/turret/archon_projector/update_icon()
	. = ..()
	cut_overlays()
	var/image/gun_overlay = image(icon, icon_state = "turret_gun", dir = gun_dir)
	add_overlay(gun_overlay)

/obj/structure/destructible/clockwork/turret/archon_projector/proc/turn_gun(_dir)
	gun_dir = _dir
	update_icon()

/obj/structure/destructible/clockwork/turret/archon_projector/examine(mob/user)
	..()
	to_chat(user, "<span class='brass'>[target ? "<b>It's fixated on [target]!</b>" : "It's whirring quietly, trying to find a target."]</span>")
	to_chat(user, "<span class='brass'>[get_clockwork_power(ARCHON_FIRE_POWER) ? "It has enough power to shoot." : "<b>It does not have enough power to shoot!</b>"]</span>")

/obj/structure/destructible/clockwork/turret/archon_projector/process()
	if(!get_clockwork_power(ARCHON_FIRE_POWER))
		return
	else
		return ..()


/obj/structure/destructible/clockwork/turret/archon_projector/attack_target()
	if(world.time > last_fire + 25)
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


/obj/structure/destructible/clockwork/turret/archon_projector/alert_target()
	playsound(src,'sound/machines/clockcult/ocularwarden-target.ogg',50,1)
	visible_message("<span class='warning'>[src] whirrs, before its gun swivels to face [target]!</span>")
	if(isliving(target))
		var/mob/living/L = target
		to_chat(L, "<span class='neovgre_large'><i>\"TARGET ACQUIRED.\"</i></span>")
	else if(ismecha(target))
		var/obj/mecha/M = target
		to_chat(M.occupant, "<span class='neovgre_large'><i>\"TARGET ACQUIRED.\"</i></span>")

/obj/structure/destructible/clockwork/turret/archon_projector/target_range()
	return view(6, src)

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
	if(istype(AM, /obj/structure/window) && !GLOB.ratvar_awakens)
		damage *= 0.75
		jitter *= 1.75 //it loses damage due to the particles vibrating more when they pass through a window, and it transfers the jitter-iness to the target
