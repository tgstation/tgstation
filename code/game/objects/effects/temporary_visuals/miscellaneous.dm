//unsorted miscellaneous temporary visuals
/obj/effect/temp_visual/dir_setting/bloodsplatter
	icon = 'icons/effects/blood.dmi'
	duration = 5
	randomdir = FALSE
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	var/splatter_type = "splatter"

/obj/effect/temp_visual/dir_setting/bloodsplatter/Initialize(mapload, set_dir)
	if(ISDIAGONALDIR(set_dir))
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

/obj/effect/temp_visual/dir_setting/bloodsplatter/xenosplatter
	splatter_type = "xsplatter"

/obj/effect/temp_visual/dir_setting/speedbike_trail
	name = "speedbike trails"
	icon_state = "ion_fade"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	duration = 10
	randomdir = 0

/obj/effect/temp_visual/dir_setting/firing_effect
	icon = 'icons/effects/effects.dmi'
	icon_state = "firing_effect"
	duration = 3

/obj/effect/temp_visual/dir_setting/firing_effect/Initialize(mapload, set_dir)
	. = ..()
	if (ismovable(loc))
		var/atom/movable/spawned_inside = loc
		spawned_inside.vis_contents += src

/obj/effect/temp_visual/dir_setting/firing_effect/setDir(newdir)
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

/obj/effect/temp_visual/dir_setting/firing_effect/blue
	icon = 'icons/effects/effects.dmi'
	icon_state = "firing_effect_blue"
	duration = 3

/obj/effect/temp_visual/dir_setting/firing_effect/red
	icon = 'icons/effects/effects.dmi'
	icon_state = "firing_effect_red"
	duration = 3

/obj/effect/temp_visual/dir_setting/firing_effect/magic
	icon_state = "shieldsparkles"
	duration = 3

/obj/effect/temp_visual/dir_setting/ninja
	name = "ninja shadow"
	icon = 'icons/mob/simple/mob.dmi'
	icon_state = "uncloak"
	duration = 9

/obj/effect/temp_visual/dir_setting/ninja/cloak
	icon_state = "cloak"

/obj/effect/temp_visual/dir_setting/ninja/shadow
	icon_state = "shadow"

/obj/effect/temp_visual/dir_setting/ninja/phase
	name = "ninja energy"
	icon_state = "phasein"

/obj/effect/temp_visual/dir_setting/ninja/phase/out
	icon_state = "phaseout"

/obj/effect/temp_visual/dir_setting/wraith
	name = "shadow"
	icon = 'icons/mob/nonhuman-player/cult.dmi'
	icon_state = "phase_shift2_cult"
	duration = 0.6 SECONDS

/obj/effect/temp_visual/dir_setting/wraith/angelic
	icon_state = "phase_shift2_holy"

/obj/effect/temp_visual/dir_setting/wraith/mystic
	icon_state = "phase_shift2_wizard"

/obj/effect/temp_visual/dir_setting/wraith/out
	icon_state = "phase_shift_cult"

/obj/effect/temp_visual/dir_setting/wraith/out/angelic
	icon_state = "phase_shift_holy"

/obj/effect/temp_visual/dir_setting/wraith/out/mystic
	icon_state = "phase_shift_wizard"

/obj/effect/temp_visual/dir_setting/tailsweep
	icon_state = "tailsweep"
	duration = 4

/obj/effect/temp_visual/dir_setting/curse
	icon_state = "curse"
	duration = 32
	var/fades = TRUE

/obj/effect/temp_visual/dir_setting/curse/Initialize(mapload, set_dir)
	. = ..()
	if(fades)
		animate(src, alpha = 0, time = 32)

/obj/effect/temp_visual/dir_setting/curse/blob
	icon_state = "curseblob"

/obj/effect/temp_visual/dir_setting/curse/grasp_portal
	icon = 'icons/effects/64x64.dmi'
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE
	pixel_y = -16
	pixel_x = -16
	duration = 32
	fades = FALSE

/obj/effect/temp_visual/dir_setting/curse/grasp_portal/fading
	duration = 32
	fades = TRUE

/obj/effect/temp_visual/dir_setting/curse/hand
	icon_state = "cursehand1"


/obj/effect/temp_visual/bsa_splash
	name = "\improper Bluespace energy wave"
	desc = "A massive, rippling wave of bluepace energy, all rapidly exhausting itself the moment it leaves the concentrated beam of light."
	icon = 'icons/effects/beam_splash.dmi'
	icon_state = "beam_splash_e"
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE
	pixel_y = -16
	duration = 50

/obj/effect/temp_visual/bsa_splash/Initialize(mapload, dir)
	. = ..()
	switch(dir)
		if(WEST)
			icon_state = "beam_splash_w"
		if(EAST)
			icon_state = "beam_splash_e"

/obj/effect/temp_visual/wizard
	name = "water"
	icon = 'icons/mob/simple/mob.dmi'
	icon_state = "reappear"
	duration = 5

/obj/effect/temp_visual/wizard/out
	icon_state = "liquify"
	duration = 12

/obj/effect/temp_visual/monkeyify
	icon = 'icons/mob/simple/mob.dmi'
	icon_state = "h2monkey"
	duration = 22

/obj/effect/temp_visual/monkeyify/humanify
	icon_state = "monkey2h"

/obj/effect/temp_visual/borgflash
	icon = 'icons/mob/simple/mob.dmi'
	icon_state = "blspell"
	duration = 5

/obj/effect/temp_visual/guardian
	randomdir = 0

/obj/effect/temp_visual/guardian/phase
	duration = 5
	icon_state = "phasein"

/obj/effect/temp_visual/guardian/phase/out
	icon_state = "phaseout"

/obj/effect/temp_visual/decoy
	desc = "It's a decoy!"
	duration = 15

/obj/effect/temp_visual/decoy/Initialize(mapload, atom/mimiced_atom)
	. = ..()
	alpha = initial(alpha)
	if(mimiced_atom)
		name = mimiced_atom.name
		appearance = mimiced_atom.appearance
		setDir(mimiced_atom.dir)
		mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/temp_visual/decoy/fading/Initialize(mapload, atom/mimiced_atom)
	. = ..()
	animate(src, alpha = 0, time = duration)

/obj/effect/temp_visual/decoy/fading/threesecond
	duration = 40

/obj/effect/temp_visual/decoy/fading/fivesecond
	duration = 50

/obj/effect/temp_visual/decoy/fading/halfsecond
	duration = 5

/obj/effect/temp_visual/small_smoke
	icon_state = "smoke"
	duration = 50

/obj/effect/temp_visual/small_smoke/halfsecond
	duration = 5

/obj/effect/temp_visual/fire
	icon = 'icons/effects/fire.dmi'
	icon_state = "heavy"
	light_range = LIGHT_RANGE_FIRE
	light_color = LIGHT_COLOR_FIRE
	duration = 10

/obj/effect/temp_visual/revenant
	name = "spooky lights"
	icon_state = "purplesparkles"

/obj/effect/temp_visual/revenant/cracks
	name = "glowing cracks"
	icon_state = "purplecrack"
	duration = 6

/obj/effect/temp_visual/gravpush
	name = "gravity wave"
	icon_state = "shieldsparkles"
	duration = 5

/obj/effect/temp_visual/telekinesis
	name = "telekinetic force"
	icon_state = "empdisable"
	duration = 5

/obj/effect/temp_visual/emp
	name = "emp sparks"
	icon_state = "empdisable"

/obj/effect/temp_visual/emp/pulse
	name = "emp pulse"
	icon_state = "emppulse"
	duration = 8
	randomdir = 0

/obj/effect/temp_visual/bluespace_fissure
	name = "bluespace fissure"
	icon_state = "bluestream_fade"
	duration = 9

/obj/effect/temp_visual/bluespace_fissure/Initialize(mapload)
	. = ..()
	apply_wibbly_filters(src)

/obj/effect/temp_visual/gib_animation
	icon = 'icons/mob/simple/mob.dmi'
	duration = 15

/obj/effect/temp_visual/gib_animation/Initialize(mapload, gib_icon)
	icon_state = gib_icon // Needs to be before ..() so icon is correct
	. = ..()

/obj/effect/temp_visual/gib_animation/animal
	icon = 'icons/mob/simple/animal.dmi'

/obj/effect/temp_visual/mummy_animation
	icon = 'icons/mob/simple/mob.dmi'
	icon_state = "mummy_revive"
	duration = 20

/obj/effect/temp_visual/heal //color is white by default, set to whatever is needed
	name = "healing glow"
	icon_state = "heal"
	duration = 15

/obj/effect/temp_visual/heal/Initialize(mapload, set_color)
	if(set_color)
		add_atom_colour(set_color, FIXED_COLOUR_PRIORITY)
	. = ..()
	pixel_x = rand(-12, 12)
	pixel_y = rand(-9, 0)

/obj/effect/temp_visual/kinetic_blast
	name = "kinetic explosion"
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "kinetic_blast"
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE
	duration = 4

/obj/effect/temp_visual/explosion
	name = "explosion"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "explosion"
	pixel_x = -32
	pixel_y = -32
	duration = 8

/obj/effect/temp_visual/explosion/fast
	icon_state = "explosionfast"
	duration = 4

/obj/effect/temp_visual/blob
	name = "blob"
	icon_state = "blob_attack"
	alpha = 140
	randomdir = 0
	duration = 6

/obj/effect/temp_visual/desynchronizer
	name = "desynchronizer field"
	icon_state = "chronofield"
	duration = 3

/obj/effect/temp_visual/impact_effect
	icon_state = "impact_bullet"
	duration = 5

/obj/effect/temp_visual/impact_effect/Initialize(mapload, x, y)
	pixel_x = x
	pixel_y = y
	return ..()

/obj/effect/temp_visual/impact_effect/red_laser
	icon_state = "impact_laser"
	duration = 4

/obj/effect/temp_visual/impact_effect/red_laser/wall
	icon_state = "impact_laser_wall"
	duration = 10

/obj/effect/temp_visual/impact_effect/blue_laser
	icon_state = "impact_laser_blue"
	duration = 4

/obj/effect/temp_visual/impact_effect/green_laser
	icon_state = "impact_laser_green"
	duration = 4

/obj/effect/temp_visual/impact_effect/yellow_laser
	icon_state = "impact_laser_yellow"
	duration = 4

/obj/effect/temp_visual/impact_effect/purple_laser
	icon_state = "impact_laser_purple"
	duration = 4

/obj/effect/temp_visual/impact_effect/shrink
	icon_state = "m_shield"
	duration = 10

/obj/effect/temp_visual/impact_effect/ion
	icon_state = "shieldsparkles"
	duration = 6

/obj/effect/temp_visual/impact_effect/energy
	icon_state = "impact_energy"
	duration = 6

/obj/effect/temp_visual/impact_effect/neurotoxin
	icon_state = "impact_spit"
	color = "#5BDD04"

/obj/effect/temp_visual/impact_effect/ink_spit
	icon_state = "impact_spit"
	color = COLOR_NEARLY_ALL_BLACK

/obj/effect/temp_visual/heart
	name = "heart"
	icon = 'icons/mob/simple/animal.dmi'
	icon_state = "heart"
	duration = 25

/obj/effect/temp_visual/heart/Initialize(mapload)
	. = ..()
	pixel_x = rand(-4,4)
	pixel_y = rand(-4,4)
	animate(src, pixel_y = pixel_y + 32, alpha = 0, time = 25)

/obj/effect/temp_visual/annoyed
	name = "annoyed"
	icon = 'icons/effects/effects.dmi'
	icon_state = "annoyed"
	duration = 25

/obj/effect/temp_visual/annoyed/Initialize(mapload)
	. = ..()
	pixel_x = rand(-4,0)
	pixel_y = rand(8,12)
	animate(src, pixel_y = pixel_y + 16, alpha = 0, time = duration)

/obj/effect/temp_visual/bleed
	name = "bleed"
	icon = 'icons/effects/bleed.dmi'
	icon_state = "bleed0"
	duration = 10
	var/shrink = TRUE

/obj/effect/temp_visual/bleed/Initialize(mapload, atom/size_calc_target)
	. = ..()
	var/size_matrix = matrix()
	if(size_calc_target)
		layer = size_calc_target.layer + 0.01
		size_matrix = matrix() * (size_calc_target.get_visual_height() / ICON_SIZE_Y)
		transform = size_matrix //scale the bleed overlay's size based on the target's icon size
	var/matrix/M = transform
	if(shrink)
		M = size_matrix*0.1
	else
		M = size_matrix*2
	animate(src, alpha = 20, transform = M, time = duration, flags = ANIMATION_PARALLEL)

/obj/effect/temp_visual/bleed/explode
	icon_state = "bleed10"
	duration = 12
	shrink = FALSE

/obj/effect/temp_visual/warp_cube
	duration = 5
	var/outgoing = TRUE

/obj/effect/temp_visual/warp_cube/Initialize(mapload, atom/teleporting_atom, warp_color, new_outgoing)
	. = ..()
	if(teleporting_atom)
		outgoing = new_outgoing
		appearance = teleporting_atom.appearance
		setDir(teleporting_atom.dir)
		if(warp_color)
			color = list(warp_color, warp_color, warp_color, list(0,0,0))
			set_light(1.4, 1, warp_color)
		mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		var/matrix/skew = transform
		skew = skew.Turn(180)
		skew = skew.Interpolate(transform, 0.5)
		if(!outgoing)
			transform = skew * 2
			skew = teleporting_atom.transform
			alpha = 0
			animate(src, alpha = teleporting_atom.alpha, transform = skew, time = duration)
		else
			skew *= 2
			animate(src, alpha = 0, transform = skew, time = duration)
	else
		return INITIALIZE_HINT_QDEL

/obj/effect/temp_visual/cart_space
	icon_state = "launchpad_launch"
	duration = 2 SECONDS

/obj/effect/temp_visual/cart_space/bad
	icon_state = "launchpad_pull"
	duration = 2 SECONDS

/obj/effect/constructing_effect
	icon = 'icons/effects/rcd.dmi'
	icon_state = ""
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE
	anchored = TRUE
	obj_flags = CAN_BE_HIT
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	var/status = 0
	var/delay = 0

/obj/effect/constructing_effect/Initialize(mapload, rcd_delay, rcd_status, rcd_upgrades)
	. = ..()
	status = rcd_status
	delay = rcd_delay
	if (status == RCD_DECONSTRUCT)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/, update_appearance)), 1.1 SECONDS)
		delay -= 11
		icon_state = "rcd_end_reverse"
	else
		update_appearance()

	if (rcd_upgrades & RCD_UPGRADE_ANTI_INTERRUPT)
		color = list(
			1.0, 0.5, 0.5, 0.0,
			0.1, 0.0, 0.0, 0.0,
			0.1, 0.0, 0.0, 0.0,
			0.0, 0.0, 0.0, 1.0,
			0.0, 0.0, 0.0, 0.0,
		)

		mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		obj_flags &= ~CAN_BE_HIT

/obj/effect/constructing_effect/update_name(updates)
	. = ..()

	if (status == RCD_DECONSTRUCT)
		name = "deconstruction effect"
	else
		name = "construction effect"

/obj/effect/constructing_effect/update_icon_state()
	icon_state = "rcd"
	if(delay < 10)
		icon_state += "_shortest"
		return ..()
	if (delay < 20)
		icon_state += "_shorter"
		return ..()
	if (delay < 37)
		icon_state += "_short"
		return ..()
	if(status == RCD_DECONSTRUCT)
		icon_state += "_reverse"
	return ..()

/obj/effect/constructing_effect/proc/end_animation()
	if (status == RCD_DECONSTRUCT)
		qdel(src)
	else
		mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		obj_flags &= ~CAN_BE_HIT
		icon_state = "rcd_end"
		addtimer(CALLBACK(src, PROC_REF(end)), 1.5 SECONDS)

/obj/effect/constructing_effect/proc/end()
	qdel(src)

/obj/effect/constructing_effect/proc/attacked(mob/user)
	user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(loc, 'sound/items/weapons/egloves.ogg', vol = 80, vary = TRUE)
	end()

/obj/effect/constructing_effect/attackby(obj/item/weapon, mob/user, params)
	attacked(user)

/obj/effect/constructing_effect/attack_hand(mob/living/user, list/modifiers)
	attacked(user)

/obj/effect/temp_visual/electricity
	icon_state = "electricity3"
	duration = 0.5 SECONDS

/obj/effect/temp_visual/thunderbolt
	icon_state = "thunderbolt"
	icon = 'icons/effects/32x96.dmi'
	duration = 0.6 SECONDS

/obj/effect/temp_visual/light_ash
	icon_state = "light_ash"
	icon = 'icons/effects/weather_effects.dmi'
	duration = 3.2 SECONDS

/obj/effect/temp_visual/sonar_ping
	duration = 3 SECONDS
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE
	randomdir = FALSE
	/// The image shown to modsuit users
	var/image/modsuit_image
	/// The person in the modsuit at the moment, really just used to remove this from their screen
	var/datum/weakref/mod_man
	/// The creature we're placing this on
	var/datum/weakref/pinged_person
	/// The icon state applied to the image created for this ping.
	var/real_icon_state = "sonar_ping"
	/// Does the visual follow the creature?
	var/follow_creature = TRUE
	/// Creature's X & Y coords, which can either be overridden or kept the same depending on follow_creature.
	var/creature_x
	var/creature_y

/obj/effect/temp_visual/sonar_ping/Initialize(mapload, mob/living/looker, mob/living/creature, ping_state, follow_creatures = TRUE)
	. = ..()
	if(!looker || !creature)
		return INITIALIZE_HINT_QDEL
	if(ping_state)
		real_icon_state = ping_state
	follow_creature = follow_creatures
	creature_x = creature.x
	creature_y = creature.y

	modsuit_image = image(icon = icon, loc = looker.loc, icon_state = real_icon_state, layer = ABOVE_ALL_MOB_LAYER, pixel_x = ((creature.x - looker.x) * 32), pixel_y = ((creature.y - looker.y) * 32))
	modsuit_image.plane = ABOVE_LIGHTING_PLANE
	SET_PLANE_EXPLICIT(modsuit_image, ABOVE_LIGHTING_PLANE, creature)
	mod_man = WEAKREF(looker)
	pinged_person = WEAKREF(creature)
	add_mind(looker)
	START_PROCESSING(SSfastprocess, src)

/obj/effect/temp_visual/sonar_ping/Destroy()
	var/mob/living/previous_user = mod_man?.resolve()
	if(previous_user)
		remove_mind(previous_user)
	STOP_PROCESSING(SSfastprocess, src)
	// Null so we don't shit the bed when we delete
	modsuit_image = null
	return ..()

/// Add the image to the modsuit wearer's screen
/obj/effect/temp_visual/sonar_ping/proc/add_mind(mob/living/looker)
	looker?.client?.images |= modsuit_image

/// Remove the image from the modsuit wearer's screen
/obj/effect/temp_visual/sonar_ping/proc/remove_mind(mob/living/looker)
	looker?.client?.images -= modsuit_image

/// Update the position of the ping while it's still up. Not sure if i need to use the full proc but just being safe
/obj/effect/temp_visual/sonar_ping/process(seconds_per_tick)
	var/mob/living/looker = mod_man?.resolve()
	var/mob/living/creature = pinged_person?.resolve()
	if(isnull(looker) || isnull(creature))
		return PROCESS_KILL
	modsuit_image.loc = looker.loc
	// Long pings follow, short pings stay put. We still need to update for looker.x&y though
	if(follow_creature)
		creature_y = creature.y
		creature_x = creature.x
	modsuit_image.pixel_x = ((creature_x - looker.x) * 32)
	modsuit_image.pixel_y = ((creature_y - looker.y) * 32)

/obj/effect/temp_visual/block //color is white by default, set to whatever is needed
	name = "blocking glow"
	icon_state = "block"
	duration = 6.7

/obj/effect/temp_visual/block/Initialize(mapload, set_color)
	if(set_color)
		add_atom_colour(set_color, FIXED_COLOUR_PRIORITY)
	. = ..()
	pixel_x = rand(-12, 12)
	pixel_y = rand(-9, 0)

/obj/effect/temp_visual/crit
	name = "critical hit"
	icon_state = "crit"
	duration = 15

/obj/effect/temp_visual/crit/Initialize(mapload)
	. = ..()
	animate(src, pixel_y = pixel_y + 16, alpha = 0, time = duration)

/obj/effect/temp_visual/jet_plume
	name = "jet plume"
	icon_state = "jet_plume"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	duration = 0.4 SECONDS

/// Plays a dispersing animation on hivelord and legion minions so they don't just vanish
/obj/effect/temp_visual/despawn_effect
	name = "withering spawn"
	duration = 1 SECONDS

/obj/effect/temp_visual/despawn_effect/Initialize(mapload, atom/copy_from)
	if (isnull(copy_from))
		. = ..()
		return INITIALIZE_HINT_QDEL
	icon = copy_from.icon
	icon_state = copy_from.icon_state
	pixel_x = copy_from.pixel_x
	pixel_y = copy_from.pixel_y
	duration = rand(0.5 SECONDS, 1 SECONDS)
	var/matrix/transformation = matrix(transform)
	transformation.Turn(rand(-70, 70))
	transformation.Scale(0.7, 0.7)
	animate(
		src,
		pixel_x = rand(-5, 5),
		pixel_y = -5,
		transform = transformation,
		color = "#44444400",
		time = duration,
		flags = ANIMATION_RELATIVE,
	)
	return ..()

/obj/effect/temp_visual/mech_sparks
	name = "mech sparks"
	icon_state = "mech_sparks"
	duration = 0.4 SECONDS

/obj/effect/temp_visual/mech_sparks/Initialize(mapload, set_color)
	. = ..()
	pixel_x = rand(-16, 16)
	pixel_y = rand(-8, 8)

/obj/effect/temp_visual/mech_attack_aoe_charge
	name = "mech attack aoe charge"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "mech_attack_aoe_charge"
	duration = 1 SECONDS
	pixel_x = -32
	pixel_y = -32

/obj/effect/temp_visual/mech_attack_aoe_attack
	name = "mech attack aoe attack"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "mech_attack_aoe_attack"
	duration = 0.5 SECONDS
	pixel_x = -32
	pixel_y = -32

/obj/effect/temp_visual/spotlight
	name = "Spotlight"
	icon = 'icons/effects/light_overlays/light_64.dmi'
	icon_state = "spotlight"
	duration = 5 MINUTES
	pixel_x = -16
	pixel_y = -8 //32
