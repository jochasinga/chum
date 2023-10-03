(module
  (type $t0 (func (param i32 i32) (result i32)))
  (type $t1 (func (param i32 i32) (result i32)))
  (func $sete (export "sete") (param $zf i32) (param $val i32) (result i32)
    ;; - arg0 | $zf is the zero flag
    ;; - arg1 | $val is the value to set

    ;; function to set the last byte of a 32 bit integer
    ;; if the first parameter (zero flag) is non-zero
    ;; and otherwise just return the second parameter.

    ;; get zero flag
    local.get $zf
    (if
      (then
        local.get $val
        i32.const 0xff ;; 255 for mask
        i32.or
        return
      )
    )
    local.get $val
  )
  (func $sall (export "sall") (param $val i32) (param $by i32) (result i32)
    ;; - arg0 | $val is the value to shift
    ;; - arg1 | $by is the shift-by number
    local.get $val
    local.get $by
    i32.shl
  )
)