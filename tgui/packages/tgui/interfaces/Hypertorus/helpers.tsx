import { Icon, Tooltip } from 'tgui-core/components';

// Exponential rendering specifically for HFR values.
// Note that we don't want to use unicode exponents as anything over ^3
// is more or less unreadable.
export const to_exponential_if_big = (value: number) => {
  if (Math.abs(value) > 5000) {
    return value.toExponential(1);
  }
  return Math.round(value);
};

// Simple question mark icon with a hover tooltip
export const HoverHelp = ({ content }: { content: string }) => {
  return (
    <Tooltip content={content}>
      <Icon name="question-circle" width="12px" mr="6px" />
    </Tooltip>
  );
};

// When no hover help is available, but we want a placeholder for spacing
export const HelpDummy = (props) => {
  return <Icon name="" width="12px" mr="6px" />;
};
