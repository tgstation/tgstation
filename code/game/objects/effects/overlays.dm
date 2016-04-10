/obj/effect/overlay
	name = "overlay"
	unacidable = 1
	var/i_attached//Added for possible image attachments to objects. For hallucinations and the like.

/obj/effect/overlay/singularity_act()
	return

/obj/effect/overlay/singularity_pull()
	return

/obj/effect/overlay/beam//Not actually a projectile, just an effect.
	name="beam"
	icon='icons/effects/beam.dmi'
	icon_state="b_beam"
	var/atom/BeamSource

/obj/effect/overlay/beam/New()
	..()
	spawn(10) qdel(src)

/obj/effect/overlay/temp
	icon_state = "nothing"
	anchored = 1
	layer = 4.1
	mouse_opacity = 0
	var/duration = 10
	var/randomdir = 1

/obj/effect/overlay/temp/Destroy()
	..()
	return QDEL_HINT_PUTINPOOL

/obj/effect/overlay/temp/New()
	if(randomdir)
		dir = pick(cardinal)
	flick("[icon_state]", src) //Because we might be pulling it from a pool, flick whatever icon it uses so it starts at the start of the icon's animation.
	spawn(duration)
		qdel(src)

/obj/effect/overlay/temp/heal //color is white by default, set to whatever is needed
	name = "healing glow"
	icon_state = "heal"
	duration = 15

/obj/effect/overlay/temp/heal/New()
	..()
	pixel_x = rand(-12, 12)
	pixel_y = rand(-9, 0)

/obj/effect/overlay/temp/explosion
	name = "explosion"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "explosion"
	pixel_x = -32
	pixel_y = -32
	duration = 8

/obj/effect/overlay/temp/blob
	name = "blob"
	icon_state = "blob_attack"
	alpha = 140
	randomdir = 0
	duration = 6

/obj/effect/overlay/temp/guardian
	randomdir = 0

/obj/effect/overlay/temp/guardian/phase
	duration = 5
	icon_state = "phasein"

/obj/effect/overlay/temp/guardian/phase/out
	icon_state = "phaseout"

/obj/effect/overlay/temp/decoy
	desc = "It's a decoy!"
	duration = 15

/obj/effect/overlay/temp/decoy/New(loc, atom/mimiced_atom)
	..()
	alpha = initial(alpha)
	if(mimiced_atom)
		name = mimiced_atom.name
		icon = mimiced_atom.icon
		icon_state = mimiced_atom.icon_state
		dir = mimiced_atom.dir
	animate(src, alpha = 0, time = duration)

/obj/effect/overlay/temp/cult
	randomdir = 0
	duration = 10

/obj/effect/overlay/temp/cult/sac
	name = "maw of Nar-Sie"
	icon_state = "sacconsume"

/obj/effect/overlay/temp/cult/door
	name = "unholy glow"
	icon_state = "doorglow"
	layer = 3.17 //above closed doors

/obj/effect/overlay/temp/cult/door/unruned
	icon_state = "unruneddoorglow"

/obj/effect/overlay/temp/cult/turf
	name = "unholy glow"
	icon_state = "wallglow"
	layer = TURF_LAYER + 0.07

/obj/effect/overlay/temp/cult/turf/floor
	icon_state = "floorglow"
	duration = 5


/obj/effect/overlay/temp/revenant
	name = "spooky lights"
	icon_state = "purplesparkles"

/obj/effect/overlay/temp/revenant/cracks
	name = "glowing cracks"
	icon_state = "purplecrack"
	duration = 6


/obj/effect/overlay/temp/emp
	name = "emp sparks"
	icon_state = "empdisable"

/obj/effect/overlay/temp/emp/pulse
	name = "emp pulse"
	icon_state = "emp pulse"
	duration = 8
	randomdir = 0


/obj/effect/overlay/palmtree_r
	name = "Palm tree"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm1"
	density = 1
	layer = 5
	anchored = 1

/obj/effect/overlay/palmtree_l
	name = "Palm tree"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm2"
	density = 1
	layer = 5
	anchored = 1

/obj/effect/overlay/coconut
	name = "Coconuts"
	icon = 'icons/misc/beach.dmi'
	icon_state = "coconuts"