package body Safe_Ops with SPARK_Mode => On is
   procedure Bounded_Copy (Input : in String; Output : out String) is
   begin
      Output := Input;
   end Bounded_Copy;
end Safe_Ops;
