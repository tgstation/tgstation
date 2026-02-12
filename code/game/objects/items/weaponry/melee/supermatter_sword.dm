/obj/item/melee/supermatter_sword
	name = "supermatter sword"
	desc = "In a station full of bad ideas, this might just be the worst."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "supermatter_sword_balanced"
	inhand_icon_state = "supermatter_sword"
	icon_angle = -90
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	slot_flags = null
	w_class = WEIGHT_CLASS_BULKY
	force = 0.001
	armour_penetration = 1000
	force_string = "INFINITE"
	item_flags = NEEDS_PERMIT|NO_BLOOD_ON_ITEM
	custom_materials = list(/datum/material/adamantine = SHEET_MATERIAL_AMOUNT * 20, /datum/material/iron = SHEET_MATERIAL_AMOUNT)
	var/obj/machinery/power/supermatter_crystal/shard
	var/balanced = 1

/obj/item/melee/supermatter_sword/Initialize(mapload)
	. = ..()
	shard = new /obj/machinery/power/supermatter_crystal(src)
	qdel(shard.countdown)
	shard.countdown = null
	START_PROCESSING(SSobj, src)
	visible_message(span_warning("[src] appears, balanced ever so perfectly on its hilt. This isn't ominous at all."))
	RegisterSignal(src, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(eat_bullets))

/obj/item/melee/supermatter_sword/process()
	if(balanced || throwing || ismob(src.loc) || isnull(src.loc))
		return
	if(!isturf(src.loc))
		var/atom/target = src.loc
		forceMove(target.loc)
		consume_everything(target)
	else
		var/turf/turf = get_turf(src)
		if(!isspaceturf(turf))
			consume_turf(turf)

/obj/item/melee/supermatter_sword/pre_attack(atom/target, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(.)
		return .

	if(target == user)
		user.dropItemToGround(src, TRUE)
	else
		user.do_attack_animation(target)
	consume_everything(target)
	return TRUE

/obj/item/melee/supermatter_sword/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	if(ismob(hit_atom))
		var/mob/mob = hit_atom
		if(src.loc == mob)
			mob.dropItemToGround(src, TRUE)
	consume_everything(hit_atom)

/obj/item/melee/supermatter_sword/pickup(user)
	..()
	balanced = 0
	icon_state = "supermatter_sword"
	icon_angle = -45

/obj/item/melee/supermatter_sword/ex_act(severity, target)
	visible_message(
		span_danger("The blast wave smacks into [src] and rapidly flashes to ash."),
		span_hear("You hear a loud crack as you are washed with a wave of heat.")
	)
	consume_everything()
	return TRUE

/obj/item/melee/supermatter_sword/acid_act()
	visible_message(span_danger("The acid smacks into [src] and rapidly flashes to ash."),\
	span_hear("You hear a loud crack as you are washed with a wave of heat."))
	consume_everything()
	return TRUE

/obj/item/melee/supermatter_sword/proc/eat_bullets(datum/source, obj/projectile/hitting_projectile)
	SIGNAL_HANDLER

	visible_message(
		span_danger("[hitting_projectile] smacks into [source] and rapidly flashes to ash."),
		null,
		span_hear("You hear a loud crack as you are washed with a wave of heat."),
	)
	consume_everything(hitting_projectile)
	return COMPONENT_BULLET_BLOCKED

/obj/item/melee/supermatter_sword/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] touches [src]'s blade. It looks like [user.p_theyre()] tired of waiting for the radiation to kill [user.p_them()]!"))
	user.dropItemToGround(src, TRUE)
	shard.Bumped(user)

/obj/item/melee/supermatter_sword/proc/consume_everything(target)
	if(isnull(target))
		shard.Bump(target)
	else if(!isturf(target))
		shard.Bumped(target)
	else
		consume_turf(target)

/obj/item/melee/supermatter_sword/proc/consume_turf(turf/turf)
	var/oldtype = turf.type
	var/turf/newT = turf.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
	if(newT.type == oldtype)
		return
	playsound(turf, 'sound/effects/supermatter.ogg', 50, TRUE)
	turf.visible_message(
		span_danger("[turf] smacks into [src] and rapidly flashes to ash."),
		span_hear("You hear a loud crack as you are washed with a wave of heat."),
	)
	shard.Bump(turf)
