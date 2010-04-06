#!/usr/bin/env clj

; Define and load all the libraries into our namespace that we want all binds for:
(def *supported-libraries* ['clojure.core 'clojure.contrib.duck-streams 'clojure.contrib.seq-utils 'clojure.contrib.str-utils 'clojure.contrib.repl-utils])
(doseq [k *supported-libraries*] (use k))
          
          
(defn print-public-binds
  "Prints all binds defined in library $s."
  [s]
  (doseq [k (keys (ns-publics s))] (println k)))


(doseq [s *supported-libraries*] (print-public-binds s))

(defn vrange [n]
  "A quicksort algorithm using a variadic function:
  http://en.wikipedia.org/wiki/Variadic_function
  like this."
  (loop [i 0 v []]
    (if (< i n)
      (recur (inc i) (conj v i))
      v)))

(use '[clojure.contrib.seq-utils :only (group-by)])
 
(defstruct employee :Name :ID :Salary :Department)
 
(def data
     (->> '(("Tyler Bennett" E10297 32000 D101)
            ("John Rappl" E21437 47000 D050)
            ("George Woltman" E00127 53500 D101)
            ("Adam Smith" E63535 18000 D202)