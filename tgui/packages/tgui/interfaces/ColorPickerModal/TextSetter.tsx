/**
 * @file
 * @copyright 2023 itsmeow
 * @license MIT
 */
import React, { useCallback, useEffect, useMemo, useState } from 'react';
import { validHex } from 'tgui-core/color';
import { Input, NumberInput } from 'tgui-core/components';

interface TextSetterProps {
  value: number;
  callback: (value: number) => void;
  min?: number;
  max?: number;
  unit?: string;
}

export const TextSetter: React.FC<TextSetterProps> = React.memo(
  ({ value, callback, min = 0, max = 100, unit }) => {
    return (
      <NumberInput
        width="70px"
        value={Math.round(value)}
        step={1}
        minValue={min}
        maxValue={max}
        onChange={callback}
        unit={unit}
      />
    );
  },
);

interface HexColorInputProps {
  prefixed?: boolean;
  alpha?: boolean;
  color: string;
  fluid?: boolean;
  onChange: (newColor: string) => void;
}

export const HexColorInput: React.FC<HexColorInputProps> = React.memo(
  ({ alpha, color, fluid, onChange, ...rest }) => {
    const initialColor = useMemo(() => {
      const stripped = color
        .replace(/[^0-9A-Fa-f]/g, '')
        .substring(0, 6)
        .toUpperCase();
      return stripped;
    }, [color]);

    const [localValue, setLocalValue] = useState(initialColor);

    useEffect(() => {
      setLocalValue(initialColor);
    }, [initialColor]);

    const isValidFullHex = useCallback(
      (val: string) => {
        return validHex(val, alpha) && val.length === 6;
      },
      [alpha],
    );

    const handleChangeEvent = (value: string) => {
      const strippedValue = value
        .replace(/[^0-9A-Fa-f]/g, '')
        .substring(0, 6)
        .toUpperCase();

      setLocalValue(strippedValue);

      if (isValidFullHex(strippedValue)) {
        onChange(strippedValue);
      }
    };

    const commitOrRevert = useCallback(() => {
      if (isValidFullHex(localValue)) {
        onChange(localValue);
      } else {
        setLocalValue(initialColor);
      }
    }, [initialColor, isValidFullHex, localValue, onChange]);

    const handleBlur = () => {
      commitOrRevert();
    };

    const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
      if (e.key === 'Enter') {
        commitOrRevert();
        (e.currentTarget as HTMLInputElement).blur();
      }
    };

    return (
      <Input
        fluid
        value={localValue}
        onChange={handleChangeEvent}
        onBlur={handleBlur}
        onKeyDown={handleKeyDown}
        {...rest}
      />
    );
  },
);
