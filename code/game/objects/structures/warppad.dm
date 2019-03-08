/obj/structure/warp_pad_frame
	name = "warp pad frame"
	icon = 'icons/turf/floors.dmi'
	desc = "Just needs a Bluespace Crystal."
	icon_state = "light_off"
	density = FALSE
	anchored = TRUE
	layer = ABOVE_OPEN_TURF_LAYER

/obj/structure/warp_pad_frame/attackby(obj/item/W, mob/user, params)
	if(istype(W,/obj/item/stack/sheet/bluespace_crystal))
		var/obj/item/stack/sheet/bluespace_crystal/BS = W
		BS.use(1)
		to_chat(user, "<span class='notice'>You add the bluespace crystals and the pad hums to life.</span>")
		new /obj/structure/warp_pad(src.loc)
		del(src)
	else
		return ..()

/obj/structure/galaxy_warp_frame
	name = "galaxy warp frame"
	icon = 'icons/turf/floors.dmi'
	desc = "Just needs 3 Bluespace Crystals."
	icon_state = "light_off"
	density = FALSE
	anchored = TRUE
	layer = ABOVE_OPEN_TURF_LAYER

/obj/structure/galaxy_warp_frame/attackby(obj/item/W, mob/user, params)
	if(istype(W,/obj/item/stack/sheet/bluespace_crystal))
		var/obj/item/stack/sheet/bluespace_crystal/BS = W
		if(BS.amount >= 3)
			BS.use(3)
			to_chat(user, "<span class='notice'>You add the bluespace crystals and the pad hums to life.</span>")
			new /obj/structure/galaxy_warp(src.loc)
			del(src)
		else
			to_chat(user, "<span class='notice'>You need 3 bluespace crystals.</span>")
	else
		return ..()

/obj/structure/warp_pad
	name = "warp pad (UNMARKED)"
	icon = 'icons/turf/floors.dmi'
	desc = "Warp everything standing on this to another pad in the same Z-level. Provided you're a gem of course."
	icon_state = "light_on-w"
	density = FALSE
	anchored = TRUE
	layer = ABOVE_OPEN_TURF_LAYER
	var/warplocation = null

/obj/structure/warp_pad/berrybattlefield
	name = "warp pad (Berry Battlefield)"
	warplocation = "Berry Battlefield"

/obj/structure/warp_pad/earthgalaxywarp
	name = "warp pad (Earth Galaxy Warp)"
	warplocation = "Earth Galaxy Warp"

/obj/structure/warp_pad/attack_hand(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(isgem(H))
			if(warplocation == null)
				to_chat(user, "<span class='notice'>The warp pad isn't set up yet, get a multitool.</span>")
				return //have to set this thing first.
			var/list/warppads = list()
			for(var/obj/structure/warp_pad/W in world)
				if(W.z == src.z) //has to be on same z-level.
					if(W.warplocation != null && W != src) //no null warp pads either
						warppads.Add(W)

			var/obj/structure/warp_pad/W = input("Where do you wish to warp?") as null|anything in warppads
			if(W != null)
				playsound(src, 'sound/effects/warppad.ogg', 50)
				for(var/atom/A in range(src,0))
					if(istype(A,/mob))
						var/mob/M = A
						M.loc = W.loc
					if(istype(A,/obj) && A != src)
						var/obj/O = A
						O.loc = W.loc
				new /obj/effect/temp_visual/warpout(src.loc)
				new /obj/effect/temp_visual/warpin(W.loc)
				playsound(W, 'sound/effects/warppad.ogg', 50)
		else
			to_chat(user, "<span class='notice'>You can't seem to use this.</span>")
	else
		to_chat(user, "<span class='notice'>You can't seem to use this.</span>")

/obj/structure/warp_pad/attackby(obj/item/W, mob/user, params)
	if(istype(W,/obj/item/multitool))
		warplocation = input("What do you wish to name this warp pad?") as text
		name = "warp pad ([warplocation])"
	else
		return ..()


/obj/structure/galaxy_warp
	name = "galaxy warp (UNMARKED)"
	desc = "Warp everything standing on this to another galaxy warp. Provided you're a gem of course."
	icon = 'icons/turf/floors.dmi'
	icon_state = "light_on-w"
	density = FALSE
	anchored = TRUE
	layer = ABOVE_OPEN_TURF_LAYER
	var/warplocation = null

/obj/structure/galaxy_warp/researchfacility
	name = "galaxy warp (Biological Research Facility)"
	warplocation = "Biological Research Facility"

/obj/structure/galaxy_warp/zoo
	name = "galaxy warp (Pink's Human Zoo)"
	warplocation = "Pink's Human Zoo"

/obj/structure/galaxy_warp/earth
	name = "galaxy warp (Earth)"
	warplocation = "Earth"

/obj/structure/galaxy_warp/attack_hand(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(isgem(H))
			if(warplocation == null)
				to_chat(user, "<span class='notice'>The warp pad isn't set up yet, get a multitool.</span>")
				return //have to set this thing first.
			var/list/warppads = list()
			for(var/obj/structure/galaxy_warp/W in world)
				if(W.warplocation != null && W != src) //no null warp pads either
					warppads.Add(W)

			var/obj/structure/galaxy_warp/W = input("Where do you wish to warp?") as null|anything in warppads
			if(W != null)
				playsound(src, 'sound/effects/warppad.ogg', 50)
				for(var/atom/A in range(src,0))
					if(istype(A,/mob))
						var/mob/M = A
						M.loc = W.loc
					if(istype(A,/obj) && A != src)
						var/obj/O = A
						O.loc = W.loc
				new /obj/effect/temp_visual/warpout(src.loc)
				new /obj/effect/temp_visual/warpin(W.loc)
				playsound(W, 'sound/effects/warppad.ogg', 50)

/obj/structure/galaxy_warp/attackby(obj/item/W, mob/user, params)
	if(istype(W,/obj/item/multitool))
		warplocation = input("What do you wish to name this galaxy warp?") as text
		name = "galaxy warp ([warplocation])"
	else
		return ..()