
//**************************************************************
// Telekinetic Grab
//**************************************************************

/obj/item/tk_grab
	name = "Telekinetic Grab"
	desc = "Magic"
	icon = 'icons/obj/magic.dmi'
	icon_state = "2"
	flags = NOBLUDGEON
	w_class = 10.0
	layer = 20
	
	var/last_throw = 0
	var/atom/movable/focus = null
	var/mob/living/host = null
	
/obj/item/tk_grab/dropped(mob/user)
	if(src.focus && user && src.loc != user && src.loc != user.loc && focus.Adjacent(loc))
		focus.loc = src.loc
	del(src)
	return

/obj/item/tk_grab/equipped(var/mob/user,var/slot)
	if( (slot == slot_l_hand) || (slot== slot_r_hand) )	return
	del(src)
	return

/obj/item/tk_grab/attack_self(mob/user)
	if(focus) focus.attack_self_tk(user)
	return

/obj/item/tk_grab/afterattack(atom/target,mob/living/user) //TODO: Rewrite this
	if(!target || !user)	return
	if(last_throw+3 > world.time)	return
	if(!host || host != user)
		del(src)
		return
	if(!(M_TK in host.mutations))
		del(src)
		return
	if(isobj(target) && !isturf(target.loc))
		return
	var/d = get_dist(user, target)
	if(focus)
		d = max(d,get_dist(user,focus)) // whichever is further
	if(d > tk_maxrange)
		user << "<span class='warning'>Your mind won't reach that far.</span>"
		return
	if(!focus)
		focus_object(target, user)
		return
	if(target == focus)
		target.attack_self_tk(user)
		return // todo: something like attack_self not laden with assumptions inherent to attack_self
	if(!istype(target, /turf) && istype(focus,/obj/item) && target.Adjacent(focus))
		var/obj/item/I = focus
		var/resolved = target.attackby(I, user, user:get_organ_target())
		if(!resolved && target && I)
			I.afterattack(target,user,1) // for splashing with beakers
	else
		apply_focus_overlay()
		focus.throw_at(target, 10, 1)
		last_throw = world.time
	return

/obj/item/tk_grab/attack(mob/living/target,mob/living/user,def_zone)
	return

/obj/item/tk_grab/proc/focus_object(var/obj/target,var/mob/living/user)
	if(istype(target,/obj))
		if(!target.anchored && isturf(target.loc))
			src.focus = target
			src.update_icon()
			src.apply_focus_overlay()
		else del(src)
	return

/obj/item/tk_grab/proc/apply_focus_overlay()
	if(src.focus)
		var/obj/effect/overlay/O = new(locate(src.focus.x,src.focus.y,src.focus.z))
		O.name = "sparkles"
		O.anchored = 1
		O.density = 0
		O.layer = FLY_LAYER
		O.dir = pick(cardinal)
		O.icon = 'icons/effects/effects.dmi'
		O.icon_state = "nothing"
		flick("empdisable",O)
		spawn(5) qdel(O)
	return

/obj/item/tk_grab/update_icon()
	src.overlays.Cut()
	if(src.focus && src.focus.icon && src.focus.icon_state)
		src.overlays += icon(focus.icon,focus.icon_state)
	return
