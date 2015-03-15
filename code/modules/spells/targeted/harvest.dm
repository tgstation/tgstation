/spell/targeted/harvest
	name = "Harvest"
	desc = "Back to where I come from, and you're coming with me."

	school = "transmutation"
	charge_max = 200
	spell_flags = Z2NOCAST | CONSTRUCT_CHECK | INCLUDEUSER
	invocation = ""
	invocation_type = SpI_NONE
	range = 0
	max_targets = 0

	overlay = 1
	overlay_icon = 'icons/effects/effects.dmi'
	overlay_icon_state = "rune_teleport"
	overlay_lifespan = 0

	hud_state = "const_harvest"

/spell/targeted/harvest/cast(list/targets, mob/user)//because harvest is already a proc
	..()

	var/destination = null
	for(var/obj/machinery/singularity/narsie/large/N in narsie_list)
		destination = N.loc
		break
	if(destination)
		var/prey = 0
		for(var/mob/living/M in targets)
			if(!findNullRod(M))
				M.forceMove(destination)
				if(M != user)
					prey = 1
		user << "<span class='sinister'>You warp back to Nar-Sie[prey ? " along with your prey":""].</span>"
	else
		user << "<span class='danger'>...something's wrong!</span>"//There shouldn't be an instance of Harvesters when Nar-Sie isn't in the world.
