/obj/effect/sign/securearea/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			del(src)
			return
		if(3.0)
			del(src)
			return
		else
	return

/obj/effect/sign/securearea/blob_act()
	del(src)
	return


/obj/effect/sign/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			del(src)
			return
		if(3.0)
			del(src)
			return
		else
	return

/obj/effect/sign/blob_act()
	del(src)
	return


/obj/effect/sign/map
	desc = "A framed picture of the station."
	name = "station map"
	icon = 'icons/obj/decals.dmi'
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/map/left
	icon_state = "map-left"

/obj/effect/sign/map/right
	icon_state = "map-right"

/obj/effect/sign/securearea
	desc = "A warning sign which reads 'SECURE AREA'. This obviously applies to a nun-Clown."
	name = "SECURE AREA"
	icon = 'icons/obj/decals.dmi'
	icon_state = "securearea"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/biohazard
	desc = "A warning sign which reads 'BIOHAZARD'"
	name = "BIOHAZARD"
	icon = 'icons/obj/decals.dmi'
	icon_state = "bio"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/electricshock
	desc = "A warning sign which reads 'HIGH VOLTAGE'"
	name = "HIGH VOLTAGE"
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/examroom
	desc = "A guidance sign which reads 'EXAM ROOM'"
	name = "EXAM"
	icon = 'icons/obj/decals.dmi'
	icon_state = "examroom"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/vacuum
	desc = "A warning sign which reads 'HARD VACUUM AHEAD'"
	name = "HARD VACUUM AHEAD"
	icon = 'icons/obj/decals.dmi'
	icon_state = "space"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/deathsposal
	desc = "A warning sign which reads 'DISPOSAL LEADS TO SPACE'"
	name = "DISPOSAL LEADS TO SPACE"
	icon = 'icons/obj/decals.dmi'
	icon_state = "deathsposal"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/pods
	desc = "A warning sign which reads 'ESCAPE PODS'"
	name = "ESCAPE PODS"
	icon = 'icons/obj/decals.dmi'
	icon_state = "pods"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/fire
	desc = "A warning sign which reads 'DANGER: FIRE'"
	name = "DANGER: FIRE"
	icon = 'icons/obj/decals.dmi'
	icon_state = "fire"
	anchored = 1.0
	opacity = 0
	density = 0


/obj/effect/sign/nosmoking_1
	desc = "A warning sign which reads 'NO SMOKING'"
	name = "NO SMOKING"
	icon = 'icons/obj/decals.dmi'
	icon_state = "nosmoking"
	anchored = 1.0
	opacity = 0
	density = 0


/obj/effect/sign/nosmoking_2
	desc = "A warning sign which reads 'NO SMOKING'"
	name = "NO SMOKING"
	icon = 'icons/obj/decals.dmi'
	icon_state = "nosmoking2"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/redcross
	desc = "The Intergalactic symbol of Medical institutions. You'll probably get help here.'"
	name = "Med-Bay"
	icon = 'icons/obj/decals.dmi'
	icon_state = "redcross"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/goldenplaque
	desc = "To be Robust is not an action or a way of life, but a mental state. Only those with the force of Will strong enough to act during a crisis, saving friend from foe, are truly Robust. Stay Robust my friends."
	name = "The Most Robust Men Award for Robustness"
	icon = 'icons/obj/decals.dmi'
	icon_state = "goldenplaque"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/kiddieplaque
	desc = "Next to the extremely long list of names and job titles, there is a drawing of a little child. The child is holding a crayon and writing some code in his diary with it. The child is smiling evilly."
	name = "Credits plaque for AI developers."
	icon = 'icons/obj/decals.dmi'
	icon_state = "kiddieplaque"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/atmosplaque
	desc = "This plaque commemorates the fall of the Atmos FEA division. For all the charred, dizzy, and brittle men who have died in its hands."
	name = "FEA Atmospherics Division"
	icon = 'icons/obj/decals.dmi'
	icon_state = "atmosplaque"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/maltesefalcon1         //The sign is 64x32, so it needs two tiles. ;3
	desc = "The Maltese Falcon, Space Bar and Grill."
	name = "The Maltese Falcon"
	icon = 'icons/obj/decals.dmi'
	icon_state = "maltesefalcon1"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/maltesefalcon2
	desc = "The Maltese Falcon, Space Bar and Grill."
	name = "The Maltese Falcon"
	icon = 'icons/obj/decals.dmi'
	icon_state = "maltesefalcon2"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/science//These 3 have multiple types, just var-edit the icon_state to whatever one you want on the map
	desc = "A warning sign which reads 'SCIENCE!'"
	name = "SCIENCE!"
	icon = 'icons/obj/decals.dmi'
	icon_state = "science1"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/chemistry
	desc = "A warning sign which reads 'CHEMISTY'"
	name = "CHEMISTRY"
	icon = 'icons/obj/decals.dmi'
	icon_state = "chemistry1"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/botany
	desc = "A warning sign which reads 'HYDROPONICS'"
	name = "HYDROPONICS"
	icon = 'icons/obj/decals.dmi'
	icon_state = "hydro1"
	anchored = 1.0
	opacity = 0
	density = 0