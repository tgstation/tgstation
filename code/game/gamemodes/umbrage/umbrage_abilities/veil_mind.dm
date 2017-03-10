//Converts people within three tiles of the caster into veils. Also confuses noneligible targets and stuns silicons.
/datum/action/innate/umbrage/veil_mind
	name = "Veil Mind"
	id = "veil_mind"
	desc = "Converts nearby eligible targets into thralls. To be eligible, they must be alive and recently drained by Devour Will."
	button_icon_state = "umbrage_veil_mind"
	check_flags = AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS
	psi_cost = 30
	lucidity_cost = 1 //Yep, thralling is optional! It's just one of many possible playstyles.
	blacklisted = 0

/datum/action/innate/umbrage/veil_mind/Activate()
	var/mob/living/carbon/human/H = owner
	if(!H.can_speak_vocal())
		to_chat(H, "<span class='warning'>You can't speak!</span>")
		return
	owner.visible_message("<span class='warning'>[owner]'s sigils flare as they inhale...</span>", "<span class='velvet bold'>dawn kqn okjc...</span><br>\
	<span class='notice'>You take a deep breath...</span>")
	playsound(owner, 'sound/magic/veil_mind_gasp.ogg', 25, 1)
	if(!do_after(owner, 10, target = owner))
		return
	owner.visible_message("<span class='boldwarning'>[owner] lets out a chilling cry!</span>", "<span class='velvet bold'>...wjz oanra</span><br>\
	<span class='notice'>You veil the minds of everyone nearby.</span>")
	playsound(owner, 'sound/magic/veil_mind_scream.ogg', 100, 1)
	for(var/mob/living/L in view(3, owner))
		if(L == owner)
			continue
		if(issilicon(L))
			to_chat(L, "<span class='ownerdanger'>$@!) ERR: RECEPTOR OVERLOAD ^!</</span>")
			L << sound('sound/misc/interference.ogg', volume = 50)
			L.emote("alarm")
			L.Stun(2)
			L.overlay_fullscreen("flash", /obj/screen/fullscreen/flash/static)
			L.clear_fullscreen("flash", 10)
		else
			if(L.ear_deaf)
				to_chat(L, "<span class='warning'>...but you can't hear it!</span>")
			else
				if(L.status_flags & FAKEDEATH)
					if(ticker.mode.antag_veil(L))
						to_chat(owner, "<span class='velvet'><b>[L.real_name]</b> has become a veil!</span>")
				else
					to_chat(L, "<span class='boldwarning'>...and it scrambles your thoughts!</span>")
					L.dir = pick(cardinal)
					L.confused += 2
	return TRUE
