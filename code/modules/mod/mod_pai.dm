/obj/item/mod/control/proc/insert_pai(mob/user, obj/item/paicard/card)
	if(mod_pai)
		to_chat(user, span_warning("A [mod_pai] is already inserted!"))
		return
	if(!card.pai || !card.pai.mind)
		balloon_alert(user, "pAI unresponsive!")
		return
	balloon_alert(user, "transferring to suit...")
	if(!do_after(user, 5 SECONDS, target = src))
		balloon_alert(user, "interrupted!")
		return FALSE
	if(!user.transferItemToLoc(card, src))
		return

	mod_pai = card.pai
	balloon_alert(user, "pAI transferred to suit")
	balloon_alert(mod_pai, "transferred to a suit")
	mod_pai.can_transmit = TRUE
	mod_pai.can_receive = TRUE
	mod_pai.canholo = FALSE
	mod_pai.remote_control = src
	mod_pai.forceMove(src)
	for(var/datum/action/action as anything in actions)
		action.Grant(mod_pai)
	return TRUE

/obj/item/mod/control/proc/remove_pai(mob/user)
	if(!mod_pai)
		balloon_alert(user, "no pAI to remove!")
		return
	if(!do_after(user, 5 SECONDS, target = src))
		balloon_alert(user, "interrupted!")
		return FALSE
	if(!user.dropItemToGround(mod_pai.card))
		return

	for(var/datum/action/action as anything in actions)
		if(action.owner == mod_pai)
			action.Remove(mod_pai)
	balloon_alert(user, "pAI removed from the suit")
	balloon_alert(mod_pai, "removed from a suit")
	mod_pai.remote_control = null
	mod_pai.canholo = TRUE
	mod_pai = null

#define MOVE_DELAY 2
#define WEARER_DELAY 1
#define LONE_DELAY 5
#define CELL_PER_STEP DEFAULT_CELL_DRAIN * 2.5
#define PAI_FALL_TIME 1 SECONDS

/obj/item/mod/control/relaymove(mob/user, direction)
	if((!active && wearer) || !cell || cell.charge < CELL_PER_STEP  || user != mod_pai || !COOLDOWN_FINISHED(src, cooldown_mod_move) || (wearer?.pulledby?.grab_state > GRAB_PASSIVE))
		return FALSE
	var/timemodifier = MOVE_DELAY * (ISDIAGONALDIR(direction) ? SQRT_2 : 1) * (wearer ? WEARER_DELAY : LONE_DELAY)
	COOLDOWN_START(src, cooldown_mod_move, movedelay * timemodifier + slowdown)
	playsound(src, 'sound/mecha/mechmove01.ogg', 25, TRUE)
	cell.charge = max(0, cell.charge - CELL_PER_STEP)
	if(wearer)
		ADD_TRAIT(wearer, TRAIT_FORCED_STANDING, MOD_TRAIT)
		addtimer(CALLBACK(src, .proc/pai_fall), PAI_FALL_TIME, TIMER_UNIQUE | TIMER_OVERRIDE)
	if(ismovable(wearer?.loc))
		return wearer.loc.relaymove(wearer, direction)
	if(wearer && !wearer.Process_Spacemove(direction))
		return FALSE
	var/atom/movable/mover = wearer || src
	return step(mover, direction)

#undef MOVE_DELAY
#undef WEARER_DELAY
#undef LONE_DELAY
#undef CELL_PER_STEP

/obj/item/mod/control/proc/pai_fall()
	if(!wearer)
		return
	REMOVE_TRAIT(wearer, TRAIT_FORCED_STANDING, MOD_TRAIT)
