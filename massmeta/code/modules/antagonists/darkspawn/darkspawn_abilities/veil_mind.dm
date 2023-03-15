//Converts people within three tiles of the caster into veils. Also confuses noneligible targets and stuns silicons.
/datum/action/innate/darkspawn/veil_mind
	name = "Veil Mind"
	id = "veil_mind"
	desc = "Converts nearby eligible targets into veils. To be eligible, they must be alive and recently drained by Devour Will."
	button_icon_state = "veil_mind"
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_CONSCIOUS
	psi_cost = 60 //since this is only useful when cast directly after a succ it should be pretty expensive
	lucidity_price = 2

/datum/action/innate/darkspawn/veil_mind/Activate()
	var/mob/living/carbon/human/H = owner
	if(!H.can_speak())
		to_chat(H, span_warning("You can't speak!"))
		return
	owner.visible_message(span_warning("[owner]'s sigils flare as they inhale..."), "<span class='velvet bold'>dawn kqn okjc...</span><br>\
	[span_notice("You take a deep breath...")]")
	playsound(owner, 'massmeta/sounds/ambience/antag/veil_mind_gasp.ogg', 25)
	if(!do_after(owner, 1 SECONDS, owner))
		return
	owner.visible_message(span_boldwarning("[owner] lets out a chilling cry!"), "<span class='velvet bold'>...wjz oanra</span><br>\
	[span_notice("You veil the minds of everyone nearby.")]")
	playsound(owner, 'massmeta/sounds/ambience/antag/veil_mind_scream.ogg', 100)
	for(var/mob/living/L in view(3, owner))
		if(L == owner)
			continue
		if(issilicon(L))
			to_chat(L, span_userdanger("$@!) ERR: RECEPTOR OVERLOAD ^!</"))
			SEND_SOUND(L, sound('sound/misc/interference.ogg', volume = 50))
			L.emote("alarm")
			L.Stun(20)
			L.overlay_fullscreen("flash", /atom/movable/screen/fullscreen/flash/static)
			L.clear_fullscreen("flash", 10)
		else
			if(HAS_TRAIT(L, TRAIT_DEAF))
				to_chat(L, span_warning("...but you can't hear it!"))
			else
				if(L.has_status_effect(STATUS_EFFECT_BROKEN_WILL))
					if(L.add_veil())
						to_chat(owner, span_velvet("<b>[L.real_name]</b> has become a veil!"))
				else
					to_chat(L, span_boldwarning("...and it scrambles your thoughts!"))
					L.dir = pick(GLOB.cardinals)
					L.adjust_confusion(2 SECONDS)
	return TRUE
