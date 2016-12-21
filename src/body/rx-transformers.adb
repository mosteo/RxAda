with Rx.Debug;
with Rx.Subscriptions;

package body Rx.Transformers is

   ---------------
   -- Subscribe --
   ---------------

   overriding procedure Subscribe
     (Producer : in out Operator;
      Consumer : Into.Subscriber'Class)
   is
   begin
      if Producer.Has_Parent then
         declare
            Parent : From.Observable := Producer.Get_Parent; -- Our own copy
         begin
            Producer.Get_Operator.Subscribe (Consumer);
            Parent.Subscribe (Producer);
         end;
      else
         raise Constraint_Error with "Attempting subscription without producer observable";
      end if;
   end Subscribe;

   -------------
   -- On_Next --
   -------------

   overriding procedure On_Next (This : in out Operator; V : From.T) is
   begin
      if This.Actual.Is_Valid then
         This.Get_Operator.On_Next (V);
      else
         raise Subscriptions.No_Longer_Subscribed;
      end if;
   exception
      when Subscriptions.No_Longer_Subscribed =>
         Debug.Log ("Transform.On_Next: caught No_Longer_Subscribed", Debug.Note);
         This.Unsubscribe;
         raise;
   end On_Next;

   ------------------
   -- On_Completed --
   ------------------

   overriding procedure On_Completed (This : in out Operator) is
   begin
      if This.Actual.Is_Valid then
         begin
            This.Get_Operator.On_Completed;
            This.Unsubscribe;
         exception
            when others =>
               This.Unsubscribe;
               raise;
         end;
      else
         raise Subscriptions.No_Longer_Subscribed;
      end if;
   end On_Completed;

   --------------
   -- On_Error --
   --------------

   overriding procedure On_Error (This : in out Operator; Error : Errors.Occurrence) is
   begin
      if This.Actual.Is_Valid then
         begin
            This.Get_Operator.On_Error (Error);
            This.Unsubscribe;
         exception
            when others =>
               This.Unsubscribe;
               raise;
         end;
      else
         Error.Reraise;
      end if;
   end On_Error;

   -------------------
   -- Unsubscribe --
   -------------------

   overriding
   procedure Unsubscribe (This : in out Operator) is
   begin
      if This.Actual.Is_Valid then
         This.Get_Operator.Unsubscribe;
         This.Actual.Clear;
      end if;
   exception
      when Subscriptions.No_Longer_Subscribed =>
         Debug.Log ("Transform.Unsubscribe: caught No_Longer_Subscribed", Debug.Note);
         This.Actual.Clear;
      when others =>
         This.Actual.Clear;
         raise;
   end Unsubscribe;

   ------------------
   -- Will_Observe --
   ------------------

   function Will_Observe (Producer : From.Observable;
                          Consumer : Operator'Class)
                          return Into.Observable
   is
   begin
      return Actual : Operator'Class := Consumer do
         Actual.Set_Parent (Producer);
      end return;
   end Will_Observe;

end Rx.Transformers;
