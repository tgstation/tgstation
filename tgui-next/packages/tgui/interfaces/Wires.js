import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, LabeledList, Section, Box } from '../components';
import { createLogger } from '../logging';

const logger = createLogger('AirAlarm');

export const Wires = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const wires = data.wires || [];
  const statuses = data.status || [];
  return (
    <Fragment>
      <Section>
        <LabeledList>
          {wires.map(wire => (
            <LabeledList.Item
              key={wire.color}
              className="candystripe"
              label={wire.color}
              labelColor={wire.color}
              color={wire.color}
              buttons={(
                <Fragment>
                  <Button
                    content={wire.cut ? 'Mend' : 'Cut'}
                    onClick={() => act(ref, 'cut', {
                      wire: wire.color,
                    })} />
                  <Button
                    content="Pulse"
                    onClick={() => act(ref, 'pulse', {
                      wire: wire.color,
                    })} />
                  <Button
                    content={wire.attached ? 'Detach' : 'Attach'}
                    onClick={() => act(ref, 'attach', {
                      wire: wire.color,
                    })} />
                </Fragment>
              )}>
              {!!wire.wire && (
                <i>
                  ({wire.wire})
                </i>
              )}
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Section>
      {!!statuses.length && (
        <Section>
          {statuses.map(status => (
            <Box key={status}>
              {status}
            </Box>
          ))}
        </Section>
      )}
    </Fragment>
  );
};
