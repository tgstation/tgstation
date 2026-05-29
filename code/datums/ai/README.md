# AI controllers

## Introduction

Our AI controller system is an attempt at making it possible to create modularized AI that stores its behavior in datums, while keeping state and decision making in a controller. This allows a more versatile way of creating AI that doesn't rely on OOP as much, and doesn't clutter up the Life() code in Mobs.

## AI Controllers

A datum that can be added to any atom in the game. Similarly to components, they might only support a given subtype (e.g. /mob/living), but the idea is that theoretically, you could apply a specific AI controller to a big a group of different types as possible and it would still work.

They also hold data for any of the actions they might need to use, such as cooldowns, whether or not they're currently fighting, etcetera this is stored in the blackboard, more information on that below.

### Blackboard

The blackboard is an associated list keyed with strings and with values of whatever you want. These store information the mob has such as "Am I attacking someone", "Do I have a weapon". By using an associated list like this, You could make actions that work on multiple ai controllers if you so pleased by making the key to use a variable.

## AI Behavior

AI behaviors are the actions an AI can take. These can range from "Do an emote" to "Attack this target". Any dynamic data should be stored in the blackboard, to allow different controllers to use the same behaviors.

# Guides:

[Making Your AI](./learn_ai.md): Quickly runs through how to make an ai controller for anything with a step by step development of one.
