/obj/item/smelling_salts
	name = "smelling salts"
	desc = "A small pile of a salt-like substance that smells absolutely repulsive. Rumor has it that the smell is so pungent that even the dead will come back to life to escape it."
	icon_state = "smelling_salts"
	icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/salts.dmi'
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	item_flags = NOBLUDGEON

/obj/item/smelling_salts/attack(mob/living/mob_attacked, mob/user)
	. = ..()
	if(!iscarbon(mob_attacked))
		to_chat(user, span_warning("On second thought, maybe [src] won't work on [mob_attacked]."))
		return

	if(mob_attacked == user)
		to_chat(user, span_warning("You can't bring yourself to get [src] anywhere near your face."))
		return

	if(mob_attacked.stat != DEAD)
		to_chat(user, span_warning("On second thought, maybe you shouldn't use this on [mob_attacked] if they're not <b>dead</b>."))
		return

	try_revive(mob_attacked, user)

/// If the right conditions are present (basically could this person be defibrilated), revives the target
/obj/item/smelling_salts/proc/try_revive(mob/living/carbon/carbon_target, mob/user)
	carbon_target.notify_revival("You are being brought back to life!")
	carbon_target.grab_ghost()

	user.balloon_alert_to_viewers("trying to revive [carbon_target]")

	if(!do_after(user, 3 SECONDS, carbon_target))
		user.balloon_alert(user, "stopped reviving [carbon_target]")
		return

	if(carbon_target.stat != DEAD)
		to_chat(user, span_warning("Wait, [carbon_target] isn't actually <b>dead</b>!"))
		return

	var/defib_result = carbon_target.can_defib()
	var/fail_reason

	switch (defib_result)
		if (DEFIB_FAIL_SUICIDE, DEFIB_FAIL_BLACKLISTED, DEFIB_FAIL_NO_INTELLIGENCE)
			fail_reason = "[carbon_target] doesn't respond at all... You don't think they're coming back."
		if (DEFIB_FAIL_NO_HEART, DEFIB_FAIL_FAILING_HEART, DEFIB_FAIL_FAILING_BRAIN)
			fail_reason = "[carbon_target] seems to respond just a little, but something you can't see must be wrong about them..."
		if (DEFIB_FAIL_TISSUE_DAMAGE, DEFIB_FAIL_HUSK)
			fail_reason = "[carbon_target]'s body seems way too damaged for this to work..."
		if (DEFIB_FAIL_NO_BRAIN)
			fail_reason = "[carbon_target]'s head looks like it's missing something important."

	if(carbon_target.health <= HEALTH_THRESHOLD_FULLCRIT)
		fail_reason = "[carbon_target]'s body seems just a little too damaged for this to work..."

	if(fail_reason)
		to_chat(user, span_boldwarning("[fail_reason]"))
		return

	carbon_target.adjustOxyLoss(amount = 60, updating_health = TRUE)
	playsound(src, 'modular_doppler/emotes/sound/female_sniff.ogg', 50, FALSE)
	carbon_target.set_heartattack(FALSE)

	if(defib_result == DEFIB_POSSIBLE)
		carbon_target.grab_ghost()

	carbon_target.revive()
	// to_chat(carbon_target, span_userdanger("[CONFIG_GET(string/blackoutpolicy)]"))
	log_combat(user, carbon_target, "revived", src)
