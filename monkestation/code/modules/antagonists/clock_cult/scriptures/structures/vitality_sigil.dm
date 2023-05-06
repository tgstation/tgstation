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
	if(affected_mob.stat == DEAD)
		return FALSE

	if(affected_mob.can_block_magic(MAGIC_RESISTANCE_HOLY))
		return FALSE

	if(HAS_TRAIT(affected_mob, TRAIT_NODEATH))
		return FALSE

	if(!ishuman(affected_mob))
		return FALSE

	return TRUE


/obj/structure/destructible/clockwork/sigil/vitality/apply_effects(mob/living/affected_mob)
	. = ..()
	if(!.)
		return FALSE

	if(IS_CLOCK(affected_mob))
		return

	if(affected_mob.can_block_magic(MAGIC_RESISTANCE_HOLY))
		return

	affected_mob.Paralyze(1 SECONDS)

	var/before_cloneloss = affected_mob.getCloneLoss()
	affected_mob.adjustCloneLoss(20, TRUE, TRUE)
	var/after_cloneloss = affected_mob.getCloneLoss()

	if(before_cloneloss == after_cloneloss)
		visible_message(span_clockred("[src] fails to siphon [affected_mob]'s spirit!"))
		return

	playsound(loc, 'sound/magic/clockwork/ratvar_attack.ogg', 40)
	if((affected_mob.stat == DEAD) || (affected_mob.getCloneLoss() >= affected_mob.maxHealth))
		affected_mob.do_jitter_animation()
		affected_mob.death()
		playsound(loc, 'sound/magic/exit_blood.ogg', 60)
		to_chat(affected_mob, span_clockred("The last of your life is drained away..."))
		check_special_role(affected_mob)
		GLOB.clock_vitality += (affected_mob.client ? 30 : 10) // 100 (for clients) total in the ideal situation, since it'll take 7 pulses to go from full to crit
		return

	affected_mob.visible_message(span_clockred("[affected_mob] looks weak as the color fades from their body."), span_clockred("You feel your soul faltering..."))
	GLOB.clock_vitality += (affected_mob.client ? 10 : 0) // Monkey or whatever? You get jackshit


/// Checks the role of whoever was killed by the vitality sigil, and does any special code if needed.
/obj/structure/destructible/clockwork/sigil/vitality/proc/check_special_role(mob/living/affected_mob)
	if(IS_CULTIST(affected_mob))
		send_clock_message(null, "The dog of Nar'sie, [affected_mob] has had their vitality drained, rejoice!", "<span class='clockred'>")
		spawn_reebe(src)
	else
		send_clock_message(null, "[affected_mob] has had their vitality drained by [src], rejoice!", "<span class='clockred'>")


