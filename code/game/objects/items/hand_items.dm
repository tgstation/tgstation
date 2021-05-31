// For all of the items that are really just the user's hand used in different ways, mostly (all, really) from emotes

/obj/item/circlegame
	name = "circled hand"
	desc = "If somebody looks at this while it's below your waist, you get to bop them."
	icon_state = "madeyoulook"
	force = 0
	throwforce = 0
	item_flags = DROPDEL | ABSTRACT | HAND_ITEM
	attack_verb_continuous = list("bops")
	attack_verb_simple = list("bop")

/obj/item/circlegame/Initialize()
	. = ..()
	var/mob/living/owner = loc
	if(!istype(owner))
		return
	RegisterSignal(owner, COMSIG_PARENT_EXAMINE, .proc/ownerExamined)

/obj/item/circlegame/Destroy()
	var/mob/owner = loc
	if(istype(owner))
		UnregisterSignal(owner, COMSIG_PARENT_EXAMINE)
	return ..()

/obj/item/circlegame/dropped(mob/user)
	UnregisterSignal(user, COMSIG_PARENT_EXAMINE) //loc will have changed by the time this is called, so Destroy() can't catch it
	// this is a dropdel item.
	return ..()

/// Stage 1: The mistake is made
/obj/item/circlegame/proc/ownerExamined(mob/living/owner, mob/living/sucker)
	SIGNAL_HANDLER

	if(!istype(sucker) || !in_range(owner, sucker))
		return
	addtimer(CALLBACK(src, .proc/waitASecond, owner, sucker), 4)

/// Stage 2: Fear sets in
/obj/item/circlegame/proc/waitASecond(mob/living/owner, mob/living/sucker)
	if(QDELETED(sucker) || QDELETED(src) || QDELETED(owner))
		return

	if(owner == sucker) // big mood
		to_chat(owner, "<span class='danger'>Wait a second... you just looked at your own [src.name]!</span>")
		addtimer(CALLBACK(src, .proc/selfGottem, owner), 10)
	else
		to_chat(sucker, "<span class='danger'>Wait a second... was that a-</span>")
		addtimer(CALLBACK(src, .proc/GOTTEM, owner, sucker), 6)

/// Stage 3A: We face our own failures
/obj/item/circlegame/proc/selfGottem(mob/living/owner)
	if(QDELETED(src) || QDELETED(owner))
		return

	playsound(get_turf(owner), 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
	owner.visible_message("<span class='danger'>[owner] shamefully bops [owner.p_them()]self with [owner.p_their()] [src.name].</span>", "<span class='userdanger'>You shamefully bop yourself with your [src.name].</span>", \
		"<span class='hear'>You hear a dull thud!</span>")
	log_combat(owner, owner, "bopped", src.name, "(self)")
	owner.do_attack_animation(owner)
	owner.apply_damage(100, STAMINA)
	owner.Knockdown(10)
	qdel(src)

/// Stage 3B: We face our reckoning (unless we moved away or they're incapacitated)
/obj/item/circlegame/proc/GOTTEM(mob/living/owner, mob/living/sucker)
	if(QDELETED(sucker))
		return

	if(QDELETED(src) || QDELETED(owner))
		to_chat(sucker, "<span class='warning'>Nevermind... must've been your imagination...</span>")
		return

	if(!in_range(owner, sucker) || !(owner.mobility_flags & MOBILITY_USE))
		to_chat(sucker, "<span class='notice'>Phew... you moved away before [owner] noticed you saw [owner.p_their()] [src.name]...</span>")
		return

	to_chat(owner, "<span class='warning'>[sucker] looks down at your [src.name] before trying to avert [sucker.p_their()] eyes, but it's too late!</span>")
	to_chat(sucker, "<span class='danger'><b>[owner] sees the fear in your eyes as you try to look away from [owner.p_their()] [src.name]!</b></span>")

	owner.face_atom(sucker)
	if(owner.client)
		owner.client.give_award(/datum/award/achievement/misc/gottem, owner) // then everybody clapped

	playsound(get_turf(owner), 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
	owner.do_attack_animation(sucker)

	if(HAS_TRAIT(owner, TRAIT_HULK))
		owner.visible_message("<span class='danger'>[owner] bops [sucker] with [owner.p_their()] [src.name] much harder than intended, sending [sucker.p_them()] flying!</span>", \
			"<span class='danger'>You bop [sucker] with your [src.name] much harder than intended, sending [sucker.p_them()] flying!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", ignored_mobs=list(sucker))
		to_chat(sucker, "<span class='userdanger'>[owner] bops you incredibly hard with [owner.p_their()] [src.name], sending you flying!</span>")
		sucker.apply_damage(50, STAMINA)
		sucker.Knockdown(50)
		log_combat(owner, sucker, "bopped", src.name, "(setup- Hulk)")
		var/atom/throw_target = get_edge_target_turf(sucker, owner.dir)
		sucker.throw_at(throw_target, 6, 3, owner)
	else
		owner.visible_message("<span class='danger'>[owner] bops [sucker] with [owner.p_their()] [src.name]!</span>", "<span class='danger'>You bop [sucker] with your [src.name]!</span>", \
			"<span class='hear'>You hear a dull thud!</span>", ignored_mobs=list(sucker))
		sucker.apply_damage(15, STAMINA)
		log_combat(owner, sucker, "bopped", src.name, "(setup)")
		to_chat(sucker, "<span class='userdanger'>[owner] bops you with [owner.p_their()] [src.name]!</span>")
	qdel(src)

/obj/item/slapper
	name = "slapper"
	desc = "This is how real men fight."
	icon_state = "latexballon"
	inhand_icon_state = "nothing"
	force = 0
	throwforce = 0
	item_flags = DROPDEL | ABSTRACT | HAND_ITEM
	attack_verb_continuous = list("slaps")
	attack_verb_simple = list("slap")
	hitsound = 'sound/effects/snap.ogg'
	/// How many smaller table smacks we can do before we're out
	var/table_smacks_left = 3

/obj/item/slapper/attack(mob/M, mob/living/carbon/human/user)
	if(ishuman(M))
		var/mob/living/carbon/human/L = M
		if(L && L.dna && L.dna.species)
			L.dna.species.stop_wagging_tail(M)
	user.do_attack_animation(M)
	playsound(M, 'sound/weapons/slap.ogg', 50, TRUE, -1)
	if(user.zone_selected == BODY_ZONE_HEAD || user.zone_selected == BODY_ZONE_PRECISE_MOUTH)
		user.visible_message("<span class='danger'>[user] slaps [M] in the face!</span>",
		"<span class='notice'>You slap [M] in the face!</span>",\
		"<span class='hear'>You hear a slap.</span>")
	else
		user.visible_message("<span class='danger'>[user] slaps [M]!</span>",
		"<span class='notice'>You slap [M]!</span>",\
		"<span class='hear'>You hear a slap.</span>")
	return

/obj/item/slapper/attack_obj(obj/O, mob/living/user, params)
	if(!istype(O, /obj/structure/table))
		return ..()

	var/obj/structure/table/the_table = O
	var/is_right_clicking = LAZYACCESS(params2list(params), RIGHT_CLICK)

	if(is_right_clicking && table_smacks_left == initial(table_smacks_left)) // so you can't do 2 weak slaps followed by a big slam
		transform = transform.Scale(5) // BIG slap
		if(HAS_TRAIT(user, TRAIT_HULK))
			transform = transform.Scale(2)
			color = COLOR_GREEN
		user.do_attack_animation(the_table)
		SEND_SIGNAL(user, COMSIG_LIVING_SLAM_TABLE, the_table)
		SEND_SIGNAL(the_table, COMSIG_TABLE_SLAMMED, user)
		playsound(get_turf(the_table), 'sound/effects/tableslam.ogg', 110, TRUE)
		user.visible_message("<b><span class='danger'>[user] slams [user.p_their()] fist down on [the_table]!</span></b>", "<b><span class='danger'>You slam your fist down on [the_table]!</span></b>")
		qdel(src)
	else
		user.do_attack_animation(the_table)
		playsound(get_turf(the_table), 'sound/effects/tableslam.ogg', 40, TRUE)
		user.visible_message("<span class='notice'>[user] slaps [user.p_their()] hand on [the_table].</span>", "<span class='notice'>You slap your hand on [the_table].</span>", vision_distance=COMBAT_MESSAGE_RANGE)
		table_smacks_left--
		if(table_smacks_left <= 0)
			qdel(src)

/obj/item/noogie
	name = "noogie"
	desc = "Get someone in an aggressive grab then use this on them to ruin their day."
	icon_state = "latexballon"
	inhand_icon_state = "nothing"
	force = 0
	throwforce = 0
	item_flags = DROPDEL | ABSTRACT | HAND_ITEM

/obj/item/noogie/attack(mob/living/carbon/target, mob/living/carbon/human/user)
	if(!istype(target))
		to_chat(user, "<span class='warning'>You don't think you can give this a noogie!</span>")
		return

	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>You can't bring yourself to noogie [target]! You don't want to risk harming anyone...</span>")
		return

	if(!(target?.get_bodypart(BODY_ZONE_HEAD)) || user.pulling != target || user.grab_state < GRAB_AGGRESSIVE || user.getStaminaLoss() > 80)
		return FALSE

	var/obj/item/bodypart/head/the_head = target.get_bodypart(BODY_ZONE_HEAD)
	if((target.get_biological_state() != BIO_FLESH_BONE && target.get_biological_state() != BIO_JUST_FLESH) || !the_head.is_organic_limb())
		to_chat(user, "<span class='warning'>You can't noogie [target], [target.p_they()] [target.p_have()] no skin on [target.p_their()] head!</span>")
		return

	// [user] gives [target] a [prefix_desc] noogie[affix_desc]!
	var/brutal_noogie = FALSE // was it an extra hard noogie?
	var/prefix_desc = "rough"
	var/affix_desc = ""
	var/affix_desc_target = ""

	if(HAS_TRAIT(target, TRAIT_ANTENNAE))
		prefix_desc = "violent"
		affix_desc = "on [target.p_their()] sensitive antennae"
		affix_desc_target = "on your highly sensitive antennae"
		brutal_noogie = TRUE
	if(user.dna?.check_mutation(HULK))
		prefix_desc = "sickeningly brutal"
		brutal_noogie = TRUE

	var/message_others = "[prefix_desc] noogie[affix_desc]"
	var/message_target = "[prefix_desc] noogie[affix_desc_target]"

	user.visible_message("<span class='danger'>[user] begins giving [target] a [message_others]!</span>", "<span class='warning'>You start giving [target] a [message_others]!</span>", vision_distance=COMBAT_MESSAGE_RANGE, ignored_mobs=target)
	to_chat(target, "<span class='userdanger'>[user] starts giving you a [message_target]!</span>")

	if(!do_after(user, 1.5 SECONDS, target))
		to_chat(user, "<span class='warning'>You fail to give [target] a noogie!</span>")
		to_chat(target, "<span class='danger'>[user] fails to give you a noogie!</span>")
		return

	if(brutal_noogie)
		SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, "noogie_harsh", /datum/mood_event/noogie_harsh)
	else
		SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, "noogie", /datum/mood_event/noogie)

	noogie_loop(user, target, 0)

/// The actual meat and bones of the noogie'ing
/obj/item/noogie/proc/noogie_loop(mob/living/carbon/human/user, mob/living/carbon/target, iteration)
	if(!(target?.get_bodypart(BODY_ZONE_HEAD)) || user.pulling != target)
		return FALSE

	if(user.getStaminaLoss() > 80)
		to_chat(user, "<span class='warning'>You're too tired to continue giving [target] a noogie!</span>")
		to_chat(target, "<span class='danger'>[user] is too tired to continue giving you a noogie!</span>")
		return

	var/damage = rand(1, 5)
	if(HAS_TRAIT(target, TRAIT_ANTENNAE))
		damage += rand(3,7)
	if(user.dna?.check_mutation(HULK))
		damage += rand(3,7)

	if(damage >= 5)
		target.emote("scream")

	log_combat(user, target, "given a noogie to", addition = "([damage] brute before armor)")
	target.apply_damage(damage, BRUTE, BODY_ZONE_HEAD)
	user.adjustStaminaLoss(iteration + 5)
	playsound(get_turf(user), pick('sound/effects/rustle1.ogg','sound/effects/rustle2.ogg','sound/effects/rustle3.ogg','sound/effects/rustle4.ogg','sound/effects/rustle5.ogg'), 50)

	if(prob(33))
		user.visible_message("<span class='danger'>[user] continues noogie'ing [target]!</span>", "<span class='warning'>You continue giving [target] a noogie!</span>", vision_distance=COMBAT_MESSAGE_RANGE, ignored_mobs=target)
		to_chat(target, "<span class='userdanger'>[user] continues giving you a noogie!</span>")

	if(!do_after(user, 1 SECONDS + (iteration * 2), target))
		to_chat(user, "<span class='warning'>You fail to give [target] a noogie!</span>")
		to_chat(target, "<span class='danger'>[user] fails to give you a noogie!</span>")
		return

	iteration++
	noogie_loop(user, target, iteration)


/obj/item/kisser
	name = "kiss"
	desc = "I want you all to know, everyone and anyone, to seal it with a kiss."
	icon = 'icons/mob/animal.dmi'
	icon_state = "heart"
	inhand_icon_state = "nothing"
	force = 0
	throwforce = 0
	item_flags = DROPDEL | ABSTRACT | HAND_ITEM
	/// The kind of projectile this version of the kiss blower fires
	var/kiss_type = /obj/projectile/kiss

/obj/item/kisser/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	var/obj/projectile/blown_kiss = new kiss_type(get_turf(user))
	user.visible_message("<b>[user]</b> blows \a [blown_kiss] at [target]!", "<span class='notice'>You blow \a [blown_kiss] at [target]!</span>")

	//Shooting Code:
	blown_kiss.spread = 0
	blown_kiss.original = target
	blown_kiss.fired_from = user
	blown_kiss.firer = user // don't hit ourself that would be really annoying
	blown_kiss.impacted = list(user = TRUE) // just to make sure we don't hit the wearer
	blown_kiss.preparePixelProjectile(target, user)
	blown_kiss.fire()
	qdel(src)

/obj/item/kisser/death
	name = "kiss of death"
	desc = "If looks could kill, they'd be this."
	color = COLOR_BLACK
	kiss_type = /obj/projectile/kiss/death

/obj/projectile/kiss
	name = "kiss"
	icon = 'icons/mob/animal.dmi'
	icon_state = "heart"
	hitsound = 'sound/effects/kiss.ogg'
	hitsound_wall = 'sound/effects/kiss.ogg'
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	speed = 1.6
	damage_type = BRUTE
	damage = 0
	nodamage = TRUE // love can't actually hurt you
	armour_penetration = 100 // but if it could, it would cut through even the thickest plate
	flag = MAGIC // and most importantly, love is magic~

/obj/projectile/kiss/fire(angle, atom/direct_target)
	if(firer)
		name = "[name] blown by [firer]"
	return ..()

/obj/projectile/kiss/Impact(atom/A)
	if(!nodamage || !isliving(A)) // if we do damage or we hit a nonliving thing, we don't have to worry about a harmless hit because we can't wrongly do damage anyway
		return ..()

	harmless_on_hit(A)
	qdel(src)
	return FALSE

/**
 * To get around shielded hardsuits & such being set off by kisses when they shouldn't, we take a page from hallucination projectiles
 * and simply fake our on hit effects. This lets kisses remain incorporeal without having to make some new trait for this one niche situation.
 * This fake hit only happens if we can deal damage and if we hit a living thing. Otherwise, we just do normal on hit effects.
 */
/obj/projectile/kiss/proc/harmless_on_hit(mob/living/living_target)
	playsound(get_turf(living_target), hitsound, 100, TRUE)
	living_target.visible_message("<span class='danger'>[living_target] is hit by \a [src].</span>", "<span class='userdanger'>You're hit by \a [src]!</span>", vision_distance=COMBAT_MESSAGE_RANGE)
	try_fluster(living_target)

/obj/projectile/kiss/proc/try_fluster(mob/living/living_target)
	// people with the social anxiety quirk can get flustered when hit by a kiss
	if(!HAS_TRAIT(living_target, TRAIT_ANXIOUS) || (living_target.stat > SOFT_CRIT))
		return
	if(HAS_TRAIT(living_target, TRAIT_FEARLESS) || prob(50)) // 50% chance for it to apply, also immune while on meds
		return

	var/other_msg
	var/self_msg
	var/roll = rand(1, 3)
	switch(roll)
		if(1)
			other_msg = "stumbles slightly, turning a bright red!"
			self_msg = "You lose control of your limbs for a moment as your blood rushes to your face, turning it bright red!"
			living_target.add_confusion(rand(5, 10))
		if(2)
			other_msg = "stammers softly for a moment before choking on something!"
			self_msg = "You feel your tongue disappear down your throat as you fight to remember how to make words!"
			addtimer(CALLBACK(living_target, /atom/movable.proc/say, pick("Uhhh...", "O-oh, uhm...", "I- uhhhhh??", "You too!!", "What?")), rand(0.5 SECONDS, 1.5 SECONDS))
			living_target.stuttering += rand(5, 15)
		if(3)
			other_msg = "locks up with a stunned look on [living_target.p_their()] face, staring at [firer ? firer : "the ceiling"]!"
			self_msg = "Your brain completely fails to process what just happened, leaving you rooted in place staring at [firer ? "[firer]" : "the ceiling"] for what feels like an eternity!"
			living_target.face_atom(firer)
			living_target.Stun(rand(3 SECONDS, 8 SECONDS))

	living_target.visible_message("<b>[living_target]</b> [other_msg]", "<span class='userdanger'>Whoa! [self_msg]<span>")

/obj/projectile/kiss/on_hit(atom/target, blocked, pierce_hit)
	def_zone = BODY_ZONE_HEAD // let's keep it PG, people
	. = ..()
	if(isliving(target))
		try_fluster(target)

/obj/projectile/kiss/death
	name = "kiss of death"
	nodamage = FALSE // okay i kinda lied about love not being able to hurt you
	damage = 35
	wound_bonus = 0
	sharpness = SHARP_POINTY
	color = COLOR_BLACK

/obj/projectile/kiss/death/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(!iscarbon(target))
		return
	var/mob/living/carbon/heartbreakee = target
	var/obj/item/organ/heart/dont_go_breakin_my_heart = heartbreakee.getorganslot(ORGAN_SLOT_HEART)
	dont_go_breakin_my_heart.applyOrganDamage(999)
