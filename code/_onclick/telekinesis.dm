/*
	Telekinesis

	This needs more thinking out, but I might as well.
*/
var/const/tk_maxrange = 15

/*
	Telekinetic attack:

	By default, emulate the user's unarmed attack
*/
/atom/proc/attack_tk(mob/user)
	if(user.stat)
		return
	user.UnarmedAttack(src,0) // attack_hand, attack_paw, etc
	return

/*
	This is similar to item attack_self, but applies to anything
	that you can grab with a telekinetic grab.

	It is used for manipulating things at range, for example, opening and closing closets.
	There are not a lot of defaults at this time, add more where appropriate.
*/
/atom/proc/attack_self_tk(mob/user)
	return

/obj/item/attack_self_tk(mob/user)
	attack_self(user)

/obj/attack_tk(mob/user)
	if(user.stat)
		return
	if(anchored)
		..()
		return

	var/obj/item/tk_grab/O = new(src)
	user.put_in_active_hand(O)
	O.host = user
	O.focus_object(src)
	return

/obj/item/attack_tk(mob/user)
	if(user.stat)
		return
	var/obj/item/tk_grab/O = new(src)
	user.put_in_active_hand(O)
	O.host = user
	O.focus_object(src)
	return


/mob/attack_tk(mob/user)
	return // needs more thinking about

/*
	TK Grab Item (the workhorse of old TK)

	* If you have not grabbed something, do a normal tk attack
	* If you have something, throw it at the target.  If it is already adjacent, do a normal attackby()
	* If you click what you are holding, or attack_self(), do an attack_self_tk() on it.
	* Deletes itself if it is ever not in your hand, or if you should have no access to TK.
*/
/obj/item/tk_grab
	name = "Telekinetic Grab"
	desc = "Magic"
	icon = 'icons/obj/magic.dmi'//Needs sprites
	icon_state = "2"
	flags = NOBLUDGEON | ABSTRACT | DROPDEL
	//item_state = null
	w_class = WEIGHT_CLASS_GIGANTIC
	layer = ABOVE_HUD_LAYER
	plane = ABOVE_HUD_PLANE

	var/last_throw = 0
	var/atom/movable/focus = null
	var/mob/living/host = null


/obj/item/tk_grab/dropped(mob/user)
	if(focus && user && loc != user && loc != user.loc) // drop_item() gets called when you tk-attack a table/closet with an item
		if(focus.Adjacent(loc))
			focus.loc = loc
	. = ..()

//stops TK grabs being equipped anywhere but into hands
/obj/item/tk_grab/equipped(mob/user, slot)
	if(slot == slot_hands)
		return
	qdel(src)
	return

/obj/item/tk_grab/attack_hand(mob/user)
	return

/obj/item/tk_grab/attack_self(mob/user)
	if(!focus)
		return
	if(qdeleted(focus))
		qdel(src)
		return
	focus.attack_self_tk(user)
	update_icon()

/obj/item/tk_grab/afterattack(atom/target, mob/living/carbon/user, proximity, params)//TODO: go over this
	if(!target || !user)
		return
	if(last_throw+3 > world.time)
		return
	if(!host || host != user)
		qdel(src)
		return
	if(!(user.dna.check_mutation(TK)))
		qdel(src)
		return
	if(isobj(target) && !isturf(target.loc))
		return

	if(!tkMaxRangeCheck(user, target, focus))
		return

	if(!focus)
		focus_object(target, user)
		return

	if(focus.anchored || !isturf(focus.loc))
		qdel(src)
		return

	if(target == focus)
		target.attack_self_tk(user)
		return // todo: something like attack_self not laden with assumptions inherent to attack_self


	if(!isturf(target) && istype(focus,/obj/item) && target.Adjacent(focus))
		var/obj/item/I = focus
		var/resolved = target.attackby(I, user, params)
		if(!resolved && target && I)
			I.afterattack(target,user,1) // for splashing with beakers
			update_icon()
	else
		apply_focus_overlay()
		focus.throw_at(target, 10, 1,user)
		last_throw = world.time
		user.changeNext_move(CLICK_CD_MELEE)
		update_icon()

/proc/tkMaxRangeCheck(mob/user, atom/target, atom/focus)
	var/d = get_dist(user, target)
	if(focus)
		d = max(d,get_dist(user,focus)) // whichever is further
	if(d > tk_maxrange)
		user << "<span class ='warning'>Your mind won't reach that far.</span>"
		return 0
	return 1

/obj/item/tk_grab/attack(mob/living/M, mob/living/user, def_zone)
	return


/obj/item/tk_grab/proc/focus_object(obj/target, mob/living/user)
	if(!isobj(target))
		return//Cant throw non objects atm might let it do mobs later
	if(target.anchored || !isturf(target.loc))
		qdel(src)
		return
	focus = target
	update_icon()
	apply_focus_overlay()
	return


/obj/item/tk_grab/proc/apply_focus_overlay()
	if(!focus)
		return
	PoolOrNew(/obj/effect/overlay/temp/telekinesis, get_turf(focus))


/obj/item/tk_grab/update_icon()
	cut_overlays()
	if(focus && focus.icon && focus.icon_state)
		add_overlay(icon(focus.icon,focus.icon_state))
	return

/obj/item/tk_grab/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is using [user.p_their()] telekinesis to choke [user.p_them()]self! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (OXYLOSS)

/*Not quite done likely needs to use something thats not get_step_to
/obj/item/tk_grab/proc/check_path()
	var/turf/ref = get_turf(src.loc)
	var/turf/target = get_turf(focus.loc)
	if(!ref || !target)
		return 0
	var/distance = get_dist(ref, target)
	if(distance >= 10)
		return 0
	for(var/i = 1 to distance)
		ref = get_step_to(ref, target, 0)
	if(ref != target)
		return 0
	return 1
*/

//equip_to_slot_or_del(obj/item/W, slot, qdel_on_fail = 1)
/*
		if(istype(user, /mob/living/carbon))
			if(user:mutations & TK && get_dist(source, user) <= 7)
				if(user:get_active_hand())
					return 0
				var/X = source:x
				var/Y = source:y
				var/Z = source:z

*/
