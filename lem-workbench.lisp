(uiop:define-package #:ollama/lem-workbench
  (:use #:cl #:lem))
(in-package #:ollama/lem-workbench)

(define-attribute process-region-attribute
  (t :background "dim gray" :foreground "white"))

(defun call-with-process-region (start end loading-message process then)
  (buffer-mark-cancel (point-buffer start))
  (let ((overlay (make-overlay start end 'process-region-attribute))
        (spinner
          (lem/loading-spinner:start-loading-spinner 
           :line
           :loading-message loading-message
           :point end)))
    (with-point ((start start :right-inserting)
                 (end end :left-inserting))
      (let ((string (points-to-string start end)))
        (bt2:make-thread
         (lambda ()
           (let ((result (funcall process string)))
             (send-event (lambda ()
                           (lem/loading-spinner:stop-loading-spinner spinner)
                           (with-point ((start start :left-inserting)
                                        (end end :right-inserting))
                             (funcall then start end result)
                             (delete-overlay overlay)))))))))))

;;; translator
(defun translate-region (start end target-lang)
  (call-with-process-region 
   start
   end
   "Translation..."
   (lambda (string)
     (ollama/translator:translate
      string
      :target-lang target-lang))
   (lambda (start end result)
     (delete-between-points start end)
     (insert-string start result))))

(define-command ollama-translate-to-japanese (start end) (:region)
  (translate-region start end "japanese"))

(define-command ollama-translate-to-english (start end) (:region)
  (translate-region start end "english"))

;;; coding
(defparameter *default-coding-model* "deepkseek-coder-v2")

(defun make-prompt (code)
  (format nil "Could you please review the following code snippet and provide comments? Specifically, I'm interested in understanding:

1. The overall functionality and purpose of the code.
2. Any potential issues, such as bugs or inefficiencies.
3. Suggestions for improvements or best practices.

Here's the code:
```
~A
```" code))

(define-command ollama-code-review (start end) (:region)
  (call-with-process-region
   start
   end
   "Review..."
   (lambda (string)
     (ollama/utils:slurp
      (ollama:generate (make-prompt string) :model *default-coding-model*)))
   (lambda (start end result)
     (declare (ignore start end))
     (let ((buffer (make-buffer "*ollama*")))
       (erase-buffer buffer)
       (with-point ((point (buffer-point buffer) :left-inserting))
         (buffer-end point)
         (insert-string point result)
         (insert-character point #\newline))
       (pop-to-buffer buffer)))))
