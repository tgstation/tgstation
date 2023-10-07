/datum/outfit/slasher
	name = "Slasher Outfit"
	suit = /obj/item/clothing/suit/apron/slasher
	uniform = /obj/item/clothing/under/color/random/slasher
	shoes = /obj/item/clothing/shoes/slasher_shoes
	mask = /obj/item/clothing/mask/gas/slasher

/datum/antagonist/slasher
	name = "\improper Slasher"
	show_in_antagpanel = TRUE
	roundend_category = "slashers"
	antagpanel_category = "Slasher"
	job_rank = ROLE_SLASHER
	antag_hud_name = "slasher"
	show_name_in_check_antagonists = TRUE
	hud_icon = 'monkestation/icons/mob/slasher.dmi'
	preview_outfit = /datum/outfit/slasher

	var/obj/item/slasher_machette/linked_machette
	var/breath_out = FALSE
	///rallys the amount of souls effects are based on this
	var/souls_sucked = 0
	///when we sucked our last soul in world time
	var/last_soul_sucked = 0

/datum/antagonist/slasher/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current

	ADD_TRAIT(current_mob, TRAIT_BATON_RESISTANCE, "slasher")
	ADD_TRAIT(current_mob, TRAIT_CLUMSY, "slasher")
	ADD_TRAIT(current_mob, TRAIT_DUMB, "slasher")
	ADD_TRAIT(current_mob, TRAIT_NODEATH, "slasher")
	ADD_TRAIT(current_mob, TRAIT_LIMBATTACHMENT, "slasher")
	ADD_TRAIT(current_mob, TRAIT_NIGHT_VISION, "slasher")

	RegisterSignal(current_mob, COMSIG_LIVING_LIFE, PROC_REF(LifeTick))

	///abilities galore
	var/datum/action/cooldown/slasher/summon_machette/machete = new
	machete.Grant(current_mob)
	var/datum/action/cooldown/slasher/blood_walk/blood_walk = new
	blood_walk.Grant(current_mob)
	var/datum/action/cooldown/slasher/incorporealize/incorporealize = new
	incorporealize.Grant(current_mob)
	var/datum/action/cooldown/slasher/soul_steal/soul_steal = new
	soul_steal.Grant(current_mob)
	var/datum/action/cooldown/slasher/regenerate/regenerate = new
	regenerate.Grant(current_mob)
	var/datum/action/cooldown/slasher/terror/terror = new
	terror.Grant(current_mob)

	var/mob/living/carbon/human/human = current_mob
	human.equipOutfit(/datum/outfit/slasher)

/datum/antagonist/slasher/proc/LifeTick(mob/living/source, seconds_per_tick, times_fired)
	if(breath_out)
		source.emote("exhale")
		breath_out = FALSE
	else
		source.emote("inhale")
		breath_out = TRUE

	for(var/mob/living/carbon/human in view(7, source))
		if(human == source)
			continue
		human.playsound_local(human, 'sound/health/slowbeat.ogg', 40, FALSE, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)

	for(var/obj/machinery/light/listed_light in view(3, source))
		if(prob(10))
			listed_light.break_light_tube()

	var/turf/TT = get_turf(source)
	var/turf/T = pick(RANGE_TURFS(4,TT))

	if(prob(5))
		new /obj/effect/gibspawner/generic(T)
