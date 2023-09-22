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
	///The list of spores
	var/list/spores = list()
	COOLDOWN_DECLARE(spore_delay)
	var/spore_cooldown = BLOBMOB_SPORE_SPAWN_COOLDOWN
	///Its Blobbernaut, if it has spawned any.
	var/mob/living/simple_animal/hostile/blob/blobbernaut/blobbernaut
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
	for(var/mob/living/simple_animal/hostile/blob/blobspore/spore in spores)
		to_chat(spore, span_userdanger("Your factory was destroyed! You can no longer sustain yourself."))
		spore.death()
	spores = null
	if(blobbernaut)
		blobbernaut.factory = null
		to_chat(blobbernaut, span_userdanger("Your factory was destroyed! You feel yourself dying!"))
		blobbernaut.throw_alert("nofactory", /atom/movable/screen/alert/nofactory)
		blobbernaut = null
	if(overmind)
		overmind.factory_blobs -= src
	return ..()

/obj/structure/blob/special/factory/Be_Pulsed()
	. = ..()
	if(blobbernaut)
		return
	if(spores.len >= max_spores)
		return
	if(!COOLDOWN_FINISHED(src, spore_delay))
		return
	COOLDOWN_START(src, spore_delay, spore_cooldown)
	var/mob/living/simple_animal/hostile/blob/blobspore/BS = new (loc, src)
	if(overmind) //if we don't have an overmind, we don't need to do anything but make a spore
		BS.overmind = overmind
		BS.update_icons()
		overmind.blob_mobs.Add(BS)
