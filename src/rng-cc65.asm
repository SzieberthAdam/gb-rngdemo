;* RNG-CC65

;* Derived from the 240p-test-mini ([240ptm]) source code with the following
;* LICENSE which also applies to this file:
;* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Pseudorandom number generator
;
; Copyright 2018 Damian Yerrick
;
; This software is provided 'as-is', without any express or implied
; warranty.  In no event will the authors be held liable for any damages
; arising from the use of this software.
;
; Permission is granted to anyone to use this software for any purpose,
; including commercial applications, and to alter it and redistribute it
; freely, subject to the following restrictions:
;
; 1. The origin of this software must not be misrepresented; you must not
;    claim that you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation would be
;    appreciated but is not required.
; 2. Altered source versions must be plainly marked as such, and must not be
;    misrepresented as being the original software.
; 3. This notice may not be removed or altered from any source distribution.
;* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

;* GB-RNG adaptation and comments Copyright (c) 2019 Szieberth Ádám


;* =============================================================================
;* ABSTRACT
;* =============================================================================

;* This LCG RNG is the port of the cc65 rand function to the Game Boy hardware
;* by Damian Yerrick. The cc65 is a famous linear congruential generator (LCG).

;* =============================================================================
;* INCLUDES
;* =============================================================================

INCLUDE "RNG.INC"


;* =============================================================================
;* INITIALIZATION
;* =============================================================================

SECTION "RNG", ROM0

;* For completeness I have kept the srand subroutine of the 240p-test-mini
;* source code despite there is no need for it by the GB-RNG. Without it, the
;* initialization could be done by just clearing RNGSEED+3 and RNGSEED+2.

rand_init::
    ld a, [RNGSEED+1]           ; 3|4   set random seed to BC for srand()
    ld b, a                     ; 1|1   ...
    ld a, [RNGSEED]             ; 3|4   ...
    ld c, a                     ; 1|1   ___

;* "Sets the random seed to BC.
;* C expects startup code to behave as if srand(1) was called.
;* AHL trashed" [240ptm]
srand::
    ld hl, RNGSEED+3            ; 3|3

;* Damian Yerrick commented the next three lines on gbdev:
;* "The part about zeroing the high bytes of the seed is just there to make it
;* conform to the C ABI used on LR35902, which has 16-bit int." [GBD.SEEDCL]

    xor a                       ; 1|1
    ld [hl-], a                 ; 1|2
    ld [hl-], a                 ; 1|2

    ld a, b                     ; 1|1
    ld [hl-], a                 ; 1|2
    ld [hl], c                  ; 1|2
    ret                         ; 1|4


;* =============================================================================
;* RANDOM NUMBER GENERATOR
;* =============================================================================

;* "Generates a pseudorandom 16-bit integer in BC
;* using the LCG formula from cc65 rand():
;* x[i + 1] = x[i] * 0x01010101 + 0x31415927
;* @return A=B=state bits 31-24 (which have the best entropy),
;* C=state bits 23-16, DEHL trashed" [240ptm]
rand::                          ; 36|47

;* Load the current value to BCDE

    ld hl, RNGSEED+3            ; 3|3
    ld a, [hl-]                 ; 1|2
    ld b, a                     ; 1|1
    ld a, [hl-]                 ; 1|2
    ld c, a                     ; 1|1
    ld a, [hl-]                 ; 1|2
    ld d, a                     ; 1|1
    ld a, [hl]                  ; 1|2
    ld e, a                     ; 1|1

;* Multiply by 0x01010101

    add a, d                    ; 1|1
    ld d, a                     ; 1|1
    adc a, c                    ; 1|1
    ld c, a                     ; 1|1
    adc a, b                    ; 1|1
    ld b, a                     ; 1|1

;* Add 0x31415927 and write back

    ld a, e                     ; 1|1
    add a, $27                  ; 2|2
    ld [hl+], a                 ; 1|2
    ld a, d                     ; 1|1
    adc a, $59                  ; 2|2
    ld [hl+], a                 ; 1|2
    ld a, c                     ; 1|1
    adc a, $41                  ; 2|2
    ld [hl+], a                 ; 1|2
    ld c, a                     ; 1|1
    ld a, b                     ; 1|1
    adc a, $31                  ; 2|2
    ld [hl], a                  ; 1|2
    ld b, a                     ; 1|1
    ret                         ; 1|4


;* Note that GB-RNG only takes the value from A.


;* =============================================================================
;* REMARKS
;* =============================================================================

;* This is a widely used LCG. Recommended to me by Eldred Habert (ISSOtm) on the
;* gbdev server.

;* =============================================================================
;* REFERENCES
;* =============================================================================

;* [240ptm]     Damian Yerrick: 240p-test-mini (SOFTWARE)
;*              https://github.com/pinobatch/240p-test-mini

;* [GBD.SEEDCL] Damian Yerrick about zeroing the high bytes @ gbdev
;*              https://discordapp.com/channels/303217943234215948/490065800225488916/530802237295820832
