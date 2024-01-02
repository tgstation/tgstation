# Silo graphing tool by ArcaneMusic.
# This tool is designed to parse the Silo's logs and graph the total quantity of each material over time. Silo logs can be obtained from https://tgstation13.org/parsed-logs/
# Useful utility for determining the amount of materials used in a round, and how much of each material is left at the end of the round.
# To run, throw silo.json files into the logs folder one level down, then run this python script.
# Remember to install imports if you don't have them already. (pip install matplotlib)
# Terminal will hold numerical averages of every round
# Lastly throw on show_json_figures to True if you want to see all the graphs for each individual round log you have saved.

import json
import os
import matplotlib.pyplot as plt

show_json_figures = False  # Set to True to show all JSON-specific figures at the end
sheet_amount = 100 # How many units of material are a sheet worth right now?

materials = {
    "iron": {"total": 0, "spent": 0, "obtained": 0},
    "glass": {"total": 0, "spent": 0, "obtained": 0},
    "silver": {"total": 0, "spent": 0, "obtained": 0},
    "gold": {"total": 0, "spent": 0, "obtained": 0},
    "uranium": {"total": 0, "spent": 0, "obtained": 0},
    "titanium": {"total": 0, "spent": 0, "obtained": 0},
    "bluespace crystal": {"total": 0, "spent": 0, "obtained": 0},
    "diamond": {"total": 0, "spent": 0, "obtained": 0},
    "plasma": {"total": 0, "spent": 0, "obtained": 0},
    "bananium": {"total": 0, "spent": 0, "obtained": 0},
    "plastic": {"total": 0, "spent": 0, "obtained": 0},
}

grand_total = {
    "iron": {"grand_total": 0, "grand_spent": 0, "grand_obtained": 0},
    "glass": {"grand_total": 0, "grand_spent": 0, "grand_obtained": 0},
    "silver": {"grand_total": 0, "grand_spent": 0, "grand_obtained": 0},
    "gold": {"grand_total": 0, "grand_spent": 0, "grand_obtained": 0},
    "uranium": {"grand_total": 0, "grand_spent": 0, "grand_obtained": 0},
    "titanium": {"grand_total": 0, "grand_spent": 0, "grand_obtained": 0},
    "bluespace crystal": {"grand_total": 0, "grand_spent": 0, "grand_obtained": 0},
    "diamond": {"grand_total": 0, "grand_spent": 0, "grand_obtained": 0},
    "plasma": {"grand_total": 0, "grand_spent": 0, "grand_obtained": 0},
    "bananium": {"grand_total": 0, "grand_spent": 0, "grand_obtained": 0},
    "plastic": {"grand_total": 0, "grand_spent": 0, "grand_obtained": 0},
}

log_folder = "tools\silo_grapher\logs"
total_files = 0
first_time_value = None
first_time_setup = True

total_ores_mined = 0

for filename in os.listdir(log_folder):
    with open(os.path.join(log_folder, filename), "r") as file:
        total_files += 1
        time = {}
        y = {}

        for material in materials:
            time[material] = []
            y[material] = []

        for line in file:
            try:
                log = json.loads(line)
                raw_materials = log.get("data", {}).get("raw_materials", "")
                if first_time_setup:
                    first_time_value = float(log["ts"])
                    first_time_setup = False
                if not raw_materials:
                    continue

                for raw_material in raw_materials.split(", "):
                    quantity, material = raw_material.split(" ", 1)
                    if quantity.startswith("-"):
                        materials[material]["spent"] += int(quantity[1:])
                        materials[material]["total"] -= int(quantity[1:])
                    else:
                        materials[material]["obtained"] += int(quantity[1:])
                        materials[material]["total"] += int(quantity[1:])
                        total_ores_mined += int(quantity[1:])
                    time[material].append((float(log["w-state"]["timestamp"]) - float(first_time_value)) / 10.0)
                    y[material].append(int(materials[material]["total"]))

            except Exception as e:
                print(f"Failed to parse line: {line}")
                print(f"Error: {e}")

        for material, values in materials.items():
            total = values["total"]
            spent = values["spent"]
            obtained = values["obtained"]
            grand_total[material]["grand_total"] += values["total"]
            grand_total[material]["grand_spent"] += values["spent"]
            grand_total[material]["grand_obtained"] += values["obtained"]

        for material in materials:
            materials[material]["total"] = 0
            materials[material]["spent"] = 0
            materials[material]["obtained"] = 0
        first_time_setup = True

        if show_json_figures:
            fig, ax = plt.subplots()
            for material in materials:
                ax.plot(time[material], y[material], label=material)

            ax.set_xlabel("Time")
            ax.set_ylabel("Total Quantity")
            ax.set_title(f"Material Quantity Changes - {filename}")
            ax.legend()

fig, ax = plt.subplots()
for material in materials:
    ax.plot(time[material], y[material], label=material)

ax.set_xlabel("Time")
ax.set_ylabel("Total Quantity")
ax.set_title("Overall Material Quantity Changes")
ax.legend()
plt.show()

for material, values in grand_total.items():
    if values["grand_obtained"] != 0:
        grand_total[material]["grand_spent_percentage"] = values["grand_spent"] / values["grand_obtained"] * sheet_amount
    else:
        grand_total[material]["grand_spent_percentage"] = 0

print("************Grand totals************")
for material, values in grand_total.items():
    print(
        f"{material} net: {values['grand_total']/sheet_amount} | spent total: {values['grand_spent']/sheet_amount} | obtained total: {values['grand_obtained']/sheet_amount}"
    )
print("************AVERAGES************")
for material, values in grand_total.items():
    print(
        f"{material} net: {round(values['grand_total']/(sheet_amount*total_files), 2)} | spent total: {round(values['grand_spent']/(sheet_amount*total_files), 2)} | obtained total: {round(values['grand_obtained']/(sheet_amount*total_files), 2)} | percentage spent: {values['grand_spent_percentage'] :.2f}%"
    )
print(f"This is equivalent to a total of an average {int(total_ores_mined/(sheet_amount*3))} mineral tiles, or {int(total_ores_mined/(sheet_amount*3*total_files))} mineral walls per round.")
