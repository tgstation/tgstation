/obj/item/highfrequencyblade
	name = "high frequency blade"
	desc = "A sword reinforced by a powerful alternating current and resonating at extremely high vibration frequencies. \
		This oscillation weakens the molecular bonds of anything it cuts, thereby increasing its cutting ability."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "hfrequency0"
	worn_icon_state = "hfrequency0"
	icon_angle = -45
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 10
	wound_bonus = 25
	exposed_wound_bonus = 50
	throwforce = 25
	throw_speed = 4
	attack_speed = CLICK_CD_HYPER_RAPID
	embed_type = /datum/embedding/hfr_blade
	block_chance = 25
	block_sound = 'sound/items/weapons/parry.ogg'
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	/// The color of the slash we create
	var/slash_color = COLOR_BLUE
	/// Previous x position of where we clicked on the target's icon
	var/previous_x
	/// Previous y position of where we clicked on the target's icon
	var/previous_y
	/// The previous target we attacked
	var/datum/weakref/previous_target

/datum/embedding/hfr_blade
	embed_chance = 100

/obj/item/highfrequencyblade/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		wield_callback = CALLBACK(src, PROC_REF(on_wield)), \
		unwield_callback = CALLBACK(src, PROC_REF(on_unwield)), \
	)
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/highfrequencyblade/update_icon_state()
	icon_state = "hfrequency[HAS_TRAIT(src, TRAIT_WIELDED)]"
	return ..()

/obj/item/highfrequencyblade/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	if(attack_type == PROJECTILE_ATTACK)
		if(HAS_TRAIT(src, TRAIT_WIELDED) || prob(final_block_chance))
			owner.visible_message(span_danger("[owner] deflects [attack_text] with [src]!"))
			playsound(src, SFX_BULLET_MISS, 75, TRUE)
			return TRUE
		return FALSE
	var/stop_that_blade = (final_block_chance + (attack_type == OVERWHELMING_ATTACK ? 25 : 0)) * (HAS_TRAIT(src, TRAIT_WIELDED) ? 2 : 1)
	if(prob(stop_that_blade))
		owner.visible_message(span_danger("[owner] parries [attack_text] with [src]!"))
		return TRUE
	return FALSE

/obj/item/highfrequencyblade/pre_attack(atom/target, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(.)
		return .
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		return . // Default attack
	if(isliving(target) && HAS_TRAIT(src, TRAIT_PACIFISM))
		return . // Default attack (ultimately nothing)

	return slash(target, user, modifiers)

/// triggered on wield of two handed item
/obj/item/highfrequencyblade/proc/on_wield(obj/item/source, mob/user)
	update_icon(UPDATE_ICON_STATE)

/// triggered on unwield of two handed item
/obj/item/highfrequencyblade/proc/on_unwield(obj/item/source, mob/user)
	update_icon(UPDATE_ICON_STATE)

/obj/item/highfrequencyblade/proc/slash(atom/target, mob/living/user, list/modifiers)
	user.do_attack_animation(target, "nothing")
	var/damage_mod = 1
	var/x_slashed = text2num(modifiers[ICON_X]) || ICON_SIZE_X/2 //in case we arent called by a client
	var/y_slashed = text2num(modifiers[ICON_Y]) || ICON_SIZE_Y/2 //in case we arent called by a client
	new /obj/effect/temp_visual/slash(get_turf(target), target, x_slashed, y_slashed, slash_color)
	if(target == previous_target?.resolve()) //if the same target, we calculate a damage multiplier if you swing your mouse around
		var/x_mod = previous_x - x_slashed
		var/y_mod = previous_y - y_slashed
		damage_mod = max(1, round((sqrt(x_mod ** 2 + y_mod ** 2) / 10), 0.1))
	previous_target = WEAKREF(target)
	previous_x = x_slashed
	previous_y = y_slashed
	playsound(src, 'sound/items/weapons/bladeslice.ogg', 100, vary = TRUE)
	playsound(src, 'sound/items/weapons/zapbang.ogg', 50, vary = TRUE)
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_damage(force*damage_mod, BRUTE, sharpness = SHARP_EDGED, wound_bonus = wound_bonus, exposed_wound_bonus = exposed_wound_bonus, def_zone = user.zone_selected)
		log_combat(user, living_target, "slashed", src)
		if(living_target.stat == DEAD && prob(force*damage_mod*0.5))
			living_target.visible_message(span_danger("[living_target] explodes in a shower of gore!"), blind_message = span_hear("You hear organic matter ripping and tearing!"))
			living_target.investigate_log("has been gibbed by [src].", INVESTIGATE_DEATHS)
			living_target.gib(DROP_ALL_REMAINS)
			log_combat(user, living_target, "gibbed", src)
		return TRUE
	else if(target.uses_integrity)
		target.take_damage(force*damage_mod*3, BRUTE, MELEE, FALSE, null, 50)
		return TRUE
	else if(iswallturf(target) && prob(force*damage_mod*0.5))
		var/turf/closed/wall/wall_target = target
		wall_target.dismantle_wall()
		return TRUE
	else if(ismineralturf(target) && prob(force*damage_mod))
		var/turf/closed/mineral/mineral_target = target
		mineral_target.gets_drilled()
		return TRUE
	return FALSE

/obj/effect/temp_visual/slash
	icon_state = "highfreq_slash"
	alpha = 150
	duration = 0.5 SECONDS
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE

/obj/effect/temp_visual/slash/Initialize(mapload, atom/target, x_slashed, y_slashed, slash_color)
	. = ..()
	if(!target)
		return
	var/matrix/new_transform = matrix()
	new_transform.Turn(rand(1, 360)) // Random slash angle
	var/datum/decompose_matrix/decomp = target.transform.decompose()
	new_transform.Translate((x_slashed - ICON_SIZE_X/2) * decomp.scale_x, (y_slashed - ICON_SIZE_Y/2) * decomp.scale_y) // Move to where we clicked
	//Follow target's transform while ignoring scaling
	new_transform.Turn(decomp.rotation)
	new_transform.Translate(decomp.shift_x, decomp.shift_y)
	new_transform.Translate(target.pixel_x, target.pixel_y) // Follow target's pixel offsets
	transform = new_transform
	//Double the scale of the matrix by doubling the 2x2 part without touching the translation part
	var/matrix/scaled_transform = new_transform + matrix(new_transform.a, new_transform.b, 0, new_transform.d, new_transform.e, 0)
	animate(src, duration*0.5, color = slash_color, transform = scaled_transform, alpha = 255)

/obj/item/highfrequencyblade/wizard
	desc = "A blade that was mastercrafted by a legendary blacksmith. Its enchantments let it slash through anything."
	force = 8
	throwforce = 20
	wound_bonus = 20
	exposed_wound_bonus = 25

/obj/item/highfrequencyblade/wizard/attack_self(mob/user, modifiers)
	if(!HAS_MIND_TRAIT(user, TRAIT_MAGICALLY_GIFTED))
		balloon_alert(user, "you're too weak!")
		return
	return ..()
