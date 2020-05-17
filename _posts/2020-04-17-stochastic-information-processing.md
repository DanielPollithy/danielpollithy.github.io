---
layout: post
published: true
mathjax: true
featured: false
comments: false
title: Stochastic Information Processing
categories:
  - general
  - lecture
---

This is a summary of the lecture Stochastic Information Processing which I
attended in the winter semester 2019/2020. The content has overlaps with
LMA (localization of mobile agents), i.e. Kalman Filter.
In SI it is taught how to convert a generative model into a probabilistic one
and how to confront parametric integrals by means of approximations.

## SI

Unfortunately, I wrote this in German. But the derivations could be interesting
nevertheless.

### Statische Systeme

**Statische Systeme** sind besonders einfache wertediskrete Systeme, in denen die
Ausgabe y nur von der Eingabe u abhängt. Wobei u und y diskrete Zufallsvariablen
sind. Ein statisches System S stellt eine bedingte Wahrscheinlichkeitsverteilung
dar: $P(y=i|u=j)$. Von der Verteilung u zur Verteilung y. Da beide diskreten ZV auf endlichen Mengen definiert sind, können wir S als **stochastische Matrix** A darstellen.
Diese enthält per Konvention $(P(y=i|u=j))_{i,j}$, also pro Zeile die Verteilung
für ein konkretes u. A enthält nur nicht negative Einträge, jede Zeilensumme ist
eins. Wenn zusätzlich auch noch die Spaltensummen ein ergeben, dann spricht man
von einer doppelt-stochastischen Matrix.

Möchte man nun y aus u errechnen, so kann man so vorgehen:

$$ P(y=i) \stackrel{(1)}{=}  \sum_{j=1}^{J}{P(y=i, u=j)}   
          \stackrel{(2)}{=}  \sum_{j=1}^{J}{ P(y=i|u=j) \cdot P(u=j)}
          \stackrel{(3)}{=}  A^T \cdot P(u)
          $$

(1) Satz der totalen W'keit. (2) Konditionierung. (3) Summe als Matrix.

Man sieht also, dass das System nicht deterministisch ist. Unsicherheiten werden
weiter propagiert.

### Dynamische Systeme (diskret)

Der Ausgang $\boldsymbol{y_k}$ hängt von Eingabe $\boldsymbol{u_k}$ und Zustand $\boldsymbol{x_k}$ ab.
Der Zustand fasst die gesamte Historie zusammen. Man unterteilt dyn. Systeme in die **Systemabbildung** (dynamischer Teil) und die statische **Messabbildung**.
Diskrete ZV $\boldsymbol{x_k}$ ist Markov-Kette erster Ordnung, falls gilt:

#### Systemabbildung

$$ P(\boldsymbol{x_{k+1}}|\boldsymbol{x_{k}}, ... \boldsymbol{x_{0}}, \boldsymbol{u_{k}}, ...\boldsymbol{x_{0}}) = P(\boldsymbol{x_{k+1}}|\boldsymbol{x_{k}}) $$

(1. Markoweigenschaft)

Man sagt: $\boldsymbol{x_{k+1}}$ ist bedingt unabhängig von $\boldsymbol{x_{k-1}}$ ... $\boldsymbol{x_{0}}$. Wobei die Bedingung ist, dass $\boldsymbol{x_{k}}$ bekannt ist.

**Achtung!** $\boldsymbol{x_{k+1}}$ ist **nicht unabhängig** von $\boldsymbol{x_{0}}$. Nur bedingt unabhängig. Es folgt also, dass die zukünftige Entwicklung bedingt unabhängig von alten Zuständen ist, falls der aktuelle Zustand bekannt ist.
Man betrachte zum Beispiel einen fallenden Ball. Kennt man den Zustand (Position, Geschwindigkeit, Beschleunigung, etc.) des Balles, so kann man seinen nächsten Zustand ohne Wissen über die Vergangenheit prädizieren.

#### Messabbildung

Der Zustand ist meist **nicht verfügbar** (Wortwahl ist Absicht). Man spricht von
einer "latenten Variable". Stattdessen kann man meist modellieren, wie $y_k$ sein müsste, wenn man einen gewissen Zustand $x_k$ und einen gewissen Eingang $u_k$ hätte.
Diese Abbildung kann man ebenfalls als bedingte W'keit formulieren: $P(y_k=j|x_k=i, u_k=m)$.
Der Einfluss von $u_k$ wird als "Durchgriff" bezeichnet, aber oft weggelassen.
Wenn $y_k$ bedingt unabhängig von allen anderen ZV ist, falls $x_k$ gegeben ist,
so nennt man dies die 2. Markoweigenschaft.

Die diskrete Messabbildung wird als Messmatrix B(i,j) bezeichnet (analog zu A.).

#### Hidden Markov Model (HMM)

Mit folgenden Zutaten kann nun also ein HMM beschrieben werden:

1. Initialer Zustandsvektor
2. Systemabbildung
3. Messabbildung

#### Prädiktion, Filterung und Glättung

Die Aufgabe eines Schätzers in einem solchen System läge zum Beispiel darin,
gegeben die Messungen bis zu einem Zeitpunkt t1, einen einzelnen oder mehrere
Zustände zu einem beliebigen Zeitpunkt t2 zu schätzen.

Dabei unterscheidet man:

- Prädiktion: t2 > t1
- Filterung: t2 = t1 (Man prädiziert von (t2-1) zum aktuellen Zeitschritt und korriegiert
  dann seine Schätzung mit der ebenfalls bekannten Messung)
- Glättung: t2 < t1.
    - "Fixed-Lag smoothing" ähnlich zu Filterung bloß kleiner Lag.
    - "Fixed-Point Smoothing": Der Zeitpunkt, der geschätzt werden soll, steht fest. Es kommen aber immer noch mehr Daten hinein.
    - "Fixed-interval smoothing": Man schätzt alle Zustände bis zum t2=t1-1, verwendet aber nur die Messungen, die bei den aktuellen Zeitpunkten zur Verfügung standen.
    - "Fixed-interval prediction": Man hat nur die Messungen in einem festen Interval, es kommt nicht neues mehr dazu. Diese feste Anzahl an Punkten verwendet man dann um beliebige Prädiktionen zu machen.


#### Wonham Filter

Komplettes rekursives, diskretes Filter unter Verwendung von Einschrittprädiktion.

- Dynamikmodell: $x_{t+1} = A^T x_t$
- Messmodell: $y_t = B^T x_t$

Aus einer Messung auf den Zustand zu schließen, funktioniert wie folgt:

$$ P(x_k|y_{0:k})
    \stackrel{(1)}{=} P(x_k|y_k, y_{0:{k-1}}) \\
    \stackrel{(2)}{=} \frac{P(y_k|x_k, y_{0:{k-1}}) P(x_k|y_{0:{k-1}})}{P(y_k|y_{0:{k-1}})} \\
    \stackrel{(3)}{=} \frac{P(y_k|x_k, y_{0:{k-1}}) P(x_k|y_{0:{k-1}})}{\sum_{i}{P(y_k, x_k=i|y_{0:{k-1}})}} \\
    \stackrel{(4)}{=} \frac{P(y_k|x_k, y_{0:{k-1}}) P(x_k|y_{0:{k-1}})}{\sum_{i}{P(y_k|x_k=i,y_{0:{k-1}}) P(x_k=i|y_{0:{k-1}})}} \\
     \stackrel{(5)}{=} \frac{P(y_k|x_k) P(x_k|y_{0:{k-1}})}{\sum_{i}{P(y_k|x_k=i) P(x_k=i|y_{0:{k-1}})}} \\
$$

(1) Nur andere Schreibweise     

(2) Bayes Regel

(3) Satz der totalen W'keit

(4) Konditionierung

(5) 2. Markovannahme

Für ein konkret beobachtetes Symbol y' bedeutet das, dass man aus der Matrix B die beobachtete Spalte entnimmt. Diese enthält die Likelihood von y' unter allen möglichen Zuständen. Diesen multipliziert man dann mit vom Systemmodell prädizierten Zuständen und normiert. So erhält man einen durch die Beobachtungen verbesserte Schätzung über den Zustand.


```python

# Beispiel: Wie viele Sterne (1-5) hat ein Buch wirklich verdient?
#           Böse Bots bewerten Bücher entweder mit 5 oder 1 Stern.
#           Menschen tendieren zu "nicht extremen" Bewertungen.
#              Also lieber 4 als 5 Sterne geben, obwohl das Buch sehr gut war.
#              Und wenn ein Buch schon gut bewertet wird, dann ist man umso kritischer.


# Starte gleichverteilt
x = np.array([0.2, 0.2, 0.2, 0.2, 0.2])[:, np.newaxis]

A = np.identity(5)

B = np.array([
    [0.60, 0.20, 0.1, 0.01, 0.09],  # Messungen, wenn das Buch 5 Sterne hätte
    [0.10, 0.70, 0.1, 0.01, 0.09],  # Messungen, wenn das Buch 4 Sterne hätte
    [0.09, 0.01, 0.8, 0.01, 0.09],  # Messungen, wenn das Buch 3 Sterne hätte
    [0.09, 0.01, 0.1, 0.70, 0.10],  # Messungen, wenn das Buch 2 Sterne hätte
    [0.09, 0.01, 0.1, 0.20, 0.60],  # Messungen, wenn das Buch 1 Sterne hätte
])

# Wie viele Sterne sollen wir auf unserer Website darstellen, wenn wir folgende
#    Bewertungen erhalten haben
star_ratings= [5, 1, 3, 5, 3, 4, 4, 1, 3, 4, 2]
```


```python

# Rekursive Filterung

print("Kunde bewertet: \t\t 1 Stern \t 2 Sterne \t 3 Sterne \t 4 Sterne \t 5 Sterne")
print("-"*110)

for star_rating in star_ratings:    
    # step prediction
    x = A.T @ x

    # filter.
    # select the column of B for our observed measurement
    B_col = B[:, star_rating-1]

    x = (np.diag(B_col) @ x) / (np.ones(5) @  (np.diag(B_col) @ x))  

    print("{} Sterne \t\t->\t {:.2f} \t\t {:.2f} \t\t {:.2f} \t\t {:.2f} \t\t {:.2f}".format(
        star_rating, x[0,0], x[1,0], x[2,0], x[3,0], x[4,0])
         )

```

    Kunde bewertet: 		 1 Stern 	 2 Sterne 	 3 Sterne 	 4 Sterne 	 5 Sterne
    --------------------------------------------------------------------------------------------------------------
    5 Sterne 		->	 0.09 		 0.09 		 0.09 		 0.10 		 0.62
    1 Sterne 		->	 0.40 		 0.07 		 0.06 		 0.07 		 0.40
    3 Sterne 		->	 0.28 		 0.05 		 0.34 		 0.05 		 0.28
    5 Sterne 		->	 0.11 		 0.02 		 0.13 		 0.02 		 0.72
    3 Sterne 		->	 0.06 		 0.01 		 0.54 		 0.01 		 0.38
    4 Sterne 		->	 0.01 		 0.00 		 0.06 		 0.08 		 0.85
    4 Sterne 		->	 0.00 		 0.00 		 0.00 		 0.25 		 0.74
    1 Sterne 		->	 0.00 		 0.00 		 0.00 		 0.25 		 0.74
    3 Sterne 		->	 0.00 		 0.00 		 0.02 		 0.25 		 0.73
    4 Sterne 		->	 0.00 		 0.00 		 0.00 		 0.54 		 0.46
    2 Sterne 		->	 0.00 		 0.00 		 0.00 		 0.54 		 0.46


### Wertekontinuierliche Systeme

#### Wertekontinuierliche lineare Systeme

Linearität eines System ($A:x\rightarrow y$) besteht dann, wenn folgende zwei Eigenschaften vorliegen:

1. Skalierung: $A(c \cdot x) = c \cdot A(x)$
2. Superposition: $A(x_1 + x_2) = A(x_1) + A(x_2)$

In der Realität existieren lineare Systeme nur in gewissen Grenzen.

#### Statisches System

$ y_k = f(u_k) $, wobei $u_k \in R^{P}$ und $y_k \in R^{M}$

Für $f$ linear kann man schreiben: $y_k = A_k u_k$ mit $A \in R^{MxP}$.

Dieses generative Modell wird stochastisch, wenn $u_k$ eine W'keitsverteilung ist oder man endogenes Rauschen hinzufügt (also Rauschen im System). Dafür erweitert man $u_k$ zu $u_{k}^{*} = [u_k, w_k]$, wobei $w_k$ das Rauschen zusammenfasst.

Die Unsicherheiten in $u_k$ und $y_k$ beschreibt man oft mit den ersten beiden Momenten dieser vektoriellen ZV (Erwartungswert und Kovarianzmatrix).

Wir definieren $\hat{u}_k = E[u_k]$ und $C_k^u = Cov[u_k]$

#### Wichtige Erinnerung

Die Linearität des Erwartungswertes liefert für ein lineares System: $E[y_k] = E[A_k u_k] = A_k E[u_k] = A_k \hat{u}_k$.

Und die Kovarianz: $Cov[y_k] = Cov[y_k] = E[(E[y_k] - y_k)^2] = E[ (\hat{y}_k - y_k)^2 ] = E[ (A \hat{u}_k - A u_k)^2 ] = E[(A (\hat{u}_k - u_k))^2] = E[A ( \hat{u}_k - u_k)^2 A^T] = A E[ ( \hat{u}_k - u_k)^2 ] A^T = A Cov_k^u A^T$

#### Dynamische Systeme

Lineare Entwicklung des Zustandes: $x_{k+1} = A_k x_k + B_k u_k$ (Markovkette 1. Ordnung, zeitvariant, ohne k wäre es zeitinvariant).

Additives Rauschen: $u_k = \hat{u}_k + w_k$, wobei $w_k$ ein Zufallsvektor mit $E[w_k]=0$ und $Cov[w_k]=C_k^w$

Messmodell: Zustand nicht **verfügbar**. Achtung: Verfügbarkeit heißt, dass man eine Größe nicht messen kann, wobei **Beobachtbarkeit** bedeutet, dass man mit Messungen auf die Größe schließen kann. Der verdeckte Zustand ist nicht verfügbar, aber beobachtbar. Beispiel: Position eines Autos in Foto ist verfügbar, Geschwindigkeit nur über mehrere Frames beobachtbar.

Lineare Messabbilung: $y_k = H_k x_k + v_k$ wobei $v_k$ wieder additives Rauschen ist.

### Kalman Filter


#### Prädiktionsschritt

$x_{k+1} = A_k x_k + B_k (\hat{u}_k + w_k)$

$E[x_{k+1}] = E[A_k x_k + B_k (\hat{u}_k + w_k)] = E[A_k x_k] + E[B_k (\hat{u}_k + w_k)] = A_k \hat{x}_k + B_k E[\hat{u}_k + w_k] = A_k \hat{x}_k + B_k E[\hat{u}_k + w_k] = A_k \hat{x}_k + B_k \hat{u}$

Notiz: $E[w_k] = 0$ per Definition. Wenn er nicht null wäre, aber bekannt, so könnte man ihn von $w_k$ abziehen. Wenn er nicht bekannt wäre, dann müsste man diesen ebenfalls schätzen.

$Cov[x_{k+1}] = Cov[A_k x_k + B_k (\hat{u}_k + w_k)] = A_k C_k^x A_k^T + B_k C_k^w B_k^T$

**Trick:**

Um die Kovarianz zu berechnen, definiert man $A_k^{*} = [A_k, B_k]$ und $x_k^{*} = [x_k, u_k]^T$.

Rauschen sei unabhängig von Zustand. Dann sieht $Cov[x_k^{*}]$ wie folgt aus: $\begin{bmatrix}C_k^x & 0\\0 & C_k^w\end{bmatrix}$



Dann geht:

$$Cov[x_{k+1}^{*}] = E[(x_k^{*} - \hat{x_k^{*}})^2] = E[(x_k^{*} - \hat{x_k^{*}}) (x_k^{*} - \hat{x_k^{*}})^T]$$

$$ = E[A_k^{*} \cdot \begin{bmatrix} x_k - \hat{x_k} \\ u_k - \hat{u_k} \end{bmatrix} \cdot [(x_k - \hat{x_k})^T , (u_k - \hat{u_k})^T] \cdot {A_k^{*}}^T ] $$

$$ = A_k^{*}  \cdot  E[\begin{bmatrix} x_k - \hat{x_k} \\ u_k - \hat{u_k} \end{bmatrix} \cdot [(x_k - \hat{x_k})^T , (u_k - \hat{u_k})^T]  ]  \cdot  {A_k^{*}}^T$$

Da die Kovarianz mittelwertbefreit ist, folgt:

$$ = A_k^{*}  \cdot  Cov[ \begin{bmatrix} x_k \\ u_k \end{bmatrix} ]  \cdot  {A_k^{*}}^T$$

$$ = A_k^{*}  \cdot  \begin{bmatrix}C_k^x & 0\\0 & C_k^w\end{bmatrix}  \cdot  {A_k^{*}}^T$$

$$ = [A_k, B_k]  \cdot  \begin{bmatrix}C_k^x & 0\\0 & C_k^w\end{bmatrix}  \cdot  \begin{bmatrix}A_k^T \\ B_k^T \end{bmatrix}$$

$$ = A_k C_k^x A_k^T + B_k C_k^w B_k^T $$



#### Kalman Filterschritt

Lineare Messabbildung: $y_k = H_k x_k + v_k$ "Was für eine Messung erwarte ich?"

Die Kombination von Vorwissen und Messung ermöglicht es, auf einen höherdimensionalen verdeckten Zustand zu schließen:

$x_k^p = K_k^1 x_k + K_k^2 y_k$ (Der Filterschritt ist eine gewichtete Linearkombination)

Gesucht ist das BLUE filter (Best linear unbiased estimator). Linear ist er ja schon.

Unbiased: $E[x_k] = \tilde{x_k}$ Wobei $\tilde{x_k}$ die Grundwahrheit ist.


$$ E[x_k^p] = E[K_k^1 x_k + K_k^2 y_k] = K_k^1 E[x_k] + K_k^2 E[y_k] = K_k^1 E[x_k] + K_k^2 H_k E[x_k] + E[v_k] = K_k^1 E[x_k] + K_k^2 H_k E[y_k] = K_k^1 \tilde{x_k} + K_k^2 H_k \tilde{x_k}$$

$$ K_k^1 \tilde{x_k} + K_k^2 H_k \tilde{x_k} = \tilde{x_k}$$

$$ K_k^1 + K_k^2 H_k = I$$

$$ K_k^1 = I - K_k^2 H_k $$

=> Dadurch kann man die Linearkombination mit nur einer Matrix $K_k$ ausdrücken:

$$ x_k^p = (I - K_k^2 H_k) x_k + K_k^2 y_k = (I - K_k H_k) x_k + K_k y_k $$

Die Frage ist nun, wie bestimmen wir das optimale K? Wir suchen das K, für das die prädizierte Kovarianz $C_k^e$ minimal wird.


$$ C_k^e = Cov[x_k^p] = (I - K_k H_k) C_k^x (I - K_k H_k)^T + K_k C_k^y K_k^T   $$

$C_k^e$ ist abhängig von $K_k$. Daher schreiben wir: $C_k^p(K_k)$

$C_k^p(K_k)$ ist positiv definit und symmetrisch, das heißt, es handelt sich um eine Kovarianzmatrix.
Wie minimiert man das?

Man könnte $det(C_k^p(K_k))$ oder $trace(C_k^p(K_k))$ minimieren. Beide sind proportional zum Flächeninhalt der Kovarianzellipse. Die Determinante ist 1/4 des umschließenden Rechteckes. Die Spur hat die Größe des größten Quaders, der in die Ellipse hineinpasst.

Wenn man die Determinante minimiert, dann ist es theoretisch möglich, dass eine Richtung 0 wird. Dadurch wird der Flächeninhalt null und die Covarianz ist minimal. Das ist unschön, weil man die Unsicherheit in alle Richtungen minimieren will.

Daher verwenden wir die Projektion der Matrix auf alle möglichen Einheitsvektoren e. Diese Projektion P(K) liefert ein skalares Gütemaß, welches wir minimieren.

$$ P(K_k) = e^T C_k^e(K_k) e $$.

**Ableitungsregeln für Matrizen:**

Matrix C:

 - $ d/dC (a^T C b) = a^T b $  ($a^T b$ ist diadisches Produkt, also eine singuläre Matrix. Rang=1. det=0. nicht invertierbar.)

 - $ d/dK (a^T K C K^T b) = ab^T K C^T + ba^T K C $ (KCK^T ist ein lineare Propagation, evtl. Basiswechsel. a^T ... b  ist eine Projektion.)

 - wenn a=b=e und C symm., dann: $ d/dK (e^T K C K^T e) = 2 ee^T KC $

jetzt können wir $P(K_k)$ ableiten:










$$\frac{d}{dK_k} e^T C_k^e(K_k) e = $$


$$ \frac{d}{dK_k} e^T ((I - K_k H_k) C_k^x (I - K_k H_k)^T + K_k C_k^y K_k^T) e = $$

$$ \frac{d}{dK_k} e^T ( (I C_k^x I^T) - (I C_k^x H_k^T K_k^T) - (K_k H_k C_k^x I^T) + (K_k H_k C_k^x H_k^T K_k^T)  +   K_k C_k^y K_k^T) e = $$

Erster Summand fällt weg, weil er kein K enthält.

$$ \frac{d}{dK_k} e^T ( - (I C_k^x H_k^T K_k^T) - (K_k H_k C_k^x I^T) + (K_k H_k C_k^x H_k^T K_k^T)  +   K_k C_k^y K_k^T) e = $$

Projektion auf alle Summanden anwenden:

$$ \frac{d}{dK_k} - e^T (I C_k^x H_k^T K_k^T) e - e^T (K_k H_k C_k^x I^T) e + e^T (K_k H_k C_k^x H_k^T K_k^T) e  +  e^T ( K_k C_k^y K_k^T) e$$

1. Summand (Mit $D^T = C_k^x H_k^T$ und)
    $$\frac{d}{dK_k} - e^T (I C_k^x H_k^T K_k^T) e = $$

    $$ (\frac{d}{dK_k^T} - (e^T (D^T K_k^T) e))^T = - (D ee^T)^T = - (H_k C_k^x ee^T)^T $$

- 2 Summand:
    $$ - ee^T (H_k C_k^x)^T $$

- 3 Summand:
    $$ 2 ee^T K_k H_k C_k^x H_k^T $$

- 4 Summand:
    $$ 2 ee^T K_k C_k^y $$

Daraus folgt:

$$ \frac{d}{dK_k} - e^T (I C_k^x H_k^T K_k^T) e - e^T (K_k H_k C_k^x I^T) e + e^T (K_k H_k C_k^x H_k^T K_k^T) e  +  e^T ( K_k C_k^y K_k^T) e$$

$$ = - (H_k C_k^x ee^T)^T  - ee^T (H_k C_k^x)^T   + 2 ee^T K_k H_k C_k^x H_k^T  + 2 ee^T K_k C_k^y$$

Setzen wir Null:

$$ - (H_k C_k^x ee^T)^T  - ee^T (H_k C_k^x)^T   + 2 ee^T K_k H_k C_k^x H_k^T  + 2 ee^T K_k C_k^y  \stackrel{!}{=}  0 $$

$$ = ee^T [-{C_k^x}^T H_k^T  - {C_k^x}^T H_k^T  + 2 K_k H_k C_k^x H_k^T  + 2 K_k C_k^y ]$$

$$ = ee^T [-2{C_k^x}^T H_k^T  + 2 K_k H_k C_k^x H_k^T  + 2 K_k C_k^y ]$$

Wir multiplizieren beidseitig mit $({ee^T})^{-1}$:

$$ -2{C_k^x}^T H_k^T  + 2 K_k H_k C_k^x H_k^T  + 2 K_k C_k^y  = 0 $$

$$ + 2 K_k H_k C_k^x H_k^T  + 2 K_k C_k^y = +2{C_k^x}^T H_k^T  $$

Teilen durch 2:

$$ K_k H_k C_k^x H_k^T  + K_k C_k^y = {C_k^x}^T H_k^T  $$

Klammern $K_k$ aus:

$$ K_k (H_k C_k^x H_k^T + C_k^y) = {C_k^x}^T H_k^T  $$

Und multiplizieren rechtseitig mit  $(H_k C_k^x H_k^T + C_k^y)^{-1}$, um $K_k$ alleine zu stellen:

$$ K_k = (C_k^x)^T H_k^T (H_k C_k^x H_k^T + C_k^y)^{-1}$$

Das Transponierte der Kovarianzmatrix ist immernoch die Kovarianzmatrix, da sie symmetrisch ist:

$$ K_k = C_k^x H_k^T (H_k C_k^x H_k^T + C_k^y)^{-1}$$

$K_k$ heißt **Kalman Gain** und ist optimal, wenn:

1. das Filter linear ist und
2. die Zufallsvariablen normalverteilt sind (zum Beispiel additives, normalverteiltes Rauschen)

Somit ergibt sich:

$$ E[x_k^e] = (I - K_k H_k) E[x_k^p] + K_k E[y_k] $$

Und:

$$ C_k^e = Cov[x_k^p] = (I - K_k H_k) C_k^x (I - K_k H_k)^T + K_k C_k^y K_k^T $$
$$...$$
$$ C_k^e = C_k^p - K_k H_k C_k^p$$

Für intuitive Anschauungen eignet es sich die **Feedback Form** zu betrachten:

$$ \hat{x_k^e} = \hat{x_k^p} + K_k (\hat{y_k} - H_k \hat{x_k^p}) $$

Hieran lässt sich erkennen, dass der geschätzte Zustand nach einem Messupdate eine Kombination des priori Zustandes mit dem neuen Wissen aus der Messung ist. Wenn das Kalman Gain hoch ist, dann wird die Messung mit geringer Unsicherheit gesehen und somit werden starke Abweichungen der Messung von der erwarteten Messung stark auf den neuen Zustand einfließen. Wenn das Messrauschen unendlich groß wäre, dann wäre $K_k=0.$

## Allgemeine Systeme

### Statische Systeme

Generatives Modell (Werte abgebildet auf Werte):
$$\underline{\mathbf{y}_k} = a(\underline{\mathbf{u}_k})$$

Jetzt sind aber $u_k$ und $y_k$ durch die W'keitsverteilungsdichtefunktionen (kurz "Dichten") $f_k^u(\underline{\mathbf{u}_k})$ und $f_k^y(\underline{\mathbf{y}_k})$

Würde man nun einfach trotzdem mit Erwartungswert und Kovarianz weiterrechnen, anstatt die Dichten zu betrachten, dann wäre das eine Linearisierung, wie sie beim EKF vorgenommen wird.

Gesucht ist also die Dichte $f_k^y(\underline{\mathbf{y}_k})$ zur gegebenen Dichte $f_k^u(\underline{\mathbf{u}_k})$. Ein Abbildung von einer Dichte zu einer anderen Dichte nennen wir probabilistisches Modell.

### Dynamische Systeme

Diese zerfallen wieder in das Beobachtungsmodell und die Systemabbildung.

Ein "einfacheres" nichtlineares Systemmodell: $$x_{k+1} = a_k(x_k, \hat{u}_k, w_k)$$

Es wäre schwieriger, wenn $x_{x+1}$ auch auf der rechten Seite vorkäme, dann spricht man von einem impliziten System. Dieser Fall wurde in LMA behandelt.)

Für additives Rauschen kommt man leicht vom generativen zu einem probabilistischen Modell:

$$ x_{k+1} = a(x_k, \hat{u}_k) + w_k$$

Das Systemrauschen $$w_k$$ ist hier additiv und wird beschrieben durch die Dichte $f_k^w(w_k)$.

Zusätzlich gehen wir davon aus, dass das Systemrauschen:

1. Gaussverteil ist mit bekannten Parametern.
2. $f_k^w(w_k)$ für unterschiedliche k unabhängig voneinander sind. Im Falle von Gaußverteilung reicht **unkorreliert**, da in diesem Fall unabhängig daraus folgt. Dann gilt für die gemeinsame Verteilung zweier  Rauschdichten: $f_{1,2}^w(w_1, w_2) = f_1^w(w_1) \cdot f_2^w(w_2)$

Bei der Messabbildung kann genauso verfahren werden: $$ y_k = h_k(x_k) + v_k $$


**Was für Dichten können wir verwenden?**

- Kontinuierliche analytische Dichten
    - Gaußdichte
    - GMM
    - Exponentialdichte (Exponenten komplexer machen)
    - Edgeworth-Entwicklungen (Gaußdichte mit Polynom multipliziert. Nichts globales, aber lokal bekommt man ein paar Hügel rein).
- Diskrete Dichten auf kontinuierlichen Domänen
    - Dirac-Mixture Densities

### Blick auf Gaußdichte

2d:
$$f_{x,y}(x,y) = N(\begin{bmatrix}x\\y\end{bmatrix} - \begin{bmatrix}\hat{x}\\\hat{y}\end{bmatrix}, \begin{bmatrix}\sigma_x^2 & \rho \sigma_x \sigma_y \\ \rho \sigma_x \sigma_y & \sigma_y^2  \end{bmatrix})$$

Wobei $\rho \in [-1, +1]$ als Korrelationskoeffizient bezeichnet wird. Wenn dieser =+1 ist, dann lieft eine deterministische Abhängigkeit vor.

Man schreibt manchmal:
$$ f_{x,y}(x,y) = \frac{1}{2 \pi \sigma_x \sigma_y \sqrt{(1-\rho^2)}} \exp(-\frac{1}{2}Q(x,y)) $$

mit $$ Q(x,y) = \frac{1}{1-\rho} \Big(  \frac{(x-\hat{x})^2}{\sigma_x^2} +  \frac{(y-\hat{y})^2}{\sigma_y^2}   - 2 \rho \frac{x-\hat{x}}{\sigma_x} \frac{y-\hat{y}}{\sigma_y}    \Big)$$

Maßgrößen für Kovarianzen:

- die Determinante von Cov det(C) ist proportional zum Volumen der Kovarianz-Körpers, da die Determinante das Produkt der Eigenwerte ist. Somit ist im 2d-Fall zum Beispiel 4*det(C) die Fläche des umschließenden Rechtecks.
- Spur (Summe der Quadrate der Diagonale): Nach Pythagoras ist die Spur einer diagonalen Kovarianzmatrix das Quadrat der der Länge ... -> Wurzel ... Vorteil: Spur invariant ggü. unitärer Rotation. Selbst wenn ein Eigenwert mal 0 sein sollte, dann ist die Spur immernoch nicht null.

### Moment Matching

Berechne die Verteilung einer Population anhand ihrer Momente. Angenommen wir haben eine Stichprobe aus der Population genommen. Nun könnten wir zum Beispiel die empirischen 1. und 2. Momente berechnen. Empirischer Mittelwert und empirische Varianz. Nun wählen wir eine beliebige Verteilungsfunktion. Jetzt können wir Parameter für die Verteilung bestimmen, die empirischen Momente liefern. Diese Methode ist besser per Hand zu rechnen und kann zum Beispiel auch als Initialisierung für eine Maximum-Likelihood-Schätzung verwendet werden.


Theorem: Für eine gegebene Dichte $\tilde{f}(x)$ führt die Wahl von $m=E_{\tilde{f}}[x]$ und $\sigma^2=Cov_{\tilde{f}}[x]$, zu einer Minimierung der Kullback-Leibler-Divergenz zwischen $\tilde{f}$ und der Normalverteilung.

$$ KL = \int_{R} {  \tilde{f}(x) log\big( \frac{\tilde{f}(x)}{f(x)}  \big)  } dx $$

**Offene Frage:** Warum $\tilde{f}(x)$ als Vorfaktor?

Das i-te zentrale Momente einer Gaußdichte lautet:

$$ C_i = E[(x-x)^{i}] $$

Ein zentrales Moment ist das gleiche, wie ein "normales" Moment, bloß, dass man die Dichte um Null zentriert hat.

ToDo: Beschreibe, wie man Momente generell berechnen kann.

**GMM**: $f(x) = \sum_{i=1}^{L}{w_i N(\hat{x}_i, \sigma_i)}$

- Anzahl Moden ist ungleich Anzahl Komponenten -> Maximum bestimmen nicht trivial
- Wir akzeptieren nur $w_i > 0$. Theoretisch geht es aber auch anders. Und Summe der Gewichte muss 1 sein.
- **Ein GMM mit L Komponenten hat 3L-1 Freiheitsgrade**

### Diracsche Deltafunktion

$\delta(x-x_0) = $ ...

- nicht definiert, für $x=x_0$
- 0, für alles andere

Mit $\int_{R}{\delta(x-x_0) dx} = 1$

Sie besitzt die **Ausblendeigenschaft**:

- $\int f(x) \delta(x-x_0) dx = f(x_0)$
- Auch: $f(x) \cdot \delta(x-x_0) = f(x_0) \cdot \delta(x-x_0)$
    - Fall $x=x_0$: $f(x_0) = f(x_0)$
    - Sonst: 0

Allgemein gilt:

$$ \delta(f(x)) = \sum_{i=1}^{N}{\frac{1}{|f'(x_i)|} \delta(x-x_i) } $$

$x_i$ sind die N Nullstellen der Funktion f(x). $f(x) \ne 0$

Beweis dazu: https://math.stackexchange.com/questions/276583/dirac-delta-function-of-a-function.


(Eine sehr umfassende Sammlung von Eigenschaften der diracschen Delta-Funktion: https://mathworld.wolfram.com/DeltaFunction.html)

Beispiele generatives Modell zu bedingter Dichte:

$y = 3 * x$ -----> $f(y|x) = \delta(y-3x)$

$y = a(x) + w$ -----> $f(y|x,w) = \delta(y-a(x)-w)$

Bei den bedingten Dichten handelt es sich also um dirac distributionen, die nur dort ungleich Null sind, wo die Funktion wahr ist.

#### Additives Rauschen

$$x_{k+1} = a_k(x_k) + w_k$$

$$ f^{x_{k+1}}(x_{k+1}| x_k, w_k) = \delta(a_k(x_k) + w_k - x_{k+1}) $$

$$ f^{x_{k+1}}(x_{k+1}| x_k) = \int{f^{x_{k+1}, w_k}(x_{k+1}, w_k| x_k) d w_k} $$

$$ f^{x_{k+1}}(x_{k+1}| x_k) = \int{f^{x_{k+1}}(x_{k+1}|x_k, w_k) \cdot f^w(w_k|x_k) d w_k} $$

Hier nehmen wir jetzt an, dass das Rauschen unabhängig von den Daten ist.

$$ f^{x_{k+1}}(x_{k+1}| x_k) = \int{f^{x_{k+1}}(x_{k+1}|x_k, w_k) \cdot f^w(w_k) d w_k} $$

Jetzt Dirac einsetzen:

$$ f^{x_{k+1}}(x_{k+1}| x_k) = \int{\delta(a_k(x_k) + w_k - x_{k+1}) \cdot f^w(w_k) d w_k} $$

Für welches $w_k$ ist der Dirac-Stoß ungleich Null? (vgl. $\delta(w_k - w_{k,0})$)

$$ a_k(x_k) + w_k - x_{k+1} = 0 $$

$$ w_k  = x_{k+1} - a_k(x_k) $$

Durch Siebeigenschaft des Dirac folgt:

$$ f^{x_{k+1}}(x_{k+1}| x_k) = f^w(x_{k+1} - a_k(x_k) ) $$

Was eine bequeme Form für additives Rauschen ist. Wenn das Rauschen zum Beispiel normalverteilt ist, dann ist die Transitionsdichte für ein gegebens x_k ebenfalls normalverteilt.

#### Multiplikatives Rauschen

$ x_{k+1} = x_k \cdot w_k $ mit $w_k \sim f_k^w(w_k)$

$$ f(x_{k+1}|x_k, w_k) = \delta(g(w_k)) $$

$$ g(w_k) = x_k w_k - x_{k+1}$$

Finde Nullstellen von g:

$$ x_k w_k - x_{k+1} = 0 $$

$$ x_k w_k  = x_{k+1}$$

$$ w_k  = \frac{x_{k+1}}{x_k}$$

$$\frac{d}{d w_k} g(w_k) = x_k$$

Daraus folgt:

$$\delta(g(w_k)) = \frac{1}{|x_k|} \delta(w_{k} - \frac{x_{k+1}}{x_k})$$

$$ f(x_{k+1}|x_k) = \int{f(x_{k+1}|x_k, w_k) f_k^w(w_k) d w_k} $$

$$ f(x_{k+1}|x_k) = \int{\delta(g(w_k)) f_k^w(w_k) d w_k} $$

$$ f(x_{k+1}|x_k) = \int{\frac{1}{|x_k|} \delta(w_{k} - \frac{x_{k+1}}{x_k}) f_k^w(w_k) d w_k} $$

$$ f(x_{k+1}|x_k) = \frac{1}{|x_k|} f_k^w(\frac{x_{k+1}}{x_k}) $$

### Visualisierung der Transitionsdichte

y = a(x) + w

y = x + N(0, 1)

$$f(y|x) = \int{f(y|x,w) \cdot f(w) dw} = f^w(y - a(x)) = f^w(y - x)$$

$$f(y|x) = N(y - x)$$



```python
from scipy.stats import norm
```


```python
%matplotlib notebook
```


```python

step = 0.5

x = np.arange(0, 10, step)
y = np.arange(0, 10, step*0.1)
z = np.arange(0, 10, step)

X, Y = np.meshgrid(x, y)

f = norm.pdf(Y-X, 0.1)



fig = plt.figure()
ax = fig.gca(projection='3d')

surf = ax.plot_surface(X, Y, f, cmap=cm.coolwarm,
                       linewidth=0, antialiased=True)

# Add a color bar which maps values to colors.
fig.colorbar(surf, shrink=0.5, aspect=5)

plt.xlabel("$x_k$")
plt.ylabel("$y_k$")
ax.set_zlabel("$P(y|x)$")

plt.show()
```


    <IPython.core.display.Javascript object>



<img src="data:image/png;base64,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fk+ePFG8O0hERG8OA5CIiIhIZBiARERERCLDACQiIiISGQYgERERkcgwAImIiIhEhgFIREREJDIMQCIiIiKRYQASERERiQwDkIiIiEhkGIBEREREIsMAJCIiIhIZBiARERGRyDAAiYiIiESGAUhEREQkMgxAIiIiIpFhABIRERGJDAOQiIiISGQYgEREREQiwwAkIiIiEhkGIBEREZHIMACJiIiIRIYBSERERCQyDEAiIiIikWEAEhEREYkMA5CIiIhIZBiARERERCLDACQiIiISGQYgERERkcgwAImIiIhEhgFIREREJDIMQCIiIiKRYQASERERiQwDkIiIiEhkGIBEREREIsMAJCIiIhIZBiARERGRyDAAiYiIiESGAUhEREQkMgxAIiIiIpFhABIRERGJDAOQiIiISGQYgEREREQiwwAkIiIiEhkGIBEREZHIMACJiIiIRIYBSERERCQyDEAiIiIikWEAEhEREYkMA5CIiIhIZBiARERERCLDACQiIiISGQYgERERkcgwAImIiIhEhgFIREREJDIMQCIiIiKRYQASERERiQwDkIiIiEhkGIBEREREIsMAJCIiIhIZBiARERGRyDAAiYiIiESGAUhEREQkMgxAIiIiIpFhABIRERGJDAOQiIiISGQYgEREREQiwwAkIiIiEhkGIBEREZHIMACJiIiIRIYBSERERCQyDEAiIiIikWEAEhEREYkMA5CIiIhIZBiARERERCLDACQiIiISGQYgERERkcgwAImIiIhEhgFIREREJDIMQCIiIiKRYQASERERiQwDkIiIiEhkGIBEREREIsMAJCIiIhIZBiARERGRyDAAiYiIiESGAUhEREQkMgxAIiIiIpH5/7hsKg08ijc9AAAAAElFTkSuQmCC" width="640">


Dieser Plot ist so zu sehen, dass für jedes gegeben $\hat{x}_k$ eine Normalverteilung vorliegt. Die Verbundwahrscheinlichkeit von $P(x,y)$ im Diskreten oder $f^{x,y}(x,y)$ im Kontinuierlichen hängt von $x_k$ ab.
Im Diskreten kann man folgenden Satz nutzen: $P(X \cap Y) = P(X|Y) \cdot P(Y) = P(Y|X) \cdot P(X)$.

### Chapman-Kolmogorov-Integral (CKI)

Betrachten wir einen stochastischen Prozess $(x)_k$ bei dem wir die 1. Markov-Eigenschaft annehmen.

$$ f(x_{k+1}) = \int_{R}{ f(x_{k+1}|x_k) \cdot f(x_k)  d x } $$

Wir berechnen die Transitionsdichte zunächst weiterhin mit der dirachsen Delta-Funktion.
Für den Trivialfall, dass $f(x_k)$ deterministisch (also dirac-verteilt) ist, löst sich das Intergral noch von selbst auf.

Das Hauptproblem ist, dass es sich beim CKI um ein Parameterintegral handelt.
Das heißt, es ist nicht nur abhängig von der Integriervariable $x_k$, sondern auch noch von anderen "freien" Variablen. In diesem Fall $x_{k+1}$.


### Beobachtungen einfließen lassen

Gegeben einer Beobachtung $\hat{y}$ müssen wir uns entscheiden, was für eine Art von Schätzer wir haben wollen:

Maximum-Likelihood: $$arg_x max f(\hat{y}|x)$$
Maximum-A-Posteriori: $$arg_x max f(x|\hat{y})$$

Angenommen wir haben das folgende generative Modell: $y = x^2 + v$
Dann erhalten wir $$f(y|x,v) = \delta(y-x^2-v)$$

Interessieren wir uns für $f(x|\hat{y})$:

$$ f(x|\hat{y}) = \frac{f(x, \hat{y})}{f(\hat{y})} = \frac{f(\hat{y}|x) f(x)}{f(\hat{y})} $$
