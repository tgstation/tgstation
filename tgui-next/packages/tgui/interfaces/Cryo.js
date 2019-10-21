import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, LabeledList, ProgressBar, Section} from '../components';

export const Cryo = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const damageTypes = [
    {
      label: "Brute",
      type: "bruteloss",
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
      type: "fireloss",
    },
  ];

  return (
    <Fragment>
      <Section
        title="Occupant">
        <LabeledList>
          <LabeledList.Item
            label="Occupant"
            content={data.occupant.name ? data.occupant.name : "No Occupant"} />
          {data.hasOccupant && (
            <Fragment>
              <LabeledList.Item
                label="State"
                content={data.occupant.stat} />
              <LabeledList.Item
                label="Temperature"
                content={data.occupant.bodyTemperature} />
              <LabeledList.Item
                label="Health"
                content={(
                  <ProgressBar
                    value={data.occupant.health / (data.occupant.maxHealth - data.occupant.minHealth)}
                    content="" />)} />
              <LabeledList.Item
                content={(damageTypes.map(damageType => (
                  <LabeledList.Item
                    key={damageType.id}
                    label={damageType.label}
                    content={(
                      <ProgressBar
                        value={data.occupant[damageType.type]/100}
                        content={data.occupant[damageType.type]} />
                    )} />
                )))} />
            </Fragment>
          )}
        </LabeledList>
      </Section>
      <Section
        title="Cell">
        <LabeledList>
          <LabeledList.Item
            label="Power"
            content={(
              <Button
                icon={data.isOperating ? "power-off" : "close"}
                disabled={data.isOpen}
                onClick={() => act(ref, 'power')}
                content={data.isOperating ? "On" : "Off"} />
            )} />
          <LabeledList.Item
            label="Temperature"
            content={data.cellTemperature} K />
          <LabeledList.Item label="Door">
            <Button
              icon={data.isOpen ? "unlock" : "lock"}
              onClick={() => act(ref, 'door')}
              content={data.isOpen ? "Open" : "Closed"} />
            <Button
              icon={data.autoEject ? ("sign-out") : ("sign-in")}
              onClick={() => act(ref, 'autoeject')}
              content={data.autoEject ? "Auto" : "Manual"} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title="Beaker"
        button={(
          <Button
            icon="eject"
            disabled={!!data.isBeakerLoaded}
            onClick={() => act(ref, 'ejectbeaker')}
            content="Eject" />
        )}>
        <LabeledList>
          <LabeledList.Item label="Contents">
            {data.isBeakerLoaded ? (
              data.beakerContents ? (
                <LabeledList>
                  {data.beakerContents.map(beakerContent => (
                    <LabeledList.Item
                      key={damageType.id} >
                      {beakerContent.volume} units of {beakerContent.name}
                    </LabeledList.Item>
                  ))}
                </LabeledList>
              ) : (
                <Fragment>Beaker Empty</Fragment>
              )
            ) : (
              <Fragment>No Beaker</Fragment>
            )}
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Fragment>
  ); };
