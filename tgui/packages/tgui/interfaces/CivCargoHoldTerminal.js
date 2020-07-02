import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const CivCargoHoldTerminal = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    points,
    pad,
    sending,
    status_report,
    id_inserted,
    id_bounty_info,
    id_bounty_value,
  } = data;
  return (
    <Window resizable>
      <Window.Content scrollable>
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
              <Button
                icon={'pen'}
                content={"New Bounty"}
                disabled={!id_inserted}
                onClick={() => act('bounty')} />
              <Button
                icon={'download'}
                content={"Eject"}
                disabled={!id_inserted}
                onClick={() => act('eject')} />
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
            <LabeledList.Item label="Civil Bounty Status">
              <i>{id_bounty_info ? id_bounty_info : 'N/A'}</i>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
