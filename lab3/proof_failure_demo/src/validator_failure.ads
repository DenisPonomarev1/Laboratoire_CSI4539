package Validator_Failure with SPARK_Mode => On is
   Max_Length : constant Positive := 100;
   subtype Buffer_Index is Positive range 1 .. Max_Length;
   subtype Buffer_String is String (Buffer_Index);
   subtype Valid_Length is Natural range 0 .. Max_Length;

   function Fits_Buffer (Input : String) return Boolean
   with
     Post => Fits_Buffer'Result = (Input'Length <= Max_Length);

   procedure Validate_And_Copy
     (Input         : in String;
      Accepted      : out Boolean;
      Copied_Length : out Valid_Length;
      Output        : out Buffer_String)
   with
     Global => null,
     Depends =>
       (Accepted      => Input,
        Copied_Length => Input,
        Output        => Input),
     Post =>
       (if Accepted then
           Copied_Length = Input'Length + 1
        else
           Copied_Length = 0);
end Validator_Failure;
