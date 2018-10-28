/datum/mutation/human/telepathy
	name = "Telepathy"
	desc = "A rare mutation that allows the user to telephaticly communicate to others."
	quality = POSITIVE
	lowest_value = 256 * 12
	get_chance = 70
	text_gain_indication = "<span class='notice'>You can hear your own voice echoing in your mind!</span>"
	text_lose_indication = "<span class='notice'>You don't hear your mind echo anymore.</span>"
	power = /obj/effect/proc_holder/spell/targeted/telepathy/genetic
	instability = 10

/datum/mutation/human/telepathy/on_acquiring(mob/living/carbon/human/owner)
	. = ..()

/datum/mutation/human/telepathy/on_losing(mob/living/carbon/human/owner)
	. = ..()

/obj/effect/proc_holder/spell/targeted/telepathy/genetic
	magic_check = FALSE

/datum/mutation/human/firebreath
	name = "Fire Breath"
	desc = "An ancient mutation that gives lizards breath of fire."
	quality = POSITIVE
	lowest_value = 256 * 12
	get_chance = 20
	locked = TRUE
	text_gain_indication = "<span class='notice'>Your throat is burning!</span>"
	text_lose_indication = "<span class='notice'>Your throat is cooling down.</span>"
	power = /obj/effect/proc_holder/spell/aimed/firebreath
	instability = 40

/obj/effect/proc_holder/spell/aimed/firebreath
	name = "Fire Breath"
	desc = "You can breath fire at a target."
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
			to_chat(C,"<span class='warning'>Something infront of your mouth caught fire!</span>")
			return FALSE

/obj/item/projectile/magic/aoe/fireball/firebreath
	name = "fire breath"
	exp_heavy = 0
	exp_light = 0
	exp_flash = 0
	exp_fire= 4



