import { createRef, PropsWithChildren, useEffect } from 'react';

export const Autofocus = (props: PropsWithChildren) => {
  const ref = createRef<HTMLDivElement>();

  useEffect(() => {
    setTimeout(() => {
      ref.current?.focus();
    }, 1);
  }, []);

  return (
    <div ref={ref} tabIndex={-1}>
      {props.children}
    </div>
  );
};
