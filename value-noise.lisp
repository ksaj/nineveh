(in-package :nineveh.hashing)

(defun-g value-2d ((p :vec2))
  (let* ((pi (floor p))
         (pf (- p pi))
         (hash (fast32-hash-2d pi))
         (blend (interpolation-c2 pf))
         (blend2 (v! blend (- (v2! 1.0) blend))))
    (dot hash (* (s~ blend2 :zxzx) (s~ blend2 :wwyy)))))

(defun-g value-3d ((p :vec3))
  (let* ((pi (floor p))
         (pf (- p pi)))
    (multiple-value-bind (hash-lowz hash-highz) (fast32-hash-3d pi)
      (let* ((blend (interpolation-c2 pf))
             (res0 (mix hash-lowz hash-highz (z blend)))
             (blend2 (v! (s~ blend :xy) (- (v2! 1.0) (s~ blend :xy)))))
        (dot res0 (* (s~ blend2 :zxzx) (s~ blend2 :wwyy)))))))

(defun-g value-4d ((p :vec4))
  (let* ((pi (floor p))
         (pf (- p pi)))
    (multiple-value-bind (z0w0-hash z1w0-hash z0w1-hash z1w1-hash)
        (fast32-2-hash-4d-4 pi)
      (let* ((blend (interpolation-c2 pf))
             (res0 (+ z0w0-hash (* (- z0w1-hash z0w0-hash) (s~ blend :wwww))))
             (res1 (+ z1w0-hash (* (- z1w1-hash z1w0-hash) (s~ blend :wwww)))))
        (setf res0 (+ res0 (* (- res1 res0) (s~ blend :zzzz))))
        (setf (s~ blend :zw) (- (v2! 1.0) (s~ blend :xy)))
        (dot res0 (* (s~ blend :zxzx) (s~ blend :wwyy)))))))