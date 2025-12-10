#!/usr/bin/env python3
import os
from dmi import *

new_file = Dmi(32, 32)
for file in os.listdir("./credit_pngs"):
    filename = os.fsdecode(file)
    new_icon = Dmi.from_file(f"./credit_pngs/{filename}")
    new_icon.default_state.name = filename[:-4]
    new_file.states.append(new_icon.default_state)

new_file.to_file("../../config/contributors.dmi")
