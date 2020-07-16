import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const Wires = (props, context) => {
  const { act, data } = useBackend(context);
  const wires = data.wires || [];
  const statuses = data.status || [];
  return (
    <Window
      width={350}
      height={150 + wires.length * 30}>
      <Window.Content>
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
                      onClick={() => act('cut', {
                        wire: wire.color,
                      })} />
                    <Button
                      content="Pulse"
                      onClick={() => act('pulse', {
                        wire: wire.color,
                      })} />
                    <Button
                      content={wire.attached ? 'Detach' : 'Attach'}
                      onClick={() => act('attach', {
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
      </Window.Content>
    </Window>
  );
};
