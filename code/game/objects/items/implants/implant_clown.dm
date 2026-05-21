/// A passive implant that plays a funny noise (defaults to sound/misc/sadtrombone.ogg) when you deathgasp for any reason
/obj/item/implant/sad_trombone
	name = "sad trombone implant"
	actions_types = null

	/// What do we play when the implantee deathgasps?
	var/death_noise = 'sound/misc/sadtrombone.ogg'

	implant_info = "Activates upon death. Plays a sad trombone sound."

	implant_lore = "The Honk Co. Sad Trombone Implant is a subdermal vitals analyzer and \
		sound synthesizer with exactly one sound effect pre-loaded: a sad trombone. \
		Upon dying (or pretending to die via convincing-enough death gasp), plays a sad trombone sound."

/obj/item/implant/sad_trombone/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(.)
		RegisterSignal(target, COMSIG_MOB_EMOTED("deathgasp"), PROC_REF(on_deathgasp))

/obj/item/implant/sad_trombone/removed(mob/target, silent = FALSE, special = FALSE)
	. = ..()
	if(.)
		UnregisterSignal(target, COMSIG_MOB_EMOTED("deathgasp"))

/obj/item/implant/sad_trombone/proc/on_deathgasp(mob/source)
	SIGNAL_HANDLER
	playsound(loc, death_noise, 50, FALSE)

///Implanter that spawns with a sad trombone implant, as well as an appropriate name
/obj/item/implanter/sad_trombone
	name = "implanter (sad trombone)"
	imp_type = /obj/item/implant/sad_trombone

///Implant case that spawns with a sad trombone implant, as well as an appropriate name and description
/obj/item/implantcase/sad_trombone
	name = "implant case - 'Sad Trombone'"
	desc = "A glass case containing a sad trombone implant."
	imp_type = /obj/item/implant/sad_trombone
