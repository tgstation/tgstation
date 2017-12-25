/datum/surgery_step/remove_object/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
    if(L)
        if(ishuman(target))
            var/mob/living/carbon/human/H = target
            var/objects = 0
            for(var/obj/item/I in L.embedded_objects)
                objects++
                I.forceMove(get_turf(H))
                L.embedded_objects -= I

                if (I.pinned)
                    target.do_pindown(target.pinned_to, 0)
                    target.pinned_to = null
                    target.anchored = 0
                    target.update_canmove()
                    I.pinned = null
            if(!H.has_embedded_objects())
                H.clear_alert("embeddedobject")

            if(objects > 0)
                user.visible_message("[user] successfully removes [objects] objects from [H]'s [L]!", "<span class='notice'>You successfully remove [objects] objects from [H]'s [L.name].</span>")
            else
                to_chat(user, "<span class='warning'>You find no objects embedded in [H]'s [L]!</span>")

    else
        to_chat(user, "<span class='warning'>You can't find [target]'s [parse_zone(user.zone_selected)], let alone any objects embedded in it!</span>")

    return 1