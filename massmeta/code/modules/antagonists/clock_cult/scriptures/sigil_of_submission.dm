//==================================//
// !      Sigil of Submission     ! //
//==================================//
/datum/clockcult/scripture/create_structure/sigil_submission
	name = "Сигил подчинения"
	desc = "Вызывает сигил подчинения, который обращает любого, кто помещен на нее, в веру Рат'вара."
	tip = "Превратите экипаж в слуг, используя сигил подчинения."
	button_icon_state = "Sigil of Submission"
	power_cost = 250
	invokation_time = 50
	invokation_text = list("Расслабься, животное...", "потому что я покажу тебе правду.")
	summoned_structure = /obj/structure/destructible/clockwork/sigil/submission
	cogs_required = 1
	category = SPELLTYPE_SERVITUDE

//==========Submission=========
/obj/structure/destructible/clockwork/sigil/submission
	name = "сигил подчинения"
	desc = "Странный сигил с потусторонними рисунками на нём."
	clockwork_desc = "Сигил, пульсирующий великолепным светом. Любой, кто удержится на этом, станет верным слугой Рат'вара."
	icon_state = "sigilsubmission"
	effect_stand_time = 80
	idle_color = "#FFFFFF"
	invokation_color = "#e042d8"
	pulse_color = "#EBC670"
	fail_color = "#d43333"

/obj/structure/destructible/clockwork/sigil/submission/can_affect(mob/living/M)
	if(!..())
		return FALSE
	return is_convertable_to_clockcult(M)

/obj/structure/destructible/clockwork/sigil/submission/apply_effects(mob/living/M)
	if(!..())
		M.visible_message(span_warning("[M] сопротивляется!"))
		return FALSE
	M.Paralyze(50)
	if(M.client)
		var/previous_colour = M.client.color
		M.client.color = LIGHT_COLOR_CLOCKWORK
		animate(M.client, color=previous_colour, time=10)
	var/datum/antagonist/servant_of_ratvar/R = add_servant_of_ratvar(M)
	R.equip_servant_conversion()
