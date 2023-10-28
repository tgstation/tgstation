/datum/quirk/item_quirk/asthma
	name = "Asthma"
	desc = "You suffer from asthma, a inflammatory disorder that causes your airpipe to squeeze shut! Be careful around smoke!"
	icon = FA_ICON_LUNGS_VIRUS
	value = -4
	gain_text = span_danger("You have a harder time breathing.")
	lose_text = span_notice("You suddenly feel like your lungs just got a lot better at breathing!")
	medical_record_text = "Patient suffers from asthma."
	hardcore_value = 2
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_PROCESSES
	mail_goodies = list(/obj/item/reagent_containers/inhaler_canister/albuterol)

	var/hit_max_mult_at_inflammation_percent = 0.8

	var/inflammation = 0
	var/max_inflammation = 500

	var/passive_inflammation_reduction = 0.15

	var/current_pressure_mult = 1
	var/max_pressure_mult = 0 // cant breathe at all

	var/inflammation_on_smoke = 7.5

	var/histimine_inflammation = 2
	var/histimine_OD_inflammation = 10 // allergic reactions tend to fuck people up

	var/inhaled_albuterol = 0
	var/albuterol_inflammtion_reduction = 5
	var/albuterol_immediate_reduction_mult = 8

	var/alerted_user_to_inflammation = FALSE

	var/datum/disease/asthma_attack/current_attack
	var/time_next_attack_allowed

	var/time_first_attack_can_happen = 0

	var/min_time_between_attacks = 20 MINUTES
	var/max_time_between_attacks = 30 MINUTES

	var/chance_for_attack_to_happen_per_second = 100

/datum/quirk/item_quirk/asthma/add_unique(client/client_source)
	. = ..()

	var/obj/item/inhaler/albuterol/asthma/rescue_inhaler = new(get_turf(quirk_holder))
	give_item_to_holder(rescue_inhaler, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS), flavour_text = "You can use this to quickly relieve the symptoms of your asthma.")

	RegisterSignal(quirk_holder, COMSIG_CARBON_EXPOSED_TO_SMOKE, PROC_REF(holder_exposed_to_smoke))
	RegisterSignal(quirk_holder, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(organ_removed))
	RegisterSignal(quirk_holder, COMSIG_ATOM_REAGENTS_TRANSFERRED_TO, PROC_REF(reagents_transferred))
	RegisterSignal(quirk_holder, COMSIG_CARBON_POST_BREATHE, PROC_REF(holder_breathed))

	time_next_attack_allowed = world.time + time_first_attack_can_happen

/datum/quirk/item_quirk/asthma/remove()
	. = ..()

	current_attack?.cure()
	UnregisterSignal(quirk_holder, COMSIG_CARBON_EXPOSED_TO_SMOKE, COMSIG_CARBON_LOSE_ORGAN, COMSIG_ATOM_REAGENTS_TRANSFERRED_TO, COMSIG_CARBON_POST_BREATHE)

/datum/quirk/item_quirk/asthma/process(seconds_per_tick)
	if(HAS_TRAIT(quirk_holder, TRAIT_STASIS))
		return
	if (quirk_holder.stat == DEAD)
		return
	if (!iscarbon(quirk_holder))
		return

	var/mob/living/carbon/carbon_quirk_holder = quirk_holder
	var/obj/item/organ/internal/lungs/holder_lungs = carbon_quirk_holder.get_organ_slot(ORGAN_SLOT_LUNGS)
	if (!holder_lungs)
		return

	adjust_inflammation(-passive_inflammation_reduction * seconds_per_tick)

	if (carbon_quirk_holder.has_reagent(/datum/reagent/toxin/histamine))
		var/datum/reagent/toxin/histamine/holder_histimine = carbon_quirk_holder.reagents.get_reagent(/datum/reagent/toxin/histamine)
		if (holder_histimine)
			if (holder_histimine.overdosed) // uh oh!
				if (SPT_PROB(15, seconds_per_tick))
					to_chat(carbon_quirk_holder, span_boldwarning("You feel your neck swelling, squeezing on your windpipe more and more!"))
				adjust_inflammation(histimine_OD_inflammation)
			else
				if (SPT_PROB(5, seconds_per_tick))
					to_chat(carbon_quirk_holder, span_warning("You find yourself wheezing a little harder as your neck swells..."))
				adjust_inflammation(histimine_inflammation)

	if (carbon_quirk_holder.has_reagent(/datum/reagent/medicine/albuterol))
		var/datum/reagent/medicine/albuterol/albuterol = carbon_quirk_holder.reagents.get_reagent(/datum/reagent/medicine/albuterol)
		if (isnull(albuterol))
			inhaled_albuterol = 0
		else
			inhaled_albuterol = min(albuterol.volume, inhaled_albuterol)

		if (inhaled_albuterol > 0)
			adjust_inflammation(-(albuterol_inflammtion_reduction * seconds_per_tick))

	else if (carbon_quirk_holder.client &&
			isnull(current_attack) &&
			world.time > time_next_attack_allowed &&
			SPT_PROB(chance_for_attack_to_happen_per_second, seconds_per_tick))

		do_asthma_attack()

/datum/quirk/item_quirk/asthma/proc/do_asthma_attack()
	var/datum/disease/asthma_attack/typepath = pick_weight(GLOB.asthma_attack_rarities)

	current_attack = new typepath
	current_attack.infect(quirk_holder, make_copy = FALSE) // dont leave make_copy on FALSE. worst mistake ive ever made
	RegisterSignal(current_attack, COMSIG_QDELETING, PROC_REF(attack_deleting))

	notify_ghosts("[quirk_holder] is having an asthma attack: [current_attack.name]!", source = quirk_holder, action = NOTIFY_ORBIT, header = "Asthma attack!")

/datum/quirk/item_quirk/asthma/proc/adjust_inflammation(amount, silent = FALSE)
	var/old_inflammation = inflammation

	var/mob/living/carbon/carbon_quirk_holder = quirk_holder
	var/obj/item/organ/internal/lungs/holder_lungs = carbon_quirk_holder.get_organ_slot(ORGAN_SLOT_LUNGS)
	var/health_mult = get_lung_health_mult(holder_lungs)
	if (amount > 0) // make it worse
		amount *= (2 - health_mult)
	else // reduce the reduction
		amount *= health_mult

	inflammation = (clamp(inflammation + amount, 0, max_inflammation))
	var/difference = (old_inflammation - inflammation)
	if (difference != 0)
		holder_lungs?.set_received_pressure_mult(get_pressure_mult())

		if (!silent)
			INVOKE_ASYNC(src, PROC_REF(do_inflammation_change_feedback), difference)

/datum/quirk/item_quirk/asthma/proc/adjust_albuterol_levels(adjustment)
	if (adjustment > 0)
		var/mob/living/carbon/carbon_quirk_holder = quirk_holder
		if (!carbon_quirk_holder.currently_breathing()) // it didnt go into the lungs get fucked
			return

		adjust_inflammation(-(albuterol_inflammtion_reduction * albuterol_immediate_reduction_mult))

	inhaled_albuterol += adjustment

/datum/quirk/item_quirk/asthma/proc/get_pressure_mult()
	var/virtual_max = (max_inflammation * hit_max_mult_at_inflammation_percent)

	return (1 - (min(inflammation/virtual_max, 1)))

/datum/quirk/item_quirk/asthma/proc/do_inflammation_change_feedback(difference)
	var/change_mult = 1 + (difference / 300)
	if (difference > 0) // it decreased
		if (prob(2 * change_mult))
			to_chat(quirk_holder, span_notice("The phlem in your throat forces you to cough!"))
			quirk_holder.emote("cough")

	else if (difference < 0)// it increased
		if (prob(5 * change_mult))
			quirk_holder.emote("wheeze")
		if (prob(15 * change_mult))
			to_chat(quirk_holder, span_warning("You feel your windpipe tightening..."))

/datum/quirk/item_quirk/asthma/proc/get_lung_health_mult()
	var/mob/living/carbon/carbon_quirk_holder = quirk_holder
	var/obj/item/organ/internal/lungs/holder_lungs = carbon_quirk_holder.get_organ_slot(ORGAN_SLOT_LUNGS)
	if (isnull(holder_lungs))
		return 1
	if (holder_lungs.organ_flags & ORGAN_FAILING)
		return 0
	return (1 - (holder_lungs.damage / holder_lungs.maxHealth))

/datum/quirk/item_quirk/asthma/proc/holder_exposed_to_smoke(datum/signal_source, mob/living/carbon/smoker, seconds_per_tick)
	SIGNAL_HANDLER

	adjust_inflammation(inflammation_on_smoke * seconds_per_tick)

/datum/quirk/item_quirk/asthma/proc/organ_removed(datum/signal_source, obj/item/organ/removed)
	SIGNAL_HANDLER

	if (istype(removed, /obj/item/organ/internal/lungs))
		reset_asthma()

/datum/quirk/item_quirk/asthma/proc/reagents_transferred(datum/signal_source, datum/reagents/transferrer, list/datum/reagent/transferred_reagents, final_total, mob/transferred_by, methods, ignore_stomach)
	SIGNAL_HANDLER

	if (!(methods & INHALE))
		return
	if (istype(transferrer.my_atom, /obj/item/clothing/mask/cigarette)) // smoking is bad, kids
		adjust_inflammation(inflammation_on_smoke * final_total * 5)

	for (var/list/data as anything in transferred_reagents)
		var/datum/reagent/reagent = data["R"]
		if (istype(reagent, /datum/reagent/medicine/albuterol))
			var/transfer_amount = data["T"]
			adjust_albuterol_levels(transfer_amount)

/datum/quirk/item_quirk/asthma/proc/holder_breathed(datum/signal_source, result, datum/gas_mixture/breath)
	SIGNAL_HANDLER

	if (HAS_TRAIT(quirk_holder, TRAIT_NOBREATH))
		return
	if (result) // successful breath
		alerted_user_to_inflammation = FALSE
	else if (!alerted_user_to_inflammation && inflammation > 0)
		alerted_user_to_inflammation = TRUE
		to_chat(quirk_holder, span_danger("You feel like you can't get enough air in your lungs! \
		If you think it's your asthma, you can try using a <b>high-pressured internals tank</b>!"))

/datum/quirk/item_quirk/asthma/proc/attack_deleting(datum/signal_source)
	SIGNAL_HANDLER

	UnregisterSignal(current_attack, COMSIG_QDELETING)
	current_attack = null

	time_next_attack_allowed = rand(min_time_between_attacks, max_time_between_attacks)

/datum/quirk/item_quirk/asthma/proc/reset_asthma()
	inflammation = 0
	var/mob/living/carbon/carbon_quirk_holder = quirk_holder
	var/obj/item/organ/internal/lungs/holder_lungs = carbon_quirk_holder.get_organ_slot(ORGAN_SLOT_LUNGS)
	holder_lungs?.set_received_pressure_mult(initial(holder_lungs.received_pressure_mult))
