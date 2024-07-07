/datum/component/heart_eater
	/// Check if we fully ate whole heart and reset when we start eat new one.
	var/bites_taken = 0
	/// Remember last heart we ate and reset bites_taken counter if we start eat new one
	var/datum/weakref/last_heart_we_ate
	/// List of all mutations allowed to get.
	var/list/datum/mutation/human/mutations_list = list(
		/datum/mutation/human/adaptation/cold,
		/datum/mutation/human/adaptation/heat,
		/datum/mutation/human/adaptation/pressure,
		/datum/mutation/human/adaptation/thermal,
		/datum/mutation/human/chameleon,
		/datum/mutation/human/cryokinesis,
		/datum/mutation/human/cryokinesis/pyrokinesis,
		/datum/mutation/human/dwarfism,
		/datum/mutation/human/geladikinesis/ash,
		/datum/mutation/human/insulated,
		/datum/mutation/human/telekinesis,
		/datum/mutation/human/telepathy,
		/datum/mutation/human/thermal,
		/datum/mutation/human/tongue_spike,
		/datum/mutation/human/webbing,
		/datum/mutation/human/xray,
	)

/datum/component/heart_eater/Initialize(...)
	. = ..()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/heart_eater/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_LIVING_FINISH_EAT, PROC_REF(eat_eat_eat))

/datum/component/heart_eater/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_LIVING_FINISH_EAT)

/datum/component/heart_eater/proc/eat_eat_eat(mob/living/carbon/human/eater, datum/what_we_ate, mob/living/feeder)
	SIGNAL_HANDLER

	if(get_area(eater) == GLOB.areas_by_type[/area/centcom/wizard_station])
		return
	if(!istype(what_we_ate, /obj/item/organ/internal/heart))
		return
	var/obj/item/organ/internal/heart/we_ate_heart = what_we_ate
	if(isnull(last_heart_we_ate))
		return
	if(we_ate_heart == last_heart_we_ate)
		return
	bites_taken = 0

	last_heart_we_ate = WEAKREF(we_ate_heart)
	bites_taken++
	if(bites_taken % 4 == 0)
		if(prob(50))
			eater.maxHealth += 25
			eater.max_stamina += 25
			to_chat(eater, span_warning("This heart is perfect. You feel a surge of vital energy."))
			return
		else
			eater.maxHealth *= 0.9
			var/datum/mutation/human/new_mutation = pick(mutations_list)
			eater.dna.add_mutation(new_mutation)
			to_chat(eater, span_warning("This heart is not right for you. You now have [new_mutation.name] mutation."))
			return
