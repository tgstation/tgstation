import { useBackend } from '../../tgui/backend';
import { Button, ByondUi, LabeledList, Section, ProgressBar, AnimatedNumber, Table} from '../../tgui/components';
import { Window } from '../../tgui/layouts';

export const HelmComputer = (props, context) => {
  const { act, data, config } = useBackend(context);
  const { mapRef, isViewer } = data;
  return (
    <Window
      width={870}
      height={708}
      resizable>
      <div className="CameraConsole__left">
        <Window.Content>
          {!isViewer && (
            <ShipControlContent />
          )}
          <ShipContent />
          <SharedContent />
        </Window.Content>
      </div>
      <div className="CameraConsole__right">
        <ByondUi
          className="CameraConsole__map"
          params={{
            id: mapRef,
            type: 'map',
          }} />
      </div>
    </Window>
  );
};

const SharedContent = (props, context) => {
  const { act, data } = useBackend(context);
  const { isViewer, integrity, shipInfo = [], otherInfo = [] } = data;
  return (
    <>
      <Section
        title={(
          <Button.Input
            content={shipInfo.name}
            currentValue={shipInfo.name}
            disabled={isViewer}
            onCommit={(e, value) => act('rename_ship', {
              newName: value,
            })} />
        )}
        buttons={(
          <Button
            tooltip="Refresh Ship Stats"
            tooltipPosition="left"
            icon="sync"
            disabled={isViewer}
            onClick={() => act('reload_ship')} />
        )}>
        <LabeledList>
          <LabeledList.Item label="Class">
            {shipInfo.class}
          </LabeledList.Item>
          <LabeledList.Item label="Integrity">
            <ProgressBar
              ranges={{
                good: [51, 100],
                average: [26, 50],
                bad: [0, 25],
              }}
              maxValue={100}
              value={integrity} />
          </LabeledList.Item>
          <LabeledList.Item label="Sensor Range">
            <ProgressBar
              value={shipInfo.sensor_range}
              minValue={1}
              maxValue={8}>
              <AnimatedNumber value={shipInfo.sensor_range} />
            </ProgressBar>
          </LabeledList.Item>
          {shipInfo.mass && (
            <LabeledList.Item label="Mass">
              {shipInfo.mass + 'tonnes'}
            </LabeledList.Item>
          )}
        </LabeledList>
      </Section>
      <Section title="Factions"
        buttons={(
          <>
            <Button
              tooltip="Toggle KOS"
              tooltipPosition="left"
              icon="fas fa-skull"
              disabled={isViewer}
              onClick={() => act('toggle_kos')} />
            <Button
              tooltip="Toggle Default"
              tooltipPosition="left"
              icon="fas fa-flag"
              disabled={isViewer}
              onClick={() => act('return')} />
          </>
        )} />
      <Section title="Radar">
        <Table>
          <Table.Row bold>
            <Table.Cell>
              Name
            </Table.Cell>
            <Table.Cell>
              Integrity
            </Table.Cell>
            {!isViewer && (
              <Table.Cell>
                Act
              </Table.Cell>
            )}
          </Table.Row>
          {otherInfo.map(ship => (
            <Table.Row key={ship.name}>
              <Table.Cell>
                {ship.name}
              </Table.Cell>
              <Table.Cell>
                {!!ship.integrity && (
                  <ProgressBar
                    ranges={{
                      good: [51, 100],
                      average: [26, 50],
                      bad: [0, 25],
                    }}
                    maxValue={100}
                    value={ship.integrity} />
                )}
              </Table.Cell>
              {!isViewer && (
                <Table.Cell>
                  <Button
                    tooltip="Interact"
                    tooltipPosition="left"
                    icon="circle"
                    disabled={isViewer || (data.speed > 0) || data.state !== 'flying'}
                    onClick={() => act('act_overmap', {
                      ship_to_act: ship.ref,
                    })} />
                </Table.Cell>
              )}
            </Table.Row>
          ))}
        </Table>
      </Section>
    </>
  );
};

// Content included on helms when they're controlling ships
const ShipContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    isViewer,
    engineInfo,
    shipInfo,
    speed,
    heading,
    eta,
    x,
    y,
    dock_request,
    dock_req_name,
  } = data;
  return (
    <>
      {!!dock_request && (
        <Section title="Docking Request">
          <LabeledList>
            <LabeledList.Item label={dock_req_name}>
              <Button
                content="Accept"
                color="good"
                disabled={isViewer}
                onClick={() => act('dock_req_success')} />
              <Button
                content="Decline"
                color="bad"
                disabled={isViewer}
                onClick={() => act('dock_req_failure')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      )}
      <Section title="Velocity">
        <LabeledList>
          <LabeledList.Item label="Speed">
            <ProgressBar
              ranges={{
                good: [0, 4],
                average: [5, 6],
                bad: [7, Infinity],
              }}
              maxValue={10}
              value={speed}>
              <AnimatedNumber
                value={speed}
                format={value => Math.round(value * 10) / 10} />
              spM
            </ProgressBar>
          </LabeledList.Item>
          <LabeledList.Item label="Heading">
            <AnimatedNumber value={heading} />
          </LabeledList.Item>
          <LabeledList.Item label="Position">
            X
            <AnimatedNumber value={x} />
            /Y
            <AnimatedNumber value={y} />
          </LabeledList.Item>
          <LabeledList.Item label="ETA">
            <AnimatedNumber
              value={eta} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title="Engines"
        buttons={(
          <Button
            tooltip="Refresh Engine"
            tooltipPosition="left"
            icon="sync"
            disabled={isViewer}
            onClick={() => act('reload_engines')} />
        )}>
        <Table>
          <Table.Row bold>
            <Table.Cell collapsing>
              Name
            </Table.Cell>
            <Table.Cell fluid>
              Fuel
            </Table.Cell>
          </Table.Row>
          {engineInfo && engineInfo.map(engine => (
            <Table.Row
              key={engine.name}
              className="candystripe">
              <Table.Cell collapsing>
                <Button
                  content={
                    (engine.name.len < 14) ? engine.name : engine.name.slice(0, 10) + "..."
                  }
                  color={engine.enabled && "good"}
                  icon={engine.enabled ? "toggle-on" : "toggle-off"}
                  disabled={isViewer}
                  tooltip="Toggle Engine"
                  tooltipPosition="right"
                  onClick={() => act('toggle_engine', {
                    engine: engine.ref,
                  })} />
              </Table.Cell>
              <Table.Cell fluid>
                {!!engine.maxFuel && (
                  <ProgressBar
                    fluid
                    ranges={{
                      good: [50, Infinity],
                      average: [25, 50],
                      bad: [-Infinity, 25],
                    }}
                    maxValue={engine.maxFuel}
                    minValue={0}
                    value={engine.fuel}>
                    <AnimatedNumber
                      value={engine.fuel / engine.maxFuel * 100}
                      format={value => Math.round(value)} />
                    %
                  </ProgressBar>
                )}
              </Table.Cell>
            </Table.Row>
          ))}
          <Table.Row>
            <Table.Cell>
              Est burn:
            </Table.Cell>
            <Table.Cell>
              <AnimatedNumber
                value={600 / (1/(shipInfo.est_thrust / (shipInfo.mass * 100)))}
                format={value => Math.round(value * 10) / 10} />
              spM/burn
            </Table.Cell>
          </Table.Row>
        </Table>
      </Section>
    </>
  );
};

// Arrow directional controls
const ShipControlContent = (props, context) => {
  const { act, data } = useBackend(context);
  const { calibrating } = data;
  let flyable = (data.state === 'flying');
  //  DIRECTIONS const idea from Lyra as part of their Haven-Urist project
  const DIRECTIONS = {
    north: 1,
    south: 2,
    east: 4,
    west: 8,
    northeast: 1 + 4,
    northwest: 1 + 8,
    southeast: 2 + 4,
    southwest: 2 + 8,
  };
  return (
    <Section
      title="Navigation"
      buttons={(
        <>
          <Button
            tooltip="Undock"
            tooltipPosition="left"
            icon="sign-out-alt"
            disabled={data.state !== 'idle'}
            onClick={() => act('undock')} />
          <Button
            tooltip="Dock in Empty Space"
            tooltipPosition="left"
            icon="sign-in-alt"
            disabled={data.state !== 'flying'}
            onClick={() => act('dock_empty')} />
          <Button
            tooltip={calibrating ? "Cancel Jump" : "Bluespace Jump"}
            tooltipPosition="left"
            icon={calibrating ? "times" : "angle-double-right"}
            color={calibrating ? "bad" : undefined}
            disabled={data.state !== 'flying'}
            onClick={() => act('bluespace_jump')} />
        </>
      )}>
      {data.state === 'idle' && (
        <div className="NoticeBox">
          Ship Docked.
        </div>
      )}
      <Table collapsing>
        <Table.Row height={1}>
          <Table.Cell width={1}>
            <Button
              icon="arrow-left"
              iconRotation={45}
              mb={1}
              disabled={!flyable}
              onClick={() => act('change_heading', {
                dir: DIRECTIONS.northwest,
              })} />
          </Table.Cell>
          <Table.Cell width={1}>
            <Button
              icon="arrow-up"
              mb={1}
              disabled={!flyable}
              onClick={() => act('change_heading', {
                dir: DIRECTIONS.north,
              })} />
          </Table.Cell>
          <Table.Cell width={1}>
            <Button
              icon="arrow-right"
              iconRotation={-45}
              mb={1}
              disabled={!flyable}
              onClick={() => act('change_heading', {
                dir: DIRECTIONS.northeast,
              })} />
          </Table.Cell>
        </Table.Row>
        <Table.Row height={1}>
          <Table.Cell width={1}>
            <Button
              icon="arrow-left"
              mb={1}
              disabled={!flyable}
              onClick={() => act('change_heading', {
                dir: DIRECTIONS.west,
              })} />
          </Table.Cell>
          <Table.Cell width={1}>
            <Button
              tooltip="Stop"
              icon="circle"
              mb={1}
              disabled={!data.speed || !flyable}
              onClick={() => act('stop')} />
          </Table.Cell>
          <Table.Cell width={1}>
            <Button
              icon="arrow-right"
              mb={1}
              disabled={!flyable}
              onClick={() => act('change_heading', {
                dir: DIRECTIONS.east,
              })} />
          </Table.Cell>
        </Table.Row>
        <Table.Row height={1}>
          <Table.Cell width={1}>
            <Button
              icon="arrow-left"
              iconRotation={-45}
              mb={1}
              disabled={!flyable}
              onClick={() => act('change_heading', {
                dir: DIRECTIONS.southwest,
              })} />
          </Table.Cell>
          <Table.Cell width={1}>
            <Button
              icon="arrow-down"
              mb={1}
              disabled={!flyable}
              onClick={() => act('change_heading', {
                dir: DIRECTIONS.south,
              })} />
          </Table.Cell>
          <Table.Cell width={1}>
            <Button
              icon="arrow-right"
              iconRotation={45}
              mb={1}
              disabled={!flyable}
              onClick={() => act('change_heading', {
                dir: DIRECTIONS.southeast,
              })} />
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};
