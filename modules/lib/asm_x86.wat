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
  (func $cmpl (export "cmpl") (param $a i32) (param $b i32) (result i32)
    ;; - arg0 | $a is the first value
    ;; - arg1 | $b is the second value

    ;; compare two 32 bit signed integers.
    ;; return 1 if $a > $b
    ;; return 0 if $a == $b
    ;; return -1 if $a < $b
    (local $diff i32)
    local.get $a
    local.get $b
    i32.sub
    local.set $diff
    local.get $diff
    i32.eqz
    (if
      (then
        i32.const 0
        return
      )
      (else
        local.get $diff
        i32.const 0
        i32.gt_s
        (if
          (then
            i32.const 1
            return
          )
          (else
            i32.const -1
            return
          )
        )
      )
    )
    i32.const 0
  )
)