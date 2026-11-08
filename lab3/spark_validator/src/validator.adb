package body Validator with SPARK_Mode => On is

   function Fits_Buffer (Input : String) return Boolean is
   begin
      return Input'Length <= Max_Length;
   end Fits_Buffer;

   function Is_Allowed_Char (C : Character) return Boolean is
   begin
      return (C in 'a' .. 'z')
        or else (C in 'A' .. 'Z')
        or else (C in '0' .. '9')
        or else C = ' '
        or else C = '_'
        or else C = '-'
        or else C = '.'
        or else C = '/';
   end Is_Allowed_Char;

   function Is_Allowed_Input (Input : String) return Boolean is
   begin
      for I in Input'Range loop
         if Input (I) not in Policy_Char then
            return False;
         end if;
      end loop;
      return True;
   end Is_Allowed_Input;

   procedure Copy_Validated
     (Input         : in String;
      Copied_Length : out Valid_Length;
      Output        : out Buffer_String)
   with
     Pre => Fits_Buffer (Input) and then Is_Allowed_Input (Input),
     Post => Copied_Length = Input'Length
   is
   begin
      Output := (others => ' ');
      Copied_Length := Input'Length;
      if Input'Length > 0 then
         Output (1 .. Input'Length) := Input;
      end if;
   end Copy_Validated;

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

      if not Is_Allowed_Input (Input) then
         return;
      end if;

      Accepted := True;
      Copy_Validated (Input, Copied_Length, Output);
   end Validate_And_Copy;

end Validator;
