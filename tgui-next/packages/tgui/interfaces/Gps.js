import { Fragment } from 'inferno';
import { act } from '../byond';
import { Box, Button, LabeledList, Section, Table } from '../components';


export const Gps = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;

  const {
    current,
    globalmode,
    power,
    tag,
    updating,
    signals = [],
  } = data;

  return (
    <Fragment>
      <Section
        title="Control"
        buttons={(
          <Button
            icon="power-off"
            content={power ? "On" : "Off"}
            selected={power}
            onClick={() => act(ref, "power")}
          />
        )}
      >
        <LabeledList>
          <LabeledList.Item label="Tag">
            <Button
              icon="pencil-alt"
              content={tag}
              onClick={() => act(ref, "rename")}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Scan Mode">
            <Button
              icon={updating ? "unlock" : "lock"}
              content={updating ? "AUTO" : "MANUAL"}
              color={!updating && "bad"}
              onClick={() => act(ref, "updating")}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Range">
            <Button
              icon="sync"
              content={globalmode ? "MAXIMUM" : "LOCAL"}
              selected={!globalmode}
              onClick={() => act(ref, "globalmode")}
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      {!!power && (
        <Fragment>
          <Section title="Current Location">
            <Box
              fontSize="20px"
              bold
            >
              {current}
            </Box>
          </Section>
          <Section title="Detected Signals">
            <Table width="100%">
              <Table.Row bold>
                <Table.Cell>
                  Name
                </Table.Cell>
                <Table.Cell>
                  Coords
                </Table.Cell>
                <Table.Cell>
                  Dist
                </Table.Cell>
                <Table.Cell>
                  Direction
                </Table.Cell>
              </Table.Row>
              {signals.map(signal => (
                <Table.Row key={signal.entrytag} className="candystripe">
                  <Table.Cell bold color="label">
                    {signal.entrytag}
                  </Table.Cell>
                  <Table.Cell>
                    {signal.coord}
                  </Table.Cell>
                  <Table.Cell>
                    {!!signal.direction && (
                      signal.dist +"m"
                    )}
                  </Table.Cell>
                  <Table.Cell>
                    {!!signal.direction && (
                      signal.degrees + "° (" + signal.direction + ")"
                    )}
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        </Fragment>
      )}
    </Fragment>
  );
};
