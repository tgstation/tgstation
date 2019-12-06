import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { AnimatedNumber, Button, LabeledList, ProgressBar, Section } from '../components';
import { BeakerContents } from './common/BeakerContents';

export const Cryo = props => {
  const { act, data } = useBackend(props);
  const damageTypes = [
    {
      label: "Brute",
      type: "bruteLoss",
    },
    {
      label: "Respiratory",
      type: "oxyLoss",
    },
    {
      label: "Toxin",
      type: "toxLoss",
    },
    {
      label: "Burn",
      type: "fireLoss",
    },
  ];
  return (
    <Fragment>
      <Section title="Occupant">
        <LabeledList>
          <LabeledList.Item
            label="Occupant"
            content={data.occupant.name ? data.occupant.name : "No Occupant"} />
          {!!data.hasOccupant && (
            <Fragment>
              <LabeledList.Item
                label="State"
                content={data.occupant.stat}
                color={data.occupant.statstate} />
              <LabeledList.Item
                label="Temperature"
                color={data.occupant.temperaturestatus}>
                <AnimatedNumber value={data.occupant.bodyTemperature} /> K
              </LabeledList.Item>
              <LabeledList.Item label="Health">
                <ProgressBar
                  value={data.occupant.health / data.occupant.maxHealth}
                  color={(data.occupant.health > 0) ? "good" : "average"}>
                  <AnimatedNumber value={data.occupant.health} />
                </ProgressBar>
              </LabeledList.Item>
              {(damageTypes.map(damageType => (
                <LabeledList.Item
                  key={damageType.id}
                  label={damageType.label}>
                  <ProgressBar
                    value={data.occupant[damageType.type]/100}>
                    <AnimatedNumber value={data.occupant[damageType.type]} />
                  </ProgressBar>
                </LabeledList.Item>
              )))}
            </Fragment>
          )}
        </LabeledList>
      </Section>
      <Section title="Cell">
        <LabeledList>
          <LabeledList.Item
            label="Power"
            content={(
              <Button
                icon={data.isOperating ? "power-off" : "times"}
                disabled={data.isOpen}
                onClick={() => act('power')}
                color={data.isOperating && ("green")}>
                {data.isOperating ? "On" : "Off"}
              </Button>
            )} />
          <LabeledList.Item label="Temperature">
            <AnimatedNumber value={data.cellTemperature} /> K
          </LabeledList.Item>
          <LabeledList.Item label="Door">
            <Button
              icon={data.isOpen ? "unlock" : "lock"}
              onClick={() => act('door')}
              content={data.isOpen ? "Open" : "Closed"} />
            <Button
              icon={data.autoEject ? "sign-out-alt" : "sign-in-alt"}
              onClick={() => act('autoeject')}
              content={data.autoEject ? "Auto" : "Manual"} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title="Beaker"
        buttons={(
          <Button
            icon="eject"
            disabled={!data.isBeakerLoaded}
            onClick={() => act('ejectbeaker')}
            content="Eject" />
        )}>
        <BeakerContents
          beakerLoaded={data.isBeakerLoaded}
          beakerContents={data.beakerContents} />
      </Section>
    </Fragment>
  );
};
