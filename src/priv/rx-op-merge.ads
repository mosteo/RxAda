with Rx.Impl.Preservers;
with Rx.Schedulers;

private with Rx.Op.Observe_On;

generic
   with package Preserver is new Rx.Impl.Preservers (<>);
package Rx.Op.Merge is

   function Create (Merge_With : Preserver.Observable'Class;
                    Observe_On : Schedulers.Scheduler := Schedulers.Immediate)
                    return Preserver.Operator'Class;
   --  Observe_On is used for the Merge_With observable only

   function Create (One, Two   : Preserver.Observable'Class;
                    Scheduler  : Schedulers.Scheduler := Schedulers.Immediate)
                    return Preserver.Observable'Class;

private

   use Preserver.Linkers;

   package RxObserve is new Rx.Op.Observe_On (Preserver);

   function Create (One, Two   : Preserver.Observable'Class;
                    Scheduler  : Schedulers.Scheduler := Schedulers.Immediate)
                    return Preserver.Observable'Class is
     (One
      & RxObserve.Create (Scheduler)
      & Create (Two, Scheduler));

end Rx.Op.Merge;
