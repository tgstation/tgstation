
import { useBackend } from '../../backend';
import { LabeledList } from '../../components';

export const GasmixParser = (props, context) => {
  const { act, data } = useBackend(context);
  const { gases=[], temperature, volume, pressure, total_moles } = props;
  return (
    <LabeledList>
      {Object.keys(gases).map((gas_name) => (
        <LabeledList.Item label={gas_name} key={gas_name}>
          {gases[gas_name].toFixed(2)
            + ' mol ('
            + ((gases[gas_name] / total_moles) * 100).toFixed(2)
            + ' %)'}
        </LabeledList.Item>
      ))}
      <LabeledList.Item label="Temperature">
        {(total_moles ? temperature.toFixed(2) : "-")+ ' K'}
      </LabeledList.Item>
      <LabeledList.Item label="Volume">{(total_moles ? volume.toFixed(2) : "-") + ' L'}</LabeledList.Item>
      <LabeledList.Item label="Pressure">{(total_moles ? pressure.toFixed(2) : "-") + ' kPa'}</LabeledList.Item>
    </LabeledList>
  );
};
