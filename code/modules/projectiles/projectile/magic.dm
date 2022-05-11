/obj/projectile/magic
	name = "bolt"
	icon_state = "energy"
	damage = 0
	damage_type = OXY
	nodamage = TRUE
	armour_penetration = 100
	armor_flag = NONE
	/// determines what type of antimagic can block the spell projectile
	var/antimagic_flags = MAGIC_RESISTANCE
	/// determines the drain cost on the antimagic item
	var/antimagic_charge_cost = 1

/obj/projectile/magic/prehit_pierce(mob/living/target)
	. = ..()
	if(istype(target) && target.can_block_magic(antimagic_flags, antimagic_charge_cost))
		visible_message(span_warning("[src] fizzles on contact with [target]!"))
		return PROJECTILE_DELETE_WITHOUT_HITTING

/obj/projectile/magic/death
	name = "bolt of death"
	icon_state = "pulse1_bl"

/obj/projectile/magic/death/on_hit(mob/living/target)
	. = ..()
	if(!isliving(target))
		return

	if(target.mob_biotypes & MOB_UNDEAD) //negative energy heals the undead
		if(target.revive(full_heal = TRUE, admin_revive = TRUE))
			target.grab_ghost(force = TRUE) // even suicides
			to_chat(target, span_notice("You rise with a start, you're undead!!!"))
		else if(target.stat != DEAD)
			to_chat(target, span_notice("You feel great!"))
		return

	target.death()

/obj/projectile/magic/resurrection
	name = "bolt of resurrection"
	icon_state = "ion"
	damage = 0
	damage_type = OXY
	nodamage = TRUE

/obj/projectile/magic/resurrection/on_hit(mob/living/target)
	. = ..()
	if(!isliving(target))
		return

	if(target.mob_biotypes & MOB_UNDEAD) //positive energy harms the undead
		target.death()
		return

	if(target.revive(full_heal = TRUE, admin_revive = TRUE))
		target.grab_ghost(force = TRUE) // even suicides
		to_chat(target, span_notice("You rise with a start, you're alive!!!"))
	else if(target.stat != DEAD)
		to_chat(target, span_notice("You feel great!"))

/obj/projectile/magic/teleport
	name = "bolt of teleportation"
	icon_state = "bluespace"
	damage = 0
	damage_type = OXY
	nodamage = TRUE
	var/inner_tele_radius = 0
	var/outer_tele_radius = 6

/obj/projectile/magic/teleport/on_hit(mob/target)
	. = ..()
	var/teleammount = 0
	var/teleloc = target
	if(!isturf(target))
		teleloc = target.loc
	for(var/atom/movable/stuff in teleloc)
		if(!stuff.anchored && stuff.loc && !isobserver(stuff))
			if(do_teleport(stuff, stuff, 10, channel = TELEPORT_CHANNEL_MAGIC))
				teleammount++
				var/smoke_range = max(round(4 - teleammount), 0)
				var/datum/effect_system/fluid_spread/smoke/smoke = new
				smoke.set_up(smoke_range, location = stuff.loc) //Smoke drops off if a lot of stuff is moved for the sake of sanity
				smoke.start()

/obj/projectile/magic/safety
	name = "bolt of safety"
	icon_state = "bluespace"
	damage = 0
	damage_type = OXY
	nodamage = TRUE

/obj/projectile/magic/safety/on_hit(atom/target)
	. = ..()
	if(isturf(target))
		return BULLET_ACT_HIT

	var/turf/origin_turf = get_turf(target)
	var/turf/destination_turf = find_safe_turf()

	if(do_teleport(target, destination_turf, channel=TELEPORT_CHANNEL_MAGIC))
		for(var/t in list(origin_turf, destination_turf))
			var/datum/effect_system/fluid_spread/smoke/smoke = new
			smoke.set_up(0, location = t)
			smoke.start()

/obj/projectile/magic/door
	name = "bolt of door creation"
	icon_state = "energy"
	damage = 0
	damage_type = OXY
	nodamage = TRUE
	var/list/door_types = list(/obj/structure/mineral_door/wood, /obj/structure/mineral_door/iron, /obj/structure/mineral_door/silver, /obj/structure/mineral_door/gold, /obj/structure/mineral_door/uranium, /obj/structure/mineral_door/sandstone, /obj/structure/mineral_door/transparent/plasma, /obj/structure/mineral_door/transparent/diamond)

/obj/projectile/magic/door/on_hit(atom/target)
	. = ..()
	if(istype(target, /obj/machinery/door))
		OpenDoor(target)
	else
		var/turf/T = get_turf(target)
		if(isclosedturf(T) && !isindestructiblewall(T))
			CreateDoor(T)

/obj/projectile/magic/door/proc/CreateDoor(turf/T)
	var/door_type = pick(door_types)
	var/obj/structure/mineral_door/D = new door_type(T)
	T.ChangeTurf(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
	D.Open()

/obj/projectile/magic/door/proc/OpenDoor(obj/machinery/door/D)
	if(istype(D, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = D
		A.locked = FALSE
	D.open()

/obj/projectile/magic/change
	name = "bolt of change"
	icon_state = "ice_1"
	damage = 0
	damage_type = BURN
	nodamage = TRUE

/obj/projectile/magic/change/on_hit(mob/living/target)
	. = ..()
	if(isliving(target))
		target.wabbajack()

/obj/projectile/magic/animate
	name = "bolt of animation"
	icon_state = "red_1"
	damage = 0
	damage_type = BURN
	nodamage = TRUE

/obj/projectile/magic/animate/on_hit(atom/target, blocked = FALSE)
	. = ..()
	target.animate_atom_living(firer)

/atom/proc/animate_atom_living(mob/living/owner = null)
	if((isitem(src) || isstructure(src)) && !is_type_in_list(src, GLOB.mimic_blacklist))
		if(istype(src, /obj/structure/statue/petrified))
			var/obj/structure/statue/petrified/P = src
			if(P.petrified_mob)
				var/mob/living/L = P.petrified_mob
				var/mob/living/simple_animal/hostile/statue/S = new(P.loc, owner)
				S.name = "statue of [L.name]"
				if(owner)
					S.faction = list("[REF(owner)]")
				S.icon = P.icon
				S.icon_state = P.icon_state
				S.copy_overlays(P, TRUE)
				S.color = P.color
				S.atom_colours = P.atom_colours.Copy()
				if(L.mind)
					L.mind.transfer_to(S)
					if(owner)
						to_chat(S, span_userdanger("You are an animate statue. You cannot move when monitored, but are nearly invincible and deadly when unobserved! Do not harm [owner], your creator."))
				P.forceMove(S)
				return
		else
			var/obj/O = src
			if(istype(O, /obj/item/gun))
				new /mob/living/simple_animal/hostile/mimic/copy/ranged(drop_location(), src, owner)
			else
				new /mob/living/simple_animal/hostile/mimic/copy(drop_location(), src, owner)

	else if(istype(src, /mob/living/simple_animal/hostile/mimic/copy))
		// Change our allegiance!
		var/mob/living/simple_animal/hostile/mimic/copy/C = src
		if(owner)
			C.ChangeOwner(owner)

/obj/projectile/magic/spellblade
	name = "blade energy"
	icon_state = "lavastaff"
	damage = 15
	damage_type = BURN
	dismemberment = 50
	nodamage = FALSE

/obj/projectile/magic/arcane_barrage
	name = "arcane bolt"
	icon_state = "arcane_barrage"
	damage = 20
	damage_type = BURN
	nodamage = FALSE
	hitsound = 'sound/weapons/barragespellhit.ogg'

/obj/projectile/magic/locker
	name = "locker bolt"
	icon_state = "locker"
	nodamage = TRUE
	var/weld = TRUE
	var/created = FALSE //prevents creation of more then one locker if it has multiple hits
	var/locker_suck = TRUE
	var/datum/weakref/locker_ref

/obj/projectile/magic/locker/Initialize(mapload)
	. = ..()
	var/obj/structure/closet/decay/locker_temp_instance = new(src)
	locker_ref = WEAKREF(locker_temp_instance)

/obj/projectile/magic/locker/prehit_pierce(atom/A)
	. = ..()
	if(. == PROJECTILE_DELETE_WITHOUT_HITTING)
		var/obj/structure/closet/decay/locker_temp_instance = locker_ref.resolve()
		qdel(locker_temp_instance)
		return PROJECTILE_DELETE_WITHOUT_HITTING

	if(isliving(A) && locker_suck)
		var/mob/living/target = A
		var/obj/structure/closet/decay/locker_temp_instance = locker_ref.resolve()
		if(!locker_temp_instance?.insertion_allowed(target))
			return
		target.forceMove(src)
		return PROJECTILE_PIERCE_PHASE

/obj/projectile/magic/locker/on_hit(target)
	if(created)
		return ..()
	if(LAZYLEN(contents))
		var/obj/structure/closet/decay/locker_temp_instance = locker_ref.resolve()
		if(!locker_temp_instance)
			return ..()
		for(var/atom/movable/AM in contents)
			locker_temp_instance.insert(AM)
		locker_temp_instance.welded = weld
		locker_temp_instance.update_appearance()
	created = TRUE
	return ..()

/obj/projectile/magic/locker/Destroy()
	locker_suck = FALSE
	RemoveElement(/datum/element/connect_loc, projectile_connections) //We do this manually so the forcemoves don't "hit" us. This behavior is kinda dumb, someone refactor this
	for(var/atom/movable/AM in contents)
		AM.forceMove(get_turf(src))
	. = ..()

/obj/structure/closet/decay
	breakout_time = 600
	icon_welded = null
	icon_state = "cursed"
	var/weakened_icon = "decursed"
	var/auto_destroy = TRUE

/obj/structure/closet/decay/Initialize(mapload)
	. = ..()
	if(auto_destroy)
		addtimer(CALLBACK(src, .proc/bust_open), 5 MINUTES)

/obj/structure/closet/decay/after_weld(weld_state)
	if(weld_state)
		unmagify()

/obj/structure/closet/decay/open(mob/living/user, force = FALSE)
	. = ..()
	if(.)
		unmagify()

///Give it the lesser magic icon and tell it to delete itself
/obj/structure/closet/decay/proc/unmagify()
	icon_state = weakened_icon
	update_appearance()

	addtimer(CALLBACK(src, .proc/decay), 15 SECONDS)

///Fade away into nothing
/obj/structure/closet/decay/proc/decay()
	animate(src, alpha = 0, time = 3 SECONDS)
	addtimer(CALLBACK(src, .proc/decay_finished), 3 SECONDS)

/obj/structure/closet/decay/proc/decay_finished()
	dump_contents()
	qdel(src)

/obj/projectile/magic/flying
	name = "bolt of flying"
	icon_state = "flight"

/obj/projectile/magic/flying/on_hit(mob/living/target)
	. = ..()
	if(isliving(target))
		var/atom/throw_target = get_edge_target_turf(target, angle2dir(Angle))
		target.throw_at(throw_target, 200, 4)

/obj/projectile/magic/bounty
	name = "bolt of bounty"
	icon_state = "bounty"

/obj/projectile/magic/bounty/on_hit(mob/living/target)
	. = ..()
	if(isliving(target))
		target.apply_status_effect(/datum/status_effect/bounty, firer)

/obj/projectile/magic/antimagic
	name = "bolt of antimagic"
	icon_state = "antimagic"

/obj/projectile/magic/antimagic/on_hit(mob/living/target)
	. = ..()
	if(isliving(target))
		target.apply_status_effect(/datum/status_effect/song/antimagic)

/obj/projectile/magic/fetch
	name = "bolt of fetching"
	icon_state = "fetch"

/obj/projectile/magic/fetch/on_hit(mob/living/target)
	. = ..()
	if(isliving(target))
		var/atom/throw_target = get_edge_target_turf(target, get_dir(target, firer))
		target.throw_at(throw_target, 200, 4)

/obj/projectile/magic/sapping
	name = "bolt of sapping"
	icon_state = "sapping"

/obj/projectile/magic/sapping/on_hit(mob/living/target)
	. = ..()
	if(isliving(target))
		SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, src, /datum/mood_event/sapped)

/obj/projectile/magic/necropotence
	name = "bolt of necropotence"
	icon_state = "necropotence"

/obj/projectile/magic/necropotence/on_hit(mob/living/target)
	. = ..()
	if(isliving(target))
		if(!target.mind)
			return

		to_chat(target, span_danger("Your body feels drained and there is a burning pain in your chest."))
		target.maxHealth -= 20
		target.health = min(target.health, target.maxHealth)
		if(target.maxHealth <= 0)
			to_chat(target, span_userdanger("Your weakened soul is completely consumed by the [src]!"))
			return
		for(var/obj/effect/proc_holder/spell/spell in target.mind.spell_list)
			spell.charge_counter = spell.charge_max
			spell.recharging = FALSE
			spell.update_appearance()

/obj/projectile/magic/wipe
	name = "bolt of possession"
	icon_state = "wipe"

/obj/projectile/magic/wipe/on_hit(mob/living/carbon/target)
	. = ..()
	if(iscarbon(target))
		for(var/x in target.get_traumas())//checks to see if the victim is already going through possession
			if(istype(x, /datum/brain_trauma/special/imaginary_friend/trapped_owner))
				target.visible_message(span_warning("[src] vanishes on contact with [target]!"))
				return BULLET_ACT_BLOCK
		to_chat(target, span_warning("Your mind has been opened to possession!"))
		possession_test(target)
		return BULLET_ACT_HIT

/obj/projectile/magic/wipe/proc/possession_test(mob/living/carbon/target)
	var/datum/brain_trauma/special/imaginary_friend/trapped_owner/trauma = target.gain_trauma(/datum/brain_trauma/special/imaginary_friend/trapped_owner)
	var/poll_message = "Do you want to play as [target.real_name]?"
	if(target.mind)
		poll_message = "[poll_message] Job:[target.mind.assigned_role.title]."
	if(target.mind && target.mind.special_role)
		poll_message = "[poll_message] Status:[target.mind.special_role]."
	else if(target.mind)
		var/datum/antagonist/A = target.mind.has_antag_datum(/datum/antagonist/)
		if(A)
			poll_message = "[poll_message] Status:[A.name]."
	var/list/mob/dead/observer/candidates = poll_candidates_for_mob(poll_message, ROLE_PAI, FALSE, 10 SECONDS, target)
	if(target.stat == DEAD)//boo.
		return
	if(LAZYLEN(candidates))
		var/mob/dead/observer/ghost = pick(candidates)
		to_chat(target, span_boldnotice("You have been noticed by a ghost and it has possessed you!"))
		var/oldkey = target.key
		target.ghostize(FALSE)
		target.key = ghost.key
		trauma.friend.key = oldkey
		trauma.friend.reset_perspective(null)
		trauma.friend.Show()
		trauma.friend_initialized = TRUE
	else
		to_chat(target, span_notice("Your mind has managed to go unnoticed in the spirit world."))
		qdel(trauma)

/// Gives magic projectiles a 3x3 Area of Effect range that will bump into any nearby mobs
/obj/projectile/magic/aoe
	name = "Area Bolt"
	desc = "What the fuck does this do?!"

/obj/projectile/magic/aoe/Range()
	for(var/mob/living/target in range(1, get_turf(src)))
		if(target.stat != DEAD && target != firer)
			return Bump(target)
	..()


/obj/projectile/magic/aoe/lightning
	name = "lightning bolt"
	icon_state = "tesla_projectile" //Better sprites are REALLY needed and appreciated!~
	damage = 15
	damage_type = BURN
	nodamage = FALSE
	speed = 0.3

	var/zap_power = 20000
	var/zap_range = 15
	var/zap_flags = ZAP_MOB_DAMAGE | ZAP_MOB_STUN | ZAP_OBJ_DAMAGE | ZAP_LOW_POWER_GEN
	var/chain
	var/mob/living/caster

/obj/projectile/magic/aoe/lightning/fire(setAngle)
	if(caster)
		chain = caster.Beam(src, icon_state = "lightning[rand(1, 12)]")
	..()

/obj/projectile/magic/aoe/lightning/on_hit(target)
	. = ..()
	tesla_zap(src, zap_range, zap_power, zap_flags)

/obj/projectile/magic/aoe/lightning/no_zap
	zap_power = 10000
	zap_range = 4
	zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE | ZAP_LOW_POWER_GEN

/obj/projectile/magic/aoe/lightning/Destroy()
	qdel(chain)
	. = ..()

/obj/projectile/magic/fireball
	name = "bolt of fireball"
	icon_state = "fireball"
	damage = 10
	damage_type = BRUTE
	nodamage = FALSE

	//explosion values
	var/exp_heavy = 0
	var/exp_light = 2
	var/exp_flash = 3
	var/exp_fire = 2

/obj/projectile/magic/fireball/on_hit(mob/living/target)
	. = ..()
	if(ismob(target))
		//between this 10 burn, the 10 brute, the explosion brute, and the onfire burn, your at about 65 damage if you stop drop and roll immediately
		target.take_overall_damage(0, 10)

	var/turf/T = get_turf(target)
	explosion(T, devastation_range = -1, heavy_impact_range = exp_heavy, light_impact_range = exp_light, flame_range = exp_fire, flash_range = exp_flash, adminlog = FALSE, explosion_cause = src)

//still magic related, but a different path

/obj/projectile/temp/chill
	name = "bolt of chills"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	nodamage = FALSE
	armour_penetration = 100
	temperature = -200 // Cools you down greatly per hit

/obj/projectile/magic/nothing
	name = "bolt of nothing"

/obj/projectile/magic/spellcard
	name = "enchanted card"
	desc = "A piece of paper enchanted to give it extreme durability and stiffness, along with a very hot burn to anyone unfortunate enough to get hit by a charged one."
	icon_state = "spellcard"
	damage_type = BURN
	damage = 2
	nodamage = FALSE
	antimagic_charge_cost = 0 // since the cards gets spammed like a shotgun
