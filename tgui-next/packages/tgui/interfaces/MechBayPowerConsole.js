import { act } from '../byond';
import { AnimatedNumber, Button, LabeledList, NoticeBox, ProgressBar, Section } from '../components';

export const MechBayPowerConsole = props => {
  const { state } = props;
  const { data, config } = state;
  const { ref } = config;
  const { recharge_port } = data;
  const mech = recharge_port && recharge_port.mech;
  const cell = mech && mech.cell;
  return (
    <Section
      title="Mech status"
      textAlign="center"
      buttons={(
        <Button
          icon="sync"
          content="Sync"
          onClick={() => act(ref, "reconnect")} />)}>
      <LabeledList>
        <LabeledList.Item label="Integrity">
          {!recharge_port && (
            <NoticeBox>No power port detected. Please re-sync.</NoticeBox>
          ) || !mech && (
            <NoticeBox>No mech detected.</NoticeBox>
          ) || (
            <ProgressBar
              ranges={{
                good: [mech.maxhealth * 0.7, Infinity],
                average: [mech.maxhealth * 0.3, mech.maxhealth * 0.7],
                bad: [-Infinity, mech.maxhealth * 0.3],
              }}
              value={mech.health}
              minValue={0}
              maxValue={mech.maxhealth} />
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Power">
          {!recharge_port && (
            <NoticeBox>No power port detected. Please re-sync.</NoticeBox>
          ) || !mech && (
            <NoticeBox>No mech detected.</NoticeBox>
          ) || !cell && (
            <NoticeBox>No cell is installed.</NoticeBox>
          ) || (
            <ProgressBar
              ranges={{
                good: [cell.maxcharge * 0.7, Infinity],
                average: [cell.maxcharge * 0.3, cell.maxcharge * 0.7],
                bad: [-Infinity, cell.maxcharge * 0.3],
              }}
              value={cell.charge}
              minValue={0}
              maxValue={cell.maxcharge}>
              <AnimatedNumber value={cell.charge} />
              {' / ' + cell.maxcharge}
            </ProgressBar>
          )}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
