Welcome to this short guide to the POLICY config mechanism.

You are probably reading this guide because you have been informed your antagonist or ghost role needs to support policy configuration.

## Requirements
It is a requirement of /tg/station development that all ghost roles, antags, minor antags and event mobs of any kind must support the policy system when implemented.

## What is policy configuration
Policy configuration is a json file that the administrators of a server can edit, which contains a dictionary of keywords -> string message.

The policy text for a specific keyword should be displayed when relevant and appropriate, to allow server administrators to define the broad strokes of policy for some feature or mob.

It is okay to provide a default text when the config is not set, but you are required to provide the config in all cases of a ghost role or an antagonist, or minor event.

If you're in doubt about needing to support policy config, I suggest doing it anyway. This should replace all flavour text, ghost spawn messages and so forth that the player (i.e client) sees upon entering the role, mob, or feature that is meant to dictate how they are permitted to be played as/with.

## What does this mean?

Concretely, it means you need to display to the client taking control of the mob or ghost role a string of text, pulled via keyword from the policy config system.

You can access the string of text through the `get_policy(keyword)` proc, this takes a single keyword argument, which should be a text string unique to your feature.

This will return a configured string of text, or blank/null if no policy string is set.

This is also accessible to the user if they use `/client/verb/policy()` which will display to them a list of all the policy texts for keywords applicable to the mob, you can add/modify the list of keywords by modifying the `get_policy_keywords()` proc of a mob type where that is relevant.

### Example
Here is a simple example taken from the slime pyroclastic event
```
var/policy = get_policy(ROLE_PYROCLASTIC_SLIME)
if (policy)
	to_chat(S, policy)
```
It's recommended to use a define for your policy keyword to make it easily changeable by a developer
