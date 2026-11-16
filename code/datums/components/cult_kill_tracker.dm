/// Component to handle the behavior of a nullrod keeping track of cultists it has crit or killed, and converting the item into a cult weapon when sacrificed
/datum/component/cult_kill_tracker
	/// Lazylist, tracks weakrefs()s to all cultists which have been crit or killed by this nullrod.
	var/list/cultists_slain
	/// Ref to the last mob hit with this rod.
	var/last_ref
	/// The stat of the target being hit with this rod, before actually performing damage calculations.
	var/last_stat = DEAD

/datum/component/cult_kill_tracker/Initialize(...)
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE

/datum/component/cult_kill_tracker/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_ZONE, PROC_REF(on_attack_zone))
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(post_hit))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ITEM_CULT_SACRIFICE, PROC_REF(on_sacrificed))
	if(isgun(parent))
		RegisterSignal(parent, COMSIG_PROJECTILE_ON_HIT, PROC_REF(on_projectile_hit))
		RegisterSignal(parent, COMSIG_PROJECTILE_POST_HIT_LIVING, PROC_REF(post_hit))

/datum/component/cult_kill_tracker/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_ITEM_ATTACK_ZONE, COMSIG_ITEM_AFTERATTACK, COMSIG_ATOM_EXAMINE, COMSIG_ITEM_CULT_SACRIFICE, COMSIG_PROJECTILE_ON_HIT, COMSIG_PROJECTILE_POST_HIT_LIVING))

/datum/component/cult_kill_tracker/proc/on_attack_zone(obj/item/source, mob/living/target, mob/living/user)
	SIGNAL_HANDLER
	if(!user.mind?.holy_role)
		return
	if(!IS_CULTIST(target) || istype(target, /mob/living/carbon/human/cult_ghost))
		return
	last_ref = WEAKREF(target)
	last_stat = target.stat

/datum/component/cult_kill_tracker/proc/post_hit(source, mob/living/target)
	SIGNAL_HANDLER
	if(!last_ref)
		return
	var/mob/living/resolved_mob = locate(last_ref)
	//If they got deleted during the processing of the attack, they're probably fucking dead.
	if(!istype(resolved_mob) || (resolved_mob == target && resolved_mob.stat > last_stat))
		LAZYOR(cultists_slain, last_ref)
	last_ref = null
	last_stat = DEAD

/datum/component/cult_kill_tracker/proc/on_examine(obj/item/source, mob/viewer, list/examine_list)
	SIGNAL_HANDLER
	if(!IS_CULTIST(viewer) || !GET_ATOM_BLOOD_DNA_LENGTH(source))
		return

	var/num_slain = LAZYLEN(cultists_slain)
	examine_list += span_cult_italic("It has the blood of [num_slain] fallen cultist[num_slain == 1 ? "" : "s"] on it. \
		<b>Offering</b> it to Nar'sie will transform it into a [num_slain >= 3 ? "powerful" : "standard"] cult weapon.")

/datum/component/cult_kill_tracker/proc/on_sacrificed(obj/item/source, obj/effect/rune/convert/rune)
	SIGNAL_HANDLER
	var/num_slain = LAZYLEN(cultists_slain)
	var/displayed_message = "[source] glows an unholy red and begins to transform..."
	if(num_slain && GET_ATOM_BLOOD_DNA_LENGTH(source))
		displayed_message += " The blood of [num_slain] fallen cultist[num_slain == 1 ? "":"s"] is absorbed into [source]!"

	source.visible_message(span_cult_italic(displayed_message))
	switch(num_slain)
		if(0)
			rune.animate_convert_item(source, /obj/item/melee/cultblade/dagger)
		if(1)
			rune.animate_convert_item(source, /obj/item/melee/cultblade)
		else
			rune.animate_convert_item(source, /obj/item/melee/cultblade/halberd)
	return COMPONENT_SACRIFICE_SUCCESSFUL

/datum/component/cult_kill_tracker/proc/on_projectile_hit(obj/projectile/source, atom/movable/firer, atom/target)
	SIGNAL_HANDLER
	if(!isliving(firer) || !isliving(target))
		return
	var/mob/living/firer_mob = firer
	var/mob/living/target_mob = target
	if(!firer_mob.mind.holy_role)
		return
	if(!IS_CULTIST(target_mob) || istype(target_mob, /mob/living/carbon/human/cult_ghost))
		return
	last_ref = WEAKREF(target_mob)
	last_stat = target_mob.stat
