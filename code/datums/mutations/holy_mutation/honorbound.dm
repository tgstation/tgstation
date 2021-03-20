
/* TODO:
after someone passes honor checks you still can't attack them
*/
///Honorbound prevents you from attacking the unready, the just, or the innocent
/datum/mutation/human/honorbound
	name = "Honorbound"
	desc = "Less of a genome and of a forceful rewrite of genes. Nothing Nanotrasen supplies allows for a genetic restructure like this... \
	The user feels compelled to follow supposed \"rules of combat\" but in reality they physically are unable to. \
	Their brain is rewired to excuse any curious inabilities that arise from this odd effect."
	quality = POSITIVE //so it gets carried over on revives
	locked = TRUE
	text_gain_indication = "<span class='notice'>You feel honorbound!</span>"
	text_lose_indication = "<span class='warning'>You feel unshackled from your code of honor!</span>"
	var/list/guilty = list() //list of guilty people

/datum/mutation/human/honorbound/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return

	//moodlet
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "honorbound", /datum/mood_event/honorbound)
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
	UnregisterSignal(owner, list(COMSIG_PARENT_ATTACKBY,COMSIG_ATOM_HULK_ATTACK,COMSIG_ATOM_ATTACK_HAND,COMSIG_ATOM_ATTACK_PAW,COMSIG_ATOM_BULLET_ACT,COMSIG_ATOM_HITBY,COMSIG_MOB_CLICKON))
	. = ..()

/datum/mutation/human/honorbound/proc/attack_honor(mob/living/carbon/human/honorbound, atom/clickingon, params)
	SIGNAL_HANDLER
	var/obj/item/weapon = honorbound.get_active_held_item()
	var/list/modifiers = params2list(params)

	if(!isliving(clickingon))
		return
	//fucking YUGE check but essentially is every situation where a click shouldn't be checked for honor:
	//non combat mode clicks:
	//* no weapon, not disarming, weapon has no force
	//combat mode clicks
	//* is not a gun and out of range of attacking
	if(!honorbound.DirectAccess(clickingon) && !isgun(weapon))
		return
	if(!honorbound.combat_mode && ((!weapon || !weapon.force) && !LAZYACCESS(modifiers, RIGHT_CLICK)))
		return
	var/mob/living/clickedmob = clickingon
	if(!is_honorable(honorbound, clickedmob))
		return COMSIG_MOB_CANCEL_CLICKON

/datum/mutation/human/honorbound/proc/guilty(mob/living/user)
	if(user in guilty)
		return
	var/datum/mind/guilty_conscience = user.mind
	if(guilty_conscience) //sec and medical are immune to becoming guilty through attack (we don't check holy because holy shouldn't be able to attack eachother anyways)
		var/job = guilty_conscience.assigned_role
		if(job in (GLOB.security_positions + GLOB.medical_positions))
			return
	to_chat(owner, "<span class='notice'>[user] is now considered guilty by [GLOB.deity] for attacking you first.</span>")
	guilty += user

/datum/mutation/human/honorbound/proc/is_honorable(mob/living/carbon/human/honorbound_human, mob/living/target_creature)
	var/is_guilty = (target_creature in guilty)
	//THE UNREADY (Applies over ANYTHING else!)
	if(target_creature.IsSleeping() || HAS_TRAIT(target_creature, TRAIT_RESTRAINED))
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
		if((Proj.damage_type == BURN) || (Proj.damage_type == BRUTE))
			if(!Proj.nodamage && Proj.damage < shot_honorbound.health && isliving(Proj.firer))
				guilty(Proj.firer)

/datum/mutation/human/honorbound/proc/thrown_guilt(datum/source, atom/movable/thrown_movable, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	if(istype(thrown_movable, /obj/item))
		var/mob/living/honorbound = source
		var/obj/item/thrown_item = thrown_movable
		if(thrown_item.throwforce < honorbound.health && ishuman(thrown_item.thrownby))
			guilty(thrown_item.thrownby)

