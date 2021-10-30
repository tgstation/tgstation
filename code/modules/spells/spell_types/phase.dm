/obj/effect/proc_holder/spell/self/phase
	name = "Phase"
	desc = "Phase through objects for a short moment."

	school = SCHOOL_TRANSMUTATION
	charge_max = 10 SECONDS
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	cooldown_min = 2 SECONDS
	action_icon = 'icons/mob/actions/actions_animal.dmi'
	action_icon_state = "phase"
	action_background_icon_state = "bg_demon"
	var/phase_time = 15 //The amount of time the mob phases for.
	var/alpha_amount = 120 //The strength of the phasing invisability.

/obj/effect/proc_holder/spell/self/phase/cast(list/targets, mob/user = usr)
	. = ..()
	user.alpha = alpha_amount
	move_resist = MOVE_FORCE_OVERPOWERING
	user.pass_flags = PASSGLASS | PASSTABLE | PASSGRILLE | PASSMOB | PASSCLOSEDTURF | PASSMACHINE | PASSSTRUCTURE | PASSFLAPS | PASSDOORS
	addtimer(CALLBACK(src, .proc/Rephase), phase_time)

/obj/effect/proc_holder/spell/self/phase/proc/Rephase(list/targets, mob/user = usr)
	user.alpha = initial(user.alpha)
	user.move_resist = initial(user.move_resist)
	user.pass_flags = initial(user.pass_flags)
