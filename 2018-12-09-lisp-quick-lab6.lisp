; Matthew Shu
; Quick Lab 6

(defun ReadOneOld ()
  (let ((in (open "/Users/Matthew/Google Drive/Montgomery Blair High School/AI/One.txt")))
    (let ((count 0))
    (when in
    (loop for val = (read-line in nil)
      for y from 1
      while val
      collect val into OneAll))
      
    (close in))))

(defun ReadOne ()
  (with-open-file (stream "/Users/Matthew/Google Drive/Montgomery Blair High School/AI/One.txt")
    (loop for val = (read-line stream nil)
      for y from 1
      while val
      if (= y 1)
      collect val into aStop
      else 
      if (= y 2)
      collect val into bStop
      else
      if (< y (+ 3 (parse-integer (car aStop))))
      collect val into OneA
      else
      collect val into OneB
      finally
      (print aStop)
      (print OneA)
      (print OneB)))
  )

(defun ReadTwo ()
  (with-open-file (stream "/Users/Matthew/Google Drive/Montgomery Blair High School/AI/Two.txt")
    (loop for val = (read-line stream nil)
      while val
      collect val into TwoAll
      finally
      (print TwoAll)))
  )
