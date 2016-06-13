private with Ada.Finalization;
-- with Ada.Containers.Indefinite_Holders;
-- with Ada.Containers.Indefinite_Doubly_Linked_Lists;
--  This is a workaround for a memory leak in the Indefinite_Holders (as of GPL2016)
--  It turns out Lists are broken too in instantiation from rx-from.adb
--  Rolling out my own holders (probably buggy too, or inneficient, or whatever...)

with Gnat.Debug_Pools;

generic
   type Indef (<>) is private;
package Rx.Holders is

--     pragma Preelaborate;

   type Definite is tagged private;

   type Reference (Actual : access Indef) is private
   	with Implicit_Dereference => Actual;
   type Const_Ref (Actual : access constant Indef) is private
   	with Implicit_Dereference => Actual;

   function "+" (I : Indef)    return Definite with Inline;
   function "+" (D : Definite) return Indef    with Inline;

   function Hold (I : Indef) return Definite renames "+";

   function Ref  (I : aliased in out Definite) return Reference with Inline;
   function CRef (I :                Definite) return Const_Ref with Inline;

private

   use Ada.Finalization;

   type Indef_Access is access Indef;

   type Definite is new Ada.Finalization.Controlled with record
      Actual : Indef_Access;
   end record;

   overriding procedure Adjust   (D : in out Definite);
   overriding procedure Finalize (D : in out Definite);

   type Reference (Actual : access Indef) is null record;
   type Const_Ref (Actual : access constant Indef) is null record;

   function "+" (I : Indef)    return Definite is (Controlled with Actual => new Indef'(I));
   function "+" (D : Definite) return Indef    is (D.Actual.all);

   function Ref  (I : aliased in out Definite) return Reference is (Actual => I.Actual);
   function CRef (I :                Definite) return Const_Ref is (Actual => I.Actual);

end Rx.Holders;
