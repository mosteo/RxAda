with Rx.Actions.Transform;
with Rx.Errors;
with Rx.Impl.Links;
with Rx.Subscriptions;
with Rx.Typed;

generic
   with package From is new Rx.Typed (<>);
   with package Into is new Rx.Typed (<>);
package Rx.Impl.Transformers with Preelaborate is

   --  Renamings for bug workarounds
   subtype From_Observable is From.Observable'Class;
   subtype Into_Observable is Into.Observable'Class;

   package Actions is new Rx.Actions.Transform (From.Contracts, Into.Contracts);

   --  Transformative operator scaffolding:
   package Links is new Rx.Impl.Links (From);

   type Operator is new
     Links.Downstream and
     Into.Contracts.Observable and
     From.Contracts.Observer and
     From.Contracts.subscriber
   with private;
   --  This is the fundamental type that bridges observables y observers doing something along the way
   --  Override the Observer/Subscriber inherited methods in new operators

   overriding procedure On_Next (This : in out Operator; V : From.T) is null;
--     with Pre'Class => This.Is_Subscribed or else raise No_Longer_Subscribed;

   overriding procedure On_Complete  (This : in out Operator);
--     with Pre'Class => This.Is_Subscribed or else raise No_Longer_Subscribed;
   --  By default calls downstream On_Complete 

   overriding procedure On_Error (This : in out Operator; Error : Errors.Occurrence);
--     with Pre'Class => This.Is_Subscribed or else raise No_Longer_Subscribed;
   --  By default calls downstream On_Error

   overriding function Is_Subscribed (This : Operator) return Boolean;

   overriding procedure Subscribe (This : in out Operator; Consumer : in out Into.Observer'Class);
--     with Post'Class => This.Is_Subscribed;
   --  Can be overriden to modify the actual consumer that will be stored.
   --  In that case, the parent implementation should be called

   --  Typically, there won't be a need to override these:

   overriding procedure Unsubscribe (This : in out Operator);
--     with Post'Class => not This.Is_Subscribed;

--     not overriding function Get_Observer (This : in out Operator) return Into.Holders.Observers.Reference;
   --     with Pre'Class => This.Is_Subscribed or else raise No_Longer_Subscribed;

   not overriding function Get_Observer (This : in out Operator) return access Into.Observer'Class
     with Post'Class => This.Is_Subscribed or else raise No_Longer_Subscribed;
   --  Workaround for two reference-related bugs: memory-leak and access error

   ---------------------
   --  Chain building --
   ---------------------

   function Will_Observe (Producer : From.Observable;
                          Consumer : Operator'Class)
                          return Into.Observable;
   --  This does the magic of preparing a passive chain, ready for actual subscription/observation

   function "&" (Producer : From.Observable;
                 Consumer : Operator'Class)
                 return Into.Observable renames Will_Observe;

private

   type Operator is new
     Links.Downstream and
     Into.Contracts.Observable and
     From.Contracts.Observer and
     From.Contracts.Subscriber
   with record
      Downstream : Into.Holders.Observer;
   end record;

   overriding function Is_Subscribed (This : Operator) return Boolean is (This.Downstream.Is_Valid);

--     not overriding function Get_Observer (This : in out Operator) return Into.Holders.Observers.Reference is
--       (if This.Is_Subscribed then
--           This.Downstream.Ref
--        else
--           raise No_Longer_Subscribed);

   not overriding function Get_Observer (This : in out Operator) return access Into.Observer'Class is
     (if This.Is_Subscribed then
         This.Downstream.Get_Access
      else
         raise No_Longer_Subscribed);

end Rx.Impl.Transformers;