import { useBackend } from '../backend';
import {
  Box,
  Button,
  Input,
  LabeledControls,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Table,
} from '../components';
import { RADIO_CHANNELS } from '../constants';
import { Window } from '../layouts';

export const Telecomms = (props) => {
  const { act, data } = useBackend();
  const {
    type,
    minfreq,
    maxfreq,
    frequency,
    multitool,
    multibuff,
    toggled,
    id,
    network,
    prefab,
    changefrequency,
    currfrequency,
    broadcasting,
    receiving,
  } = data;
  const linked = data.linked || [];
  const frequencies = data.frequencies || [];
  return (
    <Window title={id} width={400} height={600}>
      <Window.Content scrollable>
        {!multitool && <NoticeBox>Use a multitool to make changes.</NoticeBox>}
        <Section title="Settings">
          <LabeledList>
            <LabeledList.Item
              label="Power"
              buttons={
                <Button
                  icon={toggled ? 'power-off' : 'times'}
                  content={toggled ? 'On' : 'Off'}
                  color={toggled ? 'good' : 'bad'}
                  disabled={!multitool}
                  onClick={() => act('toggle')}
                />
              }
            />
            <LabeledList.Item
              label="Identification String"
              buttons={
                <Input
                  width={13}
                  value={id}
                  onChange={(e, value) => act('id', { value })}
                />
              }
            />
            <LabeledList.Item
              label="Network"
              buttons={
                <Input
                  width={10}
                  value={network}
                  defaultValue={'tcommsat'}
                  onChange={(e, value) => act('network', { value })}
                />
              }
            />
            <LabeledList.Item
              label="Prefabrication"
              buttons={
                <Button
                  icon={prefab ? 'check' : 'times'}
                  content={prefab ? 'True' : 'False'}
                  disabled={'True'}
                />
              }
            />
          </LabeledList>
        </Section>
        {!!(toggled && multitool) && (
          <Box>
            {type === 'bus' && (
              <Section title="Bus">
                <Table>
                  <Table.Row>
                    <Table.Cell>Change Frequency:</Table.Cell>
                    <Table.Cell>
                      {RADIO_CHANNELS.find(
                        (channel) => channel.freq === changefrequency,
                      ) && (
                        <Box
                          inline
                          color={
                            RADIO_CHANNELS.find(
                              (channel) => channel.freq === changefrequency,
                            ).color
                          }
                          ml={2}
                        >
                          [
                          {
                            RADIO_CHANNELS.find(
                              (channel) => channel.freq === changefrequency,
                            ).name
                          }
                          ]
                        </Box>
                      )}
                    </Table.Cell>
                    <NumberInput
                      animate
                      unit="kHz"
                      step={0.2}
                      stepPixelSize={10}
                      minValue={minfreq / 10}
                      maxValue={maxfreq / 10}
                      value={changefrequency / 10}
                      onChange={(value) => act('change_freq', { value })}
                    />
                    <Button
                      icon={'times'}
                      disabled={changefrequency === 0}
                      onClick={() => act('change_freq', { value: 10001 })}
                    />
                  </Table.Row>
                </Table>
              </Section>
            )}
            {type === 'relay' && (
              <Section title="Relay">
                <Button
                  content={'Receiving'}
                  icon={receiving ? 'volume-up' : 'volume-mute'}
                  color={receiving ? '' : 'bad'}
                  onClick={() => act('receive')}
                />
                <Button
                  content={'Broadcasting'}
                  icon={broadcasting ? 'microphone' : 'microphone-slash'}
                  color={broadcasting ? '' : 'bad'}
                  onClick={() => act('broadcast')}
                />
              </Section>
            )}
            <Section title="Linked Network Entities">
              <Table>
                {linked.map((entry) => (
                  <Table.Row key={entry.id} className="candystripe">
                    <Table.Cell bold>
                      {entry.index}. {entry.id} ({entry.name})
                    </Table.Cell>
                    {!!multitool && (
                      <Button
                        icon={'times'}
                        disabled={!multitool}
                        onClick={() => act('unlink', { value: entry.index })}
                      />
                    )}
                  </Table.Row>
                ))}
              </Table>
            </Section>
            <Section title="Filtered Frequencies">
              <Table>
                {frequencies.map((entry) => (
                  <Table.Row key={frequencies.i} className="candystripe">
                    <Table.Cell bold>{entry / 10} kHz</Table.Cell>
                    <Table.Cell>
                      {RADIO_CHANNELS.find(
                        (channel) => channel.freq === entry,
                      ) && (
                        <Box
                          inline
                          color={
                            RADIO_CHANNELS.find(
                              (channel) => channel.freq === entry,
                            ).color
                          }
                          ml={2}
                        >
                          [
                          {
                            RADIO_CHANNELS.find(
                              (channel) => channel.freq === entry,
                            ).name
                          }{' '}
                          ]
                        </Box>
                      )}
                    </Table.Cell>
                    <Table.Cell />
                    {!!multitool && (
                      <Button
                        icon={'times'}
                        disabled={!multitool}
                        onClick={() => act('delete', { value: entry })}
                      />
                    )}
                  </Table.Row>
                ))}
                {!!multitool && (
                  <Table.Row className="candystripe" collapsing>
                    <Table.Cell>Add Frequency</Table.Cell>
                    <Table.Cell>
                      {RADIO_CHANNELS.find(
                        (channel) => channel.freq === frequency,
                      ) && (
                        <Box
                          inline
                          color={
                            RADIO_CHANNELS.find(
                              (channel) => channel.freq === frequency,
                            ).color
                          }
                          ml={2}
                        >
                          [
                          {
                            RADIO_CHANNELS.find(
                              (channel) => channel.freq === frequency,
                            ).name
                          }
                          ]
                        </Box>
                      )}
                    </Table.Cell>
                    <Table.Cell>
                      <NumberInput
                        animate
                        unit="kHz"
                        step={0.2}
                        stepPixelSize={10}
                        minValue={minfreq / 10}
                        maxValue={maxfreq / 10}
                        value={frequency / 10}
                        onChange={(value) => act('tempfreq', { value })}
                      />
                    </Table.Cell>
                    <Button
                      icon={'plus'}
                      disabled={!multitool}
                      onClick={() => act('freq')}
                    />
                  </Table.Row>
                )}
              </Table>
            </Section>
            {!!multitool && (
              <Section title="Multitool">
                {!!multibuff && (
                  <Box bold m={1}>
                    Current Buffer: {multibuff}
                  </Box>
                )}
                <LabeledControls m={1}>
                  <Button
                    icon={'plus'}
                    content={'Add Machine'}
                    disabled={!multitool}
                    onClick={() => act('buffer')}
                  />
                  <Button
                    icon={'link'}
                    content={'Link'}
                    disabled={!multibuff}
                    onClick={() => act('link')}
                  />
                  <Button
                    icon={'times'}
                    content={'Flush'}
                    disabled={!multibuff}
                    onClick={() => act('flush')}
                  />
                </LabeledControls>
              </Section>
            )}
          </Box>
        )}
      </Window.Content>
    </Window>
  );
};
