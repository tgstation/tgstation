import { LabeledList, Box, Button } from '../../components';

export type Gasmix = {
  name?: string;
  gases: [string, string, number][]; // ID, name, and amount.
  temperature: number;
  volume: number;
  pressure: number;
  total_moles: number;
  heat_capacity: number;
  thermal_energy: number;
  reactions: [string, string, number][]; // ID, name, and amount.
  reference: string;
};

type GasmixParserProps = {
  gasmix: Gasmix;
  totalMolesOnClick?: () => void;
  gasesOnClick?: (gas_id: string) => void;
  temperatureOnClick?: () => void;
  volumeOnClick?: () => void;
  pressureOnClick?: () => void;
  heatCapacityOnClick?: () => void;
  thermalEnergyOnClick?: () => void;
  reactionOnClick?: (reaction_id: string) => void;
  // Whether we need to show the number of the reaction or not
  detailedReactions?: boolean;
};

export const GasmixParser = (props: GasmixParserProps, context) => {
  const {
    gasmix,
    totalMolesOnClick,
    gasesOnClick,
    temperatureOnClick,
    volumeOnClick,
    pressureOnClick,
    heatCapacityOnClick,
    thermalEnergyOnClick,
    reactionOnClick,
    detailedReactions,
    ...rest
  } = props;

  const {
    gases,
    temperature,
    volume,
    pressure,
    total_moles,
    heat_capacity,
    thermal_energy,
    reactions,
  } = gasmix;

  return !total_moles ? (
    <Box nowrap italic mb="10px">
      {'No Gas Detected!'}
    </Box>
  ) : (
    <LabeledList {...rest}>
      <LabeledList.Item
        label={
          totalMolesOnClick ? (
            <Button
              content={'Total Moles'}
              onClick={() => totalMolesOnClick()}
            />
          ) : (
            'Total Moles'
          )
        }>
        {(total_moles
          ? total_moles.toLocaleString(undefined, {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2,
          })
          : '-') + ' mol'}
      </LabeledList.Item>
      {gases.map((gas) => (
        <LabeledList.Item
          label={
            gasesOnClick ? (
              <Button content={gas[1]} onClick={() => gasesOnClick(gas[0])} />
            ) : (
              gas[1]
            )
          }
          key={gas[1]}>
          {gas[2].toLocaleString(undefined, {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2,
          }) +
            ' mol (' +
            ((gas[2] / total_moles) * 100).toLocaleString(undefined, {
              minimumFractionDigits: 2,
              maximumFractionDigits: 2,
            }) +
            ' %)'}
        </LabeledList.Item>
      ))}
      <LabeledList.Item
        label={
          temperatureOnClick ? (
            <Button
              content={'Temperature'}
              onClick={() => temperatureOnClick()}
            />
          ) : (
            'Temperature'
          )
        }>
        {(total_moles
          ? (temperature - 273.15).toLocaleString(undefined, {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2,
          })
          : '-') +
          ' °C (' +
          (total_moles
            ? temperature.toLocaleString(undefined, {
              minimumFractionDigits: 2,
              maximumFractionDigits: 2,
            })
            : '-') +
          ' K)'}
      </LabeledList.Item>
      <LabeledList.Item
        label={
          volumeOnClick ? (
            <Button content={'Volume'} onClick={() => volumeOnClick()} />
          ) : (
            'Volume'
          )
        }>
        {(total_moles
          ? volume.toLocaleString(undefined, {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2,
          })
          : '-') + ' L'}
      </LabeledList.Item>
      <LabeledList.Item
        label={
          pressureOnClick ? (
            <Button content={'Pressure'} onClick={() => pressureOnClick()} />
          ) : (
            'Pressure'
          )
        }>
        {(total_moles
          ? pressure.toLocaleString(undefined, {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2,
          })
          : '-') + ' kPa'}
      </LabeledList.Item>
      <LabeledList.Item
        label={
          heatCapacityOnClick ? (
            <Button
              content={'Heat Capacity'}
              onClick={() => heatCapacityOnClick()}
            />
          ) : (
            'Heat Capacity'
          )
        }>
        {heat_capacity + ' / K'}
      </LabeledList.Item>
      <LabeledList.Item
        label={
          thermalEnergyOnClick ? (
            <Button
              content={'Thermal Energy'}
              onClick={() => thermalEnergyOnClick()}
            />
          ) : (
            'Thermal Energy'
          )
        }>
        {thermal_energy}
      </LabeledList.Item>
      {detailedReactions ? (
        reactions.map((reaction) => (
          <LabeledList.Item
            key={`${gasmix.reference}-${reaction[0]}`}
            label={
              reactionOnClick ? (
                <Button
                  content={reaction[1]}
                  onClick={reactionOnClick(reaction[0])}
                />
              ) : (
                reaction[1]
              )
            }>
            {reaction[2]}
          </LabeledList.Item>
        ))
      ) : (
        <LabeledList.Item label="Gas Reactions">
          {reactions.length
            ? reactions.map((reaction) =>
              reactionOnClick ? (
                <Box mb="0.5em">
                  <Button
                    content={reaction[1]}
                    onClick={() => reactionOnClick(reaction[0])}
                  />
                </Box>
              ) : (
                <div>{reaction[1]}</div>
              )
            )
            : 'No reactions detected'}
        </LabeledList.Item>
      )}
    </LabeledList>
  );
};
