import { toTitleCase } from 'common/string';

import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section, Table } from '../components';
import { Window } from '../layouts';

export const LaborClaimConsole = (props) => {
  const { act, data } = useBackend();
  const { can_go_home, id_points, ores, status_info, unclaimed_points } = data;
  return (
    <Window width={315} height={440}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Status">{status_info}</LabeledList.Item>
            <LabeledList.Item label="Shuttle controls">
              <Button
                content="Move shuttle"
                disabled={!can_go_home}
                onClick={() => act('move_shuttle')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Points">{id_points}</LabeledList.Item>
            <LabeledList.Item
              label="Unclaimed points"
              buttons={
                <Button
                  content="Claim points"
                  disabled={!unclaimed_points}
                  onClick={() => act('claim_points')}
                />
              }
            >
              {unclaimed_points}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Directions">
          The nearby stacking machine will unload crates and collect smelted
          materials, points will be calculated based on volume of delivered
          materials.
          <br />
          Please note that only sheets printed with our manufacturer's seal of
          quality, such as those produced from the work camp furnace, will be
          accepted as proof of labour.
        </Section>
      </Window.Content>
    </Window>
  );
};
