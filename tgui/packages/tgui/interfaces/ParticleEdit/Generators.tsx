import { useBackend } from '../../backend';
import { NumberInput, Dropdown, Stack } from '../../components';
import { GeneratorProps, GeneratorTypes, GeneratorTypesNoVectors, ParticleUIData, P_DATA_GENERATOR, RandToNumber, RandTypes } from './data';

export const GeneratorListEntry = (props: GeneratorProps, context) => {
  const { act, data } = useBackend<ParticleUIData>(context);
  const { var_name, generator, allow_vectors } = props;
  // omits generators that are not allowed with certain vars
  const allowed_generators = allow_vectors
    ? GeneratorTypes
    : GeneratorTypesNoVectors;
  const type = generator ? generator[0] : 'num';
  const calcA = generator ? generator[1] : 'list(0,0,0)';
  const calcB = generator ? generator[2] : 'list(1,1,1)';
  const rand_type = generator ? generator[3] : 'UNIFORM_RAND';
  let A;
  let B;
  if (calcA.search('list') === -1) {
    // standard num
    A = parseFloat(calcA);
  } else {
    // it's a list so let's check what's inside
    A = calcA.replace('list(', '');
    A = A.replace(')', '');
    A = A.split(',');
    A = A.map((x) => parseFloat(x));
  }

  if (calcB.search('list') === -1) {
    // standard num
    B = parseFloat(calcB);
  } else {
    // it's a list so let's check what's inside
    B = calcB.replace('list(', '');
    B = B.replace(')', '');
    B = B.split(',');
    B = B.map((x) => parseFloat(x));
  }
  return (
    <>
      <Stack.Item>
        <Dropdown
          options={allowed_generators}
          selected={type}
          onSelected={(e) =>
            act('edit', {
              var: var_name,
              var_mod: P_DATA_GENERATOR,
              new_value: [e, A, B, RandToNumber[rand_type]],
            })
          }
          width="130px"
        />
      </Stack.Item>
      <Stack.Item>
        A:
        {typeof A === 'number' ? (
          <NumberInput
            animated
            value={A}
            minValue={0}
            onDrag={(e, value) =>
              act('edit', {
                var: var_name,
                var_mod: P_DATA_GENERATOR,
                new_value: [type, value, B, RandToNumber[rand_type]],
              })
            }
          />
        ) : (
          <>
            <NumberInput
              animated
              value={A[0]}
              onDrag={(e, value) =>
                act('edit', {
                  var: var_name,
                  var_mod: P_DATA_GENERATOR,
                  new_value: [
                    type,
                    [value, A[1], A[2]],
                    B,
                    RandToNumber[rand_type],
                  ],
                })
              }
            />
            <NumberInput
              animated
              value={A[1]}
              onDrag={(e, value) =>
                act('edit', {
                  var: var_name,
                  var_mod: P_DATA_GENERATOR,
                  new_value: [type, [A[0], value, A[2]], B, rand_type],
                })
              }
            />
            <NumberInput
              animated
              value={A[2]}
              onDrag={(e, value) =>
                act('edit', {
                  var: var_name,
                  var_mod: P_DATA_GENERATOR,
                  new_value: [type, [A[0], A[1], value], B, rand_type],
                })
              }
            />
          </>
        )}
      </Stack.Item>
      <Stack.Item>
        B:
        {typeof B === 'number' ? (
          <NumberInput
            animated
            value={B}
            onDrag={(e, value) =>
              act('edit', {
                var: var_name,
                var_mod: P_DATA_GENERATOR,
                new_value: [type, A, value, RandToNumber[rand_type]],
              })
            }
          />
        ) : (
          <>
            <NumberInput
              animated
              value={B[0]}
              onDrag={(e, value) =>
                act('edit', {
                  var: var_name,
                  var_mod: P_DATA_GENERATOR,
                  new_value: [
                    type,
                    A,
                    [value, B[1], B[2]],
                    RandToNumber[rand_type],
                  ],
                })
              }
            />
            <NumberInput
              animated
              value={B[1]}
              onDrag={(e, value) =>
                act('edit', {
                  var: var_name,
                  var_mod: P_DATA_GENERATOR,
                  new_value: [
                    type,
                    A,
                    [B[0], value, B[2]],
                    RandToNumber[rand_type],
                  ],
                })
              }
            />
            <NumberInput
              animated
              value={B[2]}
              onDrag={(e, value) =>
                act('edit', {
                  var: var_name,
                  var_mod: P_DATA_GENERATOR,
                  new_value: [
                    type,
                    A,
                    [B[0], B[1], value],
                    RandToNumber[rand_type],
                  ],
                })
              }
            />
          </>
        )}
      </Stack.Item>
      <Stack.Item>
        <Dropdown
          options={RandTypes}
          selected={rand_type}
          onSelected={(e, value) =>
            act('edit', {
              var: var_name,
              var_mod: P_DATA_GENERATOR,
              new_value: [type, A, B, RandToNumber[value]],
            })
          }
          width="130px"
        />
      </Stack.Item>
    </>
  );
};
