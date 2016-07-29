<<<<<<< HEAD
/datum/wires/syndicatebomb
	holder_type = /obj/machinery/syndicatebomb
	randomize = TRUE

/datum/wires/syndicatebomb/New(atom/holder)
	wires = list(
		WIRE_BOOM, WIRE_UNBOLT,
		WIRE_ACTIVATE, WIRE_DELAY, WIRE_PROCEED
	)
	..()

/datum/wires/syndicatebomb/interactable(mob/user)
	var/obj/machinery/syndicatebomb/P = holder
	if(P.open_panel)
		return TRUE

/datum/wires/syndicatebomb/on_pulse(wire)
	var/obj/machinery/syndicatebomb/B = holder
	switch(wire)
		if(WIRE_BOOM)
			if(B.active)
				holder.visible_message("<span class='danger'>\icon[B] An alarm sounds! It's go-</span>")
				B.explode_now = TRUE
				tell_admins(B)
		if(WIRE_UNBOLT)
			holder.visible_message("<span class='notice'>\icon[B] The bolts spin in place for a moment.</span>")
		if(WIRE_DELAY)
			if(B.delayedbig)
				holder.visible_message("<span class='notice'>\icon[B] The bomb has already been delayed.</span>")
			else
				holder.visible_message("<span class='notice'>\icon[B] The bomb chirps.</span>")
				playsound(B, 'sound/machines/chime.ogg', 30, 1)
				B.detonation_timer += 300
				B.delayedbig = TRUE
		if(WIRE_PROCEED)
			holder.visible_message("<span class='danger'>\icon[B] The bomb buzzes ominously!</span>")
			playsound(B, 'sound/machines/buzz-sigh.ogg', 30, 1)
			var/seconds = B.seconds_remaining()
			if(seconds >= 61) // Long fuse bombs can suddenly become more dangerous if you tinker with them.
				B.detonation_timer = world.time + 600
			else if(seconds >= 21)
				B.detonation_timer -= 100
			else if(seconds >= 11) // Both to prevent negative timers and to have a little mercy.
				B.detonation_timer = world.time + 100
		if(WIRE_ACTIVATE)
			if(!B.active && !B.defused)
				holder.visible_message("<span class='danger'>\icon[B] You hear the bomb start ticking!</span>")
				B.activate()
				B.update_icon()
			else if(B.delayedlittle)
				holder.visible_message("<span class='notice'>\icon[B] Nothing happens.</span>")
			else
				holder.visible_message("<span class='notice'>\icon[B] The bomb seems to hesitate for a moment.</span>")
				B.detonation_timer += 100
				B.delayedlittle = TRUE

/datum/wires/syndicatebomb/on_cut(wire, mend)
	var/obj/machinery/syndicatebomb/B = holder
	switch(wire)
		if(WIRE_BOOM)
			if(mend)
				B.defused = FALSE // Cutting and mending all the wires of an inactive bomb will thus cure any sabotage.
			else
				if(B.active)
					holder.visible_message("<span class='danger'>\icon[B] An alarm sounds! It's go-</span>")
					B.explode_now = TRUE
					tell_admins(B)
				else
					B.defused = TRUE
		if(WIRE_UNBOLT)
			if(!mend && B.anchored)
				holder.visible_message("<span class='notice'>\icon[B] The bolts lift out of the ground!</span>")
				playsound(B, 'sound/effects/stealthoff.ogg', 30, 1)
				B.anchored = FALSE
		if(WIRE_PROCEED)
			if(!mend && B.active)
				holder.visible_message("<span class='danger'>\icon[B] An alarm sounds! It's go-</span>")
				B.explode_now = TRUE
				tell_admins(B)
		if(WIRE_ACTIVATE)
			if(!mend && B.active)
				holder.visible_message("<span class='notice'>\icon[B] The timer stops! The bomb has been defused!</span>")
				B.active = FALSE
				B.defused = TRUE
				B.update_icon()

/datum/wires/syndicatebomb/proc/tell_admins(obj/machinery/syndicatebomb/B)
	if(istype(B, /obj/machinery/syndicatebomb/training))
		return
	var/turf/T = get_turf(B)
	log_game("\A [B] was detonated via boom wire at [COORD(T)].")
	message_admins("A [B.name] was detonated via boom wire at \
		[ADMIN_COORDJMP(T)].")
=======
/datum/wires/syndicatebomb
	random = 1
	holder_type = /obj/machinery/syndicatebomb
	wire_count = 5

var/const/WIRE_BOOM = 1			// Explodes if pulsed or cut while active, defuses a bomb that isn't active on cut
var/const/WIRE_UNBOLT = 2		// Unbolts the bomb if cut, hint on pulsed
var/const/WIRE_DELAY = 4		// Raises the timer on pulse, does nothing on cut
var/const/WIRE_PROCEED = 8		// Lowers the timer, explodes if cut while the bomb is active
var/const/WIRE_ACTIVATE = 16	// Will start a bombs timer if pulsed, will hint if pulsed while already active, will stop a timer a bomb on cut

/datum/wires/syndicatebomb/UpdatePulsed(var/index)
	var/obj/machinery/syndicatebomb/P = holder
	if(P.degutted)
		return
	switch(index)
		if(WIRE_BOOM)
			if (P.active)
				P.loc.visible_message("<span class='warning'>[bicon(holder)] An alarm sounds! It's go-</span>")
				P.timer = 0
		if(WIRE_UNBOLT)
			P.loc.visible_message("<span class='notice'>[bicon(holder)] The bolts spin in place for a moment.</span>")
		if(WIRE_DELAY)
			playsound(P.loc, 'sound/machines/chime.ogg', 30, 1)
			P.loc.visible_message("<span class='notice'>[bicon(holder)] The bomb chirps.</span>")
			P.timer += 10
		if(WIRE_PROCEED)
			playsound(P.loc, 'sound/machines/buzz-sigh.ogg', 30, 1)
			P.loc.visible_message("<span class='warning'>[bicon(holder)] The bomb buzzes ominously!</span>")
			if (P.timer >= 61) //Long fuse bombs can suddenly become more dangerous if you tinker with them
				P.timer = 60
			if (P.timer >= 21)
				P.timer -= 10
			else if (P.timer >= 11) //both to prevent negative timers and to have a little mercy
				P.timer = 10
		if(WIRE_ACTIVATE)
			if(!P.active && !P.defused)
				playsound(P.loc, 'sound/machines/click.ogg', 30, 1)
				P.loc.visible_message("<span class='warning'>[bicon(holder)] You hear the bomb start ticking!</span>")
				P.active = 1
				if(!P.open_panel) //Needs to exist in case the wire is pulsed with a signaler while the panel is closed
					P.icon_state = "syndicate-bomb-active"
				else
					P.icon_state = "syndicate-bomb-active-wires"
				processing_objects.Add(P)
			else
				P.loc.visible_message("<span class='notice'>[bicon(holder)] The bomb seems to hesitate for a moment.</span>")
				P.timer += 5

/datum/wires/syndicatebomb/UpdateCut(var/index, var/mended)
	var/obj/machinery/syndicatebomb/P = holder
	if(P.degutted)
		return
	switch(index)
		if(WIRE_EXPLODE)
			if(!mended)
				if(P.active)
					P.loc.visible_message("<span class='warning'>[bicon(holder)] An alarm sounds! It's go-</span>")
					P.timer = 0
				else
					P.defused = 1
			if(mended)
				P.defused = 0 //cutting and mending all the wires of an inactive bomb will thus cure any sabotage
		if(WIRE_UNBOLT)
			if (!mended && P.anchored)
				playsound(P.loc, 'sound/effects/stealthoff.ogg', 30, 1)
				P.loc.visible_message("<span class='notice'>[bicon(holder)] The bolts lift out of the ground!</span>")
				P.anchored = 0
		if(WIRE_PROCEED)
			if(!mended && P.active)
				P.loc.visible_message("<span class='warning'>[bicon(holder)] An alarm sounds! It's go-</span>")
				P.timer = 0
		if(WIRE_ACTIVATE)
			if (!mended && P.active)
				P.loc.visible_message("<span class='notice'>[bicon(holder)] The timer stops! The bomb has been defused!</span>")
				P.icon_state = "syndicate-bomb-inactive-wires" //no cutting possible with the panel closed
				P.active = 0
				P.defused = 1
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
