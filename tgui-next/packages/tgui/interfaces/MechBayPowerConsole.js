import { Fragment } from 'inferno';
import { act, ref } from '../byond';
import { AnimatedNumber, ProgressBar, Section, Button, NoticeBox } from '../components';

export const MechBayPowerConsole = props => {
  const { state } = props;
  const { data, config } = state;
  const { ref } = config;
  return (
    <Fragment>
      <Section
        title="Integrity"
        textAlign="center"
        buttons={(
          <Button
            icon="sync"
            content="Sync"
            onClick={() => act(ref, "reconnect")} />)}>
        {data.recharge_port ? (
          data.recharge_port.mech ? (
            <ProgressBar
              ranges={{
                green: [0.7, 1],
                yellow: [0.3, 0.7],
                red: [0, 0.3]}}
              value={data.recharge_port.mech.health}
              minValue={0}
              maxValue={data.recharge_port.mech.maxhealth} />
          ) : (
            <NoticeBox>No mech detected.</NoticeBox>)
        ) : (
          <NoticeBox>No recharge port detected.</NoticeBox>)}
      </Section>
      <Section title="Power Status" textAlign="center">
        {data.recharge_port ? (
          data.recharge_port.mech ? (
            data.recharge_port.mech.cell ? (
              <ProgressBar
                ranges={{
                  green: [0.7, 1],
                  yellow: [0.3, 0.7],
                  red: [0, 0.3]}}
                value={data.recharge_port.mech.cell.charge}
                minValue={0}
                maxValue={data.recharge_port.mech.cell.maxcharge}>
                <AnimatedNumber value={data.recharge_port.mech.cell.charge} />
              </ProgressBar>
            ) : (
              <NoticeBox>No cell is installed.</NoticeBox>)
          ) : (
            <NoticeBox>No mech detected.</NoticeBox>)
        ) : (
          <NoticeBox>No recharge port detected.</NoticeBox>
        )}
      </Section>
    </Fragment>
  );
};
