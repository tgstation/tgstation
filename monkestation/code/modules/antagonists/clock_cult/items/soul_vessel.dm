/obj/item/mmi/posibrain/soul_vessel
	name = "Soul Vessel"
	desc = "A cube made of gear, made to capture and store the vitality of living beings."
	icon = 'monkestation/icons/obj/clock_cult/clockwork_objects.dmi'
	icon_state = "soul_vessel"
	base_icon_state = "soul_vessel"
	req_access = list()
	begin_activation_message = span_notice("You start spinning the gears of the Soul Vessel.")
	success_message = span_notice("The gears of the Soul Vessel start spinning at a steady rate, it looks as though it has found a willing soul!")
	fail_message = span_notice("The gears of the Soul Vessel stop spinning. It looks as though it has run out of energy for now, but you could grant it more.")
	new_mob_message = span_notice("The Soul Vessel starts making a steady ticking sound.")
	dead_message = span_deadsay("It's gears are not moving.")
	recharge_message = span_warning("The gears of the Soul Vessel are already spinning.")

/obj/item/mmi/posibrain/soul_vessel/Initialize(mapload, autoping)
	. = ..()
	laws = new /datum/ai_laws/ratvar()
	radio.set_on(FALSE)
	if(!brainmob) //we might be forcing someone into it right away
		set_brainmob(new /mob/living/brain(src))
