with Rx.Debug;
with Rx.Holders;
with Rx.Subscriptions;

package body Rx.Src.Create is

   package body With_State is

      type Source is new Typed.Contracts.Observable with record
         Initial : State;
      end record;

      ---------------
      -- Subscribe --
      ---------------

      overriding procedure Subscribe
        (Producer : in out Source;
         Consumer : in out Typed.Subscriber)
      is
      begin
         begin
            On_Subscribe (Producer.Initial, Consumer);
         exception
            when Subscriptions.No_Longer_Subscribed =>
               Debug.Log ("At Create.Subscribe: caught No_Longer_Subscribed", Debug.Note);
            when E : others =>
               if Autocompletes then -- Because the error was within On_Next somewhere
                  Typed.Default_Error_Handler (Consumer, E);
               else
                  raise; -- Otherwise either client properly treated or wrong client implementation
               end if;
         end;

         if Autocompletes and then Consumer.Is_Subscribed then
            Consumer.On_Completed;
         end if;
      exception
         when Subscriptions.No_Longer_Subscribed =>
            Debug.Log ("At Create.Subscribe: caught No_Longer_Subscribed", Debug.Note);
      end Subscribe;

      ------------
      -- Create --
      ------------

      function Create (Initial : State) return Typed.Observable is
      begin
         return Source'(Initial => Initial);
      end Create;

   end With_State;

   -------------------
   -- Parameterless --
   -------------------

   type Parameterless_Proc is access procedure (Observer : in out Typed.Subscriber);
   procedure On_Subscribe (Initial : Parameterless_Proc; Observer : in out Typed.Subscriber) is
   begin
      Initial (Observer);
   end On_Subscribe;

   package Create_Parameterless is new With_State (Parameterless_Proc, On_Subscribe, Autocompletes => False);

   function Parameterless (On_Subscribe : not null access procedure (Observer : in out Typed.Subscriber))
                           return Typed.Observable is
   begin
      return Create_Parameterless.Create (On_Subscribe);
   end Parameterless;

   ---------------------
   -- Tagged_Stateful --
   ---------------------

   package Obs_Holders is new Rx.Holders (Observable'Class);
   type Holder is new Obs_Holders.Definite with null record;

   procedure On_Subscribe (Initial : Holder; Observer : in out Typed.Subscriber) is
      Actual : Observable'Class := Initial.Get; -- Local RW copy
   begin
      Actual.On_Subscribe (Observer);
   exception
      when Subscriptions.No_Longer_Subscribed =>
         Debug.Log ("At Create.On_Subscribe: caught No_Longer_Subscribed", Debug.Note);
   end On_Subscribe;

   package Create_Tagged is new With_State (Holder, On_Subscribe, Autocompletes => False);

   function Tagged_Stateful (Producer : Observable'Class) return Typed.Observable is
   begin
      return Create_Tagged.Create (Hold (Producer));
   end Tagged_Stateful;

end Rx.Src.Create;
