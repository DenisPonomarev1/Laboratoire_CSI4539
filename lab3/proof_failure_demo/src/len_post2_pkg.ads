package Len_Post2_Pkg with SPARK_Mode => On is
   procedure Run (N : Natural; L : out Natural) with
     Pre => N < 100,
     Post => L = N + 1;
end Len_Post2_Pkg;
