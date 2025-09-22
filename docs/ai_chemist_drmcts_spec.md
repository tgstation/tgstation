# AI Chemist Loop via DR-MCTS Heuristics

## 1. Objective

Design a Dream Maker + external DR-MCTS control loop that allows an AI-controlled chemist crewmember to autonomously produce medicines/drugs, store them responsibly, and keep medbay stocked via the drug dispenser. The loop must be believable, tick-safe, and configurable via SS_AI.

## 2. Scenario Overview

- **Role**: `/datum/job/chemist`-aligned AI crew member.
- **Primary goal**: Maintain medbay dispensers with a prioritized set of medicines (tricordrazine, kelotane, dermaline, etc.) while responding to emergent requests (radio, alerts).
- **Operating area**: Chemistry lab, Medbay lobby, storage fridges, chemistry lockers.
- **Core assets**: ChemMaster 3000, Chem Dispenser, Smart Fridge / Reagent Storage, Drug Dispenser in medbay lobby, beaker/bottle inventory, reagent sheets/recipes.

## 3. Blackboard Extensions

Add chemist-specific keys under `BB.role.chemist` namespace:

| Key | Type | Description |
| --- | --- | --- |
| `target_queue` | priority queue | Pending recipes w/ demand signal and urgency (0..1). |
| `reagent_stock` | map | Current counts per reagent (moles) across lab containers, refreshed via perception sweep. |
| `container_bank` | list | Known beakers/bottles and their status (empty, filled, location). |
| `machine_status` | map | `{chem_dispenser, chemmaster, grinder}` statuses, including power, reagent availability. |
| `delivery_slots` | list | Slots in medbay dispensers/fridges needing refill. |
| `safety_flags` | struct | `fire_alarm`, `biohazard`, `toxins_alert`, influences option gating. |
| `cooldowns` | map | Rate limits for machine interactions to avoid tick spikes. |

## 4. Perception Hooks

- Monitor chemistry lab machinery (`COMSIG_MACHINE_INTERACT`, reagent change signals) to refresh `machine_status`.
- Periodic area scan (every 30 ticks) to update `reagent_stock` and `container_bank`.
- Parse radio/nearby speech for keywords (`chemist`, `med`, `need`, `injury`, reagent names) via LLM parser; translate into `target_queue` entries with timeouts.
- Listen for `GLOB.chemistry_supply` events (if implemented) or fallback to heuristic demand based on medbay damage alerts.
- Pull dispenser inventory via `drug_dispenser.export_inventory()` (non-blocking) to populate `delivery_slots`.

## 5. Macro-Options Library (Chemist Pack)

Each option implements `precond`, `propose`, `step`, `done`, `timeout`. Key options:

1. **Assess Lab State**
   - Snapshot equipment status, restock beakers, align `reagent_stock` map.
   - Low cost; used to re-anchor beliefs.

2. **Synthesize Reagents**
   - Parameterized by recipe (sequence of reagent dispensing steps and heating/cooling).
   - Precondition: required precursors available; lab safe.
   - Steps: path to Chem Dispenser → load beaker → dispense volumes → heat/cool if needed (via heater) → transfer to ChemMaster buffer.

3. **Compound Medicine (ChemMaster)**
   - Takes reagent mix in ChemMaster buffer, sets tablet/bottle, runs process, labels output.
   - Heuristic ensures labels follow canonical names for admin clarity.

4. **Grind/Extract Resources**
   - Uses All-In-One Grinder to convert pills/leaves; triggered if `reagent_stock` low but raw materials present.

5. **Refill Drug Dispenser**
   - Navigate to medbay dispenser → insert bottles/pills according to `delivery_slots` priorities → confirm via export check.

6. **Respond to Urgent Request**
   - For high-urgency radio events, produce requested medicine bypassing queue (subject to safety flags) and deliver directly to requester location (if accessible) or to drop-off table.

7. **Handle Hazards**
   - If `safety_flags` triggered (plasma fire, vent flood), exit lab, notify via radio, wait until cleared.

8. **Cleanup**
   - Dispose of toxins, reclaim empty beakers, ensure lab tidy (garbage bin, chemical storage).

## 6. DR-MCTS Heuristic Design

### 6.1 State Summary Features

- Role state: current option, inventory contents, lab occupancy map.
- Resource vectors: `[tricord, kelotane, dermaline, ryetalyn, inaprovaline, ...]` demand gap (desired minus stocked).
- Time-sensitive tasks: queue head urgency, time since request.
- Safety: hazard flags, chem equipment health.
- Movement cost: path distance between lab stations and dispenser.

### 6.2 Priors

- Use role-specific prior weights favoring `Assess Lab State` at start of shift.
- Priors shaped by demand gap: larger deficit boosts `Synthesize`/`Compound` options for relevant recipes.
- If dispenser stock > threshold, prior mass moves to `Cleanup`/`Assess`.

### 6.3 Reward Model / Value Estimate

- Baseline value network trained on replay: inputs include resource gap, hazard state, queue backlog, and tick counters.
- Immediate heuristic reward: +1 per medicine unit stocked toward goal, +0.5 per urgent request satisfied, -1 for hazard ignoring, -0.2 per tick of queue head overdue, -2 for lab safety violation (spill, explosion).
- DR estimator uses short rollout (depth 3-4 options) with behavior policy from human chemist logs.

### 6.4 Doubly-Robust Details

- Behavior policy π_b approximated from logs by frequency of macro-options under similar feature vectors.
- Importance weights clipped at 3.0 to maintain variance control.
- β blending schedule: start at 0.7 (favor value network) and shift toward Monte Carlo backup when urgency >0.7.

## 7. Planning Cadence & Tick Budget

- Chemist AI tick slice: ≤0.35 ms average.
- Planning triggered every 25 ticks or upon queue change; budget 60 ms per plan request.
- Option execution loops with micro-stepping to avoid blocking (pathing uses existing movement controller).
- Cooldowns ensure no more than one ChemMaster interaction per 5 ticks to reduce busy-wait.

## 8. Equipment Interaction Protocols

1. **Chem Dispenser**
   - Use `attackby(beaker)` to insert; send `Topic()` commands for reagent dispense.
   - Validate reagent availability; fallback to grinder if insufficient.

2. **ChemMaster 3000**
   - Insert beaker → `Topic("transfer"/"create")` sequences → set output container (bottle, pill) → label via `Topic("name")`.
   - Wait for machine acknowledgment before proceeding (poll `mach.last_action_complete`).

3. **Heater/Cooler**
   - Attach beaker, set target temperature, monitor `beaker.chem_temp` via periodic check.

4. **Drug Dispenser**
   - Use `attackby(bottle)`; confirm acceptance via returned flag. Update `delivery_slots` accordingly.

5. **Storage**
   - Manage `smartfridge` interactions: deposit surplus, withdraw precursors.

## 9. Safety & Compliance

- Safety heuristic ensures no harmful chems (e.g., toxins) are produced unless flagged by admin override or explicit request.
- Radio updates when lab in operation, restocking completed, or hazards encountered.
- Log each `Refill Drug Dispenser` action with contents for admin audit.

## 10. Failure Handling

- If planner fails (timeout/error): fallback to scripted loop (Assess → Synthesize tricord → Refill) until planner recovers.
- If equipment destroyed/unpowered: mark in `machine_status`, notify medbay, idle at safe location.
- If path blocked: request assistance via radio and retry after 50 ticks.

## 11. Acceptance Criteria

1. Medbay dispenser maintains ≥80% target stock for core medicines during simulation runs.
2. AI responds to urgent requests within 120 ticks and delivers correct item ≥90% of time.
3. Tick usage remains within budget for 2 chemist AIs simultaneously.
4. Safety incidents (explosions, toxins misuse) under 1% of runs without admin override.
5. Logs/audit provide trace of production and dispenser refills.

## 12. Future Enhancements

- Integrate with `SS_supply` for automated precursor delivery.
- Add advanced compounds (e.g., spaceacillin) with research station coordination.
- Support cross-role cooperation (AI doctor requesting reagents via blackboard).

