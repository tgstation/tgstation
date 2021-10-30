/obj/effect/proc_holder/spell/self/disappear
	name = "Disappear"
	desc = "This spell will make you nearly invisible for a few seconds."

	school = SCHOOL_TRANSMUTATION
	charge_max = 25 SECONDS
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	cooldown_min = 5 SECONDS
	action_icon = 'icons/mob/actions/actions_mime.dmi'
	action_icon_state = "mime_disappear"
	action_background_icon_state = "bg_mime"
	var/disappear_time = 25 //The amount of time the mob disappears for.
	var/alpha_amount = 10 //The strength of the invisability.

/obj/effect/proc_holder/spell/self/disappear/cast(list/targets, mob/user = usr)
	. = ..()
	user.alpha = alpha_amount
	addtimer(CALLBACK(src, .proc/Reappear), disappear_time)

/obj/effect/proc_holder/spell/self/disappear/proc/Reappear(list/targets, mob/user = usr)
	user.alpha = initial(user.alpha)
