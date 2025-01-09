(uiop:define-package #:ollama/translator
  (:use #:cl)
  (:export #:translate
           #:translate-to-english
           #:translate-to-japanese))
(in-package #:ollama/translator)

(defun translate (text &key (target-lang (alexandria:required-argument :target-lang)))
  (ollama/utils:slurp
   (ollama:generate
    (format nil
            "Please translate the following sentences into ~A
Then, please output only the translation results.
「~A」 "
            target-lang
            text)
    :model "phi4")))

(defun translate-to-english (text)
  (translate text :target-lang "english"))

(defun translate-to-japanese (text)
  (translate text :target-lang "japanese"))
