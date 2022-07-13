
///Honorbound prevents you from attacking the unready, the just, or the innocent
/datum/mutation/human/honorbound
	name = "Honorbound"
	desc = "Less of a genome and more of a forceful rewrite of genes. Nothing Nanotrasen supplies allows for a genetic restructure like this... \
	The user feels compelled to follow supposed \"rules of combat\" but in reality they physically are unable to. \
	Their brain is rewired to excuse any curious inabilities that arise from this odd effect."
	quality = POSITIVE //so it gets carried over on revives
	power_path = /datum/action/cooldown/spell/pointed/declare_evil
	locked = TRUE
	text_gain_indication = "<span class='notice'>You feel honorbound!</span>"
	text_lose_indication = "<span class='warning'>You feel unshackled from your code of honor!</span>"
	/// list of guilty people
	var/list/guilty = list()

/datum/mutation/human/honorbound/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	//moodlet
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "honorbound", /datum/mood_event/honorbound)
	//checking spells cast by honorbound
	RegisterSignal(owner, COMSIG_MOB_CAST_SPELL, .proc/spell_check)
	RegisterSignal(owner, COMSIG_MOB_FIRED_GUN, .proc/staff_check)
	//signals that check for guilt
	RegisterSignal(owner, COMSIG_PARENT_ATTACKBY, .proc/attackby_guilt)
	RegisterSignal(owner, COMSIG_ATOM_HULK_ATTACK, .proc/hulk_guilt)
	RegisterSignal(owner, COMSIG_ATOM_ATTACK_HAND, .proc/hand_guilt)
	RegisterSignal(owner, COMSIG_ATOM_ATTACK_PAW, .proc/paw_guilt)
	RegisterSignal(owner, COMSIG_ATOM_BULLET_ACT, .proc/bullet_guilt)
	RegisterSignal(owner, COMSIG_ATOM_HITBY, .proc/thrown_guilt)

	//signal that checks for dishonorable attacks
	RegisterSignal(owner, COMSIG_MOB_CLICKON, .proc/attack_honor)

/datum/mutation/human/honorbound/on_losing(mob/living/carbon/human/owner)
	SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "honorbound")
	UnregisterSignal(owner, list(
		COMSIG_PARENT_ATTACKBY,
		COMSIG_ATOM_HULK_ATTACK,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_ATTACK_PAW,
		COMSIG_ATOM_BULLET_ACT,
		COMSIG_ATOM_HITBY,
		COMSIG_MOB_CLICKON,
		COMSIG_MOB_CAST_SPELL,
		COMSIG_MOB_FIRED_GUN,
		))
	. = ..()

/// Signal to see if the mutation allows us to attack a target
/datum/mutation/human/honorbound/proc/attack_honor(mob/living/carbon/human/honorbound, atom/clickingon, list/modifiers)
	SIGNAL_HANDLER

	if(modifiers[ALT_CLICK] || modifiers[SHIFT_CLICK] || modifiers[CTRL_CLICK] || modifiers[MIDDLE_CLICK])
		return
	if(!isliving(clickingon))
		return

	var/mob/living/clickedmob = clickingon
	var/obj/item/weapon = honorbound.get_active_held_item()

	if(!honorbound.DirectAccess(clickedmob) && !isgun(weapon))
		return
	if(weapon?.item_flags & NOBLUDGEON)
		return
	if(!honorbound.combat_mode && (HAS_TRAIT(clickedmob, TRAIT_ALLOWED_HONORBOUND_ATTACK) || ((!weapon || !weapon.force) && !LAZYACCESS(modifiers, RIGHT_CLICK))))
		return
	if(!is_honorable(honorbound, clickedmob))
		return (COMSIG_MOB_CANCEL_CLICKON)

/**
 * Called by hooked signals whenever someone attacks the person with this mutation
 * Checks if the attacker should be considered guilty and adds them to the guilty list if true
 *
 * Arguments:
 * * user: person who attacked the honorbound
 * * declaration: if this wasn't an attack, but instead the honorbound spending favor on declaring this person guilty
 */
/datum/mutation/human/honorbound/proc/guilty(mob/living/user, declaration = FALSE)
	if(user in guilty)
		return
	var/datum/mind/guilty_conscience = user.mind
	if(guilty_conscience) //sec and medical are immune to becoming guilty through attack (we don't check holy because holy shouldn't be able to attack eachother anyways)
		var/datum/job/job = guilty_conscience.assigned_role
		if(job.departments_bitflags & (DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SECURITY))
			return
	if(declaration)
		to_chat(owner, span_notice("[user] is now considered guilty by [GLOB.deity] from your declaration."))
	else
		to_chat(owner, span_notice("[user] is now considered guilty by [GLOB.deity] for attacking you first."))
	to_chat(user, span_danger("[GLOB.deity] no longer considers you innocent!"))
	guilty += user

/**
 * Called by attack_honor signal to check whether an attack should be allowed or not
 *
 * Arguments:
 * * honorbound_human: typecasted owner of mutation
 * * target_creature: person honorbound_human is attacking
 */
/datum/mutation/human/honorbound/proc/is_honorable(mob/living/carbon/human/honorbound_human, mob/living/target_creature)
	var/is_guilty = (target_creature in guilty)
	//THE UNREADY (Applies over ANYTHING else!)
	if(honorbound_human == target_creature)
		return TRUE //oh come on now
	if(target_creature.IsSleeping() || target_creature.IsUnconscious() || HAS_TRAIT(target_creature, TRAIT_RESTRAINED))
		to_chat(honorbound_human, span_warning("There is no honor in attacking the <b>unready</b>."))
		return FALSE
	//THE JUST (Applies over guilt except for med, so you best be careful!)
	if(ishuman(target_creature))
		var/mob/living/carbon/human/target_human = target_creature
		var/datum/job/job = target_human.mind?.assigned_role
		var/is_holy = target_human.mind?.holy_role
		if(is_holy || (job?.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY))
			to_chat(honorbound_human, span_warning("There is nothing righteous in attacking the <b>just</b>."))
			return FALSE
		if(job?.departments_bitflags & DEPARTMENT_BITFLAG_MEDICAL)
			to_chat(honorbound_human, span_warning("If you truly think this healer is not <b>innocent</b>, declare them guilty."))
			return FALSE
	//THE INNOCENT
	if(!is_guilty)
		to_chat(honorbound_human, span_warning("There is nothing righteous in attacking the <b>innocent</b>."))
		return FALSE
	return TRUE

// SIGNALS THAT ARE FOR BEING ATTACKED FIRST (GUILTY)
/datum/mutation/human/honorbound/proc/attackby_guilt(datum/source, obj/item/I, mob/attacker)
	SIGNAL_HANDLER
	if(I.force && I.damtype != STAMINA)
		guilty(attacker)

/datum/mutation/human/honorbound/proc/hulk_guilt(datum/source, mob/attacker)
	SIGNAL_HANDLER
	guilty(attacker)

/datum/mutation/human/honorbound/proc/hand_guilt(datum/source, mob/living/attacker)
	SIGNAL_HANDLER
	if(attacker.combat_mode)
		guilty(attacker)

/datum/mutation/human/honorbound/proc/paw_guilt(datum/source, mob/living/attacker)
	SIGNAL_HANDLER
	guilty(attacker)

/datum/mutation/human/honorbound/proc/bullet_guilt(datum/source, obj/projectile/proj)
	SIGNAL_HANDLER
	var/mob/living/shot_honorbound = source
	var/static/list/guilty_projectiles = typecacheof(list(
		/obj/projectile/beam,
		/obj/projectile/bullet,
		/obj/projectile/magic,
	))
	if(!is_type_in_typecache(proj, guilty_projectiles))
		return
	if((proj.damage_type == STAMINA))
		return
	if(!proj.nodamage && proj.damage < shot_honorbound.health && isliving(proj.firer))
		guilty(proj.firer)

/datum/mutation/human/honorbound/proc/thrown_guilt(datum/source, atom/movable/thrown_movable, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	if(istype(thrown_movable, /obj/item))
		var/mob/living/honorbound = source
		var/obj/item/thrown_item = thrown_movable
		var/mob/thrown_by = thrown_item.thrownby?.resolve()
		if(thrown_item.throwforce < honorbound.health && ishuman(thrown_by))
			guilty(thrown_by)

//spell checking
/datum/mutation/human/honorbound/proc/spell_check(mob/user, datum/action/cooldown/spell/spell_cast)
	SIGNAL_HANDLER
	punishment(user, spell_cast.school)

/datum/mutation/human/honorbound/proc/staff_check(mob/user, obj/item/gun/gun_fired, target, params, zone_override)
	SIGNAL_HANDLER
	if(!istype(gun_fired, /obj/item/gun/magic))
		return
	var/obj/item/gun/magic/offending_staff = gun_fired
	punishment(user, offending_staff.school)

/**
 * Called when a spell is casted or a magic gun is fired, checks the signal and punishes accordingly
 *
 * Arguments:
 * * user: typecasted owner of mutation
 * * school: school of magic casted from the staff/spell
 */
/datum/mutation/human/honorbound/proc/punishment(mob/living/carbon/human/user, school)
	switch(school)
		if(SCHOOL_HOLY, SCHOOL_MIME, SCHOOL_RESTORATION)
			return
		if(SCHOOL_NECROMANCY, SCHOOL_FORBIDDEN)
			to_chat(user, span_userdanger("[GLOB.deity] is enraged by your use of forbidden magic!"))
			lightningbolt(user)
			SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "honorbound", /datum/mood_event/banished)
			user.dna.remove_mutation(/datum/mutation/human/honorbound)
			user.mind.holy_role = NONE
			to_chat(user, span_userdanger("You have been excommunicated! You are no longer holy!"))
		else
			to_chat(user, span_userdanger("[GLOB.deity] is angered by your use of [school] magic!"))
			lightningbolt(user)
			SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "honorbound", /datum/mood_event/holy_smite)//permanently lose your moodlet after this

/datum/action/cooldown/spell/pointed/declare_evil
	name = "Declare Evil"
	desc = "If someone is so obviously an evil of this world you can spend a huge amount of favor to declare them guilty."
	button_icon_state = "declaration"
	ranged_mousepointer = 'icons/effects/mouse_pointers/honorbound.dmi'

	school = SCHOOL_HOLY
	cooldown_time = 0

	invocation = "This is an error!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_HUMAN

	active_msg = "You prepare to declare a sinner..."
	deactive_msg = "You decide against a declaration."

	/// The amount of favor required to declare on someone
	var/required_favor = 150
	/// A ref to our owner's honorbound mutation
	var/datum/mutation/human/honorbound/honor_mutation
	/// The declaration that's shouted in invocation. Set in New()
	var/declaration = "By the divine light of my deity, you are an evil of this world that must be wrought low!"

/datum/action/cooldown/spell/pointed/declare_evil/New()
	. = ..()
	declaration = "By the divine light of [GLOB.deity], you are an evil of this world that must be wrought low!"

/datum/action/cooldown/spell/pointed/declare_evil/Destroy()
	// If we had an owner, Destroy() called Remove(), and already handled this
	if(honor_mutation)
		UnregisterSignal(honor_mutation, COMSIG_PARENT_QDELETING)
		honor_mutation = null
	return ..()

/datum/action/cooldown/spell/pointed/declare_evil/Grant(mob/grant_to)
	if(!ishuman(grant_to))
		return FALSE

	var/mob/living/carbon/human/human_owner = grant_to
	var/datum/mutation/human/honorbound/honor_mut = human_owner.dna?.check_mutation(/datum/mutation/human/honorbound)
	if(QDELETED(honor_mut))
		return FALSE

	RegisterSignal(honor_mut, COMSIG_PARENT_QDELETING, .proc/on_honor_mutation_lost)
	honor_mutation = honor_mut
	return ..()

/datum/action/cooldown/spell/pointed/declare_evil/Remove(mob/living/remove_from)
	. = ..()
	UnregisterSignal(honor_mutation, COMSIG_PARENT_QDELETING)
	honor_mutation = null

/// If we lose our honor mutation somehow, self-delete (and clear references)
/datum/action/cooldown/spell/pointed/declare_evil/proc/on_honor_mutation_lost(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/datum/action/cooldown/spell/pointed/declare_evil/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE

	// This shouldn't technically be a possible state, but you never know
	if(!honor_mutation)
		return FALSE
	if(GLOB.religious_sect.favor < required_favor)
		if(feedback)
			to_chat(owner, span_warning("You need at least 150 favor to declare someone evil!"))
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/declare_evil/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	if(!isliving(cast_on))
		to_chat(owner, span_warning("You can only declare living beings evil!"))
		return FALSE

	var/mob/living/living_cast_on = cast_on
	if(living_cast_on.stat == DEAD)
		to_chat(owner, span_warning("Declaration on the dead? Really?"))
		return FALSE

	// sec and medical are immune to becoming guilty through attack
	// (we don't check holy, because holy shouldn't be able to attack eachother anyways)
	if(!living_cast_on.key || !living_cast_on.mind)
		to_chat(owner, span_warning("There is no evil a vacant mind can do."))
		return FALSE

	// also handles any kind of issues with self declarations
	if(living_cast_on.mind.holy_role)
		to_chat(owner, span_warning("Followers of [GLOB.deity] cannot be evil!"))
		return FALSE

	// cannot declare security as evil
	if(living_cast_on.mind.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY)
		to_chat(owner, span_warning("Members of security are uncorruptable! You cannot declare one evil!"))
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/declare_evil/before_cast(mob/living/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	invocation = "[cast_on]! [declaration]"

/datum/action/cooldown/spell/pointed/declare_evil/cast(mob/living/cast_on)
	. = ..()
	GLOB.religious_sect.adjust_favor(-required_favor, owner)
	honor_mutation.guilty(cast_on, declaration = TRUE)
