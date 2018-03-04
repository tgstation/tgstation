/datum/admins/proc/spawn_objasmob(object as text)
	set category = "Debug"
	set desc = "(obj path) Spawn /obj as /mob"
	set name = "Spawn obj as mob"

	if(!check_rights(R_SPAWN))
		return

	var/chosen = pick_closest_path(object, make_types_fancy(subtypesof(/obj)))

	var/mob/living/simple_animal/hostile/mimic = /mob/living/simple_animal/hostile/mimic

	var/list/settings = list(
    "mainsettings" = list(
      list("name" = "name", "type" = "string", "value" = "[chosen]"),
      list("name" = "access", "type" = "datum", "path" = "/obj/item/card/id", "value" = "[initial(mimic.access_card)]")
    ),
    "advsettings" = list(
      list(
        list("name" = "Spells", "settings" = list(
          list("name" = "spell\[\]", "type" = "datum", "path" = "/obj/effect/proc_holder/spell", "value" = "/obj/effect/proc_holder/spell/aimed/fireball/fireball")
        ))
      )
    ))

	var/list/prefreturn = presentpreflikepicker(usr,"Customize mob", "Customize mob", Button1="Ok", StealFocus = 1,Timeout = 6000, settings=settings)
	to_chat(usr, json_encode(prefreturn))


//	log_admin("[key_name(usr)] spawned cargo pack [chosen] at ([usr.x],[usr.y],[usr.z])")
//	SSblackbox.record_feedback("tally", "admin_verb", 1, "Spawn Cargo") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
