package body Validator_Failure with SPARK_Mode => On is

   function Fits_Buffer (Input : String) return Boolean is
   begin
      return Input'Length <= Max_Length;
   end Fits_Buffer;

   procedure Validate_And_Copy
     (Input         : in String;
      Accepted      : out Boolean;
      Copied_Length : out Valid_Length;
      Output        : out Buffer_String)
   is
   begin
      Output := (others => ' ');
      Accepted := False;
      Copied_Length := 0;

      if not Fits_Buffer (Input) then
         return;
      end if;

      Accepted := True;
      Copied_Length := Input'Length;

      if Input'Length > 0 then
         Output (1 .. Input'Length) := Input;
      end if;
   end Validate_And_Copy;

end Validator_Failure;
