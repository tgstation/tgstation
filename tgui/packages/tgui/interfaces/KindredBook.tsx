import { Collapsible, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  clans: ClanInfo[];
};

type ClanInfo = {
  clan_name: string;
  clan_desc: string;
};

export const KindredBook = (props) => {
  const { data } = useBackend<Data>();
  const { clans } = data;
  return (
    <Window width={410} height={460} theme="spookyconsole">
      <Window.Content scrollable>
        <Section title="Bloodsucker Clans">
          <Table mb={2}>
            <Table.Row>
              Written by generations of Curators, this holds all information we
              the Curators know about the undead threat that looms the
              station...
            </Table.Row>
            <Table.Row>So, what Clan are you interested in?</Table.Row>
          </Table>
          <Table>
            <Table.Row>
              {clans.map((clan) => (
                <Collapsible key={clan.clan_name} title={clan.clan_name}>
                  <Table.Cell color="label">{clan.clan_desc}</Table.Cell>
                </Collapsible>
              ))}
            </Table.Row>
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
