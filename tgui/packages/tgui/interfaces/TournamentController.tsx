import { useBackend, useLocalState } from "../backend";
import { Button, Dropdown, Section, Stack } from "../components";
import { Window } from "../layouts";

type TournamentControllerData = {
  arena_templates: string[],
  team_names: string[],
};

const ArenaInfo = (props, context) => {
  const { act, data } = useBackend<TournamentControllerData>(context);

  const [selectedArena, setSelectedArea]
    = useLocalState<string | null>(context, "selectedArena", null);

  return (
    <Section title="Arena">
      <Stack fill>
        <Stack.Item grow>
          <Dropdown
            width="100%"
            selected={selectedArena ?? "Load an arena..."}
            options={data.arena_templates}
            onSelected={setSelectedArea}
          />
        </Stack.Item>

        <Stack.Item>
          <Button
            color="green"
            icon="upload"
            onClick={() => act("load_arena", {
              arena_template: selectedArena,
            })}
          >
            Upload
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const RoundInfo = (props, context) => {
  const { act, data } = useBackend<TournamentControllerData>(context);

  const [selectedTeamA, setSelectedTeamA]
    = useLocalState(context, "selectedTeamA", data.team_names[0]);

  const [selectedTeamB, setSelectedTeamB]
    = useLocalState(context, "selectedTeamB", data.team_names[1]);

  return (
    <Section title="Round">
      <Stack fill>
        <Stack.Item grow>
          <Dropdown
            width="100%"
            selected={selectedTeamA}
            options={data.team_names}
            onSelected={setSelectedTeamA}
          />
        </Stack.Item>

        <Stack.Item>
          <b>VS.</b>
        </Stack.Item>

        <Stack.Item grow>
          <Dropdown
            width="100%"
            selected={selectedTeamB}
            options={data.team_names}
            onSelected={setSelectedTeamB}
          />
        </Stack.Item>
      </Stack>

      <Stack fill>
        <Stack.Item>
          <Button
            icon="user-friends"
            onClick={() => {
              act("spawn_teams", {
                team_a: selectedTeamA,
                team_b: selectedTeamB,
              });
            }}
          >
            Spawn teams
          </Button>
        </Stack.Item>

        <Stack.Item>
          <Button
            icon="door-closed"
            onClick={() => act("close_shutters")}
          >
            Close shutters
          </Button>
        </Stack.Item>

        <Stack.Item>
          <Button
            icon="door-open"
            onClick={() => act("open_shutters")}
          >
            Open shutters
          </Button>
        </Stack.Item>

        <Stack.Item>
          <Button.Confirm
            content="Start countdown"
            icon="stopwatch"
            onClick={() => act("start_countdown")}
            tooltip="This will open the shutters at the end of the countdown."
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const TournamentController = () => {
  return (
    <Window
      width={600}
      height={532}
      theme="admin"
    >
      <Window.Content scrollable>
        <ArenaInfo />
        <RoundInfo />
      </Window.Content>
    </Window>
  );
};
