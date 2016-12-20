with Rx.Errors;

package body Rx.Op.Buffer is

   use Transform.Into.Conversions;

   type Counter is new Transform.Implementation.Operator with record
      Container : Transform.Into.D := Empty;

      Need      : Positive;
      Have      : Natural := 0;

      Skip      : Natural := 0;
      Skipped   : Natural := 0;

      Skipping  : Boolean := False;
   end record;

   overriding procedure On_Next (This  : in out Counter;
                                 V     :        Transform.From.T);

   overriding procedure On_Completed (This  : in out Counter);

   overriding procedure On_Error (This  : in out Counter;
                                  Error :        Errors.Occurrence);

   procedure Emit (This : in out Counter; Child : in out Transform.Into.Observer'Class) is
   begin
      This.Have := 0;
      This.Get_Subscriber.On_Next (+ This.Container);
      This.Container := Empty;
   end Emit;

   -------------
   -- On_Next --
   -------------

   overriding procedure On_Next (This  : in out Counter;
                                 V     :        Transform.From.T) is
   begin
      if This.Skipping then
         This.Skipped := This.Skipped + 1;

         if This.Skipped = This.Skip then
            This.Skipping := False;
         end if;
      else
         Append (This.Container, V);
         This.Have := This.Have + 1;

         if This.Have = This.Need then
            Emit (This, This.Get_Subscriber);

            if This.Skip > 0 then
               This.Skipping := True;
               This.Skipped  := 0;
            end if;
         end if;
      end if;
   end On_Next;

   ------------------
   -- On_Completed --
   ------------------

   overriding procedure On_Completed (This  : in out Counter) is
   begin
      if This.Have > 0 then
         Emit (This, This.Get_Subscriber);
      end if;
      This.Get_Subscriber.On_Completed;
   end On_Completed;

   --------------
   -- On_Error --
   --------------

   overriding procedure On_Error (This  : in out Counter;
                                  Error :        Errors.Occurrence) is
   begin
      if This.Have > 0 then
         Emit (This, This.Get_Subscriber);
         This.Get_Subscriber.On_Error (Error);
      end if;
   end On_Error;

   ------------
   -- Create --
   ------------

   function Create
     (Every : Positive;
      Skip : Natural := 0)
      return Transform.Operator'Class
   is
   begin
      return Transform.Create (Counter'(Transform.Implementation.Operator with
                               Need   => Every,
                               Skip   => Skip,
                               others => <>));
   end Create;

end Rx.Op.Buffer;
