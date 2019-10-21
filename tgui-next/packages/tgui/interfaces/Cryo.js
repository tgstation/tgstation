import { Fragment } from 'inferno';
import { act } from '../byond';
import { Box, Button, LabeledList, ProgressBar, Section} from '../components';

export const Cryo = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
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
      <Section
        title="Occupant">
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
                content={data.occupant.bodyTemperature + ' K'}
                color={data.occupant.temperaturestatus} />
              <LabeledList.Item
                label="Health"
                content={(
                  <ProgressBar
                    value={data.occupant.health / data.occupant.maxHealth}
                    content={data.occupant.health}
                    color={(data.occupant.health > 0) ? "good" : "average"} />)} />
              {(damageTypes.map(damageType => (
                  <LabeledList.Item
                    key={damageType.id}
                    label={damageType.label}
                    content={(
                      <ProgressBar
                        value={data.occupant[damageType.type]/100}
                        content={data.occupant[damageType.type]} />
                    )} />
                )))}
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
                icon={data.isOperating ? "power-off" : "times"}
                disabled={data.isOpen}
                onClick={() => act(ref, 'power')}
                content={data.isOperating ? "On" : "Off"}
                color={data.isOperating && ("green")} />
            )} />
          <LabeledList.Item
            label="Temperature"
            content={data.cellTemperature + ' K'} />
          <LabeledList.Item label="Door">
            <Button
              icon={data.isOpen ? "unlock" : "lock"}
              onClick={() => act(ref, 'door')}
              content={data.isOpen ? "Open" : "Closed"} />
            <Button
              icon={data.autoEject ? "sign-out-alt" : "sign-in-alt"}
              onClick={() => act(ref, 'autoeject')}
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
            onClick={() => act(ref, 'ejectbeaker')}
            content="Eject" />
        )}>
        <LabeledList>
          <LabeledList.Item label="Contents">
            {data.isBeakerLoaded ? (
              data.beakerContents ? (
                  data.beakerContents.map(beakerContent => (
                    <Box
                      key={beakerContent.id}
                      color="pale-blue" >
                      {beakerContent.volume} units of {beakerContent.name}
                    </Box>
                  ))
              ) : (
                "Beaker Empty"
              )
            ) : (
              "No Beaker"
            )}
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Fragment>
  ); };
