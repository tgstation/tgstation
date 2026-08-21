/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { Window } from './Window';

export const NtosWindow = (props) => {
  const { width = 575, height = 700, children } = props;
  return <div>{children}</div>;
};

const NtosWindowContent = (props) => {
  return (
    <div className="NtosWindow__content">
      <Window.Content {...props} />
    </div>
  );
};

NtosWindow.Content = NtosWindowContent;
