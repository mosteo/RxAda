with Rx.Debug;

package body Rx.Subscribe is

   ------------------
   -- On_Completed --
   ------------------

   overriding procedure On_Completed (This : in out Subscribe) is
      use Rx.Actions;
   begin
      if This.Completed then
         raise Program_Error with "Doubly completed";
      elsif
        This.Errored then
         raise Program_Error with "Completed after error";
      else
         This.Completed := True;
      end if;

      if This.Is_Subscribed then
         if This.Func_On_Completed /= null then
            This.Func_On_Completed.all;
         else
            Subscribe'Class (This).Do_On_Completed;
         end if;
      end if;
   end On_Completed;

   --------------
   -- On_Error --
   --------------

   overriding procedure On_Error (This : in out Subscribe; Error : in out Errors.Occurrence) is
      use Rx.Actions;
   begin
      if This.Errored then
         raise Program_Error with "Doubly errored";
      elsif This.Completed then
         raise Program_Error with "Errored after completed";
      else
         This.Errored := True;
      end if;

      if This.Is_Subscribed then
         if This.Func_On_Error /= null then
            This.Func_On_Error (Error);
         else
            Subscribe'Class (This).Do_On_Error (Error);
         end if;
         Error.Set_Handled;
      else
         Debug.Print (Error.Get_Exception.all);
         Error.Reraise;
      end if;
   end On_Error;

   -------------
   -- On_Next --
   -------------

   overriding procedure On_Next (This : in out Subscribe; V : Typed.Type_Traits.T) is
      use Typed.Actions;
   begin
      if This.Is_Subscribed then
         if This.Func_On_Next /= null then
            This.Func_On_Next (V);
         else
            Subscribe'Class (This).Do_On_Next (V);
         end if;
      else
         raise Subscriptions.No_Longer_Subscribed;
      end if;
   end On_Next;

   ------------
   -- Create --
   ------------

   function Create (On_Next      : Typed.Actions.Proc1   := null;
                    On_Completed : Rx.Actions.Proc0      := null;
                    On_Error     : Rx.Actions.Proc_Error := null) return Typed.Contracts.Sink'Class is
   begin
      return Subscribe'(Typed.Contracts.Sink with
                  On_Next,
                  On_Completed,
                  On_Error,
                  Subscription => Subscriptions.Subscribe,
                  Completed    => False,
                  Errored      => False);
   end Create;

end Rx.Subscribe;
