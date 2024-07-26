import { PropsWithChildren, useEffect, useRef } from 'react';

/** Used to force the window to steal focus on load. Children optional */
export function Autofocus(props: PropsWithChildren) {
  const { children } = props;
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const timer = setTimeout(() => {
      ref.current?.focus();
    }, 1);

    return () => {
      clearTimeout(timer);
    };
  }, []);

  return (
    <div ref={ref} tabIndex={-1}>
      {children}
    </div>
  );
}
