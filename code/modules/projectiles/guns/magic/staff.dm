/obj/item/gun/magic/staff
	slot_flags = ITEM_SLOT_BACK
	ammo_type = /obj/item/ammo_casing/magic/nothing
	worn_icon_state = null
	icon_state = "staff"
	icon_angle = -45
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	item_flags = NEEDS_PERMIT | NO_MAT_REDEMPTION
	/// Can non-magic folk use our staff?
	/// If FALSE, only wizards or survivalists can use the staff to its full potential - If TRUE, anyone can
	var/allow_intruder_use = FALSE

/obj/item/gun/magic/staff/proc/is_wizard_or_friend(mob/user)
	if(!HAS_MIND_TRAIT(user, TRAIT_MAGICALLY_GIFTED) && !allow_intruder_use)
		return FALSE
	return TRUE

/obj/item/gun/magic/staff/can_trigger_gun(mob/living/user, akimbo_usage)
	if(akimbo_usage && !is_wizard_or_friend(user))
		return FALSE
	return ..()

/obj/item/gun/magic/staff/check_botched(mob/living/user, atom/target)
	if(!is_wizard_or_friend(user))
		return !on_intruder_use(user, target)
	return ..()

/// Called when someone who isn't a wizard or magician uses this staff.
/// Return TRUE to allow usage.
/obj/item/gun/magic/staff/proc/on_intruder_use(mob/living/user, atom/target)
	return TRUE

/// Turns mobs into other mobs
/obj/item/gun/magic/staff/change
	name = "staff of change"
	desc = "An artefact that spits bolts of coruscating energy which cause the target's very form to reshape itself."
	fire_sound = 'sound/effects/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/change
	icon_state = "staffofchange"
	inhand_icon_state = "staffofchange"
	school = SCHOOL_TRANSMUTATION
	/// If set, all wabbajacks this staff produces will be of this type, instead of random
	var/preset_wabbajack_type
	/// If set, all wabbajacks this staff produces will be of this changeflag, instead of only WABBAJACK
	var/preset_wabbajack_changeflag

/obj/item/gun/magic/staff/change/unrestricted
	allow_intruder_use = TRUE

/obj/item/gun/magic/staff/change/pickup(mob/user)
	. = ..()
	if(!is_wizard_or_friend(user))
		to_chat(user, span_hypnophrase("<span style='font-size: 24px'>You don't feel strong enough to properly wield this staff!</span>"))
		balloon_alert(user, "you feel weak holding this staff")

/// Transforms the user
/obj/item/gun/magic/staff/change/proc/transform_self(mob/living/user)
	user.dropItemToGround(src, TRUE)
	var/wabbajack_into = preset_wabbajack_type || pick(WABBAJACK_MONKEY, WABBAJACK_HUMAN, WABBAJACK_ANIMAL)
	var/mob/living/new_body = user.wabbajack(wabbajack_into, preset_wabbajack_changeflag)
	if(!new_body)
		return
	balloon_alert(new_body, "wabbajack, wabbajack!")
	return new_body

/obj/item/gun/magic/staff/change/on_intruder_use(mob/living/user, atom/target)
	transform_self(user)

/obj/item/gun/magic/staff/change/do_suicide(mob/living/user)
	playsound(loc, fire_sound, 50, TRUE, -1)
	var/mob/living/transformed = transform_self(user)
	transformed.death()
	transformed.set_suicide(TRUE)
	return MANUAL_SUICIDE

/// Brings objects to life
/obj/item/gun/magic/staff/animate
	name = "staff of animation"
	desc = "An artefact that spits bolts of life-force which causes objects which are hit by it to animate and come to life! This magic doesn't affect machines."
	fire_sound = 'sound/effects/magic/staff_animation.ogg'
	ammo_type = /obj/item/ammo_casing/magic/animate
	icon_state = "staffofanimation"
	inhand_icon_state = "staffofanimation"
	school = SCHOOL_EVOCATION

/obj/item/gun/magic/staff/animate/do_suicide(mob/living/user)
	user.Stun(20 SECONDS, ignore_canstun = TRUE)
	var/list/my_shit = user.unequip_everything()
	my_shit -= src
	user.put_in_active_hand(src) // Keep this one for now
	charges++ // We already subtracted one
	user.Paralyze(2 SECONDS, ignore_canstun = TRUE) // We have at most 6 charges so this is slightly longer than necessary
	while (length(my_shit) && charges > 0)
		if(QDELETED(user) || user.stat == DEAD)
			break
		charges--
		playsound(loc, fire_sound, 50, TRUE, -1)
		var/obj/item/my_thing = pop(my_shit)
		user.dropItemToGround(my_thing)
		var/mob/living/angry_thing = my_thing.animate_atom_living()
		angry_thing.ai_controller?.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, user)
		angry_thing.ai_controller?.set_blackboard_key(BB_TARGET_MINIMUM_STAT, HARD_CRIT)
		angry_thing.ai_controller?.ai_interact(user, combat_mode = TRUE)
		user.apply_damage(35, BRUTE, forced = TRUE) // Mimics are not actually very strong so we pretend that it just bit us so we die faster, at least 3 charges & worn items should do it
		sleep(0.25 SECONDS)

	if (QDELETED(user))
		return MANUAL_SUICIDE
	if (user.stat == CONSCIOUS)
		return SHAME
	if (user.stat != DEAD)
		user.death() // If you got put into crit by the mobs we'll finish you off
	return MANUAL_SUICIDE

/// Heals people and even raises the dead
/obj/item/gun/magic/staff/healing
	name = "staff of healing"
	desc = "An artefact that spits bolts of restoring magic which can remove ailments of all kinds and even raise the dead."
	fire_sound = 'sound/effects/magic/staff_healing.ogg'
	ammo_type = /obj/item/ammo_casing/magic/heal
	icon_state = "staffofhealing"
	inhand_icon_state = "staffofhealing"
	school = SCHOOL_RESTORATION
	/// Our internal healbeam, used if an intruder (non-magic person) tries to use our staff
	var/obj/item/gun/medbeam/healing_beam

/obj/item/gun/magic/staff/healing/pickup(mob/user)
	. = ..()
	if(!is_wizard_or_friend(user))
		to_chat(user, span_hypnophrase("<span style='font-size: 24px'>The staff feels weaker as you touch it</span>"))
		user.balloon_alert(user, "the staff feels weaker as you touch it")

/obj/item/gun/magic/staff/healing/examine(mob/user)
	. = ..()
	if(!is_wizard_or_friend(user))
		. += span_notice("On the handle you notice a beautiful engraving in High Spaceman, \"Thou shalt not crosseth thy beams.\"")

/obj/item/gun/magic/staff/healing/Initialize(mapload)
	. = ..()
	healing_beam = new(src)
	healing_beam.mounted = TRUE

/obj/item/gun/magic/staff/healing/Destroy()
	QDEL_NULL(healing_beam)
	return ..()

/obj/item/gun/magic/staff/healing/unrestricted
	allow_intruder_use = TRUE

/obj/item/gun/magic/staff/healing/on_intruder_use(mob/living/user, atom/target)
	if(target == user)
		return FALSE
	healing_beam.process_fire(target, user)
	return FALSE

/obj/item/gun/magic/staff/healing/dropped(mob/user)
	healing_beam.LoseTarget()
	return ..()

/obj/item/gun/magic/staff/healing/handle_suicide(mob/living/carbon/human/user, mob/living/carbon/human/target, params, bypass_timer)
	return //Stops people clicking on themselves for self-healing

/obj/item/gun/magic/staff/healing/do_suicide(mob/living/user)
	playsound(loc, fire_sound, 50, TRUE, -1)
	if(user.mob_biotypes & MOB_UNDEAD)
		user.dust(drop_items = TRUE)
		return MANUAL_SUICIDE
	user.visible_message(span_suicide("...but nothing happens."))
	return SHAME

/// Does random shit when fired
/obj/item/gun/magic/staff/chaos
	name = "staff of chaos"
	desc = "An artefact that spits bolts of chaotic magic that can potentially do anything."
	fire_sound = 'sound/effects/magic/staff_chaos.ogg'
	ammo_type = /obj/item/ammo_casing/magic/chaos
	icon_state = "staffofchaos"
	inhand_icon_state = "staffofchaos"
	max_charges = 10
	recharge_rate = 2
	no_den_usage = TRUE
	school = SCHOOL_FORBIDDEN //this staff is evil. okay? it just is. look at this projectile type list. this is wrong.

	/// List of all projectiles we can fire from our staff.
	/// Doesn't contain all subtypes of magic projectiles, unlike what it looks like
	var/list/allowed_projectile_types = list(
		/obj/projectile/magic/animate,
		/obj/projectile/magic/antimagic,
		/obj/projectile/magic/arcane_barrage,
		/obj/projectile/magic/bounty,
		/obj/projectile/magic/change,
		/obj/projectile/magic/death,
		/obj/projectile/magic/door,
		/obj/projectile/magic/fetch,
		/obj/projectile/magic/fireball,
		/obj/projectile/magic/flying,
		/obj/projectile/magic/locker,
		/obj/projectile/magic/necropotence,
		/obj/projectile/magic/resurrection,
		/obj/projectile/magic/babel,
		/obj/projectile/magic/spellblade,
		/obj/projectile/magic/teleport,
		/obj/projectile/magic/wipe,
		/obj/projectile/temp/chill,
		/obj/projectile/magic/shrink
	)

/obj/item/gun/magic/staff/chaos/unrestricted
	allow_intruder_use = TRUE

/obj/item/gun/magic/staff/chaos/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	chambered.projectile_type = pick(allowed_projectile_types)
	return ..()

/obj/item/gun/magic/staff/chaos/on_intruder_use(mob/living/user)
	if(!user.can_cast_magic()) // Don't let people with antimagic use the staff of chaos.
		balloon_alert(user, "the staff refuses to fire!")
		return FALSE

	if(prob(95)) // You have a 5% chance of hitting yourself when using the staff of chaos.
		return TRUE
	balloon_alert(user, "chaos!")
	user.dropItemToGround(src, TRUE)
	process_fire(user, user, FALSE)
	return FALSE

/obj/item/gun/magic/staff/chaos/do_suicide(mob/living/user)
	charges++ // We already subtracted one
	for (var/i in 1 to 5)
		if (!charges || user.stat == DEAD || QDELETED(user))
			break
		playsound(loc, fire_sound, 50, TRUE, -1)
		process_fire(user, user, FALSE)
		charges--
		sleep(0.25 SECONDS)

	return FIRELOSS

/**
 * Staff of chaos given to the wizard upon completing a cheesy grand ritual. Is completely evil and if something
 * breaks, it's completely intended. Fuck off.
 * Also can be used by everyone, because why not.
 */
/obj/item/gun/magic/staff/chaos/true_wabbajack
	name = "\proper Wabbajack"
	desc = "If there is some deity out there, they've definitely skipped their psych appointment before creating this."
	icon_state = "the_wabbajack"
	inhand_icon_state = "the_wabbajack"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF //fuck you
	max_charges = 999999 //fuck you
	recharge_rate = 1
	allow_intruder_use = TRUE

/obj/item/gun/magic/staff/chaos/true_wabbajack/Initialize(mapload)
	. = ..()
	allowed_projectile_types |= subtypesof(/obj/projectile/bullet/cannonball)
	allowed_projectile_types |= subtypesof(/obj/projectile/bullet/rocket)
	allowed_projectile_types |= subtypesof(/obj/projectile/energy/tesla)
	allowed_projectile_types |= subtypesof(/obj/projectile/magic)
	allowed_projectile_types |= subtypesof(/obj/projectile/temp)
	allowed_projectile_types |= list(
		/obj/projectile/beam/mindflayer,
		/obj/projectile/bullet/gyro,
		/obj/projectile/bullet/honker,
		/obj/projectile/bullet/mime,
		/obj/projectile/curse_hand,
		/obj/projectile/energy/electrode,
		/obj/projectile/energy/nuclear_particle,
		/obj/projectile/gravityattract,
		/obj/projectile/gravitychaos,
		/obj/projectile/gravityrepulse,
		/obj/projectile/ion,
		/obj/projectile/meteor,
		/obj/projectile/neurotoxin,
		/obj/projectile/plasma,
	) //if you ever try to expand this list, avoid adding bullets/energy projectiles, this ain't supposed to be a gun... unless it's funny

/// Creates and opens doors
/obj/item/gun/magic/staff/door
	name = "staff of door creation"
	desc = "An artefact that spits bolts of transformative magic that can create doors in walls."
	fire_sound = 'sound/effects/magic/staff_door.ogg'
	ammo_type = /obj/item/ammo_casing/magic/door
	icon_state = "staffofdoor"
	inhand_icon_state = "staffofdoor"
	max_charges = 10
	recharge_rate = 2
	no_den_usage = TRUE
	school = SCHOOL_TRANSMUTATION

/obj/item/gun/magic/staff/door/do_suicide(mob/living/user)
	. = ..()
	var/obj/machinery/door/airlock/material/door = new(user.drop_location())
	door.set_custom_materials(list(GET_MATERIAL_REF(/datum/material/meat) = SHEET_MATERIAL_AMOUNT))
	door.update_appearance(updates = UPDATE_ICON)
	door.name = user.real_name
	addtimer(CALLBACK(door, TYPE_PROC_REF(/obj/machinery/door, open)), 1.5 SECONDS)
	user.drop_everything()
	user.ghostize()
	qdel(user)
	return MANUAL_SUICIDE

/// Makes people slip really hard
/obj/item/gun/magic/staff/honk
	name = "staff of the honkmother"
	desc = "Honk."
	fire_sound = 'sound/items/airhorn/airhorn.ogg'
	ammo_type = /obj/item/ammo_casing/magic/honk
	icon_state = "honker"
	inhand_icon_state = "honker"
	max_charges = 4
	recharge_rate = 8
	school = SCHOOL_EVOCATION

/obj/item/gun/magic/staff/honk/do_suicide(mob/living/user)
	. = ..()
	new /obj/effect/decal/cleanable/food/pie_smudge(user.drop_location())
	user.AddComponent(\
		/datum/component/face_decal/splat,\
		icon_state = "creampie",\
		layers = EXTERNAL_FRONT,\
	)
	return SHAME

/// Dismembers people, and is a passable melee weapon
/obj/item/gun/magic/staff/spellblade
	name = "spellblade"
	desc = "A deadly combination of laziness and bloodlust, this blade allows the user to dismember their enemies without all the hard work of actually swinging the sword."
	fire_sound = 'sound/effects/magic/fireball.ogg'
	ammo_type = /obj/item/ammo_casing/magic/spellblade
	icon_state = "spellblade"
	inhand_icon_state = "spellblade"
	icon_angle = -45
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = 'sound/items/weapons/rapierhit.ogg'
	block_sound = 'sound/items/weapons/parry.ogg'
	force = 20
	armour_penetration = 75
	block_chance = 50
	sharpness = SHARP_EDGED
	max_charges = 4
	school = SCHOOL_EVOCATION

/obj/item/gun/magic/staff/spellblade/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
		speed = 1.5 SECONDS, \
		effectiveness = 125, \
		bonus_modifier = 0, \
		butcher_sound = hitsound, \
	)

/obj/item/gun/magic/staff/spellblade/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	if(attack_type == PROJECTILE_ATTACK || attack_type == LEAP_ATTACK || attack_type == OVERWHELMING_ATTACK)
		final_block_chance = 0 //Don't bring a sword to a gunfight, and also you aren't going to really block someone full body tackling you with a sword. Or a road roller, if one happened to hit you.
	return ..()

/obj/item/gun/magic/staff/spellblade/do_suicide(mob/living/user)
	. = ..()
	if (!iscarbon(user))
		return BRUTELOSS
	var/mob/living/carbon/suicider = user
	for (var/obj/item/bodypart/limb in suicider.bodyparts)
		limb.dismember(BRUTE, silent = FALSE, wounding_type = WOUND_SLASH)
		sleep(0.25 SECONDS)

	return BRUTELOSS

/// Welds people into flying lockers
/obj/item/gun/magic/staff/locker
	name = "staff of the locker"
	desc = "An artefact that expels encapsulating bolts, for incapacitating thy enemy."
	fire_sound = 'sound/effects/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/locker
	icon_state = "locker"
	inhand_icon_state = "locker"
	worn_icon_state = "lockerstaff"
	max_charges = 6
	recharge_rate = 4
	school = SCHOOL_TRANSMUTATION //in a way

/obj/item/gun/magic/staff/locker/do_suicide(mob/living/user)
	. = ..()
	var/obj/structure/closet/decay/locker = new(user.drop_location())
	locker.insert(user)
	locker.welded = TRUE
	locker.update_appearance(UPDATE_ICON_STATE)
	return BRUTELOSS

/// Makes targets "fly" by throwing them away
/obj/item/gun/magic/staff/flying
	name = "staff of flying"
	desc = "An artefact that spits bolts of graceful magic that can make something fly."
	fire_sound = 'sound/effects/magic/staff_healing.ogg'
	ammo_type = /obj/item/ammo_casing/magic/flying
	icon_state = "staffofflight"
	inhand_icon_state = "staffofchange"
	worn_icon_state = "flightstaff"
	school = SCHOOL_EVOCATION

/obj/item/gun/magic/staff/flying/do_suicide(mob/living/user)
	. = ..()
	var/atom/throw_target = get_edge_target_turf(user, pick(GLOB.alldirs))
	user.throw_at(throw_target, 200, 4)
	return BRUTELOSS

/// Scrambles languages
/obj/item/gun/magic/staff/babel
	name = "staff of babel"
	desc = "An artefact that spits bolts of confusion magic that can make something depressed and incoherent."
	fire_sound = 'sound/effects/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/babel
	icon_state = "staffofbabel"
	inhand_icon_state = "staffofdoor"
	worn_icon_state = "babelstaff"
	school = SCHOOL_FORBIDDEN //evil

/obj/item/gun/magic/staff/babel/do_suicide(mob/living/user)
	. = ..()
	process_fire(user, user, FALSE)
	user.say("I wish I was dead.", forced = "failed babel staff suicide")
	return SHAME

/// Deals damage to the target and recharges their spells if they have any
/obj/item/gun/magic/staff/necropotence
	name = "staff of necropotence"
	desc = "An artefact that spits bolts of death magic that can repurpose the soul."
	fire_sound = 'sound/effects/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/necropotence
	icon_state = "staffofnecropotence"
	inhand_icon_state = "staffofchaos"
	worn_icon_state = "necrostaff"
	school = SCHOOL_NECROMANCY //REALLY evil

/obj/item/gun/magic/staff/necropotence/do_suicide(mob/living/user)
	. = ..()
	user.unequip_everything()
	var/obj/item/soulstone/anybody/stone = new(user.drop_location())
	stone.capture_soul(user, user = null, forced = TRUE)
	user.death()
	return MANUAL_SUICIDE

/// Asks a ghost to start playing as the poor victim
/obj/item/gun/magic/staff/wipe
	name = "staff of possession"
	desc = "An artefact that spits bolts of mind-unlocking magic that can let ghosts invade the victim's mind."
	fire_sound = 'sound/effects/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/wipe
	icon_state = "staffofwipe"
	inhand_icon_state = "pharoah_sceptre"
	worn_icon_state = "wipestaff"
	school = SCHOOL_FORBIDDEN //arguably the worst staff in the entire game effect wise

/obj/item/gun/magic/staff/wipe/do_suicide(mob/living/user)
	. = ..()
	process_fire(user, user, FALSE)
	return MANUAL_SUICIDE_NONLETHAL // Someone else is you now

/// Makes the target really small
/obj/item/gun/magic/staff/shrink
	name = "staff of shrinking"
	desc = "An artefact that spits bolts of tiny magic that makes things small. It's easily mistaken for a wand."
	fire_sound = 'sound/effects/magic/staff_shrink.ogg'
	ammo_type = /obj/item/ammo_casing/magic/shrink
	icon_state = "shrinkstaff"
	inhand_icon_state = "staff"
	max_charges = 10 // slightly more/faster charges since this will be used on walls and such
	recharge_rate = 5
	no_den_usage = TRUE
	school = SCHOOL_TRANSMUTATION
	slot_flags = NONE //too small to wear on your back
	w_class = WEIGHT_CLASS_NORMAL //but small enough for a bag

/obj/item/gun/magic/staff/shrink/do_suicide(mob/living/user)
	. = ..()
	playsound(user, fire_sound, 50, TRUE)
	user.unequip_everything()
	user.visible_message(span_suicide("[user] shrinks into nothing!"), span_suicide("You shrink into nothing!"))
	user.Stun(20 SECONDS, ignore_canstun = TRUE)
	user.set_suicide(TRUE)
	user.ghostize()
	animate(user, transform = matrix() * 0, time = 1 SECONDS)
	QDEL_IN(user, 1 SECONDS)
	return MANUAL_SUICIDE
