with Ada.Exceptions;

with Rx.Errors;
with Rx.Impl.Any;
with Rx.Impl.Casts;
with Rx.Impl.Integers;
with Rx.Impl.Floats;
with Rx.Impl.Strings;
with Rx.Operators;
with Rx.Subscriptions;
with Rx.Schedulers;

private with Rx.Src.Empty;
private with Rx.Src.Interval;

package Rx.Std is

--  Instances and default visibility for the common predefined types:
--  Strings, Integers, StrToInt, IntToInt, IntToStr
--  Also default sources/operators from ReactiveX documentation

   --  Type shortcuts:

   subtype Subscription is Rx.Subscriptions.Subscription;

   --  Convenience instances

   package Any      renames Rx.Impl.Any.Instance.Observables;
   package Integers renames Rx.Impl.Integers.Observables;
   package Floats   renames Rx.Impl.Floats.Observables;
   package Strings  renames Rx.Impl.Strings.Observables;

   package AnyToFlt is new Rx.Operators (Any,      Floats);
   package IntToFlt is new Rx.Operators (Integers, Floats);
   package StrToFlt is new Rx.Operators (Strings,  Floats);

   package AnyToInt is new Rx.Operators (Any,     Integers);
   package FltToInt is new Rx.Operators (Floats,  Integers);
   package StrToInt is new Rx.Operators (Strings, Integers);

   package AnyToStr is new Rx.Operators (Any,      Strings);
   package FltToStr is new Rx.Operators (Floats,   Strings);
   package IntToStr is new Rx.Operators (Integers, Strings);

   package FltCount is new FltToInt.Counters (Integer'Succ, 0);
   package IntCount is new Integers.Counters (Integer'Succ, 0);
   package StrCount is new StrToInt.Counters (Integer'Succ, 0);

   function String_Succ (S : String) return String;
   -- Lexicographic enumeration over the Character type. Useless I guess.

   package IntEnums is new Integers.Enums (Integer'Succ);
   package StrEnums is new Strings.Enums  (String_Succ);

   --  Standard Rx sources and operators

   function Empty return Any.Observable;

   function Error (E : Rx.Errors.Occurrence)                return Any.Observable;
   function Error (E : Ada.Exceptions.Exception_Occurrence) return Any.Observable;

   function Interval (First       : Integer := 0;
                      Pause       : Duration := 1.0;
                      First_Pause : Duration := 1.0;
                      Scheduler   : Schedulers.Scheduler := Schedulers.Computation)
                      return Integers.Observable;

   function Never return Any.Observable;

   --  Casts for predefined types

   Float_To_Integer  : constant FltToInt.Operator := FltToInt.Map (Rx.Impl.Casts.To_Integer'Access);
   Float_To_String   : constant FltToStr.Operator := FltToStr.Map (Rx.Impl.Casts.To_String'Access);

   Integer_To_Float  : constant IntToFlt.Operator := IntToFlt.Map (Rx.Impl.Casts.To_Float'Access);
   Integer_To_String : constant IntToStr.Operator := IntToStr.Map (Rx.Impl.Casts.To_String'Access);

   String_To_Float   : constant StrToFlt.Operator := StrToFlt.Map (Rx.Impl.Casts.To_Float'Access);
   String_To_Integer : constant StrToInt.Operator := StrToInt.Map (Rx.Impl.Casts.To_Integer'Access);

private

   package RxEmpty is new Rx.Src.Empty (Any.Typedd);

   function Empty return Any.Observable renames RxEmpty.Empty;

   function Error (E : Rx.Errors.Occurrence)                return Any.Observable renames RxEmpty.Error;
   function Error (E : Ada.Exceptions.Exception_Occurrence) return Any.Observable renames RxEmpty.Error;

   package RxInterval is new Rx.Src.Interval (Integers.Typedd, Integer'Succ);

   function Interval (First       : Integer := 0;
                      Pause       : Duration := 1.0;
                      First_Pause : Duration := 1.0;
                      Scheduler   : Schedulers.Scheduler := Schedulers.Computation)
                      return Integers.Observable renames RxInterval.Create;

   function Never return Any.Observable renames RxEmpty.Never;

   function String_Succ (S : String) return String
   is (if    S'Length = 0                 then String'(1 => Character'First)
       elsif S (S'Last) /= Character'Last then S (S'First .. S'Last - 1) & Character'Succ (S (S'Last))
       else  S & Character'First);

end Rx.Std;
