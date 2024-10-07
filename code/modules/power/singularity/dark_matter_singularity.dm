// bonus probability to chase the target granted by eating a supermatter
#define DARK_MATTER_SUPERMATTER_CHANCE_BONUS 10

/// This type of singularity cannot grow as big, but it constantly hunts down living targets.
/obj/singularity/dark_matter
	name = "dark matter singularity"
	desc = "<i>\"It is both beautiful and horrifying, \
		a cosmic paradox that defies all logic. I can't \
		take my eyes off it, even though I know it could \
		devour us all in an instant.\
		\"</i><br>- Chief Engineer Miles O'Brien"
	ghost_notification_message = "IT'S HERE"
	icon_state = "dark_matter_s1"
	singularity_icon_variant = "dark_matter"
	maximum_stage = STAGE_FOUR
	energy = 250
	singularity_component_type = /datum/component/singularity/bloodthirsty
	///to avoid cases of the singuloth getting blammed out of existence by the very meteor it rode in on...
	COOLDOWN_DECLARE(initial_explosion_immunity)

/obj/singularity/dark_matter/Initialize(mapload, starting_energy)
	. = ..()
	COOLDOWN_START(src, initial_explosion_immunity, 5 SECONDS)

/obj/singularity/dark_matter/examine(mob/user)
	. = ..()
	if(!COOLDOWN_FINISHED(src, initial_explosion_immunity))
		. += span_warning("Protected by dark matter, [src] seems to be immune to explosions for [DisplayTimeText(COOLDOWN_TIMELEFT(src, initial_explosion_immunity))].")
	if(consumed_supermatter)
		. += span_userdanger("IT HUNGERS")
	else
		. += span_warning("<i>\"The most disturbing aspect of the singularity is its \
		apparent attraction to living organisms. It seems to sense \
		their presence and move towards them at a surprisingly fast speed. \
		We have observed it consume several specimens of flora and fauna that \
		we have collected from this sector. The singularity does not seem \
		to care for other inanimate objects or machines, but will consume \
		them all the same. We have tried to communicate with it using various \
		methods, but received no response.\"</i><br>- Research Director Jadzia Dax")

/obj/singularity/dark_matter/ex_act(severity, target)
	if(!COOLDOWN_FINISHED(src, initial_explosion_immunity))
		return FALSE
	return ..()

/obj/singularity/dark_matter/supermatter_upgrade()
	var/datum/component/singularity/resolved_singularity = singularity_component.resolve()
	resolved_singularity.chance_to_move_to_target += DARK_MATTER_SUPERMATTER_CHANCE_BONUS
	name = "Dark Lord Singuloth"
	desc = "You managed to make a singularity from dark matter, which makes no sense at all, and then you threw a supermatter into it? Are you fucking insane? Fuck it, praise Lord Singuloth."
	consumed_supermatter = TRUE

#undef DARK_MATTER_SUPERMATTER_CHANCE_BONUS
