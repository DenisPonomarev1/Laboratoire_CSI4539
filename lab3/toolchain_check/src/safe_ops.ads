package Safe_Ops with SPARK_Mode => On is
   procedure Bounded_Copy (Input : in String; Output : out String)
   with
     Pre  => Input'Length = Output'Length,
     Post => Output = Input;
end Safe_Ops;
