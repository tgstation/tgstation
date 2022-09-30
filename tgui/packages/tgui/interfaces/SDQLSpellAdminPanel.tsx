import { useBackend } from "../backend";
import { Button, Table } from "../components";
import { Window } from "../layouts";

type SDQLSpellAdminPanelData = {
  spells: {
    ref: string;
    name: string;
    ownerRef: string;
    owner: string;
    creator: string;
  }[]
}

export const SDQLSpellAdminPanel = (props, context) => {
  const { act, data } = useBackend<SDQLSpellAdminPanelData>(context);

  return (
    <Window title="SDQL Spell Admin Panel" width={1200} height={500} theme="admin" resizable>
      <Window.Content>
        <Table>
          <Table.Row header>
            <Table.Cell>
              Spell Name
            </Table.Cell>

            <Table.Cell>
              Spell Owner
            </Table.Cell>

            <Table.Cell>
              Spell Creator
            </Table.Cell>

            <Table.Cell>
              Actions
            </Table.Cell>
          </Table.Row>

          {data.spells.map(spell => {
            const createSpellAct = (action: string) => () => {
              act(action, { spell: spell.ref });
            };

            const createOwnerAct = (action: string) => () => {
              act(action, { owner: spell.ownerRef });
            };

            return (
              <Table.Row key={spell.ref}>
                <Table.Cell>
                  {spell.name}
                </Table.Cell>

                <Table.Cell>
                  {spell.owner}
                </Table.Cell>

                <Table.Cell>
                  {spell.creator}
                </Table.Cell>

                <Table.Cell>
                  <Button onClick={createSpellAct("edit_spell")}>
                    Edit
                  </Button>

                  <Button onClick={createOwnerAct("follow_owner")}>
                    Follow Owner
                  </Button>

                  <Button onClick={createSpellAct("vv_spell")}>
                    VV
                  </Button>

                  <Button onClick={createOwnerAct("open_player_panel")}>
                    Player Panel
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
