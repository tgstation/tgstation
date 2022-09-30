import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

type Data = {
  points: number;
  pad: string;
  sending: BooleanLike;
  status_report: string;
};

export const CargoHoldTerminal = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { points, pad, sending, status_report } = data;

  return (
    <Window width={600} height={230}>
      <Window.Content scrollable>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Current Cargo Value">
              <Box inline bold>
                <AnimatedNumber value={Math.round(points)} /> credits
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Cargo Pad"
          buttons={
            <>
              <Button
                icon={'sync'}
                content={'Recalculate Value'}
                disabled={!pad}
                onClick={() => act('recalc')}
              />
              <Button
                icon={sending ? 'times' : 'arrow-up'}
                content={sending ? 'Stop Sending' : 'Send Goods'}
                selected={sending}
                disabled={!pad}
                onClick={() => act(sending ? 'stop' : 'send')}
              />
            </>
          }>
          <LabeledList>
            <LabeledList.Item label="Status" color={pad ? 'good' : 'bad'}>
              {pad ? 'Online' : 'Not Found'}
            </LabeledList.Item>
            <LabeledList.Item label="Cargo Report">
              {status_report}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
