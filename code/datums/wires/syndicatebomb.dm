/datum/wires/syndicatebomb
	var/const/W_BOOM = "boom" // Explodes if pulsed or cut while active, defuses a bomb that isn't active on cut.
	var/const/W_UNBOLT = "unbolt" // Unbolts the bomb if cut, hint on pulsed.
	var/const/W_DELAY = "delay" // Raises the timer on pulse, does nothing on cut.
	var/const/W_PROCEED = "proceed" // Lowers the timer, explodes if cut while the bomb is active.
	var/const/W_ACTIVATE = "activate" // Will start a bombs timer if pulsed, will hint if pulsed while already active, will stop a timer a bomb on cut.

	holder_type = /obj/machinery/syndicatebomb
	randomize = TRUE

/datum/wires/syndicatebomb/New(atom/holder)
	wires = list(
		W_BOOM, W_UNBOLT,
		W_ACTIVATE, W_DELAY, W_PROCEED
	)
	..()

/datum/wires/syndicatebomb/interactable(mob/user)
	var/obj/machinery/syndicatebomb/P = holder
	if(P.open_panel)
		return TRUE

/datum/wires/syndicatebomb/on_pulse(wire)
	var/obj/machinery/syndicatebomb/B = holder
	switch(wire)
		if(W_BOOM)
			if(B.active)
				B.loc.visible_message("<span class='danger'>\icon[B] An alarm sounds! It's go-</span>")
				B.timer = 0
		if(W_UNBOLT)
			B.loc.visible_message("<span class='notice'>\icon[B] The bolts spin in place for a moment.</span>")
		if(W_DELAY)
			B.loc.visible_message("<span class='notice'>\icon[B] The bomb chirps.</span>")
			playsound(B.loc, 'sound/machines/chime.ogg', 30, 1)
			B.timer += 10
		if(W_PROCEED)
			B.loc.visible_message("<span class='danger'>\icon[B] The bomb buzzes ominously!</span>")
			playsound(B.loc, 'sound/machines/buzz-sigh.ogg', 30, 1)
			if(B.timer >= 61) // Long fuse bombs can suddenly become more dangerous if you tinker with them.
				B.timer = 60
			else if(B.timer >= 21)
				B.timer -= 10
			else if(B.timer >= 11) // Both to prevent negative timers and to have a little mercy.
				B.timer = 10
		if(W_ACTIVATE)
			if(!B.active && !B.defused)
				B.loc.visible_message("<span class='danger'>\icon[B] You hear the bomb start ticking!</span>")
				playsound(B.loc, 'sound/machines/click.ogg', 30, 1)
				B.active = 1
				B.update_icon()
			else
				B.loc.visible_message("<span class='notice'>\icon[B] The bomb seems to hesitate for a moment.</span>")
				B.timer += 5

/datum/wires/syndicatebomb/on_cut(wire, mend)
	var/obj/machinery/syndicatebomb/B = holder
	switch(wire)
		if(W_BOOM)
			if(mend)
				B.defused = 0 // Cutting and mending all the wires of an inactive bomb will thus cure any sabotage.
			else
				if(B.active)
					B.loc.visible_message("<span class='danger'>\icon[B] An alarm sounds! It's go-</span>")
					B.timer = 0
				else
					B.defused = 1
		if(W_UNBOLT)
			if(!mend && B.anchored)
				B.loc.visible_message("<span class='notice'>\icon[B] The bolts lift out of the ground!</span>")
				playsound(B.loc, 'sound/effects/stealthoff.ogg', 30, 1)
				B.anchored = 0
		if(W_PROCEED)
			if(!mend && B.active)
				B.loc.visible_message("<span class='danger'>\icon[B] An alarm sounds! It's go-</span>")
				B.timer = 0
		if(W_ACTIVATE)
			if (!mend && B.active)
				B.loc.visible_message("<span class='notice'>\icon[B] The timer stops! The bomb has been defused!</span>")
				B.active = 0
				B.defused = 1
				B.update_icon()