/datum/action/changeling/smoke_screen
	name = "Smoke Screen"
	desc = "We vaporize some of our blood to create a smoke cloud while steahlthy injecting hallucination reagents into nearby humans."
	helptext = "Create a smoke cloud and confuses nearby people, causing them to see everyone to have the same appearance as you"
	button_icon_state = "smoke_screen"
	chemical_cost = 20
	dna_cost = 1

/datum/action/changeling/smoke_screen/sting_action(mob/living/user, mob/living/target)
	. = ..()
	var/mob/living/carbon/our_ling = user
	for(var/dir in GLOB.alldirs)
		our_ling.spray_blood(dir)
	var/datum/effect_system/fluid_spread/smoke/blood_smoke/smoke_screen = new()
	smoke_screen.set_up(8, holder = user, location = user.loc)
	smoke_screen.start()
	return TRUE

/datum/effect_system/fluid_spread/smoke/blood_smoke
	effect_type = /obj/effect/particle_effect/fluid/smoke/red

/obj/effect/particle_effect/fluid/smoke/red
	name = "red smoke"
	color = COLOR_MAROON
	opacity = FALSE
	lifetime = 15 SECONDS

/obj/effect/particle_effect/fluid/smoke/red/smoke_mob(mob/living/carbon/smoker, seconds_per_tick)
	. = ..()
	if(!ishuman(smoker))
		return
	var/mob/living/carbon/human/poor_sod = smoker
	poor_sod.add_blood_DNA_to_items(poor_sod.get_blood_dna_list())
