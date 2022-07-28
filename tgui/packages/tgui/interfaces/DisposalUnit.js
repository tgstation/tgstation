import { useBackend } from '../backend';
import { Button, LabeledList, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

export const DisposalUnit = (props, context) => {
  const { act, data } = useBackend(context);
  let stateColor;
  let stateText;
  if (data.full_pressure) {
    stateColor = 'good';
    stateText = 'Ready';
  } else if (data.panel_open) {
    stateColor = 'bad';
    stateText = 'Power Disabled';
  } else if (data.pressure_charging) {
    stateColor = 'average';
    stateText = 'Pressurizing';
  } else {
    stateColor = 'bad';
    stateText = 'Off';
  }
  return (
    <Window width={300} height={180}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="State" color={stateColor}>
              {stateText}
            </LabeledList.Item>
            <LabeledList.Item label="Pressure">
              <ProgressBar value={data.per} color="good" />
            </LabeledList.Item>
            <LabeledList.Item label="Handle">
              <Button
                icon={data.flush ? 'toggle-on' : 'toggle-off'}
                disabled={data.isai || data.panel_open}
                content={data.flush ? 'Disengage' : 'Engage'}
                onClick={() => act(data.flush ? 'handle-0' : 'handle-1')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Eject">
              <Button
                icon="sign-out-alt"
                disabled={data.isai}
                content="Eject Contents"
                onClick={() => act('eject')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Power">
              <Button
                icon="power-off"
                disabled={data.panel_open}
                selected={data.pressure_charging}
                onClick={() =>
                  act(data.pressure_charging ? 'pump-0' : 'pump-1')
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
