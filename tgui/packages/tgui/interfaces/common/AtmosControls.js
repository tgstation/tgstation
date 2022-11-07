import { decodeHtmlEntities } from 'common/string';
import { useBackend } from '../../backend';
import { Button, LabeledList, NumberInput, Section } from '../../components';
import { getGasLabel } from '../../constants';

export const Vent = (props, context) => {
  const { vent } = props;
  const { act } = useBackend(context);
  const {
    ref,
    long_name,
    power,
    checks,
    excheck,
    incheck,
    direction,
    external,
    internal,
    extdefault,
    intdefault,
  } = vent;
  return (
    <Section
      level={2}
      title={decodeHtmlEntities(long_name)}
      buttons={
        <Button
          icon={power ? 'power-off' : 'times'}
          selected={power}
          content={power ? 'On' : 'Off'}
          onClick={() =>
            act('power', {
              ref,
              val: Number(!power),
            })
          }
        />
      }>
      <LabeledList>
        <LabeledList.Item label="Mode">
          <Button
            icon="sign-in-alt"
            content={direction ? 'Pressurizing' : 'Siphoning'}
            color={!direction && 'danger'}
            onClick={() =>
              act('direction', {
                ref,
                val: Number(!direction),
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Pressure Regulator">
          <Button
            icon="sign-in-alt"
            content="Internal"
            selected={incheck}
            onClick={() =>
              act('incheck', {
                ref,
                val: checks,
              })
            }
          />
          <Button
            icon="sign-out-alt"
            content="External"
            selected={excheck}
            onClick={() =>
              act('excheck', {
                ref,
                val: checks,
              })
            }
          />
        </LabeledList.Item>
        {!!incheck && (
          <LabeledList.Item label="Internal Target">
            <NumberInput
              value={Math.round(internal)}
              unit="kPa"
              width="75px"
              minValue={0}
              step={10}
              maxValue={5066}
              onChange={(e, value) =>
                act('set_internal_pressure', {
                  ref,
                  value,
                })
              }
            />
            <Button
              icon="undo"
              disabled={intdefault}
              content="Reset"
              onClick={() =>
                act('reset_internal_pressure', {
                  ref,
                })
              }
            />
          </LabeledList.Item>
        )}
        {!!excheck && (
          <LabeledList.Item label="External Target">
            <NumberInput
              value={Math.round(external)}
              unit="kPa"
              width="75px"
              minValue={0}
              step={10}
              maxValue={5066}
              onChange={(e, value) =>
                act('set_external_pressure', {
                  ref,
                  value,
                })
              }
            />
            <Button
              icon="undo"
              disabled={extdefault}
              content="Reset"
              onClick={() =>
                act('reset_external_pressure', {
                  ref,
                })
              }
            />
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};

export const Scrubber = (props, context) => {
  const { scrubber } = props;
  const { act } = useBackend(context);
  const { long_name, power, scrubbing, ref, widenet, filter_types } = scrubber;
  return (
    <Section
      level={2}
      title={decodeHtmlEntities(long_name)}
      buttons={
        <Button
          icon={power ? 'power-off' : 'times'}
          content={power ? 'On' : 'Off'}
          selected={power}
          onClick={() =>
            act('power', {
              ref,
              val: Number(!power),
            })
          }
        />
      }>
      <LabeledList>
        <LabeledList.Item label="Mode">
          <Button
            icon={scrubbing ? 'filter' : 'sign-in-alt'}
            color={scrubbing || 'danger'}
            content={scrubbing ? 'Scrubbing' : 'Siphoning'}
            onClick={() =>
              act('scrubbing', {
                ref,
                val: Number(!scrubbing),
              })
            }
          />
          <Button
            icon={widenet ? 'expand' : 'compress'}
            selected={widenet}
            content={widenet ? 'Expanded range' : 'Normal range'}
            onClick={() =>
              act('widenet', {
                ref,
                val: Number(!widenet),
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Filters">
          {(scrubbing &&
            filter_types.map((filter) => (
              <Button
                key={filter.gas_id}
                icon={filter.enabled ? 'check-square-o' : 'square-o'}
                content={getGasLabel(filter.gas_id, filter.gas_name)}
                title={filter.gas_name}
                selected={filter.enabled}
                onClick={() =>
                  act('toggle_filter', {
                    ref,
                    val: filter.gas_id,
                  })
                }
              />
            ))) ||
            'N/A'}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
