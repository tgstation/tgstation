/*
	Telekinesis

	This needs more thinking out, but I might as well.
*/

#define TK_MAXRANGE 15


/**
 * Telekinesis attack act, happens when the TK user clicks on a non-adjacent target in range.
 *
 * * By default, emulates the user's unarmed attack.
 * * Called indirectly by the `COMSIG_MOB_ATTACK_RANGED` signal.
 * * Returns `COMPONENT_CANCEL_ATTACK_CHAIN` when it performs any action, to further acts on the attack chain.
 */
/atom/proc/attack_tk(mob/user)
	if(user.stat || !tkMaxRangeCheck(user, src))
		return
	new /obj/effect/temp_visual/telekinesis(get_turf(src))
	add_hiddenprint(user)
	user.UnarmedAttack(src, FALSE) // attack_hand, attack_paw, etc
	return COMPONENT_CANCEL_ATTACK_CHAIN


/obj/attack_tk(mob/user)
	if(user.stat)
		return
	if(anchored)
		return ..()
	return attack_tk_grab(user)


/obj/item/attack_tk(mob/user)
	if(user.stat)
		return
	return attack_tk_grab(user)


/**
 * Telekinesis object grab act.
 *
 * * Called by `/obj/attack_tk()`.
 * * Returns `COMPONENT_CANCEL_ATTACK_CHAIN` when it performs any action, to further acts on the attack chain.
 */
/obj/proc/attack_tk_grab(mob/user)
	var/obj/item/tk_grab/O = new(src)
	O.tk_user = user
	if(!O.focus_object(src))
		return
	user.put_in_active_hand(O)
	add_hiddenprint(user)
	return COMPONENT_CANCEL_ATTACK_CHAIN


/mob/attack_tk(mob/user)
	return


/**
 * Telekinesis item attack_self act.
 *
 * * This is similar to item attack_self, but applies to anything that you can grab with a telekinetic grab.
 * * It is used for manipulating things at range, for example, opening and closing closets..
 * * Defined at the `/atom` level but only used at the `/obj/item` one.
 * * Returns `COMPONENT_CANCEL_ATTACK_CHAIN` when it performs any action, to further acts on the attack chain.
 */
/atom/proc/attack_self_tk(mob/user)
	return


/obj/item/attack_self_tk(mob/user)
	if(attack_self(user))
		return COMPONENT_CANCEL_ATTACK_CHAIN


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
	item_flags = NOBLUDGEON | ABSTRACT | DROPDEL
	//inhand_icon_state = null
	w_class = WEIGHT_CLASS_GIGANTIC
	layer = ABOVE_HUD_LAYER
	plane = ABOVE_HUD_PLANE

	///Object focused / selected by the TK user
	var/atom/movable/focus
	var/mob/living/carbon/tk_user

/obj/item/tk_grab/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/item/tk_grab/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	focus = null
	tk_user = null
	return ..()

/obj/item/tk_grab/process()
	if(check_if_focusable(focus)) //if somebody grabs your thing, no waiting for them to put it down and hitting them again.
		update_appearance()

/obj/item/tk_grab/dropped(mob/user)
	if(focus && user && loc != user && loc != user.loc) // drop_item() gets called when you tk-attack a table/closet with an item
		if(focus.Adjacent(loc))
			focus.forceMove(loc)
	. = ..()

//stops TK grabs being equipped anywhere but into hands
/obj/item/tk_grab/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_HANDS)
		return
	qdel(src)

/obj/item/tk_grab/examine(user)
	if (focus)
		return focus.examine(user)
	else
		return ..()


/obj/item/tk_grab/attack_self(mob/user)
	if(!focus)
		return
	if(QDELING(focus))
		qdel(src)
		return
	if(focus.attack_self_tk(user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		. = TRUE
	update_appearance()


/obj/item/tk_grab/afterattack(atom/target, mob/living/carbon/user, proximity, params)//TODO: go over this
	. = ..()
	if(.)
		return

	if(!target || !user)
		return

	if(!focus)
		focus_object(target)
		return TRUE

	if(!check_if_focusable(focus))
		return

	if(target == focus)
		if(target.attack_self_tk(user) & COMPONENT_CANCEL_ATTACK_CHAIN)
			. = TRUE
		update_appearance()
		return

	if(!isturf(target) && isitem(focus) && target.Adjacent(focus))
		apply_focus_overlay()
		var/obj/item/I = focus
		. = I.melee_attack_chain(tk_user, target, params) //isn't copying the attack chain fun. we should do it more often.
		if(check_if_focusable(focus))
			focus.do_attack_animation(target, null, focus)
	else
		. = TRUE
		apply_focus_overlay()
		//Only items can be thrown 10 tiles everything else only 1 tile
		focus.throw_at(target, focus.tk_throw_range, 1,user)
	user.changeNext_move(CLICK_CD_MELEE)
	update_appearance()


/proc/tkMaxRangeCheck(mob/user, atom/target)
	var/d = get_dist(user, target)
	if(d > TK_MAXRANGE)
		to_chat(user, "<span class='warning'>Your mind won't reach that far.</span>")
		return
	return TRUE

/obj/item/tk_grab/attack(mob/living/M, mob/living/user, def_zone)
	return

/obj/item/tk_grab/proc/focus_object(obj/target)
	if(!check_if_focusable(target))
		return
	focus = target
	update_appearance()
	apply_focus_overlay()
	return TRUE

/obj/item/tk_grab/proc/check_if_focusable(obj/target)
	if(!tk_user || !istype(tk_user) || QDELETED(target) || !istype(target) || !tk_user.dna.check_mutation(TK))
		qdel(src)
		return
	if(!tkMaxRangeCheck(tk_user, target) || target.anchored || !isturf(target.loc))
		qdel(src)
		return
	return TRUE

/obj/item/tk_grab/proc/apply_focus_overlay()
	if(!focus)
		return
	new /obj/effect/temp_visual/telekinesis(get_turf(focus))

/obj/item/tk_grab/update_overlays()
	. = ..()
	if(!focus)
		return

	var/mutable_appearance/focus_overlay = new(focus)
	focus_overlay.layer = layer + 0.01
	focus_overlay.plane = ABOVE_HUD_PLANE
	. += focus_overlay

/obj/item/tk_grab/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is using [user.p_their()] telekinesis to choke [user.p_them()]self! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (OXYLOSS)


#undef TK_MAXRANGE
