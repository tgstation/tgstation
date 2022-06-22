import { BooleanLike } from "common/react";
import { useBackend } from "../backend";
import { Button, Stack, Table } from "../components";
import { Window } from "../layouts";

type CircuitAdminPanelData = {
  circuits: {
    ref: string;
    name: string;
    creator: string;
    has_inserter: BooleanLike;
  }[]
}

export const CircuitAdminPanel = (props, context) => {
  const { act, data } = useBackend<CircuitAdminPanelData>(context);

  return (
    <Window title="Circuit Admin Panel" width={1200} height={500} resizable>
      <Window.Content>
        <Stack vertical>
          <Stack.Item>
            <Stack>
              <Stack.Item grow />
              <Stack.Item>
                <Button onClick={() => {
                  act("disable_circuit_sound");
                }}>
                  Disable all circuit sound emitters
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Table>
              <Table.Row header>
                <Table.Cell>
                  Circuit name
                </Table.Cell>

                <Table.Cell>
                  Creator
                </Table.Cell>

                <Table.Cell>
                  Actions
                </Table.Cell>
              </Table.Row>

              {data.circuits.map(circuit => {
                const createAct = (action: string) => () => {
                  act(action, { circuit: circuit.ref });
                };

                return (
                  <Table.Row key={circuit.ref}>
                    <Table.Cell>
                      {circuit.name}
                    </Table.Cell>

                    <Table.Cell>
                      {circuit.creator}
                    </Table.Cell>

                    <Table.Cell>
                      <Button onClick={createAct("follow_circuit")}>
                        Follow
                      </Button>

                      <Button onClick={createAct("open_circuit")}>
                        Open
                      </Button>

                      <Button onClick={createAct("vv_circuit")}>
                        VV
                      </Button>

                      <Button onClick={createAct("save_circuit")}>
                        Save
                      </Button>

                      <Button onClick={createAct("duplicate_circuit")}>
                        Duplicate
                      </Button>

                      {!!circuit.has_inserter && (
                        <Button onClick={createAct("open_player_panel")}>
                          Player Panel
                        </Button>
                      )}
                    </Table.Cell>
                  </Table.Row>
                );
              })}
            </Table>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
