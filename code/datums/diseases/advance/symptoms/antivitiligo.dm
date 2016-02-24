/*
//////////////////////////////////////
Anti Vitiligo
        Extremely Noticable.
        Decreases resistance slightly.
        Reduces stage speed slightly.
        Reduces transmission.
        Critical Level.
BONUS
        wachu lookin at nygga
//////////////////////////////////////
*/

/datum/symptom/antivitiligo

        name = "Anti-Vitiligo"
        stealth = -3
        resistance = -1
        stage_speed = -1
        transmittable = -3
        level = 3
        severity = 3

/datum/symptom/antivitiligo/Activate(var/datum/disease/advance/A)
        ..()
        if(prob(SYMPTOM_ACTIVATION_PROB))
                var/mob/living/M = A.affected_mob
                if(istype(M, /mob/living/carbon/human))
                        var/mob/living/carbon/human/H = M
                        if(H.skin_tone == "african1")
                                return
                        switch(A.stage)
                                if(5)
                                        H.set_skin_tone("african1")
                                        H.update_body(0)
                                else
                                        H.visible_message("<span class='warning'>[H] looks a bit black.</span>", "<span class='notice'>You suddenly crave Fried Chicken.</span>")
        if(prob(SYMPTOM_ACTIVATION_PROB))
                var/mob/living/M = A.affected_mob
                if(istype(M, /mob/living/carbon/human))
                        var/mob/living/carbon/human/H = M
                        switch(A.stage)
                                if(5)
                                        var/random_name = ""
                                        switch(H.gender)
                                                if(MALE)
                                                        random_name = pick("Jamal", "Devon", "Ooga")
                                                else
                                                        random_name = pick("Shaniqua", "Jewel", "Latifa")
                                        random_name += " [pick("Melons, Jabongo")]"
                                        H.SetSpecialVoice(random_name)
                                else
                                        return
        return