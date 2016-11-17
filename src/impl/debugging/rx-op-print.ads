with Rx.Operate;

generic
   with package Operate is new Rx.Operate (<>);
package Rx.Op.Print is

   function Create (Func : Operate.Typed.Actions.Func1Str := null; With_Timestamp : Boolean := True)
                    return Operate.Operator'Class;
   --  If null, the current thread id will be printed

end Rx.Op.Print;
