with Rx.Typed;

generic
   with package Typed is new Rx.Typed (<>);
package Rx.Src.Start is

   function Create (Func : Typed.Actions.TFunc0'Class) return Typed.Observable;
   --  Will emit the result of Func.Get

end Rx.Src.Start;
