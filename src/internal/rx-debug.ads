with Ada.Exceptions;
with Ada.Tags;

with Gnat.IO;

with Gnat.Debug_Pools;

package Rx.Debug is

--     pragma Preelaborate;

   type Levels is (Verbose, -- Highly chatty
                   Reduced, -- Out-of-usual
                   Warning, -- Shouldn't happen but not critical (?)
                   Erratum  -- Something is definitely not working as expected
                   );

   Level : constant Levels := Reduced;
   --  Minimum level a message has to have for it to be printed

   procedure Log (S : String; Level : Levels := Verbose); -- Prints S if above configured level

   procedure Print (E : Ada.Exceptions.Exception_Occurrence);

   procedure Put_Line (I : Integer);
   procedure Put_Line (S : String) renames Gnat.IO.Put_Line;

   function Image (T : Ada.Tags.Tag) return String renames Ada.Tags.Expanded_Name;

   --  Memory inspection
   Debug_Pool : Gnat.Debug_Pools.Debug_Pool;
   procedure Dump;

end Rx.Debug;
