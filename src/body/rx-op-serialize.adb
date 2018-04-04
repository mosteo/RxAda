with Rx.Errors;
with Rx.Tools.Semaphores;

package body Rx.Op.Serialize is

   subtype Critical_Section is Tools.Semaphores.Critical_Section;

   type Serializer is new Operate.Operator with record
      Mutex : aliased Tools.Semaphores.Shared;
   end record;

   overriding procedure Unsubscribe (This : in out Serializer);

   overriding procedure Subscribe (Producer : in out Serializer;
                                   Consumer : in out Operate.Into.Observer'Class);

   overriding procedure On_Next (This : in out Serializer; V : Operate.T);

   overriding procedure On_Complete  (This : in out Serializer);

   overriding procedure On_Error (This : in out Serializer; Error : Errors.Occurrence);

   overriding procedure On_Next (This : in out Serializer; V : Operate.T) is
      CS : Critical_Section (This.Mutex'Access) with Unreferenced;
   begin
      This.Get_Observer.On_Next (V);
   end On_Next;

   ------------------
   -- On_Complete  --
   ------------------

   overriding procedure On_Complete  (This : in out Serializer) is
      CS : Critical_Section (This.Mutex'Access) with Unreferenced;
   begin
      This.Get_Observer.On_Complete ;
   end On_Complete ;

   --------------
   -- On_Error --
   --------------

   overriding procedure On_Error (This : in out Serializer; Error :        Errors.Occurrence) is
      CS : Critical_Section (This.Mutex'Access) with Unreferenced;
   begin
      This.Get_Observer.On_Error (Error);
   end On_Error;

   -----------------
   -- Unsubscribe --
   -----------------

   overriding procedure Unsubscribe (This : in out Serializer) is
      CS : Critical_Section (This.Mutex'Access) with Unreferenced;
   begin
      Operate.Operator (This).Unsubscribe;
   end Unsubscribe;

   ---------------
   -- Subscribe --
   ---------------

   overriding procedure Subscribe (Producer : in out Serializer;
                                   Consumer : in out Operate.Into.Observer'Class)
   is
   begin
      Producer.Mutex := Tools.Semaphores.Create_Reentrant; -- New mutex for this chain
      Operate.Operator (Producer).Subscribe (Consumer);    -- Normal subscription
   end Subscribe;

   ------------
   -- Create --
   ------------

   function Create return Operate.Operator'Class is
   begin
      return Serializer'(Operate.Operator with others => <>);
   end Create;

end Rx.Op.Serialize;
