import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { AnimatedNumber, Button, Box, Section, LabeledList } from '../components';

export const CargoHoldTerminal = props => {
  const { act, data } = useBackend(props);
  const {
    points,
    pad,
    sending,
    status_report,
  } = data;
  return (
    <Fragment>
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
        buttons={(
          <Fragment>
            <Button
              icon={"sync"}
              content={"Recalculate Value"}
              disabled={!pad}
              onClick={() => act('recalc')} />
            <Button
              icon={sending ? 'times' : 'arrow-up'}
              content={sending ? "Stop Sending" : "Send Goods"}
              selected={sending}
              disabled={!pad}
              onClick={() => act(sending ? 'stop' : 'send')} />
          </Fragment>
        )}>
        <LabeledList>
          <LabeledList.Item
            label="Status"
            color={pad ? "good" : "bad"}>
            {pad ? "Online" : "Not Found"}
          </LabeledList.Item>
          <LabeledList.Item label="Cargo Report">
            {status_report}
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Fragment>
  );
};
