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
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	anchored = 1
	layer = 4.1
	mouse_opacity = 0
	var/duration = 10
	var/randomdir = 1
	var/loopless_icon = null //Workaround so that pooled effects that normally don't repeat will repeat when taken from the pool.

/obj/effect/overlay/temp/Destroy()
	..()
	return QDEL_HINT_PUTINPOOL

/obj/effect/overlay/temp/New()
	if(randomdir)
		dir = pick(cardinal)
	if(loopless_icon)
		flick("[loopless_icon]", src)
	spawn(duration)
		qdel(src)


/obj/effect/overlay/temp/cult
	name = "unholy glow"
	loopless_icon = "wallglow"
	layer = 2.01
	randomdir = 0
	duration = 10

/obj/effect/overlay/temp/cult/floor
	loopless_icon = "floorglow"
	duration = 5


/obj/effect/overlay/temp/revenant
	name = "spooky lights"
	icon_state = "purplesparkles"

/obj/effect/overlay/temp/revenant/cracks
	name = "glowing cracks"
	loopless_icon = "purplecrack"
	duration = 6


/obj/effect/overlay/temp/emp
	name = "emp sparks"
	icon_state = "empdisable"

/obj/effect/overlay/temp/emp/pulse
	name = "emp pulse"
	loopless_icon = "emp pulse"
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