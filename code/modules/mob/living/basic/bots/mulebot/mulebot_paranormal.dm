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

///Handles the ghosts moving out from the mule
/mob/living/basic/bot/mulebot/paranormal/proc/ghost_moved()
	SIGNAL_HANDLER
	visible_message(span_notice("The ghostly figure vanishes..."))
	UnregisterSignal(load, COMSIG_MOVABLE_MOVED)
	unload()
