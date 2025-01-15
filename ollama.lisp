(uiop:define-package #:ollama
  (:use #:cl
        #:ollama/utils)
  (:export #:generate
           #:chat))
(in-package #:ollama)

(defmethod print-object ((object hash-table) stream)
  (print-unreadable-object (object stream :type t)
    (prin1 (alexandria:hash-table-plist object) stream)))

(defun url (path)
  (quri:make-uri :defaults "http://localhost:11434"
                 :path path))

(defun generate (prompt &key (model (alexandria:required-argument :model))
                             options)
  (let ((response (babel:octets-to-string
                   (dex:post (url "/api/generate")
                             :headers '(("content-type" . "application/json"))
                             :content (to-json (hash "model" model
                                                     "prompt" prompt
                                                     "options" (apply #'hash options)))))))
    (with-input-from-string (input-stream response)
      (loop :for object := (handler-case (yason:parse input-stream)
                             (end-of-file () nil))
            :while object
            :collect object))))

(defun chat (&key (role nil role-p)
                  (content (alexandria:required-argument :content))
                  (model (alexandria:required-argument :model))
                  (callback (alexandria:required-argument :callback)))
  (let ((stream
          (dex:post (url "/api/chat")
                    :headers '(("content-type" . "application/json"))
                    :content (to-json (hash "model" model
                                            "messages" (list
                                                        (if role-p
                                                            (hash "role" role
                                                                  "content" content)
                                                            (hash "content" content)))))
                    :want-stream t)))
    (loop
      (multiple-value-bind (bytes continue)
          (read-byte-line stream)
        (when bytes
          (funcall callback (yason:parse (bytes-to-string bytes))))
        (unless continue
          (return))))))
