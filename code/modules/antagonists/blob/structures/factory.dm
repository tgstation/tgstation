/obj/structure/blob/special/factory
	name = "factory blob"
	icon = 'icons/mob/nonhuman-player/blob.dmi'
	icon_state = "blob_factory"
	desc = "A thick spire of tendrils."
	max_integrity = BLOB_FACTORY_MAX_HP
	health_regen = BLOB_FACTORY_HP_REGEN
	point_return = BLOB_REFUND_FACTORY_COST
	resistance_flags = LAVA_PROOF
	armor_type = /datum/armor/structure_blob/factory
	///How many spores this factory can have.
	var/max_spores = BLOB_FACTORY_MAX_SPORES
	///The list of spores and zombies
	var/list/spores_and_zombies = list()
	COOLDOWN_DECLARE(spore_delay)
	var/spore_cooldown = BLOBMOB_SPORE_SPAWN_COOLDOWN
	///Its Blobbernaut, if it has spawned any.
	var/mob/living/basic/blob_minion/blobbernaut/minion/blobbernaut
	///Used in blob/powers.dm, checks if it's already trying to spawn a blobbernaut to prevent issues.
	var/is_creating_blobbernaut = FALSE

/datum/armor/structure_blob/factory
	laser = 25

/obj/structure/blob/special/factory/scannerreport()
	if(blobbernaut)
		return "It is currently sustaining a blobbernaut, making it fragile and unable to produce blob spores."
	return "Will produce a blob spore every few seconds."

/obj/structure/blob/special/factory/creation_action()
	if(overmind)
		overmind.factory_blobs += src

/obj/structure/blob/special/factory/Destroy()
	spores_and_zombies = null
	blobbernaut = null
	if(overmind)
		overmind.factory_blobs -= src
	return ..()

/obj/structure/blob/special/factory/Be_Pulsed()
	. = ..()
	if(blobbernaut)
		return
	if(length(spores_and_zombies) >= max_spores)
		return
	if(!COOLDOWN_FINISHED(src, spore_delay))
		return
	COOLDOWN_START(src, spore_delay, spore_cooldown)
	var/mob/living/basic/blob_minion/created_spore = (overmind) ? overmind.create_spore(loc) : new(loc)
	register_mob(created_spore)
	RegisterSignal(created_spore, COMSIG_BLOB_ZOMBIFIED, PROC_REF(on_zombie_created))

/// Tracks the existence of a mob in our mobs list
/obj/structure/blob/special/factory/proc/register_mob(mob/living/basic/blob_minion/blob_mob)
	spores_and_zombies |= blob_mob
	blob_mob.link_to_factory(src)
	RegisterSignal(blob_mob, COMSIG_LIVING_DEATH, PROC_REF(on_spore_died))
	RegisterSignal(blob_mob, COMSIG_QDELETING, PROC_REF(on_spore_lost))

/// When a spore or zombie dies reset our spawn cooldown so we don't instantly replace it
/obj/structure/blob/special/factory/proc/on_spore_died(mob/living/dead_spore)
	SIGNAL_HANDLER
	COOLDOWN_START(src, spore_delay, spore_cooldown)

/// When a spore is deleted remove it from our list
/obj/structure/blob/special/factory/proc/on_spore_lost(mob/living/dead_spore)
	SIGNAL_HANDLER
	spores_and_zombies -= dead_spore

/// When a spore makes a zombie add it to our mobs list
/obj/structure/blob/special/factory/proc/on_zombie_created(mob/living/spore, mob/living/zombie)
	SIGNAL_HANDLER
	register_mob(zombie)

/// Produce a blobbernaut
/obj/structure/blob/special/factory/proc/assign_blobbernaut(mob/living/new_naut)
	is_creating_blobbernaut = FALSE
	if (isnull(new_naut))
		return

	modify_max_integrity(initial(max_integrity) * 0.25) //factories that produced a blobbernaut have much lower health
	visible_message(span_boldwarning("The blobbernaut [pick("rips", "tears", "shreds")] its way out of the factory blob!"))
	playsound(loc, 'sound/effects/splat.ogg', 50, TRUE)

	blobbernaut = new_naut
	blobbernaut.link_to_factory(src)
	RegisterSignals(new_naut, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH), PROC_REF(on_blobbernaut_death))
	update_appearance(UPDATE_ICON)

/// When our brave soldier dies, reset our max integrity
/obj/structure/blob/special/factory/proc/on_blobbernaut_death(mob/living/death_naut)
	SIGNAL_HANDLER
	if (isnull(blobbernaut) || blobbernaut != death_naut)
		return
	blobbernaut = null
	max_integrity = initial(max_integrity)
	update_appearance(UPDATE_ICON)
