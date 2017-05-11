/obj/effect/overlay
	name = "overlay"
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
	QDEL_IN(src, 10)

/obj/effect/overlay/temp
	icon_state = "nothing"
	anchored = 1
	layer = ABOVE_MOB_LAYER
	mouse_opacity = 0
	var/duration = 10 //in deciseconds
	var/randomdir = TRUE
	var/timerid

/obj/effect/overlay/temp/Destroy()
	. = ..()
	deltimer(timerid)

/obj/effect/overlay/temp/Initialize()
	. = ..()
	if(randomdir)
		setDir(pick(GLOB.cardinal))

	timerid = QDEL_IN(src, duration)

/obj/effect/overlay/temp/ex_act()
	return

/obj/effect/overlay/temp/dir_setting
	randomdir = FALSE

/obj/effect/overlay/temp/dir_setting/Initialize(mapload, set_dir)
	if(set_dir)
		setDir(set_dir)
	. = ..()

/obj/effect/overlay/temp/dir_setting/bloodsplatter
	icon = 'icons/effects/blood.dmi'
	duration = 5
	randomdir = FALSE
	layer = BELOW_MOB_LAYER
	var/splatter_type = "splatter"

/obj/effect/overlay/temp/dir_setting/bloodsplatter/Initialize(mapload, set_dir)
	if(set_dir in GLOB.diagonals)
		icon_state = "[splatter_type][pick(1, 2, 6)]"
	else
		icon_state = "[splatter_type][pick(3, 4, 5)]"
	. = ..()
	var/target_pixel_x = 0
	var/target_pixel_y = 0
	switch(set_dir)
		if(NORTH)
			target_pixel_y = 16
		if(SOUTH)
			target_pixel_y = -16
			layer = ABOVE_MOB_LAYER
		if(EAST)
			target_pixel_x = 16
		if(WEST)
			target_pixel_x = -16
		if(NORTHEAST)
			target_pixel_x = 16
			target_pixel_y = 16
		if(NORTHWEST)
			target_pixel_x = -16
			target_pixel_y = 16
		if(SOUTHEAST)
			target_pixel_x = 16
			target_pixel_y = -16
			layer = ABOVE_MOB_LAYER
		if(SOUTHWEST)
			target_pixel_x = -16
			target_pixel_y = -16
			layer = ABOVE_MOB_LAYER
	animate(src, pixel_x = target_pixel_x, pixel_y = target_pixel_y, alpha = 0, time = duration)

/obj/effect/overlay/temp/dir_setting/bloodsplatter/xenosplatter
	splatter_type = "xsplatter"

/obj/effect/overlay/temp/dir_setting/speedbike_trail
	name = "speedbike trails"
	icon_state = "ion_fade"
	layer = BELOW_MOB_LAYER
	duration = 10
	randomdir = 0

/obj/effect/overlay/temp/dir_setting/firing_effect
	icon = 'icons/effects/effects.dmi'
	icon_state = "firing_effect"
	duration = 2

/obj/effect/overlay/temp/dir_setting/firing_effect/setDir(newdir)
	switch(newdir)
		if(NORTH)
			layer = BELOW_MOB_LAYER
			pixel_x = rand(-3,3)
			pixel_y = rand(4,6)
		if(SOUTH)
			pixel_x = rand(-3,3)
			pixel_y = rand(-1,1)
		else
			pixel_x = rand(-1,1)
			pixel_y = rand(-1,1)
	..()

/obj/effect/overlay/temp/dir_setting/firing_effect/energy
	icon_state = "firing_effect_energy"
	duration = 3

/obj/effect/overlay/temp/dir_setting/firing_effect/magic
	icon_state = "shieldsparkles"
	duration = 3

/obj/effect/overlay/temp/dir_setting/ninja
	name = "ninja shadow"
	icon = 'icons/mob/mob.dmi'
	icon_state = "uncloak"
	duration = 9

/obj/effect/overlay/temp/dir_setting/ninja/cloak
	icon_state = "cloak"

/obj/effect/overlay/temp/dir_setting/ninja/shadow
	icon_state = "shadow"

/obj/effect/overlay/temp/dir_setting/ninja/phase
	name = "ninja energy"
	icon_state = "phasein"

/obj/effect/overlay/temp/dir_setting/ninja/phase/out
	icon_state = "phaseout"

/obj/effect/overlay/temp/dir_setting/wraith
	name = "blood"
	icon = 'icons/mob/mob.dmi'
	icon_state = "phase_shift2"
	duration = 12

/obj/effect/overlay/temp/dir_setting/wraith/out
	icon_state = "phase_shift"

/obj/effect/overlay/temp/dir_setting/tailsweep
	icon_state = "tailsweep"
	duration = 4

/obj/effect/overlay/temp/wizard
	name = "water"
	icon = 'icons/mob/mob.dmi'
	icon_state = "reappear"
	duration = 5

/obj/effect/overlay/temp/wizard/out
	icon_state = "liquify"
	duration = 12

/obj/effect/overlay/temp/monkeyify
	icon = 'icons/mob/mob.dmi'
	icon_state = "h2monkey"
	duration = 22

/obj/effect/overlay/temp/monkeyify/humanify
	icon_state = "monkey2h"

/obj/effect/overlay/temp/borgflash
	icon = 'icons/mob/mob.dmi'
	icon_state = "blspell"
	duration = 5

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

/obj/effect/overlay/temp/decoy/Initialize(mapload, atom/mimiced_atom)
	. = ..()
	alpha = initial(alpha)
	if(mimiced_atom)
		name = mimiced_atom.name
		appearance = mimiced_atom.appearance
		setDir(mimiced_atom.dir)
		mouse_opacity = 0

/obj/effect/overlay/temp/decoy/fading/Initialize(mapload, atom/mimiced_atom)
	. = ..()
	animate(src, alpha = 0, time = duration)

/obj/effect/overlay/temp/decoy/fading/fivesecond
	duration = 50

/obj/effect/overlay/temp/small_smoke
	icon_state = "smoke"
	duration = 50

/obj/effect/overlay/temp/fire
	icon = 'icons/effects/fire.dmi'
	icon_state = "3"
	duration = 20

/obj/effect/overlay/temp/cult
	randomdir = 0
	duration = 10

/obj/effect/overlay/temp/cult/sparks
	randomdir = 1
	name = "blood sparks"
	icon_state = "bloodsparkles"

/obj/effect/overlay/temp/cult/blood  // The traditional teleport
	name = "blood jaunt"
	duration = 12
	icon_state = "bloodin"

/obj/effect/overlay/temp/cult/blood/out
	icon_state = "bloodout"

/obj/effect/overlay/temp/dir_setting/cult/phase  // The veil shifter teleport
	name = "phase glow"
	duration = 7
	icon_state = "cultin"

/obj/effect/overlay/temp/dir_setting/cult/phase/out
	icon_state = "cultout"

/obj/effect/overlay/temp/cult/sac
	name = "maw of Nar-Sie"
	icon_state = "sacconsume"

/obj/effect/overlay/temp/cult/door
	name = "unholy glow"
	icon_state = "doorglow"
	layer = CLOSED_FIREDOOR_LAYER //above closed doors

/obj/effect/overlay/temp/cult/door/unruned
	icon_state = "unruneddoorglow"

/obj/effect/overlay/temp/cult/turf
	name = "unholy glow"
	icon_state = "wallglow"
	layer = ABOVE_NORMAL_TURF_LAYER

/obj/effect/overlay/temp/cult/turf/floor
	icon_state = "floorglow"
	duration = 5


/obj/effect/overlay/temp/ratvar
	name = "ratvar's light"
	icon = 'icons/effects/clockwork_effects.dmi'
	duration = 8
	randomdir = 0
	layer = ABOVE_NORMAL_TURF_LAYER

/obj/effect/overlay/temp/ratvar/door
	icon_state = "ratvardoorglow"
	layer = CLOSED_DOOR_LAYER //above closed doors

/obj/effect/overlay/temp/ratvar/door/window
	icon_state = "ratvarwindoorglow"
	layer = ABOVE_WINDOW_LAYER

/obj/effect/overlay/temp/ratvar/beam
	icon_state = "ratvarbeamglow"

/obj/effect/overlay/temp/ratvar/beam/door
	layer = CLOSED_DOOR_LAYER

/obj/effect/overlay/temp/ratvar/beam/grille
	layer = BELOW_OBJ_LAYER

/obj/effect/overlay/temp/ratvar/beam/itemconsume
	layer = HIGH_OBJ_LAYER

/obj/effect/overlay/temp/ratvar/beam/falsewall
	layer = OBJ_LAYER

/obj/effect/overlay/temp/ratvar/beam/catwalk
	layer = LATTICE_LAYER

/obj/effect/overlay/temp/ratvar/wall
	icon_state = "ratvarwallglow"

/obj/effect/overlay/temp/ratvar/wall/false
	layer = OBJ_LAYER

/obj/effect/overlay/temp/ratvar/floor
	icon_state = "ratvarfloorglow"

/obj/effect/overlay/temp/ratvar/floor/catwalk
	layer = LATTICE_LAYER

/obj/effect/overlay/temp/ratvar/window
	icon_state = "ratvarwindowglow"
	layer = ABOVE_OBJ_LAYER

/obj/effect/overlay/temp/ratvar/window/single
	icon_state = "ratvarwindowglow_s"

/obj/effect/overlay/temp/ratvar/gear
	icon_state = "ratvargearglow"
	layer = BELOW_OBJ_LAYER

/obj/effect/overlay/temp/ratvar/grille
	icon_state = "ratvargrilleglow"
	layer = BELOW_OBJ_LAYER

/obj/effect/overlay/temp/ratvar/grille/broken
	icon_state = "ratvarbrokengrilleglow"

/obj/effect/overlay/temp/ratvar/mending_mantra
	layer = ABOVE_MOB_LAYER
	duration = 20
	alpha = 200
	icon_state = "mending_mantra"
	light_range = 1.5
	light_color = "#1E8CE1"

/obj/effect/overlay/temp/ratvar/mending_mantra/Initialize(mapload)
	. = ..()
	transform = matrix()*2
	var/matrix/M = transform
	M.Turn(90)
	animate(src, alpha = 20, time = duration, easing = BOUNCE_EASING, flags = ANIMATION_PARALLEL)
	animate(src, transform = M, time = duration, flags = ANIMATION_PARALLEL)

/obj/effect/overlay/temp/ratvar/volt_hit
	name = "volt blast"
	layer = ABOVE_MOB_LAYER
	duration = 5
	icon_state = "volt_hit"
	light_range = 1.5
	light_power = 2
	light_color = LIGHT_COLOR_ORANGE
	var/mob/user
	var/damage = 20

/obj/effect/overlay/temp/ratvar/volt_hit/Initialize(mapload, caster, multiplier)
	if(multiplier)
		damage *= multiplier
	duration = max(round(damage * 0.2), 1)
	. = ..()

/obj/effect/overlay/temp/ratvar/volt_hit/true/Initialize(mapload, caster, multiplier)
	. = ..()
	user = caster
	if(user)
		var/matrix/M = new
		M.Turn(Get_Angle(src, user))
		transform = M
	INVOKE_ASYNC(src, .proc/volthit)

/obj/effect/overlay/temp/ratvar/volt_hit/proc/volthit()
	if(user)
		Beam(get_turf(user), "volt_ray", time=duration, maxdistance=8, beam_type=/obj/effect/ebeam/volt_ray)
	var/hit_amount = 0
	var/turf/T = get_turf(src)
	for(var/mob/living/L in T)
		if(is_servant_of_ratvar(L))
			continue
		var/obj/item/I = L.null_rod_check()
		if(I)
			L.visible_message("<span class='warning'>Strange energy flows into [L]'s [I.name]!</span>", \
			"<span class='userdanger'>Your [I.name] shields you from [src]!</span>")
			continue
		L.visible_message("<span class='warning'>[L] is struck by a [name]!</span>", "<span class='userdanger'>You're struck by a [name]!</span>")
		L.apply_damage(damage, BURN, "chest", L.run_armor_check("chest", "laser", "Your armor absorbs [src]!", "Your armor blocks part of [src]!", 0, "Your armor was penetrated by [src]!"))
		add_logs(user, L, "struck with a volt blast")
		hit_amount++
	for(var/obj/mecha/M in T)
		if(M.occupant)
			if(is_servant_of_ratvar(M.occupant))
				continue
			to_chat(M.occupant, "<span class='userdanger'>Your [M.name] is struck by a [name]!</span>")
		M.visible_message("<span class='warning'>[M] is struck by a [name]!</span>")
		M.take_damage(damage, BURN, 0, 0)
		hit_amount++
	if(hit_amount)
		playsound(src, 'sound/machines/defib_zap.ogg', damage*hit_amount, 1, -1)
	else
		playsound(src, "sparks", 50, 1)

/obj/effect/overlay/temp/ratvar/ocular_warden
	name = "warden's gaze"
	layer = ABOVE_MOB_LAYER
	icon_state = "warden_gaze"
	duration = 3

/obj/effect/overlay/temp/ratvar/ocular_warden/Initialize()
	. = ..()
	pixel_x = rand(-8, 8)
	pixel_y = rand(-10, 10)
	animate(src, alpha = 0, time = 3, easing = EASE_OUT)

/obj/effect/overlay/temp/ratvar/spearbreak
	icon = 'icons/effects/64x64.dmi'
	icon_state = "ratvarspearbreak"
	layer = BELOW_MOB_LAYER
	pixel_y = -16
	pixel_x = -16

/obj/effect/overlay/temp/ratvar/geis_binding
	icon_state = "geisbinding"

/obj/effect/overlay/temp/ratvar/geis_binding/top
	icon_state = "geisbinding_top"

/obj/effect/overlay/temp/ratvar/component
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "belligerent_eye"
	layer = ABOVE_MOB_LAYER
	duration = 10

/obj/effect/overlay/temp/ratvar/component/Initialize()
	. = ..()
	transform = matrix()*0.75
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, -2)
	animate(src, pixel_y = pixel_y + 10, alpha = 50, time = 10, easing = EASE_OUT)

/obj/effect/overlay/temp/ratvar/component/cogwheel
	icon_state = "vanguard_cogwheel"

/obj/effect/overlay/temp/ratvar/component/capacitor
	icon_state = "geis_capacitor"

/obj/effect/overlay/temp/ratvar/component/alloy
	icon_state = "replicant_alloy"

/obj/effect/overlay/temp/ratvar/component/ansible
	icon_state = "hierophant_ansible"

/obj/effect/overlay/temp/ratvar/sigil
	name = "glowing circle"
	icon_state = "sigildull"

/obj/effect/overlay/temp/ratvar/sigil/transgression
	color = "#FAE48C"
	layer = ABOVE_MOB_LAYER
	duration = 70
	light_range = 5
	light_power = 2
	light_color = "#FAE48C"

/obj/effect/overlay/temp/ratvar/sigil/transgression/Initialize()
	. = ..()
	var/oldtransform = transform
	animate(src, transform = matrix()*2, time = 5)
	animate(transform = oldtransform, alpha = 0, time = 65)

/obj/effect/overlay/temp/ratvar/sigil/vitality
	color = "#1E8CE1"
	icon_state = "sigilactivepulse"
	layer = ABOVE_MOB_LAYER
	light_range = 1.4
	light_power = 0.5
	light_color = "#1E8CE1"

/obj/effect/overlay/temp/ratvar/sigil/accession
	color = "#AF0AAF"
	layer = ABOVE_MOB_LAYER
	duration = 70
	icon_state = "sigilactiveoverlay"
	alpha = 0


/obj/effect/overlay/temp/revenant
	name = "spooky lights"
	icon_state = "purplesparkles"

/obj/effect/overlay/temp/revenant/cracks
	name = "glowing cracks"
	icon_state = "purplecrack"
	duration = 6


/obj/effect/overlay/temp/gravpush
	name = "gravity wave"
	icon_state = "shieldsparkles"
	duration = 5

/obj/effect/overlay/temp/telekinesis
	name = "telekinetic force"
	icon_state = "empdisable"
	duration = 5

/obj/effect/overlay/temp/emp
	name = "emp sparks"
	icon_state = "empdisable"

/obj/effect/overlay/temp/emp/pulse
	name = "emp pulse"
	icon_state = "emppulse"
	duration = 8
	randomdir = 0

/obj/effect/overlay/temp/gib_animation
	icon = 'icons/mob/mob.dmi'
	duration = 15

/obj/effect/overlay/temp/gib_animation/Initialize(mapload, gib_icon)
	icon_state = gib_icon // Needs to be before ..() so icon is correct
	. = ..()

/obj/effect/overlay/temp/gib_animation/ex_act(severity)
	return //so the overlay isn't deleted by the explosion that gibbed the mob.

/obj/effect/overlay/temp/gib_animation/animal
	icon = 'icons/mob/animal.dmi'

/obj/effect/overlay/temp/dust_animation
	icon = 'icons/mob/mob.dmi'
	duration = 15

/obj/effect/overlay/temp/dust_animation/Initialize(mapload, dust_icon)
	icon_state = dust_icon // Before ..() so the correct icon is flick()'d
	. = ..()

/obj/effect/overlay/temp/mummy_animation
	icon = 'icons/mob/mob.dmi'
	icon_state = "mummy_revive"
	duration = 20

/obj/effect/overlay/temp/heal //color is white by default, set to whatever is needed
	name = "healing glow"
	icon_state = "heal"
	duration = 15

/obj/effect/overlay/temp/heal/Initialize(mapload, colour)
	if(colour)
		color = colour
	. = ..()
	pixel_x = rand(-12, 12)
	pixel_y = rand(-9, 0)

/obj/effect/overlay/temp/kinetic_blast
	name = "kinetic explosion"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "kinetic_blast"
	layer = ABOVE_ALL_MOB_LAYER
	duration = 4

/obj/effect/overlay/temp/explosion
	name = "explosion"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "explosion"
	pixel_x = -32
	pixel_y = -32
	duration = 8

/obj/effect/overlay/temp/explosion/fast
	icon_state = "explosionfast"
	duration = 4

/obj/effect/overlay/temp/blob
	name = "blob"
	icon_state = "blob_attack"
	alpha = 140
	randomdir = 0
	duration = 6

/obj/effect/overlay/temp/impact_effect
	icon_state = "impact_bullet"
	duration = 5

/obj/effect/overlay/temp/impact_effect/Initialize(mapload, atom/target, obj/item/projectile/P)
	if(target == P.original) //the projectile hit the target originally clicked
		pixel_x = P.p_x + target.pixel_x - 16 + rand(-4,4)
		pixel_y = P.p_y + target.pixel_y - 16 + rand(-4,4)
	else
		pixel_x = target.pixel_x + rand(-4,4)
		pixel_y = target.pixel_y + rand(-4,4)
	. = ..()

/obj/effect/overlay/temp/impact_effect/red_laser
	icon_state = "impact_laser"
	duration = 4

/obj/effect/overlay/temp/impact_effect/red_laser/wall
	icon_state = "impact_laser_wall"
	duration = 10

/obj/effect/overlay/temp/impact_effect/blue_laser
	icon_state = "impact_laser_blue"
	duration = 4

/obj/effect/overlay/temp/impact_effect/green_laser
	icon_state = "impact_laser_green"
	duration = 4

/obj/effect/overlay/temp/impact_effect/purple_laser
	icon_state = "impact_laser_purple"
	duration = 4

/obj/effect/overlay/temp/impact_effect/ion
	icon_state = "shieldsparkles"
	duration = 6


/obj/effect/overlay/palmtree_r
	name = "Palm tree"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm1"
	density = 1
	layer = WALL_OBJ_LAYER
	anchored = 1

/obj/effect/overlay/palmtree_l
	name = "Palm tree"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm2"
	density = 1
	layer = WALL_OBJ_LAYER
	anchored = 1

/obj/effect/overlay/coconut
	name = "Coconuts"
	icon = 'icons/misc/beach.dmi'
	icon_state = "coconuts"

/obj/effect/overlay/sparkles
	name = "sparkles"
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldsparkles"
