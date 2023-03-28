/obj/structure/plasma_cannon_vault
	name = "vault chest"
	desc = "It looks so inviting..."
	icon = 'icons/obj/objects.dmi'
	icon_state = "rack"
	density = TRUE
	anchored = TRUE
	move_resist = MOVE_FORCE_OVERPOWERING
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | UNACIDABLE | FREEZE_PROOF
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	max_integrity = 500
	var/open_time = 10 SECONDS
	var/obj/item/gun/energy/plasma_cannon/gun

/obj/structure/plasma_cannon_vault/Initialize(mapload)
	. = ..()
	gun = new(src)

/obj/structure/plasma_cannon_vault/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == gun)
		gun = null

/obj/structure/plasma_cannon_vault/attack_hand(mob/living/user, list/modifiers)
	if(DOING_INTERACTION_WITH_TARGET(user, src))
		return
	balloon_alert(user, "opening vault...")
	INVOKE_ASYNC(src, PROC_REF(random_beeps), user, open_time, 0.5 SECONDS, 1.5 SECONDS)
	if(!do_after(user, open_time, target = src))
		balloon_alert(user, "interrupted!")
		return
	icon_state = "rack"
	flick("rack", src)
	playsound(src, 'sound/machines/scanner.ogg', 100)
	addtimer(CALLBACK(src, PROC_REF(drop_gun)), 3.5 SECONDS)

/obj/structure/plasma_cannon_vault/proc/random_beeps(mob/user, time = 0, mintime = 0, maxtime = 1)
	var/static/list/beep_sounds = list('sound/machines/terminal_prompt_confirm.ogg', 'sound/machines/terminal_prompt_deny.ogg', 'sound/machines/terminal_error.ogg', 'sound/machines/terminal_select.ogg', 'sound/machines/terminal_success.ogg')
	var/time_to_spend = 0
	var/orig_time = time
	while(time > 0)
		if(!DOING_INTERACTION_WITH_TARGET(user, src) && time != orig_time)
			return
		time_to_spend = rand(mintime, maxtime)
		playsound(src, pick(beep_sounds), 75)
		time -= time_to_spend
		stoplag(time_to_spend)

/obj/structure/plasma_cannon_vault/proc/drop_gun()
	gun.forceMove(loc)
	playsound(src, 'sound/machines/chime.ogg', 75)

/obj/item/gun/energy/plasma_cannon
	name = "\improper VNS plasma cannon"
	desc = "The Venusian's \"self-defense\" weapon against hostile ships. \
		<b>Incredibly</b> breaching. <b>Incredibly</b> inefficient. <b>Incredibly</b> dangerous. \
		Requires cell charge, plasma and sulfur to function."
	icon_state = "instagib"
	inhand_icon_state = "instagib"
	ammo_type = list(/obj/item/ammo_casing/energy/plasma_cannon)
	flags_1 = CONDUCT_1
	force = 16
	recoil = 10
	dead_cell = TRUE
	cell_type = /obj/item/stock_parts/cell/emproof/empty
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_HUGE
	resistance_flags = FIRE_PROOF|ACID_PROOF
	light_range = 2
	light_power = 1
	light_color = COLOR_PALE_PURPLE_GRAY
	light_system = MOVABLE_LIGHT
	/// Our current plasma charge level.
	var/plasma_charges = 0
	/// How much plasma we need to fire.
	var/required_plasma = 10
	/// How much sulfur we start with.
	var/starting_sulfur = 0
	/// How much sulfur we need to fire.
	var/required_sulfur = 30
	/// Valid sources of plasma fuel and how much plasma they give.
	var/static/list/charger_list = list(/obj/item/stack/ore/plasma = 2, /obj/item/stack/sheet/mineral/plasma = 1)

/obj/item/gun/energy/plasma_cannon/examine(mob/user)
	. = ..()
	var/datum/reagent/sulfur = reagents.has_reagent(/datum/reagent/sulfur)
	. += span_notice("Charge meter reads [cell.charge]/[cell.maxcharge].")
	. += span_notice("Plasma meter reads [plasma_charges]/[required_plasma].")
	. += span_notice("Sulfur meter reads [sulfur ? sulfur.volume : 0]/[required_sulfur].")

/obj/item/gun/energy/plasma_cannon/Initialize(mapload)
	create_reagents(required_sulfur)
	. = ..()
	if(starting_sulfur)
		reagents.add_reagent(/datum/reagent/sulfur, starting_sulfur)

/obj/item/gun/energy/plasma_cannon/can_shoot()
	return plasma_charges == required_plasma && (!required_sulfur || reagents.has_reagent(/datum/reagent/sulfur, required_sulfur)) && ..()

/obj/item/gun/energy/plasma_cannon/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	. = ..()
	plasma_charges = 0
	reagents.del_reagent(/datum/reagent/sulfur)

/obj/item/gun/energy/plasma_cannon/attackby(obj/item/attacking_item, mob/living/user, params)
	. = ..()
	var/charge_given = is_type_in_list(attacking_item, charger_list, zebra = TRUE)
	if(charge_given)
		if(plasma_charges == required_plasma)
			balloon_alert(user, "already fueled!")
		var/obj/item/stack/plasma = attacking_item
		var/uses_needed = min(plasma.amount, required_plasma - plasma_charges)
		if(!plasma.use(uses_needed))
			return FALSE
		plasma_charges += charge_given * uses_needed
		balloon_alert(user, "plasma [plasma_charges == required_plasma ? "fully" : "partially"] refueled")
	if(!attacking_item.is_open_container())
		return FALSE
	if(reagents.has_reagent(/datum/reagent/sulfur, required_sulfur))
		balloon_alert(user, "already loaded!")
		return FALSE
	if(!attacking_item.reagents.trans_id_to(src, /datum/reagent/sulfur, required_sulfur))
		return FALSE
	balloon_alert(user, "sulfur [reagents.has_reagent(/datum/reagent/sulfur, required_sulfur) ? "fully" : "partially"] reloaded")
	return TRUE

/obj/item/gun/energy/plasma_cannon/loaded
	dead_cell = FALSE
	cell_type = /obj/item/stock_parts/cell/emproof
	plasma_charges = 10
	starting_sulfur = 30

/obj/item/gun/energy/plasma_cannon/admin
	dead_cell = FALSE
	cell_type = /obj/item/stock_parts/cell/infinite
	required_plasma = 0
	required_sulfur = 0

/obj/item/ammo_casing/energy/plasma_cannon
	projectile_type = /obj/projectile/plasma_cannon
	select_name = "PLASMA BURST"
	fire_sound = 'sound/weapons/blastcannon.ogg'
	delay = 85
	e_cost = 500

/obj/projectile/plasma_cannon
	name = "plasma ball"
	icon_state = "pcl"
	damage_type = BURN
	armor_flag = ENERGY
	hitsound = 'sound/effects/explosion3.ogg'
	range = 14
	damage = 50
	speed = 3
	wound_bonus = 0
	light_range = 2
	light_power = 3
	light_color = COLOR_PURPLE
	projectile_piercing = PASSMOB
	/// Path of projectiles we explode into when we perish.
	var/exploded_type = /obj/projectile/plasma_cannon/medium
	/// How many projectiles we fire on explosion!
	var/exploded_amount = 4
	/// How many objects/walls we pierce.
	var/possible_pierces = 3

/obj/projectile/plasma_cannon/Initialize(mapload)
	. = ..()
	particles = new /particles/plasma_trail()

/obj/projectile/plasma_cannon/Destroy()
	QDEL_NULL(particles)
	return ..()

/obj/projectile/plasma_cannon/prehit_pierce(atom/target)
	if(ismineralturf(target))
		return PROJECTILE_PIERCE_HIT
	if(!possible_pierces || ismob(target))
		return ..()
	possible_pierces--
	return PROJECTILE_PIERCE_HIT

/obj/projectile/plasma_cannon/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(pierce_hit)
		if(isturf(target))
			SSexplosions.medturf += target
		else if(isobj(target))
			SSexplosions.med_mov_atom += target
		return
	explode()

/obj/projectile/plasma_cannon/on_range()
	explode()
	return ..()

/obj/projectile/plasma_cannon/ex_act(severity, target)
	return

/obj/projectile/plasma_cannon/proc/explode()
	var/our_turf = get_turf(src)
	new /obj/effect/temp_visual/explosion/fast(our_turf)
	explode_tiles(our_turf)
	if(!exploded_amount)
		return
	var/degree_change = 360 / exploded_amount
	for(var/i in 1 to exploded_amount)
		var/obj/projectile/new_projectile = new exploded_type(our_turf)
		new_projectile.fired_from = fired_from
		new_projectile.firer = firer
		new_projectile.ignore_source_check = TRUE
		new_projectile.hit_prone_targets = TRUE
		new_projectile.pixel_x = pixel_x
		new_projectile.pixel_y = pixel_y
		new_projectile.fire(degree_change * i + Angle)

/obj/projectile/plasma_cannon/proc/explode_tiles(our_turf)
	explosion(our_turf, light_impact_range = 2, flame_range = 3)

/obj/projectile/plasma_cannon/medium
	icon_state = "pcm"
	damage = 25
	light_range = 1.5
	exploded_type = /obj/projectile/plasma_cannon/small
	exploded_amount = 10
	possible_pierces = 1

/obj/projectile/plasma_cannon/medium/explode_tiles(our_turf)
	explosion(our_turf, light_impact_range = 1, flame_range = 2)

/obj/projectile/plasma_cannon/small
	icon_state = "pcs"
	damage = 12
	light_range = 1
	exploded_type = null
	exploded_amount = 0
	possible_pierces = 0

/obj/projectile/plasma_cannon/small/explode()
	return

/particles/plasma_trail
	icon = 'icons/effects/particles/echo.dmi'
	icon_state = list("echo1" = 1, "echo2" = 1, "echo3" = 2)
	color = "#FBC9FF"
	width = 100
	height = 300
	count = 1000
	spawning = 3
	lifespan = 0.9 SECONDS
	fade = 0.4 SECONDS
	position = generator(GEN_CIRCLE, 0, 8, NORMAL_RAND)
	drift = list(0, -1)
