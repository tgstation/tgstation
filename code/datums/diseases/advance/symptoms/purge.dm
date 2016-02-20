/*
//////////////////////////////////////
Oh BOY
        The stats don't matter.
Bonus
        Get turned into a human. FOR TEH EMPRAH
//////////////////////////////////////
*/

/datum/symptom/purge

        name = "Imperium Blessing"
        stealth = -5
        resistance = 3
        stage_speed = 5
        transmittable = 2
        level = 10 //only available with FEV
        severity = 5

/datum/symptom/purge/Activate(var/datum/disease/advance/A)
        ..()
        if(prob(SYMPTOM_ACTIVATION_PROB))
                var/mob/living/M = A.affected_mob
                switch(A.stage)
                        if(1, 2)
                                if(prob(SYMPTOM_ACTIVATION_PROB))
                                        M << "<span class='notice'>[pick("You hear distant sounds of battle.", "You feel like you should report back to your commander.")]</span>"
                        if(3, 4)
                                if(prob(SYMPTOM_ACTIVATION_PROB))
                                        M << A.affected_mob.say(pick("FUCKING XENOS, PURGE, HERESY"))
                                        M << "<span class='notice'>[pick("You feel an overwhelming hatred of Xenos.")]</span>"
                        if(5)
                                if(ishuman(A.affected_mob))
                                        var/mob/living/carbon/human/human = A.affected_mob
                                        if(human.dna && human.dna.species.id != "human")
                                                human.dna.species = new /datum/species/human()
                                                human.update_icons()
                                                human.update_body()
                                                human.update_hair()
                                else
                                        return

        return
