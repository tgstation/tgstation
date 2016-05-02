var/global/list/colored_mutraces = list( // these mutantraces are affected by mutant color
	"lizard",
	"plant",
	"pod",
	"slime",
	"jelly",
	"golem"
)

var/global/list/mutants_with_eyes = list( // these mutantraces have eyes
	"lizard",
	"plant",
	"pod",
	"jelly",
)

/mob/living/carbon/human/proc/check_mutrace(mutneeded = "mut1", mutneededalt = "mut2")
	if(dna)
		if(dna.mutantrace == mutneeded || dna.mutantrace == mutneededalt)
			return 1

	return 0