//temporary visual effects(/obj/effect/temp_visual) used by clockcult stuff
/obj/effect/temp_visual/ratvar
	name = "ratvar's light"
	icon = 'icons/effects/clockwork_effects.dmi'
	duration = 8
	randomdir = 0
	layer = ABOVE_NORMAL_TURF_LAYER

/obj/effect/temp_visual/ratvar/door
	icon_state = "ratvardoorglow"
	layer = CLOSED_DOOR_LAYER //above closed doors

/obj/effect/temp_visual/ratvar/door/window
	icon_state = "ratvarwindoorglow"
	layer = ABOVE_WINDOW_LAYER

/obj/effect/temp_visual/ratvar/beam
	icon_state = "ratvarbeamglow"

/obj/effect/temp_visual/ratvar/beam/door
	layer = CLOSED_DOOR_LAYER

/obj/effect/temp_visual/ratvar/beam/grille
	layer = BELOW_OBJ_LAYER

/obj/effect/temp_visual/ratvar/beam/itemconsume
	layer = HIGH_OBJ_LAYER

/obj/effect/temp_visual/ratvar/beam/falsewall
	layer = OBJ_LAYER

/obj/effect/temp_visual/ratvar/beam/catwalk
	layer = LATTICE_LAYER

/obj/effect/temp_visual/ratvar/wall
	icon_state = "ratvarwallglow"

/obj/effect/temp_visual/ratvar/wall/false
	layer = OBJ_LAYER

/obj/effect/temp_visual/ratvar/floor
	icon_state = "ratvarfloorglow"

/obj/effect/temp_visual/ratvar/floor/catwalk
	layer = LATTICE_LAYER

/obj/effect/temp_visual/ratvar/window
	icon_state = "ratvarwindowglow"
	layer = ABOVE_OBJ_LAYER

/obj/effect/temp_visual/ratvar/window/single
	icon_state = "ratvarwindowglow_s"

/obj/effect/temp_visual/ratvar/gear
	icon_state = "ratvargearglow"
	layer = BELOW_OBJ_LAYER

/obj/effect/temp_visual/ratvar/grille
	icon_state = "ratvargrilleglow"
	layer = BELOW_OBJ_LAYER

/obj/effect/temp_visual/ratvar/grille/broken
	icon_state = "ratvarbrokengrilleglow"

/obj/effect/temp_visual/ratvar/mending_mantra
	layer = ABOVE_MOB_LAYER
	duration = 20
	alpha = 200
	icon_state = "mending_mantra"
	light_range = 1.5
	light_color = "#1E8CE1"

/obj/effect/temp_visual/ratvar/mending_mantra/Initialize(mapload)
	. = ..()
	transform = matrix()*2
	var/matrix/M = transform
	M.Turn(90)
	animate(src, alpha = 20, time = duration, easing = BOUNCE_EASING, flags = ANIMATION_PARALLEL)
	animate(src, transform = M, time = duration, flags = ANIMATION_PARALLEL)

/obj/effect/temp_visual/ratvar/volt_hit
	name = "volt blast"
	layer = ABOVE_MOB_LAYER
	duration = 8
	icon_state = "volt_hit"
	light_range = 1.5
	light_power = 2
	light_color = LIGHT_COLOR_ORANGE
	var/mob/user
	var/damage = 25

/obj/effect/temp_visual/ratvar/volt_hit/Initialize(mapload, caster)
	. = ..()
	user = caster
	if(user)
		var/matrix/M = new
		M.Turn(Get_Angle(src, user))
		transform = M
	INVOKE_ASYNC(src, .proc/volthit)

/obj/effect/temp_visual/ratvar/volt_hit/proc/volthit()
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

/obj/effect/temp_visual/ratvar/ocular_warden
	name = "warden's gaze"
	layer = ABOVE_MOB_LAYER
	icon_state = "warden_gaze"
	duration = 3

/obj/effect/temp_visual/ratvar/ocular_warden/Initialize()
	. = ..()
	pixel_x = rand(-8, 8)
	pixel_y = rand(-10, 10)
	animate(src, alpha = 0, time = 3, easing = EASE_OUT)

/obj/effect/temp_visual/ratvar/prolonging_prism
	icon = 'icons/effects/64x64.dmi'
	icon_state = "prismhex1"
	layer = RIPPLE_LAYER
	pixel_y = -16
	pixel_x = -16
	duration = 30

/obj/effect/temp_visual/ratvar/prolonging_prism/Initialize(mapload, set_appearance)
	. = ..()
	if(set_appearance)
		appearance = set_appearance
	animate(src, alpha = 0, time = duration, easing = BOUNCE_EASING)

/obj/effect/temp_visual/ratvar/spearbreak
	icon = 'icons/effects/64x64.dmi'
	icon_state = "ratvarspearbreak"
	layer = BELOW_MOB_LAYER
	pixel_y = -16
	pixel_x = -16

/obj/effect/temp_visual/ratvar/geis_binding
	icon_state = "geisbinding"

/obj/effect/temp_visual/ratvar/geis_binding/top
	icon_state = "geisbinding_top"

/obj/effect/temp_visual/ratvar/component
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "belligerent_eye"
	layer = ABOVE_MOB_LAYER
	duration = 10

/obj/effect/temp_visual/ratvar/component/Initialize()
	. = ..()
	transform = matrix()*0.75
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, -2)
	animate(src, pixel_y = pixel_y + 10, alpha = 50, time = 10, easing = EASE_OUT)

/obj/effect/temp_visual/ratvar/component/cogwheel
	icon_state = "vanguard_cogwheel"

/obj/effect/temp_visual/ratvar/component/capacitor
	icon_state = "geis_capacitor"

/obj/effect/temp_visual/ratvar/component/alloy
	icon_state = "replicant_alloy"

/obj/effect/temp_visual/ratvar/component/ansible
	icon_state = "hierophant_ansible"

/obj/effect/temp_visual/ratvar/sigil
	name = "glowing circle"
	icon_state = "sigildull"

/obj/effect/temp_visual/ratvar/sigil/transgression
	color = "#FAE48C"
	layer = ABOVE_MOB_LAYER
	duration = 70
	light_range = 5
	light_power = 2
	light_color = "#FAE48C"

/obj/effect/temp_visual/ratvar/sigil/transgression/Initialize()
	. = ..()
	var/oldtransform = transform
	animate(src, transform = matrix()*2, time = 5)
	animate(transform = oldtransform, alpha = 0, time = 65)

/obj/effect/temp_visual/ratvar/sigil/vitality
	color = "#1E8CE1"
	icon_state = "sigilactivepulse"
	layer = ABOVE_MOB_LAYER
	light_range = 1.4
	light_power = 0.5
	light_color = "#1E8CE1"

/obj/effect/temp_visual/ratvar/sigil/submission
	color = "#AF0AAF"
	layer = ABOVE_MOB_LAYER
	duration = 80
	icon_state = "sigilactiveoverlay"
	alpha = 0
