
/* TODO:
after someone passes honor checks you still can't attack them --still present? test

finish burden hooks

*/

///Honorbound prevents you from attacking the unready, the just, or the innocent
/datum/mutation/human/honorbound
	name = "Honorbound"
	desc = "Less of a genome and more of a forceful rewrite of genes. Nothing Nanotrasen supplies allows for a genetic restructure like this... \
	The user feels compelled to follow supposed \"rules of combat\" but in reality they physically are unable to. \
	Their brain is rewired to excuse any curious inabilities that arise from this odd effect."
	quality = POSITIVE //so it gets carried over on revives
	power = /obj/effect/proc_holder/spell/pointed/declare_evil
	locked = TRUE
	text_gain_indication = "<span class='notice'>You feel honorbound!</span>"
	text_lose_indication = "<span class='warning'>You feel unshackled from your code of honor!</span>"
	var/list/guilty = list() //list of guilty people

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
	UnregisterSignal(owner, list(COMSIG_PARENT_ATTACKBY,COMSIG_ATOM_HULK_ATTACK,COMSIG_ATOM_ATTACK_HAND,COMSIG_ATOM_ATTACK_PAW,COMSIG_ATOM_BULLET_ACT,COMSIG_ATOM_HITBY,COMSIG_MOB_CLICKON))
	. = ..()

/datum/mutation/human/honorbound/proc/attack_honor(mob/living/carbon/human/honorbound, atom/clickingon, params)
	SIGNAL_HANDLER
	var/obj/item/weapon = honorbound.get_active_held_item()
	var/list/modifiers = params2list(params)

	if(!isliving(clickingon))
		return
	if(!honorbound.DirectAccess(clickingon) && !isgun(weapon))
		return
	if(!honorbound.combat_mode && ((!weapon || !weapon.force) && !LAZYACCESS(modifiers, RIGHT_CLICK)))
		return
	var/mob/living/clickedmob = clickingon
	if(!is_honorable(honorbound, clickedmob))
		return COMSIG_MOB_CANCEL_CLICKON

/datum/mutation/human/honorbound/proc/guilty(mob/living/user, declaration = FALSE)
	if(user in guilty)
		return
	var/datum/mind/guilty_conscience = user.mind
	if(guilty_conscience) //sec and medical are immune to becoming guilty through attack (we don't check holy because holy shouldn't be able to attack eachother anyways)
		var/job = guilty_conscience.assigned_role
		if(job in (GLOB.security_positions + GLOB.medical_positions))
			return
	if(declaration)
		to_chat(owner, "<span class='notice'>[user] is now considered guilty by [GLOB.deity] from your declaration.</span>")
		to_chat(user, "<span class='danger'>[GLOB.deity] no longer considers you innocent!</span>")
	else
		to_chat(owner, "<span class='notice'>[user] is now considered guilty by [GLOB.deity] for attacking you first.</span>")
	guilty += user

/datum/mutation/human/honorbound/proc/is_honorable(mob/living/carbon/human/honorbound_human, mob/living/target_creature)
	var/is_guilty = (target_creature in guilty)
	//THE UNREADY (Applies over ANYTHING else!)
	if(target_creature.IsSleeping() || target_creature.IsUnconscious() || HAS_TRAIT(target_creature, TRAIT_RESTRAINED))
		to_chat(honorbound_human, "<span class='warning'>There is no honor in attacking the <b>unready</b>.</span>")
		return FALSE
	//THE JUST (Applies over guilt except for med, so you best be careful!)
	if(ishuman(target_creature))
		var/mob/living/carbon/human/target_human = target_creature
		var/job = target_human.mind?.assigned_role
		var/is_holy = target_human.mind?.holy_role
		if(job in GLOB.security_positions || is_holy)
			to_chat(honorbound_human, "<span class='warning'>There is nothing rightous in attacking the <b>just</b>.</span>")
			return FALSE
		if(job in GLOB.medical_positions)
			to_chat(honorbound_human, "<span class='warning'>If you truly think this healer is not <b>innocent</b>, declare them guilty.</span>")
			return FALSE
	//THE INNOCENT
	if(!is_guilty)
		to_chat(honorbound_human, "<span class='warning'>There is nothing rightous in attacking the <b>innocent</b>.</span>")
		return FALSE

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

/datum/mutation/human/honorbound/proc/bullet_guilt(datum/source, obj/projectile/Proj)
	SIGNAL_HANDLER
	var/mob/living/shot_honorbound = source
	if(istype(Proj, /obj/projectile/beam)||istype(Proj, /obj/projectile/bullet))
		if((Proj.damage_type != STAMINA))
			if(!Proj.nodamage && Proj.damage < shot_honorbound.health && isliving(Proj.firer))
				guilty(Proj.firer)

/datum/mutation/human/honorbound/proc/thrown_guilt(datum/source, atom/movable/thrown_movable, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	if(istype(thrown_movable, /obj/item))
		var/mob/living/honorbound = source
		var/obj/item/thrown_item = thrown_movable
		if(thrown_item.throwforce < honorbound.health && ishuman(thrown_item.thrownby))
			guilty(thrown_item.thrownby)

//spell checking
/datum/mutation/human/honorbound/proc/spell_check(obj/effect/proc_holder/spell/spell_cast, mob/user)
	SIGNAL_HANDLER
	punishment(user, spell_cast.school)

/datum/mutation/human/honorbound/proc/staff_check(obj/item/gun/source, mob/user, target, params, zone_override)
	SIGNAL_HANDLER
	if(!istype(source, /obj/item/gun/magic/staff))
		return
	var/obj/item/gun/magic/staff/offending_staff
	punishment(user, offending_staff.school)

/datum/mutation/human/honorbound/proc/punishment(mob/living/user, school)
	switch(school)
		if(SCHOOL_EVOCATION, SCHOOL_TRANSMUTATION, SCHOOL_CONJURATION, SCHOOL_TRANSMUTATION)
			to_chat(user, "<span class='userdanger'>[GLOB.deity] is angered by your use of [school] magic!</span>")
			lightningbolt(user)
			SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "honorbound_punishment", /datum/mood_event/holy_smite)
		if(SCHOOL_NECROMANCY, SCHOOL_FORBIDDEN)
			to_chat(user, "<span class='userdanger'>[GLOB.deity] is enraged by your use of forbidden magic!</span>")
			lightningbolt(user)
			SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "honorbound_punishment", /datum/mood_event/banished)
			user.mind.holy_role = NONE
			to_chat(user, "<span class='userdanger'>You have been excommunicated! You are no longer holy!</span>")

/datum/mutation/human/honorbound/proc/lightningbolt(mob/living/user)
	var/turf/lightning_source = get_step(get_step(user, NORTH), NORTH)
	lightning_source.Beam(user, icon_state="lightning[rand(1,12)]", time = 5)
	user.adjustFireLoss(LIGHTNING_BOLT_DAMAGE)
	if(ishuman(user))
		var/mob/living/carbon/human/human_target = user
		human_target.electrocution_animation(LIGHTNING_BOLT_ELECTROCUTION_ANIMATION_LENGTH)

/obj/effect/proc_holder/spell/pointed/declare_evil
	name = "Declare Evil"
	desc = "If someone is so obviously an evil of this world you can spend a huge amount of favor to declare them guilty."
	school = SCHOOL_HOLY
	charge_max = 0
	clothes_req = FALSE
	range = 1
	cooldown_min = 0
	ranged_mousepointer = 'icons/effects/mouse_pointers/honorbound.dmi'
	action_icon_state = "declaration"
	active_msg = "You prepare to declare a sinner..."

/obj/effect/proc_holder/spell/pointed/declare_evil/cast(list/targets, mob/living/carbon/human/user, silent = FALSE)
	if(!ishuman(user))
		return FALSE
	var/datum/mutation/human/honorbound/honormut = user.dna.check_mutation(/datum/mutation/human/honorbound)
	if(!honormut)
		return FALSE
	if(!targets.len)
		if(!silent)
			to_chat(user, "<span class='warning'>Nobody to declare evil here!</span>")
		return FALSE
	if(targets.len > 1)
		if(!silent)
			to_chat(user, "<span class='warning'>Too many people to declare! Pick ONE!</span>")
		return FALSE
	var/declaration_message = "[targets[1]]! By the divine light of [GLOB.deity], You are an evil of this world that must be wrought low!"
	if(!user.can_speak(declaration_message))
		to_chat(user, "<span class='warning'>You can't get the declaration out!</span>")
		return FALSE
	if(!can_target(targets[1], user, silent))
		return FALSE
	honormut.guilty(targets[1], declaration = TRUE)
	return TRUE

/obj/effect/proc_holder/spell/pointed/declare_evil/can_target(atom/target, mob/user, silent)
	. = ..()
	if(!.)
		return FALSE
	if(!isliving(target))
		if(!silent)
			to_chat(user, "<span class='warning'>You can only declare living beings evil!</span>")
		return FALSE
	var/mob/living/victim = target
	if(victim.stat == DEAD)
		if(!silent)
			to_chat(user, "<span class='warning'>Declaration on the dead? Really?</span>")
		return FALSE
	var/datum/mind/guilty_conscience = victim.mind
	if(!victim.key ||!guilty_conscience) //sec and medical are immune to becoming guilty through attack (we don't check holy because holy shouldn't be able to attack eachother anyways)
		if(!silent)
			to_chat(user, "<span class='warning'>There is no evil a vacant mind can do.</span>")
		return FALSE
	if(guilty_conscience.holy_role)//also handles any kind of issues with self declarations
		if(!silent)
			to_chat(user, "<span class='warning'>Followers of [GLOB.deity] cannot be evil!</span>")
		return FALSE
	if(guilty_conscience.assigned_role in GLOB.security_positions)
		if(!silent)
			to_chat(user, "<span class='warning'>Members of security are uncorruptable! You cannot declare one evil!</span>")
		return FALSE
	return TRUE
