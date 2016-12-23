with Rx.Preservers;

generic
   with package Operate is new Rx.Preservers (<>);
package Rx.Op.Last with Preelaborate is

   function Create (Check : Operate.Typed.Actions.TFilter1'Class := Operate.Typed.Actions.Always_Pass)
                    return Operate.Operator'Class;
   --  If no item is seen Constraint_Error will be raised when On_Completed

   function Or_Default (Default : Operate.T;
                        Check   : Operate.Typed.Actions.TFilter1'Class := Operate.Typed.Actions.Always_Pass)
                        return Operate.Operator'Class;

end Rx.Op.Last;
