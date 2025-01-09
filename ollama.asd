(defsystem "ollama"
  :depends-on ("yason"
               "dexador"
               "babel")
  :serial t
  :components ((:file "utils")
               (:file "ollama")))

(defsystem "ollama/translator"
  :depends-on ("ollama")
  :serial t
  :components ((:file "translator")))
