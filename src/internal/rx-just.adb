package body Rx.Just is

   function Create (V : Typed.Type_Traits.T) return Typed.Producers.Observable'Class is
   begin
      return Observable'(Typed.Producers.Observable with Value => Typed.Type_Traits.To_Definite (V));
   end Create;

   overriding
   procedure Subscribe (Producer : in out Observable;
                        Consumer : in out Typed.Consumers.Observer'Class) is
   begin
      Consumer.On_Next (Typed.Type_Traits.To_Indefinite (Producer.Value));
      Consumer.On_Completed;
   end Subscribe;

end Rx.Just;
