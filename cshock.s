; Colorshock 2k16
; Big Boss Man of Demografica

		section text

		jsr initialise		;init routs from library

		move.l #screen,d0
        clr.b  d0
        move.l d0,a0
        lsr.w #8,d0
        move.l d0,$ffff8200

		movem.l	blackpal,d0-d7		;Set palette
		movem.l	d0-d7,$ffff8240.w	

		move.l	#backup,a0
		move.l	$70,(a0)+			;backup vector $70 (VBL)
		move.l	$120,(a0)+			;backup vector $120 (timer b)
        move.l  $134,(a0)+          ;backup vector $134 (timer a)
		move.b	$fffa07,(a0)+		;backup enable a
		move.b	$fffa13,(a0)+		;backup mask a
		move.b	$fffa15,(a0)+		;backup mask b
		move.b	$fffa1b,(a0)+		;backup timer b control
		move.b	$fffa31,(a0)+		;backup timer b data

		move.l #vbl,$70.w
		move.l #timerb,$120.w


.wait	tst.w 	vblcount
		beq.s   .wait
		cmp.b	#57,$FFFFFC02
		bne.s	.wait

		move.l	#backup,a0
		move.l	(a0)+,$70		;restore vector $70 (vbl)
		move.l	(a0)+,$120		;restore vector $120 (timer b)
        move.l  (a0)+,$134      ;restore vector $134 (timer a)
		move.b	(a0)+,$fffa07		;restore enable a
		move.b	(a0)+,$fffa13		;restore mask a
		move.b	(a0)+,$fffa15		;restore mask b
		move.b	(a0)+,$fffa1b		;restore timer b control
		move.b	(a0)+,$fffa21		;restore timer b data

		jsr restore

		clr.w -(sp)			;exit
		trap #1

vbl:
		movem.l	d0-d7/a0-a6,-(sp)

		addq.w	#1,vblcount
		clr.w	raster_ofs
		move.w #$000,$ffff8240

		move.w #$2700,sr ;Stop all interrupts


		clr.b $fffffa1b.w ;Timer B control (stop)
		bset #0,$fffffa07.w ;Interrupt enable A (Timer B)
		bset #0,$fffffa13.w ;Interrupt mask A (Timer B)
		move.b #2,$fffffa21.w ;Timer B data (number of scanlines to next interrupt)
		bclr #3,$fffffa17.w ;Automatic end of interrupt
		move.b #8,$fffffa1b.w ;Timer B control (event mode (HBL))
		bclr #5,$fffffa09.w 	;disable timer c

		movem.l	(sp)+,d0-d7/a0-a6
		move.b #02,$ff820a

		;move.w #$2300,sr 	;Interrupts back on


		rte


timerb:
		lea $ffff8240,A3 			;8
		lea	rasters,a4 				;12
		add.w	raster_ofs,a4 		;4
		rept 32
		move.w (a4)+,(a3)		;12
		endr
		addq.w #2,raster_ofs 		;8
	
		rte		

		include	initlib.s

	section data

blackpal:
		dcb.w	16,$0000			;Black palette

rasters:
        rept 2
		dc.w $0,$800,$100,$900,$200,$A00,$300,$B00,$400,$C00
  		dc.w $500,$D00,$600,$E00,$700,$F00,$F80,$F10,$F90,$F20
  		dc.w $FA0,$F30,$FB0,$F40,$FC0,$F50,$FD0,$F60,$FE0,$F70
		dc.w $FF0,$7F0,$EF0,$6F0,$DF0,$5F0,$CF0,$4F0,$BF0,$3F0
  		dc.w $AF0,$2F0,$9F0,$1F0,$8F0,$F0,$F8,$F1,$F9,$F2
  		dc.w $FA,$F3,$FB,$F4,$FC,$F5,$FD,$F6,$FE,$F7
  		dc.w $FF,$7F,$EF,$6F,$DF,$5F,$CF,$4F,$BF,$3F
  		dc.w $AF,$2F,$9F,$1F,$8F,$F,$80F,$10F,$90F,$20F
  		dc.w $A0F,$30F,$B0F,$40F,$C0F,$50F,$D0F,$60F,$E0F,$70F
  		dc.w $F0F,$F8F,$F1F,$F9F,$F2F,$FAF,$F3F,$FBF,$F4F,$FCF
  		dc.w $F5F,$FDF,$F6F,$FEF,$F7F,$FFF,$777,$EEE,$666,$DDD
  		dc.w $555,$CCC,$444,$BBB,$333,$A3A,$232,$939,$131,$138
  		dc.w $130,$830,$30,$38,$31,$39,$32,$3A,$33,$3B
  		dc.w $34,$3C,$35,$3D,$36,$3E,$37,$3F,$83F,$13F
  		dc.w $93F,$23F,$A3F,$33F,$B3F,$43F,$C3F,$53F,$D3F,$63F
  		dc.w $E3F,$73F,$F3F,$FA7,$F2E,$F96,$F9D,$F95,$F9C,$F94
  		dc.w $F9B,$F93,$F9A,$F92,$F99,$F91,$F98,$F90,$F20,$FA0
  		dc.w $F30,$FB0,$F40,$FC0,$F50,$FD0,$F60,$FE0,$F70,$FF0
  		dc.w $FF8,$FF1,$FF9,$FF2,$FFA,$FF3,$FFB,$FF4,$FFC,$FF5
  		dc.w $FFD,$FF6,$FFE,$FF7,$EEE,$555,$444,$333,$222,$111
        endr
		;
		;dc.w $0,$800,$100,$900,$200,$A00,$300,$B00,$400,$C00
  		;dc.w $500,$D00,$600,$E00,$700,$F00,$F80,$F10,$F90,$F20
  		;dc.w $FA0,$F30,$FB0,$F40,$FC0,$F50,$FD0,$F60,$FE0,$F70
		;dc.w $FF0,$7F0,$EF0,$6F0,$DF0,$5F0,$CF0,$4F0,$BF0,$3F0

  		even

	section bss
				ds.b	256
screen			ds.b	160*288
backup			ds.b	14
screen_adr		ds.l	1
raster_ofs:		ds.w	1
vblcount:		ds.w	1