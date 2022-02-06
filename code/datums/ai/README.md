# AI controllers

## Introduction

Our AI controller system is an attempt at making it possible to create modularized AI that stores its behavior in datums, while keeping state and decision making in a controller. This allows a more versatile way of creating AI that doesn't rely on OOP as much, and doesn't clutter up the Life() code in Mobs.

## AI Controllers

A datum that can be added to any atom in the game. Similarly to components, they might only support a given subtype (e.g. /mob/living), but the idea is that theoretically, you could apply a specific AI controller to a big a group of different types as possible and it would still work.

These datums handle both the normal movement of mobs, but also their decision making, deciding which actions they will take based on the checks you put into their SelectBehaviors proc.

If behaviors are selected, and the AI is in range, it will try to perform them. It runs all the behaviors it currently has in parallel; allowing for it to for example screech at someone while trying to attack them. Aslong as it has behaviors running, it will not try to generate new plans, making it not waste CPU when it already has an active goal.

They also hold data for any of the actions they might need to use, such as cooldowns, whether or not they're currently fighting, etcetera this is stored in the blackboard, more information on that below.

### Blackboard
The blackboard is an associated list keyed with strings and with values of whatever you want. These store information the mob has such as "Am I attacking someone", "Do I have a weapon". By using an associated list like this, no data needs to be stored on the actions themselves, and you could make actions that work on multiple ai controllers if you so pleased by making the key to use a variable.

## AI Behavior
AI behaviors are the actions an AI can take. These can range from "Do an emote" to "Attack this target until he is dead". They are singletons and should contain nothing but static data. Any dynamic data should be stored in the blackboard, to allow different controllers to use the same behaviors.


# Guides:

[Making Your AI](./making_your_ai.md): Quickly runs through how to make an ai controller for anything with a step by step development of one.
