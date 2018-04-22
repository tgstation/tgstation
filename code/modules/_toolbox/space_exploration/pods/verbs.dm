/obj/pod

	verb/LeavePod()
		set name = "Exit Pod"
		set category = "Pod"
		set src = usr.loc

		if(istype(usr, /mob/living/carbon/human))
			if(usr.canUseTopic(src))
				HandleExit(usr)

	verb/EnterPod()
		set name = "Enter Pod"
		set category = "Pod"
		set src in view(1)

		if(istype(usr, /mob/living/carbon/human))
			// canUseTopic doesn't play nice with 64x64
			var/mob/living/carbon/human/L = usr
			if(L.restrained() || L.lying || L.stat || L.AmountStun() || L.AmountKnockdown())
				return 0
			if(!(usr in bounds(1)))
				return 0
			if(!isturf(src.loc) && get(src.loc, usr.type) != usr)
				return 0
			HandleEnter(usr)

	verb/OpenHUDVerb()
		set name = "Open HUD"
		set category = "Pod"
		set src = usr.loc

		OpenHUD(usr)