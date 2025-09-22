# Quickstart Verification: AI-Controlled Human Crew Foundation

## Prerequisites
- Test server compiled with AI foundation feature branch `001-DRMCTS`.
- Admin account with access to AI configuration panel and monitoring tools.
- At least two vacant human crew slots (janitor and security).
- Logging level set to include AI decision telemetry (`log_categories += AI_DECISION`).

## Manual Scenario 1: AI Janitor Workflow
1. Spawn a janitor without a player controller.
2. Confirm AI auto-activates and acquires janitor objectives in the admin blackboard.
3. Place a mess in a nearby hallway; observe AI reserving cleaning equipment and pathing to the location.
4. Verify telemetry shows action scores with Routine Upkeep multiplier >1.2 and rollout count ≤200.
5. Confirm AI cleans spill, disposes waste, and logs completion within one duty cycle.
6. Assert no repeating loop beyond two passes (watch for mitigation alerts).

## Manual Scenario 2: Emergency Reprioritization
1. Trigger a station-wide fire alert after an AI janitor begins cleaning.
2. Observe exploration scaling adjust in blackboard: Security & Emergency category shows `c_pi ≈ 0.6`.
3. Confirm janitor aborts low-priority task if safety threshold exceeded and relocates to safe zone.
4. Ensure telemetry retention buffer keeps last 30 minutes of entries; older entries disappear.

## Manual Scenario 3: Player Takeover Handoff
1. While AI controls the janitor, log in as a player and assume control of the same mob.
2. Verify AI immediately relinquishes reservations, clears queued actions, and switches status to `PLAYER_OVERRIDE`.
3. Confirm no ghost actions occur after takeover (no delayed cleaning attempts).
4. Check admin blackboard logs the takeover event with timestamp and actor.

## Manual Scenario 4: Security Equipment Contention
1. Spawn AI-controlled security officer and medical doctor near an armory locker.
2. Simultaneously create an alert requiring both to access limited equipment.
3. Confirm priority queue grants access to security (higher priority) and reschedules medical with retry window.
4. Validate reservation expiry resets within 5 seconds if unused.

## Manual Scenario 5: Configuration Adjustments
1. Open Admin Config TGUI → AI Foundation panel.
2. Adjust Routine Upkeep exploration multiplier from 1.5 → 1.0.
3. Confirm live telemetry shows decreased entropy for janitorial actions within two cycles.
4. Revert change and ensure config persistence across soft reboot.

## Expected Telemetry Checks
- Each decision record includes selected action, exploration bonus, rollout count, result, and optional notes.
- Rate limiting prevents more than one item toggle per agent every 5 seconds; attempt to spam and confirm failure + log entry.

## Cleanup
- Return configuration multipliers to default values.
- Disable AI control subsystem if further manual testing is paused (`call ai_control_subsystem.stop()`).
- Archive telemetry logs for reference.

## Verification Log (2025-09-21)
| Scenario | Status | Notes |
| --- | --- | --- |
| AI Janitor Workflow | Blocked | DreamDaemon runtime not available in this automation environment; ops to validate on staging. |
| Emergency Reprioritization | Blocked | Requires live fire alert simulation on BYOND server; deferred to ops handoff. |
| Player Takeover Handoff | Blocked | Lacks interactive BYOND session here; capture during next multiplayer playtest. |
| Security Equipment Contention | Blocked | Multi-agent sandbox with reservation manager unavailable; schedule with QA cluster. |
| Configuration Adjustments | Blocked | Admin Config TGUI can’t be exercised without runtime; ops will verify during deployment rehearsal. |
