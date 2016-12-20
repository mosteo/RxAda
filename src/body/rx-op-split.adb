package body Rx.Op.Split is

   type Operator is new Transform.Implementation.Operator with null record;

   overriding procedure On_Next (This  : in out Operator;
                                 V     :        Transform.From.T)
   is
      procedure For_Each (V : Transform.Into.T) is
      begin
         This.Get_Subscriber.On_Next (V);
      end For_Each;
   begin
      Iterate (V, For_Each'Access);
   end On_Next;

   ------------
   -- Create --
   ------------

   function Create return Transform.Operator'Class is
   begin
      return Transform.Create (Operator'(null record));
   end Create;

end Rx.Op.Split;
