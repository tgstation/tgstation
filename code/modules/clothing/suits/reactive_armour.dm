/obj/item/reactive_armour_shell
	name = "reactive armour shell"
	desc = "An experimental suit of armour, awaiting installation of an anomaly core."
	icon_state = "reactiveoff"
	icon = 'icons/obj/clothing/suits.dmi'
	w_class = WEIGHT_CLASS_BULKY

/obj/item/reactive_armour_shell/attackby(obj/item/I, mob/user, params)
	..()
	var/static/list/anomaly_armour_types = list(
		/obj/effect/anomaly/grav	                = /obj/item/clothing/suit/armor/reactive/repulse,
		/obj/effect/anomaly/flux 	           		= /obj/item/clothing/suit/armor/reactive/tesla,
		/obj/effect/anomaly/bluespace 	            = /obj/item/clothing/suit/armor/reactive/teleport
		)

	if(istype(I, /obj/item/assembly/signaler/anomaly))
		var/obj/item/assembly/signaler/anomaly/A = I
		var/armour_path = anomaly_armour_types[A.anomaly_type]
		if(!armour_path)
			armour_path = /obj/item/clothing/suit/armor/reactive/stealth //Lets not cheat the player if an anomaly type doesnt have its own armour coded
		to_chat(user, "<span class='notice'>You insert [A] into the chest plate, and the armour gently hums to life.</span>")
		new armour_path(get_turf(src))
		qdel(src)
		qdel(A)

//Reactive armor
/obj/item/clothing/suit/armor/reactive
	name = "reactive armor"
	desc = "Doesn't seem to do much for some reason."
	///Whether the armor will try to react to hits (is it on)
	var/active = FALSE
	///This will be true for 30 seconds after an EMP, it makes the reaction effect dangerous to the user.
	var/bad_effect = FALSE
	///Message sent when the armor is emp'd. It is not the message for when the emp effect goes off.
	var/emp_message = "<span class='warning'>The reactive armor has been emp'd! Damn, now it's REALLY gonna not do much!</span>"
	///Message sent when the armor is still on cooldown, but activates.
	var/cooldown_message = "<span class='danger'>The reactive armor fails to do much, as it is recharging! From what? Only the reactive armor knows.</span>"
	///Duration of the cooldown specific to reactive armor for when it can activate again.
	var/reactivearmor_cooldown_duration = 0
	///The cooldown itself of the reactive armor for when it can activate again.
	var/reactivearmor_cooldown = 0
	icon_state = "reactiveoff"
	inhand_icon_state = "reactiveoff"
	blood_overlay_type = "armor"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)
	actions_types = list(/datum/action/item_action/toggle)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	hit_reaction_chance = 50

/obj/item/clothing/suit/armor/reactive/attack_self(mob/user)
	active = !(active)
	if(active)
		to_chat(user, "<span class='notice'>[src] is now active.</span>")
		icon_state = "reactive"
		inhand_icon_state = "reactive"
	else
		to_chat(user, "<span class='notice'>[src] is now inactive.</span>")
		icon_state = "reactiveoff"
		inhand_icon_state = "reactiveoff"
	add_fingerprint(user)
	return

/obj/item/clothing/suit/armor/reactive/hit_reaction(owner, hitby, attack_text, final_block_chance, damage, attack_type)
	if(!active || !prob(hit_reaction_chance))
		return FALSE
	if(world.time < reactivearmor_cooldown)
		cooldown_activation(owner)
		return FALSE
	if(bad_effect)
		. = emp_activation(owner, hitby, attack_text, final_block_chance, damage, attack_type)
	else
		. = reactive_activation(owner, hitby, attack_text, final_block_chance, damage, attack_type)

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
	owner.visible_message("<span class='danger'>The reactive armor doesn't do much! No surprises here.</span>")
	return TRUE

/**
 * A proc for doing owner unfriendly reactive armor effects.
 * Called from the suit activating while off cooldown, while the armor is still suffering from the effect of an EMP.
 * Returning TRUE will block the attack that triggered this
 */
/obj/item/clothing/suit/armor/reactive/proc/emp_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message("<span class='danger'>The reactive armor doesn't do much, despite being emp'd! Besides giving off a special message, of course.</span>")
	return TRUE

/obj/item/clothing/suit/armor/reactive/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF || bad_effect) //didn't get hit or already emp'd
		return
	visible_message(emp_message)
	bad_effect = TRUE
	addtimer(VARSET_CALLBACK(src, bad_effect, FALSE), 30 SECONDS)

//When the wearer gets hit, this armor will teleport the user a short distance away (to safety or to more danger, no one knows. That's the fun of it!)
/obj/item/clothing/suit/armor/reactive/teleport
	name = "reactive teleport armor"
	desc = "Someone separated our Research Director from his own head!"
	emp_message = "<span class='warning'>The reactive armor's teleportation calculations begin spewing errors!</span>"
	var/tele_range = 6
	var/rad_amount= 15
	reactivearmor_cooldown_duration = 10 SECONDS

/obj/item/clothing/suit/armor/reactive/teleport/reactive_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message("<span class='danger'>The reactive teleport system flings [owner] clear of [attack_text], shutting itself off in the process!</span>")
	playsound(get_turf(owner),'sound/magic/blink.ogg', 100, TRUE)
	do_teleport(owner, get_turf(owner), tele_range, no_effects = TRUE, channel = TELEPORT_CHANNEL_BLUESPACE)
	owner.rad_act(rad_amount)
	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return TRUE

/obj/item/clothing/suit/armor/reactive/teleport/emp_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message("<span class='danger'>The reactive teleport system ALMOST flings [owner] clear of [attack_text], shutting itself off and leaving something behind in the process!</span>")
	var/drop_organ = prob(50)
	if(drop_organ)
		owner.spew_organ(0)
	else
		var/obj/item/bodypart/body_part = owner.get_bodypart(pick(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
		if(body_part)
			body_part.drop_limb(FALSE, TRUE)
	playsound(get_turf(owner),'sound/machines/buzz-sigh.ogg', 50, TRUE)
	playsound(get_turf(owner),'sound/magic/blink.ogg', 100, TRUE)
	do_teleport(owner, get_turf(owner), tele_range, no_effects = TRUE, channel = TELEPORT_CHANNEL_BLUESPACE)
	owner.rad_act(rad_amount)
	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return TRUE

//Fire

/obj/item/clothing/suit/armor/reactive/fire
	name = "reactive incendiary armor"
	desc = "An experimental suit of armor with a reactive sensor array rigged to a flame emitter. For the stylish pyromaniac."
	cooldown_message = "<span class='danger'>The reactive incendiary armor activates, but fails to send out flames as it is still recharging its flame jets!</span>"
	emp_message = "<span class='warning'>The reactive incendiary armor's targetting system begins rebooting...</span>"

/obj/item/clothing/suit/armor/reactive/fire/reactive_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message("<span class='danger'>[src] blocks [attack_text], sending out jets of flame!</span>")
	playsound(get_turf(owner),'sound/magic/fireball.ogg', 100, TRUE)
	for(var/mob/living/carbon/C in range(6, owner))
		if(C != owner)
			C.adjust_fire_stacks(8)
			C.IgniteMob()
	owner.set_fire_stacks(-20)
	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return TRUE

/obj/item/clothing/suit/armor/reactive/fire/emp_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message("<span class='danger'>[src] just makes [attack_text] worse, by spewing molten death on [owner]!</span>")
	playsound(get_turf(owner),'sound/magic/fireball.ogg', 100, TRUE)
	owner.adjust_fire_stacks(12)
	owner.IgniteMob()
	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return FALSE

//Stealth

/obj/item/clothing/suit/armor/reactive/stealth
	name = "reactive stealth armor"
	desc = "An experimental suit of armor that renders the wearer invisible on detection of imminent harm, and creates a decoy that runs away from the owner. You can't fight what you can't see."
	cooldown_message = "<span class='danger'>The reactive stealth system activates, but is not charged enough to fully cloak!</span>"
	emp_message = "<span class='warning'>The reactive stealth armor's threat assessment system crashes...</span>"

/obj/item/clothing/suit/armor/reactive/stealth/cooldown_activation(mob/living/carbon/human/owner)
	owner.alpha = max(0, owner.alpha - 50)
	animate(owner, alpha = initial(owner.alpha), time = 3 SECONDS)
	..()

/obj/item/clothing/suit/armor/reactive/stealth/reactive_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/mob/living/simple_animal/hostile/illusion/escape/E = new(owner.loc)
	E.Copy_Parent(owner, 50)
	E.GiveTarget(owner) //so it starts running right away
	E.Goto(owner, E.move_to_delay, E.minimum_distance)
	owner.alpha = 0
	owner.visible_message("<span class='danger'>[owner] is hit by [attack_text] in the chest!</span>") //We pretend to be hit, since blocking it would stop the message otherwise
	addtimer(VARSET_CALLBACK(owner, alpha, initial(owner.alpha)), 4 SECONDS)
	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return TRUE

/obj/item/clothing/suit/armor/reactive/stealth/emp_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!isliving(hitby))
		return FALSE //it just doesn't activate
	var/mob/living/attacker = hitby
	owner.visible_message("<span class='danger'>[src] activates, cloaking the wrong person!</span>")
	attacker.alpha = 0
	addtimer(VARSET_CALLBACK(attacker, alpha, initial(attacker.alpha)), 4 SECONDS)
	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return FALSE

//Tesla

/obj/item/clothing/suit/armor/reactive/tesla
	name = "reactive tesla armor"
	desc = "An experimental suit of armor with sensitive detectors hooked up to a huge capacitor grid, with emitters strutting out of it. Zap."
	siemens_coefficient = -1
	cooldown_message = "<span class='danger'>The tesla capacitors on the reactive tesla armor are still recharging! The armor merely emits some sparks.</span>"
	cooldown_message = "<span class='warning'>The tesla capacitors beep ominously for a moment.</span>"
	var/zap_power = 25000
	var/zap_range = 20
	var/zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE

/obj/item/clothing/suit/armor/reactive/tesla/dropped(mob/user)
	..()
	if(istype(user))
		ADD_TRAIT(user, TRAIT_TESLA_SHOCKIMMUNE, "reactive_tesla_armor")

/obj/item/clothing/suit/armor/reactive/tesla/equipped(mob/user, slot)
	..()
	if(slot_flags & slot) //Was equipped to a valid slot for this item?
		REMOVE_TRAIT(user, TRAIT_TESLA_SHOCKIMMUNE, "reactive_tesla_armor")

/obj/item/clothing/suit/armor/reactive/tesla/cooldown_activation(mob/living/carbon/human/owner)
	var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
	sparks.set_up(1, 1, src)
	sparks.start()
	..()

/obj/item/clothing/suit/armor/reactive/tesla/reactive_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message("<span class='danger'>[src] blocks [attack_text], sending out arcs of lightning!</span>")
	tesla_zap(owner, zap_range, zap_power, zap_flags)
	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return TRUE

/obj/item/clothing/suit/armor/reactive/tesla/emp_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message("<span class='danger'>[src] blocks [attack_text], but pulls a massive charge of energy into [owner] from the surrounding environment!</span>")
	REMOVE_TRAIT(owner, TRAIT_TESLA_SHOCKIMMUNE, "reactive_tesla_armor") //oops! can't shock without this!
	electrocute_mob(owner, get_area(src), src, 1)
	ADD_TRAIT(owner, TRAIT_TESLA_SHOCKIMMUNE, "reactive_tesla_armor")
	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return TRUE

//Repulse

/obj/item/clothing/suit/armor/reactive/repulse
	name = "reactive repulse armor"
	desc = "An experimental suit of armor that violently throws back attackers."
	cooldown_message = "<span class='danger'>The repulse generator is still recharging! It fails to generate a strong enough wave!</span>"
	emp_message = "<span class='warning'>The repulse generator is reset to default settings...</span>"
	var/repulse_force = MOVE_FORCE_EXTREMELY_STRONG

/obj/item/clothing/suit/armor/reactive/repulse/reactive_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	playsound(get_turf(owner),'sound/magic/repulse.ogg', 100, TRUE)
	owner.visible_message("<span class='danger'>[src] blocks [attack_text], converting the attack into a wave of force!</span>")
	var/turf/T = get_turf(owner)
	var/list/thrown_items = list()
	for(var/atom/movable/A in range(T, 7))
		if(A == owner || A.anchored || thrown_items[A])
			continue
		var/throwtarget = get_edge_target_turf(T, get_dir(T, get_step_away(A, T)))
		A.safe_throw_at(throwtarget, 10, 1, force = repulse_force)
		thrown_items[A] = A

	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return TRUE

/obj/item/clothing/suit/armor/reactive/repulse/emp_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	playsound(get_turf(owner),'sound/magic/repulse.ogg', 100, TRUE)
	owner.visible_message("<span class='danger'>[src] does not block [attack_text], instead generating an attracting force!</span>")
	var/turf/T = get_turf(owner)
	var/list/thrown_items = list()
	for(var/atom/movable/A in range(T, 7))
		if(A == owner || A.anchored || thrown_items[A])
			continue
		var/throwtarget = owner
		A.safe_throw_at(throwtarget, 10, 1, force = repulse_force)
		thrown_items[A] = A

	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return FALSE

/obj/item/clothing/suit/armor/reactive/table
	name = "reactive table armor"
	desc = "If you can't beat the memes, embrace them."
	cooldown_message = "<span class='danger'>The reactive table armor's fabricators are still on cooldown!</span>"
	emp_message = "<span class='danger'>The reactive table armor's fabricators click and whirr ominously for a moment...</span>"
	var/tele_range = 10

/obj/item/clothing/suit/armor/reactive/table/reactive_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message("<span class='danger'>The reactive teleport system flings [owner] clear of [attack_text] and slams [owner.p_them()] into a fabricated table!</span>")
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
	owner.visible_message("<span class='danger'>The reactive teleport system flings [owner] clear of [attack_text] and slams [owner.p_them()] into a fabricated glass table!</span>")
	owner.visible_message("<font color='red' size='3'>[owner] GOES ON THE GLASS TABLE!!!</font>")
	var/turf/T = get_turf(owner)
	do_teleport(owner, T, tele_range, no_effects = TRUE, channel = TELEPORT_CHANNEL_BLUESPACE)
	var/obj/structure/table/glass/shattering_table = new /obj/structure/table/glass(T)
	shattering_table.table_shatter(owner)

	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return TRUE


