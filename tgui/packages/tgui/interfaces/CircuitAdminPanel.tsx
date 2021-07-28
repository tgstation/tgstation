import { useBackend } from "../backend";
import { Button, Table } from "../components";
import { Window } from "../layouts";

type CircuitAdminPanelData = {
  circuits: {
    ref: string;
    name: string;
    inserter?: string;
    shell?: string;
  }[]
}

export const CircuitAdminPanel = (props, context) => {
  const { act, data } = useBackend<CircuitAdminPanelData>(context);

  return (
    <Window title="Circuit Admin Panel" width={900} height={500}>
      <Window.Content>
        <Table>
          <Table.Row header>
            <Table.Cell>
              Circuit name
            </Table.Cell>

            <Table.Cell>
              Inserter
            </Table.Cell>

            <Table.Cell>
              Shell
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
                  {
                    circuit.inserter
                    && (
                      <>
                        {circuit.inserter} |{" "}

                        <Button onClick={createAct("open_player_panel")}>
                          Player Panel
                        </Button>
                      </>
                    )
                   || "<no inserter>"
                  }
                </Table.Cell>

                <Table.Cell>
                  {circuit.shell || "<no shell>"}
                </Table.Cell>

                <Table.Cell>
                  <Button onClick={createAct("follow_circuit")}>
                    Follow
                  </Button>

                  <Button onClick={createAct("vv_circuit")}>
                    VV
                  </Button>
                </Table.Cell>
              </Table.Row>
            );
          })}
        </Table>
      </Window.Content>
    </Window>
  );
};
