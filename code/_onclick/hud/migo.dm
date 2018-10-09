

/obj/screen/migo
	icon = 'icons/mob/actions.dmi'

/obj/screen/migo/Hush
	icon_state = "ui_hush"
	name = "Hush"
	desc = "Toggles passive noises and noises when you talk."
	var/obj/screen/migo/CheckHush/checkers

/obj/screen/migo/Hush/Click()
	if(!istype(usr, /mob/living/simple_animal/hostile/netherworld/migo))
		return
	var/mob/living/simple_animal/hostile/netherworld/migo/M = usr
	M.Hush()
	if(checkers)
		if(M.hushed)
			checkers.icon_state = "ui_soundoff"
		else
			checkers.icon_state = "ui_soundon"

/obj/screen/migo/CreateNoise
	icon_state = "ui_noise"
	name = "Fabricate Noise"
	desc = "Creates a specific noise. Different noises have different cooldowns attached to them."

/obj/screen/migo/CreateNoise/Click()
	if(!istype(usr, /mob/living/simple_animal/hostile/netherworld/migo))
		return
	var/mob/living/simple_animal/hostile/netherworld/migo/M = usr
	M.CreateNoise()

/obj/screen/migo/ChangeVoice
	icon_state = "ui_impersonate"
	name = "Tune Voice"
	desc = "Changes your voice to someone else. You will copy the voice patterns if the name matches them."
	var/obj/screen/migo/CheckVoice/checkers

/obj/screen/migo/ChangeVoice/Click()
	if(!istype(usr, /mob/living/simple_animal/hostile/netherworld/migo))
		return
	var/mob/living/simple_animal/hostile/netherworld/migo/M = usr
	if(M.ChangeVoice() && checkers)
		if(M.impersonation)
			checkers.icon_state = "ui_infoon"
		else
			checkers.icon_state = "ui_infooff"

/obj/screen/migo/CheckHush
	icon_state = "ui_soundon"
	name = "Check Noise"
	desc = "Checks what your settings are for making noises right now."

/obj/screen/migo/CheckHush/Click()
	if(!istype(usr, /mob/living/simple_animal/hostile/netherworld/migo))
		return
	var/mob/living/simple_animal/hostile/netherworld/migo/M = usr
	if(M.hushed)
		to_chat(M, "<span class='notice'>You are currently hushed.</span>")
	else
		to_chat(M, "<span class='notice'>You are not hushed and will periodically make noises.</span>")

/obj/screen/migo/CheckVoice
	icon_state = "ui_infooff"
	name = "Fabricate Noise"
	desc = "Checks who you are impersonating."

/obj/screen/migo/CheckVoice/Click()
	if(!istype(usr, /mob/living/simple_animal/hostile/netherworld/migo))
		return
	var/mob/living/simple_animal/hostile/netherworld/migo/M = usr
	if(M.impersonation)
		to_chat(M, "<span class='notice'>You are impersonating [M.impersonation].</span>")
	else
		to_chat(M, "<span class='notice'>You are not impersonating anyone.</span>")

/datum/hud/migo
	var/obj/screen/migo/CheckHush/hushchecker //hey hold these okay
	var/obj/screen/migo/CheckVoice/voicechecker//thanks

/datum/hud/migo/New(mob/owner)
	..()
	var/obj/screen/using
	healths = new /obj/screen/healths/migo()
	infodisplay += healths

	using = new /obj/screen/migo/CheckHush()
	hushchecker = using
	using.screen_loc = ui_ghost_teleport
	static_inventory += using

	using = new /obj/screen/migo/CheckVoice()
	voicechecker = using
	using.screen_loc = ui_ghost_teleport
	static_inventory += using

	using = new /obj/screen/migo/Hush()
	var/obj/screen/migo/Hush/hushvar = using
	hushvar.checkers = hushchecker
	using.screen_loc = ui_ghost_jumptomob
	static_inventory += using

	using = new /obj/screen/migo/CreateNoise()
	using.screen_loc = ui_ghost_orbit
	static_inventory += using

	using = new /obj/screen/migo/ChangeVoice()
	var/obj/screen/migo/ChangeVoice/voicevar = using
	voicevar.checkers = voicechecker
	using.screen_loc = ui_ghost_reenter_corpse
	static_inventory += using
