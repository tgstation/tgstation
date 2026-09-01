import { Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const LaborClaimConsole = (props) => {
  const { act, data } = useBackend();
  const {
    can_go_home,
    id_points,
    ores,
    status_info,
    unclaimed_points,
    shuttle_exists,
  } = data;
  return (
    <Window width={315} height={440}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Status">{status_info}</LabeledList.Item>
            {!!shuttle_exists && (
              <LabeledList.Item label="Shuttle controls">
                <Button
                  content="Move shuttle"
                  disabled={!can_go_home}
                  onClick={() => act('move_shuttle')}
                />
              </LabeledList.Item>
            )}
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
          Collect boulders and ores from the mining area and bring them to the
          unloading machine. Then, pull the lever to smelt them into sheets. Use
          the production console to dispense the sheets, and then bring bring
          them to the claim console to earn points.
          <br />
          <br />
          Boulders cannot be smelted directly, and will require additional
          manual processing - strike them with a pickaxe to break them down
          further.
          <br />
          <br />
          Sheets smelted from the labor camp's furnace will be stamped with an
          official seal of quality. Only stamped sheets can be claimed for
          points - so don't bother trying to strip down tables and chairs for
          bonus metal.
        </Section>
      </Window.Content>
    </Window>
  );
};
