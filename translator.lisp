(uiop:define-package #:ollama/translator
  (:use #:cl)
  (:export #:translate))
(in-package #:ollama/translator)

(defparameter *default-model* "llama3.2")

(defun translate (text &key (target-lang (alexandria:required-argument :target-lang))
                            (model *default-model*))
  (ollama/utils:slurp
   (ollama:generate
    (format nil
            "Please translate the following sentences into ~A
Then, please output only the translation results.
「~A」 "
            target-lang
            text)
    :model model)))
