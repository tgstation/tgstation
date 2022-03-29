import { useBackend } from '../../backend';
import { Button, LabeledList } from '../../components';
import { OperatorData, MechaUtility } from './data';

export const UtilityModulesPane = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const {
    mech_equipment,
  } = data;
  return (
    <LabeledList>
      {mech_equipment["utility"].map((module, i) => (
        <LabeledList.Item key={i} label={module.name}>
          {module.snowflake.snowflake_id ? (<Snowflake module={module} />
          ) : (
            <>
              <Button
                content={(module.activated ? "En" : "Dis") + "abled"}
                onClick={() => act('equip_act', {
                  ref: module.ref,
                  gear_action: "toggle",
                })}
                selected={module.activated} />
              <Button
                content={"Detach"}
                onClick={() => act('equip_act', {
                  ref: module.ref,
                  gear_action: "detach",
                })} />
            </>
          )}
        </LabeledList.Item>
      ))}
    </LabeledList>
  );
};

const MECHA_SNOWFLAKE_ID_EJECTOR = "ejector_snowflake";

// Handles all the snowflake buttons and whatever
const Snowflake = (props: {module: MechaUtility}, context) => {
  const {
    snowflake,
  } = props.module;
  switch (snowflake["snowflake_id"]) {
    case MECHA_SNOWFLAKE_ID_EJECTOR:
      return <SnowflakeEjector module={props.module} />;
    default:
      return null;
  }
};

const SnowflakeEjector = (props: {module: MechaUtility}, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const {
    cargo,
  } = props.module.snowflake;
  return (
    <LabeledList>
      {cargo.map((item, i) => (
        <LabeledList.Item key={i} label={item.name}>
          <Button
            onClick={() => act('equip_act', {
              ref: props.module.ref,
              cargoref: item.ref,
              gear_action: "eject",
            })}>
            {"Eject"}
          </Button>
        </LabeledList.Item>
      ))}
    </LabeledList>
  );
};
