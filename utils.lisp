(uiop:define-package #:ollama/utils
  (:use #:cl)
  (:export #:hash
           #:to-json
           #:pretty-json
           #:read-byte-line
           #:bytes-to-string
           #:slurp))
(in-package #:ollama/utils)

(defun hash (&rest plist)
  (alexandria:plist-hash-table plist :test 'equal))

(defun to-json (object)
  (yason:with-output-to-string* ()
    (yason:encode object)))

(defun pretty-json (object)
  (yason:with-output-to-string* (:indent t)
    (yason:encode object)))

(defun read-byte-line (stream)
  (let ((acc '()))
    (loop :for byte := (read-byte stream nil)
          :do (cond ((null byte)
                     (return (values (nreverse acc) nil)))
                    ((= byte (char-code #\newline))
                     (return (values (nreverse acc) t)))
                    (t
                     (push byte acc))))))

(defun bytes-to-string (bytes)
  (babel:octets-to-string
   (make-array (length bytes)
               :initial-contents bytes
               :element-type '(unsigned-byte 8))))

(defun slurp (result)
  (string-trim '(#\newline #\space #\")
               (with-output-to-string (out)
                 (loop :for ht :in result
                       :do (write-string (gethash "response" ht) out)))))
