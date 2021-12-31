/**
 * Base class for all grenades.
 */
/obj/item/grenade
	name = "grenade"
	desc = "It has an adjustable timer."
	atom_size = ITEM_SIZE_SMALL
	icon = 'icons/obj/grenade.dmi'
	icon_state = "grenade"
	inhand_icon_state = "flashbang"
	worn_icon_state = "grenade"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	throw_speed = 3
	throw_range = 7
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	resistance_flags = FLAMMABLE
	max_integrity = 40
	///Is this grenade currently armed?
	var/active = FALSE
	///How long it takes for a grenade to explode after being armed
	var/det_time = 5 SECONDS
	///Will this state what it's det_time is when examined?
	var/display_timer = TRUE
	///Used in botch_check to determine how a user's clumsiness affects that user's ability to prime a grenade correctly.
	var/clumsy_check = GRENADE_CLUMSY_FUMBLE
	///Was sticky tape used to make this sticky?
	var/sticky = FALSE
	// I moved the explosion vars and behavior to base grenades because we want all grenades to call [/obj/item/grenade/proc/detonate] so we can send COMSIG_GRENADE_DETONATE
	///how big of a devastation explosion radius on prime
	var/ex_dev = 0
	///how big of a heavy explosion radius on prime
	var/ex_heavy = 0
	///how big of a light explosion radius on prime
	var/ex_light = 0
	///how big of a flame explosion radius on prime
	var/ex_flame = 0

	// dealing with creating a [/datum/component/pellet_cloud] on detonate
	/// if set, will spew out projectiles of this type
	var/shrapnel_type
	/// the higher this number, the more projectiles are created as shrapnel
	var/shrapnel_radius
	///Did we add the component responsible for spawning sharpnel to this?
	var/shrapnel_initialized

/obj/item/grenade/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] primes [src], then eats it! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(src, 'sound/items/eatfood.ogg', 50, TRUE)
	arm_grenade(user, det_time)
	user.transferItemToLoc(src, user, TRUE)//>eat a grenade set to 5 seconds >rush captain
	sleep(det_time)//so you dont die instantly
	return BRUTELOSS

/obj/item/grenade/deconstruct(disassembled = TRUE)
	if(!disassembled)
		detonate()
	if(!QDELETED(src))
		qdel(src)

/**
 * Checks for various ways to botch priming a grenade.
 *
 * Arguments:
 * * mob/living/carbon/human/user - who is priming our grenade?
 */
/obj/item/grenade/proc/botch_check(mob/living/carbon/human/user)
	if(sticky && prob(50)) // to add risk to sticky tape grenade cheese, no return cause we still prime as normal after.
		to_chat(user, span_warning("What the... [src] is stuck to your hand!"))
		ADD_TRAIT(src, TRAIT_NODROP, STICKY_NODROP)

	var/clumsy = HAS_TRAIT(user, TRAIT_CLUMSY)
	if(clumsy && (clumsy_check == GRENADE_CLUMSY_FUMBLE) && prob(50))
		to_chat(user, span_warning("Huh? How does this thing work?"))
		arm_grenade(user, 5, FALSE)
		return TRUE
	else if(!clumsy && (clumsy_check == GRENADE_NONCLUMSY_FUMBLE))
		to_chat(user, span_warning("You pull the pin on [src]. Attached to it is a pink ribbon that says, \"[span_clown("HONK")]\""))
		arm_grenade(user, 5, FALSE)
		return TRUE

/obj/item/grenade/examine(mob/user)
	. = ..()
	if(display_timer)
		if(det_time > 0)
			. += "The timer is set to [DisplayTimeText(det_time)]."
		else
			. += "\The [src] is set for instant detonation."

/obj/item/grenade/attack_self(mob/user)
	if(HAS_TRAIT(src, TRAIT_NODROP))
		to_chat(user, span_notice("You try prying [src] off your hand..."))
		if(do_after(user, 7 SECONDS, target = src))
			to_chat(user, span_notice("You manage to remove [src] from your hand."))
			REMOVE_TRAIT(src, TRAIT_NODROP, STICKY_NODROP)
		return

	if(!active)
		if(!botch_check(user)) // if they botch the prime, it'll be handled in botch_check
			arm_grenade(user)

/obj/item/grenade/proc/log_grenade(mob/user)
	log_bomber(user, "has primed a", src, "for detonation")

/**
 * arm_grenade (formerly preprime) refers to when a grenade with a standard time fuze is activated, making it go beepbeepbeep and then detonate a few seconds later.
 * Grenades with other triggers like remote igniters probably skip this step and go straight to [/obj/item/grenade/proc/detonate]
 */
/obj/item/grenade/proc/arm_grenade(mob/user, delayoverride, msg = TRUE, volume = 60)
	log_grenade(user) //Inbuilt admin procs already handle null users
	if(user)
		add_fingerprint(user)
		if(msg)
			to_chat(user, span_warning("You prime [src]! [capitalize(DisplayTimeText(det_time))]!"))
	if(shrapnel_type && shrapnel_radius)
		shrapnel_initialized = TRUE
		AddComponent(/datum/component/pellet_cloud, projectile_type = shrapnel_type, magnitude = shrapnel_radius)
	playsound(src, 'sound/weapons/armbomb.ogg', volume, TRUE)
	if(istype(user))
		user.mind?.add_memory(MEMORY_BOMB_PRIMED, list(DETAIL_BOMB_TYPE = src), story_value = STORY_VALUE_OKAY)
	active = TRUE
	icon_state = initial(icon_state) + "_active"
	SEND_SIGNAL(src, COMSIG_GRENADE_ARMED, det_time, delayoverride)
	addtimer(CALLBACK(src, .proc/detonate), isnull(delayoverride)? det_time : delayoverride)

/**
 * detonate (formerly prime) refers to when the grenade actually delivers its payload (whether or not a boom/bang/detonation is involved)
 *
 * Arguments:
 * * lanced_by- If this grenade was detonated by an elance, we need to pass that along with the COMSIG_GRENADE_DETONATE signal for pellet clouds
 */
/obj/item/grenade/proc/detonate(mob/living/lanced_by)
	if(shrapnel_type && shrapnel_radius && !shrapnel_initialized) // add a second check for adding the component in case whatever triggered the grenade went straight to prime (badminnery for example)
		shrapnel_initialized = TRUE
		AddComponent(/datum/component/pellet_cloud, projectile_type = shrapnel_type, magnitude = shrapnel_radius)

	SEND_SIGNAL(src, COMSIG_GRENADE_DETONATE, lanced_by)
	if(ex_dev || ex_heavy || ex_light || ex_flame)
		explosion(src, ex_dev, ex_heavy, ex_light, ex_flame)

/obj/item/grenade/proc/update_mob()
	if(ismob(loc))
		var/mob/mob = loc
		mob.dropItemToGround(src)

/obj/item/grenade/attackby(obj/item/weapon, mob/user, params)
	if(active)
		return ..()

	if(weapon.tool_behaviour == TOOL_MULTITOOL)
		var/newtime = tgui_input_list(user, "Please enter a new detonation time", "Detonation Timer", list("Instant", 3, 4, 5))
		if (isnull(newtime))
			return
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		if(newtime == "Instant" && change_det_time(0))
			to_chat(user, span_notice("You modify the time delay. It's set to be instantaneous."))
			return
		newtime = round(newtime)
		if(change_det_time(newtime))
			to_chat(user, span_notice("You modify the time delay. It's set for [DisplayTimeText(det_time)]."))
		return
	else if(weapon.tool_behaviour == TOOL_SCREWDRIVER)
		if(change_det_time())
			to_chat(user, span_notice("You modify the time delay. It's set for [DisplayTimeText(det_time)]."))

/obj/item/grenade/proc/change_det_time(time) //Time uses real time.
	. = TRUE
	if(!isnull(time))
		det_time = round(clamp(time * 10, 0, 5 SECONDS))
	else
		var/previous_time = det_time
		switch(det_time)
			if (0)
				det_time = 3 SECONDS
			if (3 SECONDS)
				det_time = 5 SECONDS
			if (5 SECONDS)
				det_time = 0
		if(det_time == previous_time)
			det_time = 5 SECONDS

/obj/item/grenade/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/item/grenade/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/obj/projectile/hit_projectile = hitby
	if(damage && attack_type == PROJECTILE_ATTACK && hit_projectile.damage_type != STAMINA && prob(15))
		owner.visible_message(span_danger("[attack_text] hits [owner]'s [src], setting it off! What a shot!"))
		var/turf/source_turf = get_turf(src)
		log_game("A projectile ([hitby]) detonated a grenade held by [key_name(owner)] at [COORD(source_turf)]")
		message_admins("A projectile ([hitby]) detonated a grenade held by [key_name_admin(owner)] at [ADMIN_COORDJMP(source_turf)]")
		detonate()
		
		if(!QDELETED(src)) // some grenades don't detonate but we want them destroyed
			qdel(src)
		return TRUE //It hit the grenade, not them

/obj/item/grenade/afterattack(atom/target, mob/user)
	. = ..()
	if(active)
		user.throw_item(target)
