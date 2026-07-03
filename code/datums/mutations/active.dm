/datum/mutation/adrenaline_rush
	name = "Adrenaline Rush"
	desc = "Позволяет обладателю данной мутации при желании наполнить своё тело адреналином."
	quality = POSITIVE
	text_gain_indication = span_notice("Ты чувствуешь себя накаченным!")
	instability = POSITIVE_INSTABILITY_MODERATE
	power_path = /datum/action/cooldown/adrenaline

	energy_coeff = 1
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/adrenaline_rush/setup()
	. = ..()
	var/datum/action/cooldown/adrenaline/to_modify = .
	if(!istype(to_modify)) // null or invalid
		return

	to_modify.adrenaline_amount = 10 * GET_MUTATION_POWER(src)
	to_modify.comedown_amount = 7 / GET_MUTATION_SYNCHRONIZER(src)

/datum/action/cooldown/adrenaline
	name = "Adrenaline!"
	desc = "Energize yourself, pushing your body to its limits!"
	button_icon = 'icons/mob/actions/actions_genetic.dmi'
	button_icon_state = "adrenaline"

	cooldown_time = 2 MINUTES
	check_flags = AB_CHECK_CONSCIOUS
	/// How many units of each positive reagent injected during adrenaline.
	var/adrenaline_amount = 10
	/// How many units of each negative reagent injected after comedown.
	var/comedown_amount = 7


/datum/action/cooldown/adrenaline/Activate(mob/living/carbon/cast_on)
	. = ..()
	to_chat(cast_on, span_userdanger("You feel pumped up! It's time to GO!"))
	cast_on.reagents.add_reagent(/datum/reagent/drug/pumpup, adrenaline_amount)
	cast_on.reagents.add_reagent(/datum/reagent/medicine/synaptizine, adrenaline_amount)
	cast_on.reagents.add_reagent(/datum/reagent/determination, adrenaline_amount)
	addtimer(CALLBACK(src, PROC_REF(get_tired), cast_on), 25 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)
	return TRUE

/datum/action/cooldown/adrenaline/proc/get_tired(mob/living/carbon/cast_on)
	to_chat(cast_on, span_danger("Your adrenaline rush makes way for a bout of nausea and a deep feeling of exhaustion in your muscles."))
	cast_on.reagents.add_reagent(/datum/reagent/peaceborg/tire, comedown_amount)
	cast_on.reagents.add_reagent(/datum/reagent/peaceborg/confuse, comedown_amount)
	cast_on.set_dizzy_if_lower(10 SECONDS)
