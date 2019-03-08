/obj/item/gemwarpwhistle
	name = "warp whistle"
	desc = "One toot on this whistle will activate any and all warp pads and galaxy warps!"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "whistle"

/obj/item/gemwarpwhistle/attack_self(mob/living/carbon/user)
	var/foundwarp = FALSE
	for(var/obj/structure/galaxy_warp/WARP in view(user,0))
		if(foundwarp == FALSE)
			foundwarp = TRUE
			if(WARP.warplocation == null)
				to_chat(user, "<span class='notice'>The warp pad isn't set up yet, get a multitool.</span>")
				return //have to set this thing first.
			var/list/warppads = list()
			for(var/obj/structure/galaxy_warp/W in world)
				if(W.warplocation != null && W != WARP) //no null warp pads either
					warppads.Add(W)

			var/obj/structure/galaxy_warp/W = input("Where do you wish to warp?") as null|anything in warppads
			if(W != null)
				playsound(WARP, 'sound/effects/warppad.ogg', 50)
				for(var/atom/A in range(WARP,0))
					if(istype(A,/mob))
						var/mob/M = A
						M.loc = W.loc
					if(istype(A,/obj) && A != WARP)
						var/obj/O = A
						O.loc = W.loc
				new /obj/effect/temp_visual/warpout(WARP.loc)
				new /obj/effect/temp_visual/warpin(W.loc)
				playsound(W, 'sound/effects/warppad.ogg', 50)

	for(var/obj/structure/warp_pad/WARP in view(user,0))
		if(foundwarp == FALSE)
			foundwarp = TRUE
			if(WARP.warplocation == null)
				to_chat(user, "<span class='notice'>The warp pad isn't set up yet, get a multitool.</span>")
				return //have to set this thing first.
			var/list/warppads = list()
			for(var/obj/structure/warp_pad/W in world)
				if(W.z == WARP.z) //has to be on same z-level.
					if(W.warplocation != null && W != WARP) //no null warp pads either
						warppads.Add(W)

			var/obj/structure/warp_pad/W = input("Where do you wish to warp?") as null|anything in warppads
			if(W != null)
				playsound(WARP, 'sound/effects/warppad.ogg', 50)
				for(var/atom/A in range(WARP,0))
					if(istype(A,/mob))
						var/mob/M = A
						M.loc = W.loc
					if(istype(A,/obj) && A != WARP)
						var/obj/O = A
						O.loc = W.loc
				new /obj/effect/temp_visual/warpout(WARP.loc)
				new /obj/effect/temp_visual/warpin(W.loc)
				playsound(W, 'sound/effects/warppad.ogg', 50)

	if(foundwarp == FALSE)
		to_chat(user, "<span class='notice'>You play the Whistle, but nothing happens.</span>")