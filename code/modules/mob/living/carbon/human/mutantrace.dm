var/global/list/colored_mutraces = list( // these mutantraces are affected by mutant color
	"lizard",
	"plant",
	"pod",
	"slime",
	"jelly",
	"golem"
)

var/global/list/mutants_with_eyes = list( // these mutantraces have eyes
	"null",
	"lizard",
	"plant",
	"pod",
	"jelly",
)

/mob/living/carbon/human/proc/update_mutcolor() // this will only run at initialization, mutant race changes, and icon regenerations, rather than constantly.
	if(dna && dna.mutantrace != "human")
		var/icon/temp_icon = new /icon('icons/mob/human.dmi', "[dna.mutantrace]_[gender]_s")
		if(dna.mutantrace in colored_mutraces)
			temp_icon.Blend("#[mutant_color]", ICON_MULTIPLY)

		icon = temp_icon