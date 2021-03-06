;* RNG-RAM
;* Copyright (c) 2019 Szieberth Ádám
;* 0BSD License (see LICENSE file for more info)


;* =============================================================================
;* ABSTRACT
;* =============================================================================

;* This file contains no random number generator. It simply echoes and thus
;* retains the the bytes of the result area, the initial bytes of the RAM.


;* =============================================================================
;* INCLUDES
;* =============================================================================

INCLUDE "GBRNG.INC"
INCLUDE "RNG.INC"


;* =============================================================================
;* INITIALIZATION
;* =============================================================================

SECTION "RNG", ROM0

rand_init::
    ld hl, $C000                ; 3|3
    ret                         ; 1|4

;* =============================================================================
;* RANDOM NUMBER GENERATOR
;* =============================================================================

;* As stated above, this is not a random number generator. The title serves as a
;* sample.

rand::
    ld a, h                     ; 1|1
    cp a, $E0                   ; 2|2
    jr nc, .yield_null          ; 2|2/3 NC: $E000_Hi <= H
    jr nz, .yield_bc            ; 2|2/3
    ld a, l                     ; 1|1
    and a, a                    ; 1|1   ≡ cp a, 0
    jr nc, .yield_null          ; 2|2/3 NC: $E000 <= HL
.yield_bc
    ld a, [hl+]                 ; 1|2
    ret                         ; 1|4
.yield_null
    xor a, a                    ; 1|1
    ret                         ; 1|4
