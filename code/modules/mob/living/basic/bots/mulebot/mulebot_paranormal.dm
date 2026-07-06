/mob/living/basic/bot/mulebot/paranormal
	name = "\improper GHOULbot"
	desc = "A rather ghastly looking... Multiple Utility Load Effector bot? It only seems to accept paranormal forces, and for this reason is fucking useless."
	icon_state = "paranormalmulebot0"
	base_icon_state = "paranormalmulebot"
	///avoid the utterly miniscule chance of infinite looping
	replacement_chance = 0

/mob/living/basic/bot/mulebot/paranormal/update_overlays()
	. = ..()
	if(!isobserver(load))
		return
	var/mutable_appearance/ghost_overlay = mutable_appearance('icons/mob/simple/mob.dmi', "ghost", layer + 0.01) //use a generic ghost icon, otherwise you can metagame who's dead if they have a custom ghost set
	ghost_overlay.pixel_y = 12
	. += ghost_overlay

/mob/living/basic/bot/mulebot/paranormal/get_load_name() //Don't reveal the name of ghosts so we can't metagame who died and all that.
	. = ..()
	if(. && isobserver(load))
		return "Unknown"

/mob/living/basic/bot/mulebot/paranormal/load(atom/movable/movable_atom)
	if(load || movable_atom.anchored)
		return

	if(!isturf(movable_atom.loc)) //To prevent the loading from stuff from someone's inventory or screen icons.
		return

	if(isobserver(movable_atom))
		visible_message(span_warning("A ghostly figure appears on [src]!"))
		movable_atom.forceMove(src)
		RegisterSignal(movable_atom, COMSIG_MOVABLE_MOVED, PROC_REF(ghost_moved))

	else if(!wires.is_cut(WIRE_LOADCHECK))
		buzz(MULEBOT_MOOD_SIGH)
		return // if not hacked, only allow ghosts to be loaded

	else if(isobj(movable_atom))
		if(movable_atom.has_buckled_mobs() || (locate(/mob) in movable_atom)) //can't load non crates objects with mobs buckled to it or inside it.
			buzz(MULEBOT_MOOD_SIGH)
			return

		if(istype(movable_atom, /obj/structure/closet/crate))
			var/obj/structure/closet/crate/crate = movable_atom
			crate.close() //make sure it's closed

		movable_atom.forceMove(src)

	else if(isliving(movable_atom) && !load_mob(movable_atom))
		return

	load = movable_atom
	update_bot_mode(new_mode = BOT_IDLE)
	update_appearance()

///Handles the ghosts moving out from the mule
/mob/living/basic/bot/mulebot/paranormal/proc/ghost_moved()
	SIGNAL_HANDLER
	visible_message(span_notice("The ghostly figure vanishes..."))
	UnregisterSignal(load, COMSIG_MOVABLE_MOVED)
	unload()
