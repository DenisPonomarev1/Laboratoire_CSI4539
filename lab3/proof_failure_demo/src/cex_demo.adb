with Ada.Text_IO; use Ada.Text_IO;
with Validator_Failure;

procedure Cex_Demo is
   Input : constant String := "A";
   Accepted : Boolean;
   Copied_Length : Validator_Failure.Valid_Length;
   Output : Validator_Failure.Buffer_String;
begin
   Validator_Failure.Validate_And_Copy (Input, Accepted, Copied_Length, Output);

   Put_Line ("INPUT=""" & Input & """");
   Put_Line ("INPUT_LENGTH=" & Natural'Image (Input'Length));
   Put_Line ("ACCEPTED=" & Boolean'Image (Accepted));
   Put_Line ("COPIED_LENGTH=" & Natural'Image (Natural (Copied_Length)));
   Put_Line ("WRONG_SPEC_EXPECTED=" & Natural'Image (Input'Length + 1));
end Cex_Demo;
