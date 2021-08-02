/**
 * # Facehugger
 *
 * A simplemob used by aliens to reproduce.  Will attempt to impregnate humans on its own, but can also be picked up and thrown for more efficiency.
 *
 * A small, crab-like creature which latches onto the faces of humans and monkeys and impregnates them with an alien embryo.  After a time, the embryo
 * will explode the "parent" and an alien larva will be born.  Facehuggers can be deterred by using face-covering helmets or impossible to remove masks.
 * They will generally bash against living and synthetic beings they cannot impregnate, eventually killing them.  Aliens can pick them up while alive and
 * throw them, while humans or other handy creatures can only do so while they are dead.
 */
/mob/living/simple_animal/hostile/facehugger
	name = "alien"
	desc = "It has some sort of a tube at the end of its tail."
	icon = 'icons/mob/alien.dmi'
	icon_state = "facehugger"
	icon_living = "facehugger"
	icon_dead = "facehugger_dead"
	gender = NEUTER
	health = 10
	maxHealth = 10
	melee_damage_lower = 5
	melee_damage_upper = 5
	obj_damage = 0
	attack_verb_continuous = "flails at"
	attack_verb_simple = "flail at"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	faction = list(ROLE_ALIEN)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	verb_say = "squeaks"
	verb_ask = "squeaks"
	verb_exclaim = "shrieks"
	verb_yell = "screeches"
	initial_language_holder = /datum/language_holder/alien
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	footstep_type = FOOTSTEP_MOB_CLAW
	gold_core_spawnable = NO_SPAWN
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	environment_smash = ENVIRONMENT_SMASH_NONE
	robust_searching = TRUE
	stat_attack = HARD_CRIT
	minbodytemp = 0
	maxbodytemp = 500
	/// Whether or not this facehugger can actually impregnate targets
	var/sterile = FALSE
	/// How long it takes for a facehugger to impregnate a target once attached
	var/pregnation_time = 10 SECONDS
	/// How long it takes between coupling attempts
	var/couple_retry_time = 15 SECONDS
	/// The mob's internal mask version, stored within the mob when the facehugger isn't being used as an item.
	var/obj/item/clothing/mask/facehugger_item/mask_facehugger
	COOLDOWN_DECLARE(coupling_cooldown)

/mob/living/simple_animal/hostile/facehugger/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/simple_animal/hostile/facehugger/AttackingTarget()
	TryCoupling(target)

/mob/living/simple_animal/hostile/facehugger/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	TryCoupling(hit_atom)
	
/mob/living/simple_animal/hostile/facehugger/Crossed(atom/movable/AM)
	. = ..()
	TryCoupling(AM)

/mob/living/simple_animal/hostile/facehugger/attack_hand(mob/user)
	if(stat == DEAD || sterile)
		var/obj/item/clothing/mask/facehugger_item/hugger_item = BecomeItem()
		user.put_in_hands(hugger_item)

/mob/living/simple_animal/hostile/facehugger/attack_alien(mob/user)
	var/obj/item/clothing/mask/facehugger_item/hugger_item = BecomeItem()
	user.put_in_hands(hugger_item)

/**
 * Attempts to have the facehugger couple with the given target.  Checks all possibilities and plays them out accordingly.
 *
 * The proc which controls the facehugger's coupling power.  Checks a number of possibilities involving the target, and plays them out.
 * Smashes against animals, aliens, and cyborgs not in the facehugger's faction.  If the facehugger isn't sterile, this will deal damage to the target.
 * If the target has no head, it will also bash against them.
 * If the target wears a helmet which covers their face, the coupling attempt will fail and no damage is dealt.
 * If the target is not wearing a helmet but instead a removable mask which isn't a facehugger, the facehugger will rip it off.
 * If the facehugger wasn't stopped anywhere in the previous conditions, it will become an item and attach itself to the target's face, assuming they can wear masks.
 * Arguments:
 * * target - the atom which is being checked for coupling
 */
/mob/living/simple_animal/hostile/facehugger/proc/TryCoupling(atom/target)
	if(!isliving(target) || stat == DEAD || !COOLDOWN_FINISHED(src, coupling_cooldown))
		return FALSE
	var/mob/living/living_target = target

	//Check for immunity
	if(HAS_TRAIT(living_target, TRAIT_XENO_IMMUNE))
		return FALSE
		
	if(isanimal(target) || isalien(target) || iscyborg(target))
		if(faction_check_mob(living_target))
			return FALSE
		visible_message("<span class='danger'>[src] smashes against [target], but can't seem to latch on!</span>", "<span class='userdanger'>[src] smashes against you, but can't seem to latch on!</span>")
		if(!sterile)
			living_target.adjustBruteLoss(melee_damage_upper)
			return TRUE
	if(!iscarbon(target))
		return
	var/mob/living/carbon/carbon_target = target
		
	//Check for headlessness
	if(!carbon_target.get_bodypart(BODY_ZONE_HEAD))
		visible_message("<span class='danger'>[src] smashes against [target], but can't latch on!</span>", "<span class='userdanger'>[src] smashes against you, but cant latch on!</span>")
		if(!sterile)
			carbon_target.adjustBruteLoss(melee_damage_upper)
		return FALSE

	//Check for helmet
	if(ishuman(carbon_target))
		var/mob/living/carbon/human/human_target = carbon_target
		if(human_target.is_mouth_covered(head_only = TRUE))
			human_target.visible_message("<span class='danger'>[src] smashes against [target]'s [human_target.head]!</span>", "<span class='userdanger'>[src] smashes against your [human_target.head]!</span>")
			COOLDOWN_START(src, coupling_cooldown, couple_retry_time)
			return FALSE

	//Check for mask
	if(carbon_target.wear_mask)
		var/obj/item/clothing/mask = carbon_target.wear_mask
		if(istype(mask, /obj/item/clothing/mask/facehugger_item))
			return FALSE
		if(carbon_target.dropItemToGround(mask))
			carbon_target.visible_message("<span class='danger'>[src] tears [mask] off of [target]'s face!</span>", "<span class='userdanger'>[src] tears [mask] off of your face!</span>")
		else
			carbon_target.visible_message("<span class='danger'>[src] tries to tear [mask] off of [target]'s face, but fails!</span>", "<span class='userdanger'>[src] trys to tear [mask] off of your face, but fails!</span>")
			COOLDOWN_START(src, coupling_cooldown, couple_retry_time)
			return FALSE

	target.visible_message("<span class='danger'>[src] leaps at [target]'s face!</span>", "<span class='userdanger'>[src] leaps at your face!</span>")
	var/obj/item/clothing/mask/facehugger_item/hugger_item = BecomeItem()
	if(!carbon_target.wear_mask && carbon_target.equip_to_slot_if_possible(hugger_item, ITEM_SLOT_MASK, FALSE, TRUE, TRUE))
		hugger_item.Attach(carbon_target)
	return TRUE

/**
 * Turns the facehugger into an item, storing the mob inside of it.
 *
 * Proc to turn the facehugger into an item and store the mob inside said item.
 * The item version will take the name, description, and appearance of the facehugger.
 */
/mob/living/simple_animal/hostile/facehugger/proc/BecomeItem()
	if(!mask_facehugger)
		mask_facehugger = new(src, src)
	mask_facehugger.forceMove(loc)
	forceMove(mask_facehugger)
	//This needs to be here instead of being an initialization arg since these can change over time.
	mask_facehugger.name = name
	mask_facehugger.desc = desc
	mask_facehugger.icon_state = icon_state
	return mask_facehugger

/**
 * # Facehugger Item
 *
 * The storage item for facehuggers, used to allow them to be worn as masks.
 *
 * An item used to represent a facehugger while in the inventory of something.  It stores the mob inside of it,
 * keeping it safe from death.  Upon being dropped, the item will release the mob and destroy itself.  Also worth
 * noting, throwing this item will transfer the throw's momentum and target to the facehugger, allowing for seamless
 * throwing.  It also handles impregnating the wearer and subsequently killing the facehugger as well.
 */
/obj/item/clothing/mask/facehugger_item
	name = "alien"
	desc = "It has some sort of a tube at the end of its tail."
	icon = 'icons/mob/alien.dmi'
	icon_state = "facehugger"
	inhand_icon_state = "facehugger"
	w_class = WEIGHT_CLASS_TINY
	clothing_flags = MASKINTERNALS
	throw_range = 5
	tint = 3
	flags_cover = MASKCOVERSEYES | MASKCOVERSMOUTH
	layer = MOB_LAYER
	max_integrity = INFINITY
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	var/mob/living/simple_animal/hostile/facehugger/facehugger_mob

/obj/item/clothing/mask/facehugger_item/Initialize(parent_mob)
	. = ..()
	facehugger_mob = parent_mob

/obj/item/clothing/mask/facehugger_item/dropped(mob/user)
	. = ..()
	if(loc != user)
		facehugger_mob.forceMove(get_turf(src))
		forceMove(facehugger_mob)

/obj/item/clothing/mask/facehugger_item/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, quickstart = TRUE)
	facehugger_mob.throw_at(target, range, speed, thrower, spin, diagonals_first, callback, quickstart)

/**
 * Proc which begins the impregnation process 
 *
 * Checks whether or not the facehugger is sterile.  If it isn't, it will knockout the wearer and initialize the impregnation process.
 * Regardless of the above condition, the facehugger will go on cooldown, preventing it from trying to couple for a time.
 * Argument:
 * * target - the wearer of the facehugger
 */
/obj/item/clothing/mask/facehugger_item/proc/Attach(mob/living/target)
	if(!facehugger_mob.sterile)
		target.take_bodypart_damage(brute = facehugger_mob.melee_damage_upper)
		target.Unconscious(facehugger_mob.pregnation_time)
		addtimer(CALLBACK(src, .proc/Impregnate, target), facehugger_mob.pregnation_time)
	COOLDOWN_START(facehugger_mob, coupling_cooldown, facehugger_mob.couple_retry_time)

/**
 * Proc which will implant the embryo into the wearer if it can.
 *
 * Makes sure the wearer can still be impregnated and the facehugger is still capable of it, then implants an embryo.
 * It will also log this event.  After the impregnation is done, the facehugger will fall limp and fall off of the wearer's face, dead.
 * Argument:
 * * target - the wearer of the facehugger and the one to be impregnated
 */
/obj/item/clothing/mask/facehugger_item/proc/Impregnate(mob/living/carbon/target)
	if(QDELETED(target) || target.stat == DEAD || facehugger_mob?.sterile)
		return

	var/obj/item/bodypart/chest/LC = target.get_bodypart(BODY_ZONE_CHEST)
	if((!LC || LC.status != BODYPART_ROBOTIC) && !target.getorgan(/obj/item/organ/body_egg/alien_embryo))
		new /obj/item/organ/body_egg/alien_embryo(target)
		var/turf/T = get_turf(target)
		log_game("[key_name(target)] was impregnated by a facehugger at [loc_name(T)]")
		
	target.visible_message("<span class='danger'>[src] falls limp after violating [target]'s face!</span>", "<span class='userdanger'>[src] falls limp after violating your face!</span>")
	facehugger_mob.icon_dead = "facehugger_impregnated"
	facehugger_mob.death()
	target.dropItemToGround(src)

/**
 * # Lamarr
 *
 * The research director's sterilized facehugger.  Spawns in a trophy case on almost all normal stations.
 *
 * A facehugger which spawns in a trophy case within the research director's office on most normal stations.
 * Because Lamarr spawns in a trophy cabinet, he must be initialized as an item and not a mob.  Therefore,
 * this unique subtype of the facehugger item will create itself a facehugger mob identical to it on initialization.
 * When Lamarr is picked up again, it will create itself a normal facehugger item, so this item is only for
 * initializing an instance of Lamarr.
 */
/obj/item/clothing/mask/facehugger_item/lamarr
	name = "Lamarr"
	desc = "The Research Director's pet, a domesticated and debeaked xenomorph facehugger. Friendly, but may still try to couple with your head."

/obj/item/clothing/mask/facehugger_item/lamarr/Initialize()
	. = ..()
	var/mob/living/simple_animal/hostile/facehugger/mob_lamarr = new(src)
	mob_lamarr.name = name
	mob_lamarr.desc = desc
	mob_lamarr.sterile = TRUE
	facehugger_mob = mob_lamarr
	mob_lamarr.mask_facehugger = src

/**
 * # Toy Facehugger
 *
 * A toy breed of facehugger which is sterile and can be purchased from the mining vendor.
 *
 * A toy version of facehugger which was originally implied to be an actual toy, but since
 * the shift from facehuggers being items to mobs, they are now a toy breed of the normal
 * facehuggers instead.  They will leap onto people's faces, but they cannot impregnate targets.
 * They also have a longer period of time between coupling attempts.
 */
/mob/living/simple_animal/hostile/facehugger/toy
	name = "toy facehugger"
	desc = "A toy breed of facehugger incapable of reproduction, but still good for pranking someone."
	sterile = TRUE
	couple_retry_time = 30 SECONDS
