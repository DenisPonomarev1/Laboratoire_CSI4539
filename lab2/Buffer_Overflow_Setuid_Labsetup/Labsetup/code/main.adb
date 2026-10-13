--  main.adb
--
--  Minimal Ada rewrite of stack.c's bof()/main() (E7/T7).
--  Reads "badfile" (or a path given as argv[1]), copies it into a
--  constrained 100-byte buffer, and lets Ada's bounds check raise
--  Constraint_Error on oversized input instead of overflowing memory.

with Ada.Text_IO;
with Ada.Command_Line;
with Ada.Streams;
with Ada.Streams.Stream_IO;

procedure Main is
   use Ada.Text_IO;
   use Ada.Streams;

   Buf_Size : constant := 100;                 -- same as BUF_SIZE in stack.c
   subtype Buffer_String is String (1 .. Buf_Size);  -- the constrained subtype

   procedure Bof (Input : String) is           -- Ada version of bof(char *str)
      pragma Warnings (Off, "variable ""Buffer"" is not referenced");
      pragma Warnings (Off, "possibly useless assignment to ""Buffer""");
      Buffer : Buffer_String;
   begin
      --  Equivalent of strcpy(buffer, str), but bounds-checked: if
      --  Input'Length > Buf_Size, this slice is out of range and Ada
      --  raises Constraint_Error before anything is overwritten.
      Buffer (1 .. Input'Length) := Input;
      Put_Line ("  bof: copied" & Input'Length'Image &
                 " bytes into a" & Buf_Size'Image & "-byte buffer, no overflow.");
   end Bof;

   function Read_File (Path : String) return String is
      F : Ada.Streams.Stream_IO.File_Type;
   begin
      Ada.Streams.Stream_IO.Open (F, Ada.Streams.Stream_IO.In_File, Path);
      declare
         Len    : constant Ada.Streams.Stream_IO.Count :=
                    Ada.Streams.Stream_IO.Size (F);
         Data   : Stream_Element_Array (1 .. Stream_Element_Offset (Len));
         Last   : Stream_Element_Offset;
         Result : String (1 .. Natural (Len));
      begin
         Ada.Streams.Stream_IO.Read (F, Data, Last);
         Ada.Streams.Stream_IO.Close (F);
         for I in Data'Range loop
            Result (Natural (I)) := Character'Val (Data (I));
         end loop;
         return Result;
      end;
   end Read_File;

   Input_Path : constant String :=
     (if Ada.Command_Line.Argument_Count >= 1
      then Ada.Command_Line.Argument (1)
      else "badfile");

begin
   Put_Line ("Reading input from: " & Input_Path);
   declare
      Input : constant String := Read_File (Input_Path);
   begin
      Put_Line ("Input length:" & Input'Length'Image & " bytes "
                 & "(buffer size is" & Buf_Size'Image & " bytes)");
      Bof (Input);
      Put_Line ("Returned Properly.");
   exception
      when Constraint_Error =>
         Put_Line ("Constraint_Error caught: input is longer than the "
                    & Buf_Size'Image & "-byte buffer.");
         Put_Line ("Input rejected safely -- no memory was overwritten, "
                    & "no shell was spawned.");
   end;
exception
   when others =>
      Put_Line ("Could not read input file """ & Input_Path & """.");
end Main;