/*
//////////////////////////////////////
Oh BOY
        The stats don't matter.
Bonus
        Get lynched/turned into a lizardman
//////////////////////////////////////
*/
 
/datum/symptom/liggeritis
 
        name = "Skin Mutation"
        stealth = -5
        resistance = 3
        stage_speed = 3
        transmittable = 0
        level = 6
        severity = 5
       
/datum/symptom/liggeritis/Activate(var/datum/disease/advance/A)
        ..()
        if(prob(SYMPTOM_ACTIVATION_PROB))
                var/mob/living/M = A.affected_mob
                switch(A.stage)
                        if(1, 2)
                                if(prob(SYMPTOM_ACTIVATION_PROB))
                                        M << "<span class='notice'>[pick("Your skin feels awfully itchy", "Your tailbone feels like it's going to burst")]</span>"
                        if(3, 4)
                                if(prob(SYMPTOM_ACTIVATION_PROB))
                                        M << A.affected_mob.say(pick("Hiss"))
                                        M << "<span class='notice'>[pick("You cannot resist the urge to hiss")]</span>"
                        if(5)
                                if(ishuman(A.affected_mob))
                                        var/mob/living/carbon/human/human = A.affected_mob
                                        if(human.dna && human.dna.species.id != "lizard")
                                                human.dna.species = new /datum/species/lizard()
                                                human.update_icons()
                                else
                                        return
                                       
        return