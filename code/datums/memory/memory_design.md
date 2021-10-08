
## What are memories?
Memories are events that happen to spacemen that are stored in their mind. They are then turned into generated stories that spessmen can engrave into walls, tattoo onto limbs, changelings can absorb people and read memories, etc.

One thing i'd keep in mind is that stories are not memories. Memories persist and can be turned into stories of different types (engravings, tats) but stories are simply the output strings of memories.

## How to add a memory:
Here's a quick step by step guide on adding a memory. It's purposefully been made to be pretty easy! I'm going to be explaining memories with the surgery memory, it's a great example of a memory.

### Add defines and memory text

**For the define file**

`#define MEMORY_SUCCESSFUL_SURGERY "surgery"`

this define is used in the proc for adding a memory to someone.

`#define DETAIL_SURGERY_TYPE "SURGERY_TYPE"`

this define is going to be the name of the surgery used, it's passed to the memory through the proc. See the next step for a more in-depth explanation.

**For the memory json**

Keys are in the memory defines, and are also sent by the memory proc. The only one that is not sent by the specific memory is `%MOOD` which is replaced by a string of the `%PROTAGONIST`'s moods.

![surgery example](https://cdn.discordapp.com/attachments/590280000977240105/878375963434569758/unknown.png)

Note that the memory key consists of the memory define, and then:
* names - name of the story
* starts - the first sentence of the generated story, it should describe what is happening in the memory
* moods - comes after starts, should include `%MOOD` to show how the `%PROTAGONIST` feels during the memory.


### Add proc to store memory
Here's an in-codebase example of a memory.

```dm
surgeon.mind.add_memory(
	// argument 1
	MEMORY_SUCCESSFUL_SURGERY,
	// argument 2
	list(
		DETAIL_PROTAGONIST = surgeon,
		DETAIL_DEUTERAGONIST = target,
		DETAIL_SURGERY_TYPE = src,
	),
	// argument 3
	story_value = STORY_VALUE_OKAY,
	// argument 4, you do not need to include this if there are no flags BUT for the sake of teaching the proc this is included for the example.
	memory_flags = NONE
)
```

First argument is the memory type, basically what is happening. It is a define equal to the memory json key with all the flavor text.

Second argument is the elements in the memory. You will almost always have a `PROTAGONIST`, or the main character in the memory. The second most important character is is the `DEUTERAGONIST`. In the case of this memory, the protag is the surgeon and the deuterag is the patient. Makes sense! There are also non generic memory information, which is shown by the `DETAIL_SURGERY_TYPE` entry. This will send the name of the surgery to the memory, so it has that information when creating a story.

Third argument is the story value, or how good of a memory it is. We make really easy memories or roundstart memories like account info worth very little so they show up less often, to offset the fact that they are easy

Fourth argument are some memory flags, these can be used to cut story generation out where it doesn't make sense (gibbing not sending moods, roundstart memories not sending location, etc)

## Ways to expand this system in the future:
* Make engraving generic to atoms, not just walls.
* Tattoos could use overlay sprites on the limb.
* Tattoos working on simple animals?
* More wall engraving sprites
* Maybe implement engravings into fantasy affixes? A certain fellow by the name of `fikou` has worked on RPG stats, that combined with engraved high quality items would be awesome.
* readd special role text:
```dm
if(target.mind?.special_role)
	return "\the [lowertext(target.mind?.special_role)]"
```
