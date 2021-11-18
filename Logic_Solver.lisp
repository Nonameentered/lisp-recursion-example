; Matthew Shu
; Logic Solver

(defun main ()
  (setf countEmpty nil)
  (let ((stream (open "/Users/Matthew/Downloads/logicpuzzles/puzzle2.txt" :if-does-not-exist :error)))
    (when stream

      (setq *firstTitle* (read stream nil))
      (setq *firstSection* nil)
      (setq *otherTitles* nil)

      ;gets the list of each Person/Category
      (do ((nextLine (read stream nil) (read stream nil)))
            ((equalp nextLine '-) *firstSection*)
          (setq *firstSection* (cons nextLine *firstSection*))
        )
      (setq *firstSection* (reverse *firstSection*))

      ;creates the properties and their list of possibilities
      ;associates each of them to each Person/categories
      (do ((nextSect (read stream nil) (read stream nil)))
          ((equalp nextSect 'beginClues) nil)
        (setf possList nil)
        (do ((nextLine (read stream nil) (read stream nil)))
            ((equalp nextLine '-))
          (setf possList (cons nextLine possList)))
        (dotimes (count (list-length *firstSection*))
          (setf (get (nth count *firstSection*) nextSect) possList)
          (setf (get 'unmodifiedRow nextSect) possList)
          )
        (setf *otherTitles* (cons nextSect *otherTitles*))
        )
      (setf *otherTitles* (reverse *otherTitles*))

      (setq *fullSectionTitles* (cons *firstTitle* *otherTitles*))

      ;creates associations between sections not related to main section (e.g lucky-charms <-> position instead of player <-> something)
      (setf secsNotFirstLast *otherTitles*)
      (setf workingList secsNotFirstLast)
      (dolist (eachTitle secsNotFirstLast)
        (setf workingList (cdr workingList))
        (dolist (eachAttributeInSection (get (nth 0 *firstSection*) eachTitle))
          (dolist (remainingSect workingList)
            (setf (get eachAttributeInSection remainingSect) (get (nth 0 *firstSection*) remainingSect))
            )
          )
        )

      ;read in clues
      (setq *clueList* nil)
      (do ((nextClueSect (read stream nil) (read stream nil)))
          ((equalp nextClueSect 'endClues))
        (setf clue (cons nextClueSect nil))
        (do ((nextLine (read stream nil) (read stream nil)))
            ((equalp nextLine '-))
          (setf clue (cons nextLine clue)))
        (setf clue (reverse clue))
        (setf *clueList* (cons clue *clueList*))
        )
      
      (dolist (clue *clueList*)
        (cond
         ((and (equalp *firstTitle* (nth 0 clue)) (equalp '= (nth 2 clue))) (firstEquals clue))
         ((and (equalp *firstTitle* (nth 0 clue)) (equalp '! (nth 2 clue))) (firstNotEqual clue))
         ((equalp '= (nth 2 clue)) (notFirstEquals clue))
         ((equalp '! (nth 2 clue)) (notFirstNotEqual clue))
         (t nil)
         )
        (loneOption)
        (checkCrossTableLoneOptions)
      )
      (finalCheck)
      (output)
)))

(defun interpretClues ()
  (do ((isDone (checkDone) (checkDone)))
      ((equalp isDone t) (outputFinished))
    (dolist (clue *clueList*)
      (cond
       ((and (equalp *firstTitle* (nth 0 clue)) (equalp '= (nth 2 clue))) (firstEquals clue))
       ((and (equalp *firstTitle* (nth 0 clue)) (equalp '! (nth 2 clue))) (firstNotEqual clue))
       ((equalp '= (nth 2 clue)) (notFirstEquals clue))
       ((equalp '! (nth 2 clue)) (notFirstNotEqual clue))
       (t (print 'chicken))
       )
      (loneOption)
      (checkCrossTableLoneOptions)
      )
    )
)

(defun checkDone ()
  t
)

(defun output ()
  (dolist (row *firstSection*)
    (print row)
    (dolist (subCat *otherTitles*)
      (format t "~%  - ~a" subCat)
      (format t ": ~a" (get row subCat))
      )
    )
)

(defun finalCheck ()
  (dolist (eachPerson *firstSection*)
    (setf workingOtherTitles *otherTitles*)
    (dolist (eachTitle (reverse (cdr (reverse *otherTitles*))))
     (setf workingOtherTitles (cdr *otherTitles*))
      (cond
       ((atom (get eachPerson eachTitle))
        (dolist (eachTitle2 workingOtherTitles)
        (cond ((atom (get (get eachPerson eachTitle) eachTitle2)
          ) (setf (get eachPerson eachTitle2) (get (get eachPerson eachTitle) eachTitle2))
              ))
       )
      )
    )))
 )

(defun loneOption ()
  (setf hasOccurred nil)
  (dolist (row *firstSection*)
    (dolist (subCat *otherTitles*)
      (setf possibilities (get row subCat))
      (cond
       ((atom possibilities) nil)
       (t (setf hasOccurred (append possibilities hasOccurred)))
      )
    )
    )
  (setf hasOccurred (remove-the-duplicates (remove-first-occurrence hasOccurred)))
  
  (dolist (row *firstSection*)
    (dolist (subCat *otherTitles*)
      (setf possibilities (get row subCat))
      (cond
       ((atom possibilities) nil)
       (t
         (dolist (eachPossibility possibilities)
          (cond
           ((not (member eachPossibility hasOccurred))
            (firstEquals (list *firstTitle* subCat '= row eachPossibility))
            )
           (t nil)
           )
          )
        )
      )
    )
    )
)

(defun checkCrossTableLoneOptions ()
  (dolist (eachCrossSectionTitle (reverse (cdr (reverse *otherTitles*))))
    (setf hasOccurred nil)
    (setf known nil)
    (setf attributeList (get 'unmodifiedRow eachCrossSectionTitle))
    (dolist (attribute attributeList)
      (dolist (subCat (subseq *fullSectionTitles* (+ (position eachCrossSectionTitle *fullSectionTitles*) 1)))
        (setf possibilities (get attribute subCat))
        (cond
         ((atom possibilities) (setf known (cons possibilities known)))
         (t (setf hasOccurred (append possibilities hasOccurred))
          )
         )
        )
      )
    
    (dolist (eachKnown known)
      (setf hasOccurred (remove eachKnown hasOccurred))
      )

    (setf hasOccurred (remove-the-duplicates (remove-first-occurrence hasOccurred)))
    
    ;(print hasOccurred)
    (dolist (attribute attributeList)
      (dolist (subCat (subseq *fullSectionTitles* (+ (position eachCrossSectionTitle *fullSectionTitles*) 1)))
        (setf possibilities (get attribute subCat))
        
        (cond
         ((atom possibilities) nil)
         (t
          (dolist (eachKnown known)
      (setf possibilities (remove eachKnown possibilities))
      )
          (dolist (eachPossibility possibilities)
            (cond
             ((not (member eachPossibility hasOccurred))
              (notFirstEquals (list eachCrossSectionTitle subCat '= attribute eachPossibility))
              (checkCrossTableLoneOptions)
              )
             (t nil)
             )
            )
          )
         )
        )
      )
    )
)

(defun notFirstEquals (clue)
  (setf firstCat (nth 0 clue))
  (setf secondCat (nth 1 clue))
  (setf firstAttribute (nth 3 clue))
  (setf secondAttribute (nth 4 clue))
  (setf possOne (get firstAttribute secondCat))
  (setf possTwo (get secondAttribute firstCat))

  (cond
   (possOne
    (setf (get firstAttribute secondCat) secondAttribute)
    (setf count 0)
    (setf newClue clue)
    (cond ((listp (get 'unmodifiedRow firstCat))
    (dolist (eachAttribute (get 'unmodifiedRow firstCat))
      (cond
       ((equalp eachAttribute (nth 3 clue)) nil)
       ((atom (get (nth count (get 'unmodifiedRow firstCat)) secondCat)) nil)
       ((null (cdr (remove secondAttribute (get (nth count (get 'unmodifiedRow firstCat)) secondCat))))
        (setf (nth 4 newClue) (car (remove secondAttribute (get (nth count (get 'unmodifiedRow firstCat)) secondCat))))
        (setf (nth 3 newClue) eachAttribute)
        (notFirstEquals newClue))
       (t
        (setf (get (nth count (get 'unmodifiedRow firstCat)) secondCat) (remove secondAttribute (get (nth count (get 'unmodifiedRow firstCat)) secondCat)))
        ))
      )
      (setf count (+ count 1))
      (checkOtherSections (nth 0 clue) (nth 3 clue))
      )
    ))
   (possTwo
    (setf (get secondAttribute firstCat) firstAttribute)
    (setf count 0)
    (setf newClue clue)

    (cond ((listp (get 'unmodifiedRow secondCat))
    (dolist (eachAttribute (get 'unmodifiedRow secondCat))
      (cond
       ((equalp eachAttribute (nth 3 clue)) nil)
       ((atom (get (nth count (get 'unmodifiedRow secondCat)) firstCat)) nil)
       ((null (cdr (remove firstAttribute (get (nth count (get 'unmodifiedRow secondCat)) firstCat))))
        (setf (nth 4 newClue) (car (remove firstAttribute (get (nth count (get 'unmodifiedRow secondCat)) firstCat))))
        (setf (nth 3 newClue) eachAttribute)
        (notFirstEquals newClue))
       (t
        (setf (get (nth count (get 'unmodifiedRow secondCat)) firstCat) (remove firstAttribute (get (nth count (get 'unmodifiedRow secondCat)) firstCat)))
        ))
      )
      (setf count (+ count 1)))
      (checkOtherSections (nth 0 clue) (nth 3 clue))
      )
    )
   (t 'thatsNotGood)
   )
)

(defun firstEquals (clue)
  (setf catNum (position (nth 3 clue) *firstSection*))
  (setf newClue clue)
  (setf (get (nth catNum *firstSection*) (nth 1 clue)) (nth 4 clue))
  (setf count 0)
  (dolist (row *firstSection*)
    (cond
     ((equalp row (nth 3 clue)) nil)
     ((atom (get (nth count *firstSection*) (nth 1 clue))) nil)
     ((null (cdr (remove (nth 4 clue) (get (nth count *firstSection*) (nth 1 clue)))))
      ;(setf (get (nth count *firstSection*) (nth 1 clue)) (car (remove (nth 4 clue) (get (nth count *firstSection*) (nth 1 clue)))))
      (setf (nth 4 newClue) (car (remove (nth 4 clue) (get (nth count *firstSection*) (nth 1 clue)))))
      (setf (nth 3 newClue) row)
      ;(print newClue)
      (firstEquals newClue) (loneOption))
     
     (t
      (setf (get (nth count *firstSection*) (nth 1 clue)) (remove (nth 4 clue) (get (nth count *firstSection*) (nth 1 clue))))
      ))
    (setf count (+ count 1))
    )
  (checkOtherSectionsFromFirst (nth 3 clue))
)

(defun checkOtherSectionsFromFirst (attribute)
  (setf known nil)
  (setf knownCats nil)
  (dolist (subCat *otherTitles*)
    (setf possibilities (get attribute subCat))
    (cond
     ((atom possibilities) (setf known (cons possibilities known)) (setf knownCats (cons subCat knownCats)))
     )
    )

  (setf workingCopyKnown known)
  (setf workingCopyKnownCats knownCats)
  (dolist (eachAttribute known)
    (setf workingCopyKnown (cdr workingCopyKnown))
    (setf currentCat (car workingCopyKnownCats))
    (setf workingCopyKnownCats (cdr workingCopyKnownCats))
    (setf count 0)
    (dolist (eachSecondAttribute workingCopyKnown)
      (setf newClue (list currentCat (nth count workingCopyKnownCats) '= eachAttribute eachSecondAttribute))
      (notFirstEquals newClue)
      (setf count (+ count 1))
      )
    )
)

(defun checkOtherSections (section attribute)
  
  (setf known nil)
  (setf knownCats nil)
  (setf players nil)
  (dolist (subCat (remove section *otherTitles*))
    (setf possibilities (get attribute subCat))
    (cond
     ((atom possibilities) (dolist (eachAttribute *firstSection*)
                             (cond ((equalp (get eachAttribute subCat) possibilities) (setf players (cons eachAttribute players))
                                    (setf known (cons possibilities known))
                                    (setf knownCats (cons subCat knownCats)))))
      )
     )
    )
  (setf workingCopyKnown known)
  (setf workingCopyKnownCats knownCats)
  (dolist (eachAttribute known)

    (setf newClue (list *firstTitle* section '= (car players) attribute))
    (firstEquals newClue)
    (setf workingCopyKnown (cdr workingCopyKnown))
    (setf workingCopyKnownCats (cdr workingCopyKnownCats))
    (setf players (cdr players))
    )
)

(defun notFirstNotEqual (clue)
  (setf firstCat (nth 0 clue))
  (setf secondCat (nth 1 clue))
  (setf firstAttribute (nth 3 clue))
  (setf secondAttribute (nth 4 clue))
  (setf possOne (get firstAttribute secondCat))
  (setf possTwo (get secondAttribute firstCat))
  
  
  
  (cond
   (possOne
    (setf currentPossibilities (get firstAttribute secondCat))
    (cond
     ((null (cdr (remove secondAttribute currentPossibilities))) (setf (get firstAttribute secondCat) (car (remove secondAttribute currentPossibilities)))
      (setf (nth 2 clue) '=)
      (setf (nth 4 clue) (car (remove secondAttribute currentPossibilities)))
      (notFirstEquals clue)
      )
     (t (setf (get firstAttribute secondCat) (remove secondAttribute currentPossibilities)))
     )
    )
   (possTwo
    (setf currentPossibilities (get secondAttribute firstCat))
    (cond
     ((null (cdr (remove firstAttribute currentPossibilities))) (setf (get secondAttribute firstCat) (car (remove firstAttribute currentPossibilities)))
      (setf (nth 2 clue) '=)
      (setf (nth 4 clue) (car (remove firstAttribute currentPossibilities)))
      (notFirstEquals clue)
      )
     (t (setf (get secondAttribute firstCat) (remove firstAttribute currentPossibilities)))
     )
    )
   (t 'thatsNotGood)
   )
)

(defun firstNotEqual (clue)
  (setf catNum (position (nth 3 clue) *firstSection*))
  (setf currentPossibilities (get (nth catNum *firstSection*) (nth 1 clue)))
  ;(setf newPossibilities (remove (nth 4 clue) currentPossibilities))
  ;(print clue)
  ;(print newPossibilities)
  (cond 
   ((null (cdr (remove (nth 4 clue) currentPossibilities))) (setf (get (nth catNum *firstSection*) (nth 1 clue)) (car (remove (nth 4 clue) currentPossibilities)))
    (setf (nth 2 clue) '=)
    (setf (nth 4 clue) (car (remove (nth 4 clue) currentPossibilities)))
    (firstEquals clue)
    )
   (t (setf (get (nth catNum *firstSection*) (nth 1 clue)) (remove (nth 4 clue) currentPossibilities))))
)

(defun remove-first-occurrence (l)
  (setq nl ())
  (setq finalList ())
  (dolist
      (d l finalList)
    (cond
     ((null (member d nl)) (setq nl (cons d nl)))
     (t (setq finalList (cons d finalList)))
     ))
)

(defun remove-the-duplicates (l)
  (setq nl ())
  (dolist
      (d l nl)
    (cond
     ((null (member d nl)) (setq nl (cons d nl)))
     (t nil)
     ))
  )