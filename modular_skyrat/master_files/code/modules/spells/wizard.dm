/*
// AND SO BEGINS THE GLORIOUS MODULAR SPELL ADDITION SPOT.
// PUT ALL NEWLY CREATED WIZARD SPELLS HERE!
*/

/obj/effect/proc_holder/spell/targeted/stimpack
	name = "Magic Stimpack"
	desc = "This spell magically injects stimulants straight into your blood. Won't work on species with no reagent reactions!"

	school = "transmutation"
	charge_max = 450
	clothes_req = FALSE
	invocation = "STIMULUS CHEQ'US"
	invocation_type = INVOCATION_SHOUT
	range = -1
	include_user = TRUE

	cooldown_min = 300 //37.5 deciseconds reduction per rank
	action_icon_state = "spell_default"

/obj/effect/proc_holder/spell/targeted/stimpack/cast(mob/living/user)
	..()
	to_chat(user, "<span class='notice'>Time appears to slow as your bodily functions rapidly speed up.</span>")
	user.SetKnockdown(0)
	user.setStaminaLoss(0)
	user.set_resting(FALSE)
	user.reagents.add_reagent(/datum/reagent/medicine/stimulants, 3) //Ideally this comes out to a bit less than 30 seconds with tidi taken into account.
	return TRUE
