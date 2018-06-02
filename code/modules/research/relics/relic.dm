/obj/item/relic
	name = "strange object"
	desc = "What mysteries could this hold?"
	icon = 'icons/obj/assemblies.dmi'
	var/revealed = FALSE
	var/datum/relic_type/my_type

/obj/item/relic/Initialize(mapload,datum/relic_type/newtype = null)
	. = ..()
	icon_state = pick("shock_kit","armor-igniter-analyzer","infra-igniter0","infra-igniter1","radio-multitool","prox-radio1","radio-radio","timer-multitool0","radio-igniter-tank")
	if(ispath(newtype))
		my_type = newtype
	else
		var/pickedtype = pick(subtypesof(/datum/relic_type))
		my_type = new pickedtype()
	my_type.pre_generate(src)

/obj/item/relic/proc/reveal()
	if(revealed) //Re-rolling your relics seems a bit overpowered, yes?
		return
	revealed = TRUE
	my_type.reveal(src)