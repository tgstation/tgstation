import type { ReactNode } from 'react';
import { resolveAsset } from 'tgui/assets';
import { Box } from 'tgui-core/components';

type BoxProps = React.ComponentProps<typeof Box>;

type NtosHeaderProps = {
  left?: ReactNode;
  right?: ReactNode;
  buttons?: ReactNode;
  onMouseDown?: (event: React.MouseEvent<HTMLDivElement>) => void;
};

export const NtosHeader = (props: NtosHeaderProps) => {
  const { left, right, buttons, onMouseDown } = props;
  return (
    <div className="NtosHeader" onMouseDown={onMouseDown}>
      <div className="NtosHeader__left">{left}</div>
      <div className="NtosHeader__right">
        {right}
        {buttons}
      </div>
    </div>
  );
};

type NtosHeaderIconProps = {
  name: string;
} & BoxProps;

export const NtosHeaderIcon = (props: NtosHeaderIconProps) => {
  const { name, children } = props;
  return (
    <Box inline {...props}>
      <img className="NtosHeader__icon" src={resolveAsset(name)} />
      {children}
    </Box>
  );
};
