# Network components

Components within this directory are "network" components in the sense that the behavior they implement is dependent on the following behavior:

- Acts as or communicates with a system or otherwise a collection of other communication nodes
- Does so in a manner that is a characteristic of its functionality here in the code
- Also does so in a manner that, in-game, would operate off a similar set of principles "in-character"

It's not necessary to explain how it works "in-character"; this categorization is simply meant to serve as a reference for anyone implementing/updating/maintaining mechanics that would benefit from a quick short-hand understanding of what is working as part of a "network" and what is just a pure-code obfuscation for some sort of algorithmic and reproducible behavior. For instance, if you're making a heretic spell that makes you unable to communicate because "Magic I Don't Gotta Explain Shit", you would probably immediately know that the person wouldn't be able to use a radio or speak, but you would also want to know about the [GPS communicating their coordinates and its name](./gps.dm) or the [mind link they are a member of](./mind_linker.dm); as you can see from these two, the technological/scientific/magic-riffic implementation in or out of character is agnostic for representing a "network".
