//APPLY THESE LAST ALWAYS SO THEY CAN SOAK UP PROPERTIES AND DON'T REPLACE THEM FOREVER THANK YOU REEEEEEE

/datum/relic_effect/toggle
	var/toggled = 0
	var/max_toggle = 1
	hogged_signals = list(COMSIG_ITEM_ATTACK_SELF)
	hint = list("It has a prominent lever on its side.","It spouts a large dial.")

/datum/relic_effect/toggle/apply_to_component(obj/item/A,datum/component/relic/comp)
	comp.RegisterSignal(COMSIG_ITEM_ATTACK_SELF, CALLBACK(src, .proc/toggle, A))

/datum/relic_effect/toggle/proc/toggle(obj/item/A,mob/user)
	var/datum/component/relic/comp = A.GetComponent(/datum/component/relic)
	if(!comp.can_use())
		return FALSE
	toggled = (toggled + 1) % (max_toggle + 1)

/datum/relic_effect/toggle/activate //These are multiactivators basicly
	weight = 20
	hogged_signals = list(COMSIG_ITEM_ATTACK_SELF,COMSIG_ITEM_AFTER_ATTACK)
	var/list/internals = list()

/datum/relic_effect/toggle/activate/init()
	var/times = rand(2,4)
	var/list/subtypes = subtypesof(/datum/relic_effect/activate)
	for(var/i in 1 to times)
		var/internaltype = pick_n_take(subtypes)
		var/datum/relic_effect/activate/internal = new internaltype()
		internal.init()
		internal.range = rand(1,3) //Make sure they don't hog attack_self
		internal.free = TRUE
		internals += internal
	max_toggle = internals.len-1

/datum/relic_effect/toggle/activate/apply_to_component(obj/item/A,datum/component/relic/comp)
	comp.RegisterSignal(COMSIG_ITEM_AFTER_ATTACK, CALLBACK(src, .proc/activate, A))

/datum/relic_effect/toggle/activate/proc/activate(obj/item/A, mob/living/target, mob/living/user)
	var/datum/relic_effect/activate/internal = internals[toggled+1]

	if(..())
		internal.activate(A,target,user)

/datum/relic_effect/toggle/light
	weight = 10
	hint = list("It has a prominent lightswitch.")
	var/orig_light_color
	var/orig_power
	var/orig_range
	var/new_light_color
	var/new_power
	var/new_range

/datum/relic_effect/toggle/light/init()
	if(prob(50))
		new_light_color = pick(LIGHT_COLOR_GREEN,LIGHT_COLOR_RED,LIGHT_COLOR_YELLOW,LIGHT_COLOR_BLUE,LIGHT_COLOR_CYAN,LIGHT_COLOR_ORANGE,LIGHT_COLOR_PINK)
	if(prob(50))
		new_power = rand(1,6)
	if(prob(20)) //darklight
		new_power = -new_power / 4
	new_range = rand(1,20) * 0.5

/datum/relic_effect/toggle/light/apply(obj/item/A)
	orig_light_color = A.light_color
	orig_power = A.light_power
	orig_range = A.light_range

/datum/relic_effect/toggle/light/toggle(obj/item/A,mob/user)
	if(!..())
		return
	if(user)
		to_chat(user, "<span class='notice'>You turn [toggled?"on":"off"] [A].</span>")
	if(toggled)
		A.light_color = new_light_color
		A.set_light(l_range = new_range, l_power = new_power)
	else
		A.light_color = orig_light_color
		A.set_light(l_range = orig_range, l_power = orig_power)