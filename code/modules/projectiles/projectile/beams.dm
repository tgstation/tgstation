/obj/item/projectile/beam
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 20
	light_range = 2
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	flag = "laser"
	eyeblur = 2
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = LIGHT_COLOR_RED
	ricochets_max = 50	//Honk!
	ricochet_chance = 80
	reflectable = REFLECT_NORMAL

/obj/item/projectile/beam/laser
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/item/projectile/beam/laser/heavylaser
	name = "heavy laser"
	icon_state = "heavylaser"
	damage = 40
	tracer_type = /obj/effect/projectile/tracer/heavy_laser
	muzzle_type = /obj/effect/projectile/muzzle/heavy_laser
	impact_type = /obj/effect/projectile/impact/heavy_laser

/obj/item/projectile/beam/laser/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.IgniteMob()
	else if(isturf(target))
		impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser/wall

/obj/item/projectile/beam/weak
	damage = 15

/obj/item/projectile/beam/weak/penetrator
	armour_penetration = 50

/obj/item/projectile/beam/practice
	name = "practice laser"
	damage = 0
	nodamage = TRUE

/obj/item/projectile/beam/scatter
	name = "laser pellet"
	icon_state = "scatterlaser"
	damage = 5

/obj/item/projectile/beam/xray
	name = "\improper X-ray beam"
	icon_state = "xray"
	flag = "rad"
	damage = 15
	irradiate = 300
	range = 15
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF

	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_GREEN
	tracer_type = /obj/effect/projectile/tracer/xray
	muzzle_type = /obj/effect/projectile/muzzle/xray
	impact_type = /obj/effect/projectile/impact/xray

/obj/item/projectile/beam/disabler
	name = "disabler beam"
	icon_state = "omnilaser"
	damage = 30
	damage_type = STAMINA
	flag = "energy"
	hitsound = 'sound/weapons/tap.ogg'
	eyeblur = 0
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE
	tracer_type = /obj/effect/projectile/tracer/disabler
	muzzle_type = /obj/effect/projectile/muzzle/disabler
	impact_type = /obj/effect/projectile/impact/disabler

/obj/item/projectile/beam/pulse
	name = "pulse"
	icon_state = "u_laser"
	damage = 50
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE
	tracer_type = /obj/effect/projectile/tracer/pulse
	muzzle_type = /obj/effect/projectile/muzzle/pulse
	impact_type = /obj/effect/projectile/impact/pulse

/obj/item/projectile/beam/pulse/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if (!QDELETED(target) && (isturf(target) || istype(target, /obj/structure/)))
		target.ex_act(EXPLODE_HEAVY)

/obj/item/projectile/beam/pulse/shotgun
	damage = 40

/obj/item/projectile/beam/pulse/heavy
	name = "heavy pulse laser"
	icon_state = "pulse1_bl"
	var/life = 20

/obj/item/projectile/beam/pulse/heavy/on_hit(atom/target, blocked = FALSE)
	life -= 10
	if(life > 0)
		. = BULLET_ACT_FORCE_PIERCE
	..()

/obj/item/projectile/beam/emitter
	name = "emitter beam"
	icon_state = "emitter"
	damage = 30
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_GREEN

/obj/item/projectile/beam/emitter/singularity_pull()
	return //don't want the emitters to miss

/obj/item/projectile/beam/lasertag
	name = "laser tag beam"
	icon_state = "omnilaser"
	hitsound = null
	damage = 0
	damage_type = STAMINA
	flag = "laser"
	var/suit_types = list(/obj/item/clothing/suit/redtag, /obj/item/clothing/suit/bluetag)
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE

/obj/item/projectile/beam/lasertag/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		if(istype(M.wear_suit))
			if(M.wear_suit.type in suit_types)
				M.adjustStaminaLoss(34)

/obj/item/projectile/beam/lasertag/redtag
	icon_state = "laser"
	suit_types = list(/obj/item/clothing/suit/bluetag)
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = LIGHT_COLOR_RED
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/item/projectile/beam/lasertag/redtag/hitscan
	hitscan = TRUE

/obj/item/projectile/beam/lasertag/bluetag
	icon_state = "bluelaser"
	suit_types = list(/obj/item/clothing/suit/redtag)
	tracer_type = /obj/effect/projectile/tracer/laser/blue
	muzzle_type = /obj/effect/projectile/muzzle/laser/blue
	impact_type = /obj/effect/projectile/impact/laser/blue

/obj/item/projectile/beam/lasertag/bluetag/hitscan
	hitscan = TRUE

/obj/item/projectile/beam/instakill
	name = "instagib laser"
	icon_state = "purple_laser"
	damage = 200
	damage_type = BURN
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	light_color = LIGHT_COLOR_PURPLE

/obj/item/projectile/beam/instakill/blue
	icon_state = "blue_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE

/obj/item/projectile/beam/instakill/red
	icon_state = "red_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = LIGHT_COLOR_RED

/obj/item/projectile/beam/instakill/on_hit(atom/target)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.visible_message("<span class='danger'>[M] explodes into a shower of gibs!</span>")
		M.gib()

/obj/item/projectile/beam/heavy
	name = "\improper heavy laser beam"
	icon_state = "heavylaser"
	damage = 30
	range = 15
	irradiate = 30
	armour_penetration = 20
	dismemberment = 10
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_RED
	tracer_type = /obj/effect/projectile/tracer/xray
	muzzle_type = /obj/effect/projectile/muzzle/xray
	impact_type = /obj/effect/projectile/impact/xray
	pass_flags = PASSTABLE

/obj/item/projectile/beam/heavy/on_hit(atom/target, blocked = FALSE)
	. = BULLET_ACT_FORCE_PIERCE
	..()

/obj/item/projectile/beam/shock
	name = "\improper charged beam"
	icon_state = "spark"
	damage = 22
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_CYAN
	tracer_type = /obj/effect/projectile/tracer/xray
	muzzle_type = /obj/effect/projectile/muzzle/xray
	impact_type = /obj/effect/projectile/impact/xray

/obj/item/projectile/beam/shock/on_hit(atom/target)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.electrocute_act(15, C, 1, FALSE, FALSE, FALSE, FALSE, FALSE)
		if(prob(20))
			C.dropItemToGround(C.get_active_held_item())
		C.confused += 6

/obj/item/projectile/beam/bitcoin
	name = "\improper bitcoin stealing beam"
	icon_state = "bitcoin"
	damage = 0
	nodamage = TRUE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_GREEN
	tracer_type = /obj/effect/projectile/tracer/xray
	muzzle_type = /obj/effect/projectile/muzzle/xray
	impact_type = /obj/effect/projectile/impact/xray

/obj/item/projectile/beam/bitcoin/on_hit(atom/target)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/card/id/C = H.get_idcard(TRUE)
		if(C && C.registered_account)
			C.registered_account.adjust_money(-100)
		else
			H.adjustStaminaLoss(40)
		if(ishuman(firer))
			var/mob/living/carbon/human/FH = firer
			var/obj/item/card/id/FC = FH.get_idcard(TRUE)
			if(FC && FC.registered_account)
				FC.registered_account.adjust_money(100)

/obj/item/projectile/beam/tracer
	name = "\improper tracing beam"
	icon_state = "tracer"
	homing = TRUE
	damage = 5
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_CYAN
	tracer_type = /obj/effect/projectile/tracer/xray
	muzzle_type = /obj/effect/projectile/muzzle/xray
	impact_type = /obj/effect/projectile/impact/xray

/obj/item/projectile/beam/tracer/on_hit(atom/target)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.apply_status_effect(/datum/status_effect/laserweak)

/obj/screen/alert/status_effect/laserweak
	name = "Adamantine Slimeskin"
	desc = "You are covered in a thick, non-neutonian gel."
	icon_state = "slime_stoneskin"

/datum/status_effect/laserweak
	id = "laserweak"
	duration = 100
	alert_type = /obj/screen/alert/status_effect/slimeskin
	var/originalcolor
	var/obj/effect/light_holder

/datum/status_effect/laserweak/on_apply()
	originalcolor = owner.color
	owner.color = "#3070CC"
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		var/datum/species/S = H.dna.species
		S.burnmod += 0.4
		S.stunmod += 0.2
		light_holder = new(H)
		light_holder.set_light(7, 2.7, "#FFCC00")
	owner.visible_message("<span class='warning'>[owner] is suddenly covered in a strange, blue-ish gel!</span>",
		"<span class='notice'>You are covered in a thick, rubbery gel.</span>")
	return ..()

/datum/status_effect/laserweak/on_remove()
	owner.color = originalcolor
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		var/datum/species/S = H.dna.species
		S.burnmod -= 0.4
		S.stunmod -= 0.2
		QDEL_NULL(light_holder)
	owner.visible_message("<span class='warning'>[owner]'s gel coating liquefies and dissolves away.</span>",
"<span class='notice'>Your gel second-skin dissolves!</span>")


/obj/item/projectile/beam/blinding
	name = "\improper blinding beam"
	icon_state = "blinding"
	eyeblur = 30
	damage = 8
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_PURPLE
	tracer_type = /obj/effect/projectile/tracer/xray
	muzzle_type = /obj/effect/projectile/muzzle/xray
	impact_type = /obj/effect/projectile/impact/xray

/obj/item/projectile/beam/blinding/on_hit(atom/target)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.eye_blind += 51

/obj/item/projectile/beam/incendiary
	name = "\improper incendiary beam"
	icon_state = "lava"
	damage = 15
	var/fire_stacks = 2
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_ORANGE
	tracer_type = /obj/effect/projectile/tracer/xray
	muzzle_type = /obj/effect/projectile/muzzle/xray
	impact_type = /obj/effect/projectile/impact/xray

/obj/item/projectile/beam/incendiary/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(fire_stacks)
		M.IgniteMob()

/obj/item/projectile/beam/lowenergy
	name = "\improper small laser beam"
	icon_state = "mini"
	damage = 10
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_BLUE
	tracer_type = /obj/effect/projectile/tracer/xray
	muzzle_type = /obj/effect/projectile/muzzle/xray
	impact_type = /obj/effect/projectile/impact/xray

/obj/item/projectile/beam/rico
	name = "\improper bouncing plasma ball"
	icon_state = "pulse0"
	ricochets_max = 100
	damage = 17
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_ORANGE
	tracer_type = /obj/effect/projectile/tracer/xray
	muzzle_type = /obj/effect/projectile/muzzle/xray
	impact_type = /obj/effect/projectile/impact/xray

/obj/item/projectile/beam/rico/Bump(atom/A)
	var/turf/T = get_turf(A)
	if(ricochets < ricochets_max)
		ricochets++
		if(A.handle_ricochet(src))
			on_ricochet(A)
			ignore_source_check = TRUE
			return TRUE
	var/distance = get_dist(T, starting)
	def_zone = ran_zone(def_zone, max(100-(7*distance), 5))

	if(isturf(A) && hitsound_wall)
		var/volume = CLAMP(vol_by_damage() + 20, 0, 100)
		if(suppressed)
			volume = 5
		playsound(loc, hitsound_wall, volume, 1, -1)

	return process_hit(T, select_target(T, A))

/obj/item/projectile/beam/invisible
	invisibility = INVISIBILITY_MAXIMUM
	damage = 15
	range = 12
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_PINK
	tracer_type = /obj/effect/projectile/tracer/xray
	muzzle_type = /obj/effect/projectile/muzzle/xray
	impact_type = /obj/effect/projectile/impact/xray

/obj/item/projectile/beam/syphon
	name = "\improper syphoning beam"
	range = 8
	damage = 5
	icon_state = ""
	hitscan = TRUE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_YELLOW
	tracer_type = /obj/effect/projectile/tracer/solar
	muzzle_type = /obj/effect/projectile/muzzle/xray
	impact_type = /obj/effect/projectile/impact/xray

/obj/item/projectile/beam/syphon/on_hit(atom/target)
	var/power = 0
	if(istype(target, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = target
		C.charge -= min(1000, C.charge)
	//	if(prob(5))
	//		cell.rigged = TRUE
		power = 200
	if(istype(target, /obj/machinery/power/smes))
		var/obj/machinery/power/smes/S = target
		S.charge -= min(8000, S.charge)
		power = 300
	if(istype(target, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/APC = target
		var/obj/item/stock_parts/cell/C = APC.cell
		C.charge -=  min(500, C.charge)
		power = 200
	message_admins("<span class='notice'>[power] e [firer]</span>")
	if(ishuman(firer))
		var/mob/living/carbon/human/FH = firer
		SEND_SIGNAL(src, "syphon", power, FH)

/obj/effect/projectile/tracer/solar
	name = "syphon"
	icon_state = "solar"