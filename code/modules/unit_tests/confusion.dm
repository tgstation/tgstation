// Checks that the confusion symptom correctly gives, and removes, confusion
/datum/unit_test/confusion_symptom/Run()
	var/mob/living/carbon/human/H = allocate(/mob/living/carbon/human)
	var/datum/disease/advance/confusion/disease = allocate(/datum/disease/advance/confusion)
	var/datum/symptom/confusion/confusion = disease.symptoms[1]
	disease.processing = TRUE
	disease.update_stage(5)
	disease.infect(H, make_copy = FALSE)
	confusion.Activate(disease)
	TEST_ASSERT(H.get_confusion() > 0, "Human is not confused after getting symptom.")
	disease.cure()
	TEST_ASSERT_EQUAL(H.get_confusion(), 0, "Human is still confused after curing confusion.")

/datum/disease/advance/confusion/New()
	symptoms += new /datum/symptom/confusion
	Refresh()
