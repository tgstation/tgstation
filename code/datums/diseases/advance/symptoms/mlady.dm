/*
//////////////////////////////////////
Whiteknighting
        Noticable.
        No Resistance.
        Doesn't get the pussy.
        Transmittable.
        Low Level.
BONUS
        Will annoy non-whiteknights.
//////////////////////////////////////
*/
 
/datum/symptom/mlady
 
        name = "Increased Fedora"
        stealth = -2
        resistance = 0
        stage_speed = 0
        transmittable = 3
        level = 2
        severity = 3
 
/datum/symptom/mlady/Activate(var/datum/disease/advance/A)
        ..()
        if(prob(SYMPTOM_ACTIVATION_PROB * 1.5))
                var/mob/living/M = A.affected_mob
                switch(A.stage)
                        if(1, 2, 3, 4)
                                M << "<span notice='notice'>[pick("You suddenly feel like equipping the nearest Fedora ", "You have an intense urge to aide a helpless wymyn.")]</span>"
                                M.visible_message("<span class='danger'>[M] shouts a vigorous M'lady</span>")
                        else
                                M << "<span notice='danger'>[pick("You begin to feel pain due to a lack of female attention")]</span>"
                                M.adjustBruteLoss(0.6)
        return