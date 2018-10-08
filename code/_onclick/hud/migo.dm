

/obj/screen/migo
	icon = 'icons/mob/actions.dmi'

/obj/screen/migo/MouseEntered(location,control,params)
	openToolTip(usr,src,params,title = name,content = desc, theme = "migo")

/obj/screen/migo/Hush
	icon_state = "ui_hush"
	name = "Hush"
	desc = "Toggles passive noises and noises when you talk."

/obj/screen/migo/Hush/Click()
	if(!istype(usr, /mob/living/simple_animal/hostile/netherworld/migo))
		return
	var/mob/living/simple_animal/hostile/netherworld/migo/M = usr
	M.Hush()
	if(M.hushed)
		icon_state = "ui_speak"
	else
		icon_state = "ui_hush"

/obj/screen/migo/ChangeVoice
	icon_state = "ui_impersonate"
	name = "Tune Voice"
	desc = "Changes your voice to someone else. You will copy the voice patterns if the name matches them."

/obj/screen/migo/ChangeVoice/Click()
	if(!istype(usr, /mob/living/simple_animal/hostile/netherworld/migo))
		return
	var/mob/living/simple_animal/hostile/netherworld/migo/M = usr
	M.ChangeVoice()

/obj/screen/migo/CreateNoise
	icon_state = "ui_noise"
	name = "Fabricate Noise"
	desc = "Creates a specific noise. Different noises have different cooldowns attached to them."

/obj/screen/migo/CreateNoise/Click()
	if(!istype(usr, /mob/living/simple_animal/hostile/netherworld/migo))
		return
	var/mob/living/simple_animal/hostile/netherworld/migo/M = usr
	M.CreateNoise()

/datum/hud/migo/New(mob/owner)
	..()
	var/obj/screen/using
	healths = new /obj/screen/healths/migo()
	infodisplay += healths

	using = new /obj/screen/migo/Hush()
	using.screen_loc = ui_hand_position(2)
	static_inventory += using

	using = new /obj/screen/migo/ChangeVoice()
	using.screen_loc = ui_hand_position(1)
	static_inventory += using

	using = new /obj/screen/migo/CreateNoise()
	using.screen_loc = ui_back
	static_inventory += using
