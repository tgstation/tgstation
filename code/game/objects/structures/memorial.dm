/*

At 7:30 AM on March 8th, 2017, ArcLumin died in a fatal car crash on impact.
Rest in peace, man. You did good work.
When a contributor for SS13 dies, all codebases feel it and suffer.
We may disagree on whether farts should be a thing, or what color to paint the bikeshed,
but we are all contributors together.

Goodbye, man. We'll miss you.

This memorial has been designed for him and any future coders to perish.

*/

/obj/structure/fluff/arc
	name = "Tomb of the Unknown Employee"
	desc = "Here rests an unknown employee\nUnknown by name or rank\nWhose acts will not be forgotten"
	icon = 'icons/obj/tomb.dmi'
	icon_state = "memorial"
	density = 1
	anchored = 1
	max_integrity = INFINITY
	obj_integrity = INFINITY
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | INDESTRUCTIBLE

/obj/structure/fluff/arc/ex_act(severity)
	return FALSE

/obj/structure/fluff/arc/singularity_act(severity)
	return FALSE

/obj/structure/fluff/arc/singularity_pull()
	return FALSE
