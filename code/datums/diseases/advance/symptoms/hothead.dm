/*
//////////////////////////////////////
Hotheaditis
        Very Noticable.
        Not very resistant.
        Increases stage speed.
        Not transmittable.
        Medium Level.
BONUS
        Turns the infected into insufferable prick;
        actually it just burns the shit out of them.
//////////////////////////////////////
*/
 
/datum/symptom/hothead
 
        name = "Hothead-itis"
        stealth = -2
        resistance = 1
        stage_speed = 2
        transmittable = 1
        level = 6
        severity = 4
 
/datum/symptom/hothead/Activate(var/datum/disease/advance/A)
        ..()
        if(prob(SYMPTOM_ACTIVATION_PROB))
                var/mob/living/carbon/M = A.affected_mob
                switch(A.stage)
                        if(3, 4, 5)
                                if (M.bodytemperature < 500)
                                        M.bodytemperature = min(450, M.bodytemperature + (50 * TEMPERATURE_DAMAGE_COEFFICIENT))
                        else
                                if(prob(SYMPTOM_ACTIVATION_PROB * 2))
                                        M<< "<span class='notice'>[pick("You feel an intense desire to shitpost on an anonymous imageboard. Also, you're fucking burning hot.")]</span>"
        return