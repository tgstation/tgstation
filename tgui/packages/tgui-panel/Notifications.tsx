/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { Flex } from 'tgui-core/components';

export const Notifications = (props) => {
  const { children } = props;
  return <div className="Notifications">{children}</div>;
};

const NotificationsItem = (props) => {
  const { rightSlot, children } = props;
  return (
    <Flex align="center" className="Notification">
      <Flex.Item className="Notification__content" grow={1}>
        {children}
      </Flex.Item>
      {rightSlot && (
        <Flex.Item className="Notification__rightSlot">{rightSlot}</Flex.Item>
      )}
    </Flex>
  );
};

Notifications.Item = NotificationsItem;
