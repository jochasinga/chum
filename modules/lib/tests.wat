(module
  (import "asm_x86" "sete" (func $sete (param i32 i32) (result i32)))
  (func $test_sete_eq (export "test_sete_eq") (result i32)
    i32.const 3
    i32.const 3
    ;; 3 == 3 so sete should return 0xff or 255
    i32.eq
    i32.const 99
    call $sete
  )
  (func $test_sete_ne (export "test_sete_ne") (result i32)
    i32.const 3
    i32.const 4
    ;; 3 != 4 so sete should return 99
    i32.eq
    i32.const 99
    call $sete
  )
  (func $test_sall (export "test_sall") (result i32)
    i32.const 4
    i32.const 8
    ;; 4 << 8 should be 1024
    i32.shl
  )
  (func $test_emit_is_equal_to (export "test_emit_is_equal_to") (result i32)
    ;; 3 == 3 so this should return 1
    i32.const 3
    i32.const 3
    i32.eq
    i32.const 0
    call $sete
    i32.const 8 ;; shift by one byte
    i32.shl
    i32.const 15 ;; bool-tag is 15
    i32.or
  )
)