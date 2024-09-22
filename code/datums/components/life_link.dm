/**
 * A mob with this component passes all damage (and healing) it takes to another mob, passed as a parameter
 * Essentially we use another mob's health bar as our health bar
 */
/datum/component/life_link
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Mob we pass all of our damage to
	var/mob/living/host
	/// Optional callback invoked when damage gets transferred
	var/datum/callback/on_passed_damage
	/// Optional callback invoked when the linked mob dies
	var/datum/callback/on_linked_death

/datum/component/life_link/Initialize(mob/living/host, datum/callback/on_passed_damage, datum/callback/on_linked_death)
	. = ..()
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	if (!istype(host))
		CRASH("Life link created on [parent.type] and attempted to link to invalid type [host?.type].")
	register_host(host)
	src.on_passed_damage = on_passed_damage
	src.on_linked_death = on_linked_death

/datum/component/life_link/RegisterWithParent()
	RegisterSignal(parent, COMSIG_CARBON_LIMB_DAMAGED, PROC_REF(on_limb_damage))
	RegisterSignals(parent, COMSIG_LIVING_ADJUST_STANDARD_DAMAGE_TYPES, PROC_REF(on_damage_adjusted))
	RegisterSignal(parent, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(on_health_updated))
	RegisterSignal(parent, COMSIG_MOB_GET_STATUS_TAB_ITEMS, PROC_REF(on_status_tab_updated))
	if (!isnull(host))
		var/mob/living/living_parent = parent
		living_parent.updatehealth()

/datum/component/life_link/UnregisterFromParent()
	unregister_host()
	UnregisterSignal(parent, list(COMSIG_CARBON_LIMB_DAMAGED, COMSIG_LIVING_HEALTH_UPDATE, COMSIG_MOB_GET_STATUS_TAB_ITEMS) + COMSIG_LIVING_ADJUST_STANDARD_DAMAGE_TYPES)

/datum/component/life_link/InheritComponent(datum/component/new_comp, i_am_original, mob/living/host, datum/callback/on_passed_damage, datum/callback/on_linked_death)
	register_host(host)

/// Set someone up as our new host
/datum/component/life_link/proc/register_host(mob/living/new_host)
	unregister_host()
	if (isnull(new_host))
		return
	host = new_host
	RegisterSignal(host, COMSIG_LIVING_DEATH, PROC_REF(on_host_died))
	RegisterSignal(host, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(on_health_updated))
	RegisterSignal(host, COMSIG_LIVING_REVIVE, PROC_REF(on_host_revived))
	RegisterSignal(host, COMSIG_QDELETING, PROC_REF(on_host_deleted))
	var/mob/living/living_parent = parent
	living_parent.updatehealth()

/// Drop someone from being our host
/datum/component/life_link/proc/unregister_host()
	if (isnull(host))
		return
	UnregisterSignal(host, list(COMSIG_LIVING_DEATH, COMSIG_LIVING_HEALTH_UPDATE, COMSIG_LIVING_REVIVE, COMSIG_QDELETING))
	host = null

/// Called when your damage goes up or down
/datum/component/life_link/proc/on_damage_adjusted(mob/living/our_mob, type, amount, forced)
	SIGNAL_HANDLER
	if (forced)
		return
	amount *= our_mob.get_damage_mod(type)
	switch (type)
		if(BRUTE)
			host.adjustBruteLoss(amount, forced = TRUE)
		if(BURN)
			host.adjustFireLoss(amount, forced = TRUE)
		if(TOX)
			host.adjustToxLoss(amount, forced = TRUE)
		if(OXY)
			host.adjustOxyLoss(amount, forced = TRUE)

	on_passed_damage?.Invoke(our_mob, host, amount)
	return COMPONENT_IGNORE_CHANGE

/// Called when someone hurts one of our limbs, bypassing normal damage adjustment
/datum/component/life_link/proc/on_limb_damage(mob/living/our_mob, limb, brute, burn)
	SIGNAL_HANDLER
	if (brute != 0)
		host.adjustBruteLoss(brute, updating_health = FALSE)
	if (burn != 0)
		host.adjustFireLoss(burn, updating_health = FALSE)
	if (brute != 0 || burn != 0)
		host.updatehealth()
	on_passed_damage?.Invoke(our_mob, host, brute + burn)
	return COMPONENT_PREVENT_LIMB_DAMAGE

/// Called when either the host or parent's health tries to update, update our displayed health
/datum/component/life_link/proc/on_health_updated()
	SIGNAL_HANDLER
	update_health_hud(parent)
	update_med_hud_health(parent)
	update_med_hud_status(parent)

/// Update our parent's health display based on how harmed our host is
/datum/component/life_link/proc/update_health_hud(mob/living/mob_parent)
	var/severity = 0
	var/healthpercent = health_percentage(host)
	switch(healthpercent)
		if(100 to INFINITY)
			severity = 0
		if(85 to 100)
			severity = 1
		if(70 to 85)
			severity = 2
		if(55 to 70)
			severity = 3
		if(40 to 55)
			severity = 4
		if(25 to 40)
			severity = 5
		else
			severity = 6
	if(severity > 0)
		mob_parent.overlay_fullscreen("brute", /atom/movable/screen/fullscreen/brute, severity)
	else
		mob_parent.clear_fullscreen("brute")
	if(mob_parent.hud_used?.healths)
		mob_parent.hud_used.healths.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#efeeef'>[round(healthpercent, 0.5)]%</font></div>")

/// Update our health on the medical hud
/datum/component/life_link/proc/update_med_hud_health(mob/living/mob_parent)
	var/image/holder = mob_parent.hud_list?[HEALTH_HUD]
	if(isnull(holder))
		return
	holder.icon_state = "hud[RoundHealth(host)]"
	var/icon/size_check = icon(mob_parent.icon, mob_parent.icon_state, mob_parent.dir)
	holder.pixel_y = size_check.Height() - ICON_SIZE_Y

/// Update our vital status on the medical hud
/datum/component/life_link/proc/update_med_hud_status(mob/living/mob_parent)
	var/image/holder = mob_parent.hud_list?[STATUS_HUD]
	if(isnull(holder))
		return
	var/icon/size_check = icon(mob_parent.icon, mob_parent.icon_state, mob_parent.dir)
	holder.pixel_y = size_check.Height() - ICON_SIZE_Y
	if(host.stat == DEAD || HAS_TRAIT(host, TRAIT_FAKEDEATH))
		holder.icon_state = "huddead"
	else
		holder.icon_state = "hudhealthy"

/// When our status tab updates, draw how much HP our host has in there
/datum/component/life_link/proc/on_status_tab_updated(mob/living/source, list/items)
	SIGNAL_HANDLER
	var/healthpercent = health_percentage(host)
	items += "Host Health: [round(healthpercent, 0.5)]%"

/// Called when our host dies, we should die too
/datum/component/life_link/proc/on_host_died(mob/living/source, gibbed)
	SIGNAL_HANDLER
	on_linked_death?.Invoke(parent, host, gibbed)
	var/mob/living/living_parent = parent
	living_parent.death(gibbed)

/// Called when our host undies, we should undie too
/datum/component/life_link/proc/on_host_revived(mob/living/source, full_heal_flags)
	SIGNAL_HANDLER
	var/mob/living/living_parent = parent
	living_parent.revive(full_heal_flags)

/// Called when
/datum/component/life_link/proc/on_host_deleted()
	SIGNAL_HANDLER
	qdel(src)
