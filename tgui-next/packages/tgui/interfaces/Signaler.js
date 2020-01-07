import { Table, NumberInput, Button, Section } from '../components';
import { useBackend } from '../backend';
import { toFixed } from 'common/math';

export const Signaler = props => {
  const { act, data } = useBackend(props);
  const {
    code,
    frequency,
    minFrequency,
    maxFrequency,
  } = data;

  return (
    <Section>
      <Table>
        <Table.Row>
          <Table.Cell color="label">
            Frequency:
          </Table.Cell>
          <Table.Cell collapsing>
            <NumberInput
              animate
              unit="kHz"
              step={0.2}
              stepPixelSize={6}
              minValue={minFrequency / 10}
              maxValue={maxFrequency / 10}
              value={frequency / 10}
              format={value => toFixed(value, 1)}
              width={13}
              onDrag={(e, value) => act('freq', {
                freq: value,
              })} />
            <Button
              ml={0.5}
              icon="sync"
              content="Reset"
              onClick={() => act('reset', {
                reset: "freq",
              })} />
          </Table.Cell>
        </Table.Row>
        <Table.Row lineHeight={5}>
          <Table.Cell color="label">
            Code:
          </Table.Cell>
          <Table.Cell collapsing>
            <NumberInput
              animate
              step={1}
              stepPixelSize={6}
              minValue={1}
              maxValue={100}
              value={code}
              width={13}
              onDrag={(e, value) => act('code', {
                code: value,
              })} />
            <Button
              ml={0.5}
              icon="sync"
              content="Reset"
              onClick={() => act('reset', {
                reset: "code",
              })} />
          </Table.Cell>
        </Table.Row>
      </Table>
      <Button
        mt={0.2}
        mb={-0.2}
        fluid
        icon="arrow-up"
        content="Send Signal"
        textAlign="center"
        onClick={() => act('signal')} />
    </Section>
  );
};
