/turf/closed/indestructible/supermatter_wall
	name = "wall"
	desc = "Effectively impervious to conventional methods of destruction."
	icon = 'icons/turf/walls.dmi'
	icon_state = "crystal_cascade_1"
	layer = AREA_LAYER
	plane = ABOVE_LIGHTING_PLANE
	opacity = FALSE
	var/list/available_dirs = list(NORTH,SOUTH,EAST,WEST,UP,DOWN)
	var/next_check = 0

/turf/closed/indestructible/supermatter_wall/Initialize(mapload)
	. = ..()
	icon_state = "crystal_cascade_[rand(1,6)]"
	START_PROCESSING(SSmachines, src)

/turf/closed/indestructible/supermatter_wall/process()

	if(next_check > world.time)
		return

	if(!available_dirs || available_dirs.len <= 0)
		return PROCESS_KILL

	next_check = world.time + rand(0, 5 SECONDS)

	var/picked_dir = pick_n_take(available_dirs)
	var/turf/next_turf = get_step_multiz(src, picked_dir)
	if(!istype(next_turf) || istype(next_turf, /turf/closed/indestructible/supermatter_wall))
		return

	icon_state = "crystal_cascade_[rand(1,6)]"

	for(var/atom/movable/checked_atom as anything in next_turf)
		if(istype(checked_atom, /mob/living))
			qdel(checked_atom)
		else if(istype(checked_atom, /mob)) // Observers, AI cameras.
			continue
		else if(istype(checked_atom, /obj/cascade_portal))
			continue
		else
			qdel(checked_atom)
		CHECK_TICK

	next_turf.ChangeTurf(type)
	var/turf/closed/indestructible/supermatter_wall/sm_wall = next_turf
	if(sm_wall.available_dirs)
		sm_wall.available_dirs -= get_dir(next_turf, src)

/turf/closed/indestructible/supermatter_wall/bullet_act(obj/projectile/projectile)
	visible_message(span_notice("[src] is unscathed!"))
	return BULLET_ACT_HIT

/turf/closed/indestructible/supermatter_wall/singularity_act()
	return

/turf/closed/indestructible/supermatter_wall/blob_act(obj/structure/blob/blob)
	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)
	Consume(blob)

/turf/closed/indestructible/supermatter_wall/attack_tk(mob/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/jedi = user
	to_chat(jedi, span_userdanger("That was a really dense idea."))
	jedi.ghostize()
	var/obj/item/organ/brain/rip_u = locate(/obj/item/organ/brain) in jedi.internal_organs
	if(rip_u)
		rip_u.Remove(jedi)
		qdel(rip_u)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/turf/closed/indestructible/supermatter_wall/attack_paw(mob/user, list/modifiers)
	dust_mob(user, cause = "monkey attack")

/turf/closed/indestructible/supermatter_wall/attack_alien(mob/user, list/modifiers)
	dust_mob(user, cause = "alien attack")

/turf/closed/indestructible/supermatter_wall/attack_animal(mob/living/simple_animal/user, list/modifiers)
	var/murder
	if(!user.melee_damage_upper && !user.melee_damage_lower)
		murder = user.friendly_verb_continuous
	else
		murder = user.attack_verb_continuous
	dust_mob(user, \
	span_danger("[user] unwisely [murder] [src], and [user.p_their()] body burns brilliantly before flashing into ash!"), \
	span_userdanger("You unwisely touch [src], and your vision glows brightly as your body crumbles to dust. Oops."), \
	"simple animal attack")

/turf/closed/indestructible/supermatter_wall/attack_robot(mob/user)
	if(Adjacent(user))
		dust_mob(user, cause = "cyborg attack")

/turf/closed/indestructible/supermatter_wall/attack_ai(mob/user)
	return

/turf/closed/indestructible/supermatter_wall/attack_hulk(mob/user)
	dust_mob(user, cause = "hulk attack")

/turf/closed/indestructible/supermatter_wall/attack_larva(mob/user)
	dust_mob(user, cause = "larva attack")

/turf/closed/indestructible/supermatter_wall/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(user.incorporeal_move || user.status_flags & GODMODE)
		return

	. = TRUE
	if(user.zone_selected != BODY_ZONE_PRECISE_MOUTH)
		dust_mob(user, cause = "hand")
		return

	if(!user.is_mouth_covered())
		if(user.combat_mode)
			dust_mob(user,
				span_danger("As [user] tries to take a bite out of [src] everything goes silent before [user.p_their()] body starts to glow and burst into flames before flashing to ash."),
				span_userdanger("You try to take a bite out of [src], but find [p_them()] far too hard to get anywhere before everything starts burning and your ears fill with ringing!"),
				"attempted bite"
			)
			return

		var/obj/item/organ/tongue/licking_tongue = user.getorganslot(ORGAN_SLOT_TONGUE)
		if(licking_tongue)
			dust_mob(user,
				span_danger("As [user] hesitantly leans in and licks [src] everything goes silent before [user.p_their()] body starts to glow and burst into flames before flashing to ash!"),
				span_userdanger("You tentatively lick [src], but you can't figure out what it tastes like before everything starts burning and your ears fill with ringing!"),
				"attempted lick"
			)
			return

	var/obj/item/bodypart/head/forehead = user.get_bodypart(BODY_ZONE_HEAD)
	if(forehead)
		dust_mob(user,
			span_danger("As [user]'s forehead bumps into [src], inducing a resonance... Everything goes silent before [user.p_their()] [forehead] flashes to ash!"),
			span_userdanger("You feel your forehead bump into [src] and everything suddenly goes silent. As your head fills with ringing you come to realize that that was not a wise decision."),
			"failed lick"
		)
		return

	dust_mob(user,
		span_danger("[user] leans in and tries to lick [src], inducing a resonance... [user.p_their()] body starts to glow and burst into flames before flashing into dust!"),
		span_userdanger("You lean in and try to lick [src]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\""),
		"failed lick"
	)


/turf/closed/indestructible/supermatter_wall/proc/dust_mob(mob/living/nom, vis_msg, mob_msg, cause)
	if(nom.incorporeal_move || nom.status_flags & GODMODE) //try to keep supermatter sliver's + hemostat's dust conditions in sync with this too
		return
	if(!vis_msg)
		vis_msg = span_danger("[nom] reaches out and touches [src], inducing a resonance... [nom.p_their()] body starts to glow and burst into flames before flashing into dust!")
	if(!mob_msg)
		mob_msg = span_userdanger("You reach out and touch [src]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\"")
	if(!cause)
		cause = "contact"
	nom.visible_message(vis_msg, mob_msg, span_hear("You hear an unearthly noise as a wave of heat washes over you."))
	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)
	Consume(nom)

/turf/closed/indestructible/supermatter_wall/attackby(obj/item/item, mob/living/user, params)
	if(!istype(item) || (item.item_flags & ABSTRACT) || !istype(user))
		return
	if(user.dropItemToGround(item))
		user.visible_message(span_danger("As [user] touches \the [src] with \a [item], silence fills the room..."),\
			span_userdanger("You touch \the [src] with \the [item], and everything suddenly goes silent.</span>\n<span class='notice'>\The [item] flashes into dust as you flinch away from \the [src]."),\
			span_hear("Everything suddenly goes silent."))
		investigate_log("has been attacked ([item]) by [key_name(user)]", INVESTIGATE_ENGINE)
		Consume(item)
		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)

	else if(Adjacent(user)) //if the item is stuck to the person, kill the person too instead of eating just the item.
		var/vis_msg = span_danger("[user] reaches out and touches [src] with [item], inducing a resonance... [item] starts to glow briefly before the light continues up to [user]'s body. [user.p_they(TRUE)] bursts into flames before flashing into dust!")
		var/mob_msg = span_userdanger("You reach out and touch [src] with [item]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\"")
		dust_mob(user, vis_msg, mob_msg)

/turf/closed/indestructible/supermatter_wall/Bumped(atom/movable/hit_object)
	if(isliving(hit_object))
		hit_object.visible_message(span_danger("\The [hit_object] slams into \the [src] inducing a resonance... [hit_object.p_their()] body starts to glow and burst into flames before flashing into dust!"),
			span_userdanger("You slam into \the [src] as your ears are filled with unearthly ringing. Your last thought is \"Oh, fuck.\""),
			span_hear("You hear an unearthly noise as a wave of heat washes over you."))
	else if(isobj(hit_object) && !iseffect(hit_object))
		hit_object.visible_message(span_danger("\The [hit_object] smacks into \the [src] and rapidly flashes to ash."), null,
			span_hear("You hear a loud crack as you are washed with a wave of heat."))
	else
		return

	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)
	Consume(hit_object)

/turf/closed/indestructible/supermatter_wall/intercept_zImpact(list/falling_movables, levels)
	. = ..()
	for(var/atom/movable/hit_object as anything in falling_movables)
		Bumped(hit_object)
	. |= FALL_STOP_INTERCEPTING | FALL_INTERCEPTED

/turf/closed/indestructible/supermatter_wall/proc/Consume(atom/movable/consumed_object)
	if(isliving(consumed_object))
		var/mob/living/consumed_mob = consumed_object
		if(consumed_mob.status_flags & GODMODE)
			return
		message_admins("[src] has consumed [key_name_admin(consumed_mob)] [ADMIN_JMP(src)].")
		investigate_log("has consumed [key_name(consumed_mob)].", INVESTIGATE_ENGINE)
		consumed_mob.dust(force = TRUE)
	else if(consumed_object.flags_1 & SUPERMATTER_IGNORES_1)
		return
	else if(isobj(consumed_object))
		qdel(consumed_object)

/obj/cascade_portal
	name = "Bluespace Rift"
	desc = "Your mind begins to bubble and ooze as it tries to comprehend what it sees."
	icon = 'icons/effects/224x224.dmi'
	icon_state = "reality"
	anchored = TRUE
	appearance_flags = LONG_GLIDE
	density = TRUE
	plane = MASSIVE_OBJ_PLANE
	light_color = COLOR_RED
	light_power = 0.7
	light_range = 15
	light_range = 6
	move_resist = INFINITY
	pixel_x = -96
	pixel_y = -96
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/cascade_portal/Bumped(atom/movable/hit_object)
	if(isliving(hit_object))
		hit_object.visible_message(span_danger("\The [hit_object] slams into \the [src] inducing a resonance... [hit_object.p_their()] body starts to glow and burst into flames before flashing into dust!"),
			span_userdanger("You slam into \the [src] as your ears are filled with unearthly ringing. Your last thought is \"Oh, fuck.\""),
			span_hear("You hear an unearthly noise as a wave of heat washes over you."))
	else if(isobj(hit_object) && !iseffect(hit_object))
		hit_object.visible_message(span_danger("\The [hit_object] smacks into \the [src] and rapidly flashes to ash."), null,
			span_hear("You hear a loud crack as you are washed with a wave of heat."))
	else
		return

	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)
	Consume(hit_object)

/obj/cascade_portal/proc/Consume(atom/movable/consumed_object)
	if(isliving(consumed_object))
		var/mob/living/consumed_mob = consumed_object
		if(consumed_mob.status_flags & GODMODE)
			return
		message_admins("[src] has consumed [key_name_admin(consumed_mob)] [ADMIN_JMP(src)].")
		investigate_log("has consumed [key_name(consumed_mob)].", INVESTIGATE_ENGINE)
		consumed_mob.dust(force = TRUE)
	else if(consumed_object.flags_1 & SUPERMATTER_IGNORES_1)
		return
	else if(isobj(consumed_object))
		qdel(consumed_object)
