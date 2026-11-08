with Ada.Command_Line;
with Ada.Exceptions;
with Ada.Streams;
with Ada.Streams.Stream_IO;
with Ada.Text_IO;
with Validator;

procedure Main is
   use Ada.Streams;

   function Read_File_As_String (Path : String) return String is
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
   end Read_File_As_String;

   Input_Path : constant String :=
     (if Ada.Command_Line.Argument_Count >= 1
      then Ada.Command_Line.Argument (1)
      else "badfile");

   Input         : constant String := Read_File_As_String (Input_Path);
   Accepted      : Boolean;
   Copied_Length : Validator.Valid_Length;
   Buffer        : Validator.Buffer_String;
begin
   Validator.Validate_And_Copy
     (Input         => Input,
      Accepted      => Accepted,
      Copied_Length => Copied_Length,
      Output        => Buffer);

   Ada.Text_IO.Put_Line ("INPUT_LENGTH=" & Integer'Image (Input'Length));
   Ada.Text_IO.Put_Line
     ("FITS_BUFFER=" & Boolean'Image (Validator.Fits_Buffer (Input)));
   Ada.Text_IO.Put_Line
     ("ALLOWED_CHARS=" & Boolean'Image (Validator.Is_Allowed_Input (Input)));
   Ada.Text_IO.Put_Line ("ACCEPTED=" & Boolean'Image (Accepted));
   Ada.Text_IO.Put_Line
     ("COPIED_LENGTH=" & Integer'Image (Integer (Copied_Length)));

   if Accepted then
      if Copied_Length > 0 then
         Ada.Text_IO.Put_Line ("BUFFER_PREFIX=" & Buffer (1 .. Copied_Length));
      else
         Ada.Text_IO.Put_Line ("BUFFER_PREFIX=<empty>");
      end if;
   else
      Ada.Text_IO.Put_Line ("BUFFER_PREFIX=<rejected>");
   end if;
exception
   when E : others =>
      Ada.Text_IO.Put_Line
        ("HARNESS_EXCEPTION=" & Ada.Exceptions.Exception_Name (E));
      Ada.Text_IO.Put_Line
        (Ada.Exceptions.Exception_Message (E));
end Main;
