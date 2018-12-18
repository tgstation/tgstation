/datum/mutation/human/telepathy
	name = "Telepathy"
	desc = "A rare mutation that allows the user to telepathically communicate to others."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>You can hear your own voice echoing in your mind!</span>"
	text_lose_indication = "<span class='notice'>You don't hear your mind echo anymore.</span>"
	difficulty = 12
	power = /obj/effect/proc_holder/spell/targeted/telepathy
	instability = 10

/datum/mutation/human/telepathy/on_acquiring(mob/living/carbon/human/owner)
	. = ..()

/datum/mutation/human/telepathy/on_losing(mob/living/carbon/human/owner)
	. = ..()

/datum/mutation/human/firebreath
	name = "Fire Breath"
	desc = "An ancient mutation that gives lizards breath of fire."
	quality = POSITIVE
	difficulty = 12
	locked = TRUE
	text_gain_indication = "<span class='notice'>Your throat is burning!</span>"
	text_lose_indication = "<span class='notice'>Your throat is cooling down.</span>"
	power = /obj/effect/proc_holder/spell/aimed/firebreath
	instability = 30

/obj/effect/proc_holder/spell/aimed/firebreath
	name = "Fire Breath"
	desc = "You can breathe fire at a target."
	school = "evocation"
	charge_max = 600
	clothes_req = FALSE
	range = 20
	projectile_type = /obj/item/projectile/magic/aoe/fireball/firebreath
	base_icon_state = "fireball"
	action_icon_state = "fireball0"
	sound = 'sound/magic/demon_dies.ogg' //horrifying lizard noises
	active_msg = "You built up heat in your mouth."
	deactive_msg = "You swallow the flame."

/obj/effect/proc_holder/spell/aimed/firebreath/before_cast(list/targets)
	. = ..()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		if(C.is_mouth_covered())
			C.adjust_fire_stacks(2)
			C.IgniteMob()
			to_chat(C,"<span class='warning'>Something in front of your mouth caught fire!</span>")
			return FALSE

/obj/item/projectile/magic/aoe/fireball/firebreath
	name = "fire breath"
	exp_heavy = 0
	exp_light = 0
	exp_flash = 0
	exp_fire= 4

/datum/mutation/human/void
	name = "Void Magnet"
	desc = "A rare genome that attracts odd forces not usually observed."
	quality = MINOR_NEGATIVE //upsides and downsides
	text_gain_indication = "<span class='notice'>You feel a heavy, dull force just beyond the walls watching you.</span>"
	instability = 30
	power = /obj/effect/proc_holder/spell/self/void

/datum/mutation/human/void/on_life()
	var/obj/effect/proc_holder/spell/self/void/voidpower = power
	if(voidpower.in_use) //i don't know how rare this is but coughs are 10% on life so in theory this should be okay
		return
	if(prob(0.5+((100-dna.stability)/20))) //very rare, but enough to annoy you hopefully. +0.5 probability for every 10 points lost in stability
		if(voidpower.action)
			voidpower.action.UpdateButtonIcon()
		voidpower.invocation_type = "none"
		voidpower.cast(user=owner)

/obj/effect/proc_holder/spell/self/void
	name = "Convoke Void" //magic the gathering joke here
	desc = "A rare genome that attracts odd forces not usually observed. May sometimes pull you in randomly."
	school = "evocation"
	clothes_req = FALSE
	charge_max = 600
	invocation = "DOOOOOOOOOOOOOOOOOOOOM!!!"
	invocation_type = "shout"
	action_icon_state = "void_magnet"
	var/in_use = FALSE //so it doesnt cast while you are already deep innit

/obj/effect/proc_holder/spell/self/void/can_cast(mob/user = usr)
	. = ..()
	if(in_use)
		return FALSE

/obj/effect/proc_holder/spell/self/void/cast(mob/user = usr)
	in_use = TRUE
	user.visible_message("<span class='danger'>[user] is dragged into the void, leaving a hole in [user.p_their()] place!</span>")
	var/obj/effect/immortality_talisman/Z = new(get_turf(user))
	Z.name = "hole in reality"
	Z.desc = "It's shaped an awful lot like [user.name]."
	Z.setDir(user.dir)
	user.forceMove(Z)
	user.notransform = 1
	user.status_flags |= GODMODE
	addtimer(CALLBACK(src, .proc/return_to_reality, user, Z), 100)

/obj/effect/proc_holder/spell/self/void/proc/return_to_reality(mob/user, obj/effect/immortality_talisman/Z)
	in_use = FALSE
	invocation_type = initial(invocation_type)
	user.status_flags &= ~GODMODE
	user.notransform = 0
	user.forceMove(get_turf(Z))
	user.visible_message("<span class='danger'>[user] pops back into reality!</span>")
	Z.can_destroy = TRUE
	qdel(Z)