import { round, toFixed } from 'common/math';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, NumberInput, Section, ProgressBar, Table } from '../components';
import { TableCell, TableRow } from '../components/Table';
import { Window } from '../layouts';
import { BeakerContents } from './common/BeakerContents';

  
export const ChemHeater = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    targetTemp,
    isActive,
    isBeakerLoaded,
    currentTemp,
    beakerCurrentVolume,
    beakerMaxVolume,
    acidicBufferVol,
    basicBufferVol,
    beakerContents = [],
    activeReactions = [],
  } = data;
  return (
    <Window
      width={325}
      height={350}
      resizable>
      <Window.Content scrollable>
        <Section
          title="Controls"
          buttons={(
            <Button
              icon={isActive ? 'power-off' : 'times'}
              selected={isActive}
              content={isActive ? 'On' : 'Off'}
              onClick={() => act('power')} />
          )}>
          <Table>
            <Table.Row>
              <Table.Cell 
                bold
                collapsing color="label">
                Heat
              </Table.Cell>
              <TableCell />
              <Table.Cell bold collapsing color="label">
                Buffers
              </Table.Cell>
            </Table.Row>
            <TableRow>
              <TableCell collapsing color="label">
                Target:
              </TableCell>
              <TableCell>
                <NumberInput
                  width="65px"
                  unit="K"
                  step={10}
                  stepPixelSize={3}
                  value={round(targetTemp)}
                  minValue={0}
                  maxValue={1000}
                  onDrag={(e, value) => act('temperature', {
                    target: value,
                  })} />
              </TableCell>
              <TableCell collapsing color="label">
                Acidic:
              </TableCell>
              <TableCell>
                <Button
                  icon={'syringe'}
                  disabled={!acidicBufferVol}
                  tooltip={'Inject 1u'}
                  tooltipPosition={"top"}
                  onClick={() => act('acidBuffer', {
                    target: 1,
                  })} />
              </TableCell>
              <TableCell color={"#fbc314"}>
                {acidicBufferVol+"u"}
              </TableCell>
              <TableCell>
                <Button
                  icon={'upload'}
                  tooltip={'Draw'}
                  tooltipPosition={"top"}
                  disabled={acidicBufferVol === 30}
                  onClick={() => act('acidBuffer', {
                    target: -30,
                  })} />
              </TableCell>
            </TableRow>
            <TableRow>
              <TableCell collapsing color="label">
                Reading:
              </TableCell>
              <TableCell collapsing color="default">
                <Box
                  width="60px"
                  textAlign="right">
                  {isBeakerLoaded && (
                    <AnimatedNumber
                      value={currentTemp}
                      format={value => toFixed(value) + ' K'} />
                  ) || '—'}
                </Box>
              </TableCell>
              <TableCell collapsing color="label">
                Basic:
              </TableCell>
              <TableCell>
                <Button
                  icon={'syringe'}
                  tooltip={'Inject 1u'}                  
                  disabled={!basicBufferVol}
                  onClick={() => act('basicBuffer', {
                    target: 1,
                  })} />
              </TableCell>
              <TableCell color={"#3853a4"}>
                {basicBufferVol+"u"}
              </TableCell>
              <TableCell>
                <Button
                  icon={'upload'}
                  tooltip={'Draw'}
                  disabled={basicBufferVol === 30}
                  onClick={() => act('basicBuffer', {
                    target: -30,
                  })} />
              </TableCell>
            </TableRow>
          </Table>
        </Section>
        {!!isBeakerLoaded && (
          <Section
            title="Reactions">
            {activeReactions.length === 0 && (
              <Box color="label">
                No active reactions.
              </Box>
            ) || (
              activeReactions.map(reaction => (
                <Table collapsing={false} key={"reactions"}>
                  <TableRow>
                    <TableCell width={'80px'} color={currentTemp > reaction.overheat ? "red" : "label"}>
                      {reaction.name}
                    </TableCell>
                    <TableCell width={'100px'} pr={'10px'}>
                      <ProgressBar
                        value={reaction.purity}
                        minValue={0}
                        maxValue={1}
                        textAlign={'center'}
                        barColor={reaction.barColor}>
                        {"Purity"}
                      </ProgressBar>
                    </TableCell>
                    <TableCell width={'80px'}>
                      {"Target:" + reaction.targetVol}
                    </TableCell>
                  </TableRow> 
                </Table>
              )))}
          </Section>
        )}
        <Section
          title="Beaker"
          buttons={!!isBeakerLoaded && (
            <>
              <Box inline color="label" mr={2}>
                {beakerCurrentVolume} / {beakerMaxVolume} units
              </Box>
              <Button
                icon="eject"
                content="Eject"
                onClick={() => act('eject')} />
            </>
          )}>
          <BeakerContents
            beakerLoaded={isBeakerLoaded}
            beakerContents={beakerContents} />
          {(beakerContents.length > 0 && (
            <Box color="label">
              pH:
              <AnimatedNumber
                value={data.currentpH} />
            </Box>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
