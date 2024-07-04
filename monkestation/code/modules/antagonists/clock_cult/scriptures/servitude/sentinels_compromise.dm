/datum/scripture/slab/sentinels_compromise
	name = "Sentinel's Compromise"
	desc = "Heals a large amount of non-toxin damage on a target then converts 50% of it back as toxin damage to you."
	tip = "Works well with Properity Prisms. Cannot be used by cogscarabs."
	power_cost = 80
	cogs_required = 1
	invocation_time = 1 SECONDS //short invocation but using it also takes some time afterwards
	invocation_text = list("By the light of Eng'Ine...") //the second line is said when used on someone
	button_icon_state = "Sentinel's Compromise"
	category = SPELLTYPE_SERVITUDE //you have a healing spell please please PLEASE use it
	slab_overlay = "compromise"
	use_time = 15 SECONDS
	recital_sound = 'sound/magic/magic_missile.ogg'
	fast_invoke_mult = 0.8

/datum/scripture/slab/sentinels_compromise/check_special_requirements(mob/user)
	if(issilicon(user))
		invocation_time = 10 * initial(invocation_time)
	else
		invocation_time = initial(invocation_time) //might be worth making a silicon_invoke() proc or something
	return ..()

/datum/scripture/slab/sentinels_compromise/apply_effects(mob/living/healed_mob)
	if(!istype(healed_mob) || !IS_CLOCK(invoker) || !IS_CLOCK(healed_mob))
		return FALSE

	if(iscogscarab(invoker))
		to_chat(invoker, span_warning("Your form is too frail to take the burden of another."))
		return FALSE

	if(!do_after(invoker, invocation_time, healed_mob))
		return FALSE

	healed_mob.cure_husk()

	if(healed_mob.stat == DEAD) //technically the husk healing is free but it should be fine
		return FALSE

	clockwork_say(invoker, text2ratvar("Wounds will close."), TRUE)

	//MMMMMM, CHUNKY
	var/total_damage = (healed_mob.getBruteLoss() + healed_mob.getFireLoss() + healed_mob.getOxyLoss() + healed_mob.getCloneLoss()) * 0.6
	healed_mob.stamina.adjust(healed_mob.staminaloss * 0.6)
	healed_mob.adjustBruteLoss(-healed_mob.getBruteLoss() * 0.6)
	healed_mob.adjustFireLoss(-healed_mob.getFireLoss() * 0.6)
	healed_mob.adjustOxyLoss(-healed_mob.getOxyLoss() * 0.6)
	healed_mob.adjustCloneLoss(-healed_mob.getCloneLoss() * 0.6)
	healed_mob.blood_volume = BLOOD_VOLUME_NORMAL
	healed_mob.set_nutrition(NUTRITION_LEVEL_FULL)
	healed_mob.bodytemperature = BODYTEMP_NORMAL
	healed_mob.reagents.remove_reagent(/datum/reagent/water/holywater, 100) //if you have over 100 units of holy water then it should take multiple to purge
	healed_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, -50)

	new /obj/effect/temp_visual/heal(get_turf(healed_mob), "#1E8CE1")

	invoker.adjustToxLoss(min(total_damage * 0.5, 80), forced = TRUE)
	return TRUE
