/datum/component/heart_eater
	var/heart_eated
	var/bites_done
	var/obj/item/organ/internal/heart/last_heart_we_ate
	var/list/datum/mutation/human/mutations_list = list(
		/datum/mutation/human/telekinesis,
		/datum/mutation/human/telepathy,
		/datum/mutation/human/temperature_adaptation,
		/datum/mutation/human/pressure_adaptation,
		/datum/mutation/human/xray,
		/datum/mutation/human/thermal,
		/datum/mutation/human/insulated,
		/datum/mutation/human/webbing,
		/datum/mutation/human/chameleon,
		/datum/mutation/human/tongue_spike,
		/datum/mutation/human/dwarfism,
		/datum/mutation/human/cryokinesis
	)

/datum/component/heart_eater/Initialize(...)
	. = ..()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/heart_eater/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_CARBON_FINISH_EAT, PROC_REF(eat_eat_eat))

/datum/component/heart_eater/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_CARBON_FINISH_EAT)

/datum/component/heart_eater/proc/eat_eat_eat(mob/living/carbon/human/eater, datum/what_we_ate, mob/living/feeder)
	SIGNAL_HANDLER

	if(get_area(eater) == GLOB.areas_by_type[/area/centcom/wizard_station])
		return
	if(!istype(what_we_ate, /obj/item/organ/internal/heart))
		return
	var/obj/item/organ/internal/heart/we_ate_heart = what_we_ate
	if(!isnull(last_heart_we_ate))
		if(we_ate_heart != last_heart_we_ate)
			bites_done = 0

	last_heart_we_ate = we_ate_heart
	bites_done++
	if(bites_done % 4 == 0)
		heart_eated++
		if(prob(50))
			eater.maxHealth += 25
			eater.max_stamina += 25
			to_chat(eater, span_warning("This heart is perfect. You feel a surge of vital energy."))
			return
		else
			eater.maxHealth -= eater.maxHealth % 10
			var/datum/mutation/human/new_mutation = pick(mutations_list)
			eater.dna.add_mutation(new_mutation)
			to_chat(eater, span_warning("This heart is not right for you. You now have [new_mutation.name] mutation."))
			return
