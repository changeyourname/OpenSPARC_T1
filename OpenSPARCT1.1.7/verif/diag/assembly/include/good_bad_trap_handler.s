proc_good_trap:
	rd %asr26, %g1
	srl %g1, 0x8, %g1	! Shift & Mask
	and %g1, 0x3, %g1	! Thread ID
	or %g0, 0x1, %g3
	sll %g3, %g1, %g3	! ONe-hot Thread

	setx thread_status_mem, %g1, %g2
	stx %g3, [%g2]		! Zero in upper 32 bits indiates success

good_trap_end:
	rd %asr26, %g1
	wr %g1, 0x1, %asr26	!Halt
	nop
	b good_trap_end
	nop

.align 32

proc_bad_trap:
	rd %asr26, %g1
	srl %g1, 0x8, %g1	! Shift & Mask
	and %g1, 0x3, %g1	! Thread ID
	or %g0, 0x1, %g3
	sll %g3, %g1, %g3	! ONe-hot Thread

	or %g0, 0xf, %g4	! Fail Status
	sllx %g4, 0x20, %g4
	or %g3, %g4, %g4	! Fail status in top 32 bits, TID mask
	setx thread_status_mem, %g1, %g2
	stx %g4, [%g2]

bad_trap_end:
	rd %asr26, %g1
	wr %g1, 0x1, %asr26	!Halt
	nop
	b bad_trap_end
	nop

.align 32
