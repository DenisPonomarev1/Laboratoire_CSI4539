set pagination off
set disassembly-flavor intel
break bof
run
next
printf "\n--- bof stack frame ---\n"
printf "buffer address: "
p/x &buffer
printf "frame pointer (saved EBP is at this address): "
p/x $ebp
printf "saved EBP and return address words: "
x/2wx $ebp
printf "return-address slot: "
p/x $ebp + 4
printf "distance from buffer start to return-address slot: "
p/d (int)((char *)($ebp + 4) - (char *)&buffer)
info frame
disassemble bof