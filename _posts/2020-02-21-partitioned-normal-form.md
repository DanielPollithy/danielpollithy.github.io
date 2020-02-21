---
layout: post
published: true
mathjax: true
featured: false
comments: false
title: Partitioned Normal Form
categories:
  - general
---
What is the Partitioned Normal Form (PNF) in the context of databases? 

## NF²

NF² = NFNF = ¬NF = Non-First-Normal-Form. 

The First Normal Form (1NF) is too restrictive. 
NF² allows attributes themselves to be relations. 
Attribute values can be sets.

| A | D |   |
|---|---|---|
| A | B | C |
|---|---|---|
| 1 | 2 | 3 |
|   | 4 | 2 |
| 2 | 1 | 1 |
|   | 4 | 1 |
| 3 | 1 | 1 |

(Table 1: NF² and PNF)

The construction of an algebra which has the same expressive strength as relational algebra is more possible, but more complicated and it employs the operators $$nest_{...}{(Relation)}$$ and $$unnest_{...}{(Relation)}$$.
Each of them is generally not commuative.

## PNF

PNF is a subset of NF² with nicer properties. The construction of the algebra is easier. 

The special properties are:

1. In the partitioned normal form the nest operator is commutative!
2. The PNF can be unnested into a 1NF.
3. On every nesting layer there exists a flat key. (In table 1 the key is the attribute A)

The table above is also in PNF.

More formally expressed:

**Recursive definition of PNF**:

 - A relation R has a set of unnested (atomic) attributes A. A is not the empty set.
 - The relation can also have nested (composite) attributes X. X can be the empty set.
 - There exists a functional dependency: A -> X
 - for every tuple in R: 
   -  for every complex attribute x in X:
      - value of the complex attribute t.x is in PNF again.

The last point means, that we can construct a PNF from PNFs.

## NF² but not PNF?

Constructing a relation, which is not in PNF but in NF², can be achieved by breaking the recursive construction rules. The easiest is the "flat key" rule. If we change the values of the column A from (1,2,3) to (1,1,2) then we removed the total functional dependency between A and D. 

A -> D is now an incorrect statement, therefore the relation is not in PNF anymore. Due to the fact that we have not changed anything about the structure of the relation, it is still in NF².

| A | D |   |
|---|---|---|
| A | B | C |
|---|---|---|
| 1 | 2 | 3 |
|   | 4 | 2 |
| 1 | 1 | 3 |
|   | 4 | 1 |
| 2 | 1 | 1 |

(Table 2)