with Rx.Tools.Holders;
with Rx.Impl.Typed;

generic
   with package Typed is new Rx.Impl.Typed (<>);
package Rx.Impl.Links is

   pragma Preelaborate;

--  Types needed for:
--  1) Building the passive chains pre-subscription
--  2) The active copy of a chain post-subscription

   type Downstream is abstract tagged private;
   --  An entity able to have a stored parent observable

   procedure Set_Parent (This : in out Downstream; Parent : Typed.Contracts.Observable'Class);

   function Has_Parent (This : Downstream) return Boolean;

   function Get_Parent (This : Downstream) return Typed.Contracts.Observable'Class;

private

   package Holders is new Rx.Tools.Holders (Typed.Contracts.Observable'Class, "observable'class");
   type Holder is new Holders.Definite with null record;

   type Downstream is abstract tagged record
      Parent : Holder;
   end record;

   function Has_Parent (This : Downstream) return Boolean is (not This.Parent.Is_Empty);

   function Get_Parent (This : Downstream) return Typed.Contracts.Observable'Class is (This.Parent.Cref);

end Rx.Impl.Links;
