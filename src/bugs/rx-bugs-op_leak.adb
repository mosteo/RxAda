with Rx.Integers; use Rx.Integers; use Rx.Integers.Observables;
with Rx.Debug; use Rx.Debug;
with Rx.Subscriptions;

procedure Rx.Bugs.Op_Leak is

begin
   for I in 1 .. 3 loop
      Put_Line ("---8<---");
      declare
         Leak : Integers.Observable :=
                  No_Op
                  &
                  No_Op;

         --  OTOH, valgrind is unable to pinpoint the leak

      begin
         -- Leak := No_Op; -- This line would fix the leak, by forcing a finalization on Leak
         null;
      end;
      Put_Line ("--->8---");
   end loop;

   Put_Line ("END");

--   Dump;
end Rx.Bugs.Op_Leak;