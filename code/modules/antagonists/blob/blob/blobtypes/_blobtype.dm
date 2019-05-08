GLOBAL_LIST_INIT(valid_blobtypes, subtypesof(/datum/blobtype) - /datum/blobtype/reagent)

/datum/blobtype
	var/name
	var/description
	var/color = "#000000"
	var/complementary_color = "#000000" //a color that's complementary to the normal blob color
	var/shortdesc = null //just damage and on_mob effects, doesn't include special, blob-tile only effects
	var/effectdesc = null //any long, blob-tile specific effects
	var/analyzerdescdamage = "Unknown. Report this bug to a coder, or just adminhelp."
	var/analyzerdesceffect = "N/A"
	var/blobbernaut_message = "slams" //blobbernaut attack verb
	var/message = "The blob strikes you" //message sent to any mob hit by the blob
	var/message_living = null //extension to first mob sent to only living mobs i.e. silicons have no skin to be burnt
	var/core_regen = 2
	var/resource_delay = 0
	var/point_rate = 2
	var/mob/camera/blob/overmind

/datum/blobtype/proc/on_sporedeath(mob/living/spore)

/datum/blobtype/reagent/on_sporedeath(mob/living/spore)
	spore.reagents.add_reagent(reagent.id, 10)

/datum/blobtype/proc/send_message(mob/living/M)
	var/totalmessage = message
	if(message_living && !issilicon(M))
		totalmessage += message_living
	totalmessage += "!"
	to_chat(M, "<span class='userdanger'>[totalmessage]</span>")

/datum/blobtype/proc/on_life()
	if(resource_delay <= world.time)
		resource_delay = world.time + 10 // 1 second
		overmind.blobtype.on_life()
	overmind.blob_core.obj_integrity = min(overmind.blob_core.max_integrity, overmind.blob_core.obj_integrity+core_regen)

/datum/blobtype/proc/attack_living(var/mob/living/L) // When the blob attacks people
	send_message(L)

/datum/blobtype/proc/blobbernaut_attack(mob/living/L) // When this blob's blobbernaut attacks people

/datum/blobtype/proc/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag, coefficient = 1) //when the blob takes damage, do this
	return coefficient*damage

/datum/blobtype/proc/death_reaction(obj/structure/blob/B, damage_flag, coefficient = 1) //when a blob dies, do this
	return

/datum/blobtype/proc/expand_reaction(obj/structure/blob/B, obj/structure/blob/newB, turf/T, mob/camera/blob/O, coefficient = 1) //when the blob expands, do this
	return

/datum/blobtype/proc/tesla_reaction(obj/structure/blob/B, power, coefficient = 1) //when the blob is hit by a tesla bolt, do this
	return 1 //return 0 to ignore damage

/datum/blobtype/proc/extinguish_reaction(obj/structure/blob/B, coefficient = 1) //when the blob is hit with water, do this
	return

/datum/blobtype/proc/emp_reaction(obj/structure/blob/B, severity, coefficient = 1) //when the blob is hit with an emp, do this
	return
