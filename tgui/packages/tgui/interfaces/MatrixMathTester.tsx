import { useBackend, useLocalState } from '../backend';
import { Input, NumberInput, Section, Button, Table } from '../components';
import { toFixed } from 'common/math';
import { Window } from '../layouts';

const MatrixMathTesterInput = (
  props: { value: number; varName: string },
  context
) => {
  const { act } = useBackend(context);
  return (
    <NumberInput
      value={props.value}
      step={0.005}
      format={(value) => toFixed(value, 3)}
      width={'100%'}
      onChange={(e, value) =>
        act('change_var', { var_name: props.varName, var_value: value })
      }
    />
  );
};

type MatrixData = {
  matrix_a: number;
  matrix_b: number;
  matrix_c: number;
  matrix_d: number;
  matrix_e: number;
  matrix_f: number;
  pixelated: boolean;
};

export const MatrixMathTester = (props, context) => {
  const { act, data } = useBackend<MatrixData>(context);
  const {
    matrix_a,
    matrix_b,
    matrix_c,
    matrix_d,
    matrix_e,
    matrix_f,
    pixelated,
  } = data;
  const [scaleX, setScaleX] = useLocalState(context, 'scale_x', 1);
  const [scaleY, setScaleY] = useLocalState(context, 'scale_y', 1);
  const [translateX, setTranslateX] = useLocalState(context, 'translate_x', 0);
  const [translateY, setTranslateY] = useLocalState(context, 'translate_y', 0);
  const [shearX, setShearX] = useLocalState(context, 'shear_x', 0);
  const [shearY, setShearY] = useLocalState(context, 'shear_y', 0);
  const [angle, setAngle] = useLocalState(context, 'angle', 0);
  return (
    <Window title="Nobody Wants to Learn Matrix Math" width={290} height={270}>
      <Window.Content>
        <Section fill>
          <Table>
            <Table.Row header>
              <Table.Cell width={'30%'}>X</Table.Cell>
              <Table.Cell width={'30%'}>Y</Table.Cell>
              <Table.Cell width={'40%'}>Z</Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>
                <MatrixMathTesterInput value={matrix_a} varName="a" />
              </Table.Cell>
              <Table.Cell>
                <MatrixMathTesterInput value={matrix_d} varName="d" />
              </Table.Cell>
              <Table.Cell>
                <Input disabled placeholder="0 (fixed value)" width={'100%'} />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>
                <MatrixMathTesterInput value={matrix_b} varName="b" />
              </Table.Cell>
              <Table.Cell>
                <MatrixMathTesterInput value={matrix_e} varName="e" />
              </Table.Cell>
              <Table.Cell>
                <Input disabled placeholder="0 (fixed value)" width={'100%'} />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>
                <MatrixMathTesterInput value={matrix_c} varName="c" />
              </Table.Cell>
              <Table.Cell>
                <MatrixMathTesterInput value={matrix_f} varName="f" />
              </Table.Cell>
              <Table.Cell>
                <Input disabled placeholder="1 (fixed value)" width={'100%'} />
              </Table.Cell>
            </Table.Row>
          </Table>
          <Table mt={3}>
            <Table.Row header>
              <Table.Cell>Action</Table.Cell>
              <Table.Cell>X</Table.Cell>
              <Table.Cell>Y</Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>
                <Button
                  icon={'up-right-and-down-left-from-center'}
                  content={'Scale'}
                  width={'100%'}
                  onClick={() => act('scale', { x: scaleX, y: scaleY })}
                />
              </Table.Cell>
              <Table.Cell>
                <NumberInput
                  value={scaleX}
                  step={0.05}
                  format={(value) => toFixed(value, 2)}
                  width={'100%'}
                  onChange={(e, value) => setScaleX(value)}
                />
              </Table.Cell>
              <Table.Cell>
                <NumberInput
                  value={scaleY}
                  step={0.05}
                  format={(value) => toFixed(value, 2)}
                  width={'100%'}
                  onChange={(e, value) => setScaleY(value)}
                />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>
                <Button
                  icon={'arrow-right'}
                  content={'Translate'}
                  width={'100%'}
                  onClick={() =>
                    act('translate', { x: translateX, y: translateY })
                  }
                />
              </Table.Cell>
              <Table.Cell>
                <NumberInput
                  value={translateX}
                  step={1}
                  format={(value) => toFixed(value, 0)}
                  width={'100%'}
                  onChange={(e, value) => setTranslateX(value)}
                />
              </Table.Cell>
              <Table.Cell>
                <NumberInput
                  value={translateY}
                  step={1}
                  format={(value) => toFixed(value, 0)}
                  width={'100%'}
                  onChange={(e, value) => setTranslateY(value)}
                />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>
                <Button
                  icon={'maximize'}
                  content={'Shear'}
                  width={'100%'}
                  onClick={() => act('shear', { x: shearX, y: shearY })}
                />
              </Table.Cell>
              <Table.Cell>
                <NumberInput
                  value={shearX}
                  step={0.005}
                  format={(value) => toFixed(value, 3)}
                  width={'100%'}
                  onChange={(e, value) => setShearX(value)}
                />
              </Table.Cell>
              <Table.Cell>
                <NumberInput
                  value={shearY}
                  step={0.005}
                  format={(value) => toFixed(value, 3)}
                  width={'100%'}
                  onChange={(e, value) => setShearY(value)}
                />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>
                <Button
                  icon={'rotate-right'}
                  content={'Rotate'}
                  width={'100%'}
                  onClick={() => act('turn', { angle: angle })}
                />
              </Table.Cell>
              <Table.Cell>
                <NumberInput
                  value={angle}
                  step={0.5}
                  maxValue={360}
                  minValue={-360}
                  format={(value) => toFixed(value, 1)}
                  width={'100%'}
                  onChange={(e, value) => setAngle(value)}
                />
              </Table.Cell>
              <Table.Cell>
                <Button
                  icon={'dog'}
                  color={'bad'}
                  selected={pixelated}
                  content={'PET'}
                  tooltip={'Pixel Enhanced Transforming'}
                  tooltipPosition={'bottom'}
                  width={'100%'}
                  onClick={() => act('toggle_pixel')}
                />
              </Table.Cell>
            </Table.Row>
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
