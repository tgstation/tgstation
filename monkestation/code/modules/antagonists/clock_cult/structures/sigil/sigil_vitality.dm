///how much damage do we heal when reviving someone before costing vitality
#define FREE_DAMAGE_HEALED 20
///how much do we reduce drained mobs health health by each siphon
#define HEALTH_DRAINED 20
/obj/structure/destructible/clockwork/sigil/vitality
	name = "vitality matrix"
	desc = "A twisting, confusing artifact that drains the unenlightended on contact."
	clockwork_desc = "A beautiful artifact that will drain the life of heretics placed on top of it."
	icon_state = "sigilvitality"
	effect_stand_time = 2.5 SECONDS // You can't permastun someone with this, so you'll need to keep them grabbed + cuffed
	idle_color = "#5e87c4"
	invocation_color = "#83cbe7"
	pulse_color = "#c761d4"
	fail_color = "#525a80"
	looping = TRUE

/obj/structure/destructible/clockwork/sigil/vitality/can_affect(mob/living/affected_mob)
	if((HAS_TRAIT(affected_mob, TRAIT_HUSK) && !IS_CLOCK(affected_mob)) || HAS_TRAIT(affected_mob, TRAIT_NODEATH) || HAS_TRAIT(affected_mob, TRAIT_NO_SOUL))
		return FALSE

	if(!ishuman(affected_mob))
		return FALSE

	return TRUE

/obj/structure/destructible/clockwork/sigil/vitality/dispel_check(mob/user)
	if(active_timer)
		if(IS_CLOCK(user) && tgui_alert(user, "Are you sure you want to dispel [src]? It is currently siphoning [currently_affecting].", "Confirm dispel", list("Yes", "No")) != "Yes")
			return FALSE

/obj/structure/destructible/clockwork/sigil/vitality/apply_effects(mob/living/affected_mob)
	. = ..()
	if(!.)
		return FALSE

	if(IS_CLOCK(affected_mob))
		deltimer(active_timer)
		active_timer = null
		var/revived = FALSE
		if(affected_mob.stat == DEAD)
			var/damage_healed = FREE_DAMAGE_HEALED + ((affected_mob.getMaxHealth() - affected_mob.health) * 0.6)
			if(GLOB.clock_vitality >= damage_healed)
				GLOB.clock_vitality -= damage_healed
				affected_mob.revive(ADMIN_HEAL_ALL)
				revived = TRUE

		if(affected_mob.stat != DEAD && (!affected_mob.client || affected_mob.client.is_afk()))
			set waitfor = FALSE
			var/mob/chosen_one = SSpolling.poll_ghosts_for_target(
				"Do you want to play as a [affected_mob.real_name], an inactive clock cultist?",
				role = ROLE_CLOCK_CULTIST,
				poll_time = 5 SECONDS,
				checked_target = affected_mob,
				alert_pic = affected_mob,
				role_name_text = "clock cultist"
			)
			if(isnull(chosen_one))
				visible_message(span_warning("\The [src] fails to revive [affected_mob]!"))
				fail_invocation()
			else
				to_chat(affected_mob.mind, "Your physical form has been taken over by another soul due to your inactivity! Ahelp if you wish to regain your form.")
				message_admins("[key_name_admin(chosen_one)] has taken control of ([key_name_admin(affected_mob)]) to replace an AFK player.")
				affected_mob.ghostize(FALSE)
				affected_mob.key = chosen_one.key
				revived = TRUE
		if(revived)
			SEND_SOUND(affected_mob, 'sound/magic/clockwork/scripture_tier_up.ogg')
			to_chat(affected_mob, span_bigbrass("\"[text2ratvar("MY LIGHT SHINES THROUGH YOU, YOUR SERVITUDE IS NOT FINISHED.")]\""))
			affected_mob.visible_message(span_warning("[affected_mob] draws in a huge breath, a bright light shining from [affected_mob.p_their()] eyes."), \
									   span_bigbrass("You awaken suddenly from the void. You're alive!"))
		return

	affected_mob.Paralyze(1 SECONDS)
	var/before_drain = affected_mob.getMaxHealth()
	affected_mob.setMaxHealth(before_drain - HEALTH_DRAINED)
	var/after_drain = affected_mob.getMaxHealth()

	if(before_drain == after_drain)
		visible_message(span_clockred("[src] fails to siphon [affected_mob]'s spirit!"))
		return

	playsound(loc, 'sound/magic/clockwork/ratvar_attack.ogg', 40)
	if((affected_mob.stat == DEAD) || affected_mob.getMaxHealth() <= 0)
		playsound(loc, 'sound/magic/exit_blood.ogg', 60)
		to_chat(affected_mob, span_clockred("The last of your life is drained away..."))
		check_special_role(affected_mob)
		GLOB.clock_vitality = min(GLOB.clock_vitality + 40, MAX_CLOCK_VITALITY) // 100 (for clients) total in the ideal situation, since it'll take 6 pulses to go from full to crit
		if(affected_mob.client)
			new /obj/item/robot_suit/prebuilt/clockwork(get_turf(src))
			var/obj/item/mmi/posibrain/soul_vessel/new_vessel = new(get_turf(src))
			if(!is_banned_from(affected_mob.ckey, list(JOB_CYBORG, ROLE_CLOCK_CULTIST)))
				new_vessel.transfer_personality(affected_mob)
		affected_mob.dust(TRUE, TRUE)
		return

	affected_mob.visible_message(span_clockred("[affected_mob] looks weak as the color fades from their body."), span_clockred("You feel your soul faltering..."))
	GLOB.clock_vitality = min(GLOB.clock_vitality + (affected_mob.client ? 10 : 1), MAX_CLOCK_VITALITY) // Monkey or whatever? You get jackshit


/// Checks the role of whoever was killed by the vitality sigil, and does any special code if needed.
/obj/structure/destructible/clockwork/sigil/vitality/proc/check_special_role(mob/living/affected_mob)
	if(IS_CULTIST(affected_mob)) //for now these just give extra vitality, but at some point I need to make them give something unique, maybe the gun?
		send_clock_message(null, span_clockred("The dog of Nar'sie, [affected_mob] has had their vitality drained, rejoice!"))
		GLOB.clock_vitality = min(GLOB.clock_vitality + 20, MAX_CLOCK_VITALITY)
	else if(IS_HERETIC(affected_mob))
		send_clock_message(null, span_clockred("The heretic, [affected_mob] has had their vitality drained, rejoice!"))
		GLOB.clock_vitality = min(GLOB.clock_vitality + 30, MAX_CLOCK_VITALITY)
	else
		send_clock_message(null, span_clockred("[affected_mob] has had their vitality drained by [src], rejoice!"))

#undef FREE_DAMAGE_HEALED
#undef HEALTH_DRAINED
