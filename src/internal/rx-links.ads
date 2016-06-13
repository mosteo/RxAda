with Rx.Errors;
with Rx.Typed;

generic
   with package From is new Rx.Typed (<>);
   with package Into is new Rx.Typed (<>);
package Rx.Links is

--     pragma Preelaborate;

--  A type that knows how to build a chain and then how to trigger subscriptions.
--  Used as root for both Transformers and Mutators (the two kinds of Links)
--  Transformers change types, Mutators do not.

   type Link is abstract new
     From.Producers.Subscriptor and
     Into.Producers.Observable
   with private;

   function "&" (L : From.Observable;
                 R : Link'Class)
                 return Into.Observable;

   procedure Set_Child (This : in out Link; Child : Into.Observer);
   -- Can be used to override the default "&" behavior

   function Get_Child (This : in out Link) return Into.Consumers.Holders.Reference;
   -- Can be used within the Observer actions to pass the values along

   overriding
   procedure Subscribe (Producer : in out Link;
                        Consumer : in out Into.Observer);

   overriding
   procedure On_Completed (This : in out Link);
   --  By default calls downstream On_Completed

   overriding
   procedure On_Error (This : in out Link; Error : in out Errors.Occurrence);
   --  By default calls downstream On_Error

private

   type Link is abstract new
     From.Producers.Subscriptor and
     Into.Producers.Observable
       with record
      Child : Into.Consumers.Holder;
   end record;

end Rx.Links;
