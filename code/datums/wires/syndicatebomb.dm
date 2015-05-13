/datum/wires/syndicatebomb
	random = 1
	holder_type = /obj/machinery/syndicatebomb
	wire_count = 5

var/const/WIRE_BOOM = 1			// Explodes if pulsed or cut while active, defuses a bomb that isn't active on cut
var/const/WIRE_UNBOLT = 2		// Unbolts the bomb if cut, hint on pulsed
var/const/WIRE_DELAY = 4		// Raises the timer on pulse, does nothing on cut
var/const/WIRE_PROCEED = 8		// Lowers the timer, explodes if cut while the bomb is active
var/const/WIRE_ACTIVATE = 16	// Will start a bombs timer if pulsed, will hint if pulsed while already active, will stop a timer a bomb on cut


/datum/wires/syndicatebomb/CanUse(var/mob/living/L)
	var/obj/machinery/syndicatebomb/P = holder
	if(P.open_panel)
		return 1
	return 0

/datum/wires/syndicatebomb/UpdatePulsed(var/index)
	var/obj/machinery/syndicatebomb/P = holder
	switch(index)
		if(WIRE_BOOM)
			if (P.active)
				P.loc.visible_message("<span class='danger'>\icon[holder] An alarm sounds! It's go-</span>")
				P.timer = 0
		if(WIRE_UNBOLT)
			P.loc.visible_message("<span class='notice'>\icon[holder] The bolts spin in place for a moment.</span>")
		if(WIRE_DELAY)
			playsound(P.loc, 'sound/machines/chime.ogg', 30, 1)
			P.loc.visible_message("<span class='notice'>\icon[holder] The bomb chirps.</span>")
			P.timer += 10
		if(WIRE_PROCEED)
			playsound(P.loc, 'sound/machines/buzz-sigh.ogg', 30, 1)
			P.loc.visible_message("<span class='danger'>\icon[holder] The bomb buzzes ominously!</span>")
			if (P.timer >= 61) //Long fuse bombs can suddenly become more dangerous if you tinker with them
				P.timer = 60
			if (P.timer >= 21)
				P.timer -= 10
			else if (P.timer >= 11) //both to prevent negative timers and to have a little mercy
				P.timer = 10
		if(WIRE_ACTIVATE)
			if(!P.active && !P.defused)
				playsound(P.loc, 'sound/machines/click.ogg', 30, 1)
				P.loc.visible_message("<span class='danger'>\icon[holder] You hear the bomb start ticking!</span>")
				P.active = 1
				P.icon_state = "[initial(P.icon_state)]-active[P.open_panel ? "-wires" : ""]"
			else
				P.loc.visible_message("<span class='notice'>\icon[holder] The bomb seems to hesitate for a moment.</span>")
				P.timer += 5

/datum/wires/syndicatebomb/UpdateCut(var/index, var/mended)
	var/obj/machinery/syndicatebomb/P = holder
	switch(index)
		if(WIRE_EXPLODE)
			if(!mended)
				if(P.active)
					P.loc.visible_message("<span class='danger'>\icon[holder] An alarm sounds! It's go-</span>")
					P.timer = 0
				else
					P.defused = 1
			if(mended)
				P.defused = 0 //cutting and mending all the wires of an inactive bomb will thus cure any sabotage
		if(WIRE_UNBOLT)
			if (!mended && P.anchored)
				playsound(P.loc, 'sound/effects/stealthoff.ogg', 30, 1)
				P.loc.visible_message("<span class='notice'>\icon[holder] The bolts lift out of the ground!</span>")
				P.anchored = 0
		if(WIRE_PROCEED)
			if(!mended && P.active)
				P.loc.visible_message("<span class='danger'>\icon[holder] An alarm sounds! It's go-</span>")
				P.timer = 0
		if(WIRE_ACTIVATE)
			if (!mended && P.active)
				P.loc.visible_message("<span class='notice'>\icon[holder] The timer stops! The bomb has been defused!</span>")
				P.icon_state = "[initial(P.icon_state)]-inactive[P.open_panel ? "-wires" : ""]"
				P.active = 0
				P.defused = 1