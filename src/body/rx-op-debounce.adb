with Ada.Unchecked_Deallocation;

with Rx.Debug;
with Rx.Errors;
with Rx.Holders;
with Rx.Impl.Events;
with Rx.Subscriptions;

package body Rx.Op.Debounce is

   package From renames Operate.From;
   package Into renames Operate.Into;

   package Events is new Rx.Impl.Events (Operate.Typed);
   --  package Shared is new Rx.Impl.Shared_Subscriber (Operate.Typed);

   task type Debouncer is

      entry Init (Window : Duration; Child : Into.Subscriber);

      entry On_Event (Event : Events.Event);

   end Debouncer;

   type Debouncer_Ptr is access all Debouncer;

   procedure Free_When_Terminated is new Ada.Unchecked_Deallocation (Debouncer, Debouncer_Ptr);

   type Operator is new Operate.Subscriber with record
      Window : Duration;
      Live   : Debouncer_Ptr;
   end record;

   overriding
   procedure On_Next (This  : in out Operator;
                      V     :        From.T);
   --  Must always be provided

   overriding
   procedure On_Completed (This  : in out Operator);
   --  By default calls Child.On_Complete

   overriding
   procedure On_Error (This  : in out Operator;
                       Error :        Errors.Occurrence);

   overriding
   procedure Set_subscriber (Producer : in out Operator;
                             Consumer :        Into.Subscriber);

   overriding
   procedure Unsubscribe (This : in out Operator);

   ---------------
   -- Debouncer --
   ---------------

   task body Debouncer is

      Self : Debouncer_Ptr := Debouncer'Unchecked_Access;

      Child     : Operate.Typed.Holders.Subscriber;
      Window    : Duration;

      package Event_Holders is new Rx.Holders (Events.Event, "debounce_events");
      type Event_Holder is new Event_Holders.Definite with null record;

      Next	 : Event_Holder;
      Other      : Event_Holder;

      use all type Events.Kinds;

      -----------
      -- Flush --
      -----------

      procedure Flush (Elapsed : Boolean) is
         --  When Elapsed, the window has expired with nothing received
      begin

         if (Elapsed or else Other.Is_Valid) and then Next.Is_Valid then
            if Child.Ref.Is_Subscribed then
               begin
                  Child.Ref.On_Next (Events.Value (Next.CRef));
               exception
                  when Subscriptions.No_Longer_Subscribed =>
                     Debug.Log ("Debounce.Flush: Seen No_Longer_Subscribed", Debug.Note);
                  when E : others =>
                     Operate.Typed.Default_Error_Handler (Child.Ref, E);
               end;
            end if;
            Next.Clear;
         end if;

         if Other.Is_Valid then
            case Other.CRef.Kind is
               when On_Completed =>
                  Child.Ref.On_Completed;
               when On_Error =>
                  Child.Ref.On_Error (Events.Error (Other.CRef));
               when Unsubscribe =>
                  Child.Ref.Unsubscribe;
               when On_Next =>
                  raise Program_Error with "Should never happen";
            end case;
         end if;

      end Flush;

   begin

      accept Init (Window : Duration; Child : Into.Subscriber) do
         Debouncer.Window := Window;
         Debouncer.Child.Hold (Child);
      end;

      loop
         if not Next.Is_Valid then
            select
               accept On_Event (Event : Events.Event) do
                  if Event.Kind = On_Next then
                     Next.Hold (Event);
                  else
                     Other.Hold (Event);
                     Flush (Elapsed => False);
                  end if;
               end;
            or
               terminate;
            end select;
         else
            select
               accept On_Event (Event : Events.Event) do
                  if Event.Kind = On_Next then
                     Next.Hold (Event);
                  else
                     Other.Hold (Event);
                  end if;
               end;
               Flush (Elapsed => False);
            or
               delay Window;
               Flush (Elapsed => True);
            end select;
         end if;

         exit when Other.Is_Valid; -- Some other event

      end loop;

      Free_When_Terminated (Self);
   exception
      when E : others =>
         Debug.Report (E, "At Debouncer final handler:", Debug.Warn, Reraise => False);
         Free_When_Terminated (Self);
   end Debouncer;

   overriding
   procedure On_Next (This  : in out Operator;
                      V     :        From.T)
   is
   begin
      This.Live.On_Event (Events.On_Next (V));
   end On_Next;

   overriding
   procedure On_Completed (This  : in out Operator)
   is
   begin
      This.Live.On_Event (Events.On_Completed);
   end On_Completed;

   overriding
   procedure On_Error (This  : in out Operator;
                       Error :        Errors.Occurrence)
   is
   begin
      This.Live.On_Event (Events.On_Error (Error));
   end On_Error;

   ---------------
   -- Subscribe --
   ---------------

   overriding
   procedure Set_Subscriber (Producer : in out Operator;
                             Consumer :        Into.Subscriber)
   is
   begin
      Producer.Live  := new Debouncer;
      Producer.Live.Init (Producer.Window, Consumer);
      Operate.Subscriber (Producer).Set_Subscriber (Consumer);
      -- Consumer never to be used, so ideally we should use some always-failing consumer as child
   end Set_Subscriber;

   -----------------
   -- Unsubscribe --
   -----------------

   overriding procedure Unsubscribe (This : in out Operator) is begin
      This.Live.On_Event (Events.Unsubscribe);
   end Unsubscribe;

   ------------
   -- Create --
   ------------

   function Create (Window : Duration) return Operate.Operator is
   begin
      return Op : Operator do
         Op.Window := Window;
      end return;
   end Create;

end Rx.Op.Debounce;
