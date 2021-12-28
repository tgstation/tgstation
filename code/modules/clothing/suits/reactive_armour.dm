/obj/item/reactive_armour_shell
	name = "reactive armour shell"
	desc = "An experimental suit of armour, awaiting installation of an anomaly core."
	icon_state = "reactiveoff"
	icon = 'icons/obj/clothing/suits.dmi'
	atom_size = WEIGHT_CLASS_BULKY

/obj/item/reactive_armour_shell/attackby(obj/item/weapon, mob/user, params)
	..()
	var/static/list/anomaly_armour_types = list(
		/obj/effect/anomaly/grav = /obj/item/clothing/suit/armor/reactive/repulse,
		/obj/effect/anomaly/flux = /obj/item/clothing/suit/armor/reactive/tesla,
		/obj/effect/anomaly/bluespace = /obj/item/clothing/suit/armor/reactive/teleport,
		)

	if(istype(weapon, /obj/item/assembly/signaler/anomaly))
		var/obj/item/assembly/signaler/anomaly/anomaly = weapon
		var/armour_path = anomaly_armour_types[anomaly.anomaly_type]
		if(!armour_path)
			armour_path = /obj/item/clothing/suit/armor/reactive/stealth //Lets not cheat the player if an anomaly type doesnt have its own armour coded
		to_chat(user, span_notice("You insert [anomaly] into the chest plate, and the armour gently hums to life."))
		new armour_path(get_turf(src))
		qdel(src)
		qdel(anomaly)

//Reactive armor
/obj/item/clothing/suit/armor/reactive
	name = "reactive armor"
	desc = "Doesn't seem to do much for some reason."
	icon_state = "reactiveoff"
	inhand_icon_state = "reactiveoff"
	blood_overlay_type = "armor"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 100, ACID = 100)
	actions_types = list(/datum/action/item_action/toggle)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	hit_reaction_chance = 50
	///Whether the armor will try to react to hits (is it on)
	var/active = FALSE
	///This will be true for 30 seconds after an EMP, it makes the reaction effect dangerous to the user.
	var/bad_effect = FALSE
	///Message sent when the armor is emp'd. It is not the message for when the emp effect goes off.
	var/emp_message = span_warning("The reactive armor has been emp'd! Damn, now it's REALLY gonna not do much!")
	///Message sent when the armor is still on cooldown, but activates.
	var/cooldown_message = span_danger("The reactive armor fails to do much, as it is recharging! From what? Only the reactive armor knows.")
	///Duration of the cooldown specific to reactive armor for when it can activate again.
	var/reactivearmor_cooldown_duration = 10 SECONDS
	///The cooldown itself of the reactive armor for when it can activate again.
	var/reactivearmor_cooldown = 0


/obj/item/clothing/suit/armor/reactive/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/clothing/suit/armor/reactive/update_icon_state()
	. = ..()
	if(active)
		icon_state = "reactive"
		inhand_icon_state = "reactive"
	else
		icon_state = "reactiveoff"
		inhand_icon_state = "reactiveoff"

/obj/item/clothing/suit/armor/reactive/attack_self(mob/user)
	active = !active
	to_chat(user, span_notice("[src] is now [active ? "active" : "inactive"]."))
	update_icon()
	add_fingerprint(user)

/obj/item/clothing/suit/armor/reactive/hit_reaction(owner, hitby, attack_text, final_block_chance, damage, attack_type)
	if(!active || !prob(hit_reaction_chance))
		return FALSE
	if(world.time < reactivearmor_cooldown)
		cooldown_activation(owner)
		return FALSE
	if(bad_effect)
		return emp_activation(owner, hitby, attack_text, final_block_chance, damage, attack_type)
	else
		return reactive_activation(owner, hitby, attack_text, final_block_chance, damage, attack_type)

/**
 * A proc for doing cooldown effects (like the sparks on the tesla armor, or the semi-stealth on stealth armor)
 * Called from the suit activating whilst on cooldown.
 * You should be calling ..()
 */
/obj/item/clothing/suit/armor/reactive/proc/cooldown_activation(mob/living/carbon/human/owner)
	owner.visible_message(cooldown_message)

/**
 * A proc for doing reactive armor effects.
 * Called from the suit activating while off cooldown, with no emp.
 * Returning TRUE will block the attack that triggered this
 */
/obj/item/clothing/suit/armor/reactive/proc/reactive_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("The reactive armor doesn't do much! No surprises here."))
	return TRUE

/**
 * A proc for doing owner unfriendly reactive armor effects.
 * Called from the suit activating while off cooldown, while the armor is still suffering from the effect of an EMP.
 * Returning TRUE will block the attack that triggered this
 */
/obj/item/clothing/suit/armor/reactive/proc/emp_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("The reactive armor doesn't do much, despite being emp'd! Besides giving off a special message, of course."))
	return TRUE

/obj/item/clothing/suit/armor/reactive/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF || bad_effect || !active) //didn't get hit or already emp'd, or off
		return
	visible_message(emp_message)
	bad_effect = TRUE
	addtimer(VARSET_CALLBACK(src, bad_effect, FALSE), 30 SECONDS)

//When the wearer gets hit, this armor will teleport the user a short distance away (to safety or to more danger, no one knows. That's the fun of it!)
/obj/item/clothing/suit/armor/reactive/teleport
	name = "reactive teleport armor"
	desc = "Someone separated our Research Director from his own head!"
	emp_message = span_warning("The reactive armor's teleportation calculations begin spewing errors!")
	cooldown_message = span_danger("The reactive teleport system is still recharging! It fails to activate!")
	reactivearmor_cooldown_duration = 10 SECONDS
	var/tele_range = 6

/obj/item/clothing/suit/armor/reactive/teleport/reactive_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("The reactive teleport system flings [owner] clear of [attack_text]!"))
	playsound(get_turf(owner),'sound/magic/blink.ogg', 100, TRUE)
	do_teleport(owner, get_turf(owner), tele_range, no_effects = TRUE, channel = TELEPORT_CHANNEL_BLUESPACE)
	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return TRUE

/obj/item/clothing/suit/armor/reactive/teleport/emp_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("The reactive teleport system flings itself clear of [attack_text], leaving someone behind in the process!"))
	owner.dropItemToGround(src, TRUE, TRUE)
	playsound(get_turf(owner),'sound/machines/buzz-sigh.ogg', 50, TRUE)
	playsound(get_turf(owner),'sound/magic/blink.ogg', 100, TRUE)
	do_teleport(src, get_turf(owner), tele_range, no_effects = TRUE, channel = TELEPORT_CHANNEL_BLUESPACE)
	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return FALSE //you didn't actually evade the attack now did you

//Fire

/obj/item/clothing/suit/armor/reactive/fire
	name = "reactive incendiary armor"
	desc = "An experimental suit of armor with a reactive sensor array rigged to a flame emitter. For the stylish pyromaniac."
	cooldown_message = span_danger("The reactive incendiary armor activates, but fails to send out flames as it is still recharging its flame jets!")
	emp_message = span_warning("The reactive incendiary armor's targeting system begins rebooting...")

/obj/item/clothing/suit/armor/reactive/fire/reactive_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("[src] blocks [attack_text], sending out jets of flame!"))
	playsound(get_turf(owner),'sound/magic/fireball.ogg', 100, TRUE)
	for(var/mob/living/carbon/carbon_victim in range(6, owner))
		if(carbon_victim != owner)
			carbon_victim.adjust_fire_stacks(8)
			carbon_victim.IgniteMob()
	owner.set_fire_stacks(-20)
	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return TRUE

/obj/item/clothing/suit/armor/reactive/fire/emp_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("[src] just makes [attack_text] worse by spewing molten death on [owner]!"))
	playsound(get_turf(owner),'sound/magic/fireball.ogg', 100, TRUE)
	owner.adjust_fire_stacks(12)
	owner.IgniteMob()
	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return FALSE

//Stealth

/obj/item/clothing/suit/armor/reactive/stealth
	name = "reactive stealth armor"
	desc = "An experimental suit of armor that renders the wearer invisible on detection of imminent harm, and creates a decoy that runs away from the owner. You can't fight what you can't see."
	cooldown_message = span_danger("The reactive stealth system activates, but is not charged enough to fully cloak!")
	emp_message = span_warning("The reactive stealth armor's threat assessment system crashes...")
	///when triggering while on cooldown will only flicker the alpha slightly. this is how much it removes.
	var/cooldown_alpha_removal = 50
	///cooldown alpha flicker- how long it takes to return to the original alpha
	var/cooldown_animation_time = 3 SECONDS
	///how long they will be fully stealthed
	var/stealth_time = 4 SECONDS
	///how long it will animate back the alpha to the original
	var/animation_time = 2 SECONDS
	var/in_stealth = FALSE

/obj/item/clothing/suit/armor/reactive/stealth/cooldown_activation(mob/living/carbon/human/owner)
	if(in_stealth)
		return //we don't want the cooldown message either)
	owner.alpha = max(0, owner.alpha - cooldown_alpha_removal)
	animate(owner, alpha = initial(owner.alpha), time = cooldown_animation_time)
	..()

/obj/item/clothing/suit/armor/reactive/stealth/reactive_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/mob/living/simple_animal/hostile/illusion/escape/decoy = new(owner.loc)
	decoy.Copy_Parent(owner, 50)
	decoy.GiveTarget(owner) //so it starts running right away
	decoy.Goto(owner, decoy.move_to_delay, decoy.minimum_distance)
	owner.alpha = 0
	in_stealth = TRUE
	owner.visible_message(span_danger("[owner] is hit by [attack_text] in the chest!")) //We pretend to be hit, since blocking it would stop the message otherwise
	addtimer(CALLBACK(src, .proc/end_stealth, owner), stealth_time)
	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return TRUE

/obj/item/clothing/suit/armor/reactive/stealth/proc/end_stealth(mob/living/carbon/human/owner)
	in_stealth = FALSE
	animate(owner, alpha = initial(owner.alpha), time = animation_time)

/obj/item/clothing/suit/armor/reactive/stealth/emp_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!isliving(hitby))
		return FALSE //it just doesn't activate
	var/mob/living/attacker = hitby
	owner.visible_message(span_danger("[src] activates, cloaking the wrong person!"))
	attacker.alpha = 0
	addtimer(VARSET_CALLBACK(attacker, alpha, initial(attacker.alpha)), 4 SECONDS)
	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return FALSE

//Tesla

/obj/item/clothing/suit/armor/reactive/tesla
	name = "reactive tesla armor"
	desc = "An experimental suit of armor with sensitive detectors hooked up to a huge capacitor grid, with emitters strutting out of it. Zap."
	siemens_coefficient = -1
	cooldown_message = span_danger("The tesla capacitors on the reactive tesla armor are still recharging! The armor merely emits some sparks.")
	emp_message = span_warning("The tesla capacitors beep ominously for a moment.")
	var/zap_power = 25000
	var/zap_range = 20
	var/zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE

/obj/item/clothing/suit/armor/reactive/tesla/dropped(mob/user)
	..()
	if(istype(user))
		REMOVE_TRAIT(user, TRAIT_TESLA_SHOCKIMMUNE, "reactive_tesla_armor")

/obj/item/clothing/suit/armor/reactive/tesla/equipped(mob/user, slot)
	..()
	if(slot_flags & slot) //Was equipped to a valid slot for this item?
		ADD_TRAIT(user, TRAIT_TESLA_SHOCKIMMUNE, "reactive_tesla_armor")

/obj/item/clothing/suit/armor/reactive/tesla/cooldown_activation(mob/living/carbon/human/owner)
	var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
	sparks.set_up(1, 1, src)
	sparks.start()
	..()

/obj/item/clothing/suit/armor/reactive/tesla/reactive_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("[src] blocks [attack_text], sending out arcs of lightning!"))
	tesla_zap(owner, zap_range, zap_power, zap_flags)
	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return TRUE

/obj/item/clothing/suit/armor/reactive/tesla/emp_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("[src] blocks [attack_text], but pulls a massive charge of energy into [owner] from the surrounding environment!"))
	REMOVE_TRAIT(owner, TRAIT_TESLA_SHOCKIMMUNE, "reactive_tesla_armor") //oops! can't shock without this!
	electrocute_mob(owner, get_area(src), src, 1)
	ADD_TRAIT(owner, TRAIT_TESLA_SHOCKIMMUNE, "reactive_tesla_armor")
	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return TRUE

//Repulse

/obj/item/clothing/suit/armor/reactive/repulse
	name = "reactive repulse armor"
	desc = "An experimental suit of armor that violently throws back attackers."
	cooldown_message = span_danger("The repulse generator is still recharging! It fails to generate a strong enough wave!")
	emp_message = span_warning("The repulse generator is reset to default settings...")
	var/repulse_force = MOVE_FORCE_EXTREMELY_STRONG

/obj/item/clothing/suit/armor/reactive/repulse/reactive_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	playsound(get_turf(owner),'sound/magic/repulse.ogg', 100, TRUE)
	owner.visible_message(span_danger("[src] blocks [attack_text], converting the attack into a wave of force!"))
	var/turf/owner_turf = get_turf(owner)
	var/list/thrown_items = list()
	for(var/atom/movable/repulsed in range(owner_turf, 7))
		if(repulsed == owner || repulsed.anchored || thrown_items[repulsed])
			continue
		var/throwtarget = get_edge_target_turf(owner_turf, get_dir(owner_turf, get_step_away(repulsed, owner_turf)))
		repulsed.safe_throw_at(throwtarget, 10, 1, force = repulse_force)
		thrown_items[repulsed] = repulsed

	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return TRUE

/obj/item/clothing/suit/armor/reactive/repulse/emp_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	playsound(get_turf(owner),'sound/magic/repulse.ogg', 100, TRUE)
	owner.visible_message(span_danger("[src] does not block [attack_text], and instead generates an attracting force!"))
	var/turf/owner_turf = get_turf(owner)
	var/list/thrown_items = list()
	for(var/atom/movable/repulsed in range(owner_turf, 7))
		if(repulsed == owner || repulsed.anchored || thrown_items[repulsed])
			continue
		repulsed.safe_throw_at(owner, 10, 1, force = repulse_force)
		thrown_items[repulsed] = repulsed

	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return FALSE

/obj/item/clothing/suit/armor/reactive/table
	name = "reactive table armor"
	desc = "If you can't beat the memes, embrace them."
	cooldown_message = span_danger("The reactive table armor's fabricators are still on cooldown!")
	emp_message = span_danger("The reactive table armor's fabricators click and whirr ominously for a moment...")
	var/tele_range = 10

/obj/item/clothing/suit/armor/reactive/table/reactive_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("The reactive teleport system flings [owner] clear of [attack_text] and slams [owner.p_them()] into a fabricated table!"))
	owner.visible_message("<font color='red' size='3'>[owner] GOES ON THE TABLE!!!</font>")
	owner.Knockdown(30)
	owner.apply_damage(10, BRUTE)
	owner.apply_damage(40, STAMINA)
	playsound(owner, 'sound/effects/tableslam.ogg', 90, TRUE)
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "table", /datum/mood_event/table)
	do_teleport(owner, get_turf(owner), tele_range, no_effects = TRUE, channel = TELEPORT_CHANNEL_BLUESPACE)
	new /obj/structure/table(get_turf(owner))
	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return TRUE

/obj/item/clothing/suit/armor/reactive/table/emp_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("The reactive teleport system flings [owner] clear of [attack_text] and slams [owner.p_them()] into a fabricated glass table!"))
	owner.visible_message("<font color='red' size='3'>[owner] GOES ON THE GLASS TABLE!!!</font>")
	do_teleport(owner, get_turf(owner), tele_range, no_effects = TRUE, channel = TELEPORT_CHANNEL_BLUESPACE)
	var/obj/structure/table/glass/shattering_table = new /obj/structure/table/glass(get_turf(owner))
	shattering_table.table_shatter(owner)

	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return TRUE
