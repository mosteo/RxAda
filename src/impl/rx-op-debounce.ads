with Rx.Preservers;

generic
   with package Operate is new Rx.Preservers (<>);
package Rx.Op.Debounce is

   function Create (Window : Duration) return Operate.Operator'Class;

end Rx.Op.Debounce;
