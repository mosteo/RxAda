with Rx.Observables;
with Rx.Op.Count;
with Rx.Impl.Transformers;

private with Rx.Op.Map;
private with Rx.Op.Scan;

generic
   --  These could well be trait packages, but using those the user only has to know about "observables" packages
   with package From is new Rx.Observables (<>); -- Naming chosen for same length
   with package Into is new Rx.Observables (<>);
package Rx.Operators is

-- This package seems unnecessary but by separating it from Transform we can too separate each operator
-- implementation classes in its own packages, just like with Typed/Observables hierarchy.

   package Typed is new Rx.Impl.Transformers (From.Typed, Into.Typed);
   package Typed_Lists is new Rx.Impl.Transformers (From.Typed_Lists, Into.Typed);

   subtype Operator Is Typed.Operator'Class;

   --------------
   -- Counters --
   --------------

   generic
      with function Succ (V : Into.T) return Into.T;
      Default_Initial_Count : Into.T;
   package Counters is
      package Pkg_Count is new Rx.Op.Count (Typed, Succ, Default_Initial_Count);
      function Count (First : Into.T) return Operator renames Pkg_Count.Count;
   end Counters;

   ------------
   -- Length --
   ------------

   generic
      with function Length (V : From.Typed_Lists.T) return Into.T;
   function Length return Typed_Lists.Operator'Class;

   ---------
   -- Map --
   ---------

   function Map (F : Typed.Actions.Func1) return Operator'Class;

   ----------
   -- Scan --
   ----------

   function Scan (F         : Typed.Actions.Func2;
                  Seed      : Into.T;
                  Emit_Seed : Boolean) return Operator'Class;

   ----------
   -- Size --
   ----------

   generic
      with function Size (V : From.T) return Into.T;
   function Size return Operator'Class;

   ---------
   -- "&" --
   ---------

   function "&" (L : From.Observable; R : Operator) return Into.Observable
                 renames Typed.Concatenate;

   function "&" (L : From.Observable; R : Typed.Actions.Func1) return Into.Observable;
   --  The Map operator alternative

   package Linkers is

      --  Analog to the one in Observables

      function "&" (L : From.Observable; R : Operator) return Into.Observable
                    renames Typed.Concatenate;

      function "&" (L : From.Observable; R : Typed.Actions.Func1) return Into.Observable
                    renames Operators."&";

   end Linkers;

private

   package RxMap is new Rx.Op.Map (Typed);
   function Map (F : Typed.Actions.Func1) return Operator renames RxMap.Create;
   function "&" (L : From.Observable; R : Typed.Actions.Func1) return Into.Observable renames RxMap."&";

   package RxScan is new Rx.Op.Scan (Typed);
   function Scan (F         : Typed.Actions.Func2;
                  Seed      : Into.T;
                  Emit_Seed : Boolean) return Operator renames RxScan.Create;

end Rx.Operators;
