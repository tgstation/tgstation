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
          <LabeledList.Item label="Occupant">
            <span>{data.occupant.name ? data.occupant.name : "No Occupant"}</span>
          </LabeledList.Item>
          {data.hasOccupant ? (
            <LabeledList.Item label="State">
              <span class='{data.occupant.statstate}'>{data.occupant.stat}</span>
            </LabeledList.Item>
            <LabeledList.Item label="Temperature">
              <span class='{data.occupant.temperaturestatus}'>{data.occupant.bodyTemperature} K</span>
            </LabeledList.Item>
            <LabeledList.Item label="Health">
              <ProgressBar
                value={data.occupant.health
                  / (data.occupant.maxHealth - data.occupant.minHealth)}></ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item>
              <LabeledList>
                {damageTypes.map(damageType => (
                  <LabeledList.Item label={damageType.label}>
                    <ProgressBar value={data.occupant[damageType.type]/100} content={data.occupant[damageType.type]}/>
                  </LabeledList.Item>
                ))}
              </LabeledList>
            </LabeledList.Item>
            ) : (
              <LabeledList.Item>No Occupant</LabeledList.Item>
            )}
        </LabeledList>
      </Section>
      <Section
        title="Cell">
        <LabeledList>
          <LabeledList.Item label="Power">
            <Button
              icon={data.isOperating ? "power-off" : "close"}
              disabled={data.isOpen}
              onClick={() => act(ref, 'power')}
              content={data.isOperating ? "On" : "Off"}/>
          </LabeledList.Item>
          <LabeledList.Item label="Temperature">
           <span class='{data.temperaturestatus}'>{data.cellTemperature} K</span>
          </LabeledList.Item>
          <LabeledList.Item label="Door">
            <Button
              icon={data.isOpen ? "unlock" : "lock"}
              onClick={() => act(ref, 'door')}
              content={data.isOpen ? "Open" : "Closed"}/>
            <Button
              icon={data.autoEject ? ("sign-out") : ("sign-in")}
              onClick={() => act(ref, 'autoeject')}
              content={data.autoEject ? "Auto" : "Manual"}/>
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title="Beaker"
        button={(<Button
                  icon="eject"
                  disabled={!!data.isBeakerLoaded}
                  onClick={() => act(ref, 'ejectbeaker')}
                  content="Eject"/>)}>
        <LabeledList>
          <LabeledList.Item label="Contents">
            {data.isBeakerLoaded ? (
              data.beakerContents ? (
                <LabeledList>
                data.beakerContents.map(beakerContent => (
                  <LabeledList.Item>
                    {beakerContent.volume} units of {beakerContent.name}
                  </LabeledList.Item>
                ))
                </LabeledList>
                ) : (
                  <span class='bad'>Beaker Empty</span>
                )
            ) : (
              <span class='average'>No Beaker</span>
            )}
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Fragment>
